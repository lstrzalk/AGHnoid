module oneshot(output logic pulse_out, input trigger_in, input clk);
	// pulse_out -> read
	// trigger_in -> scan_ready

	logic delay;

	// If scan_code and clock are ready we can read
	always @ (posedge clk)
	begin
		if (trigger_in && !delay) pulse_out <= 1'b1;
		else pulse_out <= 1'b0;

		delay <= trigger_in;
	end 
endmodule
