DE1_SoC_QSYS_TCL = de1_soc_qsys.tcl

de1_soc.qsys: $(DE1_SoC_QSYS_TCL)
	qsys-script --script=$(DE1_SoC_QSYS_TCL)

.PHONY: qip
qip: de1_soc/synthesis/de1_soc.qip

de1_soc/synthesis/de1_soc.qip: de1_soc.qsys
	qsys-generate de1_soc.qsys --synthesis=VHDL

clean:
	rm -rf output_files db de1_soc
	rm -rf c5_pin_model_dump.txt de1_soc hps_isw_handoff hps_sdram_*
	rm -rf incremental_db
	rm -rf *.qpf *.qsf *.qws *.sopcinfo *.qsys
