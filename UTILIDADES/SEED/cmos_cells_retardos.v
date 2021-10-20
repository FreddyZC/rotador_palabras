module BUF(A, Y);
input A;
output Y;
assign #(0.6:1:1.7) Y = A;
endmodule

module NOT(A, Y);
input A;
output Y;
assign #(0.6:1:1.7) Y = ~A;
endmodule

module NAND(A, B, Y);
input A, B;
output Y;
assign #(0.6:1:1.5) Y = ~(A & B);
endmodule

module NOR(A, B, Y);
input A, B;
output Y;
assign #(0.5:1:1.5) Y = ~(A | B);
endmodule

module DFF(C, D, Q);
input C, D;
output reg Q;
always @(posedge C)
	Q <= #(0.3:1:1.9) D;
endmodule

module DFFSR(C, D, Q, S, R);
input C, D, S, R;
output reg Q;
always @(posedge C, posedge S, posedge R)
	if (S)
		Q <= #(0.3:1:1.9) 1'b1;
	else if (R)
		Q <= #(0.3:1:1.9) 1'b0;
	else
		Q <= #(0.3:1:1.9) D;
endmodule
