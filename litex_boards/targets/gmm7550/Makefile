TARGET := usb3_test

GHDL          := ghdl
RM            := rm -f
VHDL_STANDARD := 08

VHDL_FILES := # gatemate_pkg.vhd
VHDL_FILES += wb_ccserdes_reg.vhd
VHDL_FILES += $(TARGET).vhd

WORK_LIB := work-obj$(VHDL_STANDARD).cf

.PHONY: all clean

all: $(TARGET).v

$(WORK_LIB): $(VHDL_FILES)
	for f in $(VHDL_FILES); do \
	$(GHDL) -a --std=$(VHDL_STANDARD) $$f; \
	done

clean:
	$(RM) $(TARGET).v
	$(RM) $(WORK_LIB)

$(TARGET).v: $(WORK_LIB)
	$(GHDL) --synth  --std=$(VHDL_STANDARD) \
	--out=verilog -o=$@ $(basename $(notdir $@))
