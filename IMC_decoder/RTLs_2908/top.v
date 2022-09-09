
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


output  [ARRAY_SIZE-1:0] IN0_BL;
output  [ARRAY_SIZE-1:0] IN1_BL;
output  [ARRAY_SIZE-1:0] IN0_WL;
output  [ARRAY_SIZE-1:0] IN1_WL;
output  [ARRAY_SIZE-1:0] IN0_SL;
output  [ARRAY_SIZE-1:0] IN1_SL;
output  ENABLE_WL;
output  ENABLE_SL;
output  ENABLE_BL;
output  [2:0]S_MUX1;
output  [2:0]S_MUX2;
output  SEL_MUX1_TO_VSA;
output  SEL_MUX1_TO_CSA;
output  SEL_MUX1_TO_ADC;
output  SEL_MUX2_TO_VSA;
output  SEL_MUX2_TO_CSA;
output  SEL_MUX2_TO_ADC; 
output  PRE ; 
output  CLK_EN_ADC1;
output  CLK_EN_ADC2;
output  SAEN_CSA1;
output  SAEN_CSA2;


wire [INSTRUCTION_SIZE-1:0]data_in_instruction_memory ;
wire [INSTRUCTION_SIZE-1:0]data_out_instruction_memory ;


wire [IF_SIZE-1:0]data_in_input_buffer ;
wire [IF_SIZE-1:0]data_out_input_buffer ;


wire  [ARRAY_SIZE-1:0] IN0_WL_from_ID;
wire  [ARRAY_SIZE-1:0] IN1_WL_from_ID;

wire mac_mux_from_ID;


reg [ADDR_SIZE_IM-1:0] wishbone_address_to_read_instruction_memory;
reg [ADDR_SIZE_IM-1:0] wishbone_address_to_write_instruction_memory;

reg [ADDR_SIZE_IM-1:0] wishbone_address_to_read_input_buffer;
reg [ADDR_SIZE_IM-1:0] wishbone_address_to_write_input_buffer;


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



reg [ARRAY_DEPTH-1:0] COL_START_MAC_IF;
reg [ARRAY_DEPTH-1:0] COL_END_MAC_IF;
reg [ARRAY_DEPTH-1:0] ROW_START_MAC_IF;
reg [ARRAY_DEPTH-1:0] ROW_END_MAC_IF;


instruction_decoder_RRAM U_instruction_decoder_RRAM(.clk(clk),  
.rst(rst), 
.instruction(data_out_instruction_memory), 
.IN0_BL(IN0_BL),
.IN1_BL(IN1_BL),
.IN0_WL(IN0_WL_from_ID),
.IN1_WL(IN1_WL_from_ID),
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
.SAEN_CSA2(SAEN_CSA2),
.mac_mux(mac_mux_from_ID),
.enable_IM(enable_IM),
.COL_START_MAC(COL_START_MAC_IF),
.COL_END_MAC(COL_END_MAC_IF),
.ROW_START_MAC(ROW_START_MAC_IF),
.ROW_END_MAC(ROW_END_MAC_IF)
);


reg [ARRAY_SIZE-1:0]data_out_input_buffer_masked0; 
reg [ARRAY_SIZE-1:0]data_out_input_buffer_masked1; 

assign IN0_WL = mac_mux_from_ID ?  data_out_input_buffer_masked0 : IN0_WL_from_ID  ; //0,0 is the ON voltage for WL
assign IN1_WL = mac_mux_from_ID ?  data_out_input_buffer_masked1 : IN1_WL_from_ID ; //0,0 is the ON voltage for WL



always  @ (posedge clk or negedge rst)
begin : PC 
  if (!rst) begin

#2 
     wishbone_address_to_read_instruction_memory <= '0;
     wishbone_rd_cs_instruction_memory <=  0;
     wishbone_rd_en_instruction_memory <=  0;
     enable_IM <= 0  ; 
    enable_IM_pipe1 <=0; 

  end else if (enable_PC_IM ) begin 

#2
     wishbone_address_to_read_instruction_memory  <= start_PC_IM_address ;
     wishbone_rd_cs_instruction_memory <=  1;
     wishbone_rd_en_instruction_memory <=  1;
     enable_IM_pipe1 <= 1 ; 
     enable_IM <=  enable_IM_pipe1; 

  end
end



always  @ (posedge clk or negedge rst)
begin : MAC_OPERATION_WITH_IF 
  if (!rst) begin

#2 
    
	wishbone_rd_cs_input_buffer   <= 0 ; 
	wishbone_rd_en_input_buffer	 <= 0 ;
	wishbone_address_to_read_input_buffer <=0 ; 

  end else if ( mac_mux_from_ID ) begin 

#2
   
	wishbone_rd_cs_input_buffer   <= 1 ; 
	wishbone_rd_en_input_buffer	 <= 1 ;
	wishbone_address_to_read_input_buffer <=0 ; 

  end
end




endmodule
