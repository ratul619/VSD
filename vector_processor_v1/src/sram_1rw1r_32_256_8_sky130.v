// OpenRAM SRAM model
// Words: 256
// Word size: 32
// Write size: 8

module sram_1rw1r_32_256_8_sky130_top(
// Port 0: RW
    clk0,csb0,web0,wmask0,addr0,din0,dout0,
// Port 1: R
    clk1,csb1,addr1,dout1
  );

  parameter NUM_WMASKS = 4 ;
  parameter DATA_WIDTH = 32 ;
  parameter ADDR_WIDTH = 8 ;
  parameter RAM_DEPTH = 1 << ADDR_WIDTH;
  // FIXME: This delay is arbitrary.
  parameter DELAY = 3 ;

  input  clk0; // clock
  input   csb0; // active low chip select
  input  web0; // active low write control
  input [NUM_WMASKS-1:0]   wmask0; // write mask
  input [ADDR_WIDTH-1:0]  addr0;
  input [DATA_WIDTH-1:0]  din0;
  output [DATA_WIDTH-1:0] dout0;
  input  clk1; // clock
  input   csb1; // active low chip select
  input [ADDR_WIDTH-1:0]  addr1;
  output [DATA_WIDTH-1:0] dout1;


sram_1rw1r_32_256_8_sky130 U_sram_1rw1r_32_256_8_sky130 (.clk0(clk0) ,.csb0(csb0) ,.web0(web0) ,.wmask0(wmask0) ,.addr0(addr0) ,.din0(din0) ,.dout0(dout0) ,.clk1(clk1) ,.csb1(csb1) ,.addr1(addr1) ,.dout1(dout1) );




endmodule
