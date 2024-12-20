library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.olo_base_pkg_math.all;

entity timestamp_sampler is
    generic (
        timer_width_g   : positive := 64
    );
    port (
        clk             : in    std_logic;
        rst_n           : in    std_logic;

        cnt_i           : in    std_logic_vector(timer_width_g - 1 downto 0);
        sample_i        : in    std_logic;

        cnt_o           : out   std_logic_vector(timer_width_g - 1 downto 0)
    );
end timestamp_sampler;

architecture rtl of timestamp_sampler is

    signal cnt_s        : std_logic_vector(timer_width_g - 1 downto 0);

begin

    cnt_o               <= cnt_s;

    sample_p : process(clk) 
    begin 
        if rising_edge(clk) then
            cnt_s       <= cnt_s;

            if sample_i = '1' then
                cnt_s   <= cnt_i;
            end if;

            if rst_n = '0' then
                cnt_s   <= (others => '0');
            end if;
        end if;
    end process sample_p;

end rtl;