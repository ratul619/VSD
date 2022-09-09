`include	"opcodes.h"
`timescale 1ns / 1ps

module RRAM_CONTROLLER (clk, rst, 
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
COL_SELECT,
SEL_MUX_TO_VSA,
SEL_MUX_TO_CSA,
SEL_MUX_TO_ADC,
PRE, 
CLK_EN_ADC,
SAEN_CSA); 


 
parameter INSTRUCTION_SIZE = 32 ; 
parameter ARRAY_SIZE = 16 ; 
parameter ARRAY_DEPTH = 4 ; 
parameter IF_SIZE = 16; 
parameter ADDR_SIZE_IM = 7; 



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
reg rd_cs_input_buffer ;
reg rd_en_input_buffer ;
input wishbone_wr_en_input_buffer ; 
output reg  wishbone_empty_input_buffer ;
output reg  wishbone_full_input_buffer  ;


reg enable_IM;
reg enable_IM_pipe1;


output  reg [ARRAY_SIZE-1:0] IN0_BL;
output  reg [ARRAY_SIZE-1:0] IN1_BL;
output   [ARRAY_SIZE-1:0] IN0_WL;
output   [ARRAY_SIZE-1:0] IN1_WL;
output  reg [ARRAY_SIZE-1:0] IN0_SL;
output  reg [ARRAY_SIZE-1:0] IN1_SL;
output  reg ENABLE_WL;
output  reg ENABLE_SL;
output  reg ENABLE_BL;
output  reg COL_SELECT;
output  reg [7:0]SEL_MUX_TO_VSA;
output  reg [7:0]SEL_MUX_TO_CSA;
output  reg [7:0]SEL_MUX_TO_ADC;
output  reg PRE ; 
output  reg [1:0]CLK_EN_ADC;
output  reg SAEN_CSA;



wire [INSTRUCTION_SIZE-1:0]data_in_instruction_memory ;
wire [INSTRUCTION_SIZE-1:0]data_out_instruction_memory ;


wire [IF_SIZE-1:0]data_in_input_buffer ;
wire [IF_SIZE-1:0]data_out_input_buffer ;


reg   [ARRAY_SIZE-1:0] IN0_WL_from_ID;
reg   [ARRAY_SIZE-1:0] IN1_WL_from_ID;

reg mac_mux_from_ID;


reg [ADDR_SIZE_IM-1:0] wishbone_address_to_read_instruction_memory;
reg [ADDR_SIZE_IM-1:0] wishbone_address_to_write_instruction_memory;

reg [ADDR_SIZE_IM-1:0] IP_address_to_read_input_buffer;
reg [ADDR_SIZE_IM-1:0] wishbone_address_to_write_input_buffer;


reg halt_IM;
reg halt_IM_p1;

reg COL_SELECT_FOR_MAC_ADC;

reg [6:0]counter_mac  ; 

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
.rd_cs( rd_cs_input_buffer)   , 
.data_in(data_in_input_buffer) , 
.rd_en( rd_en_input_buffer)    ,
.wr_en( wishbone_wr_en_input_buffer)    ,
.data_out(data_out_input_buffer), 
.empty( wishbone_empty_input_buffer)    ,
.full( wishbone_full_input_buffer),
.address_to_write(wishbone_address_to_write_input_buffer),
.address_to_read(IP_address_to_read_input_buffer)
);    




reg IP_wr_cs_output_buffer ; 
wire wishbone_rd_cs_output_buffer ;
wire [31:0] IP_data_in_output_buffer;
wire wishbone_rd_en_output_buffer;
reg IP_wr_en_output_buffer;
wire [31:0] wishbone_data_out_output_buffer;
wire wishbone_empty_output_buffer;
wire wishbone_full_output_buffer;
reg [6:0]IP_address_to_write_output_buffer;
wire [6:0]wishbone_address_to_read_output_buffer;

sync_fifo_output_buffer  U_sync_fifo_output_buffer (
.clk(clk)     , 
.rst(rst)      ,
.wr_cs( IP_wr_cs_output_buffer) ,   
.rd_cs( wishbone_rd_cs_output_buffer)   , 
.data_in(IP_data_in_output_buffer) , 
.rd_en( wishbone_rd_en_output_buffer)    ,
.wr_en(IP_wr_en_output_buffer)    ,
.data_out(wishbone_data_out_output_buffer), 
.empty( wishbone_empty_output_buffer)    ,
.full( wishbone_full_output_buffer),
.address_to_write(IP_address_to_write_output_buffer),
.address_to_read(wishbone_address_to_read_output_buffer)
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
integer ROW_ADDR_W  = 0 ;
integer ROW_ADDR_R  = 0 ;

reg START_MAC_ADC ; 

integer num_row_op;
integer num_col_op;
integer present_column;



integer num_MAC_OP;

reg is_IDLE;

reg [4:0]start_IF_Address ; 
reg [4:0]end_IF_Address ; 

reg DATA_TO_WRITE;

reg PRE_p1;
reg PRE_p2;
reg ENABLE_WL_p1;
reg ENABLE_BL_p1;
reg ENABLE_SL_p1;

reg start_neg_MAC_p1;
reg start_neg_MAC_p2;
reg start_neg_MAC;

reg START_MAC;
reg START_MAC_p1;
reg START_MAC_p2;
reg START_MAC_p3;

reg COL_SELECT_FOR_READ;


always @(posedge clk   or negedge rst  ) begin 


	if (!rst) begin 

 #2 COL_ADDR_W = 0 ;
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
halt_IM =  0;
START_MAC_ADC =0;
is_IDLE = 0 ;
DATA_TO_WRITE <=0;
COL_SELECT_FOR_READ <=0;
COL_SELECT_FOR_MAC_ADC <=0; 
IP_address_to_write_output_buffer <='0; 
	end 

	else if (enable_IM && ~halt_IM)  begin 
			
case (data_out_instruction_memory[31:28])

		`WRITE_RRAM :	// 
                begin
        #1      COL_ADDR_W = data_out_instruction_memory[3:0];
                ROW_ADDR_W = data_out_instruction_memory[7:4]; 
		DATA_TO_WRITE =  data_out_instruction_memory[8];

		ENABLE_ARR_OP = 1 ; 
		is_read_ins= 0 ;
		is_write_ins = 1 ;
		is_MAC_ins = 0 ;
		is_PULSE_T_ins = 0 ;
		is_PULSE_V_ins = 0 ;
 		mac_mux_from_ID = 0 ; 
		is_IDLE = 0; 
		is_read_neg_cycle = 0 ; 
		end


		`IDLE_RRAM :	// 
                begin
        #1     
               
		ENABLE_ARR_OP = 0 ; 
		is_read_ins= 0 ;
		is_write_ins = 0;
		is_MAC_ins = 0 ;
		is_PULSE_T_ins = 0 ;
		is_PULSE_V_ins = 0 ;
 		mac_mux_from_ID = 0 ; 
		is_IDLE = 1; 
		is_read_neg_cycle = 0 ;
		end



		`READ_RRAM :	// 
                begin
        #1      COL_SELECT_FOR_READ = data_out_instruction_memory[0]; // If 0 , selecting LSB 8bits of column ie column [7:0] and if 1 selecting MSB column ie column [15:8]
                ROW_ADDR_R = data_out_instruction_memory[5:1];
		ENABLE_ARR_OP = 1 ; 

		is_read_ins= 1 ;
		is_write_ins = 0 ;
		is_MAC_ins = 0 ;
		is_PULSE_T_ins = 0 ;
		is_PULSE_V_ins = 0 ;
 		mac_mux_from_ID = 0 ; 
		is_IDLE = 0;
		is_read_neg_cycle = 0 ; 




                end 

		`MAC_OPERATION :	// 
                begin
		
	#1	
		
		
		
		COL_SELECT_FOR_MAC_ADC = data_out_instruction_memory[0];
		num_MAC_OP =    data_out_instruction_memory[8:1];
		start_IF_Address =   data_out_instruction_memory[16:9];
		
		counter_mac = 0 ;
		ENABLE_ARR_OP = 1 ; 

		is_read_ins= 0 ;
		is_write_ins = 0 ;
		is_MAC_ins = 1 ;
		is_PULSE_T_ins = 0 ;
		is_PULSE_V_ins = 0 ;
		halt_IM =  1;
		is_read_neg_cycle = 0 ;
 		mac_mux_from_ID = 1 ; 
		

		START_MAC  = 1;
		PRE <=1; 
	
                end 

		`CONF_T_PULSE_RRAM :	// 
                begin
		

	#1	T_PULSE_OP_TYPE =     data_out_instruction_memory[9:8]; 
		T_PULSE_MULTIPLIER =  data_out_instruction_memory[7:0] ; 
		ENABLE_ARR_OP = 1 ; 


		is_read_ins= 0 ;
		is_write_ins = 0 ;
		is_MAC_ins = 0 ;
		is_PULSE_T_ins = 1 ;
		is_PULSE_V_ins = 0 ;
		is_read_neg_cycle = 0 ;


                end 

		`CONF_V_PULSE_RRAM :	// 
                begin
		

	#1	V_PULSE_OP_TYPE =  	data_out_instruction_memory[3:2]; 
		V_PULSE_MUX_SEL = 	data_out_instruction_memory[1:0] ; 
		ENABLE_ARR_OP = 1 ; 
		

		is_read_ins= 0 ;
		is_write_ins = 0 ;
		is_MAC_ins = 0 ;
		is_PULSE_T_ins = 0 ;
		is_PULSE_V_ins = 1 ;
		is_read_neg_cycle = 0 ;


                end 



endcase




	end

	end


reg halt_IM_pipe1;
reg halt_IM_pipe2;
reg START_MAC_ADC_pipe1;
reg START_MAC_ADC_pipe2;


reg	rd_cs_input_buffer_p1;
reg	rd_en_input_buffer_p1;
reg PRE_p1_n;


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
	SEL_MUX_TO_VSA <= '0 ; 
	SEL_MUX_TO_CSA <= '0 ; 
	SEL_MUX_TO_ADC <= '0 ; 
	PRE_p1  <= 1 ; 
	PRE_p2  <= 1 ; 
	PRE  <= 1 ;
	PRE_p1_n <=1; 
	CLK_EN_ADC <= 0 ; 
	SAEN_CSA <= 0 ; 
	rd_cs_input_buffer   	 <= 0 ; 
	rd_en_input_buffer	 <= 0 ;
	start_neg_MAC <=0;
	start_neg_MAC_p1 <=0;
	START_MAC_p1 <=0;
	START_MAC_p2 <=0;
	START_MAC_p3 <=0;
	START_MAC <=0;
	halt_IM_p1 <=0;
	rd_cs_input_buffer_p1 <=0;
	rd_en_input_buffer_p1 <=0;
	//start_IF_Address <=0;
	end 

	else begin 

	if  (is_IDLE) begin 


			#2	
				ENABLE_WL <= 0 ; 
				ENABLE_SL <= 0 ; 
				ENABLE_BL <= 0 ; 
				SEL_MUX_TO_VSA <= '0 ; 
				SEL_MUX_TO_CSA <= '0 ; 
				SEL_MUX_TO_ADC <= '0 ; 
				IN0_BL <= 'hz ; 
				IN1_BL <= 'hz ; 
				IN0_WL_from_ID <= 'hz ; 
				IN1_WL_from_ID <= 'hz ; 
				IN0_SL <= 'hz ; 
				IN1_SL <= 'hz ; 




end 	else if (is_write_ins  ) begin  

// All Enables are ON in write 

			#2	ENABLE_WL <= 1 ; 
				ENABLE_SL <= 1 ; 
				ENABLE_BL <= 1 ; 

// All SEL passgates are OFF
				SEL_MUX_TO_VSA <= '0 ; 
				SEL_MUX_TO_CSA <= '0 ; 
				SEL_MUX_TO_ADC <= '0 ; 




//SET : DATA_TO_WRITE = 1
	if (DATA_TO_WRITE ==1)   begin 

				for ( i = 0 ;  i < ARRAY_SIZE ; i = i +1 ) begin
				if (i  == COL_ADDR_W) begin 
				IN0_BL[i] <=  0  ; 
				IN1_BL[i] <=  0  ; // AYAN : 00 is SET voltage  
				IN0_SL[i] <=  1  ; // AYAN : 11 pattern for ground : SL is ground in SET
				IN1_SL[i] <=  1  ; 
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
				IN1_WL_from_ID[i] <=  1  ; 		//AYAN :  Assuing write voltage for  in WL = 01
				end else begin  
				IN0_WL_from_ID[i] <=  1  ; 
				IN1_WL_from_ID[i] <=  1  ; 		//11 pattern for ground
				end
								    end 
	end else if  (DATA_TO_WRITE ==0)  begin 


//RESET : DATA_TO_WRITE = 0

				for ( i = 0 ;  i < ARRAY_SIZE ; i = i +1 ) begin
				if (i  == COL_ADDR_W) begin 
				IN0_BL[i] <=  1  ; 
				IN1_BL[i] <=  1  ; // AYAN : BL is ground in RESET  
				IN0_SL[i] <=  0  ; // AYAN : Assuing write voltage V1_SL for RESET
				IN1_SL[i] <=  1  ; 
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
				IN1_WL_from_ID[i] <=  1  ; 		//AYAN :  Assuing write voltage for  in WL = 01
				end else begin  
				IN0_WL_from_ID[i] <=  1  ; 
				IN1_WL_from_ID[i] <=  1  ; 		//11 pattern for ground
				end
								    end 

			



	end 



end 


/////////////////////////////////////////////////////////////////////////////////////////////////// 


		else if (is_read_ins ) begin 


			#2	ENABLE_WL <= 0 ; 
				ENABLE_SL <= 0 ; 
				ENABLE_BL <= 0 ; 
				PRE<= 0 ;
			      	is_read_neg_cycle <= 1; 
				SEL_MUX_TO_CSA <= 1 ; 


				//precharge on +ve cycle and shutoff on
				//negative 

				
				if (!COL_SELECT_FOR_READ) begin  
				COL_SELECT <= 0 ; 

				IN0_BL[7:0] <= '0; 
				IN1_BL[7:0] <= '1; 
				IN0_SL[15:0] <= '1; 
				IN1_SL[15:0] <= '1; 
				
				IN0_BL[15:8] <= '1; 
				IN1_BL[15:8] <= '1; 

				

				end else if (COL_SELECT_FOR_READ) begin  

				COL_SELECT <= 1 ; 

				IN0_BL[7:0] <= '1; 
				IN1_BL[7:0] <= '1; 
				IN0_SL[15:0] <= '1; 
				IN1_SL[15:0] <= '1; 
				
				IN0_BL[15:8] <= '0; 
				IN1_BL[15:8] <= '1; 

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




	end
end



always @(negedge clk) 
begin 


		if ( is_read_neg_cycle  ) begin 
	#2	
		PRE <= 1;
		ENABLE_WL <= 1 ; 
		ENABLE_SL <= 0 ; 
		ENABLE_BL <= 1 ; 
		SAEN_CSA <= 1 ;
				
			      end 




		end 





//////////////////////////////////////




assign IN0_WL = START_MAC ?  data_out_input_buffer : IN0_WL_from_ID  ; //0,0 is the ON voltage for WL
assign IN1_WL = START_MAC ?  data_out_input_buffer : IN1_WL_from_ID ; //0,0 is the ON voltage for WL

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


always  @ (posedge clk )
begin : MAC_OPS1 


 if (START_MAC ) begin 

#2

	ENABLE_WL <= 0;
	ENABLE_SL <= 0;
	ENABLE_BL <= 0;


	if (!COL_SELECT_FOR_MAC_ADC) begin  
	COL_SELECT <= 0 ; 

	IN0_BL[7:0] <= '0; 
	IN1_BL[7:0] <= '1; 
	IN0_SL[15:0] <= '1; 
	IN1_SL[15:0] <= '1; 
	
	IN0_BL[15:8] <= '1; 
	IN1_BL[15:8] <= '1; 

	

	end else if (COL_SELECT_FOR_MAC_ADC) begin  

	COL_SELECT <= 1 ; 

	IN0_BL[7:0] <= '1; 
	IN1_BL[7:0] <= '1; 
	IN0_SL[15:0] <= '1; 
	IN1_SL[15:0] <= '1; 
	
	IN0_BL[15:8] <= '0; 
	IN1_BL[15:8] <= '1; 

	end

	CLK_EN_ADC <=0;	
	

	if (num_MAC_OP >= 0) begin
	IP_address_to_read_input_buffer <= start_IF_Address;
	rd_cs_input_buffer   	 <=1 ; 
	rd_en_input_buffer	 <=1 ;
	start_IF_Address <= start_IF_Address + 1 ;
	PRE_p2 <= 0 ; 
	PRE_p1 <= PRE_p2 ; 
	PRE <= PRE_p1 ; 
	start_neg_MAC_p1 <= 1; 
	start_neg_MAC <= start_neg_MAC_p1; 
	num_MAC_OP--;
	end else begin
	halt_IM_p1 <= 0 ;
	halt_IM <= halt_IM_p1  ;
	START_MAC_p3 <= 0 ;
	START_MAC_p2 <= START_MAC_p3 ;
	START_MAC_p1 <= START_MAC_p2 ;
	START_MAC <= START_MAC_p1 ;
	//start_MAC_neg_cycle <= 0 ;
	rd_cs_input_buffer_p1   	 <= 0 ; 
	rd_cs_input_buffer   	 <= rd_cs_input_buffer_p1 ; 
	rd_en_input_buffer_p1	 <= 0 ;
	rd_en_input_buffer	 <= rd_en_input_buffer_p1 ;
	end



     	
  end
end



always  @ (negedge clk )
begin : MAC_OPS1_NEG 


 if (START_MAC  && start_neg_MAC) begin 

#2
	
	PRE_p1_n <=1;
	PRE <=  PRE_p1_n;
	ENABLE_WL <= 1;
	ENABLE_SL <= 0;
	ENABLE_BL <= 1;
	CLK_EN_ADC <=1;	
	
	IP_address_to_write_output_buffer++; 
	IP_wr_cs_output_buffer <=1 ; 
	IP_wr_en_output_buffer <=1 ;

	
     	
  end
end






endmodule
