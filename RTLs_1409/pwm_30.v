 
module pwm_30(CLK, RST, OUTPUT ); 
 
    parameter PERIOD_WIDTH = 10.0; 
    parameter DUTY_CYCLE = 30.0 ; 
    parameter PULSE_WIDTH = PERIOD_WIDTH*(DUTY_CYCLE/100);  


    parameter BITS = 4; 


 
    input CLK; 
    input RST; 
    output OUTPUT; 
     
    wire CLK; 
    wire RST; 
    wire OUTPUT; 
 
    reg [BITS-1:0] count; 
    reg outtemp; 
 
    always @(posedge CLK or posedge RST) 
    begin 
        if (RST) 
        begin 
            count <= 0; 
            outtemp <= 0; 
        end 
        else 
        begin

            if (count < PULSE_WIDTH) 
            begin 
                outtemp <= 1'b1; 
                count <= count + 1; 
            end 
            else if (count < PERIOD_WIDTH) 
            begin 
                outtemp <= 1'b0; 
                count <= count + 1; 
            end 
            else 
            begin 
                count <= 1; 
                outtemp <= 1'b1; 
            end 
        end 
    end 
     
    assign OUTPUT = outtemp; 
 
endmodule 
