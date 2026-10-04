## RP2040/RP2350 setup guide

- **1** Acquire an RP2040 ***with Type A host***. You can get one from aliexpress or adafruit directly, or any other market.
- Again, ***with Type A host***. One without would be useless. [Example of what the correct board looks like](https://core-electronics.com.au/adafruit-feather-rp2040-with-usb-type-a-host.html) [Example of what to search for](https://www.aliexpress.us/w/wholesale-rp2040-type-a-host.html?g=y&SearchText=rp2040+type+a+host)


- **2** Flash the firmware (this is the new V6 firmware)
	- Hold BOOT button on the rp
	- While holding BOOT, tap RESET, then release BOOT
	- RPI-RP2 drive appears, drag [V6_Zelesis.uf2](https://gitlab.com/zenham/HID_Arduino/-/raw/master/rp2040_rp2350/rp2040_firmware/v6/V6_Zelesis.uf2) onto it
	- Board reboots.
	- Coming from V5? Same steps, just flash V6 over it. Nothing to uninstall.


- **3** Set up your devices as so:
  - Real mouse  →  RP2040 USB-A port (host) - RP2040 USB-C port  →  PC
  - Plug the RP2040 into a USB port directly on the PC (the back of a desktop is best). Not a hub, not a dock, not a monitor or keyboard pass-through. In testing, a board behind a hub froze and reset every few minutes under load, and the same board was rock solid on a direct port.
  - Your real mouse plugged into USB-A should now move the cursor through the Feather
  - The first time, and any time you swap to a different mouse, the board learns the new mouse by itself. The light goes fast cyan, then green, then it reboots once. No reflashing needed.


- **4** inside Zelesis (version 4.6.7 or newer), select the mouse input as RP2040. You are done.
  - Leave VID and PID on 0, the defaults. V6 copies your own mouse's VID and PID, so the old V5 values (1118 / 203) will NOT work with it. If you entered them before, set them back to 0.


- **5** Consider staring this repo! Please?


### What the light on the board means

| Light | Meaning |
|---|---|
| Red, slow breathing | no mouse detected on the USB-A port |
| Fast cyan, then steady green | learning a new mouse |
| Red, yellow, green, a green flash, then a slow pulse between light blue and orange | mouse connected and working |
| Quick bright pulses of that colour | Zelesis is sending movement or clicks |
| Fast red flashing | the board just recovered from a crash and is waiting for the mouse |

### Troubleshooting

- **Zelesis says "RP2040 not connected"**: check you are on Zelesis 4.6.7 or newer, that VID and PID are both 0, that the board is plugged straight into the PC (not a hub), and that the light on the board is on.
- **Send a diagnostic report**: download [V6_report.ps1](https://gitlab.com/zenham/HID_Arduino/-/raw/master/rp2040_rp2350/rp2040_firmware/v6/V6_report.ps1), right click it and choose Run with PowerShell (or run `powershell -ExecutionPolicy Bypass -File V6_report.ps1`), then copy everything it prints and send it. It shows the mouse the board learned, the board's health, anything it recorded going wrong, and it warns you if the board is behind a hub.
- **A mouse that does not work right through the board**: send the report above and say which mouse it is. V6 has been tested with gaming mice, cheap low speed office mice and a 2.4 GHz wireless receiver, and mouse software like Logitech G HUB keeps working through the board.
- **RP2350 boards**: V6 is RP2040 only for now. The RP2350 firmware in the [rp2350_firmware](https://gitlab.com/zenham/HID_Arduino/-/tree/master/rp2040_rp2350/rp2350_firmware) folder is the older V4.


Previous firmware, if V6 doesn't work for your mouse (please send me the report so I can fix it):\
[V5.27, the previous default. For V5 set VID 1118 and PID 203 in Zelesis if it does not connect with the defaults](https://gitlab.com/zenham/HID_Arduino/-/raw/master/rp2040_rp2350/rp2040_firmware/v5/V5_27_Zelesis.uf2)\
[Alternate firmware 1](https://gitlab.com/zenham/HID_Arduino/-/raw/master/rp2040_rp2350/rp2040_firmware/v4/V4_Zelesis.ino.uf2)\
[Alternate firmware 2](https://gitlab.com/zenham/HID_Arduino/-/raw/master/rp2040_rp2350/rp2040_firmware/v3/V3_Zelesis.ino.uf2)\
[Alternate firmware 3](https://gitlab.com/zenham/HID_Arduino/-/raw/master/rp2040_rp2350/rp2040_firmware/v5/V5.26_Zelesis.ino.uf2)
