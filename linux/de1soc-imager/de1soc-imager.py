#!/usr/bin/env python3

import os
import argparse
import subprocess
import shutil
from pathlib import Path
from dataclasses import dataclass
from typing import Optional
import urllib.request
import tarfile

from bootloader import Bootloader, BootloaderConfig
from rootfs import RootFS, RootFSConfig
from formatter import DeviceFormatter
from builder import Builder, BuildConfig

@dataclass
class DE1SOCConfig:
    linux_version: str = "6.6.22-lts"
    debian_version: str = "bookworm"
    default_user: str = "yellowpirat"
    default_password: str = "yellowpirat"
    uboot_repo: str = "https://github.com/altera-opensource/u-boot-socfpga.git"
    uboot_branch: str = "socfpga_v2024.04"
    hps_path: Optional[Path] = None
    rbf_path: Optional[Path] = None
    output_path: Optional[Path] = None
    skip_partitioning: bool = False
    keep_build: bool = False

class DE1SOCImager:
    def __init__(self, config: DE1SOCConfig):
        if os.geteuid() != 0:
            raise PermissionError("This script must be run as root")
        self.config = config
        self.builder = Builder(BuildConfig(
            build_root=Path("build").absolute(),
            keep_build=config.keep_build
        ))
        self.work_dir = self.builder.get_build_dir("imager")


    def _download_tar(self, url: str) -> Optional[Path]:
        try:
            local_file = self.work_dir / "image.tar"
            urllib.request.urlretrieve(url, local_file)
            return local_file
        except Exception as e:
            print(f"Failed to download tar: {e}")
            return None
    
    def _mount_device(self, device_path: Path) -> bool:
        try:
            mount_path = self.work_dir / "rootfs"
            mount_path.mkdir(parents=True, exist_ok=True)
            subprocess.run(['mount', f"{device_path}2", mount_path], check=True)
            mount_path = mount_path / "boot"
            mount_path.mkdir(parents=True, exist_ok=True)
            subprocess.run(['mount', f"{device_path}1", mount_path], check=True)
            return True
        except subprocess.CalledProcessError as e:
            print(f"Failed to mount device: {e}")
            return False

    def _unmount_device(self) -> bool:
        try:
            subprocess.run(['umount', self.work_dir / "rootfs/boot"], check=True)
            subprocess.run(['umount', self.work_dir / "rootfs"], check=True)
            return True
        except subprocess.CalledProcessError as e:
            print(f"Failed to unmount device: {e}")
            return False

    def _create_tar(self, output_path: Path) -> bool:
        try:
            with tarfile.open(output_path, "w:gz") as tar:
                tar.add(self.work_dir / "rootfs", arcname="rootfs")
            return True
        except Exception as e:
            print(f"Failed to create tar: {e}")
            return False
    
    def partition(self, device_path: Optional[str] = None) -> bool:
        if not self.config.skip_partitioning and device_path:
            formatter = DeviceFormatter(device_path)
            if not formatter.format():
                return False
        return True

    def build(self, device_path: Optional[str] = None) -> bool:
        try:
            if not self.partition(device_path):
                return False
            if device_path:
                if not self._mount_device(Path(device_path)):
                    return False

            # Setup rootfs
            rootfs_config = RootFSConfig(
                linux_version=self.config.linux_version,
                debian_version=self.config.debian_version,
                default_user=self.config.default_user,
                default_password=self.config.default_password,
                output_dir=self.work_dir / "rootfs"
            )
            rootfs = RootFS(rootfs_config, self.builder)
            if not rootfs.generate():
                return False

            # Setup bootloader
            bootloader_config = BootloaderConfig(
                git_repo=self.config.uboot_repo,
                git_branch=self.config.uboot_branch,
                hps_path=self.config.hps_path,
                rbf_path=self.config.rbf_path,
                output_dir=self.work_dir / "rootfs/boot"
            )
            bootloader = Bootloader(bootloader_config, self.builder)
            if not bootloader.generate():
                return False

            if device_path:
                return self._write_to_device(Path(device_path))
            else:
                return self._create_tar(self.config.output_path)

        finally:
            if device_path:
                self._unmount_device()
            self.builder.cleanup()

    def extract(self, tar_path: str, device_path: str) -> bool:
        try:
            if tar_path.startswith(('http://', 'https://')):
                tar_path = self._download_tar(tar_path)
                if not tar_path:
                    return False

            if not self.config.skip_partitioning:
                formatter = DeviceFormatter(device_path)
                if not formatter.format():
                    return False
            if not self._mount_device(Path(device_path)):
                return False

            with tarfile.open(tar_path, 'r:*') as tar:
                tar.extractall(self.work_dir)

            return self._write_to_device(Path(device_path))

        finally:
            self._unmount_device()
            shutil.rmtree(self.work_dir, ignore_errors=True)

    def _write_to_device(self, device_path: Path) -> bool:
        try:
            # Write u-boot to partition 3
            uboot_file = self.work_dir / "rootfs/boot/u-boot-with-spl.sfp"
            device_part3 = f"{device_path}3"

            subprocess.run([
                'dd',
                f'if={uboot_file}',
                f'of={device_part3}',
                'bs=64k',
                'seek=0'
            ], check=True)

            return True
        except subprocess.CalledProcessError as e:
            print(f"Failed to write to device: {e}")
            return False

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="DE1-SOC Image Creator")
    subparsers = parser.add_subparsers(dest="command", help="Commands", required=True)

    # Build command
    build_parser = subparsers.add_parser("build", help="Build image")
    build_parser.add_argument("--device", help="Optional device to write directly")
    build_parser.add_argument("--output", help="Output tar file path")
    build_parser.add_argument("--hps", help="HPS path", required=True)
    build_parser.add_argument("--rbf", help="RBF path", required=True)
    build_parser.add_argument("--skip-partitioning", action="store_true")

    # Extract command
    extract_parser = subparsers.add_parser("extract", help="Extract image to device")
    extract_parser.add_argument("tar", help="Tar file or URL")
    extract_parser.add_argument("device", help="Device to write to")
    extract_parser.add_argument("--skip-partitioning", action="store_true")

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        exit(1)

    config = DE1SOCConfig(
        hps_path=Path(args.hps) if hasattr(args, 'hps') else None,
        rbf_path=Path(args.rbf) if hasattr(args, 'rbf') else None,
        output_path=Path(args.output) if (hasattr(args, 'output') and args.output is not None) else Path('image.tar'),
        skip_partitioning=args.skip_partitioning if hasattr(args, 'skip_partitioning') else False
    )

    imager = DE1SOCImager(config)

    success = False
    if args.command == "build":
        success = imager.build(args.device if args.device else None)
    elif args.command == "extract":
        success = imager.extract(args.tar, args.device)

    exit(0 if success else 1)
