# Batocera Linux 6.14.5 Compatibility Changes for AM40 RK3399

This document outlines the changes made to the device tree files to ensure compatibility with Linux kernel 6.14.5 in Batocera.

## Issues Addressed

1. **HDMI Output**: Fixed black screen issues with HDMI output that began appearing in Linux 6.x kernels.
2. **USB 3.0 Controller**: Addressed DWC3 controller initialization failures that affected USB 3.0 functionality.

## Changes Made

### 1. HDMI Configuration

#### In am40-user.dts:
- Added explicit HDMI configuration:
  ```
  &hdmi {
    status = "okay";
    ddc-i2c-bus = <&i2c3>;
    pinctrl-names = "default";
    pinctrl-0 = <&hdmi_cec>;
  };
  ```

#### In rk3399-am40.dtsi:
- Added I2C bus reference to HDMI node:
  ```
  ddc-i2c-bus = <&i2c3>;
  ```
- Added HDMI CEC pin configuration:
  ```
  hdmi_cec: hdmi-cec {
      rockchip,pins = <3 RK_PC5 2 &pcfg_pull_none>;
  };
  ```

### 2. DisplayPort Configuration

#### In am40-dp.dtsi:
- Added missing PHY references to the CDP_DP node:
  ```
  phys = <&tcphy0_dp>;
  phy-names = "dp";
  ```

### 3. USB Controller Configuration

#### In rk3399-am40.dtsi:
- Added fallback to USB 2.0 speed if USB 3.0 fails:
  ```
  maximum-speed = "high-speed";
  ```
- Added USB PHY references to DWC3 controllers:
  ```
  phys = <&u2phy0_otg>;
  phy-names = "usb2-phy";
  ```
- Added DWC3 controller fixes for kernel 6.x:
  ```
  snps,dis_u2_susphy_quirk;
  snps,usb2-gadget-lpm-disable;
  ```

## Notes

These changes follow patterns from successful implementations in other RK3399 boards like the RockPro64, where similar issues were fixed in Linux kernel 6.7 and later backported to earlier versions. The main focus was on:

1. Ensuring proper HDMI controller configuration and pinctrl definitions.
2. Adding workarounds for the DWC3 USB controller issues present in kernel 6.x.
3. Ensuring proper PHY references in the device tree.

These changes should allow the AM40 board to boot successfully with Batocera Linux using kernel 6.14.5 with working HDMI output and USB functionality. 