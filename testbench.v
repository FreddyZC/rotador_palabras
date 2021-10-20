`include "probador.v"
`include "muxpar.v"
`include "synth_muxpar.v"
`include "./UTILIDADES/cmos_cells.v"

module testbench;
   parameter BUS_SIZE = 60;
   parameter WORD_SIZE = 6;
   parameter WORD_NUM = BUS_SIZE / WORD_SIZE;
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			clk;			// From PROB of probador.v
   wire [WORD_NUM-1:0]	control_out;		// From COND of muxpar.v
   wire [WORD_NUM-1:0] 	control_out_synt;	// From SYNT of synth_muxpar.v
   wire [BUS_SIZE-1:0]	data_in;		// From PROB of probador.v
   wire [BUS_SIZE-1:0]	data_out;		// From COND of muxpar.v
   wire [BUS_SIZE-1:0] 	data_out_synt;		// From SYNT of synth_muxpar.v
   wire			error_out;		// From COND of muxpar.v
   wire			error_out_synt;		// From SYNT of synth_muxpar.v
   wire			reset;			// From PROB of probador.v
   // End of automatics
   
   probador #( .BUS_SIZE( BUS_SIZE ), .WORD_SIZE( WORD_SIZE ) ) PROB 
             ( /*AUTOINST*/
	      // Outputs
	      .clk			(clk),
	      .reset			(reset),
	      .data_in			(data_in[BUS_SIZE-1:0]),
	      // Inputs
	      .data_out			(data_out[BUS_SIZE-1:0]),
	      .data_out_synt		(data_out_synt[BUS_SIZE-1:0]),
	      .control_out		(control_out[WORD_NUM-1:0]),
	      .control_out_synt		(control_out_synt[WORD_NUM-1:0]),
	      .error_out		(error_out),
	      .error_out_synt		(error_out_synt));

   muxpar #( .BUS_SIZE( BUS_SIZE ), .WORD_SIZE( WORD_SIZE ) ) COND 
             ( /*AUTOINST*/
	      // Outputs
	      .data_out			(data_out[BUS_SIZE-1:0]),
	      .control_out		(control_out[WORD_NUM-1:0]),
	      .error_out		(error_out),
	      // Inputs
	      .data_in			(data_in[BUS_SIZE-1:0]),
	      .reset			(reset),
	      .clk			(clk));

   synth_muxpar SYNT ( /*AUTOINST*/
		      // Outputs
		      .control_out_synt	(control_out_synt[WORD_NUM-1:0]),
		      .data_out_synt	(data_out_synt[BUS_SIZE-1:0]),
		      .error_out_synt	(error_out_synt),
		      // Inputs
		      .clk		(clk),
		      .data_in		(data_in[BUS_SIZE-1:0]),
		      .reset		(reset));
   

endmodule // testbench
