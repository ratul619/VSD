module top_tb (); 



top uut( 
clk, 
rstn, 
enable , 
address_start , 
MAJ_OP_REG); 


reg clk , rstn ; 
wire enable; 
wire [4:0]address_start; 
wire [31:0]MAJ_OP_REG;

initial begin 


#5 

rstn = 0;
	
clk = 0 ; 
#10 
rstn = 1 ;  

#80 
$finish;


end
	

 always  begin
	#5 clk = !clk;  
 end
	 
initial  begin
    $dumpfile ("top_tb.vcd"); 
    $dumpvars; 
  end 



  endmodule
