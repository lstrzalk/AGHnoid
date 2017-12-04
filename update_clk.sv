module update_clk(master_clk/*, speed*/, update);
	input master_clk;
	//input int speed;
	output reg update;
	logic [21:0] count;

	always@(posedge master_clk)
	begin
		count <= count + 1;
		if(count == 180000)
		begin
			update <= ~update;
			count <= 0;
		end
	end
endmodule