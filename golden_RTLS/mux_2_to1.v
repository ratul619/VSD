module mux_2x1 ( select, X1 , X2 , Y );

input  select;
input[63 :0] X1;
input[63 :0] X2;
output reg  [63:0] Y;

wire select;
wire[63 :0] X1;
wire[63 :0] X2;

always @( select or X1 or X2  )
begin
   if( select == 0)
      Y = X1 ;

   if( select == 1)
      Y = X2 ;

end

endmodule
