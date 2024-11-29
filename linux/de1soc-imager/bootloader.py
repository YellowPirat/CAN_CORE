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
            subprocess.run(['make', 'CROSS_COMPILE=arm-linux-gnueabihf-', '-j4'],
                           cwd=self.uboot_dir, check=True)
            return True
        except subprocess.CalledProcessError as e:
            print(f"Failed to build U-Boot: {e}")
            return False

    def _create_boot_script(self) -> bool:
        try:
            rbf_name = self.config.rbf_path.name
            script_content = f"fatload mmc 0:1 0x2000000 {rbf_name}\n"
            script_content += "fpga load 0 0x2000000 $filesize\n"
            script_content += "bridge enable 0x2\n"

            boot_script = self.temp_dir / "boot.script"
            boot_script.write_text(script_content)

            subprocess.run([
                str(self.uboot_dir / "tools/mkimage"),
                '-A', 'arm', '-O', 'linux',
                '-T', 'script', '-C', 'none',
                '-a', '0', '-e', '0',
                '-n', 'doof',
                '-d', str(boot_script),
                str(self.config.output_dir / "u-boot.scr")
            ], check=True)
            return True
        except (subprocess.CalledProcessError, OSError) as e:
            print(f"Failed to create boot script: {e}")
            return False

    def _create_extlinux_conf(self) -> bool:
        try:
            extlinux_dir = self.config.output_dir / "extlinux"
            extlinux_dir.mkdir(parents=True, exist_ok=True)
            
            # Find vmlinuz file
            vmlinuz_files = list(self.config.output_dir.glob("vmlinuz*socfpga"))
            if not vmlinuz_files:
                print("No vmlinuz file found")
                return False
                
            vmlinuz_path = f"../{vmlinuz_files[0].name}"
            
            conf_content = [
                "LABEL Linux Default",
                f" KERNEL {vmlinuz_path}",
                " FDT ../dtb",
                " APPEND root=/dev/mmcblk0p2 rw rootwait earlyprintk console=ttyS0,115200n8"
            ]
            
            (extlinux_dir / "extlinux.conf").write_text("\n".join(conf_content))
            return True
            
        except OSError as e:
            print(f"Failed to create extlinux configuration: {e}")
            return False

    def generate(self) -> bool:
        try:
            if not self._clone_uboot():
                return False

            if not self._build_uboot():
                return False

            self.config.output_dir.mkdir(parents=True, exist_ok=True)

            if not self._create_boot_script():
                return False

            if not self._create_extlinux_conf():
                return False

            # Copy SFP file
            shutil.copy2(self.uboot_dir / "u-boot-with-spl.sfp",
                         self.config.output_dir / "u-boot-with-spl.sfp")

            # Copy RBF file
            shutil.copy2(self.config.rbf_path,
                         self.config.output_dir / self.config.rbf_path.name)

            return True
        finally:
            shutil.rmtree(self.temp_dir, ignore_errors=True)
