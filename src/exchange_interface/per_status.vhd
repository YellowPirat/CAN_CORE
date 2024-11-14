library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.peripheral_intf.all;

entity per_status is
    port (
        clk                 : in    std_logic;
        rst_n               : in    std_logic;

        per_intf_o          : out   per_intf_t;

        buffer_usage_i      : in    std_logic_vector(9 downto 0);
        peripheral_error    : in    std_logic_vector(4 downto 0);
        per_active_i        : in    std_logic;
        can_valid_i         : in    std_logic;
        fifo_ready_i        : in    std_logic;
        bus_active_i        : in    std_logic
    );
end entity per_status;

architecture rtl of per_status is

    signal per_intf_s               : per_intf_t;

    signal cnt_missed_frame_s       : std_logic;

    signal missed_frames_s          : std_logic_vector(14 downto 0);

    signal overflow_s               : std_logic;

    signal missed_frame_overflow_s  : std_logic;

begin

    per_intf_o                          <= per_intf_s;

    per_intf_s.buffer_usage             <= buffer_usage_i;
    per_intf_s.peripheral_error         <= peripheral_error;
    per_intf_s.core_active              <= per_active_i;
    per_intf_s.missed_frames            <= missed_frames_s;
    per_intf_s.missed_frames_overflow   <= missed_frame_overflow_s;



    cntr_missed_frame_p : entity work.cntr_missed_frame
        port map(
            clk                     => clk,
            rst_n                   => rst_n,

            bus_active_i            => bus_active_i,
            can_valid_i             => can_valid_i,
            fifo_ready_i            => fifo_ready_i,

            cnt_missed_frame_o      => cnt_missed_frame_s
        );

    cnt_missed_frame_p : entity work.cnt_missed_frame
        port map(
            clk                     => clk,
            rst_n                   => rst_n,

            en_cnt_i                => cnt_missed_frame_s,

            cnt_o                   => missed_frames_s,
            overflow_o              => overflow_s
        );

    missed_frame_overflow_p : process(clk)
    begin
        if rising_edge(clk) then
            if overflow_s = '1' then
                missed_frame_overflow_s <= '1';
            end if;

            if rst_n = '0' then
                missed_frame_overflow_s <= '0';
            end if;
        end if;
    end process missed_frame_overflow_p;

    

end rtl;