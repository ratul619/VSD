module rram_simu (
ADC_OUT0,
ADC_OUT1,
ADC_OUT2,
CLK_EN_ADC,
CSA,
ENABLE_ADC,
ENABLE_BL,
ENABLE_CSA,
ENABLE_SL,
ENABLE_WL,
IN0_BL,
IN0_SL,
IN0_WL,
IN1_BL,
IN1_SL,
IN1_WL,
PRE,
SAEN_CSA); 



output reg [15:0]ADC_OUT0;
output reg [15:0]ADC_OUT1;
output reg [15:0]ADC_OUT2;
input [1:0]CLK_EN_ADC;
output reg  [15:0]CSA;
input ENABLE_ADC;
input ENABLE_BL;
input ENABLE_CSA;
input ENABLE_SL;
input ENABLE_WL;
input [15:0]IN0_BL;
input [15:0]IN0_SL;
input [15:0]IN0_WL;
input [15:0]IN1_BL;
input [15:0]IN1_SL;
input [15:0]IN1_WL;
input PRE;
input SAEN_CSA;


integer  in1_table [0:15] [15:0];

integer i,j;

initial begin
    in1_table[0][0] = 1;
    in1_table[0][1] = 16;
    $display(in1_table[0][0]);
    $display(in1_table[0][1]);



   for (i=0; i<16; i=i+1) begin
   	for (j=0; j<16; i=j+1)
    		begin
      		#10 in1_table[i][j]=$random%10; 
    		$display("in1_table[i][j] : %d",in1_table[i][j]);    
   	end
   end 


end




endmodule
