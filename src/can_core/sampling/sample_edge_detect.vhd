library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sample_edge_detect is
    port(
        clk                                 : in    std_logic                   := '0';
        rst_n                               : in    std_logic                   := '1';
        data_i                              : in    std_logic                   := '1';
        sample_i                            : in    std_logic                   := '0';
        edge_detect_o                       : out   std_logic                   := '0'
    );
end entity;

architecture rtl of sample_edge_detect is

    type state_t is (dominant_s, recessive_s);

    signal current_state, new_state         : state_t                           := recessive_s;
    signal edge_s                           : std_logic                         := '0';
begin

    edge_detect_o <= edge_s;

    sample_validator_p : process(current_state, data_i, sample_i)
    begin 
        new_state <= current_state;
        edge_s <= '0';
        
        case current_state is 
            when dominant_s => 
                if data_i = '0' and sample_i = '1' then
                    new_state <= recessive_s;
                    edge_s <= '1';
                end if;
            when recessive_s =>
                if data_i = '1' and sample_i = '1' then
                    new_state <= dominant_s;
                    edge_s <= '1';
                end if;
            when others => 
                new_state <= dominant_s;
                edge_s <= '0';
        end case;
    end process sample_validator_p;

    p : process(clk)
    begin 
        if rising_edge(clk) then 
            current_state <= new_state;
            if rst_n = '0' then 
                current_state <= dominant_s;
            end if;
        end if;
    end process p;

end rtl ; -- rtl