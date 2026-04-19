--

library ieee;
use ieee.std_logic_1164.all;

entity cy7c1049 is
  port (
    wb_clk_i : in  std_logic;
    wb_rst_i : in  std_logic;

    wb_cyc_i : in  std_logic;
    wb_stb_i : in  std_logic;
    wb_adr_i : in  std_logic_vector(29 downto 0);
    wb_we_i  : in  std_logic;
    wb_sel_i : in  std_logic_vector(3 downto 0);
    wb_dat_i : in  std_logic_vector(31 downto 0);
    wb_dat_o : out std_logic_vector(31 downto 0);
    wb_ack_o : out std_logic;

    mem_ce_n : out std_logic;
    mem_oe_n : out std_logic;
    mem_we_n : out std_logic;
    mem_adr  : out std_logic_vector(18 downto 0);
    mem_dat  : inout std_logic_vector(7 downto 0)
    );
end entity cy7c1049;

architecture rtl of cy7c1049 is
  signal sel_reg   : std_logic_vector(3 downto 0);
  signal adr_reg   : std_logic_vector(16 downto 0);
  signal adr_load  : std_logic;

  signal wdat_reg  : std_logic_vector(31 downto 0);
  signal wdat_load : std_logic;

  type reg_block_4x8_t is array (3 downto 0) of std_logic_vector(7 downto 0);
  signal rdat_reg  : reg_block_4x8_t;
  signal rdat_load : std_logic_vector(3 downto 0);

  type mem_fsm_state_t is (mem_idle_st, mem_rd_st, mem_rd_ack_st, mem_wr_st);
  signal mem_state : mem_fsm_state_t;
  signal mem_next  : mem_fsm_state_t;
  signal wr_delay  : std_logic;
  signal wr_delay_next : std_logic;
  signal byte_cnt  : std_logic_vector(1 downto 0);
  signal byte_cnt_next : std_logic_vector(1 downto 0);
begin

  p_adr_reg: process(wb_clk_i) is
  begin
    if rising_edge(wb_clk_i) then
      if adr_load = '1' then
        adr_reg <= wb_adr_i(adr_reg'range);
        sel_reg <= wb_sel_i;
      end if;
    end if;
  end process p_adr_reg;

  p_wdat_reg: process(wb_clk_i) is
  begin
    if rising_edge(wb_clk_i) then
      if wdat_load = '1' then
        wdat_reg <= wb_dat_i;
      end if;
    end  if;
  end process p_wdat_reg;

  g_rdat_reg: for i in 3 downto 0 generate
    i_rdat_reg: process(wb_clk_i) is
    begin
      if rising_edge(wb_clk_i) then
        if rdat_load(i) = '1' then
          rdat_reg(i) <= mem_dat;
        end if;
      end if;
    end process i_rdat_reg;
  end generate g_rdat_reg;

  p_fsm_state: process(wb_clk_i) is
  begin
    if rising_edge(wb_clk_i) then
      if wb_rst_i = '1' then
        mem_state <= mem_idle_st;
        byte_cnt <= "00";
        wr_delay <= '0';
      else
        mem_state <= mem_next;
        byte_cnt <= byte_cnt_next;
        wr_delay <= wr_delay_next;
      end if;
    end if;
  end process p_fsm_state;

  p_fsm: process(all) is
  begin
    mem_next <= mem_idle_st;
    byte_cnt_next <= "00";
    wr_delay_next <= '0';

    adr_load  <= '0';
    wdat_load <= '0';
    rdat_load <= (others => '0');

    wb_ack_o <= '0';

    mem_dat  <= (others => 'Z');
    mem_ce_n <= '1';
    mem_oe_n <= '1';
    mem_we_n <= '1';

    case mem_state is
      when mem_idle_st =>
        if wb_cyc_i = '1' and wb_stb_i = '1' then
          adr_load <= '1';
          if wb_we_i = '0' then
            mem_next <= mem_rd_st;
          else
            wb_ack_o  <= '1';
            wdat_load <= '1';
            mem_next <= mem_wr_st;
          end if;
        else
          mem_next <= mem_idle_st;
        end if;

      when mem_rd_st =>
        mem_ce_n <= '0';
        mem_oe_n <= '0';
        case byte_cnt is
          when "00" =>
            rdat_load(0) <= '1';
            byte_cnt_next <= "01";
            mem_next <= mem_rd_st;
          when "01" =>
            rdat_load(1) <= '1';
            byte_cnt_next <= "10";
            mem_next <= mem_rd_st;
          when "10" =>
            rdat_load(2) <= '1';
            byte_cnt_next <= "11";
            mem_next <= mem_rd_st;
          when "11" =>
            rdat_load(3) <= '1';
            byte_cnt_next <= "00";
            mem_next <= mem_rd_ack_st;
          when others => null;
        end case;

      when mem_rd_ack_st =>
        wb_ack_o <= '1';
        mem_next <= mem_idle_st;

      when mem_wr_st =>
        mem_ce_n <= '0';
        case byte_cnt is
          when "00" =>
            mem_next <= mem_wr_st;
            if wr_delay = '0' then
              if sel_reg(0) = '1' then
                mem_dat  <= wdat_reg(7 downto 0);
                mem_we_n <= '0';
                byte_cnt_next <= "00";
                wr_delay_next <= '1';
              else
                byte_cnt_next <= "01";
                wr_delay_next <= '0';
              end if;
            else -- wr_delay = '1'
              byte_cnt_next <= "01";
              wr_delay_next <= '0';
            end if;

          when "01" =>
            mem_next <= mem_wr_st;
            if wr_delay = '0' then
              if sel_reg(1) = '1' then
                mem_dat  <= wdat_reg(15 downto 8);
                mem_we_n <= '0';
                byte_cnt_next <= "01";
                wr_delay_next <= '1';
              else
                byte_cnt_next <= "10";
                wr_delay_next <= '0';
              end if;
            else -- wr_delay = '1'
              byte_cnt_next <= "10";
              wr_delay_next <= '0';
            end if;

          when "10" =>
            mem_next <= mem_wr_st;
            if wr_delay = '0' then
              if sel_reg(2) = '1' then
                mem_dat  <= wdat_reg(23 downto 16);
                mem_we_n <= '0';
                byte_cnt_next <= "10";
                wr_delay_next <= '1';
              else
                byte_cnt_next <= "11";
                wr_delay_next <= '0';
              end if;
            else -- wr_delay = '1'
              byte_cnt_next <= "11";
              wr_delay_next <= '0';
            end if;

          when "11" =>
            if sel_reg(3) = '1' then
              mem_dat  <= wdat_reg(31 downto 24);
              mem_we_n <= '0';
            end if;
            byte_cnt_next <= "00";
            wr_delay_next <= '0';
            mem_next <= mem_idle_st;

          when others => null;
        end case;

      when others => null;
    end case;
  end process p_fsm;

  mem_adr <= adr_reg & byte_cnt;
  wb_dat_o <= rdat_reg(3) & rdat_reg(2) & rdat_reg(1) & rdat_reg(0);
end architecture rtl;
