library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity valid_edge_det is
    port (
        clk                                 : in    std_logic           := '0';
        rst_n                               : in    std_logic           := '1';
        valid_i                             : in    std_logic           := '0';
        edge_o                              : out   std_logic           := '0'
    );
end entity;

architecture rtl of valid_edge_det is

    type state_t is (idle_s, edge_det_s);
    signal current_state, new_state         : state_t                   := idle_s;

    signal edge_s                           : std_logic                 := '0';

begin

    edge_o          <= edge_s;

    valid_edge_det_p : process(current_state, valid_i)
    begin
        new_state           <= current_state;
        edge_s              <= '0';

        case current_state is
            when idle_s => 
                if valid_i = '1' then
                    edge_s          <= '1';
                    new_state       <= edge_det_s;
                end if;

            when edge_det_s =>
                if valid_i = '0' then
                    new_state       <= idle_s;
                end if;

            when others =>
                    new_state       <= idle_s;

        end case;
    end process valid_edge_det_p;

    p : process(clk)
    begin 
        if rising_edge(clk) then 
            current_state <= new_state;
            if rst_n = '0' then 
                current_state <= idle_s;
            end if;
        end if;
    end process p;


end rtl;
