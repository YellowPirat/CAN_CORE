library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity idle_detect is
    port (
        clk                 : in    std_logic;
        rst_n               : in    std_logic;
        frame_end_i         : in    std_logic;
        edge_i              : in    std_logic;
        enable_o            : out   std_logic
    );
end entity;

architecture rtl of idle_detect is

    type state_t is (idle_s, active_s);
    signal current_state, new_state : state_t;
    signal reload_s      : std_logic := '0';
    signal underflow_s  : std_logic := '0';

    signal q     : unsigned(9 downto 0);

begin

    cnt_p : process(clk)
    begin
        if rising_edge(clk) then
            if reload_s = '1' then 
                q <= to_unsigned(600, q'length);
            elsif q > 0 then 
                q <= q - 1;
            end if;

            if rst_n = '0' then
                q <= to_unsigned(0, q'length);
            end if;
        end if;
    end process cnt_p;


    underflow_s <= '1' when q = 0 else '0';

    enable_o <= '1' when q > 0 else '0';


    idle_detect_p : process(current_state, edge_i, frame_end_i, underflow_s)
    begin 
        new_state <= current_state;
        reload_s <= '0';
        
        case current_state is 
            when idle_s => 
                if edge_i = '1' then
                    reload_s <= '1';
                    new_state <= active_s;
                end if;
            when active_s =>
                if underflow_s = '1' or frame_end_i = '1' then
                    new_state <= idle_s;
                end if;
                if edge_i = '1' then
                    reload_s <= '1';
                end if;

            when others => 
                new_state <= idle_s;
        end case;
    end process idle_detect_p;

    p : process(clk)
    begin
        if rising_edge(clk) then 
            current_state <= new_state;
            if rst_n = '0' then
                current_state <= idle_s;
            end if;
        end if;
    end process p;


end architecture;