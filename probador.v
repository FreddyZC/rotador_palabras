module probador #( parameter BUS_SIZE = 60, parameter WORD_SIZE = 6,
		   parameter WORD_NUM = BUS_SIZE / WORD_SIZE ) 
                 ( output reg clk, reset,
		   output reg [BUS_SIZE-1:0] data_in, 
		   input wire [BUS_SIZE-1:0] data_out, data_out_synt,
		   input wire [WORD_NUM-1:0] control_out, control_out_synt,
		   input wire 		     error_out, error_out_synt );

   parameter 		      RANDOM_COMPONENT = BUS_SIZE - 2 * WORD_SIZE;
 
   reg [RANDOM_COMPONENT-1:0] median_in;
   reg [WORD_SIZE-1:0] 	      head_in, tail_in;
   reg 			      reset_n;
   reg 			      data_verif, control_verif, error_verif;
   
   integer 		      k; // USADO PARA LAS SIGNALS SALIDA
   
   /* VALORES EDITABLES DE LOS ESTIMULOS DEL PROBADOR, PARA EMULAR
    * EL EJEMPLO MOSTRADO EN LA TAREA SE DEBEN PONER LOS SIGUIENTES
    * VALORES: REPETICIONES_RANDOM = 1, VALIDOS = 3,  VALIDOSF = 1 */
   parameter 		      REPETICIONES_RANDOM = 1;
   parameter 		      VALIDOS = 3;
   parameter 		      VALIDOSF = 1;
   
   
   wire [WORD_SIZE-1:0] ones;
   
   assign ones = -1;


   always @( posedge clk ) begin: VERIFICADOR
      if( reset == 1'b0 ) begin
	 data_verif <= 1'b1;
	 control_verif <= 1'b1;
	 error_verif <= 1'b1;
      end
      else begin
	 if( data_out === data_out_synt ) begin
	    data_verif <= 1'b1;
	 end
	 else begin
	    data_verif <= 1'b0;
	    $display( "discrepancia data_outs en: %t s", $time );
	 end
	 if( control_out === control_out_synt ) begin
	    control_verif <= 1'b1;
	 end
	 else begin
	    control_verif <= 1'b0;
	    $display( "discrepancia control_outs en: %t s", $time );
	 end
	 if( error_out === error_out_synt ) begin
	    error_verif <= 1'b1;
	 end
	 else begin
	    error_verif <= 1'b0;
	    $display( "discrepancia error_outs en: %t s", $time );
	 end
      end
   end // block: VERIFICADOR
   
	 
   initial begin: FILE_OUTPUT_GEN
      $dumpfile( "000graf.vcd" );
      $dumpvars( 0 );
   end

   initial begin: INT_INPUTS
      clk = 1'b0;
      reset_n = 1'b0;
      median_in = 'b0;
      head_in = 'b0;
      tail_in = 'b0;
   end

   always begin: CLK_BEHAVIOR
      #1 clk = !clk;
   end

   always @( posedge clk ) begin: OUTPUTS_SYNC
      reset <= reset_n;
      data_in <= {head_in, median_in, tail_in};
   end
   
   initial begin: OUTPUTS_SIGNALS
      #5 reset_n = 1'b1;
      /* AQUI LOS DATOS MANUALES QUE QUERAMOS VER */
      for( k = 0; k < VALIDOS; k = k + 1 ) begin 
	 median_in = $random;
	 head_in = ones;
	 tail_in = k;
	 #2;
      end
      /* AQUI DATOS RANDOM */
      repeat( REPETICIONES_RANDOM ) begin
	 median_in = $random;
	 head_in = $random;
	 tail_in = $random;
	 #2;
      end      
      /* AQUI MAS DATOS MANUALES QUE QUERAMOS VER */
      for( k = 0; k < VALIDOSF; k = k + 1 ) begin 
	 median_in = $random;
	 head_in = ones;
	 tail_in = k;
	 #2;
      end
      
      median_in = $random;
      head_in = ones;
      tail_in = 9;
      #2;
      
      repeat( 4 ) begin
	 median_in = $random;
	 head_in = $random;
	 tail_in = $random;
	 #2;
      end
	 median_in = 0;
	 head_in = 0;
	 tail_in = 0;      
      #3 reset_n = 1'b0;
      #20 $finish;
   end

endmodule // probador

   
