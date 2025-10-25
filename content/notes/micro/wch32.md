+++
title = "WCH RISC-V Microcontrollers"
+++

## Noteworthy chips (IMO)
| Chip     | Arch |  Speed |  SRAM | Flash | Power | Notes                       |
| -------- | ---- | ------ | ----- | ----- | ----- | --------------------------- |
| CH32V003 |  V2A |  48MHz |   2KB |  16KB |    ?? |                             |
| CH32V002 |  V2C |  48MHz |   4KB |  16KB |  2-5V | Pin compatible with V003    |
| CH32V006 |  V2C |  48MHz |   8KB |  16KB |  2-5V |                             |
| CH32V203 |  V4B | 144MHz |  20KB |  ??KB |  3.3V | No PMP, Slow DIV opcode     |
| CH32V305 |  V4F | 144MHz |  32KB |  ??KB |  3.3V | FPU                         |
| CH32V307 |  V4F | 144MHz |  64KB |  ??KB |  3.3V | FPU, Ethernet               |

More here: <https://github.com/ch32-rs/ch32-data#Families>

## Useful Links
* <https://github.com/ch32-rs/wchisp>
  * <https://github.com/ch32-rs/ch32-data>
* <https://github.com/basilhussain/ch32v003-bootloader-docs>
* <https://probe.rs/>
* <https://github.com/embassy-rs/embassy>
  * <https://github.com/ch32-rs/ch32-hal>
* <https://www.felixrichter.tech/posts/rustriscvdebugging/>

## Flashing devices
### Via WCH-LinkE (Dongle with CH32V305)
This is the method you want to program bare chips (or modules without a USB port and/or buttons).

Connect the `3.3V`, `GND`, `SDIO`, and optionally the `SDCLK` pins to the microcontroller (NOTE: chips with 16 pins or less don't have a `SDCLK` pin). These pins are typically found on the backside of the dongle.

Then use [wlink](https://github.com/ch32-rs/wlink).

```bash
# list connected
wlink status

wlink flash myprogram.elf
```

**IMPORTANT**: Unless you're programming an older chip like the `CH32V2003`, your `WCH-LinkE` probably needs a firmware update. `wlink status` will report the current firmware version. Newer chips are supported by newer firmwares. At the time of this writing v2.18 is the current version, supporting the CH32V006 family of chips and the CH32V317.

Until wlink adds firmware upgrade support, you can use a separate tool:

<https://github.com/cjacker/wlink-iap>

The latest firmwares can be found in the [WCH-LinkUtility](https://www.wch.cn/downloads/WCH-LinkUtility_ZIP.html) package provided by WCH. For the WCH-LinkE, you want `FIRMWARE_CH32V305.bin`.

```bash
wlink-iap -f ../Firmware_Link/FIRMWARE_CH32V305.bin
```

The `wlink-iap` tool will automatically switch to IAP mode, so upgrading firmwares only requires that you do the above.

### Via bootloader (ISP/IAP)
You can flash a device using the `wchisp` tool ([link](https://github.com/ch32-rs/wchisp)).

NOTE: Uploading data via the booloader is slower than a WCH-LinkE. Also, you can't dump binaries using the bootloader. More information [here](https://github.com/basilhussain/ch32v003-bootloader-docs).

#### Installing wchisp
NOTE: You should add udev rules first, otherwise you'll have to `sudo` to do anything with the devices.

#### /etc/udev/rules.d/50-wchisp.rules
```udev
SUBSYSTEM=="usb", ATTRS{idVendor}=="4348", ATTRS{idProduct}=="55e0", MODE="0666"
# or replace MODE="0666" with GROUP="plugdev" or something else
```

```bash
# Paste the above in this file
sudo nano /etc/udev/rules.d/50-wchisp.rules

# Reload udev
sudo udevadm control --reload
sudo udevadm trigger
```

To install `wchisp` using Cargo:

```bash
cargo install wchisp --git https://github.com/ch32-rs/wchisp
```

Other methods can be found on the `wchisp` [github page](https://github.com/ch32-rs/wchisp).

#### Running wchisp
If the module has a `boot` button, hold it while the device powers on (by plugging it in or by pushing reset). You can confirm the device
is in bootloadr mode with `lsusb`.

```bash
lsusb
# ...
# Bus 001 Device 005: ID 4348:55e0 WinChipHead
# ...
```

You can now use `wchisp` to retrieve information about the attached device.

```bash
wchisp info

# 00:28:26 [INFO] Opening USB device #0
# 00:28:26 [INFO] Chip: CH32V203C8T6[0x3119] (Code Flash: 64KiB)
# 00:28:26 [INFO] Chip UID: CD-AB-58-CF-F1-BC-16-38
# 00:28:26 [INFO] BTVER(bootloader ver): 02.70
# 00:28:26 [INFO] Code Flash protected: true
# 00:28:26 [INFO] Current config registers: ff003fc000ff00ffffffffff00020700cdab58cff1bc1638
# RDPR_USER: 0xC03F00FF
#   [7:0]   RDPR 0xFF (0b11111111)
#     `- Protected
#   [16:16] IWDG_SW 0x1 (0b1)
#     `- IWDG enabled by the software, and disabled by hardware
#   [17:17] STOP_RST 0x1 (0b1)
#     `- Disable
#   [18:18] STANDBY_RST 0x1 (0b1)
#     `- Disable, entering standby-mode without RST
#   [23:22] SRAM_CODE_MODE 0x0 (0b0)
#     `- CODE-192KB + RAM-128KB / CODE-128KB + RAM-64KB depending on the chip
# DATA: 0xFF00FF00
#   [7:0]   DATA0 0x0 (0b0)
#   [23:16] DATA1 0x0 (0b0)
# WRP: 0xFFFFFFFF
#   `- Unprotected
```

To flash:

```bash
wchisp flash ./path/to/firmware.{bin,hex,elf}
```

Again, more information can be found on the `wchisp` [github page](https://github.com/ch32-rs/wchisp).

### Via probe-rs
??

Need to see if this is even Useful

## Creating a binary
Start with this.

<https://github.com/cjacker/ch32v_evt_makefile_gcc_project_template>

It provides a simple script for generating a basic project (NOTE: when I tried it, it was a broken blinky app).

Depending on your chip, this sample project will need to be changed to use an available PIN. The default is D0, which the CH32V002 does not have, so I made mine use D4. Take note of the init code that sets the pin to PP mode (push-pull).
