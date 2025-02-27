project_new -overwrite -family CYCLONEV -part 5CSEMA5F31C6 exchange_interface

set_global_assignment -name TOP_LEVEL_ENTITY yellowPirat
set_global_assignment -name QIP_FILE ../../project_files/de1_soc/synthesis/de1_soc.qip

set_global_assignment -name VHDL_FILE ../../extern/olo/src/base/vhdl/olo_base_pkg_array.vhd 
set_global_assignment -name VHDL_FILE ../../extern/olo/src/base/vhdl/olo_base_pkg_math.vhd 
set_global_assignment -name VHDL_FILE ../../extern/olo/src/base/vhdl/olo_base_pkg_logic.vhd 
set_global_assignment -name VHDL_FILE ../../extern/olo/src/base/vhdl/olo_base_cc_bits.vhd 
set_global_assignment -name VHDL_FILE ../../extern/olo/src/base/vhdl/olo_base_cc_reset.vhd 
set_global_assignment -name VHDL_FILE ../../extern/olo/src/base/vhdl/olo_base_cc_n2xn.vhd 
set_global_assignment -name VHDL_FILE ../../extern/olo/src/base/vhdl/olo_base_arb_prio.vhd 
set_global_assignment -name VHDL_FILE ../../extern/olo/src/base/vhdl/olo_base_arb_rr.vhd 
set_global_assignment -name VHDL_FILE ../../extern/olo/src/base/vhdl/olo_base_cc_pulse.vhd 
set_global_assignment -name VHDL_FILE ../../extern/olo/src/base/vhdl/olo_base_cc_simple.vhd 
set_global_assignment -name VHDL_FILE ../../extern/olo/src/base/vhdl/olo_base_ram_sdp.vhd 
set_global_assignment -name VHDL_FILE ../../extern/olo/src/base/vhdl/olo_base_delay_cfg.vhd 
set_global_assignment -name VHDL_FILE ../../extern/olo/src/base/vhdl/olo_base_decode_firstbit.vhd 
set_global_assignment -name VHDL_FILE ../../extern/olo/src/base/vhdl/olo_base_ram_tdp.vhd 
set_global_assignment -name VHDL_FILE ../../extern/olo/src/base/vhdl/olo_base_strobe_gen.vhd 
set_global_assignment -name VHDL_FILE ../../extern/olo/src/base/vhdl/olo_base_wconv_n2xn.vhd 
set_global_assignment -name VHDL_FILE ../../extern/olo/src/base/vhdl/olo_base_fifo_async.vhd 
set_global_assignment -name VHDL_FILE ../../extern/olo/src/base/vhdl/olo_base_delay.vhd 
set_global_assignment -name VHDL_FILE ../../extern/olo/src/base/vhdl/olo_base_prbs.vhd 
set_global_assignment -name VHDL_FILE ../../extern/olo/src/base/vhdl/olo_base_tdm_mux.vhd 
set_global_assignment -name VHDL_FILE ../../extern/olo/src/base/vhdl/olo_base_cc_handshake.vhd 
set_global_assignment -name VHDL_FILE ../../extern/olo/src/base/vhdl/olo_base_fifo_sync.vhd 
set_global_assignment -name VHDL_FILE ../../extern/olo/src/base/vhdl/olo_base_flowctrl_handler.vhd 
set_global_assignment -name VHDL_FILE ../../extern/olo/src/base/vhdl/olo_base_dyn_sft.vhd 
set_global_assignment -name VHDL_FILE ../../extern/olo/src/base/vhdl/olo_base_strobe_div.vhd 
set_global_assignment -name VHDL_FILE ../../extern/olo/src/base/vhdl/olo_base_ram_sp.vhd 
set_global_assignment -name VHDL_FILE ../../extern/olo/src/base/vhdl/olo_base_cam.vhd 
set_global_assignment -name VHDL_FILE ../../extern/olo/src/base/vhdl/olo_base_cc_status.vhd 
set_global_assignment -name VHDL_FILE ../../extern/olo/src/base/vhdl/olo_base_reset_gen.vhd 
set_global_assignment -name VHDL_FILE ../../extern/olo/src/base/vhdl/olo_base_wconv_xn2n.vhd 
set_global_assignment -name VHDL_FILE ../../extern/olo/src/base/vhdl/olo_base_fifo_packet.vhd 
set_global_assignment -name VHDL_FILE ../../extern/olo/src/base/vhdl/olo_base_pl_stage.vhd 
set_global_assignment -name VHDL_FILE ../../extern/olo/src/base/vhdl/olo_base_cc_xn2n.vhd 
set_global_assignment -name VHDL_FILE ../../extern/olo/src/axi/vhdl/olo_axi_pkg_protocol.vhd 
set_global_assignment -name VHDL_FILE ../../extern/olo/src/axi/vhdl/olo_axi_master_simple.vhd 
set_global_assignment -name VHDL_FILE ../../extern/olo/src/axi/vhdl/olo_axi_pl_stage.vhd 
set_global_assignment -name VHDL_FILE ../../extern/olo/src/axi/vhdl/olo_axi_master_full.vhd 
set_global_assignment -name VHDL_FILE ../../extern/olo/src/axi/vhdl/olo_axi_lite_slave.vhd
set_global_assignment -name VHDL_FILE ../../extern/olo/src/intf/vhdl/olo_intf_sync.vhd
set_global_assignment -name VHDL_FILE ../../extern/olo/src/intf/vhdl/olo_intf_uart.vhd

set_global_assignment -name VHDL_FILE ../../src/shield_adapter/shield_adapter.vhd
set_global_assignment -name VHDL_FILE ../../src/exchange_interface/axi_shit_cntr.vhd

set_global_assignment -name VHDL_FILE ../../src/interfaces/per_intf.vhd
set_global_assignment -name VHDL_FILE ../../src/interfaces/can_core_intf.vhd
set_global_assignment -name VHDL_FILE ../../src/interfaces/axi_lite_intf.vhd

#CAN_CORE

 set_global_assignment -name VHDL_FILE ../../src/interfaces/per_intf.vhd
 set_global_assignment -name VHDL_FILE ../../src/interfaces/can_core_intf.vhd
 set_global_assignment -name VHDL_FILE ../../src/interfaces/axi_lite_intf.vhd
 set_global_assignment -name VHDL_FILE ../../src/interfaces/baud_intf.vhd
 set_global_assignment -name VHDL_FILE ../../src/can_core/idle_detect/idle_detect.vhd
 set_global_assignment -name VHDL_FILE ../../src/can_core/destuffing/destuffing_logic.vhd
 set_global_assignment -name VHDL_FILE ../../src/can_core/destuffing/destuffing_cntr.vhd
 set_global_assignment -name VHDL_FILE ../../src/can_core/destuffing/last_bit.vhd
 set_global_assignment -name VHDL_FILE ../../src/can_core/destuffing/de1_destuffing.vhd
 set_global_assignment -name VHDL_FILE ../../src/can_core/sampling/sample_edge_detect.vhd
 set_global_assignment -name VHDL_FILE ../../src/can_core/sampling/resync_cntr.vhd
 set_global_assignment -name VHDL_FILE ../../src/can_core/sampling/sample_validator.vhd
 set_global_assignment -name VHDL_FILE ../../src/can_core/sampling/edge_detect.vhd
 set_global_assignment -name VHDL_FILE ../../src/can_core/sampling/quantum_prescaler.vhd
 set_global_assignment -name VHDL_FILE ../../src/can_core/sampling/seq_cnt.vhd
 set_global_assignment -name VHDL_FILE ../../src/can_core/sampling/sample_cntr.vhd
 set_global_assignment -name VHDL_FILE ../../src/can_core/sampling/sample.vhd
 set_global_assignment -name VHDL_FILE ../../src/can_core/sampling/de1_sampling.vhd
 set_global_assignment -name VHDL_FILE ../../src/can_core/input_stream/frame_detect.vhd
 set_global_assignment -name VHDL_FILE ../../src/can_core/input_stream/uni_dec_cnt.vhd
 set_global_assignment -name VHDL_FILE ../../src/can_core/input_stream/uni_reg.vhd
 set_global_assignment -name VHDL_FILE ../../src/can_core/input_stream/field_reg.vhd
 set_global_assignment -name VHDL_FILE ../../src/can_core/input_stream/valid_cntr.vhd
 set_global_assignment -name VHDL_FILE ../../src/can_core/input_stream/bit_reg.vhd
 set_global_assignment -name VHDL_FILE ../../src/can_core/input_stream/id_mapping.vhd
 set_global_assignment -name VHDL_FILE ../../src/can_core/input_stream/socketcan_mapper.vhd
 set_global_assignment -name VHDL_FILE ../../src/can_core/input_stream/de1_input_stream.vhd
 set_global_assignment -name VHDL_FILE ../../src/can_core/error_handling/ef_detect.vhd
 set_global_assignment -name VHDL_FILE ../../src/can_core/error_handling/ef_cntr.vhd
 set_global_assignment -name VHDL_FILE ../../src/can_core/error_handling/error_handling_cntr.vhd
 set_global_assignment -name VHDL_FILE ../../src/can_core/error_handling/de1_error_handling.vhd
 set_global_assignment -name VHDL_FILE ../../src/can_core/crc/crc_calculation.vhd
 set_global_assignment -name VHDL_FILE ../../src/can_core/crc/crc_state_machine.vhd
 set_global_assignment -name VHDL_FILE ../../src/can_core/crc/de1_crc.vhd
 set_global_assignment -name VHDL_FILE ../../src/can_core/frame_valid/frame_valid_cntr.vhd
 set_global_assignment -name VHDL_FILE ../../src/can_core/frame_valid/de1_frame_valid.vhd
 set_global_assignment -name VHDL_FILE ../../src/can_core/timestamp/timestamp_sampler.vhd
 set_global_assignment -name VHDL_FILE ../../src/can_core/timestamp/uni_cnt.vhd
 set_global_assignment -name VHDL_FILE ../../src/can_core/timestamp/de1_timestamp.vhd
 set_global_assignment -name VHDL_FILE ../../src/can_core/warm_start/warm_start.vhd
 set_global_assignment -name VHDL_FILE ../../src/can_core/warm_start/de1_warm_start.vhd
 set_global_assignment -name VHDL_FILE ../../src/can_core/de1_can_core.vhd
 set_global_assignment -name VHDL_FILE ../../src/exchange_interface/valid_edge_det.vhd
 set_global_assignment -name VHDL_FILE ../../src/exchange_interface/buffer_usage_cnt.vhd
 set_global_assignment -name VHDL_FILE ../../src/exchange_interface/buffer_usage_cntr.vhd
 set_global_assignment -name VHDL_FILE ../../src/exchange_interface/axi_addr_cntr.vhd
 set_global_assignment -name VHDL_FILE ../../src/exchange_interface/axi_fifo_cntr.vhd
 set_global_assignment -name VHDL_FILE ../../src/exchange_interface/axi_reg.vhd
 set_global_assignment -name VHDL_FILE ../../src/exchange_interface/fifo_input_cntr.vhd
 set_global_assignment -name VHDL_FILE ../../src/exchange_interface/per_status_cntr.vhd
 set_global_assignment -name VHDL_FILE ../../src/exchange_interface/de1_exchange_interface.vhd
 set_global_assignment -name VHDL_FILE ../../src/axi_interconnect/axi_smmm.vhd
 set_global_assignment -name VHDL_FILE ../../src/debug/splice_cnt.vhd
 set_global_assignment -name VHDL_FILE ../../src/debug/uart_cntr.vhd
 set_global_assignment -name VHDL_FILE ../../src/debug/splicer.vhd
 set_global_assignment -name VHDL_FILE ../../src/debug/asci_mapper.vhd
 set_global_assignment -name VHDL_FILE ../../src/debug/de1_debug.vhd
 set_global_assignment -name VHDL_FILE ../../src/core/de1_core.vhd

set_global_assignment -name VHDL_FILE ../../src/yellowPirat/yellowPirat.vhd

set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
set_global_assignment -name EDA_SIMULATION_TOOL "<None>"
set_global_assignment -name EDA_OUTPUT_DATA_FORMAT NONE -section_id eda_simulation
set_global_assignment -name SDC_FILE de1_soc_top.sdc

# enabling signaltap 
#set_global_assignment -name ENABLE_SIGNALTAP ON
#set_global_assignment -name USE_SIGNALTAP_FILE cti_tapping.stp
#set_global_assignment -name SIGNALTAP_FILE cti_tapping.stp

source ../../project_files/pin_assignment_de1_soc_top.tcl

project_close
