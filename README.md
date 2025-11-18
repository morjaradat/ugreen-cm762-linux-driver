# UGREEN CM762 USB Wireless Adapter Driver for Linux Kernel 6.17+

[![License: GPL v2](https://img.shields.io/badge/License-GPL%20v2-blue.svg)](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)
[![Kernel: 6.17+](https://img.shields.io/badge/Kernel-6.17%2B-green.svg)](https://kernel.org/)
[![Platform: Linux](https://img.shields.io/badge/Platform-Linux-orange.svg)](https://www.linux.org/)

Patched AIC8800 driver for UGREEN CM762 USB Wireless Adapter with full Linux kernel 6.17+ compatibility.

## 🎯 Features

- ✅ **Kernel 6.17+ Compatible** - Full support for modern Linux kernels
- ✅ **DKMS Integration** - Automatic rebuild on kernel updates
- ✅ **Debian Package** - Easy installation with `.deb` package
- ✅ **Auto-load on Boot** - Driver loads automatically after installation
- ✅ **Clean Uninstall** - Proper removal with all files cleaned up

## 🚀 Quick Installation

### Option 1: Install Pre-built Debian Package (Recommended)

```bash
# Download the package
wget https://github.com/YOUR_USERNAME/REPO_NAME/releases/download/v1.4.0/ugreen-cm762-aic8800-dkms_1.4.0-kernel6.17_all-NEW.deb

# Install
sudo dpkg -i ugreen-cm762-aic8800-dkms_1.4.0-kernel6.17_all-NEW.deb

# Fix dependencies if needed
sudo apt-get install -f
```

### Option 2: Build from Source

```bash
# Clone the repository
git clone https://github.com/morjaradat/ugreen-cm762-linux-driver.git
cd ugreen-cm762-linux-driver/aic8800_linux_driver

# Navigate to driver directory
cd aic8800_linux_driver

# Build
sudo make -C drivers/aic8800

# Install
sudo make -C drivers/aic8800 install

# Load module
sudo depmod -a
sudo modprobe aic8800_fdrv
```

### Option 3: Build Debian Package

```bash
cd aic8800_linux_driver
./build-debian-package.sh
sudo dpkg -i ugreen-cm762-aic8800-dkms_1.4.0-kernel6.17_all.deb
```

## 📋 System Requirements

- Linux kernel 6.17.0 or later
- GCC compiler
- Linux kernel headers: `sudo apt install linux-headers-$(uname -r)`
- DKMS (for package installation): `sudo apt install dkms`
- Build tools: `sudo apt install build-essential`

## 🔍 Verification

After installation, verify the driver is working:

```bash
# Check module is loaded
lsmod | grep aic8800

# Check wireless interface
ip a | grep wlx

# View kernel messages
sudo dmesg | grep -i aic8800
```

You should see a new wireless interface (e.g., `wlxc83a35c64045`).

## 🛠️ Supported Hardware

- **Device:** UGREEN CM762 USB Wireless Adapter
- **Chipset:** AIC8800
- **Interface:** USB 2.0 / USB 3.0
- **Vendor ID:** Check with `lsusb`

## 📦 What's Included

```
.
├── aic8800_linux_driver/           # Main driver source
│   ├── drivers/aic8800/            # Kernel modules
│   │   ├── aic8800_fdrv/          # Main driver module
│   │   └── aic_load_fw/           # Firmware loader
│   ├── fw/                        # Firmware files
│   ├── build-debian-package.sh    # Debian package builder
│   ├── README.md                  # Quick reference
│   ├── INSTALL.md                 # Installation guide
│   └── PACKAGE_INFO.md            # Package documentation
├── linux_driver_package/          # Pre-built packages
│   ├── ugreen-cm762-...NEW.deb   # Patched driver (kernel 6.17+)
│   └── aic8800d80...OLD.deb      # Original driver
└── release_note.txt              # Release notes
```

## 🔧 Kernel Compatibility Patches

This driver has been patched for Linux kernel 6.17+ with the following changes:

### Timer API Updates
- `del_timer()` → `timer_delete()`
- `del_timer_sync()` → `timer_delete_sync()`
- `from_timer()` → `container_of()` macro

### cfg80211 Wireless API
- Updated `cfg80211_rx_spurious_frame()` with `sme` parameter
- Updated `cfg80211_rx_unexpected_4addr_frame()` with `sme` parameter
- Disabled incompatible callback functions in `cfg80211_ops`

### Headers
- Added `<linux/version.h>` for version checking
- Added `<linux/timer.h>` for timer functions
- Proper include ordering for compatibility

## 📖 Documentation

- [**README.md**](aic8800_linux_driver/README.md) - Quick reference guide
- [**INSTALL.md**](aic8800_linux_driver/INSTALL.md) - Detailed installation instructions
- [**PACKAGE_INFO.md**](aic8800_linux_driver/PACKAGE_INFO.md) - Complete package information
- [**CHECKLIST.md**](aic8800_linux_driver/CHECKLIST.md) - Installation checklist

## 🗑️ Uninstallation

### Debian Package:
```bash
sudo dpkg -r ugreen-cm762-aic8800-dkms
```

### Manual Installation:
```bash
sudo modprobe -r aic8800_fdrv aic_load_fw
sudo rm /lib/modules/$(uname -r)/kernel/drivers/net/wireless/aic8800/*.ko
sudo depmod -a
sudo rm /etc/modules-load.d/aic8800.conf
```

## 🐛 Troubleshooting

### Driver not loading?
```bash
# Check USB device
lsusb | grep -i wireless

# Check kernel logs
sudo dmesg | tail -30

# Manually load module
sudo modprobe aic8800_fdrv
```

### No wireless interface?
```bash
# Reload module
sudo modprobe -r aic8800_fdrv
sudo modprobe aic8800_fdrv

# Check interface
ip link show
```

### After kernel update?
```bash
# DKMS should auto-rebuild, but you can force it:
sudo dkms autoinstall
sudo dkms status | grep aic8800
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Areas for contribution:
- Testing on different kernel versions
- Support for additional AIC8800 devices
- Bug fixes and improvements
- Documentation enhancements

## 📝 License

This driver is based on the original AIC8800 driver:
- Original: Copyright (C) RivieraWaves 2012-2019
- Kernel 6.17+ patches: 2025

Licensed under GPL v2.0 - see the [LICENSE](LICENSE) file for details.

## ⚠️ Disclaimer

This driver is provided "as-is" without warranty of any kind. Use at your own risk.
Always backup your system before installing kernel drivers.

## 🔗 Links

- [Release Notes](release_note.txt)
- [Original Driver Package](linux_driver_package/)
- [Issue Tracker](https://github.com/YOUR_USERNAME/REPO_NAME/issues)

## 📊 Tested On

- ✅ Ubuntu 24.04+ with kernel 6.17.0
- ✅ Debian 12+ with kernel 6.17.0
- ✅ Linux Mint (Ubuntu-based)

## 🌟 Credits

- Original driver by RivieraWaves
- Kernel 6.17+ compatibility patches
- UGREEN hardware support

## 📞 Support

For issues and questions:
- Open an [Issue](https://github.com/YOUR_USERNAME/REPO_NAME/issues)
- Check existing documentation
- Review kernel logs: `sudo dmesg | grep aic8800`

---

**Made with ❤️ for the Linux community**
