HPS_PATH = ../synthese/exchange_interface/hps_isw_handoff/de1_soc_hps_0

#########################################################
#														#
#				CREATE U BOOT    						#
#														#
#########################################################
.PHONY: u-boot
u-boot: ./../extern/u-boot-socfpga/u-boot-with-spl.sfp

./../extern/u-boot-socfpga/u-boot-with-spl.sfp: ./$(HPS_PATH)/de1_soc_hps_0.hiof
	python3 ./../extern/u-boot-socfpga/arch/arm/mach-socfpga/cv_bsp_generator/cv_bsp_generator.py \
	  -i ./$(HPS_PATH) \
	  -o ./../extern/u-boot-socfpga/board/altera/cyclone5-socdk/qts
	cd ./../extern/u-boot-socfpga; \
	  make socfpga_cyclone5_defconfig; \
	  make -j2


u-boot.scr: boot.script
	../extern/u-boot-socfpga/tools/mkimage -A arm -O linux \
	  -T script -C none -a 0 -e 0 -n doof \
	  -d boot.script \
	  u-boot.scr


#########################################################
#														#
#				CREATE RAW BINARY						#
#														#
#########################################################
.PHONY: kernel
kernel: ../extern/linux/arch/arm/boot/dts/socfpga_cyclone5_socdk.dtb

../extern/linux:
	cd ../extern/linux; tar -xf /usr/src/linux-source-6.1.tar.xz

../extern/linux/arch/arm/boot/zImage: ../extern/linux
	cd ../extern/linux; \
	  make socfpga_defconfig; \
	  make zImage;

../extern/linux/arch/arm/boot/dts/socfpga_cyclone5_socdk.dtb: ../extern/linux/arch/arm/boot/zImage
	cd ../extern/linux; \
	  make socfpga_cyclone5_socdk.dtb

#########################################################
#														#
#				CREATE ROOT FS   						#
#														#
#########################################################
.PHONY: rootfs
rootfs: ../extern/rootfs.tar.gz

../extern/rootfs.tar.gz: ../extern/build_rootfs.sh
	cd ../extern; ./build_rootfs.sh

#########################################################
#														#
#				CREATE SD-CARD   						#
#														#
#########################################################
sdcarddeps=../extern/linux/arch/arm/boot/zImage \
  ../extern/linux/arch/arm/boot/dts/socfpga_cyclone5_socdk.dtb \
  ../extern/rootfs.tar.gz \
  ../extern/u-boot-socfpga/u-boot-with-spl.sfp \
  yellowPirat.rbf \
  u-boot.scr

.PHONY: sdcard
sdcard: $(sdcarddeps)
	cd ../extern; ./build_sdcard.sh
