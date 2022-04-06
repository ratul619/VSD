
//vmacc.vv vd, vs1, vs2, vm    # vd[i] = +(vs1[i] * vs2[i]) + vd[i]
`include	"opcode.h"


module decoder  (clk, 
	enable , 
	rstn, 
	vector_instruction  ,
        ALU_op_from_decoder,	
	address_s1_from_decoder,
	address_s2_from_decoder,
	address_destination_from_decoder,
	vm,  
	vlmul,
	vsew,
	vdiv,
	rd,
	rs1,
	rs2,
	is_alu_op,
	is_load_store_op,
	is_vlen_op); 


input clk ,rstn , enable ; 





//decoder related 
input	[31:0]    vector_instruction;


output reg  [4:0]address_s1_from_decoder ; 
output reg  [4:0]address_s2_from_decoder ; 
output reg  [4:0]address_destination_from_decoder ; 

output reg [2:0] ALU_op_from_decoder  ; 


//setvl{i} 
output reg [2:0]vsew;
output reg [1:0]vlmul;
output reg [1:0]vdiv; 
output reg [4:0]rd;
output reg [4:0]rs1;
output reg [4:0]rs2;

output reg  vm;

output reg 	is_alu_op;
output reg 	is_load_store_op;
output reg 	is_vlen_op;






always @(posedge clk or negedge rstn ) begin

	if (!rstn ) begin 

address_s1_from_decoder  		= 0 ; 
address_s2_from_decoder  		= 0 ; 
address_destination_from_decoder 	= 0 ; 
ALU_op_from_decoder  			= 0 ; 
vsew 					= 0 ;
vlmul 					= 0 ;
vdiv 					= 0 ; 
rd 					= 0 ;
rs1 					= 0 ;
rs2 					= 0 ;
is_alu_op 				= 0 ;
is_load_store_op 			= 0 ;
is_vlen_op 				= 0 ;

	end 

else begin 




//setvl instruction first 
    		case (vector_instruction[6:0])
		
			
			`IS_SET_VL : 
				begin 

				case (vector_instruction[31])
					
				1'b0 :  //This is setvl 
					begin	
					rd  = vector_instruction[11:7]; 
					rs1 = vector_instruction[19:15]; 
					rs2 = vector_instruction[24:20];	
					end 
				1'b1 : // This is setvli 
					begin 
					vsew 	= vector_instruction[14:12];
					vlmul	= vector_instruction[11:10] ;
					vdiv	= vector_instruction[16:15]; 
					rd	= vector_instruction[11:7];
					rs1	= vector_instruction[19:15];
					end

				endcase	

	
				end 
		endcase 
		
// Need to distinguish first whether this is VV or VX type of operation. 
// In the 32b instruction its the 14-12 bits ie 3 bits wide
// Right now supporting VV or VX
    		case (vector_instruction[14:12])
	        

                `IS_VX_TYPE : 
                    begin 
            
                    //VV  	31 - 26 	25 	24-20 	19-15 	14-12 	11-7 	6-0
                    //	        funct6 		vm 	vs2 	vs1 	000 	vd 	VV
                    vm <=   vector_instruction[25];
                    address_s1_from_decoder <=  vector_instruction[19:15];
                    address_s2_from_decoder <=  vector_instruction[24:20];
                    address_destination_from_decoder  <=  vector_instruction[11:7];
	

		//Error insert VX type here 


                end

                `IS_VV_TYPE : 
                    begin 
            
                    vm <=   vector_instruction[25];
                    address_s1_from_decoder <=  vector_instruction[19:15];
                    address_s2_from_decoder <=  vector_instruction[24:20];
                    address_destination_from_decoder  <=  vector_instruction[11:7];
		    is_alu_op 				= 1 ;
		    is_load_store_op 			= 0 ;
		    is_vlen_op 				= 0 ;



                            case (vector_instruction[31:26]) 

                       `VV_vadd : 

			ALU_op_from_decoder 	<= 3'b000; 					       
                        
			
                       `VV_mult : 

			ALU_op_from_decoder 	<= 3'b001; 		

       			`VV_vsub : 

			ALU_op_from_decoder 	<= 3'b010; 		


			`VV_macc : 

			ALU_op_from_decoder 	<= 3'b011; 		





                            endcase 
                end


    endcase
    end



end






endmodule


