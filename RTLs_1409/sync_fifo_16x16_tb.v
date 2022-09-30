`timescale 1ns / 1ps
module sync_fifo_16x16_tb ();    

sync_fifo_16x16 uut (
.clk      , // Clock input
.rst      , // Active high reset
.wr_cs    , // Write chip select
.rd_cs    , // Read chipe select
.data_in  , // Data input
.rd_en    , // Read enable
.wr_en    , // Write Enable
.data_out , // Data Output
.empty    , // FIFO empty
.full ,      // FIFO full
.address_to_write,
.address_to_read
);    

// FIFO constants
parameter DATA_WIDTH = 16;
parameter ADDR_WIDTH = 4;
parameter RAM_DEPTH = 16;

 
// FIFO constants
// Port Declarations
reg  clk ;
reg  rst ;
reg  wr_cs ;
reg  rd_cs ;
reg  rd_en ;
reg  wr_en ;
reg  [DATA_WIDTH-1:0] data_in ;
wire  full ;
wire  empty ;
wire  [DATA_WIDTH-1:0] data_out ;

reg  [ADDR_WIDTH-1:0] address_to_write ;
reg  [ADDR_WIDTH-1:0] address_to_read;
//-----------Internal variables-------------------



    always  begin
    #5 clk = !clk;  
	 end



    initial begin


	#5 rst = 1;  clk = 0 ;
	#5 rst = 0; 
	#5 rst = 1; 


	wr_cs = 1; 
	wr_en = 1; 
	rd_cs = 0; 
	rd_en = 0; 


        //$monitor(clk,b,c,d,out);
        for (int i=0; i<17; i=i+1) begin
            address_to_write = i ; 
	    data_in = i + 1;
            #10; 

		


        end 

	wr_cs = 0; 
	wr_en = 0; 
	rd_cs = 1; 
	rd_en = 1; 




        //$monitor(clk,b,c,d,out);
        for (int i=0; i<17; i=i+1) begin
            address_to_read = i ; 
            #10; 

        end 

	wr_cs = 0; 
	wr_en = 0; 
	rd_cs = 0; 
	rd_en = 0; 




  #600 $finish; 


    end




initial  begin
    $dumpfile ("sync_fifo_16x16_tb.vcd"); 
    $dumpvars; 
  end 



endmodule


