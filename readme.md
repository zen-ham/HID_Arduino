### Arduino HID mouse
## This repository contains HID mouse emulation for the [Zelesis AI Aimbot](https://zelesis.com).

> [!NOTE]
> Important: 100% of games I've played, simply having the arduino plugged in and your normal mouse plugged in separately instead of chaining them together works completely fine, and you can skip alot of difficult steps if you are ok with doing it that way, since then you won't have to edit the code at all and can just keep it exactly as is. While writing this I also tested removing the host shield all together, and it continues to work as normal.
> 
> This means if you so choose, you **DON'T HAVE TO BUY** the expensive usb host shield at all, and you **DON'T HAVE TO SOLDER** anything on the board and can just go with the much simpler and easier option of just using the Arduino Leonardo on it's own.
 
## Easy mode (No Host Shield):
- **1** To get started, acquire an `Arduino Leonardo R3 ATMEGA32U4`

- **2** Download and install the [Arduino IDE](https://www.arduino.cc/en/software).

- **3** Download and unpack the repository archive to `C:\Users\your_username\Documents\Arduino\HID_Arduino`
![](https://github.com/zen-ham/HID_Arduino/blob/master/docs/media/step_3.png)

- **4** Download and unpack [this](https://github.com/felis/USB_Host_Shield_2.0/releases/tag/1.6.2) archive into `C:\Users\your_username\Documents\Arduino\libraries\USB_Host_Shield_2.0-1.6.2`

- **5** Open the file `C:\Users\your_username\Documents\Arduino\HID_Arduino\HID_Arduino.ino`

- **6** connect the `ARDUINO` to the PC. In Arduino IDE:

  1. Select the device
  2. Write "leonardo" in the search engine
  3. Select the device
  4. Select the port to which the device is connected
  5. Upload the program to your device
  ![](https://github.com/zen-ham/HID_Arduino/blob/master/docs/media/host_shield_ide_select_board_en.png)

## Advanced mode with Host Shield <small>(Theoretically harder for AC to detect but no AC currently detects either method.)</small>

- **1** To get started, acquire an `Arduino Leonardo R3 ATMEGA32U4`, `ARDUINO USB HOST SHIELD`, and a soldering iron(Optional, if you don't have one, or you can simply buy a pre-soldered board.)

- **2** Download and install the [Arduino IDE](https://www.arduino.cc/en/software).

- **3** Download and unpack the repository archive to `C:\Users\your_username\Documents\Arduino\HID_Arduino` or if you have logitech G-series mouse download [this](https://github.com/zen-ham/HID_Arduino/blob/master/logitech/README.md) and unpack the repository archive to `C:\Users\your_username\Documents\Arduino\hidmousereport`

- **4** Download and unpack [this](https://github.com/felis/USB_Host_Shield_2.0/releases/tag/1.6.2) archive into `C:\Users\your_username\Documents\Arduino\libraries\USB_Host_Shield_2.0-1.6.2`

- **5** Solder 3 contacts on the board to increase the voltage as shown in the image, if you have a pre soldered board, skip this step.
![](https://github.com/zen-ham/HID_Arduino/blob/master/docs/media/host_shield_board.gif)

- **6** Open the file `C:\Users\your_username\Documents\Arduino\HID_Arduino\HID_Arduino.ino` (or `C:\Users\your_username\Documents\Arduino\hidmousereport\hidmousereport.ino` if you have logitech G-series mouse, but only if doing the passthrough method, if your not using the host shield then just download the HID_Arduino.ino file.)

- **7** Connect the `ARDUINO USB HOST SHIELD` to the `Arduino Leonardo`.

- **8** connect the `ARDUINO` to the PC. In Arduino IDE:

  1. Select the device
  2. Write "leonardo" in the search engine
  3. Select the device
  4. Select the port to which the device is connected
  5. Upload the program to your device
  ![](https://github.com/zen-ham/HID_Arduino/blob/master/docs/media/host_shield_ide_select_board_en.png)

- **9** Connect the mouse to the host shield.

- **10** Test the mouse for functionality. If everything works as it should, then you have been successful and lucky with the mouse model. But if something does not work correctly, continue to the next steps. (For logitech G-series tutorial is ends.)

- **11** Open the file `C:\Users\your_username\Documents\Arduino\libraries\USB_Host_Shield_2.0-1.6.2\settings.h` in notepad.

- **12** Change `#define ENABLE_UHS_DEBUGGING 0` to `#define ENABLE_UHS_DEBUGGING 1`

- **13** Upload the script to the device.

- **14** In the Arduino IDE, open the Tools->Serial Monitor tab.
![](https://github.com/zen-ham/HID_Arduino/blob/master/docs/media/serial_monitor.png)

- **15** Select 9600 baud.
![](https://github.com/zen-ham/HID_Arduino/blob/master/docs/media/baud.png)

- **16** You should see the data that the mouse sends to the host shield.

- **17** Switch to the `hidcustom.h` tab and look at the `struct MYMOUSEINFO` structure

- **18** In my case, it looks like this:
![](https://github.com/zen-ham/HID_Arduino/blob/master/docs/media/struct.png)

- **19** For me, the mouse button bytes are transmitted first, but your data might be different, like the mouse coordinates on the X-axis, for example.

- **20** Then you will need to change the structure of `MYMOUSEINFO` so that the variable `uint16_t dX;` is at the beginning.

- **21** In some cases, you will need to change `uint16_t` on the `X axis` or `uint16_t` on the `Y axis` to `uint8_t` .

- **22** Do this with all the output data and normalize the structure.

- **23** If you enabled it, do not forget to disable the `#define ENABLE_UHS_DEBUGGING 0` in `settings.h` after completing all the steps.
