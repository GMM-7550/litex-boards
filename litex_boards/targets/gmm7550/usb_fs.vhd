library ieee;
use ieee.std_logic_1164.all;

entity usb_fs is
  port (
    ulpi_dir : in  std_logic;
    phy_rst  : in  std_logic;
    pll_rst  : out std_logic
    );
end entity usb_fs;

architecture rtl of usb_fs is
begin
  pll_rst <= phy_rst or (pll_rst and ulpi_dir);
end architecture rtl;
