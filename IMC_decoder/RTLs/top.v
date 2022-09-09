


module top ( 
clk, 
rstn, 
enable , 
address_start , 
MAJ_OP_REG); 

input clk , rstn ; 

output reg [4:0]address_start; 
output reg [31:0]MAJ_OP_REG; 

output reg enable;

wire [31:0]data_bus_MIG_mem; 

wire [4:0]address_MIG;

vector_register_file_sram  U_MIG_MEM(
.clk(clk),          // Clock Input
.address(address_MIG),      // Address Input
.data(data_bus_MIG_mem),         // Data bi-directional
.cs(CS),           // Chip Select
.we(WE),           // Write Enable/Read Enable
.oe(OE)            // Output Enable
); 



maj_state_machine_3x8_decoder  U_statemachine(.clk(clk), 
	.in(), 
	.rstn(rstn), 
	.enable(enable) , 
	.address_start(address_start) , 
	.execute_MIG(execute_MIG) ,
        .data_bus_MIG_mem(data_bus_MIG_mem), 	
	.WE(WE) , 
	.CS(CS) , 
	.OE(OE) , 
	.address_MIG(address_MIG) , 
	.MAJ_OP_REG(MAJ_OP_REG)  );



always @ (posedge clk  or  negedge rstn ) begin

if (!rstn) 
begin

	MAJ_OP_REG[31:0] =  0;
        enable = 0 ; 	

end	
else begin 
	MAJ_OP_REG[31] =  1'b0; 
	MAJ_OP_REG[30] =  1'b1; 
	MAJ_OP_REG[29] =  1'b1; 
	MAJ_OP_REG[28] =  1'b0; 
	MAJ_OP_REG[27] =  1'b1; 
	MAJ_OP_REG[26:0] = 0 ;  
	enable = 1;
        address_start = 5'b00011;	
	
	end 
end

endmodule 



module maj_state_machine_3x8_decoder (clk, 
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

input   clk, in, rstn , enable ;
input   [31:0]MAJ_OP_REG; 
input   [4:0] address_start;

inout  [31:0]data_bus_MIG_mem;
reg  [31:0]data_bus_MIG_mem_reg_in ;
reg  [31:0]data_bus_MIG_mem_reg_out ;

wire mem_read; 
wire mem_write; 

assign mem_read = CS && ! WE && OE;
assign mem_write = CS && WE ;


output reg [4:0] address_MIG;
output reg WE , CS , OE , execute_MIG ; 

reg out_reg ;

reg     [2:0]state;
    
parameter S0 = 0, S1 = 1, S2 = 2 , S3 = 3 , S4 = 4 , S5=5 , S6=6;

assign data_bus_MIG_mem = out_reg ? data_bus_MIG_mem_reg_out : 32'bz;



always @ (state) begin
case (state)
S0:
begin
  address_MIG <= 'hz;
  out_reg = 0; 	
	WE = 0;
       	OE = 1;
       	CS = 1;	
	data_bus_MIG_mem_reg_in =0;
end 	


S1: 
begin // Read 
	out_reg = 0; 	
	execute_MIG =1;
	address_MIG = 1 ; 
	WE = 0;
       	OE = 1;
       	CS = 1;	
	//Read from databus 
	
		
end 

S2:
begin // Wait for memory response in next cycle and register input to  data_bus_MIG_mem_reg_in
	data_bus_MIG_mem_reg_in  = data_bus_MIG_mem;

end
	


S3:
begin // Write to memory  
	out_reg = 1; 	
	
	data_bus_MIG_mem_reg_out[31] = MAJ_OP_REG[4]   ; // c 
	data_bus_MIG_mem_reg_out[30] = data_bus_MIG_mem_reg_in[30];   // n11
	data_bus_MIG_mem_reg_out[29] = data_bus_MIG_mem_reg_in[29];   // n12
	data_bus_MIG_mem_reg_out[28] = data_bus_MIG_mem_reg_in[31];   // n8 
	data_bus_MIG_mem_reg_out[27] = MAJ_OP_REG[4]  ; // c 
	data_bus_MIG_mem_reg_out[26] = MAJ_OP_REG[2]  ; // a 
	data_bus_MIG_mem_reg_out[25] = MAJ_OP_REG[2]  ; // a 
	data_bus_MIG_mem_reg_out[24] = data_bus_MIG_mem_reg_in[28] ;   // n14 
	data_bus_MIG_mem_reg_out[23:0] = 0 ; 

	address_MIG = address_MIG + 1; 
	WE = 1; 
       	CS = 1 ; //Write to mem
	OE = 0 ; 

end
	
	


	
S4:
begin //Write memory again  

	
	out_reg = 1; 	


	data_bus_MIG_mem_reg_out[31] = MAJ_OP_REG[4] ;  // c 
	data_bus_MIG_mem_reg_out[30] = data_bus_MIG_mem_reg_in[30] ;  // n11
	data_bus_MIG_mem_reg_out[29] = data_bus_MIG_mem_reg_in[29] ;  // n12
	data_bus_MIG_mem_reg_out[28] = data_bus_MIG_mem_reg_in[31] ;  // n8 
	data_bus_MIG_mem_reg_out[27] = MAJ_OP_REG[4];   // c 
	data_bus_MIG_mem_reg_out[26] = MAJ_OP_REG[2];   // a 
	data_bus_MIG_mem_reg_out[25] = MAJ_OP_REG[2];   // a 
	data_bus_MIG_mem_reg_out[24] = data_bus_MIG_mem_reg_in[28]  ; // n14 
	data_bus_MIG_mem_reg_out[23:0] = 0 ; 

	data_bus_MIG_mem_reg_out = 3; 


	address_MIG = address_MIG + 1; 

	WE = 1 ; 
       	CS = 1 ; //Write to mem
	OE = 0 ; 
end
S5:
begin // Read in next cycle for same address : and check if value matches 
	out_reg = 0; 	
	WE = 0;
       	OE = 1;
       	CS = 1;	
	//Read from databus 
	
	//data_bus_MIG_mem_reg_in  = data_bus_MIG_mem;

	


end


S6:
begin // Wait for one more cycle for data to come back and latch 
	out_reg = 0; 	
	WE = 0;
       	OE = 1;
       	CS = 1;	
	//Read from databus 
	
	data_bus_MIG_mem_reg_in  = data_bus_MIG_mem;

	


end



endcase
end


always @ (posedge clk  or  negedge rstn ) begin

if (!rstn) 
begin
	address_MIG <= 0 ;
	CS <= 0 ;
	execute_MIG  <= 0 ; 
	state <= S0;

end	
	
else if (enable)
	case (state)
	   	S0:
      			state <= S1;
   		S1:
         		state <= S2;
   		S2:
         		state <= S3;

		S3:
         		state <= S4;

		S4:
         		state <= S5;
		S5:
         		state <= S6;


		S6:
         		state <= S0;


endcase
end
endmodule
