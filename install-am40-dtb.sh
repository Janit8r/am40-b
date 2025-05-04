#!/bin/bash
set -e

# Script to install custom AM40 DTB files to an existing Batocera installation
echo "AM40 RK3399 Batocera DTB installer for kernel 6.14.5"

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" 
    exit 1
fi

# Configuration
BATOCERA_BOOT="/boot"
BATOCERA_DTB_DIR="$BATOCERA_BOOT/boot/dtbs"
DTS_DIR="$PWD"
BUILD_DIR="$PWD/build"

# Find correct DTB directory based on kernel version
if [ -d "$BATOCERA_DTB_DIR/6.14.5" ]; then
    DTB_VERSION_DIR="$BATOCERA_DTB_DIR/6.14.5"
elif [ -d "$BATOCERA_DTB_DIR/6.14" ]; then
    DTB_VERSION_DIR="$BATOCERA_DTB_DIR/6.14"
else
    echo "Could not find kernel 6.14.5 DTB directory. Are you using the correct kernel version?"
    echo "Available kernel DTB directories:"
    ls -la "$BATOCERA_DTB_DIR"
    exit 1
fi

# Create the rockchip directory if it doesn't exist
ROCKCHIP_DTB_DIR="$DTB_VERSION_DIR/rockchip"
mkdir -p "$ROCKCHIP_DTB_DIR"

# Check if we need to compile the DTS files to DTB
if [ ! -f "$BUILD_DIR/am40-user.dtb" ]; then
    echo "Compiling DTS files to DTB..."
    mkdir -p "$BUILD_DIR"
    
    # Check if dtc (device tree compiler) is available
    if ! command -v dtc &> /dev/null; then
        echo "dtc (device tree compiler) not found. Installing..."
        apt-get update
        apt-get install -y device-tree-compiler
    fi
    
    # Compile the DTS files to DTB
    dtc -I dts -O dtb -o "$BUILD_DIR/am40-user.dtb" "$DTS_DIR/am40-user.dts"
fi

# Backup existing DTB files
echo "Backing up existing DTB files..."
if [ -f "$ROCKCHIP_DTB_DIR/am40-user.dtb" ]; then
    cp "$ROCKCHIP_DTB_DIR/am40-user.dtb" "$ROCKCHIP_DTB_DIR/am40-user.dtb.backup"
fi

# Copy the custom DTB file
echo "Installing custom DTB file..."
cp "$BUILD_DIR/am40-user.dtb" "$ROCKCHIP_DTB_DIR/"

# Update the extlinux.conf file if needed
EXTLINUX_CONF="$BATOCERA_BOOT/extlinux/extlinux.conf"
if [ -f "$EXTLINUX_CONF" ]; then
    echo "Updating boot configuration..."
    # Check if the FDT line is already set to our DTB
    if grep -q "FDT /boot/dtbs/.*/rockchip/am40-user.dtb" "$EXTLINUX_CONF"; then
        echo "Boot configuration already set to use am40-user.dtb"
    else
        # Make a backup of the original file
        cp "$EXTLINUX_CONF" "$EXTLINUX_CONF.backup"
        
        # Update the FDT line to use our DTB
        KERNEL_VERSION=$(ls -1 "$BATOCERA_DTB_DIR" | grep -E '^6\.14(\.[0-9]+)?$' | sort -V | tail -n 1)
        sed -i "s|FDT .*|FDT /boot/dtbs/$KERNEL_VERSION/rockchip/am40-user.dtb|g" "$EXTLINUX_CONF"
        
        echo "Updated boot configuration to use am40-user.dtb"
    fi
fi

echo "Installation complete. Please reboot your system for changes to take effect."
echo "If the system fails to boot, you can restore the backup DTB files by booting in recovery mode." 