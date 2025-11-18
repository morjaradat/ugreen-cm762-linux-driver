#!/bin/bash

# UGREEN CM762 AIC8800 Debian Package Builder
# Creates a .deb package for easy installation and distribution

set -e  # Exit on error

PACKAGE_NAME="ugreen-cm762-aic8800-dkms"
PACKAGE_VERSION="1.4.0-kernel6.17"
PACKAGE_ARCH="all"
MAINTAINER="Driver Maintainer <driver@example.com>"
DESCRIPTION="UGREEN CM762 USB Wireless Adapter Driver (AIC8800 chipset) with kernel 6.17+ support"

BUILD_DIR="$(pwd)/debian-package"
PACKAGE_DIR="${BUILD_DIR}/${PACKAGE_NAME}_${PACKAGE_VERSION}_${PACKAGE_ARCH}"

echo "============================================"
echo "Building Debian package for AIC8800 driver"
echo "============================================"
echo "Package: ${PACKAGE_NAME}"
echo "Version: ${PACKAGE_VERSION}"
echo "Architecture: ${PACKAGE_ARCH}"
echo ""

# Clean previous build
if [ -d "$BUILD_DIR" ]; then
    echo "Cleaning previous build..."
    rm -rf "$BUILD_DIR"
fi

# Create package directory structure
echo "Creating package structure..."
mkdir -p "${PACKAGE_DIR}/DEBIAN"
mkdir -p "${PACKAGE_DIR}/usr/src/aic8800-${PACKAGE_VERSION}"
mkdir -p "${PACKAGE_DIR}/usr/share/doc/${PACKAGE_NAME}"
mkdir -p "${PACKAGE_DIR}/etc/modules-load.d"

# Copy driver source files
echo "Copying driver files..."
cp -r drivers/aic8800/* "${PACKAGE_DIR}/usr/src/aic8800-${PACKAGE_VERSION}/"

# Copy firmware if exists
if [ -d "fw" ]; then
    mkdir -p "${PACKAGE_DIR}/usr/src/aic8800-${PACKAGE_VERSION}/fw"
    cp -r fw/* "${PACKAGE_DIR}/usr/src/aic8800-${PACKAGE_VERSION}/fw/"
fi

# Create DKMS configuration
echo "Creating DKMS configuration..."
cat > "${PACKAGE_DIR}/usr/src/aic8800-${PACKAGE_VERSION}/dkms.conf" << 'EOF'
PACKAGE_NAME="aic8800"
PACKAGE_VERSION="__PACKAGE_VERSION__"
BUILT_MODULE_NAME[0]="aic_load_fw"
BUILT_MODULE_LOCATION[0]="aic_load_fw/"
BUILT_MODULE_NAME[1]="aic8800_fdrv"
BUILT_MODULE_LOCATION[1]="aic8800_fdrv/"
DEST_MODULE_LOCATION[0]="/updates/dkms/"
DEST_MODULE_LOCATION[1]="/updates/dkms/"
AUTOINSTALL="yes"
REMAKE_INITRD="no"
EOF

# Replace version placeholder
sed -i "s/__PACKAGE_VERSION__/${PACKAGE_VERSION}/g" "${PACKAGE_DIR}/usr/src/aic8800-${PACKAGE_VERSION}/dkms.conf"

# Create module load configuration
echo "aic8800_fdrv" > "${PACKAGE_DIR}/etc/modules-load.d/aic8800.conf"

# Copy documentation
echo "Copying documentation..."
if [ -f "INSTALL.md" ]; then
    cp INSTALL.md "${PACKAGE_DIR}/usr/share/doc/${PACKAGE_NAME}/"
fi
if [ -f "release_note.txt" ]; then
    cp release_note.txt "${PACKAGE_DIR}/usr/share/doc/${PACKAGE_NAME}/"
fi

# Create copyright file
cat > "${PACKAGE_DIR}/usr/share/doc/${PACKAGE_NAME}/copyright" << EOF
Format: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/
Upstream-Name: aic8800-driver
Source: UGREEN

Files: *
Copyright: 2012-2019 RivieraWaves
           2025 Kernel 6.17+ patches
License: GPL-2+

License: GPL-2+
 This package is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.
EOF

# Create postinst script (runs after installation)
cat > "${PACKAGE_DIR}/DEBIAN/postinst" << 'EOF'
#!/bin/bash
set -e

DKMS_NAME="aic8800"
DKMS_VERSION="__PACKAGE_VERSION__"

case "$1" in
    configure)
        # Add module to DKMS
        if [ -x /usr/sbin/dkms ]; then
            echo "Adding ${DKMS_NAME}/${DKMS_VERSION} to DKMS..."
            dkms add -m ${DKMS_NAME} -v ${DKMS_VERSION} || true
            
            # Build and install
            echo "Building and installing module..."
            dkms build -m ${DKMS_NAME} -v ${DKMS_VERSION} || true
            dkms install -m ${DKMS_NAME} -v ${DKMS_VERSION} || true
            
            # Load the module
            echo "Loading aic8800_fdrv module..."
            modprobe aic8800_fdrv || true
            
            echo ""
            echo "========================================="
            echo "AIC8800 driver installation completed!"
            echo "========================================="
            echo "The driver will load automatically on boot."
            echo "To check status: lsmod | grep aic8800"
            echo "Wireless interface: ip a"
        else
            echo "DKMS not found. Please install dkms package."
        fi
        ;;
esac

exit 0
EOF

# Create prerm script (runs before removal)
cat > "${PACKAGE_DIR}/DEBIAN/prerm" << 'EOF'
#!/bin/bash
set -e

DKMS_NAME="aic8800"
DKMS_VERSION="__PACKAGE_VERSION__"

case "$1" in
    remove|upgrade|deconfigure)
        # Unload module
        if lsmod | grep -q aic8800; then
            echo "Unloading aic8800 modules..."
            modprobe -r aic8800_fdrv || true
            modprobe -r aic_load_fw || true
        fi
        
        # Remove from DKMS
        if [ -x /usr/sbin/dkms ]; then
            echo "Removing ${DKMS_NAME}/${DKMS_VERSION} from DKMS..."
            dkms remove -m ${DKMS_NAME} -v ${DKMS_VERSION} --all || true
        fi
        ;;
esac

exit 0
EOF

# Replace version placeholders in scripts
sed -i "s/__PACKAGE_VERSION__/${PACKAGE_VERSION}/g" "${PACKAGE_DIR}/DEBIAN/postinst"
sed -i "s/__PACKAGE_VERSION__/${PACKAGE_VERSION}/g" "${PACKAGE_DIR}/DEBIAN/prerm"

# Make scripts executable
chmod 755 "${PACKAGE_DIR}/DEBIAN/postinst"
chmod 755 "${PACKAGE_DIR}/DEBIAN/prerm"

# Calculate installed size
INSTALLED_SIZE=$(du -sk "${PACKAGE_DIR}" | cut -f1)

# Create control file
echo "Creating control file..."
cat > "${PACKAGE_DIR}/DEBIAN/control" << EOF
Package: ${PACKAGE_NAME}
Version: ${PACKAGE_VERSION}
Section: kernel
Priority: optional
Architecture: ${PACKAGE_ARCH}
Depends: dkms (>= 2.1.0.0), build-essential
Maintainer: ${MAINTAINER}
Installed-Size: ${INSTALLED_SIZE}
Description: ${DESCRIPTION}
 This package provides DKMS support for the UGREEN CM762 USB Wireless
 Adapter driver (AIC8800 chipset). The driver has been patched for
 compatibility with Linux kernel 6.17 and later versions.
 .
 Features:
  - Kernel 6.17+ timer API compatibility
  - Updated cfg80211 wireless configuration API
  - Modern power management support
  - Automatic rebuild on kernel updates via DKMS
 .
 The driver will be automatically compiled for your kernel version
 during installation.
EOF

# Build the package
echo ""
echo "Building Debian package..."
dpkg-deb --build "${PACKAGE_DIR}"

# Move package to current directory
mv "${PACKAGE_DIR}.deb" "./$(basename ${PACKAGE_DIR}).deb"

echo ""
echo "============================================"
echo "Package built successfully!"
echo "============================================"
echo "Package file: ./$(basename ${PACKAGE_DIR}).deb"
echo ""
echo "To install:"
echo "  sudo dpkg -i ./$(basename ${PACKAGE_DIR}).deb"
echo "  sudo apt-get install -f  # If dependencies are missing"
echo ""
echo "To remove:"
echo "  sudo dpkg -r ${PACKAGE_NAME}"
echo ""
echo "Package contents:"
dpkg-deb --info "./$(basename ${PACKAGE_DIR}).deb"
echo ""
dpkg-deb --contents "./$(basename ${PACKAGE_DIR}).deb" | head -20
echo "  ..."
echo ""
echo "Done!"
