module dek7segBase(input logic [7:0] data_in, output logic [6:0] seg);
	always@(data_in)
	case(data_in)
		8'h1C	: 	seg[6:0] 	<= 	7'b0001000;	//to display 	A
		8'h32   : 	seg[6:0] 	<= 	7'b0000011;	//to display 	B
		8'h21 	: 	seg[6:0] 	<= 	7'b1000110;	//to display 	C
		8'h23 	: 	seg[6:0] 	<= 	7'b0100001;	//to display 	D
		8'h24	:	seg[6:0]	<=	7'b0000110;	//to display 	E
		8'h2B	:	seg[6:0]	<=	7'b0001110;	//to display 	F
		8'h34	:	seg[6:0]	<=	7'b1000010;	//to display 	G
		8'h33	:	seg[6:0]	<=	7'b0001001;	//to display 	H
		8'h43	:	seg[6:0]	<=	7'b1001111;	//to display 	I
		8'h3B	:	seg[6:0]	<=	7'b1000011;	//to display 	J
		8'h42	:	seg[6:0]	<=	7'b0000101;	//to display 	K
		8'h4B	:	seg[6:0]	<=	7'b1000111;	//to display 	L
		8'h3A	:	seg[6:0]	<=	7'b0101010;	//to display 	M
		8'h31	:	seg[6:0]	<=	7'b0101011;	//to display 	N
		8'h44	:	seg[6:0]	<=	7'b1000000;	//to display 	O
		8'h4D	:	seg[6:0]	<=	7'b0001100;	//to display 	P
		8'h15	:	seg[6:0]	<=	7'b0011000;	//to display 	Q
		8'h2D	:	seg[6:0]	<=	7'b0101111;	//to display 	R
		8'h1B	:	seg[6:0]	<=	7'b0010010;	//to display 	S
		8'h2C	:	seg[6:0]	<=	7'b0000111;	//to display 	T
		8'h3C	:	seg[6:0]	<=	7'b1000001;	//to display 	U
		8'h2A	:	seg[6:0]	<=	7'b1000001;	//to display 	V
		8'h1D	:	seg[6:0]	<=	7'b1100011;	//to display 	W
		8'h22	:	seg[6:0]	<=	7'b1001000;	//to display 	X
		8'h35	:	seg[6:0]	<=	7'b0010001;	//to display 	Y
		8'h1A	:	seg[6:0]	<=	7'b0100100;	//to display 	Z
		8'h45	:	seg[6:0]	<=	7'b1000000;	//to display 	0
		8'h16	:	seg[6:0]	<=	7'b1111001;	//to display 	1
		8'h1E	:	seg[6:0]	<=	7'b0100100;	//to display 	2
		8'h26	:	seg[6:0]	<=	7'b0110000;	//to display 	3
		8'h25	:	seg[6:0]	<=	7'b0011001;	//to display 	4
		8'h2E	:	seg[6:0]	<=	7'b0010010;	//to display 	5
		8'h36	:	seg[6:0]	<=	7'b0000010;	//to display 	6
		8'h3D	:	seg[6:0]	<=	7'b1111000;	//to display 	7
		8'h3E	:	seg[6:0]	<=	7'b0000000;	//to display 	8
		8'h46	:	seg[6:0]	<=	7'b0010000;	//to display 	9
		default : 	seg[6:0] 	<= 	7'b0111111;	//to display 	-
	endcase
endmodule 