project_new -overwrite -family CYCLONEV -part 5CSEMA5F31C6 exchange_interface

set_global_assignment -name TOP_LEVEL_ENTITY de1_exchange_interface_base
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
set_global_assignment -name VHDL_FILE ../../src/shield_adapter/shield_adapter.vhd

set_global_assignment -name VHDL_FILE ../../src/exchange_interface/can_core_intf.vhd
set_global_assignment -name VHDL_FILE ../../src/exchange_interface/axi_lite_intf.vhd
set_global_assignment -name VHDL_FILE ../../src/exchange_interface/axi_fifo_cntr.vhd
set_global_assignment -name VHDL_FILE ../../src/exchange_interface/axi_addr_cntr.vhd
set_global_assignment -name VHDL_FILE ../../src/exchange_interface/axireg.vhd
set_global_assignment -name VHDL_FILE ../../src/exchange_interface/exchange_testbench.vhd
set_global_assignment -name VHDL_FILE ../../src/exchange_interface/axi_interconnect.vhd
set_global_assignment -name VHDL_FILE ../../src/exchange_interface/de1_exchange_interface.vhd
set_global_assignment -name VHDL_FILE ../../src/exchange_interface/axi_shit_cntr.vhd

set_global_assignment -name VHDL_FILE de1_exchange_interface_base.vhd

set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
set_global_assignment -name EDA_SIMULATION_TOOL "<None>"
set_global_assignment -name EDA_OUTPUT_DATA_FORMAT NONE -section_id eda_simulation
set_global_assignment -name SDC_FILE exchange_interface.sdc

# enabling signaltap 
#set_global_assignment -name ENABLE_SIGNALTAP ON
#set_global_assignment -name USE_SIGNALTAP_FILE cti_tapping.stp
#set_global_assignment -name SIGNALTAP_FILE cti_tapping.stp

source ../../project_files/pin_assignment_de1_soc_top.tcl

project_close
