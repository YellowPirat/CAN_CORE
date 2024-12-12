# de1soc-imager

This is a simple script to write a debian image to an SD card for the DE1-SoC board. It can either write the image to a tar file or directly to an SD card. The image can be sourced from a URL, a local file, or can be built from scratch.

## Usage

### Build to tar

```bash
python3 ./de1soc-imager.py build --hps ../../synthese/exchange_interface/hps_isw_handoff/de1_soc_hps_0 --rbf ../yellowPirat.rbf
```

This will create a tar file in the current directory with the name `image.tar`.

### Write to SD card

```bash
python3 ./de1soc-imager.py build --device /dev/sdX --hps ../../synthese/exchange_interface/hps_isw_handoff/de1_soc_hps_0 --rbf ../yellowPirat.rbf
```

This will write the image directly to the SD card at `/dev/sdX`.

### Write to SD card from tar

```bash
python3 ./de1soc-imager.py extract ./image.tar /dev/sdX
```

This will write the image from the tar file to the SD card at `/dev/sdX`.

### Changing the rbf file

You can simply copy the new rbf file to the fat32 partition of the SD card and rename it to whatever the old rbf file was named. The bootloader will automatically load the new rbf file.

for linux:

```bash
sudo mount /dev/sdX1 /mnt
sudo cp new_rbf.rbf /mnt/old_rbf.rbf
sudo umount /mnt
```
