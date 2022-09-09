// Function    : Synchronous read write RAM 
module vector_register_file_sram_tb ( ); 

vector_register_file_sram uut( 
clk         , // Clock Input
address     , // Address Input
data        , // Data bi-directional
cs          , // Chip Select
we          , // Write Enable/Read Enable
oe            // Output Enable
); 



parameter DATA_WIDTH = 32 ;
parameter ADDR_WIDTH = 5 ;
parameter RAM_DEPTH = 1 << ADDR_WIDTH;

//--------------Input Ports----------------------- 
reg                   clk         ;
reg  [ADDR_WIDTH-1:0] address     ;
reg                   cs          ;
reg                   we          ;
reg                   oe          ; 

//--------------Inout Ports----------------------- 
wire  [DATA_WIDTH-1:0]  data       ;
reg  [DATA_WIDTH-1:0]  tb_data       ;

assign data = !oe ? tb_data : 32'hz;


initial begin
	#3
	clk =0;

	#11 
	we = 0 ; 
       	oe = 1 ; 
	cs = 0 ;

	#15 // write  
	
	we = 1 ; 
	cs = 1 ;
	address = 0; 
	tb_data = 1;
        oe = 0;	

	#15 //read 
	
	we = 0 ; 
	cs = 1 ;
	oe =1 ; 
	address = 0; 

	

	
	#15  //write 
	
	we = 1 ; 
	cs = 1 ;
	address = 1 ; 
	tb_data = 3 ; 

	#15 //read
	
	we = 0 ; 
	cs = 1 ;
	oe =1 ; 
	address = 1; 


	#15 // write  
	
	we = 1 ; 
	cs = 1 ;
	address = 5; 
	tb_data = 6;
        oe = 0;	


	
	#15 //read 
	
	we = 0 ; 
	cs = 1 ;
	oe =1 ; 
	address = 5; 

	#15 //read 
	
	we = 0 ; 
	cs = 1 ;
	oe =1 ; 
	address = 8; 

	#15 //read 
	
	we = 0 ; 
	cs = 1 ;
	oe =1 ; 
	address = 12; 





	#100 $finish;
end




	 always  begin
    		#5 clk = !clk;  
	 end






initial  begin
    $dumpfile ("vector_register_file_tb.vcd"); 
    $dumpvars; 
  end 







endmodule // End of Module ram_sp_sr_sw
