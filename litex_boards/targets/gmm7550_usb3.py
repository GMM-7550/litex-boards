#!/usr/bin/env python3

#
# This file is part of LiteX-Boards.
#
# Copyright (c) 2026 Anton Kuzmin <ak@gmm7550.dev>
#
# based on litex_boards/targets/colognechip_gatemate_evb.py
# Copyright (c) 2023 Gwenhael Goavec-merou<gwenhael.goavec-merou@trabucayre.com>
# SPDX-License-Identifier: BSD-2-Clause

from migen import *
from migen.fhdl.specials import Tristate

from litex.gen import *

from litex_boards.platforms import gmm7550

from litex.build.io import CRG

from litex.soc.cores.clock.colognechip import GateMatePLL

from litex.soc.interconnect import wishbone
from litex.soc.interconnect.csr import *

from litex.soc.integration.soc_core import *
from litex.soc.integration.builder import *
from litex.soc.integration.soc import SoCRegion

from litex.build.generic_platform import Pins, Subsignal

from litex.soc.cores.led import LedChaser
from litex.soc.cores.gpio import GPIOOut

# USB 3 Adapter board IOs -------------------------------------------------------

# P4/J4 (South IO)
p4 = [
    # LEDs (green)
    ("leds", 0, Pins("P4:5",    # D10
                     "P4:9",    # D9
                     "P4:6",    # D8
                     "P4:10")), # D7

    # Buttons
    ("btn_n", 0, Pins("P4:3")), # SW2, A
    ("btn_n", 1, Pins("P4:4")), # SW3, B

    # USB-C Power Delivery Controller (OnSemi FUSB303B)
    ("pd", 0,
     Subsignal("en_n", Pins("P4:15")),
     Subsignal("scl",  Pins("P4:11")),
     Subsignal("sda",  Pins("P4:12")),
     Subsignal("alert_n",  Pins("P4:16")),
     # Power Delivery Switch control
     Subsignal("src_en", Pins("P4:21")),
     Subsignal("disc",   Pins("P4:22")),
     ),

    # USB 1.1 (STmicro STUSB03E transceiver)
    ("usb1", 0,
     Subsignal("vp",     Pins("P4:50")),
     Subsignal("vm",     Pins("P4:52")),
     Subsignal("rcv",    Pins("P4:51")),
     Subsignal("busdet", Pins("P4:55")),
     Subsignal("oe_n",   Pins("P4:57")),
     Subsignal("con",    Pins("P4:56")),
     Subsignal("sus",    Pins("P4:58")),
     ),

    # USB 2.0 (ULPI, Microchip USB3340 PHY)
    ("ulpi", 0,
     Subsignal("clk",   Pins("P4:23")), # CLK 1, 60 MHz
     Subsignal("stp",   Pins("P4:28")),
     Subsignal("dir",   Pins("P4:30")),
     Subsignal("nxt",   Pins("P4:37")),
     Subsignal("rst_n", Pins("P4:24")),
     Subsignal("data",  Pins("P4:39", # 0
                             "P4:43", # 1
                             "P4:45", # 2
                             "P4:49", # 3
                             "P4:38", # 4
                             "P4:40", # 5
                             "P4:44", # 6
                             "P4:46", # 7
                             )),
     ),
]

# Memory Module (SRAM and SPI) on P2 (North) ------------------------------------

p2 = [
    ("p2_spiflash", 0,
        Subsignal("cs_n", Pins("P2:3")),
        Subsignal("clk",  Pins("P2:6")),
        Subsignal("mosi", Pins("P2:11")), # D0
        Subsignal("miso", Pins("P2:5")),  # D1
        Subsignal("wp",   Pins("P2:9")),  # D2
        Subsignal("hold", Pins("P2:4")),  # D3
    ),
    ("p2_spiflash4x", 0,
        Subsignal("cs_n", Pins("P2:3")),
        Subsignal("clk",  Pins("P2:6")),
        Subsignal("dq",   Pins("P2:11 P2:5 P2:9 P2:4")),
    ),

    ("async_sram", 0,
        Subsignal("ce", Pins("P2:24")),
        Subsignal("oe", Pins("P2:27")),
        Subsignal("we", Pins("P2:44")),
        Subsignal("adr", Pins("P2:10 P2:12 P2:16 P2:18", # A0, A1, A2, A3
                              "P2:22 P2:46 P2:50 P2:52", # A4, A5, A6, A7
                              "P2:56 P2:58 P2:57 P2:55", # A8, A9, A10, A11
                              "P2:51 P2:49 P2:45 P2:23", # A12, A13, A14, A15
                              "P2:21 P2:17 P2:15")),
        Subsignal("dat", Pins("P2:28 P2:30 P2:38 P2:40",   # D0, D1, D1, D3
                              "P2:43 P2:39 P2:37 P2:29")), # D4, D5, D6, D7
     ),
]

# Clock/Reset Generator ---------------------------------------------------------

class _CRG(LiteXModule):
    def __init__(self, platform, sys_clk_freq):
        usr_rst_n   = Signal()
        btn_rst_n   = Signal()
        self.cd_sys = ClockDomain()

        # Reference Clock
        ref_clk = platform.request(platform.default_clk_name)

        # User Reset (button B)
        btn_rst_n = platform.request("btn_n", 1)

        self.specials += Instance("CC_USR_RSTN", o_USR_RSTN = usr_rst_n)

        # PLL
        self.pll = pll = GateMatePLL(perf_mode="speed")
        self.comb += pll.reset.eq(~usr_rst_n | ~btn_rst_n)

        pll.register_clkin(ref_clk, 1e9/platform.default_clk_period)
        pll.create_clkout(self.cd_sys, sys_clk_freq)

        platform.add_period_constraint(self.cd_sys.clk, 1e9/sys_clk_freq)

# AsyncSRAM ------------------------------------------------------------------------------------------

class AsyncSRAM(LiteXModule):

    def __init__(self, platform, clk, rst, wb, size, pins):
        self.bus = wb
        self.data_width = 32
        self.size = size
        self.specials += Instance("cy7c1049",
                                  i_wb_clk_i = clk,
                                  i_wb_rst_i = rst,
                                  i_wb_stb_i = self.bus.stb,
                                  i_wb_cyc_i = self.bus.cyc,
                                  i_wb_adr_i = self.bus.adr,
                                  i_wb_we_i  = self.bus.we,
                                  i_wb_sel_i = self.bus.sel,
                                  i_wb_dat_i = self.bus.dat_w,
                                  o_wb_ack_o = self.bus.ack,
                                  o_wb_dat_o = self.bus.dat_r,
                                  o_mem_ce_n = pins.ce,
                                  o_mem_oe_n = pins.oe,
                                  o_mem_we_n = pins.we,
                                  o_mem_adr  = pins.adr,
                                  io_mem_dat = pins.dat,
                                  )
        hdl_dir = os.path.join(os.path.abspath(os.path.dirname(__file__)),
                               "gmm7550")
        platform.add_source(os.path.join(hdl_dir, "cy7c1049.v"))

def add_async_ram(soc, platform, name, origin, size):
    ram_bus = wishbone.Interface(data_width=soc.bus.data_width)
    clk     = ClockSignal()
    rst     = ResetSignal()
    ram     = AsyncSRAM(platform, clk, rst, ram_bus, 512 * 1024,
                        platform.request("async_sram"))

    soc.bus.add_slave(name, ram.bus, SoCRegion(origin=origin, size=size, mode="rwx"))
    soc.check_if_exists(name)
    soc.logger.info("AsyncSRAM {} {} {}.".format(
        colorer(name),
        colorer("added", color="green"),
        soc.bus.regions[name]))
    setattr(soc.submodules, name, ram)

# USB ----------------------------------------------------------------------------------------------

class USB(LiteXModule):

    def __init__(self, soc, platform, usb_options):
        # Power Delivery Control -------------------------------------------------------------------
        if 'pd' in usb_options:
            self.pd = pd = platform.request("pd")
            self.pwr = pwr = CSRStorage(2, description="USB PD power discharge and source control")
            self.pd_alert = pd_alert = CSRStatus(1, description="USB PD controller alert")
            self.comb += [pd.en_n.eq(ResetSignal()),
                          pd.src_en.eq(pwr.storage[0]),
                          pd.disc.eq(pwr.storage[1]),
                          pd_alert.status[0].eq(~pd.alert_n)]
            soc.add_i2c_master(name="i2c", pads=pd, with_irq=True)

        if ('1' in usb_options) and ('2' in usb_options):
            raise ValueError("USB options 1 and 2 are mutually exclusive.")

        # USB 1.1 transceiver ----------------------------------------------------------------------
        if '1' in usb_options:
            self.usb1 = usb1 = platform.request("usb1")
            self.ctrl = ctrl = CSRStorage(5, description="USB 1.1 outputs: SUS_N, CON, OE, VM, VP")
            self.stat = stat = CSRStatus(4, description="USB 1.1 inputs: VBUS, RCV, VM, VP")

            self.comb += usb1.sus.eq(~ctrl.storage[4])
            self.comb += usb1.con.eq(ctrl.storage[3])
            self.comb += usb1.oe_n.eq(~ctrl.storage[2])

            vp_i = Signal(); vm_i = Signal()
            self.specials += Tristate(usb1.vm,
                                      o = ctrl.storage[1], oe = ctrl.storage[2],
                                      i = vm_i)
            self.specials += Tristate(usb1.vp,
                                      o = ctrl.storage[0], oe = ctrl.storage[2],
                                      i = vp_i)

            self.comb += stat.status[3].eq(usb1.busdet)
            self.comb += stat.status[2].eq(usb1.rcv)
            self.comb += stat.status[1].eq(vm_i)
            self.comb += stat.status[0].eq(vp_i)

        # ULPI (USB 2.0 PHY) -----------------------------------------------------------------------
        self.ulpi = ulpi = platform.request("ulpi")
        if '2' in usb_options:
            pass # Not implemented yet
        else:
            self.comb += [ulpi.rst_n.eq(0)] # keep PHY in reset
                                            # D+/D- signals are connected to USB 1.1 transceiver

        # USB 3 (SuperSpeed with SerDes) -----------------------------------------------------------
        if '3' in usb_options:
            hdl_dir = os.path.join(os.path.abspath(os.path.dirname(__file__)),
                                   "gmm7550")
            platform.add_source(os.path.join(hdl_dir, "usb3_test.v"))

            dbg_leds = platform.request_all("leds")

            dbg = Signal(5)
            testpoints = platform.request("p2_spiflash4x")

            rst_done = Signal()
            tx_rst_done = Signal()
            rx_rst_done = Signal()

            wb_clk = ClockSignal()
            wb_rst = ResetSignal()

            self.comb += [dbg_leds[0].eq(rst_done),
                          dbg_leds[1].eq(tx_rst_done),
                          dbg_leds[2].eq(rx_rst_done),
                          dbg_leds[3].eq(wb_rst)]

            name = "serdes_regs"
            reg_bus = wishbone.Interface(data_width=soc.bus.data_width)
            soc.bus.add_slave(name, reg_bus, SoCRegion(size=512, mode="rw", cached=False))
            soc.check_if_exists(name)
            soc.logger.info("SERDES Registers {} {} {}.".format(
                colorer(name),
                colorer("added", color="green"),
                soc.bus.regions[name]))
            self.specials += Instance("usb3_test",
                                      i_wb_clk_i = wb_clk, # ClockSignal(),
                                      i_wb_rst_i = wb_rst, # ResetSignal(),
                                      i_wb_adr_i = reg_bus.adr,
                                      i_wb_dat_i = reg_bus.dat_w,
                                      o_wb_dat_o = reg_bus.dat_r,
                                      i_wb_cyc_i = reg_bus.cyc,
                                      i_wb_stb_i = reg_bus.stb,
                                      i_wb_sel_i = reg_bus.sel,
                                      i_wb_we_i  = reg_bus.we,
                                      o_wb_ack_o = reg_bus.ack,

                                      o_dbg_o = dbg,
                                      o_tx_reset_done_o  = tx_rst_done,
                                      o_rx_reset_done_o  = rx_rst_done,
                                      o_serdes_reset_done_o = rst_done,
                                      );

            self.comb += [testpoints.cs_n.eq(1),
                          testpoints.clk.eq(dbg[4]),
                          testpoints.dq[0].eq(dbg[0]),
                          testpoints.dq[1].eq(dbg[1]),
                          testpoints.dq[2].eq(dbg[2]),
                          testpoints.dq[3].eq(dbg[3])]

# BaseSoC ------------------------------------------------------------------------------------------

class BaseSoC(SoCCore):
    def __init__(self, sys_clk_freq=25e6, toolchain="peppercorn",
        with_l2_cache   = False,
        with_led_chaser = False,
        with_spi_flash  = False,
        with_async_ram  = False,
        usb_options     = [],
        **kwargs):
        platform = gmm7550.Platform(toolchain)
        # platform = gmm7550.Platform(toolchain, yosys_bin="yosys -m ghdl",
        #                             yosys_read_commands=dict(vhdl="ghdl -read --std=08"))

        platform.add_extension(p4)

        if with_spi_flash or with_async_ram:
            platform.add_extension(p2)

        # CRG --------------------------------------------------------------------------------------
        self.crg = _CRG(platform, sys_clk_freq)

        # SoCCore ----------------------------------------------------------------------------------
        SoCCore.__init__(self, platform, sys_clk_freq, ident="LiteX SoC on GMM-7550/USB 3", **kwargs)

        # Leds -------------------------------------------------------------------------------------
        if with_led_chaser:
            self.leds = LedChaser(
                pads         = platform.request_all("leds"),
                sys_clk_freq = sys_clk_freq)

        led_red_n = platform.request("led_red_n")
        led_green = platform.request("led_green")
        gpo = Signal(2)
        self.gpio = GPIOOut(gpo)
        self.comb += [led_red_n.eq(~gpo[0]), led_green.eq(gpo[1])]

        # Asynchronous SRAM ------------------------------------------------------------------------
        if with_async_ram:
            add_async_ram(self, platform, "main_ram", 0x40000000, 512 * KILOBYTE)

        # USB --------------------------------------------------------------------------------------
        if len(usb_options) > 0:
            usb = USB(self, platform, usb_options)
            setattr(self.submodules, "usb", usb)

# Build --------------------------------------------------------------------------------------------

def main():
    from litex.build.parser import LiteXArgumentParser
    parser = LiteXArgumentParser(platform=gmm7550.Platform, description="LiteX SoC on GMM-7550 and USB 3 Adapter")
    parser.add_target_argument("--sys-clk-freq",   default=25e6, type=float, help="System clock frequency.")
    parser.add_target_argument("--with-spi-flash", action="store_true", help="Enable SPI Flash")
    parser.add_target_argument("--with-async-ram", action="store_true", help="Enable Asynchronous SRAM")
    parser.add_target_argument("--usb", nargs='+', dest="usb_options", default=[], help="Enable USB functions: TBD")

    parser.set_defaults(cpu_type = "vexriscv", cpu_variant = "lite")

    args = parser.parse_args()

    soc = BaseSoC(
        sys_clk_freq   = args.sys_clk_freq,
        toolchain      = "peppercorn", # args.toolchain,
        with_spi_flash = args.with_spi_flash,
        with_async_ram = args.with_async_ram,
        usb_options    = args.usb_options,
        **parser.soc_argdict)

    builder = Builder(soc, **parser.builder_argdict)
    if args.build:
        builder.build(**parser.toolchain_argdict)

    # if args.load:
    #     prog = soc.platform.create_programmer()
    #     prog.load_bitstream(builder.get_bitstream_filename(mode="sram"))

    # if args.flash:
    #     from litex.build.openfpgaloader import OpenFPGALoader
    #     prog = OpenFPGALoader("gatemate_evb_spi")
    #     prog.flash(0, builder.get_bitstream_filename(mode="flash"))

if __name__ == "__main__":
    main()
