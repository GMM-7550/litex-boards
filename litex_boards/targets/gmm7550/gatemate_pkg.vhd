-------------------------------------------------------------------------------
-- This file is a part of the GMM-7550 VHDL Examples
-- <https://github.com/gmm-7550/gmm7550-examples.git>
--
-- SPDX-License-Identifier: MIT
--
-- Copyright (c) 2023 Anton Kuzmin <ak@gmm7550.dev>
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------
-- GateMate FPGA Primitives Library
-------------------------------------------------------------------------------
package gatemate is

  -----------------------------------------------------------------------------
  -- I/O Buffers
  -----------------------------------------------------------------------------
  component CC_IBUF is
    generic (
      PIN_NAME  : string  := "UNPLACED";  -- IO_<dir><bank>_<pin><pin#>
                                          -- dir:  N, E, S, W
                                          -- bank: A, B, C
                                          -- pin:  A, B
                                          -- pin#: 0..8
      V_IO      : string  := "UNDEFINED"; -- 1.2, 1.8 or 2.5 V
      PULLUP    : integer := 0;           -- 0: disable, 1: enable
      PULLDOWN  : integer := 0;           -- 0: disable, 1: enable
      KEEPER    : integer := 0;           -- 0: disable, 1: enable
      SCHMITT_TRIGGER : integer := 0;     -- 0: disable, 1: enable
      DELAY_IBF : integer := 0;           -- 0..15 x 50 ps
      FF_IBF    : integer := 0            -- 0: disable, 1: enable
      );
    port (
      I : in  std_logic; -- input from device pin
      Y : out std_logic  -- output to FPGA-internal circuitry
      );
  end component CC_IBUF;

  component CC_OBUF is
    generic (
      PIN_NAME  : string  := "UNPLACED";  -- IO_<dir><bank>_<pin><pin#>
      V_IO      : string  := "UNDEFINED"; -- 1.2, 1.8 or 2.5
      DRIVE     : string  := "3";         -- 3, 6, 9, 12 mA
      SLEW      : string  := "UNDEFINED"; -- SLOW or FAST
      DELAY_OBF : integer := 0;           -- 0..15 x 50 ps
      FF_OBF    : integer := 0            -- 0: disable, 1: enable
      );
    port (
      A : in  std_logic;
      O : out std_logic
      );
  end component CC_OBUF;

  component CC_TOBUF is
    generic (
      PIN_NAME  : string  := "UNPLACED";  -- IO_<dir><bank>_<pin><pin#>
      V_IO      : string  := "UNDEFINED"; -- 1.2, 1.8 or 2.5
      DRIVE     : string  := "3";         -- 3, 6, 9, 12 mA
      SLEW      : string  := "UNDEFINED"; -- SLOW or FAST
      PULLUP    : integer := 0;           -- 0: disable, 1: enable
      PULLDOWN  : integer := 0;           -- 0: disable, 1: enable
      KEEPER    : integer := 0;           -- 0: disable, 1: enable
      DELAY_OBF : integer := 0;           -- 0..15 x 50 ps
      FF_OBF    : integer := 0            -- 0: disable, 1: enable
      );
    port (
      A : in  std_logic; -- input from FPGA-internal circuitry
      T : in  std_logic; -- active Low output enable
      O : out std_logic  -- tri-state if T = 1
      );
  end component CC_TOBUF;

  component CC_IOBUF is
    generic (
      PIN_NAME  : string  := "UNPLACED";  -- IO_<dir><bank>_<pin><pin#>
      V_IO      : string  := "UNDEFINED"; -- 1.2, 1.8 or 2.5
      DRIVE     : string  := "3";         -- 3, 6, 9, 12 mA
      SLEW      : string  := "UNDEFINED"; -- SLOW or FAST
      PULLUP    : integer := 0;           -- 0: disable, 1: enable
      PULLDOWN  : integer := 0;           -- 0: disable, 1: enable
      KEEPER    : integer := 0;           -- 0: disable, 1: enable
      DELAY_OBF : integer := 0;           -- 0..15 x 50 ps
      FF_OBF    : integer := 0            -- 0: disable, 1: enable
      );
    port (
      A  : in    std_logic; -- input from FPGA-internal circuitry
      T  : in    std_logic; -- active Low output enable from FPGA-internal circuitry
      Y  : out   std_logic; -- output to FPGA-internal circuitry
      IO : inout std_logic  -- bidirectional in- or output to device pin
      );
  end component CC_IOBUF;

  component CC_LVDS_IBUF is
    generic (
      PIN_NAME_P : string  := "UNPLACED";  -- IO_<dir><bank>_<pin><pin#>
      PIN_NAME_N : string  := "UNPLACED";
      V_IO       : string  := "UNDEFINED"; -- 1.8 or 2.5 V
      LVDS_RTERM : integer := 0;           -- 0: disable, 1: enable
      DELAY_IBF  : integer := 0;           -- 0..15 x 50 ps
      FF_IBF     : integer := 0            -- 0: disable, 1: enable
      );
    port (
      I_P : in  std_logic; -- positive differential input from device pin
      I_N : in  std_logic; -- negative differential input from device pin
      Y   : out std_logic  -- output to FPGA-internal circuitry
      );
  end component CC_LVDS_IBUF;

  component CC_LVDS_OBUF is
    generic (
      PIN_NAME_P : string  := "UNPLACED";  -- IO_<dir><bank>_<pin><pin#>
      PIN_NAME_N : string  := "UNPLACED";
      V_IO       : string  := "UNDEFINED"; -- 1.8 or 2.5 V
      LVDS_BOOST : integer := 0;           -- 0: 3.2 mA nominal current, default
                                           -- 1: 6.4 mA increased current
      DELAY_OBF : integer := 0;           -- 0..15 x 50 ps
      FF_OBF    : integer := 0            -- 0: disable, 1: enable
      );
    port (
      A   : in  std_logic; -- input from FPGA-internal circuitry
      O_P : out std_logic; -- positive differential output to device pin
      O_N : out std_logic  -- negative differential output to device pin
      );
  end component CC_LVDS_OBUF;

  component CC_LVDS_TOBUF is
    generic (
      PIN_NAME_P : string  := "UNPLACED";  -- IO_<dir><bank>_<pin><pin#>
      PIN_NAME_N : string  := "UNPLACED";
      V_IO       : string  := "UNDEFINED"; -- 1.8 or 2.5 V
      LVDS_BOOST : integer := 0;           -- 0: 3.2 mA nominal current, default
                                           -- 1: 6.4 mA increased current
      DELAY_OBF  : integer := 0;           -- 0..15 x 50 ps
      FF_OBF     : integer := 0            -- 0: disable, 1: enable
      );
    port (
      A   : in  std_logic; -- input from FPGA-internal circuitry
      T   : in  std_logic; -- active Low output enable from FPGA-internal circuitry
      O_P : out std_logic; -- positive differential output to device pin
      O_N : out std_logic  -- negative differential output to device pin
      );
  end component CC_LVDS_TOBUF;

  component CC_LVDS_IOBUF is
    generic (
      PIN_NAME_P : string  := "UNPLACED";  -- IO_<dir><bank>_<pin><pin#>
      PIN_NAME_N : string  := "UNPLACED";
      V_IO       : string  := "UNDEFINED"; -- 1.8 or 2.5 V
      LVDS_RTERM : integer := 0;           -- 0: disable, 1: enable
      LVDS_BOOST : integer := 0;           -- 0: 3.2 mA nominal current, default
                                           -- 1: 6.4 mA increased current
      DELAY_IBF  : integer := 0;           -- 0..15 x 50 ps
      DELAY_OBF  : integer := 0;           -- 0..15 x 50 ps
      FF_IBF     : integer := 0;           -- 0: disable, 1: enable
      FF_OBF     : integer := 0            -- 0: disable, 1: enable
      );
    port (
      A    : in    std_logic; -- input from FPGA-internal circuitry
      T    : in    std_logic; -- active Low output enable from FPGA-internal circuitry
      Y    : out   std_logic; -- output to FPGA-internal circuitry
      IO_P : inout std_logic; -- positive differential bidirectional signal to device pin
      IO_N : inout std_logic  -- negative differential bidirectional signal to device pin
      );
  end component CC_LVDS_IOBUF;

  component CC_IDDR is
    generic (
      CLK_INV : integer := 0  -- clock polarity for Q0
                              -- 0: rising edge (default)
                              -- 1: falling edge
      );
    port (
      D   : in  std_logic; -- data input from any input buffer
      CLK : in  std_logic; -- clock signal input
      Q0  : out std_logic; -- data output to FPGA-internal circuitry
      Q1  : out std_logic  -- data output to FPGA-internal circuitry
      );
  end component CC_IDDR;

  component CC_ODDR is
    generic (
      CLK_INV : integer := 0  -- clock polarity for Q0
                              -- 0: rising edge (default)
                              -- 1: falling edge
      );
    port (
      D0  : in  std_logic; -- data input from FPGA-internal circuitry
      D1  : in  std_logic; -- data input from FPGA-internal circuitry
      CLK : in  std_logic; -- clock signal input to flip-flops
      DDR : in  std_logic; -- clock signal input to flip-flop switch
      Q   : out std_logic  -- data output to any output buffer
      );
  end component CC_ODDR;

  -----------------------------------------------------------------------------
  -- Registers/Latches
  -----------------------------------------------------------------------------
  component CC_DFF is
    generic (
      CLK_INV : integer := 0; -- clock polarity, 0: rising edge, 1: falling edge
      EN_INV  : integer := 0; -- enable signal inversion, 0: disable, 1: enable
      SR_INV  : integer := 0; -- set/reset signal inversion
      SR_VAL  : integer := 0; -- 0: reset to zero, 1: set to one
      INIT    : integer := 0  -- initial value of Q output after configuration
      );
    port (
      D   : in  std_logic; -- data input
      CLK : in  std_logic; -- clock signal
      EN  : in  std_logic; -- clock enable signal
      SR  : in  std_logic; -- configurable asynchronous  set/reset signal
      Q   : out std_logic  -- data output
      );
  end component CC_DFF;

  component CC_DLT is
    generic (
      G_INV   : integer := 0; -- enable signal inverting
      SR_INV  : integer := 0; -- set/reset signal inversion
      SR_VAL  : integer := 0; -- 0: reset to zero, 1: set to one
      INIT    : integer := 0  -- initial value of Q output after configuration
      );
    port (
      D  : in  std_logic; -- data input
      G  : in  std_logic; -- enable input
      SR : in  std_logic; -- configurable asynchronous set/reset signal
      Q  : out std_logic  -- data output
      );
  end component CC_DLT;

  -----------------------------------------------------------------------------
  -- LUT
  -----------------------------------------------------------------------------
  component CC_LUT1 is
    generic (
      INIT : std_logic_vector(1 downto 0) := "00"
      );
    port (
      I0 : in  std_logic;
      O  : out std_logic
      );
  end component CC_LUT1;

  component CC_LUT2 is
    generic (
      INIT : std_logic_vector(3 downto 0) := "0000"
      );
    port (
      I0 : in  std_logic;
      I1 : in  std_logic;
      O  : out std_logic
      );
  end component CC_LUT2;

  component CC_LUT3 is
    generic (
      INIT : std_logic_vector(7 downto 0) := x"00"
      );
    port (
      I0 : in  std_logic;
      I1 : in  std_logic;
      I2 : in  std_logic;
      O  : out std_logic
      );
  end component CC_LUT3;

  component CC_LUT4 is
    generic (
      INIT : std_logic_vector(15 downto 0) := x"0000"
      );
    port (
      I0 : in  std_logic;
      I1 : in  std_logic;
      I2 : in  std_logic;
      I3 : in  std_logic;
      O  : out std_logic
      );
  end component CC_LUT4;

  --        +-----+
  -- I0 --->|     |
  --        | L00 |---\
  -- I1 --->|     |   |    +-----+
  --        +-----+   \--->|     |
  --                       | L10 |---> O
  --        +-----+   /--->|     |
  -- I2 --->|     |   |    +-----+
  --        | L01 |---/
  -- I3 --->|     |
  --        +-----+
  --
  -- Figure 4.1 CC_L2T4 primitive schematic
  -- GateMate FPGA User Guide
  -- Primitivers Library
  component CC_L2T4 is
    generic (
      INIT_L00 : std_logic_vector(3 downto 0) := x"0"; -- LUT L00 configuration
      INIT_L01 : std_logic_vector(3 downto 0) := x"0"; -- LUT L01 configuration
      INIT_L10 : std_logic_vector(3 downto 0) := x"0"  -- LUT L10 configuration
      );
    port (
      I0 : in  std_logic;
      I1 : in  std_logic;
      I2 : in  std_logic;
      I3 : in  std_logic;
      O  : out std_logic
      );
  end component CC_L2T4;

  -- I4 -----------------------------\
  --                                 |    +-----+
  --        +-----+                  \--->|     |
  -- I0 --->|     |                       | L20 |---> O
  --        | L02 |---\              /--->|     |
  -- I1 --->|     |   |    +-----+   |    +-----+
  --        +-----+   \--->|     |   |
  --                       | L11 |---/
  --        +-----+   /--->|     |
  -- I2 --->|     |   |    +-----+
  --        | L03 |---/
  -- I3 --->|     |
  --        +-----+
  --
  -- Figure 4.3 CC_L2T5 primitive schematic
  -- GateMate FPGA User Guide
  -- Primitivers Library
  component CC_L2T5 is
    generic (
      INIT_L02 : std_logic_vector(3 downto 0) := x"0"; -- LUT L02 configuration
      INIT_L03 : std_logic_vector(3 downto 0) := x"0"; -- LUT L03 configuration
      INIT_L11 : std_logic_vector(3 downto 0) := x"0"; -- LUT L11 configuration
      INIT_L20 : std_logic_vector(3 downto 0) := x"0"  -- LUT L20 configuration
      );
    port (
      I0 : in  std_logic;
      I1 : in  std_logic;
      I2 : in  std_logic;
      I3 : in  std_logic;
      I4 : in  std_logic;
      O  : out std_logic
      );
  end component CC_L2T5;

  --        +------+
  -- I0 --->|      |
  -- I1 --->| L2T4 |---+---> O0
  -- I2 --->|      |   |
  -- I3 --->|      |   |
  --        +------+   |
  --   /---------------/
  --   |    +------+
  --   \--->|      |
  -- I4 --->| L2T5 |-------> O1
  -- I5 --->|      |
  -- I6 --->|      |
  -- I7 --->|      |
  --        +------+
  --
  -- Figure 4.4: Combined CC_L2T4 and CC_L2T5
  -- primitives forming an 8-input LUT-tree

  -----------------------------------------------------------------------------
  -- Multiplexers
  -----------------------------------------------------------------------------
  component CC_MX2 is
    port (
      D0 : in  std_logic;
      D1 : in  std_logic;
      S0 : in  std_logic;
      Y  : out std_logic
      );
  end component CC_MX2;

  component CC_MX4 is
    port (
      D0 : in  std_logic;
      D1 : in  std_logic;
      D2 : in  std_logic;
      D3 : in  std_logic;
      S0 : in  std_logic;
      S1 : in  std_logic;
      Y  : out std_logic
      );
  end component CC_MX4;

  -----------------------------------------------------------------------------
  -- Arithmetic Functions
  -----------------------------------------------------------------------------

  -- Full adder using dedicated logic and routing resources inside
  -- and between CPE cells. Two cascaded CC_ADDF primitives can be combined
  -- into a single CPE forming a two-bit full adder.
  component CC_ADDF is
    port (
      A  : in  std_logic;
      B  : in  std_logic;
      CI : in  std_logic;
      CO : out std_logic;
      S  : out std_logic
      );
  end component CC_ADDF;

  -- The CC_MULT primitive is a scalable, signed multiplier with inputs of any width
  component CC_MULT is
    generic (
      A_WIDTH : integer := 2; -- maximum 100
      B_WIDTH : integer := 2;
      P_WIDTH : integer := 4
      );
    port (
      A : in  std_logic_vector(A_WIDTH-1 downto 0);
      B : in  std_logic_vector(B_WIDTH-1 downto 0);
      P : out std_logic_vector(P_WIDTH-1 downto 0)
      );
  end component CC_MULT;

  -----------------------------------------------------------------------------
  -- Block RAM
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- Special Function Blocks
  -----------------------------------------------------------------------------
  component CC_BUFG is
    port (
      I : in  std_logic;
      O : out std_logic
      );
  end component CC_BUFG;

  component CC_USR_RSTN is
    port (
      USR_RSTN : out std_logic
      );
  end component CC_USR_RSTN;

  component CC_PLL is
    generic (
      REF_CLK         : string  := "0"; -- e.g. "10.0"
      OUT_CLK         : string  := "0"; -- e.g. "50.0"
      PERF_MD         : string  := "UNDEFINED"; -- LOWPOWER, ECONOMY, SPEED
      LOW_JITTER      : integer := 1;
      LOCK_REQ        : integer := 1; -- PLL lock required before output enable
      CLK270_DOUB     : integer := 0; -- clock doubling on CLK270_OUT
      CLK180_DOUB     : integer := 0; -- clock doubling on CLK180_OUT

      -- Integral coefficient of loop filter, should be greater than zero.
      CI_FILTER_CONST : integer := 2;
      -- Proportional coefficient of loop filter, should be greater than CI.
      CP_FILTER_CONST : integer := 4
      -- The higher the CP/CI ratio is, the more stable is the loop
      -- (phase margin). Higher CP lead to larger period jitter.
      );
    port (
      CLK_REF             : in  std_logic;
      USR_CLK_REF         : in  std_logic;
      CLK_FEEDBACK        : in  std_logic;

      USR_LOCKED_STDY_RST : in  std_logic;
      USR_PLL_LOCKED_STDY : out std_logic;
      USR_PLL_LOCKED      : out std_logic;

      CLK0                : out std_logic;
      CLK90               : out std_logic;
      CLK180              : out std_logic;
      CLK270              : out std_logic;
      CLK_REF_OUT         : out std_logic
      );
  end component CC_PLL;

  component CC_PLL_ADV is
    generic (
      PLL_CFG_A           : std_logic_vector(95 downto 0);
      PLL_CFG_B           : std_logic_vector(95 downto 0)
      );
    port (
      CLK_REF             : in  std_logic;
      USR_CLK_REF         : in  std_logic;
      USR_SEL_A_B         : in  std_logic;
      CLK_FEEDBACK        : in  std_logic;

      USR_LOCKED_STDY_RST : in  std_logic;
      USR_PLL_LOCKED_STDY : out std_logic;
      USR_PLL_LOCKED      : out std_logic;

      CLK0                : out std_logic;
      CLK90               : out std_logic;
      CLK180              : out std_logic;
      CLK270              : out std_logic;
      CLK_REF_OUT         : out std_logic
      );
  end component CC_PLL_ADV;

  component CC_CFG_CTRL is
    port (
      CLK   : in  std_logic;
      DATA  : in  std_logic_vector(7 downto 0);
      VALID : in  std_logic;
      EN    : in  std_logic;
      RECFG : in  std_logic
      );
  end component CC_CFG_CTRL;

  component CC_SERDES
    generic (
      TX_SEL_PRE               : integer range 0 to 31    := 0;
      TX_SEL_POST              : integer range 0 to 31    := 0;
      TX_AMP                   : integer range 0 to 31    := 15;
      TX_BRANCH_EN_PRE         : integer range 0 to 31    := 0;
      TX_BRANCH_EN_MAIN        : integer range 0 to 63    := 16#3f#; -- 63
      TX_BRANCH_EN_POST        : integer range 0 to 31    := 0;
      TX_TAIL_CASCODE          : integer range 0 to 7     := 4;
      TX_DC_ENABLE             : integer range 0 to 127   := 16#3f#; -- 63
      TX_DC_OFFSET             : integer range 0 to 31    := 0; -- 8 ?
      TX_CM_RAISE              : integer range 0 to 31    := 0;
      TX_CM_THRESHOLD_0        : integer range 0 to 31    := 14;
      TX_CM_THRESHOLD_1        : integer range 0 to 31    := 16;
      TX_SEL_PRE_EI            : integer range 0 to 31    := 0;
      TX_SEL_POST_EI           : integer range 0 to 31    := 0;
      TX_AMP_EI                : integer range 0 to 31    := 15;
      TX_BRANCH_EN_PRE_EI      : integer range 0 to 31    := 0;
      TX_BRANCH_EN_MAIN_EI     : integer range 0 to 63    := 16#3f#; -- 63
      TX_BRANCH_EN_POST_EI     : integer range 0 to 31    := 0;
      TX_TAIL_CASCODE_EI       : integer range 0 to 7     := 4;
      TX_DC_ENABLE_EI          : integer range 0 to 127   := 63;
      TX_DC_OFFSET_EI          : integer range 0 to 31    := 0;
      TX_CM_RAISE_EI           : integer range 0 to 31    := 0;
      TX_CM_THRESHOLD_0_EI     : integer range 0 to 31    := 14;
      TX_CM_THRESHOLD_1_EI     : integer range 0 to 31    := 16;
      TX_SEL_PRE_RXDET         : integer range 0 to 31    := 0;
      TX_SEL_POST_RXDET        : integer range 0 to 31    := 0;
      TX_AMP_RXDET             : integer range 0 to 31    := 15;
      TX_BRANCH_EN_PRE_RXDET   : integer range 0 to 31    := 0;
      TX_BRANCH_EN_MAIN_RXDET  : integer range 0 to 63    := 16#3f#; -- 63
      TX_BRANCH_EN_POST_RXDET  : integer range 0 to 31    := 0;
      TX_TAIL_CASCODE_RXDET    : integer range 0 to 7     := 4;
      TX_DC_ENABLE_RXDET       : integer range 0 to 127   := 63;
      TX_DC_OFFSET_RXDET       : integer range 0 to 31    := 0;
      TX_CM_RAISE_RXDET        : integer range 0 to 31    := 0;
      TX_CM_THRESHOLD_0_RXDET  : integer range 0 to 31    := 14;
      TX_CM_THRESHOLD_1_RXDET  : integer range 0 to 31    := 16;
      TX_CALIB_EN              : integer range 0 to 1     := 0;
      TX_CALIB_OVR             : integer range 0 to 1     := 0;
      TX_CALIB_VAL             : integer range 0 to 15    := 0;
      TX_CM_REG_KI             : integer range 0 to 255   := 16#80#;
      TX_CM_SAR_EN             : integer range 0 to 1     := 0;
      TX_CM_REG_EN             : integer range 0 to 1     := 1;
      TX_PMA_RESET_TIME        : integer range 0 to 31    := 3;
      TX_PCS_RESET_TIME        : integer range 0 to 31    := 3;
      TX_PCS_RESET_OVR         : integer range 0 to 1     := 0;
      TX_PCS_RESET             : integer range 0 to 1     := 0;
      TX_PMA_RESET_OVR         : integer range 0 to 1     := 0;
      TX_PMA_RESET             : integer range 0 to 1     := 0;
      TX_RESET_OVR             : integer range 0 to 1     := 0;
      TX_RESET                 : integer range 0 to 1     := 0;
      TX_PMA_LOOPBACK          : integer range 0 to 3     := 0;
      TX_PCS_LOOPBACK          : integer range 0 to 1     := 0;
      TX_DATAPATH_SEL          : integer range 0 to 3     := 3;
      TX_PRBS_OVR              : integer range 0 to 1     := 0;
      TX_PRBS_SEL              : integer range 0 to 7     := 0;
      TX_PRBS_FORCE_ERR        : integer range 0 to 1     := 0;
      TX_LOOPBACK_OVR          : integer range 0 to 1     := 0;
      TX_POWER_DOWN_OVR        : integer range 0 to 1     := 0;
      TX_POWER_DOWN_N          : integer range 0 to 1     := 0;
      TX_ELEC_IDLE_OVR         : integer range 0 to 1     := 0;
      TX_ELEC_IDLE             : integer range 0 to 1     := 0;
      TX_DETECT_RX_OVR         : integer range 0 to 1     := 0;
      TX_DETECT_RX             : integer range 0 to 1     := 0;
      TX_POLARITY_OVR          : integer range 0 to 1     := 0;
      TX_POLARITY              : integer range 0 to 1     := 0;
      TX_8B10B_EN_OVR          : integer range 0 to 1     := 0;
      TX_8B10B_EN              : integer range 0 to 1     := 0;
      TX_DATA_OVR              : integer range 0 to 1     := 0;
      TX_DATA_CNT              : integer range 0 to 7     := 0;
      TX_DATA_VALID            : integer range 0 to 1     := 0;

      RX_BUF_RESET_TIME        : integer range 0 to 31    := 3;
      RX_PCS_RESET_TIME        : integer range 0 to 31    := 3;
      RX_RESET_TIMER_PRESC     : integer range 0 to 31    := 0;
      RX_RESET_DONE_GATE       : integer range 0 to 1     := 0;
      RX_CDR_RESET_TIME        : integer range 0 to 31    := 3;
      RX_EQA_RESET_TIME        : integer range 0 to 31    := 3;
      RX_PMA_RESET_TIME        : integer range 0 to 31    := 3;
      RX_WAIT_CDR_LOCK         : integer range 0 to 1     := 1;
      RX_CALIB_EN              : integer range 0 to 1     := 0;
      RX_CALIB_OVR             : integer range 0 to 1     := 0;
      RX_CALIB_VAL             : integer range 0 to 15    := 0;
      RX_RTERM_VCMSEL          : integer range 0 to 7     := 4;
      RX_RTERM_PD              : integer range 0 to 1     := 0;
      RX_EQA_CKP_LF            : integer range 0 to 255   := 16#a3#;
      RX_EQA_CKP_HF            : integer range 0 to 255   := 16#a3#;
      RX_EQA_CKP_OFFSET        : integer range 0 to 255   := 16#01#;
      RX_EN_EQA                : integer range 0 to 1     := 0;
      RX_EQA_LOCK_CFG          : integer range 0 to 15    := 0;
      RX_TH_MON1               : integer range 0 to 31    := 8;
      RX_EN_EQA_EXT_VALUE      : integer range 0 to 14    := 0;
      RX_TH_MON2               : integer range 0 to 31    := 8;
      RX_TAPW                  : integer range 0 to 31    := 8;
      RX_AFE_OFFSET            : integer range 0 to 31    := 8;
      RX_EQA_CONFIG            : integer range 0 to 65535 := 16#01c0#;
      RX_AFE_PEAK              : integer range 0 to 31    := 16;
      RX_AFE_GAIN              : integer range 0 to 15    := 8;
      RX_AFE_VCMSEL            : integer range 0 to 7     := 4;
      RX_CDR_CKP               : integer range 0 to 255   := 16#f8#;
      RX_CDR_CKI               : integer range 0 to 255   := 0;
      RX_CDR_TRANS_TH          : integer range 0 to 511   := 128;
      RX_CDR_LOCK_CFG          : integer range 0 to 63    := 16#0b#;
      RX_CDR_FREQ_ACC          : integer range 0 to 32767 := 0;
      RX_CDR_PHASE_ACC         : integer range 0 to 65535 := 0;
      RX_CDR_SET_ACC_CONFIG    : integer range 0 to 3     := 0;
      RX_CDR_FORCE_LOCK        : integer range 0 to 1     := 0;
      RX_ALIGN_MCOMMA_VALUE    : integer range 0 to 1023  := 16#283#;
      RX_MCOMMA_ALIGN_OVR      : integer range 0 to 1     := 0;
      RX_MCOMMA_ALIGN          : integer range 0 to 1     := 0;
      RX_ALIGN_PCOMMA_VALUE    : integer range 0 to 1023  := 16#17c#;
      RX_PCOMMA_ALIGN_OVR      : integer range 0 to 1     := 0;
      RX_PCOMMA_ALIGN          : integer range 0 to 1     := 0;
      RX_ALIGN_COMMA_WORD      : integer range 0 to 3     := 0;
      RX_ALIGN_COMMA_ENABLE    : integer range 0 to 1023  := 16#3ff#;
      RX_SLIDE_MODE            : integer range 0 to 3     := 0;
      RX_COMMA_DETECT_EN_OVR   : integer range 0 to 1     := 0;
      RX_COMMA_DETECT_EN       : integer range 0 to 1     := 0;
      RX_SLIDE                 : integer range 0 to 3     := 0;
      RX_EYE_MEAS_EN           : integer range 0 to 1     := 0;
      RX_EYE_MEAS_CFG          : integer range 0 to 32767 := 0;
      RX_MON_PH_OFFSET         : integer range 0 to 63    := 0;
      RX_EI_BIAS               : integer range 0 to 15    := 4; -- 0?
      RX_EI_BW_SEL             : integer range 0 to 15    := 4;
      RX_EN_EI_DETECTOR_OVR    : integer range 0 to 1     := 0;
      RX_EN_EI_DETECTOR        : integer range 0 to 1     := 0;
      RX_DATA_SEL              : integer range 0 to 1     := 0;
      RX_BUF_BYPASS            : integer range 0 to 1     := 0;
      RX_CLKCOR_USE            : integer range 0 to 1     := 0;
      RX_CLKCOR_MIN_LAT        : integer range 0 to 63    := 32;
      RX_CLKCOR_MAX_LAT        : integer range 0 to 63    := 39;
      RX_CLKCOR_SEQ_1_0        : integer range 0 to 1023  := 16#1f7#;
      RX_CLKCOR_SEQ_1_1        : integer range 0 to 1023  := 16#1f7#;
      RX_CLKCOR_SEQ_1_2        : integer range 0 to 1023  := 16#1f7#;
      RX_CLKCOR_SEQ_1_3        : integer range 0 to 1023  := 16#1f7#;
      RX_PMA_LOOPBACK          : integer range 0 to 1     := 0;
      RX_PCS_LOOPBACK          : integer range 0 to 1     := 0;
      RX_DATAPATH_SEL          : integer range 0 to 3     := 3;
      RX_PRBS_OVR              : integer range 0 to 1     := 0;
      RX_PRBS_SEL              : integer range 0 to 7     := 0;
      RX_LOOPBACK_OVR          : integer range 0 to 1     := 0;
      RX_PRBS_CNT_RESET        : integer range 0 to 1     := 0;
      RX_POWER_DOWN_OVR        : integer range 0 to 1     := 0;
      RX_POWER_DOWN_N          : integer range 0 to 1     := 0;
      RX_RESET_OVR             : integer range 0 to 1     := 0;
      RX_RESET                 : integer range 0 to 1     := 0;
      RX_PMA_RESET_OVR         : integer range 0 to 1     := 0;
      RX_PMA_RESET             : integer range 0 to 1     := 0;
      RX_EQA_RESET_OVR         : integer range 0 to 1     := 0;
      RX_EQA_RESET             : integer range 0 to 1     := 0;
      RX_CDR_RESET_OVR         : integer range 0 to 1     := 0;
      RX_CDR_RESET             : integer range 0 to 1     := 0;
      RX_PCS_RESET_OVR         : integer range 0 to 1     := 0;
      RX_PCS_RESET             : integer range 0 to 1     := 0;
      RX_BUF_RESET_OVR         : integer range 0 to 1     := 0;
      RX_BUF_RESET             : integer range 0 to 1     := 0;
      RX_POLARITY_OVR          : integer range 0 to 1     := 0;
      RX_POLARITY              : integer range 0 to 1     := 0;
      RX_8B10B_EN_OVR          : integer range 0 to 1     := 0;
      RX_8B10B_EN              : integer range 0 to 1     := 0;
      RX_8B10B_BYPASS          : integer range 0 to 255   := 0;
      RX_BYTE_REALIGN          : integer range 0 to 1     := 0;
      RX_DBG_EN                : integer range 0 to 1     := 0;
      RX_DBG_SEL               : integer range 0 to 15    := 0;
      RX_DBG_MODE              : integer range 0 to 1     := 0;
      RX_DBG_SRAM_DELAY        : integer range 0 to 31    := 16#05#;
      RX_DBG_ADDR              : integer range 0 to 1023  := 0;
      RX_DBG_RE                : integer range 0 to 1     := 0;
      RX_DBG_WE                : integer range 0 to 1     := 0;
      RX_DBG_DATA              : integer range 0 to 15    := 0;

      PLL_EN_ADPLL_CTRL        : integer range 0 to 1     := 0;
      PLL_CONFIG_SEL           : integer range 0 to 1     := 0;
      PLL_SET_OP_LOCK          : integer range 0 to 1     := 0;
      PLL_ENFORCE_LOCK         : integer range 0 to 1     := 0;
      PLL_DISABLE_LOCK         : integer range 0 to 1     := 0;
      PLL_LOCK_WINDOW          : integer range 0 to 1     := 1;
      PLL_FAST_LOCK            : integer range 0 to 1     := 1;
      PLL_SYNC_BYPASS          : integer range 0 to 1     := 0;
      PLL_PFD_SELECT           : integer range 0 to 1     := 0;
      PLL_REF_BYPASS           : integer range 0 to 1     := 0;
      PLL_REF_SEL              : integer range 0 to 1     := 0;
      PLL_REF_RTERM            : integer range 0 to 1     := 1;
      PLL_FCNTRL               : integer range 0 to 63    := 58;
      PLL_MAIN_DIVSEL          : integer range 0 to 63    := 27;
      PLL_OUT_DIVSEL           : integer range 0 to 3     := 0;
      PLL_CI                   : integer range 0 to 31    := 3;
      PLL_CP                   : integer range 0 to 1023  := 80;
      PLL_AO                   : integer range 0 to 15    := 0;
      PLL_SCAP                 : integer range 0 to 7     := 0;
      PLL_FILTER_SHIFT         : integer range 0 to 3     := 2;
      PLL_SAR_LIMIT            : integer range 0 to 7     := 2;
      PLL_FT                   : integer range 0 to 2047  := 512;
      PLL_OPEN_LOOP            : integer range 0 to 1     := 0;
      PLL_SCAP_AUTO_CAL        : integer range 0 to 1     := 1;
      PLL_BISC_MODE            : integer range 0 to 7     := 4;
      PLL_BISC_TIMER_MAX       : integer range 0 to 15    := 15;
      PLL_BISC_OPT_DET_IND     : integer range 0 to 1     := 0;
      PLL_BISC_PFD_SEL         : integer range 0 to 1     := 0;
      PLL_BISC_DLY_DIR         : integer range 0 to 1     := 0;
      PLL_BISC_COR_DLY         : integer range 0 to 7     := 1;
      PLL_BISC_CAL_SIGN        : integer range 0 to 1     := 0;
      PLL_BISC_CAL_AUTO        : integer range 0 to 1     := 1;
      PLL_BISC_CP_MIN          : integer range 0 to 31    := 4;
      PLL_BISC_CP_MAX          : integer range 0 to 31    := 18;
      PLL_BISC_CP_START        : integer range 0 to 31    := 12;
      PLL_BISC_DLY_PFD_MON_REF : integer range 0 to 31    := 0;
      PLL_BISC_DLY_PFD_MON_DIV : integer range 0 to 31    := 2
      );
      port (
        TX_RESET_I             : in  std_logic;
        TX_PCS_RESET_I         : in  std_logic;
        TX_PMA_RESET_I         : in  std_logic;
        TX_POWER_DOWN_N_I      : in  std_logic;
        TX_CLK_I               : in  std_logic;
        TX_POLARITY_I          : in  std_logic;
        TX_PRBS_SEL_I          : in  std_logic_vector(2 downto 0);
        TX_PRBS_FORCE_ERR_I    : in  std_logic;
        TX_8B10B_EN_I          : in  std_logic;
        TX_8B10B_BYPASS_I      : in  std_logic_vector(7 downto 0);
        TX_CHAR_IS_K_I         : in  std_logic_vector(7 downto 0);
        TX_CHAR_DISPMODE_I     : in  std_logic_vector(7 downto 0);
        TX_CHAR_DISPVAL_I      : in  std_logic_vector(7 downto 0);
        TX_ELEC_IDLE_I         : in  std_logic;
        TX_DETECT_RX_I         : in  std_logic;
        TX_DATA_I              : in  std_logic_vector(63 downto 0);
        TX_RESET_DONE_O        : out std_logic;
        TX_BUF_ERR_O           : out std_logic;
        TX_DETECT_RX_PRESENT_O : out std_logic;
        TX_DETECT_RX_DONE_O    : out std_logic;

        -- Receiver
        RX_RESET_I             : in  std_logic;
        RX_PMA_RESET_I         : in  std_logic;
        RX_EQA_RESET_I         : in  std_logic;
        RX_CDR_RESET_I         : in  std_logic;
        RX_PCS_RESET_I         : in  std_logic;
        RX_BUF_RESET_I         : in  std_logic;
        RX_POWER_DOWN_N_I      : in  std_logic;
        RX_CLK_I               : in  std_logic;
        RX_POLARITY_I          : in  std_logic;
        RX_PRBS_SEL_I          : in  std_logic_vector(2 downto 0);
        RX_PRBS_CNT_RESET_I    : in  std_logic;
        RX_8B10B_EN_I          : in  std_logic;
        RX_8B10B_BYPASS_I      : in  std_logic_vector(7 downto 0);
        RX_EN_EI_DETECTOR_I    : in  std_logic;
        RX_COMMA_DETECT_EN_I   : in  std_logic;
        RX_SLIDE_I             : in  std_logic;
        RX_MCOMMA_ALIGN_I      : in  std_logic;
        RX_PCOMMA_ALIGN_I      : in  std_logic;
        RX_CLK_O               : out std_logic;
        RX_NOT_IN_TABLE_O      : out std_logic_vector(7 downto 0);
        RX_CHAR_IS_COMMA_O     : out std_logic_vector(7 downto 0);
        RX_CHAR_IS_K_O         : out std_logic_vector(7 downto 0);
        RX_DISP_ERR_O          : out std_logic_vector(7 downto 0);
        RX_PRBS_ERR_O          : out std_logic;
        RX_BUF_ERR_O           : out std_logic;
        RX_BYTE_IS_ALIGNED_O   : out std_logic;
        RX_BYTE_REALIGN_O      : out std_logic;
        RX_RESET_DONE_O        : out std_logic;
        RX_EI_EN_O             : out std_logic;
        RX_DATA_O              : out std_logic_vector(63 downto 0);

        -- Register File
        REGFILE_CLK_I          : in  std_logic;
        REGFILE_WE_I           : in  std_logic;
        REGFILE_EN_I           : in  std_logic;
        REGFILE_ADDR_I         : in  std_logic_vector(7 downto 0);
        REGFILE_DI_I           : in  std_logic_vector(15 downto 0);
        REGFILE_MASK_I         : in  std_logic_vector(15 downto 0);
        REGFILE_DO_O           : out std_logic_vector(15 downto 0);
        REGFILE_RDY_O          : out std_logic;

        -- ADPLL
        PLL_RESET_I            : in  std_logic;
        PLL_CLK_O              : out std_logic;

        -- Miscellaneous
        LOOPBACK_I             : in std_logic_vector(2 downto 0)
        );
  end component CC_SERDES;

end package gatemate;
