/*** NEW PART ***/
`include "dek7segBase.sv"

module game_status(input int lifes, input int points, output logic [6:0] dispS3, output logic [6:0] dispS5, output logic [6:0] dispS6, output logic [6:0] dispS7);
	logic [7:0] lifes_digit_scancode = 8'h26;
	dek7segBase dek7_dispS3(.data_in(lifes_digit_scancode), .seg(dispS3));		// lifes remaining

	int hundreds = 0;
	logic [7:0] hundreds_digit_scancode = 8'h45;
	dek7segBase dek7_dispS5(
		.data_in(hundreds_digit_scancode), 
		.seg(dispS5)
	);	// hundreds

	int dozens = 0;
	logic [7:0] dozens_digit_scancode = 8'h45;
	dek7segBase dek7_dispS6(
		.data_in(dozens_digit_scancode), 
		.seg(dispS6)
	);		// dozens
	
	int units = 0;
	logic [7:0] units_digit_scancode = 8'h45;
	dek7segBase dek7_dispS7(
		.data_in(units_digit_scancode), 
		.seg(dispS7)
	);		// units

	int tmp = 0;

	always@(lifes)
	begin
		case(lifes)
			0	:	lifes_digit_scancode[7:0]	<=	8'h45;	//to display 	0
			1	:	lifes_digit_scancode[7:0]	<=	8'h16;	//to display 	1
			2	:	lifes_digit_scancode[7:0]	<=	8'h1E;	//to display 	2
			3	:	lifes_digit_scancode[7:0]	<=	8'h26;	//to display 	3
		endcase // lifes
	end

	always@(points)
	begin
		if(points <= 999 && points >= 0)
		begin
			tmp = points;				// e.g. 125

			hundreds = points/100;		// 1
			tmp = tmp%100;				// 25

			dozens = tmp/10;			// 2
			tmp = tmp%10;				// 5

			units = tmp;				// 5


			case(hundreds)
				0	:	hundreds_digit_scancode[7:0]	<=	8'h45;	//to display 	0
				1	:	hundreds_digit_scancode[7:0]	<=	8'h16;	//to display 	1
				2	:	hundreds_digit_scancode[7:0]	<=	8'h1E;	//to display 	2
				3	:	hundreds_digit_scancode[7:0]	<=	8'h26;	//to display 	3
				4	:	hundreds_digit_scancode[7:0]	<=	8'h25;	//to display 	4
				5	:	hundreds_digit_scancode[7:0]	<=	8'h2E;	//to display 	5
				6	:	hundreds_digit_scancode[7:0]	<=	8'h36;	//to display 	6
				7	:	hundreds_digit_scancode[7:0]	<=	8'h3D;	//to display 	7
				8	:	hundreds_digit_scancode[7:0]	<=	8'h3E;	//to display 	8
				9	:	hundreds_digit_scancode[7:0]	<=	8'h46;	//to display 	9
			endcase // hundreds

			case(dozens)
				0	:	dozens_digit_scancode[7:0]	<=	8'h45;	//to display 	0
				1	:	dozens_digit_scancode[7:0]	<=	8'h16;	//to display 	1
				2	:	dozens_digit_scancode[7:0]	<=	8'h1E;	//to display 	2
				3	:	dozens_digit_scancode[7:0]	<=	8'h26;	//to display 	3
				4	:	dozens_digit_scancode[7:0]	<=	8'h25;	//to display 	4
				5	:	dozens_digit_scancode[7:0]	<=	8'h2E;	//to display 	5
				6	:	dozens_digit_scancode[7:0]	<=	8'h36;	//to display 	6
				7	:	dozens_digit_scancode[7:0]	<=	8'h3D;	//to display 	7
				8	:	dozens_digit_scancode[7:0]	<=	8'h3E;	//to display 	8
				9	:	dozens_digit_scancode[7:0]	<=	8'h46;	//to display 	9
			endcase // dozens

			case(units)
				0	:	units_digit_scancode[7:0]	<=	8'h45;	//to display 	0
				1	:	units_digit_scancode[7:0]	<=	8'h16;	//to display 	1
				2	:	units_digit_scancode[7:0]	<=	8'h1E;	//to display 	2
				3	:	units_digit_scancode[7:0]	<=	8'h26;	//to display 	3
				4	:	units_digit_scancode[7:0]	<=	8'h25;	//to display 	4
				5	:	units_digit_scancode[7:0]	<=	8'h2E;	//to display 	5
				6	:	units_digit_scancode[7:0]	<=	8'h36;	//to display 	6
				7	:	units_digit_scancode[7:0]	<=	8'h3D;	//to display 	7
				8	:	units_digit_scancode[7:0]	<=	8'h3E;	//to display 	8
				9	:	units_digit_scancode[7:0]	<=	8'h46;	//to display 	9
			endcase // units
		end
	end
endmodule