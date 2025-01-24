library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.peripheral_intf.all;
use work.olo_base_pkg_math.all;

entity per_status_cntr is
    generic (
        memory_depth_g              : natural := 10
    );
    port (
        clk                         : in    std_logic;
        rst_n                       : in    std_logic;

        per_status_o                : out   per_intf_t;

        buffer_usage_i              : in    std_logic_vector(log2ceil(memory_depth_g + 1) - 1 downto 0);
        frame_missed_i              : in    std_logic;

        clr_i                       : in    std_logic
    );
end entity;

architecture rtl of per_status_cntr is

    signal per_status_s             : per_intf_t;

begin

    per_status_o        <= per_status_s;

    p : process(clk) 
    begin
        if rising_edge(clk) then
            per_status_s.buffer_usage(log2ceil(memory_depth_g + 1) - 1 downto 0)    <= buffer_usage_i;
            per_status_s.buffer_usage(9 downto log2ceil(memory_depth_g + 1))        <= (others => '0');

            per_status_s.peripheral_error                                           <= (others => '0');

            if frame_missed_i = '1' then
                per_status_s.missed_frames                                          <= per_status_s.missed_frames + 1;
                if per_status_s.missed_frames = 8388608 then
                    per_status_s.missed_frames_overflow                             <= '1';
                end if;
            end if;
            
            if rst_n = '0' or clr_i = '1' then
                per_status_s.missed_frames                                          <= to_unsigned(0, per_status_s.missed_frames'length);
                per_status_s.missed_frames_overflow                                 <= '0';
            end if;
        end if;
    end process p;


end rtl;