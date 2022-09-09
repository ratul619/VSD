# add_waves.tcl 
set sig_list [list clk \
clk \
rst \
is_IDLE \
is_write_ins \
is_read_ins \
is_MAC_ins \
halt_IM \
IP_address_to_read_input_buffer \
start_IF_address \
end_IF_address \
rd_cs_input_buffer \
rd_en_input_buffer \
data_out_input_buffer \
PRE \
START_MAC \
start_neg_MAC \
IN0_WL \
IN1_WL \
IP_address_to_write_output_buffer \
IP_data_in_output_buffer \
CLK_EN_ADC \
]


gtkwave::addSignalsFromList $sig_list
