`include	"opcodes.h"
`timescale 1ns / 1ps

//	Include definition of the control signals

module instruction_decoder_RRAM (clk,  rst , instruction, 
IN0_BL,
IN1_BL,
IN0_WL,
IN1_WL,
IN0_SL,
IN1_SL,
ENABLE_WL,
ENABLE_SL,
ENABLE_BL,
S_MUX1,
S_MUX2,
SEL_MUX1_TO_VSA,
SEL_MUX1_TO_CSA,
SEL_MUX1_TO_ADC,
SEL_MUX2_TO_VSA,
SEL_MUX2_TO_CSA,
SEL_MUX2_TO_ADC,
PRE, 
CLK_EN_ADC1,
CLK_EN_ADC2,
SAEN_CSA1,
SAEN_CSA2,
mac_mux,
enable_IM,
COL_START_MAC,
COL_END_MAC,
ROW_START_MAC,
ROW_END_MAC
);


parameter INSTRUCTION_SIZE = 32 ; 
parameter ARRAY_SIZE = 16 ; 

parameter NUM_WL_ENABLE_MAC_OPS  = 4;

integer counter_MAC = ARRAY_SIZE/NUM_WL_ENABLE_MAC_OPS ; 


input		clk , rst , enable_IM ;
input	[INSTRUCTION_SIZE-1:0]	instruction;


parameter DEPTH_ARRAY = 4;


output reg [ARRAY_SIZE-1:0] IN0_BL;
output reg [ARRAY_SIZE-1:0] IN1_BL;
output reg [ARRAY_SIZE-1:0] IN0_WL;
output reg [ARRAY_SIZE-1:0] IN1_WL;
output reg [ARRAY_SIZE-1:0] IN0_SL;
output reg [ARRAY_SIZE-1:0] IN1_SL;
output reg ENABLE_WL;
output reg ENABLE_SL;
output reg ENABLE_BL;
output reg [2:0]S_MUX1;
output reg [2:0]S_MUX2;
output reg SEL_MUX1_TO_VSA;
output reg SEL_MUX1_TO_CSA;
output reg SEL_MUX1_TO_ADC;
output reg SEL_MUX2_TO_VSA;
output reg SEL_MUX2_TO_CSA;
output reg SEL_MUX2_TO_ADC;
output reg PRE ;
output reg CLK_EN_ADC1;
output reg CLK_EN_ADC2;
output reg SAEN_CSA1;
output reg SAEN_CSA2;

output reg mac_mux; 

integer COL_ADDR_W  = 0 ;
integer COL_ADDR_R  = 0 ;
integer ROW_ADDR_W  = 0 ;
integer ROW_ADDR_R  = 0 ;


reg is_read_ins;
reg is_write_ins;
reg is_MAC_ins;
reg is_PULSE_T_ins;
reg is_PULSE_V_ins;


output reg  [DEPTH_ARRAY-1:0]COL_START_MAC;
output reg  [DEPTH_ARRAY-1:0]COL_END_MAC;
output reg  [DEPTH_ARRAY-1:0]ROW_START_MAC;
output reg  [DEPTH_ARRAY-1:0]ROW_END_MAC;


reg [1:0]T_PULSE_OP_TYPE; 
reg [7:0]T_PULSE_MULTIPLIER; 



reg [1:0]V_PULSE_OP_TYPE; 
reg [1:0]V_PULSE_MUX_SEL; 


reg ENABLE_ARR_OP;
reg  [2:0]temp1;

reg is_read_neg_cycle;

integer testw =0;

integer i = 0; 

always @(posedge clk   or negedge rst  ) begin 


	if (!rst) begin 

 #2 COL_ADDR_W = 0 ;
 COL_ADDR_R = 0 ;
 ROW_ADDR_W = 0 ;
 ROW_ADDR_R = 0 ;
 is_write_ins = 0 ;
 is_MAC_ins = 0 ;
 is_PULSE_T_ins = 0 ;
 is_PULSE_V_ins = 0 ;
 is_read_neg_cycle = 0 ;
 COL_START_MAC = 0 ;
 COL_END_MAC = 0 ;
 ROW_START_MAC = 0 ;
 ROW_END_MAC = 0 ;
 T_PULSE_OP_TYPE = 0 ; 
 T_PULSE_MULTIPLIER = 0 ; 
 V_PULSE_OP_TYPE = 0 ; 
 V_PULSE_MUX_SEL = 0 ; 
 ENABLE_ARR_OP = 0 ; 
 mac_mux = 0 ; 

	end 

	else if (enable_IM)  begin 
			
case (instruction[31:28])
		`WRITE_RRAM :	// 
                begin
        #2      COL_ADDR_W = instruction[3:0];
                ROW_ADDR_W = instruction[7:4]; 
		testw = instruction[31:28] ; 

		ENABLE_ARR_OP = 1 ; 
		is_read_ins= 0 ;
		is_write_ins = 1 ;
		is_MAC_ins = 0 ;
		is_PULSE_T_ins = 0 ;
		is_PULSE_V_ins = 0 ;
 		mac_mux = 0 ; 


		

                end

		`READ_RRAM :	// 
                begin
        #2        COL_ADDR_R = instruction[3:0];
                ROW_ADDR_R = instruction[7:4];
		ENABLE_ARR_OP = 1 ; 

		is_read_ins= 1 ;
		is_write_ins = 0 ;
		is_MAC_ins = 0 ;
		is_PULSE_T_ins = 0 ;
		is_PULSE_V_ins = 0 ;
 		mac_mux = 0 ; 




                end 

		`MAC_OPERATION :	// 
                begin
		
	#2	COL_START_MAC =  instruction[15:12] ;
		COL_END_MAC =    instruction[11:8];
		ROW_START_MAC =  instruction[7:4] ;
		ROW_END_MAC = instruction[3:0] ;
		ENABLE_ARR_OP = 1 ; 

		is_read_ins= 0 ;
		is_write_ins = 0 ;
		is_MAC_ins = 1 ;
		is_PULSE_T_ins = 0 ;
		is_PULSE_V_ins = 0 ;
 		mac_mux = 1 ; 
		


                end 

		`CONF_T_PULSE_RRAM :	// 
                begin
		

	#2	T_PULSE_OP_TYPE =  instruction[9:8]; 
		T_PULSE_MULTIPLIER = instruction[7:0] ; 
		ENABLE_ARR_OP = 1 ; 


		is_read_ins= 0 ;
		is_write_ins = 0 ;
		is_MAC_ins = 0 ;
		is_PULSE_T_ins = 1 ;
		is_PULSE_V_ins = 0 ;
 		mac_mux = 0 ; 


                end 

		`CONF_V_PULSE_RRAM :	// 
                begin
		

	#2	V_PULSE_OP_TYPE =  instruction[3:2]; 
		V_PULSE_MUX_SEL = instruction[1:0] ; 
		ENABLE_ARR_OP = 1 ; 
		

		is_read_ins= 0 ;
		is_write_ins = 0 ;
		is_MAC_ins = 0 ;
		is_PULSE_T_ins = 0 ;
		is_PULSE_V_ins = 1 ;
 		mac_mux = 0 ; 


                end 



endcase




	end

	end


always @(posedge clk   or negedge rst  ) begin 

	if (!rst) begin 

#2	IN0_BL = '1 ; 
	IN1_BL = '1 ; 
	IN0_WL = '1 ; 
	IN1_WL = '1 ; 
	IN0_SL = '1 ; 
	IN1_SL = '1 ; 
	ENABLE_WL = 0 ; 
	ENABLE_SL = 0 ; 
	ENABLE_BL = 0 ; 
	S_MUX1 = 0 ; 
	S_MUX2 = 0 ; 
	SEL_MUX1_TO_VSA = 0 ; 
	SEL_MUX1_TO_CSA = 0 ; 
	SEL_MUX1_TO_ADC = 0 ; 
	SEL_MUX2_TO_VSA = 0 ; 
	SEL_MUX2_TO_CSA = 0 ; 
	SEL_MUX2_TO_ADC = 0 ; 
	PRE  = 1 ; 
	CLK_EN_ADC1 = 0 ; 
	CLK_EN_ADC2 = 0 ; 
	SAEN_CSA1 = 0 ; 
	SAEN_CSA2 = 0 ; 

	end 

	else begin 

///////////////////////////////////////////////////////////////////////////////////////////////////		
		if (ENABLE_ARR_OP) begin 

			if (is_write_ins) begin  

// All Enables are ON in write 

			#2	ENABLE_WL = 1 ; 
				ENABLE_SL = 1 ; 
				ENABLE_BL = 1 ; 

// All SEL passgates are OFF
	SEL_MUX1_TO_VSA = 0 ; 
	SEL_MUX1_TO_CSA = 0 ; 
	SEL_MUX1_TO_ADC = 0 ; 
	SEL_MUX2_TO_VSA = 0 ; 
	SEL_MUX2_TO_CSA = 0 ; 
	SEL_MUX2_TO_ADC = 0 ; 




// Assuming V[0] is the write voltage for all AMUXES

				for ( i = 0 ;  i < ARRAY_SIZE ; i = i +1 ) begin

					if (i  == COL_ADDR_W) begin 
			IN0_BL[i] =  0  ; 
			IN1_BL[i] =  0  ; 
			IN0_SL[i] =  0  ; 
			IN1_SL[i] =  0  ; 
			end else begin  
			IN0_BL[i] =  1  ; 
			IN1_BL[i] =  1  ; 
			IN0_SL[i] =  1  ; 
			IN1_SL[i] =  1  ; 
			end
								           end 


				for ( i = 0 ;  i < ARRAY_SIZE ; i = i +1 ) begin  
					if ( i == ROW_ADDR_W ) begin 
			IN0_WL[i] =  0  ; 
			IN1_WL[i] =  0  ; 
		      end else begin  
			IN0_WL[i] =  1  ; 
			IN1_WL[i] =  1  ; 
						end
								           end 







									    end 



/////////////////////////////////////////////////////////////////////////////////////////////////// 


		else if (is_read_ins) begin 


			#2	ENABLE_WL = 0 ; 
				ENABLE_SL = 0 ; 
				ENABLE_BL = 0 ; 
				PRE= 0 ;
			      is_read_neg_cycle = 1; 

			      if (COL_ADDR_R < 8)  begin 
				SEL_MUX1_TO_CSA = 1 ; 
				SEL_MUX2_TO_CSA = 0 ; 

			      
				S_MUX1 =  COL_ADDR_R ; 	


			      end else begin 	
				SEL_MUX1_TO_CSA = 0 ; 
				SEL_MUX2_TO_CSA = 1 ; 
			      temp1 = COL_ADDR_R - 7 ; 
				S_MUX2 = temp1; 
				end 


				//precharge on +ve cycle and shutoff on
				//negative 



				for ( i = 0 ;  i < ARRAY_SIZE ; i = i +1 ) begin  
					if ( i ==  COL_ADDR_R ) begin 
				IN0_BL[i] =  0  ; 
			       IN1_BL[i] =  1  ; // 01 is the read voltage 
			       IN0_SL[i] =  0  ; 
			       IN1_SL[i] =  0  ; 
			       end else begin  
			       IN0_BL[i] =  1  ; 
			       IN1_BL[i] =  1  ; 
			       IN0_SL[i] =  1  ; 
			       IN1_SL[i] =  1  ; 
						end
								           end 


				for ( i = 0 ;  i < ARRAY_SIZE ; i = i +1 ) begin  
					if ( i == ROW_ADDR_R ) begin 
					IN0_WL[i] =  0  ; 
					IN1_WL[i] =  0  ; 
				      end else begin  
					IN0_WL[i] =  1  ; 
					IN1_WL[i] =  1  ; 
						end
								           end 






		end 


	
				end







		end

end


always @(negedge clk) begin 


		if (is_read_ins  ) begin 
	#2	PRE = 1;
		ENABLE_WL = 1 ; 
		ENABLE_SL = 0 ; 
		ENABLE_BL = 1 ; 
					

			      if (COL_ADDR_R < 8)  begin 
			      SAEN_CSA1 = 1 ;
			      SAEN_CSA2 = 0 ;
 
			      end else begin 	
			      SAEN_CSA2 = 1 ; 
			      SAEN_CSA1 = 0 ; 
				
			      end 




		end 




	end 





endmodule

