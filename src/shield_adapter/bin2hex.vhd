library ieee;
use ieee.std_logic_1164.all;

entity bin2hex is
    port(
        bin_i               : in    std_logic_vector(3 downto 0);
        hex_o               : out   std_logic_vector(6 downto 0)
    );
end entity bin2hex;

architecture rtl of bin2hex is

begin

    with bin_i select 
						 --gfedcba
        hex_o   <= 
                    "1111001" when "0001",
                    "0100100" when "0010",
                    "0110000" when "0011",
                    "0011001" when "0100",
                    "0010010" when "0101",
                    "0000010" when "0110",
						  
                    "1111000" when "0111",
						  
                    "0000000" when "1000",
						  
                    "0010000" when "1001",
						  
                    "0001000" when "1010", --A
						  
                    "0100111" when "1100", --C
						  
                    "0100001" when "1101", --D
						  
                    "0000110" when "1110", --E
						  
                    "0000011" when "1011", --B
						  
                    "0001110" when "1111", --F
                    "1111111" when others;

end rtl ;