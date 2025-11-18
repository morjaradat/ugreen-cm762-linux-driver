# UGREEN CM762 USB Wireless Adapter Driver Installation Guide

## AIC8800 Driver for Linux Kernel 6.17+

This driver has been patched for compatibility with Linux kernel 6.17.0 and later versions.

### System Requirements

- Linux kernel 6.17.0 or later
- GCC compiler
- Linux kernel headers for your running kernel
- make, dpkg-dev (for building Debian package)

### Quick Installation

#### Method 1: Direct Installation

1. **Install prerequisites:**
```bash
sudo apt update
sudo apt install build-essential linux-headers-$(uname -r) dkms
```

2. **Navigate to the driver directory:**
```bash
cd aic8800_linux_driver
```

3. **Build the driver:**
```bash
sudo make -C drivers/aic8800
```

4. **Install the driver:**
```bash
sudo make -C drivers/aic8800 install
```

5. **Update module dependencies:**
```bash
sudo depmod -a
```

6. **Load the driver:**
```bash
sudo modprobe aic8800_fdrv
```

7. **Enable auto-loading on boot:**
```bash
echo "aic8800_fdrv" | sudo tee /etc/modules-load.d/aic8800.conf
```

8. **Verify installation:**
```bash
lsmod | grep aic8800
ip a  # Check for new wireless interface (wlx...)
```

#### Method 2: DKMS Installation (Recommended for kernel updates)

1. **Copy driver to DKMS location:**
```bash
sudo mkdir -p /usr/src/aic8800-1.4.0
sudo cp -r drivers/aic8800/* /usr/src/aic8800-1.4.0/
sudo cp fw /usr/src/aic8800-1.4.0/ -r
```

2. **Create DKMS configuration:**
```bash
sudo tee /usr/src/aic8800-1.4.0/dkms.conf << 'EOF'
PACKAGE_NAME="aic8800"
PACKAGE_VERSION="1.4.0"
BUILT_MODULE_NAME[0]="aic_load_fw"
BUILT_MODULE_LOCATION[0]="aic_load_fw/"
BUILT_MODULE_NAME[1]="aic8800_fdrv"
BUILT_MODULE_LOCATION[1]="aic8800_fdrv/"
DEST_MODULE_LOCATION[0]="/kernel/drivers/net/wireless/aic8800/"
DEST_MODULE_LOCATION[1]="/kernel/drivers/net/wireless/aic8800/"
AUTOINSTALL="yes"
MAKE="make -C \${dkms_tree}/\${PACKAGE_NAME}/\${PACKAGE_VERSION}/build"
CLEAN="make -C \${dkms_tree}/\${PACKAGE_NAME}/\${PACKAGE_VERSION}/build clean"
EOF
```

3. **Add and build with DKMS:**
```bash
sudo dkms add -m aic8800 -v 1.4.0
sudo dkms build -m aic8800 -v 1.4.0
sudo dkms install -m aic8800 -v 1.4.0
```

4. **Load the driver:**
```bash
sudo modprobe aic8800_fdrv
```

### Uninstallation

#### Direct Installation:
```bash
sudo modprobe -r aic8800_fdrv aic_load_fw
sudo rm /lib/modules/$(uname -r)/kernel/drivers/net/wireless/aic8800/*.ko
sudo depmod -a
sudo rm /etc/modules-load.d/aic8800.conf
```

#### DKMS Installation:
```bash
sudo dkms remove aic8800/1.4.0 --all
sudo rm -rf /usr/src/aic8800-1.4.0
```

### Troubleshooting

**Driver not loading:**
```bash
# Check kernel messages
sudo dmesg | tail -50

# Verify module files
find /lib/modules/$(uname -r) -name "aic8800*.ko"

# Check module info
modinfo aic8800_fdrv
```

**No wireless interface appearing:**
- Ensure the USB adapter is plugged in
- Check USB detection: `lsusb | grep -i wireless`
- Reload the module: `sudo modprobe -r aic8800_fdrv && sudo modprobe aic8800_fdrv`

**Build errors:**
- Ensure kernel headers match your running kernel: `uname -r` vs `ls /usr/src/`
- Update your system: `sudo apt update && sudo apt upgrade`
- Install missing dependencies: `sudo apt install linux-headers-$(uname -r)`

### Kernel Compatibility Notes

This driver has been patched for Linux kernel 6.17+ with the following changes:

- Timer API compatibility: `del_timer` → `timer_delete`, `del_timer_sync` → `timer_delete_sync`
- cfg80211 API updates for wireless configuration
- Wakelock API updates for power management
- Container-based timer callbacks using `container_of`

The driver maintains backward compatibility with older kernels through version checks.

### Supported Devices

- UGREEN CM762 USB Wireless Adapter
- AIC8800 chipset-based adapters

### Additional Information

**Firmware location:** `/lib/firmware/aic8800/`
**Module parameters:** Check with `modinfo aic8800_fdrv`
**Kernel logs:** `sudo dmesg | grep -i aic8800`

### License

Original driver: Copyright (C) RivieraWaves 2012-2019
Kernel 6.17+ patches: 2025

For support and issues, check the driver documentation or system logs.
