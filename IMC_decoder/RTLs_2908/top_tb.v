`timescale 1ns / 1ps
module top_tb  () ; 


RRAM_CONTROLLER uut (.clk, 
.rst, 
.wishbone_wr_cs_instruction_memory, 
.wishbone_wr_en_instruction_memory, 
.wishbone_empty_instruction_memory,
.wishbone_full_instruction_memory ,
.wishbone_wr_cs_input_buffer, 
.wishbone_wr_en_input_buffer, 
.wishbone_empty_input_buffer, 
.wishbone_full_input_buffer ,
.enable_PC_IM,
.wishbone_data_in_instruction_memory,
.wishbone_data_in_input_buffer,
.start_PC_IM_address); 



 
parameter INSTRUCTION_SIZE = 32 ; 
parameter ARRAY_SIZE = 16 ; 
parameter IF_SIZE = 32; 
parameter ADDR_SIZE_IM = 7; 



reg		clk , rst , enable_PC_IM ;


reg [ADDR_SIZE_IM-1:0]start_PC_IM_address;


reg wishbone_wr_cs_instruction_memory ; 
reg wishbone_wr_en_instruction_memory ; 
wire  wishbone_empty_instruction_memory ;
wire wishbone_full_instruction_memory  ;


reg [INSTRUCTION_SIZE-1:0]wishbone_data_in_instruction_memory;
reg [ARRAY_SIZE-1:0]wishbone_data_in_input_buffer;



reg wishbone_wr_cs_input_buffer ; 
reg wishbone_wr_en_input_buffer ; 
wire  wishbone_empty_input_buffer ;
wire  wishbone_full_input_buffer  ;





integer i;



	initial begin
		// Initialize Inputs

		clk = 0 ; 
		rst  = 1 ;

// Write instruction on COL=0101=5 , ROW=0001=1 

#2

		rst  = 0 ;
		enable_PC_IM = 0 ; 


	#10 
		rst  = 1 ;
		enable_PC_IM = 1; 
		start_PC_IM_address = 2;
		
//	for ( i = 0 ;  i < 50 ; i = i +1 ) begin  
//
//	#10 start_PC_IM_address++;
//
//	
//	end 



	#600 $finish;

  	  end


// outputs according to the technique


	 always  begin
    #5 clk = !clk;  
	 end
	 
initial  begin
    $dumpfile ("top_tb.vcd"); 
    $dumpvars; 
  end 





endmodule 
