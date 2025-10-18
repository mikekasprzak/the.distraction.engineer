+++
title = "WCH Microcontrollers"
+++
## Useful Links
* <https://github.com/ch32-rs/wchisp>
* <https://github.com/basilhussain/ch32v003-bootloader-docs>
* <https://probe.rs/>
* <https://github.com/embassy-rs/embassy>
  * <https://github.com/ch32-rs/ch32-hal>

## Flashing devices
### Via WCH-LinkE
Use `probe-rs`.

### Via bootloader
Use the [wchisp](https://github.com/ch32-rs/wchisp) tool.

NOTE: Uploading data via the booloader is slower than a WCH-LinkE. You also can't dump binaries using the bootloader. More information about CH32 bootloaders: <https://github.com/basilhussain/ch32v003-bootloader-docs>

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

To install using Cargo:

```bash
cargo install wchisp --git https://github.com/ch32-rs/wchisp
```

Other methods can be found on the [wchisp](https://github.com/ch32-rs/wchisp) page.

#### Running wchipsp
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

Again, more information can be found on the [wchisp](https://github.com/ch32-rs/wchisp) page.
