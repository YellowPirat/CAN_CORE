project_new -overwrite -family CYCLONEV -part 5CSEMA5F31C6 sampling

set_global_assignment -name TOP_LEVEL_ENTITY de1_read

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

set_global_assignment -name VHDL_FILE ../../src/sampling/sample_edge_detect.vhd
set_global_assignment -name VHDL_FILE ../../src/sampling/resync_cntr.vhd
set_global_assignment -name VHDL_FILE ../../src/sampling/sample_validator.vhd
set_global_assignment -name VHDL_FILE ../../src/sampling/edge_detect.vhd
set_global_assignment -name VHDL_FILE ../../src/sampling/idle_detect.vhd
set_global_assignment -name VHDL_FILE ../../src/sampling/destuffing_logic.vhd
set_global_assignment -name VHDL_FILE ../../src/sampling/last_bit.vhd
set_global_assignment -name VHDL_FILE ../../src/sampling/destuffing_cntr.vhd
set_global_assignment -name VHDL_FILE ../../src/sampling/destuffing.vhd
set_global_assignment -name VHDL_FILE ../../src/sampling/quantum_prescaler.vhd
set_global_assignment -name VHDL_FILE ../../src/sampling/seq_cnt.vhd
set_global_assignment -name VHDL_FILE ../../src/sampling/sample_cntr.vhd
set_global_assignment -name VHDL_FILE ../../src/sampling/sample.vhd
set_global_assignment -name VHDL_FILE ../../src/sampling/de1_sampling.vhd


set_global_assignment -name VHDL_FILE ../../src/core/frame_detect.vhd
set_global_assignment -name VHDL_FILE ../../src/core/uni_dec_cnt.vhd
set_global_assignment -name VHDL_FILE ../../src/core/uni_reg.vhd
set_global_assignment -name VHDL_FILE ../../src/core/field_reg.vhd
set_global_assignment -name VHDL_FILE ../../src/core/valid_cntr.vhd
set_global_assignment -name VHDL_FILE ../../src/core/bit_reg.vhd
set_global_assignment -name VHDL_FILE ../../src/core/id_mapping.vhd
set_global_assignment -name VHDL_FILE ../../src/core/de1_core.vhd

set_global_assignment -name VHDL_FILE ../../src/shield_adapter/shield_adapter.vhd
set_global_assignment -name VHDL_FILE ../../src/shield_adapter/bin2hex.vhd

set_global_assignment -name VHDL_FILE ../../src/debug/splice_cnt.vhd
set_global_assignment -name VHDL_FILE ../../src/debug/uart_cntr.vhd
set_global_assignment -name VHDL_FILE ../../src/debug/splicer.vhd
set_global_assignment -name VHDL_FILE ../../src/debug/asci_mapper.vhd
set_global_assignment -name VHDL_FILE ../../src/debug/de1_debug.vhd

set_global_assignment -name VHDL_FILE ../../src/error_handling/error_handling_cntr.vhd
set_global_assignment -name VHDL_FILE ../../src/error_handling/eof_detect.vhd
set_global_assignment -name VHDL_FILE ../../src/error_handling/de1_error_handling.vhd

set_global_assignment -name VHDL_FILE de1_read.vhd



set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
set_global_assignment -name EDA_SIMULATION_TOOL "<None>"
set_global_assignment -name EDA_OUTPUT_DATA_FORMAT NONE -section_id eda_simulation
set_global_assignment -name SDC_FILE sampling.sdc

# enabling signaltap 
#set_global_assignment -name ENABLE_SIGNALTAP ON
#set_global_assignment -name USE_SIGNALTAP_FILE cti_tapping.stp
#set_global_assignment -name SIGNALTAP_FILE cti_tapping.stp

source ../../project_files/pin_assignment_de1_soc_small_top.tcl

project_close
