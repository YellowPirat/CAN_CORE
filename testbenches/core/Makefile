# Variablen
OLO_BASE_SRC_DIR := ../../extern/olo/src/base  # Verzeichnis für die Basis-VHDL-Dateien
PROJECT_NAME := t_core

# Manuelle Auflistung der VHDL-Dateien ohne Zeilenfortsetzung
SRC_FILES = \
    ../../extern/olo/src/base/vhdl/olo_base_pkg_array.vhd \
    ../../extern/olo/src/base/vhdl/olo_base_pkg_math.vhd \
    ../../extern/olo/src/base/vhdl/olo_base_pkg_logic.vhd \
    ../../extern/olo/src/base/vhdl/olo_base_cc_bits.vhd \
    ../../extern/olo/src/base/vhdl/olo_base_cc_reset.vhd \
    ../../extern/olo/src/base/vhdl/olo_base_cc_n2xn.vhd \
    ../../extern/olo/src/base/vhdl/olo_base_arb_prio.vhd \
    ../../extern/olo/src/base/vhdl/olo_base_arb_rr.vhd \
	../../extern/olo/src/base/vhdl/olo_base_cc_pulse.vhd \
    ../../extern/olo/src/base/vhdl/olo_base_cc_simple.vhd \
    ../../extern/olo/src/base/vhdl/olo_base_ram_sdp.vhd \
    ../../extern/olo/src/base/vhdl/olo_base_delay_cfg.vhd \
    ../../extern/olo/src/base/vhdl/olo_base_decode_firstbit.vhd \
    ../../extern/olo/src/base/vhdl/olo_base_ram_tdp.vhd \
    ../../extern/olo/src/base/vhdl/olo_base_strobe_gen.vhd \
    ../../extern/olo/src/base/vhdl/olo_base_wconv_n2xn.vhd \
    ../../extern/olo/src/base/vhdl/olo_base_fifo_async.vhd \
    ../../extern/olo/src/base/vhdl/olo_base_delay.vhd \
    ../../extern/olo/src/base/vhdl/olo_base_prbs.vhd \
    ../../extern/olo/src/base/vhdl/olo_base_tdm_mux.vhd \
    ../../extern/olo/src/base/vhdl/olo_base_cc_handshake.vhd \
    ../../extern/olo/src/base/vhdl/olo_base_fifo_sync.vhd \
    ../../extern/olo/src/base/vhdl/olo_base_flowctrl_handler.vhd \
    ../../extern/olo/src/base/vhdl/olo_base_dyn_sft.vhd \
    ../../extern/olo/src/base/vhdl/olo_base_strobe_div.vhd \
    ../../extern/olo/src/base/vhdl/olo_base_ram_sp.vhd \
    ../../extern/olo/src/base/vhdl/olo_base_cam.vhd \
    ../../extern/olo/src/base/vhdl/olo_base_cc_status.vhd \
    ../../extern/olo/src/base/vhdl/olo_base_reset_gen.vhd \
    ../../extern/olo/src/base/vhdl/olo_base_wconv_xn2n.vhd \
    ../../extern/olo/src/base/vhdl/olo_base_fifo_packet.vhd \
    ../../extern/olo/src/base/vhdl/olo_base_pl_stage.vhd \
    ../../extern/olo/src/base/vhdl/olo_base_cc_xn2n.vhd \
	../../extern/olo/src/axi/vhdl/olo_axi_pkg_protocol.vhd \
	../../extern/olo/src/axi/vhdl/olo_axi_master_simple.vhd \
	../../extern/olo/src/axi/vhdl/olo_axi_pl_stage.vhd \
	../../extern/olo/src/axi/vhdl/olo_axi_master_full.vhd \
	../../extern/olo/src/axi/vhdl/olo_axi_lite_slave.vhd \
	../../extern/olo/src/intf/vhdl/olo_intf_sync.vhd \
    ../../extern/olo/src/intf/vhdl/olo_intf_uart.vhd \
    ../../src/interfaces/per_intf.vhd \
    ../../src/interfaces/can_core_intf.vhd \
    ../../src/interfaces/axi_lite_intf.vhd \
    ../../src/sampling/sample_edge_detect.vhd \
    ../../src/sampling/resync_cntr.vhd \
    ../../src/sampling/sample_validator.vhd \
	../../src/sampling/edge_detect.vhd \
    ../../src/sampling/idle_detect.vhd \
    ../../src/sampling/destuffing_logic.vhd \
    ../../src/sampling/last_bit.vhd \
    ../../src/sampling/destuffing_cntr.vhd \
    ../../src/sampling/destuffing.vhd \
    ../../src/sampling/quantum_prescaler.vhd \
    ../../src/sampling/seq_cnt.vhd \
    ../../src/sampling/sample_cntr.vhd \
    ../../src/sampling/sample.vhd \
	../../src/sampling/de1_sampling.vhd \
    ../../src/input_stream/frame_detect.vhd \
    ../../src/input_stream/uni_dec_cnt.vhd \
    ../../src/input_stream/uni_reg.vhd \
    ../../src/input_stream/field_reg.vhd \
    ../../src/input_stream/valid_cntr.vhd \
    ../../src/input_stream/bit_reg.vhd \
    ../../src/input_stream/id_mapping.vhd \
    ../../src/input_stream/socketcan_mapper.vhd \
    ../../src/input_stream/de1_input_stream.vhd \
    ../../src/debug/splice_cnt.vhd \
    ../../src/debug/uart_cntr.vhd \
    ../../src/debug/splicer.vhd \
    ../../src/debug/asci_mapper.vhd \
    ../../src/debug/de1_debug.vhd \
    ../../src/error_handling/ef_detect.vhd \
    ../../src/error_handling/ef_cntr.vhd \
    ../../src/error_handling/error_handling_cntr.vhd \
    ../../src/error_handling/de1_error_handling.vhd \
    ../../src/crc/de1_crc.vhd \
    ../../src/frame_valid/frame_valid_cntr.vhd \
    ../../src/frame_valid/de1_frame_valid.vhd \
    ../../src/timestamp/timestamp_sampler.vhd \
    ../../src/timestamp/uni_cnt.vhd \
    ../../src/timestamp/de1_timestamp.vhd \
    ../../src/warm_start/warm_start.vhd \
    ../../src/warm_start/de1_warm_start.vhd \
    ../../src/can_core/de1_can_core.vhd \
    ../../src/exchange_interface/valid_edge_det.vhd \
    ../../src/exchange_interface/buffer_usage_cnt.vhd \
    ../../src/exchange_interface/buffer_usage_cntr.vhd \
    ../../src/exchange_interface/axi_addr_cntr.vhd \
    ../../src/exchange_interface/axi_fifo_cntr.vhd \
    ../../src/exchange_interface/axi_reg.vhd \
    ../../src/exchange_interface/fifo_input_cntr.vhd \
    ../../src/exchange_interface/per_status_cntr.vhd \
    ../../src/exchange_interface/de1_exchange_interface.vhd \
    ../../src/axi_interconnect/axi_smmm.vhd \
    ../../src/core/de1_core.vhd \
	../cangen/t_cangen.vhd \
	../exchange_interface/t_hps_engine.vhd \
    t_core.vhd



# Ziel: Analyse der Basis VHDL-Dateien
ghdlinit: analyze

# Ziel: VHDL-Dateien mit GHDL analysieren
analyze:
	@echo "Analysiere Basis VHDL-Dateien..."
	@for file in $(SRC_FILES); do \
		echo "Analysiere $$file..."; \
		ghdl -a -fsynopsys "$$file"; \
	done

# Elaborate step
elaborate: analyze
	@echo "Elaboriere das Design..."
	ghdl -e -fsynopsys $(PROJECT_NAME)

# Run simulation
run: elaborate
	@echo "Starte Simulation..."
	ghdl -r -fsynopsys $(PROJECT_NAME) --wave=output.ghw

# Combine all in one target: sim
sim: run
	@echo "Simulation erfolgreich abgeschlossen!"

# Ziel: Bereinigen
clean:
	@echo "Bereinige GHDL-Artefakte..."
	@rm -f *.o *.cf *.ghw *.vcd