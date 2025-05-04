# RK3399 AM40 Batocera 6.14.5 Kernel Support

This repository contains updated device tree files for the RK3399 AM40 board to enable compatibility with Batocera Linux using kernel 6.14.5.

## Files Overview

- `am40-user.dts` - Main device tree source file
- `am40-dp.dtsi` - DisplayPort configuration include file
- `rk3399-am40.dtsi` - Base RK3399 AM40 device tree source include file
- `build-batocera-6.14.5-rk3399.sh` - Build script for compiling Batocera with kernel 6.14.5
- `batocera-6.14.5-compatibility.md` - Documentation of changes made for kernel 6.14.5 compatibility

## Changes Made for Linux Kernel 6.14.5

The device tree files have been updated to address several issues that appeared in Linux kernel 6.x:

1. **HDMI Output Fixes**: Fixed configuration for proper HDMI output
2. **USB 3.0 Controller**: Updated DWC3 controller configuration for better compatibility
3. **DisplayPort Support**: Improved DisplayPort compatibility

For detailed changes, see `batocera-6.14.5-compatibility.md`.

## Building Batocera with Kernel 6.14.5

### Prerequisites

- Linux development environment
- Git, make, and standard build tools
- At least 50GB of free disk space
- Good internet connection (for downloading sources)

### Build Instructions

1. Make the build script executable:
   ```bash
   chmod +x build-batocera-6.14.5-rk3399.sh
   ```

2. Run the build script:
   ```bash
   ./build-batocera-6.14.5-rk3399.sh
   ```

3. Wait for the build to complete (this may take several hours)

4. Find the output image in the `output` directory

### Installing to SD Card or USB Drive

Once the build is complete, you can write the image to an SD card or USB drive:

```bash
sudo dd if=output/batocera-rockchip-rk3399-6.14.5.img of=/dev/sdX bs=4M status=progress
```

Replace `/dev/sdX` with your actual device (be careful to use the correct device!).

## Troubleshooting

If you encounter issues with the build:

1. Make sure you have all required dependencies installed
2. Check the build logs in the Batocera build directory
3. Try running the specific failing step manually to see detailed error messages

For issues with the device tree on the running system, you can check the kernel logs:

```bash
dmesg | grep -i -E 'hdmi|usb|display'
```

## License

These device tree files and build scripts are provided under the same license as the original Batocera Linux project. 