# Install Quartus


# Install CAN_CORE
```
# Clone the repository
git clone --recurse-submodules https://github.com/YellowPirat/CAN_CORE.git

# Navigate to the project
cd CAN_CORE

# source activate script
source activate.sh

# checkout to linux6.1 branch
cd extern/linux
git checkout socfpga-6.1
cd ../../


# Create Quartus project and hps core (Can be skipped if already done)
cd project_files
make qip
cd ../synthese/exchange_interface
make qpf

# Compile exchange_interface
make compile
make rbf

# Create Linux (Can be skipped if already done)
cd ../../linux
make kernel
make rootfs
make u-boot

# Create bootable device (Instert SD-Card)
cd ../extern
./format_sdcard.sh /dev/sdX
cd ../linux
make sdcard

```

# Usage
Connection via UART
```
gtkterm --port=/dev/ttyUSB0
```

Read data from the AXI register 
```
sudo memtool md 0xff200000+28