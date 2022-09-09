set ::env(DESIGN_NAME) "RRAM_CONTROLLER"

set ::env(DESIGN_IS_CORE) 0
set ::env(PDK) {sky130B}
#set ::env(VERILOG_FILES_BLACKBOX) $::env(DESIGN_DIR)/RRAM_ANALOG.v
set ::env(VERILOG_FILES) [glob  $::env(DESIGN_DIR)/src/*.v $::env(DESIGN_DIR)/src/*.h]

set ::env(CLOCK_PERIOD) "10.000"
set ::env(CLOCK_PORT) "clk"
set ::env(DPL_CELL_PADDING) 2

set ::env(EXTRA_LIBS) $::env(DESIGN_DIR)/RRAM_ANALOG.lib

#set ::env(EXTRA_LEFS) $::env(DESIGN_DIR)/RRAM_ANALOG.lef
set ::env(EXTRA_GDS_FILES) $::env(DESIGN_DIR)/RRAM_ANALOG.GDS

set ::env(FP_SIZING) "absolute"
set ::env(DIE_AREA) {0.0 0.0 1800 1800 }

set ::env(PL_TARGET_DENSITY) {0.20}

#set ::env(MACRO_PLACEMENT_CFG) $::env(DESIGN_DIR)/macro.cfg
set ::env(SYNTH_NO_FLAT) {0}
set ::env(GLB_RESIZER_TIMING_OPTIMIZATIONS) {0}
#set ::env(PL_BASIC_PLACEMENT) {1}

#set ::env(GRT_OBS) "\
		li1 400 400 1497.410 1735.730, \
		met1 400 400 1497.410 1735.730, \
		met2 400 400 1497.410 1735.730, \
		met3 400 400 1497.410 1735.730"

set ::env(RT_MAX_LAYER) {met4}

set ::env(DIODE_INSERTION_STRATEGY) {4}
set ::env(GRT_ALLOW_CONGESTION) {1}
