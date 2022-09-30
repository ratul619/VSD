`timescale 1ns / 1ps
module top_tb  () ; 


RRAM_CONTROLLER uut (
.clk, 
.rst, 
.wishbone_data_in,
.wishbone_data_out,
.wishbone_address_bus,
.wbs_we_i,
.enable_IM,
.ADC_OUT0,
.ADC_OUT1,
.ADC_OUT2,
.CLK_EN_ADC,
.CSA,
.ENABLE_ADC,
.ENABLE_BL,
.ENABLE_CSA,
.ENABLE_SL,
.ENABLE_WL,
.IN0_BL,
.IN0_SL,
.IN0_WL,
.IN1_BL,
.IN1_SL,
.IN1_WL,
.PRE,
.SAEN_CSA
); 



 
parameter INSTRUCTION_SIZE = 32 ; 
parameter ARRAY_SIZE = 16 ; 
parameter IF_SIZE = 32; 
parameter ADDR_SIZE_IM = 7; 



reg		clk , rst  , enable_IM; 

reg [31:0]wishbone_data_in;
wire [31:0]wishbone_data_out;
reg [31:0]wishbone_address_bus;
reg wbs_we_i;



wire   ENABLE_CSA;
wire   ENABLE_ADC;
wire   ENABLE_WL;
wire   ENABLE_SL;
wire   ENABLE_BL;
wire   PRE ; 
wire   [1:0]CLK_EN_ADC;
wire   SAEN_CSA;

reg   [15:0]CSA;
reg   [15:0]ADC_OUT0;
reg   [15:0]ADC_OUT1;
reg   [15:0]ADC_OUT2;

wire  [15:0]IN0_WL;
wire  [15:0]IN1_WL;
wire  [15:0]IN0_BL;
wire  [15:0]IN1_BL;
wire  [15:0]IN0_SL;
wire  [15:0]IN1_SL;





integer i;



	initial begin
		// Initialize Inputs

		clk = 0 ; 
		rst  = 1 ;

// Write instruction on COL=0101=5 , ROW=0001=1 

#2

		rst  = 0 ;
		enable_IM = 0 ; 


	#10 
		rst  = 1 ;
		enable_IM = 1; 
		
//	for ( i = 0 ;  i < 50 ; i = i +1 ) begin  
//
//	#10 start_PC_IM_address++;
//
//	
//	end 



	#1000 $finish;

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
