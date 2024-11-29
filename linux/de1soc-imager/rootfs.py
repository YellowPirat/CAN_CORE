#!/usr/bin/env python3

import os
import subprocess
from pathlib import Path
from dataclasses import dataclass
import shutil
from builder import Builder
import tarfile
import io

@dataclass
class RootFSConfig:
    linux_version: str
    debian_version: str
    default_user: str
    default_password: str
    output_dir: Path

    def __post_init__(self):
        self.output_dir = Path(self.output_dir).absolute()

class RootFS:
    FAT32_LABEL = "DE1SOCF32"
    EXT3_LABEL = "de1socext3"
    DEBIAN_PACKAGES = "sudo gpiod memtool build-essential gcc make git flex bison libssl-dev bc rsync curl wget gnupg fakeroot network-manager"

    def __init__(self, config: RootFSConfig, builder: Builder):
        if os.geteuid() != 0:
            raise PermissionError("This script must be run as root")
        self.config = config
        self.root_dir = builder.get_build_dir("rootfs")

    def _debootstrap(self) -> bool:
        try:
            subprocess.run([
                'debootstrap', '--foreign', '--arch=armhf',
                self.config.debian_version, str(self.root_dir)
            ], check=True)

            subprocess.run([
                'chroot', str(self.root_dir),
                '/debootstrap/debootstrap', '--second-stage'
            ], check=True)
            return True
        except subprocess.CalledProcessError as e:
            print(f"Debootstrap failed: {e}")
            return False

    def _configure_system(self) -> bool:
        try:
            # Configure locales
            subprocess.run(['chroot', str(self.root_dir), 'apt', 'install', '-y', 'locales'], check=True)
            with open(self.root_dir / "etc/locale.gen", "a") as f:
                f.write("en_US.UTF-8 UTF-8\n")
            subprocess.run(['chroot', str(self.root_dir), 'locale-gen'], check=True)
            subprocess.run(['chroot', str(self.root_dir), 'update-locale', 'LANG=en_US.UTF-8'], check=True)

            # Setup fstab
            fstab_content = f"""
LABEL={self.EXT3_LABEL} / ext3 defaults,errors=remount-ro 0 1
LABEL={self.FAT32_LABEL} /boot vfat defaults 0 2
"""
            (self.root_dir / "etc/fstab").write_text(fstab_content.strip())

            return True
        except (subprocess.CalledProcessError, OSError) as e:
            print(f"System configuration failed: {e}")
            return False

    def _install_packages(self) -> bool:
        try:
            env = os.environ.copy()
            env['DEBIAN_FRONTEND'] = 'noninteractive'

            subprocess.run(['chroot', str(self.root_dir), 'apt', 'update'], check=True)
            subprocess.run(['chroot', str(self.root_dir), 'apt', 'install', '-y'] +
                           self.DEBIAN_PACKAGES.split(),
                           env=env, check=True)
            return True
        except subprocess.CalledProcessError as e:
            print(f"Package installation failed: {e}")
            return False

    def _setup_de1soc_repo(self) -> bool:
        try:
            keyring_dir = self.root_dir / "etc/apt/keyrings"
            keyring_dir.mkdir(parents=True, exist_ok=True)

            subprocess.run(['chroot', str(self.root_dir), '/bin/bash', '-c',
                            'wget -qO - https://yellowpirat.github.io/de1soc-linux/de1soc-linux.gpg | ' +
                            'gpg --dearmor > /etc/apt/keyrings/de1soc-linux.gpg'], check=True)

            sources_list = 'deb [signed-by=/etc/apt/keyrings/de1soc-linux.gpg] ' + \
                           'https://yellowpirat.github.io/de1soc-linux/packages stable main'
            subprocess.run(['chroot', str(self.root_dir), '/bin/bash', '-c',
                            f'echo "{sources_list}" > /etc/apt/sources.list.d/de1soc-linux.list'], check=True)

            subprocess.run(['chroot', str(self.root_dir), 'apt', 'update'], check=True)
            return True
        except (subprocess.CalledProcessError, OSError) as e:
            print(f"Failed to setup DE1-SoC repository: {e}")
            return False

    def _install_kernel(self) -> bool:
        try:
            if not self._setup_de1soc_repo():
                return False

            env = os.environ.copy()
            env['DEBIAN_FRONTEND'] = 'noninteractive'

            # Install kernel packages
            packages = [
                f'linux-image-{self.config.linux_version}-socfpga',
                f'linux-headers-{self.config.linux_version}-socfpga',
                'linux-libc-dev'
            ]
            subprocess.run(['chroot', str(self.root_dir), 'apt', 'install', '-y'] + packages,
                           env=env, check=True)

            # Copy DTB
            src_dtb = self.root_dir / f"lib/linux-image-{self.config.linux_version}-socfpga/socfpga_cyclone5_socdk.dtb"
            dst_dtb = self.root_dir / "boot/dtb"
            shutil.copy2(src_dtb, dst_dtb)

            return True
        except (subprocess.CalledProcessError, OSError) as e:
            print(f"Kernel installation failed: {e}")
            return False

    def _configure_user(self) -> bool:
        try:
            subprocess.run(['chroot', str(self.root_dir), 'useradd', '-m',
                            '-s', '/bin/bash', self.config.default_user], check=True)
            subprocess.run(['chroot', str(self.root_dir), 'adduser',
                            self.config.default_user, 'sudo'], check=True)

            passwd_cmd = f"echo {self.config.default_user}:{self.config.default_password} | chpasswd"
            subprocess.run(['chroot', str(self.root_dir), '/bin/bash', '-c', passwd_cmd], check=True)
            return True
        except subprocess.CalledProcessError as e:
            print(f"User configuration failed: {e}")
            return False

    def _configure_networking(self) -> bool:
        try:
            (self.root_dir / "etc/hostname").write_text("de1soc\n")
            with open(self.root_dir / "etc/hosts", "a") as f:
                f.write("127.0.0.1 de1soc\n")

            nm_conf = """[main]
plugins=ifupdown,keyfile
[ifupdown]
managed=true"""
            (self.root_dir / "etc/NetworkManager/NetworkManager.conf").write_text(nm_conf)

            return True
        except OSError as e:
            print(f"Network configuration failed: {e}")
            return False

    def _mount_system_dirs(self) -> None:
        for dir_name in ['dev', 'proc', 'sys']:
            target = self.root_dir / dir_name
            target.mkdir(exist_ok=True)
            subprocess.run(['mount', '--bind', f'/{dir_name}', str(target)], check=True)

    def _unmount_system_dirs(self) -> None:
        for dir_name in reversed(['dev', 'proc', 'sys']):
            try:
                subprocess.run(['umount', str(self.root_dir / dir_name)], check=True)
            except subprocess.CalledProcessError:
                pass

    def generate(self) -> bool:
        try:
            if not self._debootstrap():
                return False

            self._mount_system_dirs()

            if not self._configure_system():
                return False

            if not self._install_packages():
                return False

            if not self._setup_de1soc_repo():
                return False

            if not self._install_kernel():
                return False

            if not self._configure_user():
                return False

            if not self._configure_networking():
                return False

            self._unmount_system_dirs()
            # Copy final rootfs to output directory
            with io.BytesIO() as buffer:
                # Create tar archive in memory
                with tarfile.open(fileobj=buffer, mode='w|') as tar:
                    tar.add(self.root_dir, arcname='')
                
                # Seek to start of buffer
                buffer.seek(0)
                
                # Extract to destination
                with tarfile.open(fileobj=buffer, mode='r|') as tar:
                    tar.extractall(path=self.config.output_dir)
            return True
        finally:
            self._unmount_system_dirs()
            shutil.rmtree(self.root_dir, ignore_errors=True)
