library ieee;
use ieee.std_logic_1164.all;

entity usb_fs is
  port (
    clk48    : in  std_logic;
    reset    : in  std_logic;
    enable   : in  std_logic;

    ulpi_dir : in  std_logic;
    phy_rst  : in  std_logic;
    pll_rst  : out std_logic;

    -- I/O to ST micro STUSB03E transceiver
    fs_rcv  : in    std_logic;
    fs_dp   : inout std_logic;
    fs_dm   : inout std_logic;
    fs_oen  : out   std_logic;
    fs_con  : out   std_logic;
    fs_sus  : out   std_logic;
    fs_bdet : in    std_logic
    );
end entity usb_fs;

architecture rtl of usb_fs is
  type dev_state_t is (DEV_OFF_ST, DEV_PWR_ST);
  signal dev_state : dev_state_t;
  signal dev_next  : dev_state_t;

  signal connect : std_logic;
  signal suspend : std_logic;
begin

  pll_rst <= phy_rst or (pll_rst and ulpi_dir);

  fs_io_i: entity work.fs_io
    port map (
      clk48 => clk48,
      reset => reset,

      -- Internal signals to/from USB SIE
      tx_en   => '0',
      tx_dp   => '1',
      tx_dn   => '0',

      rxd     => open,
      rx_dp   => open,
      rx_dn   => open,

      connect => connect,
      suspend => suspend,
      busdet  => open,

      -- I/O to ST micro STUSB03E transceiver
      fs_rcv  => fs_rcv,
      fs_dp   => fs_dp,
      fs_dm   => fs_dm,
      fs_oen  => fs_oen,
      fs_con  => fs_con,
      fs_sus  => fs_sus,
      fs_bdet => fs_bdet);

  -- Top level device state machine
  top_state_reg_p: process (clk48, reset) is
  begin
    if reset = '1' then
      dev_state <= DEV_OFF_ST;
    elsif rising_edge(clk48) then
      dev_state <= dev_next;
    end if;
  end process top_state_reg_p;

  top_state_p: process (all) is
  begin
    suspend <= '1';
    connect <= '0';

    dev_next <= DEV_OFF_ST;

    case dev_state is
      when DEV_OFF_ST =>
        if enable = '1' then
          dev_next <= DEV_PWR_ST;
        end if;

      when DEV_PWR_ST =>
        suspend <= '0';
        connect <= '1';
        dev_next <= DEV_PWR_ST;

      when others => null;
    end case;
  end process top_state_p;

end architecture rtl;
