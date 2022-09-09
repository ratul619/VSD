# add_waves.tcl 
set sig_list [list clk \
is_MAC_ins \
start_MAC_OP \
start_IF_Address \
wishbone_address_to_read_input_buffer \
data_out_instruction_memory \
rd_cs_input_buffer \
rd_en_input_buffer \
data_out_input_buffer \
PRE \
halt_IM \
counter_mac \
num_MAC_OP \
START_MAC_ADC \
start_MAC_neg_cycle \
SEL_MUX1_TO_ADC \
SEL_MUX2_TO_ADC \
S_MUX1 \
S_MUX2 \
ENABLE_BL \
ENABLE_WL \
ENABLE_SL \
IN0_WL \
IN1_WL \
]
gtkwave::addSignalsFromList $sig_list
