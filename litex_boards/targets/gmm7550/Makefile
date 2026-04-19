TARGETS := usb3_test cy7c1049

GHDL          := ghdl
RM            := rm -f
VHDL_STANDARD := 08

CC_LIB_FILES := gatemate_pkg.vhd

VHDL_FILES := wb_ccserdes_reg.vhd serdes_reset_controller.vhd
VHDL_FILES += $(addsuffix .vhd,$(TARGETS))

CC_LIB_NAME := cc
CC_LIB   := $(CC_LIB_NAME)-obj$(VHDL_STANDARD).cf

WORK_LIB := work-obj$(VHDL_STANDARD).cf

.PHONY: all clean

TARGETS_V := $(addsuffix .v,$(TARGETS))

all: $(TARGETS_V)

$(CC_LIB): $(CC_LIB_FILES)
	for f in $(CC_LIB_FILES); do \
	$(GHDL) -a --std=$(VHDL_STANDARD) --work=$(CC_LIB_NAME) $$f; \
	done

$(WORK_LIB): $(VHDL_FILES) $(CC_LIB)
	for f in $(VHDL_FILES); do \
	$(GHDL) -a --std=$(VHDL_STANDARD) $$f; \
	done

clean:
	$(RM) $(TARGETS_V)
	$(RM) *.o
	$(RM) $(WORK_LIB)
	$(RM) $(CC_LIB)

%.v: $(WORK_LIB) $(CC_LIB)
	$(GHDL) --synth  --std=$(VHDL_STANDARD) \
	--vendor-library=$(CC_LIB_NAME) \
	--out=verilog -o=$@ $(basename $(notdir $@))
