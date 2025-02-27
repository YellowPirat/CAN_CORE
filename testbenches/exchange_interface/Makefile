# Variablen
OLO_BASE_SRC_DIR := ../../extern/olo/src/base  # Verzeichnis für die Basis-VHDL-Dateien
PROJECT_NAME := t_exchange_interface

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
    ../../src/interfaces/per_intf.vhd \
    ../../src/interfaces/can_core_intf.vhd \
    ../../src/interfaces/axi_lite_intf.vhd \
    ../../src/frame_generator/frame_cnt.vhd \
    ../../src/frame_generator/en_gen.vhd \
    ../../src/frame_generator/frames.vhd \
    ../../src/frame_generator/bench_finisher.vhd \
    ../../src/frame_generator/de1_frame_gen.vhd \
    ../../src/exchange_interface/axi_addr_cntr.vhd \
    ../../src/exchange_interface/axi_fifo_cntr.vhd \
    ../../src/exchange_interface/axi_reg.vhd \
    ../../src/exchange_interface/fifo_input_cntr.vhd \
    ../../src/exchange_interface/per_status_cntr.vhd \
    ../../src/exchange_interface/de1_exchange_interface.vhd \
    ../../src/core/de1_core.vhd \
    t_hps_engine.vhd \
	t_exchange_interface.vhd


# Ziel: Analyse der Basis VHDL-Dateien
ghdlinit: analyze

# Ziel: VHDL-Dateien mit GHDL analysieren
analyze:
	@echo "Analysiere Basis VHDL-Dateien..."
	@for file in $(SRC_FILES); do \
		echo "Analysiere $$file..."; \
		ghdl -a "$$file"; \
	done

# Elaborate step
elaborate: analyze
	@echo "Elaboriere das Design..."
	ghdl -e $(PROJECT_NAME)

# Run simulation
run: elaborate
	@echo "Starte Simulation..."
	ghdl -r $(PROJECT_NAME) --wave=output.ghw

# Combine all in one target: sim
sim: run
	@echo "Simulation erfolgreich abgeschlossen!"

# Ziel: Bereinigen
clean:
	@echo "Bereinige GHDL-Artefakte..."
	@rm -f *.o *.cf *.ghw *.vcd