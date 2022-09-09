//-----------------------------------------------------
// Design Name : syn_fifo
// File Name   : syn_fifo.v
// Function    : Synchronous (single clock) FIFO
//-----------------------------------------------------
module sync_fifo_output_buffer (
clk      , // Clock input
rst      , // Active high reset
wr_cs    , // Write chip select
rd_cs    , // Read chipe select
data_in  , // Data input
rd_en    , // Read enable
wr_en    , // Write Enable
data_out , // Data Output
empty    , // FIFO empty
full ,      // FIFO full
address_to_write,
address_to_read
);    
 
// FIFO constants
parameter DATA_WIDTH = 32;
parameter ADDR_WIDTH = 7;
parameter RAM_DEPTH = 64;
// Port Declarations
input clk ;
input rst ;
input wr_cs ;
input rd_cs ;
input rd_en ;
input wr_en ;
input [DATA_WIDTH-1:0] data_in ;
output full ;
output empty ;
output [DATA_WIDTH-1:0] data_out ;

input [ADDR_WIDTH-1:0] address_to_write ;
input [ADDR_WIDTH-1:0] address_to_read;
//-----------Internal variables-------------------
reg [ADDR_WIDTH-1:0] wr_pointer;
reg [ADDR_WIDTH-1:0] rd_pointer;
reg [ADDR_WIDTH :0] status_cnt;
reg [DATA_WIDTH-1:0] data_out ;
wire [DATA_WIDTH-1:0] data_ram ;

//-----------Variable assignments---------------
assign full = (status_cnt == (RAM_DEPTH-1));
assign empty = (status_cnt == 0);

//-----------Code Start---------------------------
always @ (posedge clk or negedge rst)
begin : WRITE_POINTER
  if (!rst) begin
 #2   wr_pointer <= 0;
  end else if (wr_cs && wr_en ) begin
 #2   wr_pointer <= address_to_write ;
  end
end

always @ (posedge clk or negedge rst)
begin : READ_POINTER
  if (!rst) begin
  #2  rd_pointer <= 0;
  end else if (rd_cs && rd_en ) begin
  #2  rd_pointer <= address_to_read ;
  end
end

always  @ (posedge clk or negedge rst)
begin : READ_DATA
  if (!rst) begin
  #2  data_out <= 0;
  end else if (rd_cs && rd_en ) begin
  #2  data_out <= data_ram;
  end
end


ram_dp_ar_aw_OF #(DATA_WIDTH,ADDR_WIDTH)DP_RAM_OF (
.address_0 (wr_pointer) , // address_0 input 
.data_0    (data_in)    , // data_0 bi-directional
.cs_0      (wr_cs)      , // chip select
.we_0      (wr_en)      , // write enable
.oe_0      (1'b0)       , // output enable
.address_1 (rd_pointer) , // address_q input
.data_1    (data_ram)   , // data_1 bi-directional
.cs_1      (rd_cs)      , // chip select
.we_1      (1'b0)       , // Read enable
.oe_1      (rd_en)	        // output enable
);    (*keep*) 




always @ (posedge clk or negedge rst)
begin : STATUS_COUNTER
  if (!rst) begin
    status_cnt <= 0;
  // Read but no write.
  end else if ((rd_cs && rd_en) && !(wr_cs && wr_en) 
                && (status_cnt != 0)) begin
  #2  status_cnt <= status_cnt - 1;
  // Write but no read.
  end else if ((wr_cs && wr_en) && !(rd_cs && rd_en) 
               && (status_cnt != RAM_DEPTH)) begin
  #2  status_cnt <= status_cnt + 1;
  end
end 
   


endmodule
