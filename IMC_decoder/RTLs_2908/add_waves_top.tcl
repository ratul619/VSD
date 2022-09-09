# add_waves.tcl 
set sig_list [list clk \
rst \
enable_PC_IM \
start_PC_IM_address \
enable_IM \
is_write_ins  \
is_read_ins \
is_MAC_ins \
start_MAC_OP \
ROW_START_MAC \
ROW_END_MAC \
COL_START_MAC \
COL_END_MAC \
start_IF_address \
halt_IM \
wishbone_address_to_read_instruction_memory \
data_out_instruction_memory \
ENABLE_WL \
ENABLE_BL \
ENABLE_SL \
PRE \
wishbone_address_to_read_instruction_memory \
wishbone_address_to_read_input_buffer_memory \
wishbone_rd_cs_input_buffer \
wishbone_rd_en_input_buffer \
data_out_input_buffer \
start_IF_Address \
counter_mac \
data_out_input_buffer_masked_IN0_WL \
data_out_input_buffer_masked_IN1_WL \
ENABLE_BL \
ENABLE_SL \
ENABLE_WL
]
gtkwave::addSignalsFromList $sig_list
