#!/usr/bin/env python3

import os
import subprocess
from pathlib import Path
from dataclasses import dataclass
import shutil
from builder import Builder

@dataclass
class BootloaderConfig:
    git_repo: str
    git_branch: str
    hps_path: Path
    rbf_path: Path
    output_dir: Path

    def __post_init__(self):
        self.hps_path = Path(self.hps_path).absolute()
        self.rbf_path = Path(self.rbf_path).absolute()
        self.output_dir = Path(self.output_dir).absolute()

class Bootloader:
    def __init__(self, config: BootloaderConfig, builder: Builder):
        if os.geteuid() != 0:
            raise PermissionError("This script must be run as root")
        self.config = config
        self.temp_dir = builder.get_build_dir("bootloader")
        self.uboot_dir = self.temp_dir / "uboot"

    def _clone_uboot(self) -> bool:
        try:
            subprocess.run([
                'git', 'clone', '--depth=1',
                '-b', self.config.git_branch,
                self.config.git_repo,
                str(self.uboot_dir)
            ], check=True, capture_output=True)
            return True
        except subprocess.CalledProcessError as e:
            print(f"Failed to clone U-Boot: {e.stderr.decode()}")
            return False

    def _setup_overlay_support(self) -> bool:
        try:
            # Copy the process_overlays.c to cmd directory
            shutil.copy2('bootloader/cmd/process_overlays.c',
                        self.uboot_dir / 'cmd' / 'process_overlays.c')
            
            # Append to cmd/Makefile
            with open(self.uboot_dir / 'cmd' / 'Makefile', 'a') as f:
                f.write('\nobj-y += process_overlays.o\n')
            
            # Enable overlay support in config
            subprocess.run(['scripts/config',
                          '--file', '.config',
                          '--enable', 'OF_LIBFDT_OVERLAY'],
                         cwd=self.uboot_dir, check=True)
            return True
        except (OSError, subprocess.CalledProcessError) as e:
            print(f"Failed to setup overlay support: {e}")
            return False

    def _build_uboot(self) -> bool:
        try:
            # Generate BSP
            subprocess.run([
                'python3', 'arch/arm/mach-socfpga/cv_bsp_generator/cv_bsp_generator.py',
                '-i', str(self.config.hps_path),
                '-o', 'board/altera/cyclone5-socdk/qts'
            ], cwd=self.uboot_dir, check=True)

            # Configure and build
            subprocess.run(['make', 'CROSS_COMPILE=arm-linux-gnueabihf-', 'socfpga_cyclone5_defconfig'],
                           cwd=self.uboot_dir, check=True)

            if not self._setup_overlay_support():
                return False

            # Build
            subprocess.run(['make', 'CROSS_COMPILE=arm-linux-gnueabihf-', '-j4'],
                           cwd=self.uboot_dir, check=True)
            return True
        except subprocess.CalledProcessError as e:
            print(f"Failed to build U-Boot: {e}")
            return False

    def generate(self) -> bool:
        try:
            if not self._clone_uboot():
                return False

            if not self._build_uboot():
                return False

            self.config.output_dir.mkdir(parents=True, exist_ok=True)

            # Copy flexible boot script instead of generating one
            shutil.copy2('bootloader/scripts/flexible.script',
                        self.config.output_dir / 'u-boot.scr')

            # Copy SFP file
            shutil.copy2(self.uboot_dir / "u-boot-with-spl.sfp",
                         self.config.output_dir / "u-boot-with-spl.sfp")

            # Copy RBF file
            shutil.copy2(self.config.rbf_path,
                         self.config.output_dir / self.config.rbf_path.name)

            return True
        finally:
            shutil.rmtree(self.temp_dir, ignore_errors=True)
