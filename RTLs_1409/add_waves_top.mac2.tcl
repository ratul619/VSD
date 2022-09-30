# add_waves.tcl 
set sig_list [list clk \
clk \
rst \
enable_IM \
is_IDLE \
is_write_ins_base \
is_write_ins_fpnv \
is_read_ins \
is_MAC_ins \
halt_IM \
state \
counter \
address_to_read_instruction_memory \
data_out_instruction_memory \
data_out_instruction_memory_reg1 \
data_out_instruction_memory_reg2 \
data_out_instruction_memory_reg3 \
data_out_instruction_memory_reg4 \
ROW_ADDR_R \
COL_ADDR_W \
ROW_ADDR_W \
address_output_buffer \
read_address_bus_input_buffer \
input_buffer_data_out \
num_MAC_OP \
ENABLE_ADC \
ENABLE_BL \
ENABLE_CSA \
ENABLE_SL \
ENABLE_WL \
IN0_BL \
IN0_SL \
IN0_WL \
IN1_BL \
IN1_SL \
IN1_WL \
PRE \
SAEN_CSA \
CLK_EN_ADC \
COL_SELECT_FOR_MAC_ADC \
]


gtkwave::addSignalsFromList $sig_list
