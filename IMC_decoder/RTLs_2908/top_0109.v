`include	"opcodes.h"
`timescale 1ns / 1ps

module top (clk, rst, 
wishbone_databus_in,
wishbone_databus_out,
wishbone_databus_to_ID_or_IB,
wishbone_wr_cs_instruction_memory, 
wishbone_wr_en_instruction_memory, 
wishbone_empty_instruction_memory,
wishbone_full_instruction_memory ,
wishbone_wr_cs_input_buffer, 
wishbone_wr_en_input_buffer, 
wishbone_empty_input_buffer, 
wishbone_full_input_buffer ,
enable_PC_IM, // Start program counter IM 
start_PC_IM_address, // Start program counter IM address 
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
SAEN_CSA2); 


 
parameter INSTRUCTION_SIZE = 32 ; 
parameter ARRAY_SIZE = 16 ; 
parameter ARRAY_DEPTH = 4 ; 
parameter IF_SIZE = 32; 
parameter ADDR_SIZE_IM = 6; 



input		clk , rst , enable_PC_IM ;

input   [INSTRUCTION_SIZE-1:0]wishbone_databus_in ; 
output  reg [INSTRUCTION_SIZE-1:0]wishbone_databus_out ; 

input wishbone_databus_to_ID_or_IB;

input [ADDR_SIZE_IM-1:0]start_PC_IM_address;


input wishbone_wr_cs_instruction_memory ; 
reg  wishbone_rd_cs_instruction_memory ;
reg  wishbone_rd_en_instruction_memory ;
input wishbone_wr_en_instruction_memory ; 
output reg  wishbone_empty_instruction_memory ;
output reg wishbone_full_instruction_memory  ;



input wishbone_wr_cs_input_buffer ; 
reg wishbone_rd_cs_input_buffer ;
reg wishbone_rd_en_input_buffer ;
input wishbone_wr_en_input_buffer ; 
output reg  wishbone_empty_input_buffer ;
output reg  wishbone_full_input_buffer  ;


reg enable_IM;
reg enable_IM_pipe1;


output  reg [ARRAY_SIZE-1:0] IN0_BL;
output  reg [ARRAY_SIZE-1:0] IN1_BL;
output  reg [ARRAY_SIZE-1:0] IN0_WL;
output  reg [ARRAY_SIZE-1:0] IN1_WL;
output  reg [ARRAY_SIZE-1:0] IN0_SL;
output  reg [ARRAY_SIZE-1:0] IN1_SL;
output  reg ENABLE_WL;
output  reg ENABLE_SL;
output  reg ENABLE_BL;
output  reg [2:0]S_MUX1;
output  reg [2:0]S_MUX2;
output  reg SEL_MUX1_TO_VSA;
output  reg SEL_MUX1_TO_CSA;
output  reg SEL_MUX1_TO_ADC;
output  reg SEL_MUX2_TO_VSA;
output  reg SEL_MUX2_TO_CSA;
output  reg SEL_MUX2_TO_ADC; 
output  reg PRE ; 
output  reg CLK_EN_ADC1;
output  reg CLK_EN_ADC2;
output  reg SAEN_CSA1;
output  reg SAEN_CSA2;



wire [INSTRUCTION_SIZE-1:0]data_in_instruction_memory ;
wire [INSTRUCTION_SIZE-1:0]data_out_instruction_memory ;


wire [IF_SIZE-1:0]data_in_input_buffer ;
wire [IF_SIZE-1:0]data_out_input_buffer ;


reg   [ARRAY_SIZE-1:0] IN0_WL_from_ID;
reg   [ARRAY_SIZE-1:0] IN1_WL_from_ID;

reg mac_mux_from_ID;


reg [ADDR_SIZE_IM-1:0] wishbone_address_to_read_instruction_memory;
reg [ADDR_SIZE_IM-1:0] wishbone_address_to_write_instruction_memory;

reg [ADDR_SIZE_IM-1:0] wishbone_address_to_read_input_buffer;
reg [ADDR_SIZE_IM-1:0] wishbone_address_to_write_input_buffer;


reg halt_IM;
reg start_MAC_OP;

sync_fifo_instruction_memory  U_sync_fifo_instruction_memory(
.clk(clk), 
.rst(rst),
.wr_cs( wishbone_wr_cs_instruction_memory),   
.rd_cs( wishbone_rd_cs_instruction_memory), 
.data_in(data_in_instruction_memory), 
.rd_en( wishbone_rd_en_instruction_memory),
.wr_en( wishbone_wr_en_instruction_memory),
.data_out(data_out_instruction_memory), 
.empty( wishbone_empty_instruction_memory),
.full( wishbone_full_instruction_memory) ,
.address_to_write(wishbone_address_to_write_instruction_memory),
.address_to_read(wishbone_address_to_read_instruction_memory)
);    


sync_fifo_input_buffer  U_sync_fifo_input_buffer (
.clk(clk)     , 
.rst(rst)      ,
.wr_cs( wishbone_wr_cs_input_buffer) ,   
.rd_cs( wishbone_rd_cs_input_buffer)   , 
.data_in(data_in_input_buffer) , 
.rd_en( wishbone_rd_en_input_buffer)    ,
.wr_en( wishbone_wr_en_input_buffer)    ,
.data_out(data_out_input_buffer), 
.empty( wishbone_empty_input_buffer)    ,
.full( wishbone_full_input_buffer),
.address_to_write(wishbone_address_to_write_input_buffer),
.address_to_read(wishbone_address_to_read_input_buffer)
);    



////////////////////////////////////

reg is_read_ins;
reg is_write_ins;
reg is_MAC_ins;
reg is_PULSE_T_ins;
reg is_PULSE_V_ins;


reg  [ARRAY_DEPTH-1:0]COL_START_MAC;
reg  [ARRAY_DEPTH-1:0]COL_END_MAC;
reg  [ARRAY_DEPTH-1:0]ROW_START_MAC;
reg  [ARRAY_DEPTH-1:0]ROW_END_MAC;


reg [1:0]T_PULSE_OP_TYPE; 
reg [7:0]T_PULSE_MULTIPLIER; 

reg [1:0]V_PULSE_OP_TYPE; 
reg [1:0]V_PULSE_MUX_SEL; 


reg ENABLE_ARR_OP;
reg  [2:0]temp1;

reg is_read_neg_cycle;

integer testw =0;
integer i = 0; 


integer COL_ADDR_W  = 0 ;
integer COL_ADDR_R  = 0 ;
integer ROW_ADDR_W  = 0 ;
integer ROW_ADDR_R  = 0 ;

reg previous_mac_op_over ; 

integer num_row_op;
integer num_col_op;
integer present_column;


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
 mac_mux_from_ID = 0 ; 
previous_mac_op_over  =1 ;  

	end 

	else if (enable_IM)  begin 
			
case (data_out_instruction_memory[31:28])

		`WRITE_RRAM :	// 
                begin
        #2      COL_ADDR_W = data_out_instruction_memory[3:0];
                ROW_ADDR_W = data_out_instruction_memory[7:4]; 
		testw = data_out_instruction_memory[31:28] ; 

		ENABLE_ARR_OP = 1 ; 
		is_read_ins= 0 ;
		is_write_ins = 1 ;
		is_MAC_ins = 0 ;
		is_PULSE_T_ins = 0 ;
		is_PULSE_V_ins = 0 ;
 		mac_mux_from_ID = 0 ; 

		

                end

		`READ_RRAM :	// 
                begin
        #2      COL_ADDR_R = data_out_instruction_memory[3:0];
                ROW_ADDR_R = data_out_instruction_memory[7:4];
		ENABLE_ARR_OP = 1 ; 

		is_read_ins= 1 ;
		is_write_ins = 0 ;
		is_MAC_ins = 0 ;
		is_PULSE_T_ins = 0 ;
		is_PULSE_V_ins = 0 ;
 		mac_mux_from_ID = 0 ; 




                end 

		`MAC_OPERATION :	// 
                begin
		
	#2	COL_START_MAC =  data_out_instruction_memory[15:12] ;
		COL_END_MAC =    data_out_instruction_memory[11:8];
		ROW_START_MAC =  data_out_instruction_memory[7:4] ;
		ROW_END_MAC = 	 data_out_instruction_memory[3:0] ; 
		ENABLE_ARR_OP = 1 ; 
		present_column 			<= COL_START_MAC; 

		is_read_ins= 0 ;
		is_write_ins = 0 ;
		is_MAC_ins = 1 ;
		is_PULSE_T_ins = 0 ;
		is_PULSE_V_ins = 0 ;
 		mac_mux_from_ID = 1 ; 
		previous_mac_op_over  = 0 ; 	
		halt_IM =  1;


                end 

		`CONF_T_PULSE_RRAM :	// 
                begin
		

	#2	T_PULSE_OP_TYPE =     data_out_instruction_memory[9:8]; 
		T_PULSE_MULTIPLIER =  data_out_instruction_memory[7:0] ; 
		ENABLE_ARR_OP = 1 ; 


		is_read_ins= 0 ;
		is_write_ins = 0 ;
		is_MAC_ins = 0 ;
		is_PULSE_T_ins = 1 ;
		is_PULSE_V_ins = 0 ;
 		mac_mux_from_ID = 0 ; 


                end 

		`CONF_V_PULSE_RRAM :	// 
                begin
		

	#2	V_PULSE_OP_TYPE =  	data_out_instruction_memory[3:2]; 
		V_PULSE_MUX_SEL = 	data_out_instruction_memory[1:0] ; 
		ENABLE_ARR_OP = 1 ; 
		

		is_read_ins= 0 ;
		is_write_ins = 0 ;
		is_MAC_ins = 0 ;
		is_PULSE_T_ins = 0 ;
		is_PULSE_V_ins = 1 ;
 		mac_mux_from_ID = 0 ; 


                end 



endcase




	end

	end


always @(posedge clk   or negedge rst  ) begin 

	if (!rst) begin 

#2	IN0_BL <= '1 ; 
	IN1_BL <= '1 ; 
	IN0_WL_from_ID <= '1 ; 
	IN1_WL_from_ID <= '1 ; 
	IN0_SL <= '1 ; 
	IN1_SL <= '1 ; 
	ENABLE_WL <= 0 ; 
	ENABLE_SL <= 0 ; 
	ENABLE_BL <= 0 ; 
	S_MUX1 <= 0 ; 
	S_MUX2 <= 0 ; 
	SEL_MUX1_TO_VSA <= 0 ; 
	SEL_MUX1_TO_CSA <= 0 ; 
	SEL_MUX1_TO_ADC <= 0 ; 
	SEL_MUX2_TO_VSA <= 0 ; 
	SEL_MUX2_TO_CSA <= 0 ; 
	SEL_MUX2_TO_ADC <= 0 ; 
	PRE  <= 1 ; 
	CLK_EN_ADC1 <= 0 ; 
	CLK_EN_ADC2 <= 0 ; 
	SAEN_CSA1 <= 0 ; 
	SAEN_CSA2 <= 0 ; 
	start_IF_Address <=0;
	end 

	else begin 

///////////////////////////////////////////////////////////////////////////////////////////////////		
		if (ENABLE_ARR_OP) begin 

			if (is_write_ins && previous_mac_op_over) begin  

// All Enables are ON in write 

			#2	ENABLE_WL <= 1 ; 
				ENABLE_SL <= 1 ; 
				ENABLE_BL <= 1 ; 

// All SEL passgates are OFF
	SEL_MUX1_TO_VSA <= 0 ; 
	SEL_MUX1_TO_CSA <= 0 ; 
	SEL_MUX1_TO_ADC <= 0 ; 
	SEL_MUX2_TO_VSA <= 0 ; 
	SEL_MUX2_TO_CSA <= 0 ; 
	SEL_MUX2_TO_ADC <= 0 ; 




// Assuming V[0] is the write voltage for all AMUXES

			for ( i = 0 ;  i < ARRAY_SIZE ; i = i +1 ) begin
			if (i  == COL_ADDR_W) begin 
			IN0_BL[i] <=  0  ; 
			IN1_BL[i] <=  0  ; 
			IN0_SL[i] <=  0  ; 
			IN1_SL[i] <=  0  ; 
			end else begin  
			IN0_BL[i] <=  1  ; 
			IN1_BL[i] <=  1  ; 
			IN0_SL[i] <=  1  ; 
			IN1_SL[i] <=  1  ; 
			end
								    end 


			for ( i = 0 ;  i < ARRAY_SIZE ; i = i +1 ) begin  
			if ( i == ROW_ADDR_W ) begin 
			IN0_WL_from_ID[i] <=  0  ; 
			IN1_WL_from_ID[i] <=  0  ; 
		 	end else begin  
			IN0_WL_from_ID[i] <=  1  ; 
			IN1_WL_from_ID[i] <=  1  ; 
			end
								    end 


		end 



/////////////////////////////////////////////////////////////////////////////////////////////////// 


		else if (is_read_ins && previous_mac_op_over) begin 


			#2	ENABLE_WL <= 0 ; 
				ENABLE_SL <= 0 ; 
				ENABLE_BL <= 0 ; 
				PRE<= 0 ;
			      is_read_neg_cycle <= 1; 

			      if (COL_ADDR_R < 8)  begin 
				SEL_MUX1_TO_CSA <= 1 ; 
				SEL_MUX2_TO_CSA <= 0 ; 
				S_MUX1 <=  COL_ADDR_R ; 	
			      end else begin 	
				SEL_MUX1_TO_CSA <= 0 ; 
				SEL_MUX2_TO_CSA <= 1 ; 
			      temp1 <= COL_ADDR_R - 7 ; 
				S_MUX2 <= temp1; 
				end 


				//precharge on +ve cycle and shutoff on
				//negative 



				for ( i = 0 ;  i < ARRAY_SIZE ; i = i +1 ) begin  
					if ( i ==  COL_ADDR_R ) begin 
				IN0_BL[i] <=  0  ; 
			       IN1_BL[i] <=  1  ; // 01 is the read voltage 
			       IN0_SL[i] <=  0  ; 
			       IN1_SL[i] <=  0  ; 
			       end else begin  
			       IN0_BL[i] <=  1  ; 
			       IN1_BL[i] <=  1  ; 
			       IN0_SL[i] <=  1  ; 
			       IN1_SL[i] <=  1  ; 
						end
								           end 


				for ( i = 0 ;  i < ARRAY_SIZE ; i = i +1 ) begin  
					if ( i == ROW_ADDR_R ) begin 
					IN0_WL_from_ID[i] <=  0  ; 
					IN1_WL_from_ID[i] <=  0  ; 
				      end else begin  
					IN0_WL_from_ID[i] <=  1  ; 
					IN1_WL_from_ID[i] <=  1  ; 
						end
								           end 






		end 




////////////////////////////////////////MAC OP  ///////////////////////////


		else if (is_MAC_ins) begin 

	#2
		SEL_MUX1_TO_CSA 		<= 0 ; 
		SEL_MUX2_TO_CSA 		<= 0 ; 
		SEL_MUX1_TO_VSA 		<= 0 ; 
		SEL_MUX2_TO_VSA 		<= 0 ;
		 

		wishbone_rd_cs_input_buffer   	 <= 1 ; 
		wishbone_rd_en_input_buffer	 <= 1 ;
		wishbone_address_to_read_input_buffer <= start_IF_Address;

		ENABLE_WL <= 0 ; 
		ENABLE_SL <= 0 ; 
		ENABLE_BL <= 0 ; 
		PRE<= 0 ;


		if ( COL_START_MAC <= COL_END_MAC) begin
		   start_IF_Address++;
		    COL_START_MAC++;
		end





//////////////////////////////////////////////////////////////////////////
				end


	end
end
end


always @(negedge clk) 
begin 


		if (is_read_ins  ) begin 
	#2	
		PRE <= 1;
		ENABLE_WL <= 1 ; 
		ENABLE_SL <= 0 ; 
		ENABLE_BL <= 1 ; 
					

			      if (COL_ADDR_R < 8)  begin 
			      SAEN_CSA1 <= 1 ;
			      SAEN_CSA2 <= 0 ;
 
			      end else begin 	
			      SAEN_CSA2 <= 1 ; 
			      SAEN_CSA1 <= 0 ; 
				
			      end 




		end 




	end 

//////////////////////////////////////



reg [ARRAY_SIZE-1:0]data_out_input_buffer_masked0; 
reg [ARRAY_SIZE-1:0]data_out_input_buffer_masked1; 

assign IN0_WL = mac_mux_from_ID ?  data_out_input_buffer_masked0 : IN0_WL_from_ID  ; //0,0 is the ON voltage for WL
assign IN1_WL = mac_mux_from_ID ?  data_out_input_buffer_masked1 : IN1_WL_from_ID ; //0,0 is the ON voltage for WL

reg [7:0]AddCounter = 0 ; 


always  @ (posedge clk or negedge rst)
begin : PC 
  if (!rst) begin

#2 
     wishbone_address_to_read_instruction_memory <= '0;
     wishbone_rd_cs_instruction_memory <=  0;
     wishbone_rd_en_instruction_memory <=  0;
     enable_IM <= 0  ; 
    enable_IM_pipe1 <=0; 
    AddCounter <= 0 ; 

  end else if (enable_PC_IM && ~halt_IM ) begin 

#2
     wishbone_address_to_read_instruction_memory  <= start_PC_IM_address  + AddCounter ;
     wishbone_rd_cs_instruction_memory <=  1;
     wishbone_rd_en_instruction_memory <=  1;
     enable_IM_pipe1 <= 1 ; 
     enable_IM <=  enable_IM_pipe1;  
    AddCounter ++ ; 
     	
  end
end

reg [4:0]start_IF_Address ; 



integer col, row; 
		//num_col_op <= COL_END_MAC - COL_START_MAC;
		//num_row_op <= ROW_END_MAC - ROW_START_MAC;


always  @ (negedge clk )
begin : MAC_OPERATION_WITH_IF_NEG 


	if (is_MAC_ins ) begin  

#2
	ENABLE_WL <= 1 ; 
	ENABLE_SL <= 0 ; 
	ENABLE_BL <= 1 ; 
	PRE<= 1 ;

//row operation


	for (row = 0 ; row < ARRAY_SIZE ; row++ )  begin 


		if ((row >= ROW_START_MAC)  && (row <= ROW_END_MAC )) begin 
			data_out_input_buffer_masked0[row] <= data_out_input_buffer[row] ;
			data_out_input_buffer_masked0[row] <= data_out_input_buffer[row] ;
		end else begin 
			data_out_input_buffer_masked1[row] <= 1 ;
			data_out_input_buffer_masked0[row] <= 1 ;

		end



	end
	


	if (COL_START_MAC < 8 ) begin 
 	CLK_EN_ADC1 <= 1 ; 
	CLK_EN_ADC2 <= 0 ; 
	end else begin 
 	CLK_EN_ADC1 <= 0 ; 
	CLK_EN_ADC2 <= 1 ; 
	end 

	end 


	if (COL_START_MAC <= COL_END_MAC) begin 
	present_column++; 
	end else begin 
	previous_mac_op_over = 1; 
	halt_IM = 0 ; 
	end 

	

 
end







endmodule
