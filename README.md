Custom Midi Controller
======================

Code and instructions to easily build a MIDI Controller from scratch using a
standalone Atmega328P-PU, but still use the Arduino library for the convenient 
functions.

Features
--------

- Cheap to build : use directly a standalone Atmega microcontroller (not a whole Arduino board) ;
- Plug-and-play : detected as an actual MIDI device automatically (no need for intermediate software) ;
- Easy reprogram through USB : using the proper bootloader and a switch, you enter a mode to reprogram it at will (no need for USB to Serial  / FTDI stuff) ;
- Use the Arduino library to manage pins with pinMode, digitalRead, analogRead... *Please no crazy batshit using binary operators - who actually wants to code like that, really ?*
- Easily customizable, extandable.

How to build your MIDI Controller ?
-----------------------------------

1. General overview
2. Shopping for hardware
3. Making a USB cable
4. Building the core (standalone Atmega on USB)
5. Flashing the USBasp/V-USB bootloader
6. Flashing a dummy Midi Controller firmware
7. Adding switches and potentiometer
8. Put all this in a nice case
9. Profit !

1. General overview
-------------------

The general architecture is shown below. The core of the controller is an Atmega
chip. A special bootloader is used to allow the chip to be reprogrammed directly
through USB. The user program can also communicate with the computer directly 
through USB, and actually be recognized as any USB device you would like,
including HID (Human Interface Device), and in our case, a MIDI controller. You
can then interface your controller with any music software speaking MIDI.

On the Atmega chip, potentiometers and switches can be connected, and mapped in 
the software to generate corresponding MIDI signals (control, notes, play/pause, 
...). 

Note that the Atmega alone accepts only 6 analog entries (i.e. needed to interface 
potentiometers). However it is relatively simple to add one or several
multiplexers to extend the capabilities (8 entries mapped to 1 entry, i.e. up to 
48 analog entries).

![](./doc/overview.png)

2. Shopping for hardware
------------------------

### The core

- 1 x Atmega328P-PU                ([Product on Farnell](http://fr.farnell.com/webapp/wcs/stores/servlet/Search?exaMfpn=true&mfpn=1715487)) Careful : need *exactly* the 328**P-PU** version
- 1 x Socket for 28 pin chip       ([Product on Farnell](http://fr.farnell.com/webapp/wcs/stores/servlet/Search?exaMfpn=true&mfpn=2445626)) Optionnal, but recommended
- 1 x USB connector                ([Product on Farnell](http://fr.farnell.com/webapp/wcs/stores/servlet/Search?exaMfpn=true&mfpn=1696544)) (or an old USB cable with male plug, to be cut to access the wires)
- 1 x 12MHz crystal                ([Product on Farnell](http://fr.farnell.com/webapp/wcs/stores/servlet/Search?exaMfpn=true&mfpn=2508453))
- 2 x 3.6V zener diode             ([Example on Farnell](http://fr.farnell.com/webapp/wcs/stores/servlet/Search?exaMfpn=true&mfpn=1861480))
- 2 x 22pF ceramic capacitor       ([Example on Farnell](http://fr.farnell.com/webapp/wcs/stores/servlet/Search?exaMfpn=true&mfpn=9411674))
- 1 x 100nF ceramic capacitor      ([Example on Farnell](http://fr.farnell.com/webapp/wcs/stores/servlet/Search?exaMfpn=true&mfpn=9411887))
- 1 x 4.7μF electrolytic capacitor ([Example on Farnell](http://fr.farnell.com/webapp/wcs/stores/servlet/Search?exaMfpn=true&mfpn=9451471))
- 1 x 10~50kΩ resistor             ([Example on Farnell](http://fr.farnell.com/webapp/wcs/stores/servlet/Search?exaMfpn=true&mfpn=2329609))
- 1 x 1~2kΩ resistor               ([Example on Farnell](http://fr.farnell.com/webapp/wcs/stores/servlet/Search?exaMfpn=true&mfpn=2329629))
- 2 x 68Ω resistor                 ([Example on Farnell](http://fr.farnell.com/webapp/wcs/stores/servlet/Search?exaMfpn=true&mfpn=2329701))
- 1 x mini push button switch      ([Example on Farnell](http://fr.farnell.com/webapp/wcs/stores/servlet/Search?exaMfpn=true&mfpn=2468762))
- 1 x mini toggle switch           ([Example on Farnell](http://fr.farnell.com/webapp/wcs/stores/servlet/Search?exaMfpn=true&mfpn=2320018))

- Colored wires                    ([Example](http://www.robotshop.com/eu/en/elenco-22-gauge-black-25-ft.html), or any cable you can find. Just don't use fancy jumper wires if you intend to solder !)
- Single-sided prototyping board   ([Example](http://www.robotshop.com/eu/en/prototyping-board.html)) or a breadboard if you don't want to solder right away

### Actual controller stuff

- ? x On/off switches                        ([Example on Farnell](http://fr.farnell.com/webapp/wcs/stores/servlet/Search?exaMfpn=true&mfpn=9473378))
- ? x Push-button / keys                     ([Example on Farnell](http://fr.farnell.com/webapp/wcs/stores/servlet/Search?exaMfpn=true&mfpn=2079605))
- ? x Rotatory potentiometers                ([Product on Farnell](http://fr.farnell.com/webapp/wcs/stores/servlet/Search?exaMfpn=true&mfpn=1760794))
- ? x Knob for rotatory potentiometers       ([Example on Farnell](http://fr.farnell.com/webapp/wcs/stores/servlet/Search?exaMfpn=true&mfpn=2473099))
- ? x Linear potentiometers ("sliders")      (Product on Farnell : [45mm](http://fr.farnell.com/webapp/wcs/stores/servlet/Search?exaMfpn=true&mfpn=1688415), [60mm](http://fr.farnell.com/webapp/wcs/stores/servlet/Search?exaMfpn=true&mfpn=1688411))
- ? x Cursor for linear potentiometers       ([Product on Farnell](http://fr.farnell.com/webapp/wcs/stores/servlet/Search?exaMfpn=true&mfpn=1440016))
- ? x 100 screws for linear potentiomeneters ([Product on Farnell](http://fr.farnell.com/webapp/wcs/stores/servlet/Search?exaMfpn=true&mfpn=507118))

### Tools

- A good soldering iron (+solder material) ;
- A stripper ;
- Some scissors or small cutters to cut wires after soldering ;
- Ideally, a multimeter - or at least to check there's no short between GND and 5V !
- A small knife if you need to remove the chip from the support.

### Optional - Analog multiplexers (if you aim to control more than 6 analog entries) :

These will allow you to map 8 analog inputs to 1 input

- ? x 1-to-8 analog multiplexer         ([Product on Farnell](http://fr.farnell.com/webapp/wcs/stores/servlet/Search?exaMfpn=true&mfpn=1236279))
- ? x Socket for 16 pin chip            ([Product on Farnell](http://fr.farnell.com/webapp/wcs/stores/servlet/Search?exaMfpn=true&mfpn=2445622)) Optionnal, but recommended

3. Making a USB cable
---------------------

The first step is to build ourselves a USB cable. This will be the interface
between the computer and our MIDI controller, and in particular the Atmega chip.

There are many ways to do this. For instance, you can cut an old USB cable (e.g.
from a broken USB mouse) to access the wires. You can also just solder a male or 
female connector directly on the board next to your Atmega, and use a cable like 
[this](http://fr.farnell.com/productimages/standard/en_US/95W0184-40.jpg).
Personnally I built a cable using a male USB connector and some wires. Make sure
you wires are at least ~0.5m long (mines were 20 cm long and it's clearly too short :))

The pinning of the A plug is shown below. It is good practice to use red/black
for the 5V/GND pins , and white/green for the D-/D+ pins.

![](./doc/USBpinning.png)

![](./hardware/usbCableIRL.jpg)

4. Building the core (standalone Atmega on USB)
-----------------------------------------------

![](./doc/Atmega328Pinning.png)

![](./hardware/schematic.png)

![](./hardware/board.png)

![](./hardware/boardIRL.jpg)

5. Flashing the USBasp/V-USB bootloader
---------------------------------------

For the ATMEGA to be able to communicate directly through the USB (allowing it
to be recognized as a USB device and to reprogram it at will), we use a custom
bootloader from V-USB. The bootloader is the small piece of software, pretty
similar to the BIOS in computer, which initiates the rest of the software meant
to be run. 

In our case, if the "bootloader switch" is activated when the ATMEGA boot, it will
emulate a "USBasp" programmer and you'll be able to upload to change the program. 
If the "bootloader switch" is in the other position, the bootloader will launch
the program you uploaded on the ATMEGA - which can be as simple as blinking a LED,
or acting as a USB device (mouse, keyboard, MIDI, ...).

Flashing the bootloader is a sort of egg-and-chicken situation : to flash the
chip for the first time, you need another chip. This can be done for instance
using a Arduino UNO board. Fortunately, this is done once and for all, assuming 
the flashing is succesful ! The bootloader flashing setup is the following :

![](./doc/bootloaderFlashingSetup.png)

Once this setup is ready, you should flash a particular program "ArduinoISP"
(in-situ programming) on the Arduino board. It is available in the Arduino IDE
under File > Examples. Then you need to switch the Programmer in the IDE to
"Arduino as ISP" (Tools > Programmer > Arduino as ISP).

If we wanted to flash the regular Arduino bootloader, we would now go to Tools >
Flash bootloader. However, we want to flash our particular V-USB bootloader.
Therefore, we use the Makefile in this directory to do so :

```
# Compile
make bootloader
# Flash
make bootloader-flash
```

Once this is done, you should put back your Atmega on your board and test if it
worked. To do so, you can set your board in "Bootloader mode ON". In a terminal,
type :

```
dmesg -e -w
```

to display new messages from the kernel. Plug your board in. If it's working,
you should see some blabbling about a new USB device called USBasp (meaning it's
recognized as a USB chip programmer).

6. Flashing a dummy Midi Controller firmware
--------------------------------------------

7. Adding switches and potentiometers
-------------------------------------

8. Put all this in a nice case
------------------------------

[MakerCase](http://www.makercase.com/)

![](./case/case.png)

9. Profit !
-----------

References, inspiration, credits, links
---------------------------------------

- USBaspLoader https://github.com/baerwolf/USBaspLoader
- V-USB https://www.obdev.at/products/vusb/index.html

- USnooBie kit http://www.eleccelerator.com/usnoobie/index.php
- More on USnooBie kit http://wiki.seeedstudio.com/wiki/Usnoobie_Kit

- http://www.instructables.com/id/Custom-Arduino-MIDI-Controller/?ALLSTEPS
- http://www.instructables.com/id/USB-MIDI-Controller/?ALLSTEPS

- http://codeandlife.com/2012/01/22/avr-attiny-usb-tutorial-part-1/

