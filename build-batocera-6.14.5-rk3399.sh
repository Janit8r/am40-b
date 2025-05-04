#!/bin/bash
set -e

# Script to build Batocera Linux with kernel 6.14.5 for RK3399 AM40
echo "Starting Batocera Linux build for RK3399 AM40 with kernel 6.14.5"

# Configuration
BATOCERA_DIR="batocera.linux"
KERNEL_VERSION="6.14.5"
BATOCERA_BOARD="rockchip/rk3399"
BUILD_DIR="$PWD/build"
DTS_DIR="$PWD"
OUTPUT_DIR="$PWD/output"

# Make sure directories exist
mkdir -p "$BUILD_DIR"
mkdir -p "$OUTPUT_DIR"

# Clone Batocera repository if it doesn't exist
if [ ! -d "$BATOCERA_DIR" ]; then
    echo "Cloning Batocera repository..."
    git clone https://github.com/batocera-linux/batocera.linux.git "$BATOCERA_DIR"
    cd "$BATOCERA_DIR"
else
    cd "$BATOCERA_DIR"
    echo "Updating Batocera repository..."
    git pull
fi

# Prepare build environment
echo "Setting up build environment..."
make rockchip/rk3399_defconfig

# Set kernel version to 6.14.5
echo "Configuring kernel version to $KERNEL_VERSION..."
sed -i "s/^BR2_LINUX_KERNEL_CUSTOM_VERSION_VALUE=.*$/BR2_LINUX_KERNEL_CUSTOM_VERSION_VALUE=\"$KERNEL_VERSION\"/" .config

# Update the device tree files in the kernel
echo "Copying updated device tree files..."
KERNEL_SRC_DIR="buildroot/output/build/linux-custom"
KERNEL_DTS_DIR="$KERNEL_SRC_DIR/arch/arm64/boot/dts/rockchip"

# Make sure the kernel source directory exists before copying files
if [ ! -d "$KERNEL_SRC_DIR" ]; then
    echo "Building kernel sources first..."
    make linux-extract
fi

# Create the DTS directory if it doesn't exist
mkdir -p "$KERNEL_DTS_DIR"

# Copy our custom device tree files
cp "$DTS_DIR/rk3399-am40.dtsi" "$KERNEL_DTS_DIR/"
cp "$DTS_DIR/am40-dp.dtsi" "$KERNEL_DTS_DIR/"
cp "$DTS_DIR/am40-user.dts" "$KERNEL_DTS_DIR/"

# Add our DTS to the Makefile
echo "Updating kernel DTS Makefile..."
if ! grep -q "am40-user.dtb" "$KERNEL_SRC_DIR/arch/arm64/boot/dts/rockchip/Makefile"; then
    echo "dtb-\$(CONFIG_ARCH_ROCKCHIP) += am40-user.dtb" >> "$KERNEL_SRC_DIR/arch/arm64/boot/dts/rockchip/Makefile"
fi

# Configure Batocera to use our custom DTB
echo "Configuring Batocera to use custom DTB..."
sed -i 's/^BR2_LINUX_KERNEL_INTREE_DTS_NAME=.*$/BR2_LINUX_KERNEL_INTREE_DTS_NAME="rockchip\/am40-user"/' .config

# Start the build process
echo "Starting Batocera build..."
make

# Copy the output files
echo "Build completed. Copying output files..."
cp "output/images/batocera-rockchip-rk3399-$KERNEL_VERSION.img" "$OUTPUT_DIR/"

echo "Build process completed. Image available at: $OUTPUT_DIR/batocera-rockchip-rk3399-$KERNEL_VERSION.img" 