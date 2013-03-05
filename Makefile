DEVICE = attiny85
F_CPU = 16500000L

CC = avr-gcc
OBJCOPY = avr-objcopy
OFLAGS = -O ihex -R .eeprom
CFLAGS = -Ilib -Iusbdrv -I. -DF_CPU=$(F_CPU) -mmcu=$(DEVICE) -Os -DDEBUG_LEVEL=0
PROGDIR = commandline
PROG = $(PROGDIR)/micronucleus
PFLAGS = --run --type intel-hex

COMPILE = $(CC) $(CFLAGS)

usbmouse_OBJECTS = usbdrv/usbdrv.o usbdrv/usbdrvasm.o usbdrv/osccal.o usbmouse.o
blink_OBJECTS = blink.o
OBJECTS = $(usbmouse_OBJECTS) $(main_OBJECTS)

TARGETS = blink usbmouse

HEX_TARGETS = $(addsuffix .hex, $(TARGETS))
OUT_TARGETS = $(addsuffix .out, $(TARGETS))

# Generic rule for compiling C files:
.c.o:
	$(COMPILE) -c $< -o $@

# Generic rule for compiling CPP files:
.cpp.o:
	$(COMPILE) -c $< -o $@

# Generic rule for assembling Assembler source files:
.S.o:
	$(COMPILE) -c $< -o $@

# Generic rule for compiling C to assembler, used for debugging only.
.c.s:
	$(COMPILE) -S $< -o $@

.SECONDEXPANSION: %.out
.PHONY: all %.flash clean cleanprog cleanall

%.out: $$($$*_OBJECTS)
	$(COMPILE) -o $@ $^

%.hex: $$*.out
	rm -f $@
	$(OBJCOPY) $(OFLAGS) $*.out $@
	avr-size $@

all: $(HEX_TARGETS)

$(PROG):
	cd $(PROGDIR) && make

%.flash: $$*.hex $(PROG)
	$(PROG) $(PFLAGS) $<

clean:
	rm -f $(OUT_TARGETS) $(HEX_TARGETS) $(OBJECTS)

cleanprog:
	cd $(PROGDIR) && make clean

cleanall: clean cleanprog
