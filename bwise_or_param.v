module bwise_or_param #( parameter WORD_SIZE = 4 )
                       ( output wire bwise_or_out,
			 input wire [WORD_SIZE-1:0] vector_in );

   assign bwise_or_out = |vector_in;

endmodule // bwise_or_param
