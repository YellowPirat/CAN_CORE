PROJECT_NAME = exchange_interface
# SET TO NOHPS if no HPS Core in the project
QSIS_LOCATION = ../../project_files


.PHONY: qpf

# Setze die Abhängigkeit von qpf auf $(PROJECT_NAME).qpf
qpf: $(PROJECT_NAME).qpf

# Bedingte Definition für $(PROJECT_NAME).qpf
ifneq ($(QSIS_LOCATION),NOHPS)
$(PROJECT_NAME).qpf: $(QSIS_LOCATION)/de1_soc/synthesis/de1_soc.qip create_quartus.tcl
	quartus_sh --script=create_quartus.tcl || rm -f $(PROJECT_NAME).qpf
else
$(PROJECT_NAME).qpf: create_quartus.tcl
	quartus_sh --script=create_quartus.tcl || rm -f $(PROJECT_NAME).qpf
endif

# Nachfolgende Abhängigkeiten
output_files/$(PROJECT_NAME).map.summary: $(PROJECT_NAME).qpf
	quartus_map $(PROJECT_NAME).qpf || rm -f output_files/$(PROJECT_NAME).map.summary

output_files/$(PROJECT_NAME).merge.summary: output_files/$(PROJECT_NAME).map.summary
	quartus_cdb --merge $(PROJECT_NAME).qpf || rm -f output_files/$(PROJECT_NAME).merge.summary




ifneq ($(QSIS_LOCATION),NOHPS)
compile: output_files/$(PROJECT_NAME).merge.summary
	quartus_sta -t $(QSIS_LOCATION)/de1_soc/synthesis/submodules/hps_sdram_p0_pin_assignments.tcl $(PROJECT_NAME).qpf
	quartus_stp $(PROJECT_NAME)
	quartus_sh --flow compile $(PROJECT_NAME).qpf
else
compile: output_files/$(PROJECT_NAME).merge.summary
	quartus_sta -t $(PROJECT_NAME).qpf
	quartus_stp $(PROJECT_NAME)
	quartus_sh --flow compile $(PROJECT_NAME).qpf
endif

.PHONY: rbf
rbf: output_files/$(PROJECT_NAME).rbf

output_files/$(PROJECT_NAME).rbf: output_files/$(PROJECT_NAME).sof
	quartus_cpf -c output_files/$(PROJECT_NAME).sof ../../linux/yellowPirat.rbf



clean:
	rm -rf output_files db de1_soc
	rm -rf c5_pin_model_dump.txt de1_soc hps_isw_handoff hps_sdram_*
	rm -rf incremental_db
	rm -rf *.qpf *.qsf *.qws *.sopcinfo *.qsys