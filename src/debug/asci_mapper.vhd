library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.olo_base_pkg_math.all;

entity asci_mapper is
    port(
        data_i          : in    std_logic_vector(3 downto 0)                        := (others => '0');
        data_o          : out   std_logic_vector(7 downto 0)                        := (others => '0');
        lf_i            : in    std_logic                                           := '0';
        rl_i            : in    std_logic                                           := '0'
    );
end entity;

architecture rtl of asci_mapper is

    signal tmp          : std_logic_vector(7 downto 0)                              := (others => '0');
    signal eol_s        : std_logic_vector(7 downto 0)                              := (others => '0');

begin

    eol_s       <= "00001010" when lf_i = '1' else "00001101";

    data_o      <= eol_s when lf_i = '1' or rl_i = '1' else tmp;

    with data_i select
    tmp         <=  "00110000"  when "0000",
                    "00110001"  when "0001",
                    "00110010"  when "0010",
                    "00110011"  when "0011",
                    "00110100"  when "0100",
                    "00110101"  when "0101",
                    "00110110"  when "0110",
                    "00110111"  when "0111",
                    "00111000"  when "1000",
                    "00111001"  when "1001",
                    "01000001"  when "1010",
                    "01000010"  when "1011",
                    "01000011"  when "1100",
                    "01000100"  when "1101",
                    "01000101"  when "1110",
                    "01000110"  when "1111",
                    "00001010"  when others;


end rtl ; -- rtl