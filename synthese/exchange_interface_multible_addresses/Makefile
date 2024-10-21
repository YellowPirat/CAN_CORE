DE1_SoC_QSYS_TCL = ../../project_files/de1_soc_qsys.tcl
PROJECT_NAME = exchange_interface


de1_soc.qsys: $(DE1_SoC_QSYS_TCL)
	qsys-script --script=$(DE1_SoC_QSYS_TCL)

.PHONY: qip
qip: de1_soc/synthesis/de1_soc.qip

de1_soc/synthesis/de1_soc.qip: de1_soc.qsys
	qsys-generate de1_soc.qsys --synthesis=VHDL



.PHONY: qpf
qpf: $(PROJECT_NAME).qpf

$(PROJECT_NAME).qpf: de1_soc/synthesis/de1_soc.qip create_quartus.tcl
	quartus_sh --script=create_quartus.tcl || rm $(PROJECT_NAME).qpf

output_files/$(PROJECT_NAME).map.summary: $(PROJECT_NAME).qpf
	quartus_map $(PROJECT_NAME).qpf	|| rm output_files/$(PROJECT_NAME).map.summary

output_files/$(PROJECT_NAME).merge.summary: output_files/$(PROJECT_NAME).map.summary
	quartus_cdb --merge $(PROJECT_NAME).qpf	|| rm output_files/$(PROJECT_NAME).merge.summary




compile: output_files/$(PROJECT_NAME).merge.summary
	#quartus_map d$(PROJECT_NAME).qpf
	#quartus_cdb --merge $(PROJECT_NAME).qpf
	quartus_sta -t de1_soc/synthesis/submodules/hps_sdram_p0_pin_assignments.tcl $(PROJECT_NAME).qpf
	quartus_stp $(PROJECT_NAME)
	quartus_sh --flow compile $(PROJECT_NAME).qpf


.PHONY: rbf
rbf: output_files/$(PROJECT_NAME).rbf

output_files/$(PROJECT_NAME).rbf: output_files/$(PROJECT_NAME).sof
	quartus_cpf -c output_files/$(PROJECT_NAME).sof output_files/$(PROJECT_NAME).rbf



clean:
	rm -rf output_files db de1_soc
	rm -rf c5_pin_model_dump.txt de1_soc hps_isw_handoff hps_sdram_*
	rm -rf incremental_db
	rm -rf *.qpf *.qsf *.qws *.sopcinfo *.qsys