// setVL instruction 


`define IS_SET_VL 7'b1010111





//Instruction Type: VV 
//
//Instruction Type: VV-type
//VV  	31 - 26 	25 	24-20 	19-15 	14-12 	11-7 	6-0
//	funct6 		vm 	vs2 	vs1 	000 	vd 	VV
//
//
//
//vadd.v  000000 		vm 	vs2 	vs1 	000 	vd 1010111
//vsub.vv 000010  		vm 	vs2 	vs1 	000 	vd 1010111
//vand.vv 001001  		vm 	vs2 	vs1 	000 	vd 1010111
//vor.vv  001010 		vm 	vs2 	vs1 	000 	vd 1010111
//vxor.vv 001011 		vm 	vs2 	vs1 	000 	vd 1010111 

//vmult.vv 100100 		vm 	vs2 	vs1 	000 	vd 1010111 
//vmacc.vv 101101 		vm 	vs2 	vs1 	000 	vd 1010111 


`define IS_VV_TYPE   3'b000 

`define VV_vadd 	 6'b000000   
`define VV_vsub   	 6'b000010   
`define VV_vand   	 6'b001001   
`define VV_vor   	 6'b001010   
`define VV_vxor   	 6'b001011  
`define VV_mult   	 6'b100100  
`define VV_macc   	 6'b101101  

//vnmac ins :  10110110000011111000000011010111 

//Instruction Type: VX-typ


//Instruction Type: VX-type
//VV  				31 - 26 	25 	24-20 	19-15 	14-12 	11-7 	6-0
//				funct6 		vm 	vs2 	rs1 	100 	vd 	VX 
//
//vadd.vx			000000		vm 	vs2 	rs1 	100 	vd 1010111
//vsub.vx			000010		vm 	vs2 	rs1 	100 	vd 1010111
//vand.vx			001001 		vm 	vs2 	rs1 	100 	vd 1010111
//vor.vx			001010 		vm 	vs2 	rs1 	100 	vd 1010111
//vxor.vx			001011		vm 	vs2 	rs1 	100 	vd 1010111 
//vmv.vx			010111		vm 	vs2 	rs1 	100 	vd 1010111 
//vslideup.vx			001110 		vm 	vs2 	rs1 	100 	vd 1010111 
//vslidedown.vx			001111		vm 	vs2 	rs1 	100 	vd 1010111 
//vmult.vx			100101		vm 	vs2 	rs1 	100 	vd 1010111 
//vmacc.vv 			101101 		vm 	vs2 	vs1 	100 	vd 1010111 



`define IS_VX_TYPE   3'b100 

`define VX_vadd 	 6'b000000   
`define VX_vsub 	 6'b000010   
`define VX_vand 	 6'b001001   
`define VX_vor 	 	6'b001010   
`define VX_vxor 	 6'b001011   
`define VX_vmv 	 	6'b010111   
`define VX_vslideup 	 6'b001110   
`define VX_vslidedown  	6'b001111   
`define VX_mult	 	6'b100101   
`define VX_macc	 	6'b100101   



