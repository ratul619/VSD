`timescale 1ns / 1ps


module pwm_tb; 
     
    reg CLK; 
    reg RST; 
    wire OUTPUT; 
    integer clkcount; 
   
    pwm_30 pwm_test1(.CLK(CLK), .RST(RST), .OUTPUT(OUTPUT)); 
   
    initial 
    begin 
        clkcount = 0; 
        $timeformat(-9, 2, "ns", 16); 
        $monitor("CLK = %b , RST = %b , OUTPUT = %b , clkcount = %d , time = %t \n", CLK, RST, OUTPUT, clkcount, $realtime); 
        #101; 
        RST = 0; 
        #101; 
        RST = 1; 
        #101; 
        RST = 0; 
        #1000; 
        $finish; 
    end 
   
    always 
    begin 
        CLK = 1; 
        #5; 
        CLK = 0; 
        #5; 
        clkcount = clkcount + 1; 
    end 
  

initial  begin
    $dumpfile ("pwm_tb.vcd"); 
    $dumpvars; 
  end 


 
   
endmodule 
