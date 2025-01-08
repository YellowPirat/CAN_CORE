# Install Quartus


# Install CAN_CORE
```
# Clone the repository
git clone --recurse-submodules https://github.com/YellowPirat/CAN_CORE.git

# If you forgot the recurse-flag ;=)
git submodule update

# Navigate to the project
cd CAN_CORE

# source activate script
source activate.sh

# Create Quartus project and hps core (Can be skipped if already done)
cd project_files
make qip
cd ../synthese/core
make qpf

# Compile exchange_interface
make compile
make rbf

# Enable stuff
sudo update-binfmts --enable qemu-arm
```

# Create bootable device (Instert SD-Card)

Refer to [de1soc-imager](./linux/de1soc-imager/README.md)

# Usage
Connection via UART
```
gtkterm --port=/dev/ttyUSB0
```

Read data from the AXI register 
```
    sudo memtool md 0xff200000+44
```

Config Sample Unit 1M
```
sudo memtool mw 0xff20002c 0x00000001
sudo memtool mw 0xff200030 0x00000002
sudo memtool mw 0xff200034 0x00000004
sudo memtool mw 0xff200038 0x00000003
sudo memtool mw 0xff20003c 0x00000004
sudo memtool mw 0xff200040 0x00000001

```

Config Sample Unit 500k
```
sudo memtool mw 0xff20002c 0x00000001
sudo memtool mw 0xff200030 0x00000005
sudo memtool mw 0xff200034 0x00000007
sudo memtool mw 0xff200038 0x00000007
sudo memtool mw 0xff20003c 0x00000004
sudo memtool mw 0xff200040 0x00000001
```
