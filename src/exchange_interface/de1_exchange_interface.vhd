library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

use work.axi_lite_intf.all;
use work.can_core_intf.all;
use work.peripheral_intf.all;
use work.baud_intf.all;
use work.olo_base_pkg_math.all;

entity de1_exchange_interface is
    generic (
        memory_depth_g          : positive := 10;
        width_g                 : positive;
        offset_g                : std_logic_vector(20 downto 0)
    );
    port (
        clk                     : in    std_logic;
        rst_n                   : in    std_logic;
        
        axi_intf_o              : out   axi_lite_input_intf_t;
        axi_intf_i              : in    axi_lite_output_intf_t;

        can_frame_i             : in    can_core_out_intf_t;
        can_frame_valid_i       : in    std_logic;

        baud_config_o           : out   baud_intf_t;

        driver_reset_o          : out   std_logic
    );
end de1_exchange_interface;

architecture rtl of de1_exchange_interface is

    

    signal frame_missed_s       : std_logic;
    signal fifo_out_ready_s     : std_logic;
    signal fifo_in_valid_s      : std_logic;
    signal fifo_in_ready_s      : std_logic;
    signal fifo_out_valid_s     : std_logic;
    signal fifo_out_data_s      : std_logic_vector(255 downto 0);

    signal can_frame_vec_s      : can_core_vector_t;
    signal peripheral_status_s  : per_intf_t;

    signal load_new_s           : std_logic;

    signal buffer_usage_s       : std_logic_vector(log2ceil(memory_depth_g + 1) - 1 downto 0);

    signal driver_reset_s       : std_logic;
    signal comb_rst_s           : std_logic;
    signal comb_rst_h           : std_logic;

begin

    comb_rst_s                  <= rst_n and (not driver_reset_s);
    comb_rst_h                  <= not comb_rst_s;
    driver_reset_o              <= driver_reset_s;

    -- FIFO INPUT CNTR
    fifo_input_cntr_i0 : entity work.fifo_input_cntr 
        port map(
            clk                 => clk,
            rst_n               => comb_rst_s,

            frame_valid_i       => can_frame_valid_i,
            fifo_ready_i        => fifo_in_ready_s,
            frame_valid_o       => fifo_in_valid_s,

            frame_missed_o      => frame_missed_s
        );

	-- FIFO
	fifo_i0 : entity work.olo_base_fifo_sync
		generic map(
			Width_g		        => 256,
			Depth_g		        => memory_depth_g
		)

		port map(
			Clk 		        => clk,
			Rst			        => comb_rst_h,

			In_Data		        => to_can_core_vector(can_frame_i),
			In_Valid	        => fifo_in_valid_s,
			In_Ready            => fifo_in_ready_s,

			Out_Data            => fifo_out_data_s,
			Out_Valid       	=> fifo_out_valid_s,
			Out_Ready	        => fifo_out_ready_s
		);

    can_frame_vec_s <= can_core_vector_t(fifo_out_data_s);

    per_status_cntr_i0 : entity work.per_status_cntr 
        generic map(
            memory_depth_g      => memory_depth_g
        )
        port map(
            clk                 => clk,
            rst_n               => comb_rst_s,

            per_status_o        => peripheral_status_s,

            buffer_usage_i      => buffer_usage_s,
            frame_missed_i      => frame_missed_s,

            clr_i               => driver_reset_s
        );

    buffer_usage_cntr_i0 : entity work.buffer_usage_cntr
        generic map(
            memory_depth_g      => memory_depth_g
        )
        port map(
            clk                 => clk,
            rst_n               => comb_rst_s,

            inc_i               => can_frame_valid_i,

            dec_i               => load_new_s,

            cnt_o               => buffer_usage_s,

            clr_i               => driver_reset_s
        );

    axi_reg_i0 : entity work.axi_reg
        generic map(
            width_g                 => width_g,
            offset_g                => offset_g
        )
        port map(
            clk                     => clk,
            rst_n                   => rst_n,

            axi_intf_i              => axi_intf_i,
            axi_intf_o              => axi_intf_o,

            can_frame_i             => to_can_core_intf(can_frame_vec_s),
            peripheral_status_i     => peripheral_status_s,

            ready_o                 => fifo_out_ready_s,
            valid_i                 => fifo_out_valid_s,

            load_new_o              => load_new_s,

            baud_config_o           => baud_config_o,

            driver_reset_o          => driver_reset_s
        );

end rtl;

