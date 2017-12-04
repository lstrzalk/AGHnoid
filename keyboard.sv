module keyboard(kb_clk, data, VGA_clk, reading_available, scan_ready, scan_code);
	input kb_clk;					// keyboard's clock (data sent on negedge)
	input data;						// keyboard's input data
	input VGA_clk;					// 25 MHz
	input reading_available;

	output scan_ready;
	logic ready_set;
	output logic [7:0] scan_code;
	logic scan_ready;
	logic read_char;

	logic [3:0] incnt;
	logic [8:0] shiftin;

	logic [7:0] filter;
	logic keyboard_clk_filtered;

	// scan_ready is set to 1 when scan_code is available.
	// user should set reading_available to 1 and then to 0 to clear scan_ready

	always @ (posedge ready_set or posedge reading_available)
	if (reading_available == 1) scan_ready <= 0;
	else scan_ready <= 1;
	
	// This process filters the raw clock signal coming from the keyboard 
	// using an eight-bit shift register and two AND gates

	always @(posedge VGA_clk)
	begin
	   filter <= {kb_clk, filter[7:1]};								// concatenate
	   if (filter == 8'b1111_1111) keyboard_clk_filtered <= 1;
	   else if (filter == 8'b0000_0000) keyboard_clk_filtered <= 0;
	end

	// This process reads in serial data coming from the terminal

	always @(posedge keyboard_clk_filtered)
	begin
	   	if (data==0 && read_char==0)
	   	begin
			read_char <= 1;
			ready_set <= 0;
	   	end
	   	// we are reading now
	   	else
	   	begin
		   	// shift in next 8 data bits to assemble a scan code	
		   	if (read_char == 1)
	   		begin
	      		if (incnt < 9) 
	      		begin
					incnt <= incnt + 1'b1;
					shiftin = { data, shiftin[8:1]};
					ready_set <= 0;
				end
				else
				begin
					incnt <= 0;
					scan_code <= shiftin[7:0];

					read_char <= 0;
					ready_set <= 1;
				end
			end
		end
	end
endmodule