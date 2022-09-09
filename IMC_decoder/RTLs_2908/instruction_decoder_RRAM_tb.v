
`timescale 1ns / 1ps



//	Include definition of the control signals

module  instruction_decoder_RRAM_tb ();


parameter INSTRUCTION_SIZE = 32 ; 
parameter ARRAY_SIZE = 16 ; 

reg 		clk , rst ;
reg 	[INSTRUCTION_SIZE-1:0]	instruction;


wire  [ARRAY_SIZE-1:0] IN0_BL;
wire  [ARRAY_SIZE-1:0] IN1_BL;
wire  [ARRAY_SIZE-1:0] IN0_WL;
wire  [ARRAY_SIZE-1:0] IN1_WL;
wire  [ARRAY_SIZE-1:0] IN0_SL;
wire  [ARRAY_SIZE-1:0] IN1_SL;
wire  ENABLE_WL;
wire  ENABLE_SL;
wire  ENABLE_BL;
wire  [2:0]S_MUX1;
wire  [2:0]S_MUX2;
wire  SEL_MUX1_TO_VSA;
wire  SEL_MUX1_TO_CSA;
wire  SEL_MUX1_TO_ADC;
wire  SEL_MUX2_TO_VSA;
wire  SEL_MUX2_TO_CSA;
wire  SEL_MUX2_TO_ADC;
wire  PRE ;
wire  CLK_EN_ADC1;
wire  CLK_EN_ADC2;
wire  SAEN_CSA1;
wire  SAEN_CSA2;



instruction_decoder_RRAM uut(.clk(clk),  
.rst(rst), 
.instruction(instruction), 
.IN0_BL(IN0_BL),
.IN1_BL(IN1_BL),
.IN0_WL(IN0_WL),
.IN1_WL(IN1_WL),
.IN0_SL(IN0_SL),
.IN1_SL(IN1_SL),
.ENABLE_WL(ENABLE_WL),
.ENABLE_SL(ENABLE_SL),
.ENABLE_BL(ENABLE_BL),
.S_MUX1(S_MUX1),
.S_MUX2(S_MUX2),
.SEL_MUX1_TO_VSA(SEL_MUX1_TO_VSA),
.SEL_MUX1_TO_CSA(SEL_MUX1_TO_CSA),
.SEL_MUX1_TO_ADC(SEL_MUX1_TO_ADC),
.SEL_MUX2_TO_VSA(SEL_MUX2_TO_VSA),
.SEL_MUX2_TO_CSA(SEL_MUX2_TO_CSA),
.SEL_MUX2_TO_ADC(SEL_MUX2_TO_ADC),
.PRE(PRE), 
.CLK_EN_ADC1(CLK_EN_ADC1),
.CLK_EN_ADC2(CLK_EN_ADC2),
.SAEN_CSA1(SAEN_CSA1),
.SAEN_CSA2(SAEN_CSA2) 
) ;



	initial begin
		// Initialize Inputs

		clk = 0 ; 
		rst  = 1 ;
		instruction = 32'b10000000000000000000000000010101 ;

// Write instruction on COL=0101=5 , ROW=0001=1 

#2

		rst  = 0 ;



	#10 
		rst  = 1 ;
		instruction = 32'b00000000000000000000000000010101; 

//// Read instruction on COL=0101=5 , ROW=0001=1 

	#10 
		instruction = 32'b00010000000000000000000000010101; 
//
//
// Read instruction on COL=0110=6 , ROW=0010=2 

	#10 
		instruction = 32'b00010000000000000000000000100111; 


// Read instruction on COL=1010=10 , ROW=0010=2 

	#10 
		instruction = 32'b00010000000000000000000000101010; 

// Read instruction on COL=1010=10 , ROW=1011=11 

	#10 
		instruction = 32'b00010000000000000000000010111010; 

// Write instruction on COL=1110=14 , ROW=0111=7 


	#10 
		instruction = 32'b0000000000000000000000001111110; 



	#150 $finish;

  	  end


// outputs according to the technique


	 always  begin
    #5 clk = !clk;  
	 end
	 
initial  begin
    $dumpfile ("instruction_decoder_RRAM_tb.vcd"); 
    $dumpvars; 
  end 


endmodule

