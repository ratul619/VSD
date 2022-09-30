module mux_4x1 ( input  a,                 
                         input  b,           
                         input  c,           
                         input  d,           
                         input [1:0] sel,    
                         output  out);       

   // When sel[1] is 0, (sel[0]? b:a) is selected and when sel[1] is 1, (sel[0] ? d:c) is taken
   // When sel[0] is 0, a is sent to output, else b and when sel[0] is 0, c is sent to output, else d
   assign out = sel[1] ? (sel[0] ? d : c) : (sel[0] ? b : a);

endmodule
