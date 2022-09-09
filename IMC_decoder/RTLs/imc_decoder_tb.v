
`timescale 1ns / 1ps



//	Include definition of the control signals

module imc_decoder_tb  ();


parameter INSTRUCTION_SIZE = 32 ; 
parameter DATA_MEM_SIZE = 16 ; 
parameter ADDR_MEM_SIZE = 4; 

reg 		clk , rst ;
reg 	[INSTRUCTION_SIZE-1:0]	instruction;


// common output 

wire  		CS;
wire  		WE;
wire  		OE;
wire  	[DATA_MEM_SIZE-1:0] DATA_TO_MEM	;
reg 	        [DATA_MEM_SIZE-1:0] DATA_FROM_MEM	;
wire 	[ADDR_MEM_SIZE-1:0] ADDR_MEM1	;
wire 	[ADDR_MEM_SIZE-1:0] ADDR_MEM2	;
wire 	[ADDR_MEM_SIZE-1:0] ADDR_MEM3	;
wire 	[DATA_MEM_SIZE-1:0] SAEN	;

// MIG special 

wire	EXECUTE_MIG	; 

// MAGIC special 
wire	EXECUTE_MAGIC	;

// IMPLY special 
wire	EXECUTE_IMPLY	; 

// 
output	EXECUTE_BITWISE	;


wire [1:0] exec_logical_bitwise ; 

imc_decoder	  uut (
.clk(clk),  
.rst(rst) , 
.instruction(instruction) , 
.CS(CS) , 
.WE(WE) , 
.OE(OE) , 
.ADDR_MEM1(ADDR_MEM1) ,
.ADDR_MEM2(ADDR_MEM2)  , 
.ADDR_MEM3(ADDR_MEM3) , 
.DATA_TO_MEM(DATA_TO_MEM) ,
.DATA_FROM_MEM(DATA_FROM_MEM)  , 
.SAEN(SAEN) , 
.EXECUTE_MIG(EXECUTE_MIG) , 
.EXECUTE_MAGIC(EXECUTE_MAGIC) ,
.EXECUTE_IMPLY(EXECUTE_IMPLY) ,
.EXECUTE_BITWISE(EXECUTE_BITWISE)  , 
.exec_logical_bitwise(exec_logical_bitwise)
);



	initial begin
		// Initialize Inputs

		clk = 0 ; 
		rst  = 0 ;
		instruction = 0 ;
		DATA_FROM_MEM= 0	;

	#20 
		rst  = 1 ;
		instruction = 32'b10000011000000000000000000000000; //Majority read 


	#35 

	instruction =         32'b10111000000111100000000000000000; // Majority Write 


	#10 

	instruction =         32'b11111000000111100000000000000000; // bitwise and



	#10 
	 instruction = 32'b00011010100000000000000000000000; //IMPLY exec


	#10 

	 instruction = 32'b00111000000000000000000000000000; // IMPLY copy 


	#100 $finish;

  	  end


// outputs according to the technique


	 always  begin
    #5 clk = !clk;  
	 end
	 
initial  begin
    $dumpfile ("imc_decoder_tb.vcd"); 
    $dumpvars; 
  end 


endmodule

