module controller  (rstn,
clk,
ALU_op_from_decoder ,	
address_s1_from_decoder , 
address_s2_from_decoder ,  
address_destination_from_decoder , 
is_alu_op,
is_load_store_op,
is_vlen_op); 





input clk , rstn ; 

input [2:0]ALU_op_from_decoder; 

input [4:0]address_s1_from_decoder; 
input [4:0]address_s2_from_decoder;  
input [4:0]address_destination_from_decoder;

input is_alu_op;
input is_load_store_op;
input is_vlen_op;






reg [3:0]ALU_Enable_for_lanes; 




reg   [3:0]WE_lane[3:0];
reg   [3:0]OE_lane[3:0];
reg   [3:0]CS_lane[3:0];



wire  [63:0]data_bus_bank_lane[3:0][3:0];
reg  [63:0]data_bus_bank_lane_temp[3:0][3:0];
reg   [6:0]address_bus_bank_lane[3:0][3:0];





//Registers for vlen,sew etc 
// Set default values in vtype register 
//Vector length register vl
//Vector type register vtype
//16bits regs 
// vlmul[1:0] = [1:0]vtype; 
// vsew[2:0]  = [4:2]vtype; 
// vediv[1:0] =  [6:5]vtype;  
reg [15:0]vtype ; 

integer VLEN =  256; 
integer DATABUS_WIDTH =  64; 
integer num_lanes = 4;


integer SEW  ; 
integer num_vector_iterations ; 


 reg [2:0]ALU_Sel_for_lane[3:0]; 


reg [2:0]num_bits_to_operate[3:0];

reg [4:0]start_address_in_lanes ; 

reg  [2:0]bank_no_vs1;
reg  [2:0]bank_no_vs2;
reg  [2:0]bank_no_vd;

reg [4:0]starting_address_vs1;
reg [4:0]starting_address_vs2;
reg [4:0]starting_address_vd;

integer ii;

reg [63:0]fpu_out_lane[3:0];


generate
  genvar i , j;
  for (i=0; i<4; i=i+1) begin : lane
  	for (j=0; j<4; j=j+1) begin : sram
 
vector_register_file_sram U_vector_register_file_sram_lane_bank (.clk(clk) ,  .address(address_bus_bank_lane[i][j]) ,.data(data_bus_bank_lane[i][j]) , .we(WE_lane[i][j])  , .oe(OE_lane[i][j])  , .cs(CS_lane[i][j]) ) ;

	end 


  end
endgenerate





always @(posedge clk or negedge rstn ) begin

	if (!rstn ) begin 

	

ALU_Enable_for_lanes = 0 ; 

ALU_Sel_for_lane[0] = 0 ; 
ALU_Sel_for_lane[1] = 0 ; 
ALU_Sel_for_lane[2] = 0 ; 
ALU_Sel_for_lane[3] = 0 ; 









 vtype[2:0] 	=  0 	; //  vlmul = no grouping
 vtype[5:3] 	=  0	; //  vsew = 32 
 vtype[6] 	=  0	;  // vta 
 vtype[7] 	=  0	;  // vma


	  for (ii=0; ii<4; ii=ii+1)
        	begin
		WE_lane[ii] = 0 ;
		OE_lane[ii] = 0 ;
		CS_lane[ii] = 0 ;
		end
end 

else  if (is_alu_op) begin 

//if alu_op then enable ALU. 
// vd[i] = vs1[i]  + vs2[i] ; 

//For i = 0 ; i < VLEN/SEW*num_lanes ; i++ 
//Vd[ (4*i+1)sew-1:4*i*sew] = vs1[ (4*i+1)sew-1:4*i*sew] + vs2[ (4*i+1)sew-1:4*i*sew] 
//Vd[(4*i+2)*sew-1: (4*i+1)*sew] = vs1[(4*i+2)*sew-1: (4*i+1)*sew] + vs2[(4*i+2)*sew-1: (4*i+1)*sew] 
//Vd[ (4*i+3)*sew-1: (4*i+2)*sew] = vs1[(4*i+3)*sew-1: (4*i+2)*sew] + vs2[(4*i+3)*sew-1: (4*i+2)*sew] 
//Vd[ (4*i+4)*sew-1 : (4*i+3)*sew] = vs1[(4*i+4)*sew-1 : (4*i+3)*sew] + vs2[(4*i+4)*sew-1 : (4*i+3)*sew]   




	if (vtype[5:3] == 0) begin 
	SEW  = 8;  
	num_bits_to_operate[0] = 0 ; 
	num_bits_to_operate[1] = 0 ; 
	num_bits_to_operate[2] = 0 ; 
	num_bits_to_operate[3] = 0 ; 
	end  else if (vtype[5:3] == 1)  begin 
	SEW  = 16; 
	num_bits_to_operate[0] = 1 ; 
	num_bits_to_operate[1] = 1 ; 
	num_bits_to_operate[2] = 1 ; 
	num_bits_to_operate[3] = 1 ; 
	end  else if (vtype[5:3] == 2)  begin 
	SEW  = 32; 
	num_bits_to_operate[0] = 2 ; 
	num_bits_to_operate[1] = 2 ; 
	num_bits_to_operate[2] = 2 ; 
	num_bits_to_operate[3] = 2 ; 
	end else if (vtype[5:3] == 3)   begin 
	SEW  = 64; 
	num_bits_to_operate[0] = 3 ; 
	num_bits_to_operate[1] = 3 ; 
	num_bits_to_operate[2] = 3 ; 
	num_bits_to_operate[3] = 3 ; 
	end


     bank_no_vs1  = address_s1_from_decoder/SEW; 
     bank_no_vs2  = address_s2_from_decoder/SEW; 
     bank_no_vd  =  address_destination_from_decoder/SEW; 



	if (ALU_op_from_decoder == 0) begin 
	ALU_Enable_for_lanes[0]    = 1; 
	ALU_Sel_for_lane[0] 	= 0;
	ALU_Sel_for_lane[1]	= 0;
	ALU_Sel_for_lane[2]	= 0;	
	ALU_Sel_for_lane[3]	= 0;

	//For vdd 
	
	  for (ii=0; ii<4; ii=ii+1)
        	begin
		select_bank_databus_to_A_lane[ii] = bank_no_vs1 ;
		select_bank_databus_to_B_lane[ii] = bank_no_vs2;
		select_bank_databus_to_C_lane[ii] = 0;
		end
	end 
	else if (ALU_op_from_decoder == 1) begin 
	ALU_Enable_for_lanes[1] = 1; 
	ALU_Sel_for_lane[0] 	= 1;
	ALU_Sel_for_lane[1]	= 1;
	ALU_Sel_for_lane[2]	= 1;	
	ALU_Sel_for_lane[3]	= 1;
	end 	
	else if (ALU_op_from_decoder == 2) begin 
	ALU_Enable_for_lanes[2] = 1; 
	ALU_Sel_for_lane[0] 	= 2;
	ALU_Sel_for_lane[1]	= 2;
	ALU_Sel_for_lane[2]	= 2;	
	ALU_Sel_for_lane[3]	= 2;
	end else if (ALU_op_from_decoder == 3) begin 
	ALU_Enable_for_lanes[3] = 1; 
	ALU_Sel_for_lane[0] 	= 3;
	ALU_Sel_for_lane[1]	= 3;
	ALU_Sel_for_lane[2]	= 3;	
	ALU_Sel_for_lane[3]	= 3;
	end 	




    


  
     starting_address_vs1 = SEW  * (address_s1_from_decoder  - 			(8 * bank_no_vs1 )) ; 
     starting_address_vs2 = SEW  * (address_s2_from_decoder  - 			(8 * bank_no_vs2 )) ; 
     starting_address_vd =  SEW  * (address_destination_from_decoder  - 	(8 * bank_no_vd )) ; 


     num_vector_iterations = VLEN/(SEW*num_lanes);




end

end 

reg [4:0]loopcount; 
reg [4:0]addressIncrRead; 
reg [4:0]addressIncrWrite; 
reg doneAluOp; 
reg StartWriteMem; 
reg pipeline_StartWriteMem; 

always @(posedge clk or negedge rstn )
if(!rstn) begin
   loopcount   <= 0;
   doneAluOp   <= 0;
   addressIncrRead <= 0; 
   addressIncrWrite <= 0; 
   StartWriteMem <= 0; 
   pipeline_StartWriteMem <=0;
end else if (is_alu_op) begin
	if(!doneAluOp) begin 
        loopcount <= loopcount + 1;
	       
	   

		address_bus_bank_lane[0][bank_no_vs1] =  starting_address_vs1 +  addressIncrRead		;
		address_bus_bank_lane[0][bank_no_vs2] =  starting_address_vs1 + addressIncrRead		;
		
		address_bus_bank_lane[1][bank_no_vs1] = starting_address_vs1 + addressIncrRead	;
		address_bus_bank_lane[1][bank_no_vs2] = starting_address_vs2 + addressIncrRead	;
		//address_bus_bank_lane[1][bank_no_vd] =  starting_address_vd +  addressIncrRead;


		address_bus_bank_lane[2][bank_no_vs1] = starting_address_vs1 +	addressIncrRead	;
		address_bus_bank_lane[2][bank_no_vs2] = starting_address_vs2 +	addressIncrRead	;
		//address_bus_bank_lane[2][bank_no_vd] =  starting_address_vd + 	addressIncrRead;



		address_bus_bank_lane[3][bank_no_vs1] = starting_address_vs1 + 	addressIncrRead	;
		address_bus_bank_lane[3][bank_no_vs2] = starting_address_vs2 + 	addressIncrRead	;


		WE_lane[0][bank_no_vs1] = 0 					; 
		OE_lane[0][bank_no_vs1] = 1					; 
		CS_lane[0][bank_no_vs1] = 1					;


		WE_lane[1][bank_no_vs1] = 0 					; 
		OE_lane[1][bank_no_vs1] = 1 					; 
		CS_lane[1][bank_no_vs1] = 1 					;

		
		WE_lane[2][bank_no_vs1] = 0 					; 
		OE_lane[2][bank_no_vs1] = 1 					; 
		CS_lane[2][bank_no_vs1] = 1 					;

		
		WE_lane[3][bank_no_vs1] = 0 					; 
		OE_lane[3][bank_no_vs1] = 1 					; 
		CS_lane[3][bank_no_vs1] = 1 					;


		WE_lane[0][bank_no_vs2] = 0 					; 
		OE_lane[0][bank_no_vs2] = 1					; 
		CS_lane[0][bank_no_vs2] = 1					;


		WE_lane[1][bank_no_vs2] = 0 					; 
		OE_lane[1][bank_no_vs2] = 1 					; 
		CS_lane[1][bank_no_vs2] = 1 					;

		
		WE_lane[2][bank_no_vs2] = 0 					; 
		OE_lane[2][bank_no_vs2] = 1 					; 
		CS_lane[2][bank_no_vs2] = 1 					;

		
		WE_lane[3][bank_no_vs2] = 0 					; 
		OE_lane[3][bank_no_vs2] = 1 					; 
		CS_lane[3][bank_no_vs2] = 1 					;
		addressIncrRead <= addressIncrRead +1;
	
		pipeline_StartWriteMem <= 1'b1; 
		StartWriteMem <= pipeline_StartWriteMem;  


	 if (StartWriteMem ) begin

		
		address_bus_bank_lane[0][bank_no_vd] =  starting_address_vd + addressIncrWrite 		;
		address_bus_bank_lane[1][bank_no_vd] =  starting_address_vd + addressIncrWrite		;
		address_bus_bank_lane[2][bank_no_vd] =  starting_address_vd + addressIncrWrite		;
		address_bus_bank_lane[3][bank_no_vd] =  starting_address_vd + addressIncrWrite		;

		WE_lane[0][bank_no_vd] = 1 					; 
		CS_lane[0][bank_no_vd] = 1					;


		WE_lane[1][bank_no_vd] = 1 					; 
		CS_lane[1][bank_no_vd] = 1 					;

		
		WE_lane[2][bank_no_vd] = 1 					; 
		CS_lane[2][bank_no_vd] = 1 					;

		
		WE_lane[3][bank_no_vd] = 1 					; 
		CS_lane[3][bank_no_vd] = 1 					;

		addressIncrWrite <= addressIncrWrite +1;

		//StartWriteMem <= 0; 
		

	for (ii=0; ii<4; ii=ii+1)
       	begin
		data_bus_bank_lane_temp[ii][bank_no_vd]  = fpu_out_lane[ii];
          	
        end



	end 

    	if(loopcount == num_vector_iterations) begin 
	    
	     	doneAluOp <= 1;
	 	loopcount <= 0 ;
  	end

 
	
	end

end


reg [1:0]select_bank_databus_to_A_lane[3:0];
reg [1:0]select_bank_databus_to_B_lane[3:0];
reg [1:0]select_bank_databus_to_C_lane[3:0];

wire [63:0]input_A_lane_from_bank[3:0];
wire [63:0]input_B_lane_from_bank[3:0];
wire [63:0]input_C_lane_from_bank[3:0];


mux41  U_mux_lane0_A_input( .select(select_bank_databus_to_A_lane[0]) , .X1(data_bus_bank_lane[0][0]) , .X2(data_bus_bank_lane[0][1])  , .X3(data_bus_bank_lane[0][2])  , .X4(data_bus_bank_lane[0][3])  , .q(input_A_lane_from_bank[0]) ); 
mux41  U_mux_lane0_B_input( .select(select_bank_databus_to_B_lane[0]) , .X1(data_bus_bank_lane[0][0]) , .X2(data_bus_bank_lane[0][1])  , .X3(data_bus_bank_lane[0][2])  , .X4(data_bus_bank_lane[0][3])  , .q(input_B_lane_from_bank[0]) ); 
mux41  U_mux_lane0_C_input( .select(select_bank_databus_to_C_lane[0]) , .X1(data_bus_bank_lane[0][0]) , .X2(data_bus_bank_lane[0][1])  , .X3(data_bus_bank_lane[0][2])  , .X4(data_bus_bank_lane[0][3])  , .q(input_C_lane_from_bank[0]) ); 


mux41  U_mux_lane1_A_input( .select(select_bank_databus_to_A_lane[1]) , .X1(data_bus_bank_lane[1][0]) , .X2(data_bus_bank_lane[1][1])  , .X3(data_bus_bank_lane[1][2])  , .X4(data_bus_bank_lane[1][3])  , .q(input_A_lane_from_bank[1]) ); 
mux41  U_mux_lane1_B_input( .select(select_bank_databus_to_B_lane[1]) , .X1(data_bus_bank_lane[1][1]) , .X2(data_bus_bank_lane[1][1])  , .X3(data_bus_bank_lane[1][2])  , .X4(data_bus_bank_lane[1][3])  , .q(input_B_lane_from_bank[1]) ); 
mux41  U_mux_lane1_C_input( .select(select_bank_databus_to_C_lane[1]) , .X1(data_bus_bank_lane[1][2]) , .X2(data_bus_bank_lane[1][1])  , .X3(data_bus_bank_lane[1][2])  , .X4(data_bus_bank_lane[1][3])  , .q(input_C_lane_from_bank[1]) ); 


mux41  U_mux_lane2_A_input( .select(select_bank_databus_to_A_lane[2]) , .X1(data_bus_bank_lane[2][0]) , .X2(data_bus_bank_lane[2][1])  , .X3(data_bus_bank_lane[2][2])  , .X4(data_bus_bank_lane[2][3])  , .q(input_A_lane_from_bank[2]) ); 
mux41  U_mux_lane2_B_input( .select(select_bank_databus_to_B_lane[2]) , .X1(data_bus_bank_lane[2][1]) , .X2(data_bus_bank_lane[2][1])  , .X3(data_bus_bank_lane[2][2])  , .X4(data_bus_bank_lane[2][3])  , .q(input_B_lane_from_bank[2]) ); 
mux41  U_mux_lane2_C_input( .select(select_bank_databus_to_C_lane[2]) , .X1(data_bus_bank_lane[2][2]) , .X2(data_bus_bank_lane[2][1])  , .X3(data_bus_bank_lane[2][2])  , .X4(data_bus_bank_lane[2][3])  , .q(input_C_lane_from_bank[2]) ); 

mux41  U_mux_lane3_A_input( .select(select_bank_databus_to_A_lane[3]) , .X1(data_bus_bank_lane[3][0]) , .X2(data_bus_bank_lane[3][1])  , .X3(data_bus_bank_lane[3][2])  , .X4(data_bus_bank_lane[3][3])  , .q(input_A_lane_from_bank[3]) ); 
mux41  U_mux_lane3_B_input( .select(select_bank_databus_to_B_lane[3]) , .X1(data_bus_bank_lane[3][1]) , .X2(data_bus_bank_lane[3][1])  , .X3(data_bus_bank_lane[3][2])  , .X4(data_bus_bank_lane[3][3])  , .q(input_B_lane_from_bank[3]) ); 
mux41  U_mux_lane3_C_input( .select(select_bank_databus_to_C_lane[3]) , .X1(data_bus_bank_lane[3][2]) , .X2(data_bus_bank_lane[3][1])  , .X3(data_bus_bank_lane[3][2])  , .X4(data_bus_bank_lane[3][3])  , .q(input_C_lane_from_bank[3]) ); 






//FPU unit - bascially 4 lanes for FPU
ALU_64_bit  U_alu0(.clk(clk), .a(input_A_lane_from_bank[0]) , .b(input_B_lane_from_bank[0]) , .c(input_C_lane_from_bank[0]) , .operation(ALU_Sel_for_lane[0]) , .out(fpu_out_lane[0])   , .enable_alu(ALU_Enable_for_lanes[0]) , .num_bits_to_operate(num_bits_to_operate[0]) );
ALU_64_bit  U_alu1(.clk(clk), .a(input_A_lane_from_bank[1]) , .b(input_B_lane_from_bank[1]) , .c(input_C_lane_from_bank[1]) , .operation(ALU_Sel_for_lane[1]) , .out(fpu_out_lane[1])   , .enable_alu(ALU_Enable_for_lanes[1]) , .num_bits_to_operate(num_bits_to_operate[1]) );
ALU_64_bit  U_alu2(.clk(clk), .a(input_A_lane_from_bank[2]) , .b(input_B_lane_from_bank[2]) , .c(input_C_lane_from_bank[2]) , .operation(ALU_Sel_for_lane[2]) , .out(fpu_out_lane[2])   , .enable_alu(ALU_Enable_for_lanes[2]) , .num_bits_to_operate(num_bits_to_operate[2]) );
ALU_64_bit  U_alu3(.clk(clk), .a(input_A_lane_from_bank[3]) , .b(input_B_lane_from_bank[3]) , .c(input_C_lane_from_bank[3]) , .operation(ALU_Sel_for_lane[3]) , .out(fpu_out_lane[3])   , .enable_alu(ALU_Enable_for_lanes[3]) , .num_bits_to_operate(num_bits_to_operate[3]) );

integer jj;

//always @(posedge clk) 
//begin 
//for (ii=0; ii<4; ii=ii+1) 
//begin 
//	for (jj=0; jj<4; jj=jj+1)begin  
//		//assign  data_bus_bank_lane[ii][jj]  = (CS_lane[ii][jj]  && OE_lane[ii][jj] && !WE_lane[ii][jj]) ? data_bus_bank_lane_temp[ii][jj] : 64'bz; 
//		assign  data_bus_bank_lane[0][0]  = (CS_lane[0][0]  && OE_lane[0][0] && !WE_lane[0][0]) ? data_bus_bank_lane_temp[0][0] : 64'bz; 
//
//end
//end
//end


assign  data_bus_bank_lane[0][0]  	= (CS_lane[0][0]   && WE_lane[0][0]) ? data_bus_bank_lane_temp[0][0] : 64'bz;
assign  data_bus_bank_lane[0][1]  	= (CS_lane[0][1]   && WE_lane[0][1]) ? data_bus_bank_lane_temp[0][1] : 64'bz;
assign  data_bus_bank_lane[0][2] 	= (CS_lane[0][2]   && WE_lane[0][2]) ? data_bus_bank_lane_temp[0][2] : 64'bz;
assign  data_bus_bank_lane[0][3]  	= (CS_lane[0][3]   && WE_lane[0][3]) ? data_bus_bank_lane_temp[0][3] : 64'bz;

assign  data_bus_bank_lane[1][0]  	= (CS_lane[1][0]   && WE_lane[1][0]) ? data_bus_bank_lane_temp[2][0] : 64'bz;
assign  data_bus_bank_lane[1][1]  	= (CS_lane[1][1]   && WE_lane[1][1]) ? data_bus_bank_lane_temp[2][1] : 64'bz;
assign  data_bus_bank_lane[1][2] 	= (CS_lane[1][2]   && WE_lane[1][2]) ? data_bus_bank_lane_temp[2][2] : 64'bz;
assign  data_bus_bank_lane[1][3]  	= (CS_lane[1][3]   && WE_lane[1][3]) ? data_bus_bank_lane_temp[2][3] : 64'bz;


assign  data_bus_bank_lane[2][0]  	= (CS_lane[2][0]   && WE_lane[2][0]) ? data_bus_bank_lane_temp[2][0] : 64'bz;
assign  data_bus_bank_lane[2][1]  	= (CS_lane[2][1]   && WE_lane[2][1]) ? data_bus_bank_lane_temp[2][1] : 64'bz;
assign  data_bus_bank_lane[2][2] 	= (CS_lane[2][2]   && WE_lane[2][2]) ? data_bus_bank_lane_temp[2][2] : 64'bz;
assign  data_bus_bank_lane[2][3]  	= (CS_lane[2][3]   && WE_lane[2][3]) ? data_bus_bank_lane_temp[2][3] : 64'bz;


assign  data_bus_bank_lane[3][0]  	= (CS_lane[3][0]   && WE_lane[3][0]) ? data_bus_bank_lane_temp[3][0] : 64'bz;
assign  data_bus_bank_lane[3][1]  	= (CS_lane[3][1]   && WE_lane[3][1]) ? data_bus_bank_lane_temp[3][1] : 64'bz;
assign  data_bus_bank_lane[3][2] 	= (CS_lane[3][2]   && WE_lane[3][2]) ? data_bus_bank_lane_temp[3][2] : 64'bz;
assign  data_bus_bank_lane[3][3]  	= (CS_lane[3][3]   && WE_lane[3][3]) ? data_bus_bank_lane_temp[3][3] : 64'bz;



endmodule

