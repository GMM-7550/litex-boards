library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library cc;
use cc.gatemate.all;

entity usb3_test is
  port (
    -- ser_tx_p : out std_logic;
    -- ser_tx_n : out std_logic;
    -- ser_rx_p : in  std_logic;
    -- ser_rx_n : in  std_logic;

    dbg_o               : out std_logic_vector(4 downto 0);
    serdes_reset_done_o : out std_logic;
    tx_reset_done_o     : out std_logic;
    rx_reset_done_o     : out std_logic;

    wb_clk_i : in std_logic;
    wb_rst_i : in std_logic;
    wb_adr_i : in  std_logic_vector( 7 downto 0);
    wb_dat_i : in  std_logic_vector(31 downto 0);
    wb_dat_o : out std_logic_vector(31 downto 0);
    wb_sel_i : in  std_logic_vector( 3 downto 0);

    wb_cyc_i : in  std_logic;
    wb_stb_i : in  std_logic;
    wb_we_i  : in  std_logic;
    wb_ack_o : out std_logic
    );
end entity usb3_test;

architecture rtl of usb3_test is
  signal pll_clk   : std_logic;
  signal pll_reset : std_logic;

  signal tx_power_down_n : std_logic;
  signal rx_power_down_n : std_logic;

  signal tx_reset     : std_logic;
  signal tx_pcs_reset : std_logic;
  signal tx_pma_reset : std_logic;

  signal rx_reset     : std_logic;
  signal rx_pma_reset : std_logic;
  signal rx_eqa_reset : std_logic;
  signal rx_cdr_reset : std_logic;
  signal rx_pcs_reset : std_logic;
  signal rx_buf_reset : std_logic;

  signal tx_reset_done : std_logic;
  signal rx_reset_done : std_logic;

  signal tx_elec_idle     : std_logic;
  signal tx_8b10b_en      : std_logic;
  signal tx_8b10b_bypass  : std_logic_vector(7 downto 0);
  signal tx_char_is_k     : std_logic_vector(7 downto 0);
  signal tx_char_dispmode : std_logic_vector(7 downto 0);
  signal tx_char_dispval  : std_logic_vector(7 downto 0);
  signal tx_data          : std_logic_vector(63 downto 0);

  signal tx_detect_rx         : std_logic;
  signal tx_detect_rx_present : std_logic;
  signal tx_detect_rx_done    : std_logic;

  signal lfps_bit : std_logic;

  signal poll_burst : std_logic;
  signal poll_burst_next : std_logic;
  signal clk_cnt : std_logic_vector(17 downto 0);
  signal clk_cnt_init : std_logic_vector(17 downto 0);
  signal clk_cnt_load : std_logic;
  signal clk_cnt_ovfl : std_logic;

  signal rx_en_ei_detect : std_logic;
  signal rx_ei_detect    : std_logic;

  -- SerDes regisger bus
  signal regfile_clk : std_logic;
  signal regfile_en  : std_logic;
  signal regfile_we  : std_logic;
  signal regfile_adr : std_logic_vector(7 downto 0);
  signal regfile_dat_wb2r : std_logic_vector(15 downto 0);
  signal regfile_msk      : std_logic_vector(15 downto 0);
  signal regfile_dat_r2wb : std_logic_vector(15 downto 0);
  signal regfile_rdy : std_logic;

  -- Debugging

begin

  i_wb_reg_adapter: entity work.wb_ccserdes_reg
    port map (
      wb_clk_i => wb_clk_i,
      wb_rst_i => wb_rst_i,
      wb_adr_i => wb_adr_i,
      wb_dat_i => wb_dat_i,
      wb_dat_o => wb_dat_o,
      wb_sel_i => wb_sel_i,
      wb_cyc_i => wb_cyc_i,
      wb_stb_i => wb_stb_i,
      wb_we_i  => wb_we_i,
      wb_ack_o => wb_ack_o,

      regfile_clk_o => regfile_clk,
      regfile_en_o  => regfile_en,
      regfile_we_o  => regfile_we,
      regfile_adr_o => regfile_adr,
      regfile_dat_o => regfile_dat_wb2r,
      regfile_msk_o => regfile_msk,
      regfile_dat_i => regfile_dat_r2wb,
      regfile_rdy_i => regfile_rdy
      );

  i_reset_ctrl: entity work.serdes_reset_controller
    port map (
      clk_i => wb_clk_i,
      rst_i => wb_rst_i,

      pll_reset_o    => pll_reset,
      pll_clk_i      => pll_clk,

      tx_power_down_n_o => tx_power_down_n,
      rx_power_down_n_o => rx_power_down_n,

      tx_reset_o     => tx_reset,
      tx_pcs_reset_o => tx_pcs_reset,
      tx_pma_reset_o => tx_pma_reset,

      rx_reset_o     => rx_reset,
      rx_pma_reset_o => rx_pma_reset,
      rx_eqa_reset_o => rx_eqa_reset,
      rx_cdr_reset_o => rx_cdr_reset,
      rx_pcs_reset_o => rx_pcs_reset,
      rx_buf_reset_o => rx_buf_reset,

      done_o => serdes_reset_done_o
      );

  i_serdes: component cc_serdes
    generic map (
      serdes_enable => 1,
      pll_en_adpll_ctrl => 1,
      pll_ref_sel => 1, -- LVDS (0 -- single ended)

      pll_config_sel  => 1,  -- PLL configuration from registers
      pll_fcntrl      => 58, -- M1 = 20
      pll_main_divsel => 27, -- N3 = 5, N1 = 2???, N2 = 5: 0_11_0_11
      pll_out_divsel  => 0,  -- M3 = 1
      tx_datapath_sel => 3,  -- 64/80 bit, M4 = 4

      tx_power_down_n => 1,
      rx_power_down_n => 1
      )
    port map (
  --     ser_tx_p => ser_tx_p,
  --     ser_tx_n => ser_tx_n,
  --     ser_rx_p => ser_rx_p,
  --     ser_rx_n => ser_rx_n,

      pll_clk_o           => pll_clk,
      rx_clk_i            => pll_clk,
      tx_clk_i            => pll_clk,

      tx_reset_done_o     => tx_reset_done,
      rx_reset_done_o     => rx_reset_done,

      tx_reset_i          => tx_reset,
      tx_pcs_reset_i      => tx_pcs_reset,
      tx_pma_reset_i      => tx_pma_reset,
      tx_power_down_n_i   => tx_power_down_n,

      tx_polarity_i       => '0',
      tx_prbs_sel_i       => (others => '0'),
      tx_prbs_force_err_i => '0',
      tx_8b10b_en_i       => tx_8b10b_en,
      tx_8b10b_bypass_i   => tx_8b10b_bypass,
      tx_char_is_k_i      => tx_char_is_k,
      tx_char_dispmode_i  => tx_char_dispmode,
      tx_char_dispval_i   => tx_char_dispval,
      tx_elec_idle_i      => tx_elec_idle,
      tx_data_i           => tx_data,
      tx_detect_rx_i      => tx_detect_rx,
      tx_detect_rx_present_o => tx_detect_rx_present,
      tx_detect_rx_done_o => tx_detect_rx_done,

      rx_reset_i          => rx_reset,
      rx_pma_reset_i      => rx_pma_reset,
      rx_eqa_reset_i      => rx_eqa_reset,
      rx_cdr_reset_i      => rx_cdr_reset,
      rx_pcs_reset_i      => rx_pcs_reset,
      rx_buf_reset_i      => rx_buf_reset,
      rx_power_down_n_i   => rx_power_down_n,

      rx_polarity_i       => '0',
      rx_prbs_sel_i       => (others => '0'),
      rx_prbs_cnt_reset_i => '0',
      rx_8b10b_en_i       => '0',
      rx_8b10b_bypass_i   => (others => '0'),
      rx_en_ei_detector_i => rx_en_ei_detect,
      rx_comma_detect_en_i=> '0',
      rx_slide_i          => '0',
      rx_mcomma_align_i   => '0',
      rx_pcomma_align_i   => '0',

      rx_ei_en_o          => rx_ei_detect,

      pll_reset_i         => pll_reset,
      loopback_i          => "010", -- (others =>'0'),

      regfile_clk_i  => regfile_clk,
      regfile_en_i   => regfile_en,
      regfile_we_i   => regfile_we,
      regfile_addr_i => regfile_adr,
      regfile_di_i   => regfile_dat_wb2r,
      regfile_mask_i => regfile_msk,
      regfile_do_o   => regfile_dat_r2wb,
      regfile_rdy_o  => regfile_rdy
      );

  tx_reset_done_o <= tx_reset_done;
  rx_reset_done_o <= rx_reset_done;

  -- tx_elec_idle <= '0';
  tx_8b10b_en  <= '1';
  tx_8b10b_bypass <= (others => '1');
  tx_char_is_k <= (others => '0');

  p_cnt_down: process(pll_clk) is
  begin
    if rising_edge(pll_clk) then
      if clk_cnt_load = '1' then
        clk_cnt <= clk_cnt_init;
      elsif clk_cnt_ovfl = '0' then
        clk_cnt <= std_logic_vector(unsigned(clk_cnt) - 1);
      end if;
    end if;
  end process;

  clk_cnt_ovfl <= clk_cnt(clk_cnt'left);

  p_poll_burst: process(pll_clk) is
  begin
    if rising_edge(pll_clk) then
      if tx_reset_done = '0' then
        poll_burst <= '0';
      else
        poll_burst <= poll_burst_next;
      end if;
    end if;
  end process;

  p_poll_burst_fsm: process(all) is
  begin
    clk_cnt_init <= (others => '1');
    clk_cnt_load <= '0';
    if poll_burst = '0' then
      if clk_cnt_ovfl = '1' then
        poll_burst_next <= '1';
        clk_cnt_init <= std_logic_vector(to_unsigned(64-2, clk_cnt'length));
        clk_cnt_load <= '1';
      else
        poll_burst_next <= '0';
      end if;
    else
      if clk_cnt_ovfl = '1' then
        poll_burst_next <= '0';
        clk_cnt_init <= std_logic_vector(to_unsigned(64*9 - 2, clk_cnt'length));
        clk_cnt_load <= '1';
      else
        poll_burst_next <= '1';
      end if;
    end if;
  end process;

  tx_elec_idle <= not poll_burst;

  p_lfps_bit: process(pll_clk) is
  begin
    if rising_edge(pll_clk) then
      if tx_elec_idle = '1' then
        lfps_bit <= '0';
      else
        lfps_bit <= not lfps_bit;
      end if;
    end if;
  end process;

  tx_char_dispmode <= (others => lfps_bit);
  tx_char_dispval  <= (others => lfps_bit);
  tx_data          <= (others => lfps_bit);

  p_rx_ei: process(pll_clk) is
  begin
    if rising_edge(pll_clk) then
      if rx_reset_done = '0' then
        rx_en_ei_detect <= '0';
      else
        rx_en_ei_detect <= '1';
      end if;
    end if;
  end process;

  tx_detect_rx <= '0';
  -- tx_detect_rx_present
  -- tx_detect_rx_done

  dbg_o <= (4 => pll_clk,
            3 => rx_ei_detect,
            2 => rx_en_ei_detect,
            1 => tx_elec_idle,
            0 => lfps_bit);

end architecture rtl;
