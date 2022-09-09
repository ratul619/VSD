# add_waves.tcl 
set sig_list [list clk \
clk \
rst \
is_IDLE \
is_write_ins \
is_read_ins \
DATA_TO_WRITE \
IN0_BL \
IN1_BL \
IN0_SL \
IN1_SL \
IN0_WL \
IN1_WL \
COL_ADDR_W \
ROW_ADDR_W \
COL_ADDR_R \
ROW_ADDR_R \
ENABLE_WL \
ENABLE_SL \
ENABLE_BL \
PRE \
SEL_MUX1_TO_CSA \
SEL_MUX2_TO_CSA \
S_MUX1 \
S_MUX2 \
ENABLE_WL \
ENABLE_SL \
ENABLE_BL \
SAEN_CSA1 \
SAEN_CSA2 \
]


gtkwave::addSignalsFromList $sig_list
