## RP2040/RP2350 setup guide

- **1** Acquire an RP2040 ***with Type A host***. You can get one from aliexpress or adafruit directly, or any other market.
- Again, ***with Type A host***. One without would be useless. [Example of what the correct board looks like](https://core-electronics.com.au/adafruit-feather-rp2040-with-usb-type-a-host.html) [Example of what to search for](https://www.aliexpress.us/w/wholesale-rp2040-type-a-host.html?g=y&SearchText=rp2040+type+a+host)


- **2** Flash the firmware (this is the V6.1 firmware)
	- Hold BOOT button on the rp
	- While holding BOOT, tap RESET, then release BOOT
	- RPI-RP2 drive appears, drag [V6_Zelesis.uf2](https://gitlab.com/zenham/HID_Arduino/-/raw/master/rp2040_rp2350/rp2040_firmware/v6/V6_Zelesis.uf2) onto it
	- Board reboots.
	- Coming from V5? Same steps, just flash V6 over it. Nothing to uninstall.
	- **From V6.1 the board only moves the mouse for Zelesis, and it needs a Zelesis version newer than 4.7.0.** When Zelesis connects, it gets a signed ticket from our server and hands it to the board (the RP2040 line in Zelesis shows "RP2040 unlocking...", then "RP2040 connected"). An older Zelesis cannot unlock the board, so it would not be able to move the mouse. If you flashed an earlier V6 before, you do not have to do anything, it keeps working as it did.


- **3** Set up your devices as so:
  - Real mouse  →  RP2040 USB-A port (host) - RP2040 USB-C port  →  PC
  - Plug the RP2040 into a USB port directly on the PC (the back of a desktop is best). Not a hub, not a dock, not a monitor or keyboard pass-through. In testing, a board behind a hub froze and reset every few minutes under load, and the same board was rock solid on a direct port.
  - Your real mouse plugged into USB-A should now move the cursor through the Feather
  - The first time, and any time you swap to a different mouse, the board learns the new mouse by itself. The light goes fast cyan, then green, then it reboots once. No reflashing needed.


- **4** inside Zelesis (the latest version, newer than 4.7.0), select the mouse input as RP2040. You are done.
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

- **Zelesis says "RP2040 not connected"**: check you are on the latest Zelesis (newer than 4.7.0), that VID and PID are both 0, that the board is plugged straight into the PC (not a hub), and that the light on the board is on.
- **Zelesis says "RP2040 locked: server unreachable"**: the board is waiting for Zelesis to reach our license server. Check your internet connection and firewall, it keeps retrying by itself.
- **Zelesis says "RP2040 locked: unlock refused"**: our server did not give the board a ticket (license not active, or the same key used on too many boards in one day). It retries every minute. If it stays like that, open a ticket.
- **The mouse takes a moment to light up when the board starts**: normal. At every start the board briefly cuts the power of its USB-A port and turns it back on, so a mouse that got stuck recovers by itself. If the mouse stays dark for more than about 10 seconds, unplug the mouse for 10 seconds, plug it back in and tell us.
- **Something is still wrong?** Open a ticket and tell us which mouse you use. We will send you a small diagnostic tool that shows what the board sees, which is how we sort out mouse compatibility problems.
- **A mouse that does not work right through the board**: open a ticket and say which mouse it is, then run the diagnostic tool we send you. V6 has been tested with gaming mice, cheap low speed office mice and a 2.4 GHz wireless receiver, and mouse software like Logitech G HUB keeps working through the board.
- **RP2350 boards**: V6 is RP2040 only for now. The RP2350 firmware in the [rp2350_firmware](https://gitlab.com/zenham/HID_Arduino/-/tree/master/rp2040_rp2350/rp2350_firmware) folder is the older V4.


Previous firmware, if V6 doesn't work for your mouse (please open a ticket so we can fix it):\
[V5.27, the previous default. For V5 set VID 1118 and PID 203 in Zelesis if it does not connect with the defaults](https://gitlab.com/zenham/HID_Arduino/-/raw/master/rp2040_rp2350/rp2040_firmware/v5/V5_27_Zelesis.uf2)\
[Alternate firmware 1](https://gitlab.com/zenham/HID_Arduino/-/raw/master/rp2040_rp2350/rp2040_firmware/v4/V4_Zelesis.ino.uf2)\
[Alternate firmware 2](https://gitlab.com/zenham/HID_Arduino/-/raw/master/rp2040_rp2350/rp2040_firmware/v3/V3_Zelesis.ino.uf2)\
[Alternate firmware 3](https://gitlab.com/zenham/HID_Arduino/-/raw/master/rp2040_rp2350/rp2040_firmware/v5/V5.26_Zelesis.ino.uf2)
