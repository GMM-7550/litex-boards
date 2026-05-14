--
--
--

library ieee;
use ieee.std_logic_1164.all;

entity div4 is port (
    clk_in  : in  std_logic;
    clk_out : out std_logic);
end entity div4;

architecture rtl of div4 is
  signal dff1, dff2 : std_logic;
begin

  p_dff1: process (clk_in) is
  begin
    if rising_edge(clk_in) then
      dff1 <= not dff1;
    end if;
  end process p_dff1;

  p_dff2: process (clk_in) is
  begin
    if rising_edge(clk_in) then
      if dff1 = '1' then
        dff2 <= not dff2;
      end if;
    end if;
  end process p_dff2;

  clk_out <= dff2;

end architecture rtl;
