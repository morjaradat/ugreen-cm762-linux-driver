# UGREEN CM762 AIC8800 Driver - Quick Reference

## Installation Guide Created ✓
See `INSTALL.md` for detailed installation instructions.

## Building the Debian Package

### Prerequisites
```bash
sudo apt install build-essential dkms dpkg-dev linux-headers-$(uname -r)
```

### Build the Package
```bash
./build-debian-package.sh
```

This will create: `ugreen-cm762-aic8800-dkms_1.4.0-kernel6.17_all.deb`

### Install the Package
```bash
sudo dpkg -i ugreen-cm762-aic8800-dkms_1.4.0-kernel6.17_all.deb
```

If you get dependency errors:
```bash
sudo apt-get install -f
```

### Verify Installation
```bash
# Check if module is loaded
lsmod | grep aic8800

# Check wireless interfaces
ip a

# View kernel messages
sudo dmesg | tail -20
```

### Remove the Package
```bash
sudo dpkg -r ugreen-cm762-aic8800-dkms
```

## Manual Installation (Alternative)

If you don't want to use the Debian package:

```bash
# Build
sudo make -C drivers/aic8800

# Install
sudo make -C drivers/aic8800 install

# Update dependencies
sudo depmod -a

# Load module
sudo modprobe aic8800_fdrv

# Auto-load on boot
echo "aic8800_fdrv" | sudo tee /etc/modules-load.d/aic8800.conf
```

## Package Features

✓ **DKMS Integration** - Automatic rebuild on kernel updates
✓ **Auto-load on Boot** - Driver loads automatically after installation  
✓ **Clean Uninstallation** - Removes all files and DKMS entries
✓ **Kernel 6.17+ Compatible** - Patched for modern kernel APIs

## Troubleshooting

**No wireless interface after installation:**
```bash
# Check if USB device is detected
lsusb | grep -i wireless

# Manually load the module
sudo modprobe aic8800_fdrv

# Check for errors
sudo dmesg | grep -i aic8800
```

**Module not found:**
```bash
# Rebuild DKMS modules
sudo dkms status
sudo dkms install aic8800/1.4.0-kernel6.17
```

**After kernel update:**
The DKMS system should automatically rebuild the driver.
If not:
```bash
sudo dkms autoinstall
```

## Files Included in Package

- `/usr/src/aic8800-1.4.0-kernel6.17/` - Driver source code
- `/etc/modules-load.d/aic8800.conf` - Auto-load configuration
- `/usr/share/doc/ugreen-cm762-aic8800-dkms/` - Documentation

## System Requirements

- Linux kernel 6.17.0 or later
- DKMS 2.1.0.0 or later
- GCC compiler and kernel headers
- USB 2.0/3.0 port

## Driver Information

- **Module Name:** aic8800_fdrv
- **Chipset:** AIC8800
- **Interface:** USB Wireless
- **Supported Device:** UGREEN CM762

## Success Indicators

After installation, you should see:
- ✓ New wireless interface (wlxXXXXXXXXXXXX) in `ip a`
- ✓ Module loaded: `lsmod | grep aic8800_fdrv`
- ✓ DKMS status: `dkms status | grep aic8800`
- ✓ Kernel message: "usbcore: registered new interface driver aic8800_fdrv"
