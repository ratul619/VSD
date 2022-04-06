# User config
set ::env(DESIGN_NAME) top

# Change if needed
set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v  $::env(DESIGN_DIR)/src/*.sv]

# Fill this
set ::env(CLOCK_PERIOD) "10.0"
set ::env(CLOCK_PORT) "clk"

set ::env(FP_CORE_UTIL) 35
set ::env(FP_PDN_VOFFSET) 0
set ::env(FP_PDN_VPITCH) 30

set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}

set ::env(BASE_SDC_FILE) $::env(DESIGN_DIR)/src/top.sdc

set ::env(EXTRA_LIBS) $::env(DESIGN_DIR)/macros/sram_64_128_sky130A_SS_1p8V_25C.lib

set ::env(EXTRA_LEFS) $::env(DESIGN_DIR)/macros/sram_64_128_sky130A.lef
#set ::env(MACRO_PLACEMENT_CFG) $::env(DESIGN_DIR)/macro.cfg
#set ::env(FP_PDN_CHECK_NODES) 0
set ::env(VDD_PIN) {VPWR vdd}
set ::env(GND_PIN) {VGND gnd}

set ::env(GLB_RT_OVERFLOW_ITERS) {5}


set ::env(PL_MACRO_CHANNEL) {50 50}
set ::env(PL_MACRO_HALO) {50 50}

set ::env(FP_PDN_CHECK_NODES) 0

set ::env(CELL_PAD) {2}

set ::env(DIODE_INSERTION_STRATEGY) 4

#set ::env(DIODE_PADDING) 0

