
set_units -time ns
create_clock [get_ports clk]  -name CLK  -period 4

set_false_path -from [get_ports rtsn]

#set_multi_cycle_path -from [get_ports rtsn] -setup 5 
#set_multi_cycle_path -from [get_ports rtsn] -hold 4
