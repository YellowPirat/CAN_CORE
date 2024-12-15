library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

use work.can_core_intf.all;


entity exchange_testbench is 
    port (
        clk                     : in  std_logic;
        rst_n                   : in  std_logic;

        can_core_intf           : inout can_core_comb_intf_t;

        output_fifo_valid       : out std_logic;
        output_fifo_ready       : in std_logic
    );
end exchange_testbench;

architecture rtl of exchange_testbench is
    type state_t is (wait_s, write_s, next_s, finished_s);
    signal current_state, next_state    : state_t;

    signal en_s                         : std_logic;

    signal count                        : unsigned(32 downto 0);

    signal done_s                       : std_logic;

    signal rst_h                        : std_logic;

    signal can_core_vector_s            : can_core_vector_t;

    signal add_vector                   : can_core_vector_t;

    signal random_vec_s                 : std_logic_vector(31 downto 0);

begin
    
    rst_h <= not rst_n;

    can_core_intf.output <= to_can_core_intf(can_core_vector_s);

    process(clk)
    begin 
        if rising_edge(clk) then 
            for i in 0 to 5 loop
                can_core_vector_s(32 * i + 31 downto i * 32) <= random_vec_s;
            end loop;
        end if;
    end process;

    rng_i : entity work.olo_base_prbs
        generic map(
            LfsrWidth_g         => 32,
            Polynomial_g        => "10101010101010101010101010101010",
            Seed_g              => "11001100110011001100110011001100",
            BitsPerSymbol_g     => 32
        )
        port map(
            Clk                 => clk,
            Rst                 => rst_h,
            Out_Data            => random_vec_s,
            Out_Ready           => en_s
        );


    count_p : process(clk)
    begin
        if rising_edge(clk) then

            if count > 0 then 
                done_s <= '0';

                if en_s = '1' then 
                    count <= count - 1;
                end if;
            else
                done_s <= '1';
            end if;

            if rst_n = '0' then
                count <= to_unsigned(50, count'length);
            end if;
        end if;
    end process count_p;

    clk_p : process(clk)
    begin
        if rising_edge(clk) then
            current_state <= next_state;
            if rst_n = '0' then
                current_state <= wait_s;
            end if;
        end if;
    end process clk_p;
    
    sm_i0 : process(current_state, output_fifo_ready, done_s)
    begin 
        next_state <= current_state;
        en_s <= '0';
        output_fifo_valid <= '0';


        case current_state is 

            when wait_s =>
                if output_fifo_ready = '1' then 
                    next_state <= write_s;
                end if;

            when write_s =>
                if output_fifo_ready = '1' then
                    next_state <= next_s;
                end if;

                output_fifo_valid <= '1';

            when next_s =>
                if done_s = '1' then 
                    next_state <= finished_s;
                else 
                    if output_fifo_ready = '1' then
                        next_state <= wait_s;
                    else 
                        next_state <= write_s;
                    end if;
                end if;

                en_s <= '1';

            when others =>
                next_state <= finished_s;

        end case;
    end process sm_i0;



end;