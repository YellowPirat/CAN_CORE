library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity quantum_cnt is 
    port (
        clk             : in    std_logic;
        rst_n           : in    std_logic;


        reload_value_i  : in    unsigned(5 downto 0);
        reload_i        : in    std_logic;

        done_o          : out   std_logic;
        cnt_o           : out   unsigned(5 downto 0)
    );

end entity;

architecture rtl of quantum_cnt is

    signal cnt_s                : unsigned(5 downto 0);

    signal reload_value_s       : unsigned(5 downto 0);

begin

    reload_p : process(clk)
    begin
        if rising_edge(clk) then
            if reload_i = '1' then
                reload_value_s <= reload_value_i;
            end if;

            if rst_n = '0' then 
                reload_value_s <= to_unsigned(12, reload_value_s'length);
            end if;
        end if;
    end process;

    done_o <= '1' when cnt_s = to_unsigned(0, cnt_s'length) else '0';
    cnt_o <= cnt_s;

    cnt_p : process(clk)
    begin
        if rising_edge(clk) then

            if cnt_s = to_unsigned(0, cnt_s'length) then
                cnt_s <= reload_value_s;
            else
                cnt_s <= cnt_s - 1;
            end if;

            if rst_n = '0' or reload_i = '1' then
                cnt_s <= reload_value_i;
            end if;
        end if;
    end process cnt_p;

end architecture ;