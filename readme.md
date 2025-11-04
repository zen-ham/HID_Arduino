### Arduino HID mouse
## This repository contains HID mouse emulation for the [Zelesis AI Aimbot](https://zelesis.com).
- To get started, acquire an `Arduino Leonardo R3 ATMEGA32U4`, `ARDUINO USB HOST SHIELD`, and a soldering iron if you don't have one.
<br></br>
- Download and install the [Arduino IDE](https://www.arduino.cc/en/software).
<br></br>
- Download and unpack the repository archive to `C:\Users\your_username\Documents\Arduino\HID_Arduino` or if you have logitech G-series mouse download [this](https://github.com/zen-ham/HID_Arduino/blob/master/logitech/README.md) and unpack the repository archive to `C:\Users\your_username\Documents\Arduino\hidmousereport`
<br></br>
- Download and unpack [this](https://github.com/felis/USB_Host_Shield_2.0/releases/tag/1.6.2) archive into `C:\Users\your_username\Documents\Arduino\libraries\USB_Host_Shield_2.0-1.6.2`
<br></br>
- Solder 3 contacts on the board to increase the voltage as shown in the image.
  - ![](https://github.com/zen-ham/HID_Arduino/blob/master/docs/media/host_shield_board.gif)
<br></br>
- Open the file `C:\Users\your_username\Documents\Arduino\HID_Arduino\HID_Arduino.ino` or `C:\Users\your_username\Documents\Arduino\hidmousereport\hidmousereport.ino` if you have logitech G-series mouse
<br></br>
- Connect the `ARDUINO USB HOST SHIELD` to the `Arduino Leonardo` and connect the `ARDUINO` to the PC.
<br></br>
1. Select the device
2. Write "leonardo" in the search engine
3. Select the device
4. Select the port to which the device is connected
5. Upload the program to your device
![](https://github.com/zen-ham/HID_Arduino/blob/master/docs/media/host_shield_ide_select_board_en.png)
<br></br>
- Connect the mouse to the host shield.
<br></br>
- Test the mouse for functionality. If everything works as it should, then you have been successful and lucky with the mouse model. But if something does not work correctly, continue to the next steps. (For logitech G-series tutorial is ends.)
<br></br>
- Open the file `C:\Users\your_username\Documents\Arduino\libraries\USB_Host_Shield_2.0-1.6.2\settings.h` in notepad.
<br></br>
- Change `#define ENABLE_UHS_DEBUGGING 0` to `#define ENABLE_UHS_DEBUGGING 1`
<br></br>
- Upload the script to the device.
<br></br>
- In the Arduino IDE, open the Tools->Serial Monitor tab.
  - ![](https://github.com/zen-ham/HID_Arduino/blob/master/docs/media/serial_monitor.png)
<br></br>
- Select 9600 baud.
  - ![](https://github.com/zen-ham/HID_Arduino/blob/master/docs/media/baud.png)
<br></br>
- You should see the data that the mouse sends to the host shield.
<br></br>
- Switch to the `hidcustom.h` tab and look at the `struct MYMOUSEINFO` structure
<br></br>
- In my case, it looks like this:
  - ![](https://github.com/zen-ham/HID_Arduino/blob/master/docs/media/struct.png)
<br></br>
- For me, the mouse button bytes are transmitted first, but your data might be different, like the mouse coordinates on the X-axis, for example.
<br></br>
- Then you will need to change the structure of `MYMOUSEINFO` so that the variable `uint16_t dX;` is at the beginning.
<br></br>
- In some cases, you will need to change `uint16_t` on the `X axis` or `uint16_t` on the `Y axis` to `uint8_t` .
<br></br>
- Do this with all the output data and normalize the structure.
<br></br>
- Do not forget to disable the `#define ENABLE_UHS_DEBUGGING 0` in `settings.h` after completing all the steps.
<br></br>