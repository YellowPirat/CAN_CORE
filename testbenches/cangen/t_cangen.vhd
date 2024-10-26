library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
use std.textio.all;

entity cangen is
end entity;

architecture sim of cangen is

    signal clk, rst_n : std_logic := '0';
    signal simstop : boolean := false;

    signal value1_std_logic_8_bit, value2_std_logic_8_bit: std_logic_vector(7 downto 0);

begin

  -- Clock generation
  clk_p : process
  begin
    clk <= '0';
    wait for 10 ns; 
    clk <= '1'; 
    wait for 10 ns;
    if simstop then
      wait;
    end if;
  end process clk_p;

  -- Reset generation
  rst_p : process
  begin
    rst_n <= '0';
    wait for 20 ns;
    rst_n <= '1';
    wait;
  end process rst_p;

  simstop_p : process
  begin
  wait for 10 us;
    simstop <= true;
    wait;
  end process simstop_p;

    p_read : process(rst_n,clk)
    --------------------------------------------------------------------------------------------------
    constant NUM_COL                : integer := 2;   -- number of column of file
    type t_integer_array       is array(integer range <> )  of integer;
    file test_vector                : text open read_mode is "data.txt";
    variable row                    : line;
    variable v_data_read            : t_integer_array(1 to NUM_COL);
    variable v_data_row_counter     : integer := 0;
    begin
      
      if(rst_n='0') then
        v_data_row_counter     := 0;
        v_data_read            := (others=> -1);

      ------------------------------------
      elsif(rising_edge(clk)) then
        if(not endfile(test_vector)) then
            v_data_row_counter := v_data_row_counter + 1;
            readline(test_vector,row);

            for kk in 1 to NUM_COL loop
                read(row,v_data_read(kk));
            end loop; 
            value1_std_logic_8_bit    <= std_logic_vector(to_unsigned(v_data_read(1), 8));
            value2_std_logic_8_bit    <= std_logic_vector(to_unsigned(v_data_read(2), 8));
        end if;
      end if;
    end process p_read;

end architecture;