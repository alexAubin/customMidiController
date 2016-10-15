###############################################################################
#
# Based on Arduino Makefile  http://ed.am/dev/make/arduino-mk
# Customized by Alex.
#
###############################################################################

MAIN_FILE  = main.cpp

# Microcontroller configuration : check this match yours !

BOARD_BUILD_MCU     = atmega328p
BOARD_BUILD_FCPU    = 12000000
BOARD_BUILD_VARIANT = standard

# Uploader configuration

UPLOAD_PROTOCOL = usbasp
UPLOAD_SPEED    = 19200
UPLOAD_PORT     = usb

# Compiler

CC      = avr-gcc
CXX     = avr-g++
AR      = avr-ar
OBJCOPY = avr-objcopy
AVRDUDE = avrdude
AVRSIZE = avr-size

# Arduino library stuff

ARDUINODIR = /usr/share/arduino/

###############################################################################
# Pathes, flags and stuff
###############################################################################

# Default arduino version

ARDUINOCONST = 100

# Target and sources

TARGET := $(basename $(MAIN_FILE))
SOURCES := $(wildcard *.c *.cc *.cpp lib/*/*.cpp lib/*/*.c lib/*/*.S)

# Automatically determine included libraries

LIBRARIES := $(filter $(notdir $(wildcard $(ARDUINODIR)/libraries/*)), \
	$(shell sed -ne "s/^ *\# *include *[<\"]\(.*\)\.h[>\"]/\1/p" $(SOURCES)))


# Check arduino folder is correct

ifeq "$(wildcard $(ARDUINODIR)/hardware/arduino/boards.txt)" ""
$(error ARDUINODIR is not set correctly; arduino software not found)
endif

# Default path for avr tools

AVRTOOLSPATH := $(subst :, , $(PATH))
AVRTOOLSPATH += $(ARDUINODIR)/hardware/tools
AVRTOOLSPATH += $(ARDUINODIR)/hardware/tools/avr/bin

# Files

TARGET := $(if $(TARGET),$(TARGET),a.out)
OBJECTS := $(addsuffix .o, $(basename $(SOURCES)))
DEPFILES := $(patsubst %, .dep/%.dep, $(SOURCES))
ARDUINOCOREDIR := $(ARDUINODIR)/hardware/arduino/cores/arduino
ARDUINOLIB := .lib/arduino.a
ARDUINOLIBLIBSDIR := $(ARDUINODIR)/libraries
ARDUINOLIBLIBSPATH := $(foreach lib, $(LIBRARIES), \
	$(ARDUINODIR)/libraries/$(lib)/ $(ARDUINODIR)/libraries/$(lib)/utility/ )
ARDUINOLIBOBJS := $(foreach dir, $(ARDUINOCOREDIR) $(ARDUINOLIBLIBSPATH), \
	$(patsubst %, .lib/%.o, $(wildcard $(addprefix $(dir)/, *.c *.cpp))))

# Flags

OPTIMIZATION := -O1
CPPFLAGS := $(OPTIMIZATION) -Wall -fno-exceptions -ffunction-sections -fdata-sections
CPPFLAGS += -funsigned-char -funsigned-bitfields -fpack-struct -fshort-enums
CPPFLAGS += -mmcu=$(BOARD_BUILD_MCU)
CPPFLAGS += -DF_CPU=$(BOARD_BUILD_FCPU) -DARDUINO=$(ARDUINOCONST)
CPPFLAGS += -I. -I./lib/*/ -I$(ARDUINOCOREDIR)
CPPFLAGS += -I$(ARDUINODIR)/hardware/arduino/variants/$(BOARD_BUILD_VARIANT)/
CPPFLAGS += $(addprefix -I$(ARDUINODIR)/libraries/, $(LIBRARIES))
CPPFLAGS += $(patsubst %, -I$(ARDUINODIR)/libraries/%/utility, $(LIBRARIES))
CPPDEPFLAGS = -MMD -MP -MF .dep/$<.dep
CPPINOFLAGS := -x c++ -include $(ARDUINOCOREDIR)/Arduino.h
AVRDUDEFLAGS := $(addprefix -C , $(AVRDUDECONF)) -DV
AVRDUDEFLAGS += -p $(BOARD_BUILD_MCU) -c $(UPLOAD_PROTOCOL) -b $(UPLOAD_SPEED) -P $(UPLOAD_PORT)
LINKFLAGS := $(OPTIMIZATION) -Wl,--gc-sections -mmcu=$(BOARD_BUILD_MCU) 

# Include dependencies

ifneq "$(MAKECMDGOALS)" "clean"
-include $(DEPFILES)
endif

###############################################################################
# Targets
###############################################################################

.PHONY:	default everything all hex upload clean bootloader bootloader-flash

default: hex

everything: clean hex upload

all: everything

hex: $(TARGET).hex

upload:
	@echo " "
	@echo "#######################"
	@echo " Uploading to board..."
	@echo "#######################"
	@echo " "
	su root --command "$(AVRDUDE) $(AVRDUDEFLAGS) -v -F -B 1 -U flash:w:$(TARGET).hex"

clean:
	@echo " "
	@echo "#######################"
	@echo " Cleaning stuff..."
	@echo "#######################"
	@echo " "
	rm -f $(OBJECTS) $(TARGET).elf $(TARGET).hex $(ARDUINOLIB) *~
	rm -rf .lib .dep

bootloader:
	@echo " "
	@echo "#######################"
	@echo " Compiling USBasp bootloader..."
	@echo " Note : this Makefile passed the following parameters to the bootloader's Makefile :"
	@echo " DEVICE = $(BOARD_BUILD_MCU)"
	@echo " F_CPU  = $(BOARD_BUILD_FCPU) (Hz)"
	@echo "#######################"
	@echo " "
	$(MAKE) -C bootloader clean
	$(MAKE) -C bootloader firmware F_CPU=$(BOARD_BUILD_FCPU) DEVICE=$(BOARD_BUILD_MCU) 

bootloader-flash:
	@echo " "
	@echo "#######################"
	@echo " Attempting to flash bootloader using Arduino as in-situ programmer (AVRisp)..."
	@echo "#######################"
	@echo " "
	$(MAKE) -C bootloader fuse  DEVICE=$(BOARD_BUILD_MCU) PROGRAMMER='-c avrisp -P `ls /dev/ttyACM*` -b $(UPLOAD_SPEED)' LOCKOPT='-U lock:w:0xcf:m'
	$(MAKE) -C bootloader flash DEVICE=$(BOARD_BUILD_MCU) PROGRAMMER='-c avrisp -P `ls /dev/ttyACM*` -b $(UPLOAD_SPEED)' LOCKOPT='-U lock:w:0xcf:m'

###############################################################################
# Building rules
###############################################################################

$(TARGET).hex: $(TARGET).elf
	$(OBJCOPY) -O ihex -R .eeprom $< $@

.INTERMEDIATE: $(TARGET).elf

$(TARGET).elf: $(ARDUINOLIB) $(OBJECTS)
	$(CC) $(LINKFLAGS) $(OBJECTS) $(ARDUINOLIB) -o $@

%.o: %.c
	mkdir -p .dep/$(dir $<)
	$(COMPILE.cpp) $(CPPDEPFLAGS) -o $@ $<

%.o: %.cpp
	mkdir -p .dep/$(dir $<)
	$(COMPILE.cpp) $(CPPDEPFLAGS) -o $@ $<

%.o: %.cc
	mkdir -p .dep/$(dir $<)
	$(COMPILE.cpp) $(CPPDEPFLAGS) -o $@ $<

%.o: %.C
	mkdir -p .dep/$(dir $<)
	$(COMPILE.cpp) $(CPPDEPFLAGS) -o $@ $<

%.o: %.ino
	mkdir -p .dep/$(dir $<)
	$(COMPILE.cpp) $(CPPDEPFLAGS) -o $@ $(CPPINOFLAGS) $<

%.o: %.pde
	mkdir -p .dep/$(dir $<)
	$(COMPILE.cpp) $(CPPDEPFLAGS) -o $@ -x c++ -include $(ARDUINOCOREDIR)/Arduino.h $<

%.o: %.S
	$(COMPILE.c) $(CPPDEPFLAGS) -x assembler-with-cpp -c $< -o $@

# Rules for the Arduino lib

$(ARDUINOLIB): $(ARDUINOLIBOBJS)
	$(AR) rcs $@ $?

.lib/%.c.o: %.c
	mkdir -p $(dir $@)
	$(COMPILE.c) -o $@ $<

.lib/%.cpp.o: %.cpp
	mkdir -p $(dir $@)
	$(COMPILE.cpp) -o $@ $<

.lib/%.cc.o: %.cc
	mkdir -p $(dir $@)
	$(COMPILE.cpp) -o $@ $<

.lib/%.C.o: %.C
	mkdir -p $(dir $@)
	$(COMPILE.cpp) -o $@ $<

