`include "bwise_or_param.v"

module muxpar #( parameter BUS_SIZE = 32, parameter WORD_SIZE = 4 )
               ( output reg [BUS_SIZE-1:0] data_out,
		 output reg [WORD_NUM-1:0] control_out,
		 output reg 		   error_out,
		 input wire [BUS_SIZE-1:0] data_in,
		 input wire 		   reset, clk );

   parameter            WORD_NUM = BUS_SIZE / WORD_SIZE;  
   wire [BUS_SIZE-1:0] 	data_in_w;
   wire [WORD_NUM-1:0] 	control_out_w;
   /* PARAMETROS Y REGS PARA LA MAQUINA DE ESTADOS */
   parameter 		RESET = 5'b00001;
   parameter 		FIRST_PKT = 5'b00010;
   parameter 		REG_PKT = 5'b00100;
   parameter 		F_ERR = 5'b01000;
   parameter 		SEQ_ERR = 5'b10000;
   reg [4:0] 		next_state, state;
   reg 			next_error_out;
   reg [WORD_SIZE-1:0] 	count, next_count;
   wire [WORD_SIZE-1:0] ones, zeros;
   
   assign ones = -1;
   assign zeros = 0;
   assign data_in_w = data_in;
   
   /* SALIDA control_out SE CONSTRUYE A PARTIR DE CADA WORD_SIZE DEL
    * data_in, Y CADA BIT SER\'A UN OR BITWISE DE CADA UNA DE ESTAS
    * WORD_SIZE */
   genvar 				   i;
   generate
      for( i = 0; i < WORD_NUM; i = i + 1 ) begin
	 bwise_or_param #( .WORD_SIZE( WORD_SIZE ) )
	 bor ( control_out_w[i], data_in_w[WORD_SIZE*i+:WORD_SIZE] );
      end
   endgenerate

   always @( * ) begin: CONTROL_OUTPUT
      control_out = control_out_w;
   end

   /* SALIDA data_out INVIERTE LOS BLOQUES WORD_SIZE DE data_in EJEMPLO
    * SI data_in = 0xFA1C0 ENTONCE data_out = 0x0C1AF
    */
   genvar k;
   generate 
      for( k = 0; k < WORD_NUM; k = k + 1 ) begin
	 always @( * ) begin
	    //data_out[WORD_SIZE*(k+1)-1:k*WORD_SIZE] = 
            //data_in[BUS_SIZE-1-k*WORD_SIZE:BUS_SIZE-WORD_SIZE*(k+1)];
	    data_out[WORD_SIZE*k+:WORD_SIZE] = 
	    data_in[WORD_SIZE*(WORD_NUM - 1 - k)+:WORD_SIZE];
	 end
      end
   endgenerate

   /* A PARTIR DE AQUE SE ENCUETRA EL CODIGO DE LA MAQUINA DE ESTADOS */
   always @( posedge clk ) begin: STATE_LOGIC
      state <= next_state;
      count <= next_count;
   end

   always @( * ) begin: NEXT_STATE_LOGIC
      next_count = count;
      next_state = state;
      case( state )
	RESET: // 1
	  if( reset == 1'b0 ) begin
	     next_state = RESET;
	     next_count = 'hff;
	  end
	  else begin
	     if( data_in[BUS_SIZE-1:BUS_SIZE-WORD_SIZE] == ones  ) begin
		if( data_in[WORD_SIZE-1:0] == zeros ) begin
		   next_state = FIRST_PKT;
		   next_count = 1;
		end
		else begin
		   next_state = F_ERR;
		   next_count = zeros;
		end
	     end
	  end // else: !if( reset == 1'b0 )
	FIRST_PKT: // 2
	  if( reset == 1'b0 ) begin
	     next_state = RESET;
	     next_count = zeros;
	  end
	  else begin
	     if( data_in[BUS_SIZE-1:BUS_SIZE-WORD_SIZE] == ones ) begin
		if( data_in[WORD_SIZE-1:0] == zeros ) begin
		   next_state = FIRST_PKT;
		   next_count = 'b1;
		end
		else if( data_in[WORD_SIZE-1:0] == count ) begin
		   next_state = REG_PKT;
		   next_count = next_count + 1;
		end
		else begin
		   next_state = SEQ_ERR;
		   next_count = zeros;
		end
	     end
	     else begin
		next_state = F_ERR;
		next_count = zeros;
	     end
	  end // else: !if( reset == 1'b0 )
	REG_PKT: //4
	  if( reset == 1'b0 ) begin
	     next_state = RESET;
	     next_count = zeros;
	  end
	  else begin
	     if( data_in[BUS_SIZE-1:BUS_SIZE-WORD_SIZE] == ones ) begin
		if( data_in[WORD_SIZE-1:0] == count ) begin
		   next_state = REG_PKT;
		   next_count = next_count + 1;
		end
		else if( data_in[WORD_SIZE-1:0] == zeros ) begin
		   next_state = FIRST_PKT;
		   next_count = 'b1;
		end
		else begin
		   next_state = SEQ_ERR;
		   next_count = zeros;
		end
	     end // if ( data_in[BUS_SIZE-1:BUS_SIZE-WORD_SIZE] == -1 )
	     else begin
		next_state = F_ERR;
		next_count = zeros;
	     end // else: !if( data_in[BUS_SIZE-1:BUS_SIZE-WORD_SIZE] == -1 )	     
	  end // else: !if( reset == 1'b0 )
	F_ERR:
	  if( reset == 1'b0 ) begin
	     next_state = RESET;
	     next_count = zeros;
	  end
	  else begin
	     if( data_in[BUS_SIZE-1:BUS_SIZE-WORD_SIZE] == ones ) begin
		if( data_in[WORD_SIZE-1:0] == zeros ) begin
		   next_state = FIRST_PKT;
		   next_count = 'b1;
		end
		else begin
		   next_state = F_ERR;
		   next_count = zeros;
		end
	     end
	     else begin
		next_state = F_ERR;
		next_count = zeros;
	     end // else: !if( data_in[BUS_SIZE-1:BUS_SIZE-WORD_SIZE] == ones )
	  end // else: !if( reset == 1'b0 )
	SEQ_ERR:
	  if( reset == 1'b0 ) begin
	     next_state = RESET;
	     next_count = zeros;
	  end
	  else begin
	     if( data_in[BUS_SIZE-1:BUS_SIZE-WORD_SIZE] == ones ) begin
		if( data_in[WORD_SIZE-1:0] == zeros ) begin
		   next_state = FIRST_PKT;
		   next_count = 'b1;
		end
		else begin
		   next_state = F_ERR;
		   next_count = zeros;
		end
	     end
	     else begin
		next_state = F_ERR;
		next_count = zeros;
	     end
	  end // else: !if( reset == 1'b0 )
	default: begin
	   next_state = RESET;
	end
      endcase // case ( state )	
   end // block: NEXT_STATE_LOGIC

   always @( * ) begin: INTER_LOGIC
      next_error_out = 1'b0;
      if( next_state == F_ERR ) begin 
	 next_error_out = 1'b1;
      end
      else if ( next_state == SEQ_ERR ) begin
	 next_error_out = 1'b1;
      end
      else begin
	 next_error_out = 1'b0;
      end
   end // block: INTER_LOGIC
   
   always @( posedge clk ) begin: ERROR_LOGIC
      error_out <= next_error_out;
   end
    
endmodule // muxpar

	  

   
