library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;


entity exchange_testbench is 
    generic(
        TestDataLen_g       : positive := 100;
        TimeStampLengh_g    : positive := 48;
        CanDataLengh_g      : positive := 64
    );
    port (
        clk                 : in  std_logic;
        rst_n               : in  std_logic;

        timestamp		    : out std_logic_vector(TimeStampLengh_g - 1 downto 0);
        can_id              : out std_logic_vector(28 downto 0);
        rtr                 : out std_logic;
        eff                 : out std_logic;
        err                 : out std_logic;
        dlc                 : out std_logic_vector(3 downto 0);
        data                : out std_logic_vector(CanDataLengh_g -1 downto 0);
        core_error          : out std_logic_vector(3 downto 0);

        output_fifo_valid   : out std_logic;
        output_fifo_ready   : in std_logic;

        fifo_full           : in std_logic
    );
end exchange_testbench;

architecture rtl of exchange_testbench is
    type state_t is (wait_s, write_s, next_s, finished_s);
    signal current_state, next_state : state_t;
    signal en_s         : std_logic;
    signal done_s       : std_logic;

    signal rst_h        : std_logic;

    signal q, d         : unsigned(4 downto 0);

    -- timestamp
    signal q_ts, d_ts   : unsigned(TimeStampLengh_g - 1 downto 0);



    begin
    
    rst_h <= not rst_n;

    -- can_id
    prbs_i0 : entity work.olo_base_prbs
        generic map(
            LfsrWidth_g     => 29,
            Polynomial_g    => "10011100111001110011100111001",
            Seed_g          => "10101010101010101010101010101",
            BitsPerSymbol_g => 29
        )
        port map(
            Clk             => clk,
            Rst             => rst_h,

            Out_Data        => can_id,
            Out_Ready       => en_s
        );


    -- data
    prbs_i1 : entity work.olo_base_prbs
        generic map(
            LfsrWidth_g     => 64,
            Polynomial_g    => "1001100110011001100110011001100110011001100110011001100110011001",
            Seed_g          => "1010101010101010101010101010101010101010101010101010101010101010",
            BitsPerSymbol_g => 64
        )
        port map(
            Clk             => clk,
            Rst             => rst_h,

            Out_Data        => data,
            Out_Ready       => en_s
        );

    -- timestamp
    q_ts <= to_unsigned(123456, q_ts'length) when rst_n = '0' else d_ts when rising_edge(clk);
    d_ts <= q_ts when en_s = '0' else q_ts + 10;
    timestamp <= std_logic_vector(q_ts);



    -- Flags
    rtr <= '0';
    eff <= '0';
    err <= '0';
    core_error <= "0000";
    dlc <= "1000";


    
    current_state <= wait_s when rst_n = '0' else next_state when rising_edge(clk);
    sm_i0 : process(current_state, fifo_full, output_fifo_ready, done_s)
    begin 
        next_state <= current_state;
        en_s <= '0';
        output_fifo_valid <= '0';


        case current_state is 

            when wait_s =>
                if fifo_full = '0' then 
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
                    if fifo_full = '1' then
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


    q <= to_unsigned(0, q'length) when rst_n = '0' else d when rising_edge(clk);
    d <= q when q = 10 or en_s = '0' else q + 1;
    done_s <= '1' when q = 10 else '0';
end;