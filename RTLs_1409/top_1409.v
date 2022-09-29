`include	"opcodes.h"
`timescale 1ns / 1ps

module RRAM_CONTROLLER (clk, rst, 
wishbone_data_in,
wishbone_data_out,
wishbone_address_bus,
wbs_we_i,
enable_IM,
ADC_OUT0,
ADC_OUT1,
ADC_OUT2,
CLK_EN_ADC,
CSA,
ENABLE_ADC,
ENABLE_BL,
ENABLE_CSA,
ENABLE_SL,
ENABLE_WL,
IN0_BL,
IN0_SL,
IN0_WL,
IN1_BL,
IN1_SL,
IN1_WL,
PRE,
SAEN_CSA
); 


 
parameter INSTRUCTION_SIZE = 32 ; 
parameter ARRAY_SIZE = 16 ; 
parameter ARRAY_DEPTH = 4 ; 
parameter IF_SIZE = 16; 
parameter ADDR_SIZE_IM = 7; 




input		clk , rst  , enable_IM; 

input [31:0]wishbone_data_in;
output reg [31:0]wishbone_data_out;
input [31:0]wishbone_address_bus;
input wbs_we_i;



output reg  ENABLE_CSA;
output reg  ENABLE_ADC;
output reg  ENABLE_WL;
output reg  ENABLE_SL;
output reg  ENABLE_BL;
output reg  PRE ; 
output reg  [1:0]CLK_EN_ADC;
output reg  SAEN_CSA;

input  [15:0]CSA;
input  [15:0]ADC_OUT0;
input  [15:0]ADC_OUT1;
input  [15:0]ADC_OUT2;

output  [15:0]IN0_WL;
output  [15:0]IN1_WL;
output reg [15:0]IN0_BL;
output reg [15:0]IN1_BL;
output reg [15:0]IN0_SL;
output reg [15:0]IN1_SL;


reg [31:0] ADC_OUTPUT;
reg [31:0]wishbone_data_out_CSA;
reg [31:0]wishbone_data_out_ADC;
reg halt_IM;
reg COL_SELECT_FOR_MAC_ADC;
reg [6:0]counter_mac  ; 

reg [31:0]instruction_memory_data_out;

reg [5:0]address_to_read_instruction_memory;

reg rd_enable_sync_fifo_instruction_memory;

sync_fifo_32x64  U_sync_fifo_instruction_memory (
.clk(clk)     , 
.rst(rst)      ,
.wr_cs(wbs_we_i) ,   
.rd_cs(rd_enable_sync_fifo_instruction_memory) , 
.data_in(wishbone_data_in) , 
.rd_en(rd_enable_sync_fifo_instruction_memory)   , 
.wr_en(wbs_we_i)    ,
.data_out(data_out_instruction_memory), 
.empty(empty0)     ,
.full(full0),
.address_to_write(wishbone_address_bus[5:0]),
.address_to_read(address_to_read_instruction_memory)
);  

reg [31:0]data_bus_output_buffer;

reg [5:0]address_output_buffer;
reg wr_sync_fifo_output_buffer;
sync_fifo_32x64  U_sync_fifo_output_buffer (
.clk(clk)     , 
.rst(rst)      ,
.wr_cs(wr_sync_fifo_output_buffer) ,   
.rd_cs(wbs_we_i) , 
.data_in(data_bus_output_buffer) , 
.rd_en(wbs_we_i)    ,
.wr_en(wr_sync_fifo_output_buffer)    ,
.data_out(wishbone_data_out), 
.empty(empty4)     ,
.full(full4),
.address_to_write(address_output_buffer),
.address_to_read(wishbone_address_bus[5:0])
);    


reg [15:0] input_buffer_data_out;
reg  [3:0]read_address_bus_input_buffer;


reg rd_input_buffer;

sync_fifo_16x16  U_sync_fifo_input_buffer (
.clk(clk)     , 
.rst(rst)      ,
.wr_cs(wbs_we_i) ,   
.rd_cs(rd_input_buffer) , 
.data_in(wishbone_data_in[15:0]) , 
.rd_en(rd_input_buffer)    ,
.wr_en(wbs_we_i)    ,
.data_out(input_buffer_data_out), 
.empty(empty5)     ,
.full(full5),
.address_to_write(wishbone_address_bus[3:0]),
.address_to_read(read_address_bus_input_buffer)
);   




////////////////////////////////////

reg is_read_ins;
reg is_write_ins;
reg is_MAC_ins;


reg  [ARRAY_DEPTH-1:0]COL_START_MAC;
reg  [ARRAY_DEPTH-1:0]COL_END_MAC;
reg  [ARRAY_DEPTH-1:0]ROW_START_MAC;
reg  [ARRAY_DEPTH-1:0]ROW_END_MAC;


reg [1:0]T_PULSE_OP_TYPE; 
reg [7:0]T_PULSE_MULTIPLIER; 

reg [1:0]V_PULSE_OP_TYPE; 
reg [1:0]V_PULSE_MUX_SEL; 


reg is_read_next_cycle;
reg is_MAC_next_cycle;

integer i = 0; 


integer COL_ADDR_W  = 0 ;
integer ROW_ADDR_W  = 0 ;
integer ROW_ADDR_R  = 0 ;

reg START_MAC_ADC ; 

integer num_row_op;
integer num_col_op;
integer present_column;



reg [4:0]num_MAC_OP;

reg is_IDLE;

reg [4:0]start_IF_Address ; 
reg [4:0]end_IF_Address ; 

reg DATA_TO_WRITE;

reg start_neg_MAC;

reg START_MAC;

reg [31:0]data_out_instruction_memory;



reg mac_mux_from_ID;
always @(posedge clk   or negedge rst  ) begin 


	if (!rst) begin 

		is_read_ins <= 0 ;
		is_write_ins <= 0 ;
		is_MAC_ins <= 0 ;
 		mac_mux_from_ID <= 0 ; 
		is_IDLE <=0;
	end 

	else if (enable_IM && ~halt_IM)  begin 
			
case (data_out_instruction_memory[31:28])

		`WRITE_RRAM :	// 
                begin
        #1      COL_ADDR_W = data_out_instruction_memory[3:0];
                ROW_ADDR_W = data_out_instruction_memory[7:4]; 
		DATA_TO_WRITE =  data_out_instruction_memory[8];

		is_read_ins= 0 ;
		is_write_ins = 1 ;
		is_MAC_ins = 0 ;
		is_IDLE = 0; 
		end


		`IDLE_RRAM :	// 
                begin
        #1     
               
		is_read_ins= 0 ;
		is_write_ins = 0;
		is_MAC_ins = 0 ;
		is_IDLE = 1; 
		end



		`READ_RRAM :	// 
                begin
                ROW_ADDR_R = data_out_instruction_memory[5:1];

		is_read_ins= 1 ;
		is_write_ins = 0 ;
		is_MAC_ins = 0 ;
		is_IDLE = 0;
                end 

		`MAC_OPERATION :	// 
                begin
		
	#1	
		
		is_read_ins <= 0 ;
		is_write_ins <= 0 ;
		is_MAC_ins <=1  ;
 		mac_mux_from_ID <= 1 ; 
		is_IDLE <=0;
				num_MAC_OP <= 16;
		COL_SELECT_FOR_MAC_ADC <= data_out_instruction_memory[0];
			
                end 

		




		endcase
	end
end


reg [ARRAY_SIZE-1:0]IN0_WL_from_ID;
reg [ARRAY_SIZE-1:0]IN1_WL_from_ID;


reg [ARRAY_SIZE-1:0]IN0_WL_from_IF;
reg [ARRAY_SIZE-1:0]IN1_WL_from_IF;


always @(posedge clk   or negedge rst  ) begin 


	if (!rst) begin 


				
				ENABLE_WL <= 0 ; 
				ENABLE_SL <= 0 ; 
				ENABLE_BL <= 0 ; 
				IN0_BL <= 0 ; 
				IN1_BL <=  0 ; 
				IN0_WL_from_ID <=  '0 ; 
				IN1_WL_from_ID <= '0 ; 
				IN0_SL <= '0 ; 
				IN1_SL <= '0 ; 
				rd_input_buffer <=0;
				read_address_bus_input_buffer <=0;
				address_output_buffer <=0 ; 
				wr_sync_fifo_output_buffer <= 0; 
				START_MAC <=0;
				halt_IM <=0;
			      	is_read_next_cycle <= 0;
			      	is_MAC_next_cycle <= 0;



	end 

	else if (enable_IM && ~halt_IM)  begin 


	 if  (is_IDLE) begin 


				
				ENABLE_WL <= 0 ; 
				ENABLE_SL <= 0 ; 
				ENABLE_BL <= 0 ; 
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




//SET : DATA_TO_WRITE = 1
			if (DATA_TO_WRITE)   begin 

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
			end else if  (!DATA_TO_WRITE)  begin 


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



end else if (is_read_ins ) begin 

			

			#2	ENABLE_WL <= 0 ; 
				ENABLE_SL <= 0 ; 
				ENABLE_BL <= 0 ; 
				PRE<= 0 ;
			      	is_read_next_cycle <= 1;
				halt_IM <=1;


				//precharge on +ve cycle and shutoff on
				//negative 

				
				IN0_BL[15:0] <= '0; 
				IN1_BL[15:0] <= '1; 
				IN0_SL[15:0] <= '1; 
				IN1_SL[15:0] <= '1; 
				


				for ( i = 0 ;  i < ARRAY_SIZE ; i = i +1 ) begin  
				if ( i == ROW_ADDR_R ) begin 
				IN0_WL_from_ID[i] <=  0  ; 
				IN1_WL_from_ID[i] <=  0  ; 
				end else begin  
				IN0_WL_from_ID[i] <=  1  ; 
				IN1_WL_from_ID[i] <=  1  ; 
				end
								           end



	end else if (is_read_ins && is_read_next_cycle  ) begin  

				PRE <= 1;
				ENABLE_WL <= 1 ; 
				ENABLE_SL <= 0 ; 
				ENABLE_BL <= 1 ; 
				SAEN_CSA <= 1 ;
				halt_IM <=0;
				is_read_next_cycle <=0;

	end  else  if (is_MAC_ins  ) begin 

#2

		ENABLE_WL <= 0;
		ENABLE_SL <= 0;
		ENABLE_BL <= 0;


		IN0_BL[15:0] <= '0; 
		IN1_BL[15:0] <= '1; 
		IN0_SL[15:0] <= '1; 
		IN1_SL[15:0] <= '1; 
		START_MAC <=1 ;	
		halt_IM <=1;

		

// Change the data format from input buffer to data to WL lines 


				for ( i = 0 ;  i < ARRAY_SIZE ; i = i +1 ) begin  
				if (input_buffer_data_out[i]  ) begin 
				IN0_WL_from_IF[i] <=  0  ; 
				IN1_WL_from_IF[i] <=  1  ; 
				end else begin  
				IN0_WL_from_IF[i] <=  1  ; 
				IN1_WL_from_IF[i] <=  1  ; 
				end
								           end




//select column of ADC	

	if (num_MAC_OP >= 0) begin

	num_MAC_OP--;
	address_output_buffer++; 
	wr_sync_fifo_output_buffer <= 1;
       	read_address_bus_input_buffer++;
	rd_input_buffer <=1 ;
	is_MAC_next_cycle <=1;


	end else if (num_MAC_OP == 0) begin
	//increment address of input buffer and feed
	//to the WLs 
	wr_sync_fifo_output_buffer <=0; 
	rd_input_buffer <=0 ;
	halt_IM <=0;
	is_MAC_next_cycle <=0;
	end



     	
  	end else  if (is_MAC_ins &&  is_MAC_next_cycle ) begin 
	PRE <=  0;
	ENABLE_WL <= 1;
	ENABLE_SL <= 0;
	ENABLE_BL <= 1;
	CLK_EN_ADC <=1;	
	is_MAC_next_cycle <=0;
	end 

end

end









//////////////////////////////////////




assign IN0_WL = START_MAC ?  IN0_WL_from_IF : IN0_WL_from_ID  ; 
assign IN1_WL = START_MAC ?  IN1_WL_from_IF : IN1_WL_from_ID ; 

reg [7:0]AddCounter = 0 ; 


always  @ (posedge clk or negedge rst)
begin : PC 
  if (!rst) begin

#2 
     address_to_read_instruction_memory <= '0;
     rd_enable_sync_fifo_instruction_memory <=0; 
     AddCounter <= 0 ; 

  end else if (enable_IM && ~halt_IM ) begin 

#2
     address_to_read_instruction_memory  <= address_to_read_instruction_memory   + AddCounter ;
     rd_enable_sync_fifo_instruction_memory <=1;
     AddCounter ++ ; 
     	
  end
end



always @(*)

begin  

if (is_read_ins) begin  


 data_bus_output_buffer[15:0] 	= CSA; 
end else if (is_MAC_ins) begin  

 data_bus_output_buffer[0] 	= 	1'b1 ;
 data_bus_output_buffer[4] 	=      1'b1;
 data_bus_output_buffer[8] 	=	1'b1;
 data_bus_output_buffer[12]  = 	1'b1;
 data_bus_output_buffer[16]  = 	1'b1;
 data_bus_output_buffer[20]  =	1'b1;
 data_bus_output_buffer[24]  =	1'b1;
 data_bus_output_buffer[28]  = 	1'b1;


 		if (COL_SELECT_FOR_MAC_ADC) begin 



		 data_bus_output_buffer[3:1] = 	 {ADC_OUT0[8],ADC_OUT1[8],ADC_OUT2[8]}; 	
		 data_bus_output_buffer[7:5] = 	 {ADC_OUT0[9],ADC_OUT1[9],ADC_OUT2[9]};	
		 data_bus_output_buffer[11:9] = 	 {ADC_OUT0[10],ADC_OUT1[10],ADC_OUT2[10]}; 
		 data_bus_output_buffer[15:13] = 	 {ADC_OUT0[11],ADC_OUT1[11],ADC_OUT2[11]}; 
		 data_bus_output_buffer[19:17] = 	 {ADC_OUT0[12],ADC_OUT1[12],ADC_OUT2[12]}; 
		 data_bus_output_buffer[23:21] = 	 {ADC_OUT0[13],ADC_OUT1[13],ADC_OUT2[13]}; 
		 data_bus_output_buffer[27:25] = 	 {ADC_OUT0[14],ADC_OUT1[14],ADC_OUT2[14]}; 
		 data_bus_output_buffer[31:29] = 	 {ADC_OUT0[15],ADC_OUT1[15],ADC_OUT2[15]}; 



		end else begin 

		 data_bus_output_buffer[3:1] = 		{ADC_OUT0[0],ADC_OUT1[0],ADC_OUT2[0]};
		 data_bus_output_buffer[7:5] = 		{ADC_OUT0[1],ADC_OUT1[1],ADC_OUT2[1]};
		 data_bus_output_buffer[11:9] = 	{ADC_OUT0[2],ADC_OUT1[2],ADC_OUT2[2]};
		 data_bus_output_buffer[15:13] = 	{ADC_OUT0[3],ADC_OUT1[3],ADC_OUT2[3]};
		 data_bus_output_buffer[19:17] = 	{ADC_OUT0[4],ADC_OUT1[4],ADC_OUT2[4]};
		 data_bus_output_buffer[23:21] = 	{ADC_OUT0[5],ADC_OUT1[5],ADC_OUT2[5]};
		 data_bus_output_buffer[27:25] = 	{ADC_OUT0[6],ADC_OUT1[6],ADC_OUT2[6]};
		 data_bus_output_buffer[31:29] = 	{ADC_OUT0[7],ADC_OUT1[7],ADC_OUT2[7]};



		end 


end 

end 



endmodule

