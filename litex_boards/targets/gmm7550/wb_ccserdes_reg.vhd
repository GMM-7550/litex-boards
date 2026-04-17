--
-- Wishbone adapter for GateMate SerDes register interface
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity wb_ccserdes_reg is
  port (
    wb_clk_i      : in  std_logic;
    wb_rst_i      : in  std_logic;
    wb_adr_i      : in  std_logic_vector( 9 downto 0);
    wb_dat_i      : in  std_logic_vector(31 downto 0);
    wb_dat_o      : out std_logic_vector(31 downto 0);
    wb_sel_i      : in  std_logic_vector( 3 downto 0);

    wb_cyc_i      : in  std_logic;
    wb_stb_i      : in  std_logic;
    wb_we_i       : in  std_logic;
    wb_ack_o      : out std_logic;

    regfile_clk_o : out std_logic;
    regfile_en_o  : out std_logic;
    regfile_we_o  : out std_logic;
    regfile_adr_o : out std_logic_vector( 7 downto 0);
    regfile_dat_o : out std_logic_vector(15 downto 0);
    regfile_msk_o : out std_logic_vector(15 downto 0);
    regfile_dat_i : in  std_logic_vector(15 downto 0);
    regfile_rdy_i : in  std_logic);
end entity wb_ccserdes_reg;

architecture rtl of wb_ccserdes_reg is
  type wb_fsm_state_t is (wb_idle_st, wb_start_st, wb_wait_st, wb_ack_st, wb_dead_time_st);
  signal wb_fsm_state : wb_fsm_state_t;
  signal wb_fsm_next  : wb_fsm_state_t;

  signal we_reg   : std_logic;
  signal adr_reg  : std_logic_vector(9 downto 0);
  signal adr_reg_load : std_logic;

  signal wsel_reg : std_logic_vector( 1 downto 0);
  signal wdat_reg : std_logic_vector(15 downto 0);
  signal wdat_reg_load : std_logic;

  signal rdat_reg : std_logic_vector(15 downto 0);
  signal rdat_reg_load : std_logic;

  signal to_cnt : std_logic_vector(5 downto 0); -- 16 cycles min between SerDes accesses
  signal to_start : std_logic;
  signal to_end   : std_logic;
begin

  p_wb_fsm_state: process (wb_clk_i) is
  begin
    if rising_edge(wb_clk_i) then
      if wb_rst_i = '1' then
        wb_fsm_state <= wb_idle_st;
      else
        wb_fsm_state <= wb_fsm_next;
      end if;
    end if;
  end process p_wb_fsm_state;

  p_wb_fsm: process (all) is
  begin
    wb_fsm_next <= wb_idle_st;

    wb_ack_o <= '0';

    regfile_en_o <= '0';
    regfile_we_o <= '0';

    to_start <= '0';
    adr_reg_load <= '0';
    wdat_reg_load <= '0';
    rdat_reg_load <= '0';

    case wb_fsm_state is

      when wb_idle_st =>
        if wb_cyc_i = '1' and wb_stb_i = '1' then
          wb_fsm_next <= wb_start_st;
          adr_reg_load <= '1';
          wdat_reg_load <= wb_we_i;
        else
          wb_fsm_next <= wb_idle_st;
        end if;

      when wb_start_st =>
        regfile_en_o <= '1';
        regfile_we_o <= we_reg;
        if regfile_rdy_i = '1' then
          rdat_reg_load <= not we_reg;
          wb_fsm_next <= wb_ack_st;
        else
          wb_fsm_next <= wb_wait_st;
        end if;

      when wb_wait_st =>
        if regfile_rdy_i = '1' then
          rdat_reg_load <= not we_reg;
          wb_fsm_next <= wb_ack_st;
        else
          wb_fsm_next <= wb_wait_st;
        end if;

      when wb_ack_st =>
        wb_ack_o <= '1';
        to_start <= '1';
        wb_fsm_next <= wb_dead_time_st;

      when wb_dead_time_st =>
        if to_end = '1' then
          wb_fsm_next <= wb_idle_st;
        else
          wb_fsm_next <= wb_dead_time_st;
        end if;

      when others => null;

    end case;
  end process p_wb_fsm;

  p_to_cnt: process (wb_clk_i) is
  begin
    if rising_edge(wb_clk_i) then
      if wb_rst_i = '1' then
        to_cnt <= (others => '1');
      else
        if to_start = '1' then
          to_cnt <= (to_cnt'left => '0', others => '1');
        elsif to_end = '0' then
          to_cnt <= std_logic_vector(unsigned(to_cnt) - 1);
        end if;
      end if;
    end if;
  end process p_to_cnt;

  to_end <= to_cnt(to_cnt'left);

  p_adr_reg: process (wb_clk_i) is
  begin
    if rising_edge(wb_clk_i) then
      if adr_reg_load = '1' then
        we_reg <= wb_we_i;
        adr_reg <= wb_adr_i;
      end if;
    end if;
  end process p_adr_reg;

  p_wdat_reg: process (wb_clk_i) is
  begin
    if rising_edge(wb_clk_i) then
      if wdat_reg_load = '1' then
        wdat_reg <= wb_dat_i(15 downto 0);
        wsel_reg <= wb_sel_i( 1 downto 0);
      end if;
    end if;
  end process p_wdat_reg;

  p_rdat_reg: process (wb_clk_i) is
  begin
    if rising_edge(wb_clk_i) then
      if rdat_reg_load = '1' then
        rdat_reg <= regfile_dat_i;
      end if;
    end if;
  end process p_rdat_reg;

  wb_dat_o <= (15 downto 0 => rdat_reg, others => '0');

  regfile_clk_o <= wb_clk_i;

  regfile_adr_o <= adr_reg(9 downto 2);
  regfile_dat_o <= wdat_reg;
  regfile_msk_o(15 downto 8) <= (others => '1') when wsel_reg(1) = '1' else (others => '0');
  regfile_msk_o( 7 downto 0) <= (others => '1') when wsel_reg(0) = '1' else (others => '0');

end architecture rtl;
