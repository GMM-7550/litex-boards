--

library ieee;
use ieee.std_logic_1164.all;

entity serdes_reset_controller is
  port (
    clk_i : in  std_logic;
    rst_i : in  std_logic;

    pll_reset_o : out std_logic;
    pll_clk_i   : in  std_logic;

    tx_power_down_n_o : out std_logic;
    rx_power_down_n_o : out std_logic;

    tx_reset_o     : out std_logic;
    tx_pcs_reset_o : out std_logic;
    tx_pma_reset_o : out std_logic;

    rx_reset_o     : out std_logic;
    rx_pma_reset_o : out std_logic;
    rx_eqa_reset_o : out std_logic;
    rx_cdr_reset_o : out std_logic;
    rx_pcs_reset_o : out std_logic;
    rx_buf_reset_o : out std_logic;

    done_o : out std_logic
    );
end entity serdes_reset_controller;

architecture rtl of serdes_reset_controller is
  signal clk          : std_logic;
  signal pll_rst      : std_logic;
  signal rst_sync     : std_logic_vector(1 downto 0); -- resynchronizer to pll_clk
  signal rst_master   : std_logic;
  signal rst_steps    : std_logic_vector(3 downto 0);
begin

  clk <= pll_clk_i;
  -- clk <= clk_i;

  p_pll_rst: process(clk_i) is
  begin
    if rising_edge(clk_i) then
      pll_rst <= rst_i;
    end if;
  end process p_pll_rst;

  pll_reset_o <= pll_rst;

  p_rst_sync: process(pll_rst, clk) is
  begin
    if pll_rst = '1' then
      rst_sync <= (others => '1');
    elsif rising_edge(clk) then
      rst_sync <= rst_sync(rst_sync'left-1 downto 0) & "0";
    end if;
  end process p_rst_sync;

  rst_master <= rst_sync(rst_sync'left);

  p_rst_steps: process(clk) is
  begin
    if rising_edge(clk) then
      if rst_master = '1' then
        rst_steps <= (others => '1');
      else
        rst_steps <= rst_steps(rst_steps'left - 1 downto 0) & "0";
      end if;
    end if;
  end process p_rst_steps;

  tx_power_down_n_o <= not rst_steps(0);
  rx_power_down_n_o <= not rst_steps(0);

  tx_pma_reset_o <= rst_steps(1);
  tx_pcs_reset_o <= rst_steps(1);

  rx_pma_reset_o <= rst_steps(1);
  rx_eqa_reset_o <= rst_steps(1);
  rx_cdr_reset_o <= rst_steps(1);
  rx_pcs_reset_o <= rst_steps(1);
  rx_buf_reset_o <= rst_steps(1);

  tx_reset_o <= rst_steps(2);
  rx_reset_o <= rst_steps(2);

  done_o <= not rst_steps(rst_steps'left);

end architecture rtl;
