module verificador #( parameter BITS = 2 ) 
                    ( output reg verificador,
		      input wire 	    clk,
		      input wire [BITS-1:0] signal1,
		      input wire [BITS-1:0] signal2 );

   // SE USA TRIPLE = PARA TOMAR EN CUENTA LOS VALORES
   // xx Y ASI PODERLOS COMPARAR COMO IGUALES.
   always @( posedge clk ) begin
      if( signal1 === signal2 ) begin
	 verificador <= 1'b1;
      end
      else begin
	 verificador <= 1'b0;
      end
   end

endmodule // verificador

   
 
