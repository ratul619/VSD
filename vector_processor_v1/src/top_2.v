module top  (clk, 
	rstn, 
	vector_instruction , start   ); 


input clk ,rstn , start  ; 
input	[31:0]    vector_instruction;

reg enable_decoder;


wire  [2:0]ALU_op_from_decoder; 
wire  [4:0]address_s1_from_decoder; 
wire  [4:0]address_s2_from_decoder;  
wire  [4:0]address_destination_from_decoder;
wire  is_alu_op;
wire  is_load_store_op;
wire  is_vlen_op;





wire  [2:0]vsew;
wire  [1:0]vlmul;
wire  [1:0]vdiv; 
wire  [4:0]rd;
wire  [4:0]rs1;
wire  [4:0]rs2;
wire   vm;


always @(posedge clk or negedge rstn ) begin

	if (!rstn ) begin 
	enable_decoder <=0 ; 
	end 
	else if (start) begin 
	enable_decoder <=1 ; 
	end
end





(* keep *) controller U_controller (.rstn(rstn),
.clk(clk),
.ALU_op_from_decoder(ALU_op_from_decoder) ,	
.address_s1_from_decoder(address_s1_from_decoder) , 
.address_s2_from_decoder(address_s2_from_decoder) ,  
.address_destination_from_decoder(address_destination_from_decoder) , 
.is_alu_op(is_alu_op),
.is_load_store_op(is_load_store_op),
.is_vlen_op(is_vlen_op)); 


(* keep *) decoder  U_decoder (.clk(clk), 
.enable(enable_decoder) , 
.rstn(rstn), 
.vector_instruction(vector_instruction)  ,
.ALU_op_from_decoder(ALU_op_from_decoder),	
.address_s1_from_decoder(address_s1_from_decoder),
.address_s2_from_decoder(address_s2_from_decoder),
.address_destination_from_decoder(address_destination_from_decoder),
.vm(vm),  
.vlmul(vlmul),
.vsew(vsew),
.vdiv(vdiv),
.rd(rd),
.rs1(rs1),
.rs2(rs2),
.is_alu_op(is_alu_op),
.is_load_store_op(is_load_store_op),
.is_vlen_op(is_vlen_op)); 





endmodule 

