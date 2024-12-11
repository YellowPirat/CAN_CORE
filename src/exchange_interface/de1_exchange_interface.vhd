library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

use work.axi_lite_intf.all;
use work.can_core_intf.all;
use work.peripheral_intf.all;

entity de1_exchange_interface is
    port (
        clk                     : in    std_logic;
        rst_n                   : in    std_logic;
        
        axi_intf_o              : out   axi_lite_input_intf_t;
        axi_intf_i              : in    axi_lite_output_intf_t;

        can_frame_i             : in    can_core_out_intf_t;
        can_frame_valid_i       : in    std_logic;

        peripheral_status_i     : in    per_intf_t
    );
end de1_exchange_interface;

architecture rtl of de1_exchange_interface is

    signal rst_h                : std_logic;

    signal frame_missed_s       : std_logic;
    signal fifo_out_ready_s     : std_logic;
    signal fifo_in_valid_s      : std_logic;
    signal fifo_in_ready_s      : std_logic;
    signal fifo_out_valid_s     : std_logic;
    signal fifo_out_data_s     : std_logic_vector(191 downto 0);

begin

    rst_h           <= not rst_n;

    -- FIFO INPUT CNTR
    fifo_input_cntr_i0 : entity work.fifo_input_cntr 
        port map(
            clk                 => clk,
            rst_n               => rst_n,

            frame_valid_i       => can_frame_valid_i,
            fifo_ready_i        => fifo_in_ready_s,
            frame_valid_o       => fifo_in_valid_s,

            frame_missed_o      => frame_missed_s
        );

	-- FIFO
	fifo_i0 : entity work.olo_base_fifo_sync
		generic map(
			Width_g		        => 192,
			Depth_g		        => 31
		)

		port map(
			Clk 		        => clk,
			Rst			        => rst_h,

			In_Data		        => to_can_core_vector(can_frame_i),
			In_Valid	        => fifo_in_valid_s,
			In_Ready            => fifo_in_ready_s,

			Out_Data            => fifo_out_data_s,
			Out_Valid       	=> fifo_out_valid_s,
			Out_Ready	        => fifo_out_ready_s
		);

    axi_reg_i0 : entity work.axi_reg
        port map(
            clk                     => clk,
            rst_n                   => rst_n,

            axi_intf_i              => axi_intf_i,
            axi_intf_o              => axi_intf_o,

            can_frame_i             => to_can_core_intf(fifo_out_data_s),
            peripheral_status_i     => peripheral_status_i,

            ready_o                 => fifo_out_valid_s,
            valid_i                 => fifo_out_ready_s
        );

end rtl;

