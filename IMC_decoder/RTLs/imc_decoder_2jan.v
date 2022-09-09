`include	"opcodes.h"

//	Include definition of the control signals

module imc_decoder (clk,  rst , instruction, CS , WE , OE , ADDR_MEM1 ,ADDR_MEM2  , ADDR_MEM3 , DATA_TO_MEM ,DATA_FROM_MEM  , SAEN , EXECUTE_MIG , EXECUTE_MAGIC ,EXECUTE_IMPLY ,EXECUTE_BITWISE  , exec_logical_bitwise);


parameter INSTRUCTION_SIZE = 32 ; 
parameter DATA_MEM_SIZE = 16 ; 
parameter ADDR_MEM_SIZE = 4; 

input		clk , rst ;
input	[INSTRUCTION_SIZE-1:0]	instruction;


// common output 

output reg 		CS;
output reg 		WE;
output reg 		OE;
output reg 	[DATA_MEM_SIZE-1:0] DATA_TO_MEM	;
input 	        [DATA_MEM_SIZE-1:0] DATA_FROM_MEM	;
output reg 	[ADDR_MEM_SIZE-1:0] ADDR_MEM1	;
output reg 	[ADDR_MEM_SIZE-1:0] ADDR_MEM2	;
output reg 	[ADDR_MEM_SIZE-1:0] ADDR_MEM3	;
output reg 	[DATA_MEM_SIZE-1:0] SAEN	;

// MIG special 

output	EXECUTE_MIG	; 
reg [DATA_MEM_SIZE-1:0]data_from_mem;

// MAGIC special 
output	EXECUTE_MAGIC	;

// IMPLY special 
output	EXECUTE_IMPLY	; 

// 
output	EXECUTE_BITWISE	;

reg exec_mig ; 
reg exec_magic ; 
reg exec_imply ; 
reg exec_bitwise ; 

output reg [1:0] exec_logical_bitwise ; 


wire mem_read ;
wire mem_write ; 


// 
// MIG : 16b - 1b extra
//      [14:13] --> MIG/IMPLY/MAGIC/BITWISE - 2b 
//      [12] --/ Read/Write  - 1b
//      [11-8] -- SAEN decode - 4b
//    [7-4] -- write registers - 4b 
//    [0-3] -- temp regs


// For which IMC operation 
always @(posedge clk   ) begin 

			// Check the instruction op-code
case (instruction[31:30])
		`MAJORITY :	// 
                begin
                     exec_mig = 1 ;
                     exec_magic = 0 ;
                     exec_imply  = 0 ; 
                     exec_bitwise = 0 ;
                    
                        case (instruction[29])

                            
                            1'b0: //Read 
                            begin 
                                CS   = 0 ; // active low 
                                WE   = 1 ; // active low
                                ADDR_MEM1 = instruction[28:25];


                            end 
                            1'b1: //write  
                            begin 
                                CS   = 0 ; // active low 
                                WE   = 0 ; // active low
                                ADDR_MEM1 = instruction[28:25];
                                DATA_TO_MEM = instruction[24:8]; // need to write code for mask pattern 
                                 
                            end 
                        endcase
                end 
                        
                `MAGIC :	// 
                begin
                     exec_mig = 0 ;
                     exec_magic = 1 ;
                     exec_imply  = 0 ; 
                     exec_bitwise = 0 ; 
                end




		`IMPLY :	// The instruction is a xor
                begin
                     exec_mig = 0 ;
                     exec_magic = 0 ;
                     exec_imply  = 1 ; 
                     exec_bitwise = 0 ;

                        case (instruction[29])

                            1'b0 :  //exec
                                begin
                                    ADDR_MEM1 = instruction[28:25]   ;
                                    ADDR_MEM1 = instruction[24:21]; 
                                    CS = 0 ; 
                                    WE = 0;
                                end 

                            1'b1 : //copy 
                                  begin
                                    ADDR_MEM1 = instruction[28:25]   ;
                                    ADDR_MEM1 = instruction[24:21]; 
                                    CS = 0 ; 
                                    WE = 1;
                                end 





                        
                        endcase



                end 



            	`BITWISE:	// The instruction is a xor
                begin
                     exec_mig = 0 ;
                     exec_magic = 0 ;
                     exec_imply  = 0 ; 
                     exec_bitwise = 1 ;
                     exec_logical_bitwise = instruction[1:0];
                     ADDR_MEM1 = instruction[29:26];
                     ADDR_MEM2 = instruction[25:22];
                     ADDR_MEM3 = instruction[21:19];
                     CS = 0 ; 
                     WE = 1 ; 

                end

endcase
end


assign  EXECUTE_MIG = exec_mig ;
assign  EXECUTE_MAGIC = exec_magic ;
assign  EXECUTE_IMPLY = exec_imply ;
assign  EXECUTE_BITWISE = exec_bitwise;


// outputs according to the technique



endmodule

