# LINUX
## BASIC SETUP
Connection via UART
```
gtkterm --port=/dev/ttyUSB0
```

Read data from the AXI register 
```
sudo memtool md 0xff200000+20
```

