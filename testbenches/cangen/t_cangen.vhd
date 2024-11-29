library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
use std.textio.all;

entity cangen is
  port(
    rst_n     : in std_logic;
    rxd_o     : out std_logic;
    simstop   : in boolean := false
  );
end entity;

architecture sim of cangen is

    signal step : std_logic := '0';
    signal rxd : std_logic := '1';
    signal active_s : std_logic := '0';

    signal value1_std_logic_8_bit, value2_std_logic_8_bit: std_logic_vector(7 downto 0) := (others => '1');

    signal cnt_s  : unsigned(10 downto 0) := to_unsigned(0, 11);

begin




  step_p : process
  begin 
    step <= '0';
    wait for 24800 ps;
    step <= '1';
    wait for 24800 ps;
    cnt_s <= cnt_s + 1;
    if simstop then
      wait;
    end if;
  end process step_p; 

    p_read : process(rst_n,step)
    --------------------------------------------------------------------------------------------------
    constant NUM_COL                : integer := 1;   -- number of column of file
    type t_integer_array       is array(integer range <> )  of integer;
    file test_vector                : text open read_mode is "../cangen/deadaffe5000000.csv";
    variable row                    : line;
    variable v_data_read            : t_integer_array(1 to NUM_COL);
    variable v_data_row_counter     : integer := 0;
    variable v_data_str             : string(1 to 80);
    begin
      
      if(rst_n='0') then
        v_data_row_counter     := 0;
        v_data_read            := (others=> -1);

      ------------------------------------
      elsif(rising_edge(step)) then
        if(not endfile(test_vector)) then
            v_data_row_counter := v_data_row_counter + 1;
            readline(test_vector,row);

            for kk in 1 to NUM_COL loop
                read(row,v_data_read(kk));
            end loop; 

            value1_std_logic_8_bit    <= std_logic_vector(to_unsigned(v_data_read(1), 8));
            rxd <= value1_std_logic_8_bit(0);
            active_s <= '1';
        else
            active_s <= '0';
        end if;
          
      end if;
    end process p_read;

    rxd_o <= rxd;

end architecture;