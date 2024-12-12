#!/usr/bin/env python3

import os
import subprocess
from pathlib import Path
from typing import Optional, Tuple

class DeviceFormatter:
    SFDISK_TEMPLATE = """label: dos
{device}3 : start=2048, size=2048, type=a2
{device}1 : start=4096, size=65536, type=b
{device}2 : start=69632, size=, type=83
"""

    def __init__(self, device_path: str):
        self.device_path = Path(device_path).absolute()
        if os.geteuid() != 0:
            raise PermissionError("This script must be run as root")

    def _unmount_partitions(self) -> None:
        """Unmount any mounted partitions"""
        for i in range(1, 3):
            try:
                subprocess.run(['sudo', 'umount', f'{self.device_path}{i}'],
                               check=False, capture_output=True)
            except subprocess.CalledProcessError:
                pass

    def _clean_device(self) -> bool:
        """Clean the device with zeros"""
        try:
            subprocess.run(['sudo', 'dd',
                            'if=/dev/zero',
                            f'of={self.device_path}',
                            'bs=512', 'count=1'],
                           check=True, capture_output=True)
            return True
        except subprocess.CalledProcessError as e:
            print(f"Error cleaning device: {e.stderr.decode()}")
            return False

    def _partition_device(self) -> bool:
        """Create the required partitions"""
        try:
            sfdisk_content = self.SFDISK_TEMPLATE.format(device=self.device_path)
            p = subprocess.Popen(['sudo', 'sfdisk', str(self.device_path)],
                                 stdin=subprocess.PIPE,
                                 stdout=subprocess.PIPE,
                                 stderr=subprocess.PIPE)
            stdout, stderr = p.communicate(input=sfdisk_content.encode())

            if p.returncode != 0:
                print(f"Error partitioning device: {stderr.decode()}")
                return False
            return True
        except subprocess.CalledProcessError as e:
            print(f"Error partitioning device: {e.stderr.decode()}")
            return False

    def _format_partitions(self) -> bool:
        """Format the partitions with appropriate filesystems"""
        try:
            # Format FAT32 partition
            subprocess.run(['sudo', 'mkfs.vfat', '-n', 'DE1SOCF32',
                            f'{self.device_path}1'],
                           check=True, capture_output=True)

            # Format EXT3 partition
            subprocess.run(['sudo', 'mkfs.ext3', '-F', '-L', 'de1socext3',
                            f'{self.device_path}2'],
                           check=True, capture_output=True)

            # Ensure writes are synced
            subprocess.run(['sudo', 'sync'], check=True, capture_output=True)
            return True
        except subprocess.CalledProcessError as e:
            print(f"Error formatting partitions: {e.stderr.decode()}")
            return False

    def format(self) -> bool:
        """Format the device with required partitions and filesystems"""
        if not self.device_path.exists():
            print(f"Device {self.device_path} does not exist")
            return False

        self._unmount_partitions()

        if not self._clean_device():
            return False

        if not self._partition_device():
            return False

        if not self._format_partitions():
            return False

        return True
