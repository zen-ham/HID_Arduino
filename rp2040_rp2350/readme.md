## RP2040/RP2350 setup guide

- **1** Acquire an RP2040 **with Type A host**. You can get one from aliexpress or adafruit directly, or any other market.


- **2** Flash the firmware
	- Hold BOOT button on the Feather
	- While holding BOOT, tap RESET, then release BOOT
	- RPI-RP2 drive appears — drag [V4_Zelesis.ino.uf2](https://raw.githubusercontent.com/zen-ham/HID_Arduino/refs/heads/master/rp2040_rp2350/rp2040_firmware/V4_Zelesis.ino.uf2) onto it
	- Board reboots.


- **3** Set up your devices as so:
  - Real mouse  →  RP2040 USB-A port (host) - RP2040 USB-C port  →  PC
  - Your real mouse plugged into USB-A should now move the cursor through the Feather


- **4** inside Zelesis, select the mouse input as RP2040. You are done. If it doesn't connect with VID and PID on default values, then enter 
	- VID: 1118
	- PID: 203


- **5** Consider staring this repo! Please?