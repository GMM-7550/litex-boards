library ieee;
use ieee.std_logic_1164.all;

library cc;
use cc.gatemate.all;

entity usb3_test is
  port (
    -- ser_tx_p : out std_logic;
    -- ser_tx_n : out std_logic;
    -- ser_rx_p : in  std_logic;
    -- ser_rx_n : in  std_logic;

    wb_clk_i : in std_logic;
    wb_rst_i : in std_logic;
    wb_adr_i : in  std_logic_vector( 9 downto 0);
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
  -- SerDes regisger bus
  signal regfile_clk : std_logic;
  signal regfile_en  : std_logic;
  signal regfile_we  : std_logic;
  signal regfile_adr : std_logic_vector(7 downto 0);
  signal regfile_dat_wb2r : std_logic_vector(15 downto 0);
  signal regfile_msk      : std_logic_vector(15 downto 0);
  signal regfile_dat_r2wb : std_logic_vector(15 downto 0);
  signal regfile_rdy : std_logic;
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

  i_serdes: component cc_serdes
  --   -- generic map (
  --   --   )
    port map (
  --     ser_tx_p => ser_tx_p,
  --     ser_tx_n => ser_tx_n,
  --     ser_rx_p => ser_rx_p,
  --     ser_rx_n => ser_rx_n,

      tx_reset_i          => '0',
      tx_pcs_reset_i      => '0',
      tx_pma_reset_i      => '0',
      tx_power_down_n_i   => '0',
      tx_clk_i            => '0',
      tx_polarity_i       => '0',
      tx_prbs_sel_i       => (others => '0'),
      tx_prbs_force_err_i => '0',
      tx_8b10b_en_i       => '1',
      tx_8b10b_bypass_i   => (others => '0'),
      tx_char_is_k_i      => (others => '0'),
      tx_char_dispmode_i  => (others => '0'),
      tx_char_dispval_i   => (others => '0'),
      tx_elec_idle_i      => '0',
      tx_detect_rx_i      => '0',
      tx_data_i           => (others => '0'),

      rx_reset_i          => '0',
      rx_pma_reset_i      => '0',
      rx_eqa_reset_i      => '0',
      rx_cdr_reset_i      => '0',
      rx_pcs_reset_i      => '0',
      rx_buf_reset_i      => '0',
      rx_power_down_n_i   => '0',
      rx_clk_i            => '0',
      rx_polarity_i       => '0',
      rx_prbs_sel_i       => (others => '0'),
      rx_prbs_cnt_reset_i => '0',
      rx_8b10b_en_i       => '0',
      rx_8b10b_bypass_i   => (others => '0'),
      rx_en_ei_detector_i => '0',
      rx_comma_detect_en_i=> '0',
      rx_slide_i          => '0',
      rx_mcomma_align_i   => '0',
      rx_pcomma_align_i   => '0',

      pll_reset_i         => '0',
      loopback_i          => (others =>'0'),

      regfile_clk_i  => regfile_clk,
      regfile_en_i   => regfile_en,
      regfile_we_i   => regfile_we,
      regfile_addr_i => regfile_adr,
      regfile_di_i   => regfile_dat_wb2r,
      regfile_mask_i => regfile_msk,
      regfile_do_o   => regfile_dat_r2wb,
      regfile_rdy_o  => regfile_rdy
      );

end architecture rtl;
