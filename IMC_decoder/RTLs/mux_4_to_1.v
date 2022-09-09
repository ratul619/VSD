module mux_4_to_1 ( Y1 , Y2 , Y3 , Y4 ,  s0, s1, out);

input wire [31:0]Y1; 
input wire [31:0]Y2; 
input wire [31:0]Y3; 
input wire [31:0]Y4; 

input  s0, s1;
output reg [31:0]out;

always @ (Y1 or Y2 or Y3 or Y4 or s0 or s1)
begin

case (s0 | s1)
2'b00 : out <= Y1;
2'b01 : out <= Y2;
2'b10 : out <= Y3;
2'b11 : out <= Y4;
endcase

end

endmodule
