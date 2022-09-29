 
module pwm(CLK, RST, OUTPUT , SELECT ); 

input CLK , RST ;
input [1:0]SELECT;
output OUTPUT;


mux_4x1  U_sel_pwm( .a(output_pwm_30) ,  .b(output_pwm_50) ,  .c(output_pwm_70) ,  .d(output_pwm_90) ,  .sel(SELECT) ,  .out(OUTPUT) );    


pwm_30  U_pwm_30 (.CLK(CLK), .RST(RST), .OUTPUT(output_pwm_30) ); 
pwm_50  U_pwm_50 (.CLK(CLK), .RST(RST), .OUTPUT(output_pwm_50) ); 
pwm_70  U_pwm_70 (.CLK(CLK), .RST(RST), .OUTPUT(output_pwm_70) ); 
pwm_90  U_pwm_90 (.CLK(CLK), .RST(RST), .OUTPUT(output_pwm_90) ); 







 
endmodule 
