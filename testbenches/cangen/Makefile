# Variablen
OLO_BASE_SRC_DIR := ../../extern/olo/src/base  # Verzeichnis für die Basis-VHDL-Dateien
PROJECT_NAME := cangen

# Manuelle Auflistung der VHDL-Dateien ohne Zeilenfortsetzung
SRC_FILES = \
	t_cangen.vhd


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