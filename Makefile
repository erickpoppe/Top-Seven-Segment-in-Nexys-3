# Xilinx ISE Command Line Build System for Nexys 3
# Engineer: Erick Poppe

# Project settings
PROJECT = top_seven_seg
TOP_MODULE = top_seven_seg
PART = xc6slx16-3-csg324

# Directories
RTL_DIR = rtl
CONSTRAINTS_DIR = constraints
BUILD_DIR = build

# Source Files
VHDL_SRC = $(RTL_DIR)/$(PROJECT).vhd
UCF_SRC = $(CONSTRAINTS_DIR)/nexys3.ucf

all: $(BUILD_DIR)/$(PROJECT).bit

$(BUILD_DIR)/$(PROJECT).bit: $(VHDL_SRC) $(UCF_SRC)
	@mkdir -p $(BUILD_DIR)
	@echo "=== RUNNING SYNTHESIS (XST) ==="
	@echo "run -ifn $(PROJECT).prj -ifmt mixed -ofn $(BUILD_DIR)/$(PROJECT).ngc -ofmt NGC -p $(PART) -top $(TOP_MODULE)" > $(BUILD_DIR)/xst.scr
	cd $(BUILD_DIR) && xst -ifn xst.scr
	
	@echo "=== RUNNING TRANSLATE (NGDBUILD) ==="
	cd $(BUILD_DIR) && ngdbuild -p $(PART) -uc ../$(UCF_SRC) $(PROJECT).ngc $(PROJECT).ngd
	
	@echo "=== RUNNING MAP ==="
	cd $(BUILD_DIR) && map -p $(PART) -w -logic_opt off -ol high -t 1 -xt 0 -register_duplication off -r 4 -global_opt off -mt off -ir off -pr off -lc off -power off -o $(PROJECT)_map.ncd $(PROJECT).ngd $(PROJECT).pcf
	
	@echo "=== RUNNING PLACE & ROUTE (PAR) ==="
	cd $(BUILD_DIR) && par -w -ol high -mt off $(PROJECT)_map.ncd $(PROJECT).ncd $(PROJECT).pcf
	
	@echo "=== GENERATING BITSTREAM (BITGEN) ==="
	cd $(BUILD_DIR) && bitgen -w -g StartUpClk:JtagClk $(PROJECT).ncd $(PROJECT).bit $(PROJECT).pcf

flash: $(BUILD_DIR)/$(PROJECT).bit
	@echo "=== FLASHING BOARD VIA ADEPT2 ==="
	djtgcfg prog -d Nexys3 -i 0 -f $(BUILD_DIR)/$(PROJECT).bit

clean:
	rm -rf $(BUILD_DIR) xst.srp

