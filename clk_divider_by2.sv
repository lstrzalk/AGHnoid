



module clk_divider_by2(master_clk, VGA_clk);
	input master_clk; 	//50 MHz clock
	output logic VGA_clk; //25 MHz clock
	logic q;

	always@(posedge master_clk)
		begin
			q <= ~q; 
			VGA_clk <= q;
		end
		
endmodule


/**********
*Przebieg:*
clk	q	out
0	0	0
1	1	1
0	1	1
1	0	0
0	0	0
**********/

