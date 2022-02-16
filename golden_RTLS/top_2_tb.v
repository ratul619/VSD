module top_tb  (  ); 



top  uut (clk, 
	rstn, 
	vector_instruction , start   ); 


reg clk ,rstn , start   ; 
reg	[31:0]    vector_instruction;


initial begin
  $dumpfile("top.vcd");
  $dumpvars();
  clk = 0;


end



initial begin
		# 10 
		rstn = 1'b0;
		clk = 1; 


		#16 

		rstn = 1'b1; 
		start = 1; 
		#5; 

		vector_instruction = 32'b00000010101000101000101001010111   ;


		#500 $finish;

end




always #5 clk  = ~clk;





endmodule 

