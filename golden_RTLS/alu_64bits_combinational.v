module ALU_64_bit(a, b, operation, out   , c , clk , rstn , enable_alu  , num_bits_to_operate );
      input [63:0] a;
      input [63:0] b;
      input [63:0] c;
      input [2:0] operation;
      output reg [63:0]out ;

      input [2:0]num_bits_to_operate; 



 input clk , rstn , enable_alu;


      always @ (* ) begin
		if (enable_alu)  begin 

			if (num_bits_to_operate == 0 ) begin 

		       	case (operation)
			       3'b000: 	begin 
				  
						out[7:0]  		= a[7:0]		+   	 b[7:0];    
						out[63:8] = 0 ;  
					end	  
				3'b001: begin 
						out[7:0] 	 	= a[7:0] 	 	* 	 b[7:0];    
						out[63:8] = 0 ; 
					end 

				3'b010: begin  
						out[7:0]  		= a[7:0] 		-      	 b[7:0];    
						out[63:8] = 0 ;
					end 

				3'b011: begin  	out[7:0]  		= (a[7:0] 		* 	 b[7:0]) + c ;  
						out[63:8] = 0 ;
					end
		       endcase 

		end else if (num_bits_to_operate == 1 ) begin 

		       case (operation)
			       3'b000: 	begin 
				  
						out[15:0]  		= a[15:0]		+   	 b[15:0];    
						out[63:16] = 0 ;  
					end	  
				3'b001: begin 
						out[15:0] 	 	= a[15:0] 	 	* 	 b[15:0];   
						out[63:16] = 0 ;  

					end 

				3'b010: begin  
						out[15:0]  		= a[15:0] 		-      	 b[15:0];    
						out[63:16] = 0 ;
					end 

				3'b011: begin  	out[15:0]  		= (a[15:0] 		* 	 b[15:0]) + c[15:0] ; 
						out[63:16] = 0 ;
			       			
					end
		       endcase 


		end  else if (num_bits_to_operate == 2 ) begin 

		       case (operation)
			       3'b000: 	begin 
				  
						out[31:0]  		= a[31:0]		+   	 b[31:0];    
						out[63:32] = 0 ;  
					end	  
				3'b001: begin 
						out[31:0] 	 	= a[31:0] 	 	* 	 b[31:0];    
						out[63:32] = 0 ;  

					end 

				3'b010: begin  
						out[31:0]  		= a[31:0] 		-      	 b[31:0];    
						out[63:32] = 0 ;
					end 

				3'b011: begin  	out[31:0]  		= (a[31:0] 		* 	 b[31:0]) + c[31:0] ;  
						out[63:32] = 0 ;

					end
		       endcase


		end else if (num_bits_to_operate == 3 ) begin 

		       case (operation)
			       3'b000: 	begin 
				  
						out[63:0]  		= a[63:0]		+   	 b[63:0];    
					end	  
				3'b001: begin 
						out[63:0] 	 	= a[63:0] 	 	* 	 b[63:0];    
					end 

				3'b010: begin  
						out[63:0]  		= a[63:0] 		-      	 b[63:0];    
					end 

				3'b011: begin  	out[63:0]  		= (a[63:0] 		* 	 b[63:0]) + c[63:0] ;  
					end
		       endcase 


		end



	    




           end
	 end 

endmodule
