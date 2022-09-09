module maj_state_machine_3x8_decoder_tb ();


 maj_state_machine_3x8_decoder uut (clk, 
	in, 
	rstn, 
	enable , 
	address_start , 
	execute_MIG ,
        data_bus_MIG_mem, 	
	WE , 
	CS , 
	OE , 
	address_MIG , 
	MAJ_OP_REG  );



reg    clk, in, rstn , enable ;
reg    [31:0]MAJ_OP_REG; 
reg    [4:0] address_start;

wire  [31:0]data_bus_MIG_mem;



wire [4:0]address_MIG;
wire WE , CS , OE , execute_MIG ; 


	initial begin 


	#5 

	rstn = 0;
	enable = 0; 
        	
	clk = 0 ; 
	#10 
	rstn = 1 ;  
	enable = 1; 
	MAJ_OP_REG[31] =  1'b0; 
	MAJ_OP_REG[30] =  1'b1; 
	MAJ_OP_REG[29] =  1'b1; 
	MAJ_OP_REG[28] =  1'b0; 
	MAJ_OP_REG[27] =  1'b1; 
	MAJ_OP_REG[26:0] = 0 ;  
	address_start = 5'b00011;

	#80 
	$finish;


	end
	




	 always  begin
    		#5 clk = !clk;  
	 end
	 
initial  begin
    $dumpfile ("maj_statemachine_tb.vcd"); 
    $dumpvars; 
  end 














endmodule
