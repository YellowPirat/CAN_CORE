library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity frame_valid_cntr is
    port (
        clk                 : in    std_logic;
        rst_n               : in    std_logic;

        can_frame_valid_i   : in    std_logic;
        error_i             : in    std_logic;
        sof_state_i         : in    std_logic;

        frame_valid_o       : out   std_logic
    );
end frame_valid_cntr;

architecture rtl of frame_valid_cntr is

    type state_t is (idle_s, error_frame_s, error_frame_valid_s);
    signal current_state, new_state : state_t;

    signal frame_valid_s            : std_logic;

begin

    frame_valid_o               <= frame_valid_s;
    
    frame_valid_cntr_p : process(current_state, can_frame_valid_i, error_i, sof_state_i) 
    begin
        new_state               <= current_state;
        frame_valid_s           <= '0';

        case current_state is
            when idle_s =>
                if sof_state_i = '1' and can_frame_valid_i = '1' then
                    frame_valid_s   <= '1';
                end if;

                if error_i = '1' then
                    new_state       <= error_frame_s;
                    frame_valid_s   <= '0';
                end if;

            when error_frame_s =>
                if sof_state_i = '1' then
                    new_state       <= error_frame_valid_s;
                    frame_valid_s   <= '1';
                end if;

            when error_frame_valid_s =>
                if sof_state_i = '0' then
                    new_state       <= idle_s;
                    frame_valid_s   <= '0';
                else
                    frame_valid_s   <= '1';
                end if;

            when others =>
                    new_state  <= idle_s;
        end case;
    end process frame_valid_cntr_p;

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

