module mux41 ( select, X1 , X2 , X3 , X4 , q );

parameter N = 64; 

input[1:0] select;
input[N-1:0] X1;
input[N-1:0] X2;
input[N-1:0] X3;
input[N-1:0] X4;
output reg  [N-1:0] q;

wire[1:0] select;
wire[N-1:0] X1;
wire[N-1:0] X2;
wire[N-1:0] X3;
wire[N-1:0] X4;

always @( select or X1 or X2 or X3 or X4 )
begin
   if( select == 0)
      q = X1 ;

   if( select == 1)
      q = X2 ;

   if( select == 2)
      q = X3 ;

   if( select == 3)
      q = X4;
end

endmodule
