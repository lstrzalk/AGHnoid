module vga(VGA_clk, xCount, yCount, displayArea, VGA_hSync, VGA_vSync, blank_n);
	input VGA_clk;
	output reg [9:0]xCount, yCount;			// current pixel "trackers"
	output reg displayArea;  				// checking if area is active
	output VGA_hSync, VGA_vSync, blank_n;	

	reg p_hSync, p_vSync; 					// checking if syncs are active
	
	// horizontal timing: disp-h 640, 16 fp, 96 hs, 48 bp
	integer hFrontPorch = 640; 	//start of horizntal front porch
	integer hSync = 656;		//start of horizontal sync
	integer hBackPorch = 752; 	//start of horizontal back porch
	integer hMaxCol = 800; 		//total columns

	// vertical timing: disp-v 480, 10 fp, 2 vs, 33 bp (per line)
	integer vFrontPorch = 480; 	//start of vertical front porch 
	integer vSync = 490; 		//start of vertical sync
	integer vBackPorch = 492; 	//start of vertical back porch
	integer vMaxRow = 525; 		//total rows. 

	always@(posedge VGA_clk)
		begin
			if(xCount === hMaxCol)
				xCount <= 0;
			else
				xCount <= xCount + 1;
		end

	always@(posedge VGA_clk)
		begin
			if(xCount === hMaxCol)
			begin
				if(yCount === vMaxRow)
					yCount <= 0;
				else
				yCount <= yCount + 1;
			end
		end
	
	always@(posedge VGA_clk)
		begin
			displayArea <= ((xCount < hFrontPorch) && (yCount < vFrontPorch)); 
		end

	always@(posedge VGA_clk)
		begin
			p_hSync <= ((xCount >= hSync) && (xCount < hBackPorch)); 
			p_vSync <= ((yCount >= vSync) && (yCount < vBackPorch)); 
		end
 
	assign VGA_vSync = ~p_vSync; 
	assign VGA_hSync = ~p_hSync;
	assign blank_n = displayArea;
	
endmodule


