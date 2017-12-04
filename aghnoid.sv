/*** naprawic kolory ***/
`include "clk_divider_by2.sv"
`include "oneshot.sv"
`include "keyboard.sv"
`include "vga.sv"
`include "game_status.sv"

module aghnoid(master_clk, kb_clk, data, DAC_clk, VGA_R, VGA_G, VGA_B, VGA_hSync, VGA_vSync, blank_n, dispS1, dispS2, dispS3, dispS4, dispS5, dispS6, dispS7);
	input master_clk, kb_clk, data; 					// 50MHz

	/***************/
	/*** OUTPUTS ***/
	/***************/
	output logic [9:0] VGA_R, VGA_G, VGA_B;  			// Red, Green, Blue VGA signals
	output VGA_hSync, VGA_vSync, DAC_clk, blank_n; 		// Horizontal and Vertical sync signals
	output logic [6:0] dispS1;	// key pressed
	output logic [6:0] dispS2;	// L (lifes)
	output logic [6:0] dispS3;	// lifes remaining
	output logic [6:0] dispS4;	// P (points)
	output logic [6:0] dispS5;	// hundreds
	output logic [6:0] dispS6;	// dozens
	output logic [6:0] dispS7;	// units

	/*************/
	/*** WIRES ***/
	/*************/
	wire [9:0] xCount; // x pixel
	wire [9:0] yCount; // y pixel
	wire displayArea; 	//is it in the active display area?
	wire VGA_clk; 		//25 MHz	
	wire R;
	wire G;
	wire B;
	wire [7:0] scan_code1;
	wire reading_available, scan_ready;
	wire update;

	/*********************/
	/*** GAME ELEMENTS ***/
	/*********************/

	// State
	parameter bksp = 8'h66;			// backspace key = game reset
	parameter enter = 8'h5A;		// enter = start game
	parameter key_d = 8'h23;		// key d = right -> 
	parameter key_a = 8'h1C;		// key a = left <-
	parameter one_point = 4;
	logic [7:0] scan_code;
	logic start = 0;				
	logic reset = 0;					

	// Window //
	parameter window_width = 640;
	parameter window_height = 480;

	// Border //
	logic border;
	parameter border_width = 10;

	// Rocket //
	logic rocket;
	parameter rocket_width = 80, rocket_height = 10;
	parameter rocket_x_min_pos = border_width+1;							// 11
	parameter rocket_x_max_pos = window_width - (border_width+1);			// 629
	int rocket_x_pos = (window_width/2) - (rocket_width/2);					// 280
	int rocket_y_pos = window_height - (2*border_width + rocket_height);	// 450
	
	// Ball //
	logic ball;
	parameter ball_radius = 7;
	int ball_pos_x = window_width/2;	// 320
	int ball_pos_y = 450 - ball_radius;	// 443
	int ball_pos_x_direction = 0;
	int ball_pos_y_direction = 2;
	
	// Bricks //
	parameter bricks_rows = 6;
	parameter bricks_columns = 20;
	parameter brick_width = 28;
	parameter brick_height = 15;
	parameter brick_break = 2;
	logic [bricks_columns-1:0][bricks_rows-1:0] bricks;
	logic [bricks_columns-1:0][bricks_rows-1:0] bricks_mask; // 0 -> active | 1 -> inactive
	int bricks_pos_x[bricks_columns][bricks_rows];
	int bricks_pos_y[bricks_columns][bricks_rows];

	// Game Status //
	int lifes = 3;
	int points = 0;
	
	/***************/
	/*** MODULES ***/
	/***************/

	clk_divider_by2 divider(master_clk, VGA_clk); 									// Divide 50MHz clock by 2 to 25MHz
	vga gen(VGA_clk, xCount, yCount, displayArea, VGA_hSync, VGA_vSync, blank_n);	// Generates xCount, yCount and horizontal/vertical sync signals	
	oneshot pulser(reading_available, scan_ready, master_clk);
	keyboard keyboard_handler(kb_clk, data, VGA_clk, reading_available, scan_ready, scan_code1);
	update_clk updater(master_clk, update);

	dek7segBase dek7_dispS1(
		.data_in(scan_code1), 
		.seg(dispS1)
	);	// key pressed

	dek7segBase dek7_dispS2(
		.data_in(8'h4B), 
		.seg(dispS2)
	);	// L (lifes)

	dek7segBase dek7_dispS4(
		.data_in(8'h4D), 
		.seg(dispS4)
	);	// P (points)

	game_status status(lifes, points, dispS3, dispS5, dispS6, dispS7);

	/***************/
	/*** ASSIGNS ***/
	/***************/

	assign DAC_clk = VGA_clk;	
	/* DLA 6 WIERSZY*/
	assign R = (displayArea && (
					bricks	[	0	]	[	0	]	||
					bricks	[	1	]	[	0	]	||
					bricks	[	2	]	[	0	]	||
					bricks	[	3	]	[	0	]	||
					bricks	[	4	]	[	0	]	||
					bricks	[	5	]	[	0	]	||
					bricks	[	6	]	[	0	]	||
					bricks	[	7	]	[	0	]	||
					bricks	[	8	]	[	0	]	||
					bricks	[	9	]	[	0	]	||
					bricks	[	10	]	[	0	]	||
					bricks	[	11	]	[	0	]	||
					bricks	[	12	]	[	0	]	||
					bricks	[	13	]	[	0	]	||
					bricks	[	14	]	[	0	]	||
					bricks	[	15	]	[	0	]	||
					bricks	[	16	]	[	0	]	||
					bricks	[	17	]	[	0	]	||
					bricks	[	18	]	[	0	]	||
					bricks	[	19	]	[	0	]	||
					bricks	[	0	]	[	1	]	||
					bricks	[	1	]	[	1	]	||
					bricks	[	2	]	[	1	]	||
					bricks	[	3	]	[	1	]	||
					bricks	[	4	]	[	1	]	||
					bricks	[	5	]	[	1	]	||
					bricks	[	6	]	[	1	]	||
					bricks	[	7	]	[	1	]	||
					bricks	[	8	]	[	1	]	||
					bricks	[	9	]	[	1	]	||
					bricks	[	10	]	[	1	]	||
					bricks	[	11	]	[	1	]	||
					bricks	[	12	]	[	1	]	||
					bricks	[	13	]	[	1	]	||
					bricks	[	14	]	[	1	]	||
					bricks	[	15	]	[	1	]	||
					bricks	[	16	]	[	1	]	||
					bricks	[	17	]	[	1	]	||
					bricks	[	18	]	[	1	]	||
					bricks	[	19	]	[	1	]	||
					bricks	[	0	]	[	2	]	||
					bricks	[	1	]	[	2	]	||
					bricks	[	2	]	[	2	]	||
					bricks	[	3	]	[	2	]	||
					bricks	[	4	]	[	2	]	||
					bricks	[	5	]	[	2	]	||
					bricks	[	6	]	[	2	]	||
					bricks	[	7	]	[	2	]	||
					bricks	[	8	]	[	2	]	||
					bricks	[	9	]	[	2	]	||
					bricks	[	10	]	[	2	]	||
					bricks	[	11	]	[	2	]	||
					bricks	[	12	]	[	2	]	||
					bricks	[	13	]	[	2	]	||
					bricks	[	14	]	[	2	]	||
					bricks	[	15	]	[	2	]	||
					bricks	[	16	]	[	2	]	||
					bricks	[	17	]	[	2	]	||
					bricks	[	18	]	[	2	]	||
					bricks	[	19	]	[	2	]	||
					bricks	[	0	]	[	4	]	||
					bricks	[	1	]	[	4	]	||
					bricks	[	2	]	[	4	]	||
					bricks	[	3	]	[	4	]	||
					bricks	[	4	]	[	4	]	||
					bricks	[	5	]	[	4	]	||
					bricks	[	6	]	[	4	]	||
					bricks	[	7	]	[	4	]	||
					bricks	[	8	]	[	4	]	||
					bricks	[	9	]	[	4	]	||
					bricks	[	10	]	[	4	]	||
					bricks	[	11	]	[	4	]	||
					bricks	[	12	]	[	4	]	||
					bricks	[	13	]	[	4	]	||
					bricks	[	14	]	[	4	]	||
					bricks	[	15	]	[	4	]	||
					bricks	[	16	]	[	4	]	||
					bricks	[	17	]	[	4	]	||
					bricks	[	18	]	[	4	]	||
					bricks	[	19	]	[	4	]	||

						border));
						
	assign G = (displayArea && ( 
						bricks	[	0	]	[	0	]	||
						bricks	[	1	]	[	0	]	||
						bricks	[	2	]	[	0	]	||
						bricks	[	3	]	[	0	]	||
						bricks	[	4	]	[	0	]	||
						bricks	[	5	]	[	0	]	||
						bricks	[	6	]	[	0	]	||
						bricks	[	7	]	[	0	]	||
						bricks	[	8	]	[	0	]	||
						bricks	[	9	]	[	0	]	||
						bricks	[	10	]	[	0	]	||
						bricks	[	11	]	[	0	]	||
						bricks	[	12	]	[	0	]	||
						bricks	[	13	]	[	0	]	||
						bricks	[	14	]	[	0	]	||
						bricks	[	15	]	[	0	]	||
						bricks	[	16	]	[	0	]	||
						bricks	[	17	]	[	0	]	||
						bricks	[	18	]	[	0	]	||
						bricks	[	19	]	[	0	]	||
						bricks	[	0	]	[	2	]	||
						bricks	[	1	]	[	2	]	||
						bricks	[	2	]	[	2	]	||
						bricks	[	3	]	[	2	]	||
						bricks	[	4	]	[	2	]	||
						bricks	[	5	]	[	2	]	||
						bricks	[	6	]	[	2	]	||
						bricks	[	7	]	[	2	]	||
						bricks	[	8	]	[	2	]	||
						bricks	[	9	]	[	2	]	||
						bricks	[	10	]	[	2	]	||
						bricks	[	11	]	[	2	]	||
						bricks	[	12	]	[	2	]	||
						bricks	[	13	]	[	2	]	||
						bricks	[	14	]	[	2	]	||
						bricks	[	15	]	[	2	]	||
						bricks	[	16	]	[	2	]	||
						bricks	[	17	]	[	2	]	||
						bricks	[	18	]	[	2	]	||
						bricks	[	19	]	[	2	]	||
						bricks	[	0	]	[	3	]	||
						bricks	[	1	]	[	3	]	||
						bricks	[	2	]	[	3	]	||
						bricks	[	3	]	[	3	]	||
						bricks	[	4	]	[	3	]	||
						bricks	[	5	]	[	3	]	||
						bricks	[	6	]	[	3	]	||
						bricks	[	7	]	[	3	]	||
						bricks	[	8	]	[	3	]	||
						bricks	[	9	]	[	3	]	||
						bricks	[	10	]	[	3	]	||
						bricks	[	11	]	[	3	]	||
						bricks	[	12	]	[	3	]	||
						bricks	[	13	]	[	3	]	||
						bricks	[	14	]	[	3	]	||
						bricks	[	15	]	[	3	]	||
						bricks	[	16	]	[	3	]	||
						bricks	[	17	]	[	3	]	||
						bricks	[	18	]	[	3	]	||
						bricks	[	19	]	[	3	]	||
						bricks	[	0	]	[	5	]	||
						bricks	[	1	]	[	5	]	||
						bricks	[	2	]	[	5	]	||
						bricks	[	3	]	[	5	]	||
						bricks	[	4	]	[	5	]	||
						bricks	[	5	]	[	5	]	||
						bricks	[	6	]	[	5	]	||
						bricks	[	7	]	[	5	]	||
						bricks	[	8	]	[	5	]	||
						bricks	[	9	]	[	5	]	||
						bricks	[	10	]	[	5	]	||
						bricks	[	11	]	[	5	]	||
						bricks	[	12	]	[	5	]	||
						bricks	[	13	]	[	5	]	||
						bricks	[	14	]	[	5	]	||
						bricks	[	15	]	[	5	]	||
						bricks	[	16	]	[	5	]	||
						bricks	[	17	]	[	5	]	||
						bricks	[	18	]	[	5	]	||
						bricks	[	19	]	[	5	]	||
						ball ) );
	assign B = (displayArea && ( 
						bricks	[	0	]	[	0	]	||
						bricks	[	1	]	[	0	]	||
						bricks	[	2	]	[	0	]	||
						bricks	[	3	]	[	0	]	||
						bricks	[	4	]	[	0	]	||
						bricks	[	5	]	[	0	]	||
						bricks	[	6	]	[	0	]	||
						bricks	[	7	]	[	0	]	||
						bricks	[	8	]	[	0	]	||
						bricks	[	9	]	[	0	]	||
						bricks	[	10	]	[	0	]	||
						bricks	[	11	]	[	0	]	||
						bricks	[	12	]	[	0	]	||
						bricks	[	13	]	[	0	]	||
						bricks	[	14	]	[	0	]	||
						bricks	[	15	]	[	0	]	||
						bricks	[	16	]	[	0	]	||
						bricks	[	17	]	[	0	]	||
						bricks	[	18	]	[	0	]	||
						bricks	[	19	]	[	0	]	||
						bricks	[	0	]	[	3	]	||
						bricks	[	1	]	[	3	]	||
						bricks	[	2	]	[	3	]	||
						bricks	[	3	]	[	3	]	||
						bricks	[	4	]	[	3	]	||
						bricks	[	5	]	[	3	]	||
						bricks	[	6	]	[	3	]	||
						bricks	[	7	]	[	3	]	||
						bricks	[	8	]	[	3	]	||
						bricks	[	9	]	[	3	]	||
						bricks	[	10	]	[	3	]	||
						bricks	[	11	]	[	3	]	||
						bricks	[	12	]	[	3	]	||
						bricks	[	13	]	[	3	]	||
						bricks	[	14	]	[	3	]	||
						bricks	[	15	]	[	3	]	||
						bricks	[	16	]	[	3	]	||
						bricks	[	17	]	[	3	]	||
						bricks	[	18	]	[	3	]	||
						bricks	[	19	]	[	3	]	||
						bricks	[	0	]	[	4	]	||
						bricks	[	1	]	[	4	]	||
						bricks	[	2	]	[	4	]	||
						bricks	[	3	]	[	4	]	||
						bricks	[	4	]	[	4	]	||
						bricks	[	5	]	[	4	]	||
						bricks	[	6	]	[	4	]	||
						bricks	[	7	]	[	4	]	||
						bricks	[	8	]	[	4	]	||
						bricks	[	9	]	[	4	]	||
						bricks	[	10	]	[	4	]	||
						bricks	[	11	]	[	4	]	||
						bricks	[	12	]	[	4	]	||
						bricks	[	13	]	[	4	]	||
						bricks	[	14	]	[	4	]	||
						bricks	[	15	]	[	4	]	||
						bricks	[	16	]	[	4	]	||
						bricks	[	17	]	[	4	]	||
						bricks	[	18	]	[	4	]	||
						bricks	[	19	]	[	4	]	||
						rocket ) );

	initial
	begin
		for (int i = 0; i < bricks_columns; i++)
			for (int j = 0; j < bricks_rows; j++)
			begin
				// LEFT TOP CORNER OF BRICK
				bricks_pos_x[i][j] = 2*border_width + i*brick_width + i*brick_break;
				bricks_pos_y[i][j] = 2*border_width + j*brick_height + j*brick_break;
				bricks_mask[i][j] = 1;
			end		
	end

	/*************************************************************************************************************/
	/************************************************* GAME LOGIC ************************************************/
	/*************************************************************************************************************/

	/***********************/
	/*** Display Borders ***/
	/***********************/

	always @(posedge VGA_clk)
	begin
			border <= (((xCount >= 0) && (xCount <= border_width) 
					|| 	(xCount >= window_width-border_width) 	&& (xCount <= window_width)) 
					|| (yCount >= 0) && (yCount <= border_width));
	end

	/**********************/
	/*** Display Rocket ***/
	/**********************/

	always @(posedge VGA_clk)
	begin
			rocket <= (((xCount > rocket_x_pos) && (xCount < (rocket_x_pos + rocket_width)) && ((yCount >= rocket_y_pos) && (yCount <= (rocket_y_pos + rocket_height))) ));
	end
	
	/**********************/
	/*** Display Bricks ***/
	/**********************/

	always @(posedge VGA_clk)
	begin
		for (int i = 0; i < bricks_columns; i++)
			for (int j = 0; j < bricks_rows; j++)
					bricks[i][j] <= (
									(xCount >= bricks_pos_x[i][j]) && (xCount <= (bricks_pos_x[i][j]+brick_width)) 
									&& 
									(yCount >= bricks_pos_y[i][j]) && (yCount <= (bricks_pos_y[i][j]+brick_height))
									) && bricks_mask[i][j];
	end

	/********************/
	/*** Display Ball ***/
	/********************/
	always @(posedge VGA_clk)
	begin
			ball <= (((xCount - ball_pos_x)*(xCount - ball_pos_x) + (yCount - ball_pos_y)*(yCount - ball_pos_y)) < (ball_radius * ball_radius));
	end

	/*********************/
	/*** Start / Reset ***/
	/*********************/
	always @(posedge update)
	begin
		scan_code = scan_code1;
		
		if(scan_code == enter)
		begin
			start = 1;
		end		
		else if(scan_code == bksp)
		begin
			reset = 1;
		end		
	
	
	/*******************/
	/*** Move Rocket ***/
	/*******************/

		if(reset == 0 && start == 1)
		begin
				if( ((rocket_x_pos + rocket_width) < rocket_x_max_pos) && ( ( rocket_x_pos ) > rocket_x_min_pos))
				begin
					if(scan_code == key_d)		// right
						rocket_x_pos = rocket_x_pos + 2;
					else if(scan_code == key_a)				// left
						rocket_x_pos = rocket_x_pos - 2;
				end
				else if (rocket_x_pos + rocket_width >= rocket_x_max_pos-1)
				begin
					if(scan_code == key_d)		// right
						rocket_x_pos = rocket_x_pos;
					else if(scan_code == key_a)	// left
						rocket_x_pos = rocket_x_pos - 2;
				end
				else if (rocket_x_pos <= rocket_x_min_pos+1)
				begin
					if(scan_code == key_d)		// right
						rocket_x_pos = rocket_x_pos + 2;
					else if(scan_code == key_a)	// left
						rocket_x_pos = rocket_x_pos;
				end
		
		/********************************************/
	/*** Move Ball And Handle Ball Collisions ***/
	/********************************************/

			// Right border side
			if( ball_pos_x + ball_radius == window_width-border_width)
			begin
				ball_pos_x_direction = ball_pos_x_direction * (-1);
			end // Left border side
			else if( ball_pos_x - ball_radius == border_width)
			begin
				ball_pos_x_direction = ball_pos_x_direction * (-1);
			end // Bottom border side
			else if( ball_pos_y + ball_radius == window_height)
			begin				
				if(lifes > 0)
				begin
					lifes = lifes - 1;
					if(points-one_point*bricks_columns >= 0)
					begin
						points = points - one_point*bricks_columns;
					end
					else
					begin
						points = 0;
					end
					reset = 1;
					scan_code = 0;
				end
				else
				begin
					start = 0;
				end
			end // Top border side
			else if( ball_pos_y - ball_radius == border_width)
			begin
				ball_pos_y_direction = ball_pos_y_direction * (-1);
			end
			///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			else if( (ball_pos_y + ball_radius == rocket_y_pos) && (ball_pos_x >= rocket_x_pos) && (ball_pos_x <= rocket_x_pos + rocket_width))
			begin	// Top Rocket Collision
				if((ball_pos_x >= rocket_x_pos) && (ball_pos_x < rocket_x_pos + 3*rocket_width/8)) 
				begin
					if(ball_pos_x_direction == 0)
					begin
						ball_pos_x_direction = -1;
					end
				end
				else if((ball_pos_x >= rocket_x_pos + 3*rocket_width/8) && (ball_pos_x < rocket_x_pos + 5*rocket_width/8))
				begin
					ball_pos_x_direction = 0;
				end
				else if((ball_pos_x >= rocket_x_pos + 5*rocket_width/8) && (ball_pos_x < rocket_x_pos + rocket_width))
				begin
					if(ball_pos_x_direction == 0)
					begin
						ball_pos_x_direction = 1;
					end
				end
				ball_pos_y_direction = ball_pos_y_direction * (-1);
			end
			else if( (ball_pos_y >= rocket_y_pos) && (ball_pos_y <= rocket_y_pos + rocket_height) && (ball_pos_x + ball_radius == rocket_x_pos))
			begin	// Left Rocket Collision
				ball_pos_x_direction = ball_pos_x_direction * (-1);		
			end
			else if( (ball_pos_y >= rocket_y_pos) && (ball_pos_y <= rocket_y_pos + rocket_height) && (ball_pos_x - ball_radius == rocket_x_pos + rocket_width))
			begin	// Right Rocket Collision
				ball_pos_x_direction = ball_pos_x_direction * (-1);		
			end
			///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			else
			begin
				for (int i = 0; i < bricks_columns; i++)
					for (int j = 0; j < bricks_rows; j++)
						if(bricks_mask[i][j])
						begin	
						
							if(((bricks_pos_x[i][j] <= ball_pos_x) && (bricks_pos_x[i][j] + brick_width >= ball_pos_x)) &&
									((bricks_pos_y[i][j] == ball_pos_y + ball_radius) || (bricks_pos_y[i][j] + brick_height == ball_pos_y - ball_radius)))
							begin
								ball_pos_y_direction = ball_pos_y_direction * (-1);		
								points = points + one_point;	
								bricks_mask[i][j] = 0;
							end
							else if(((bricks_pos_y[i][j] <= ball_pos_y) && (bricks_pos_y[i][j] + brick_height >= ball_pos_y)) &&
									((bricks_pos_x[i][j] == ball_pos_x + ball_radius) || (bricks_pos_x[i][j] + brick_width == ball_pos_x - ball_radius)))
							begin
								ball_pos_x_direction = ball_pos_x_direction * (-1);		
								points = points + one_point;	
								bricks_mask[i][j] = 0;
							end
							else if((bricks_pos_x[i][j] - ball_pos_x <= ball_radius) || (ball_pos_x - bricks_pos_x[i][j] + brick_width <= ball_radius))
							begin
								if((((bricks_pos_x[i][j] + brick_width - ball_pos_x)*(bricks_pos_x[i][j] + brick_width - ball_pos_x)+(bricks_pos_y[i][j] + brick_height - ball_pos_y)*(bricks_pos_y[i][j] + brick_height - ball_pos_y)) <= ball_radius * ball_radius) ||
								   (((bricks_pos_x[i][j] + brick_width - ball_pos_x)*(bricks_pos_x[i][j] + brick_width - ball_pos_x)+(bricks_pos_y[i][j] - ball_pos_y)*(bricks_pos_y[i][j] - ball_pos_y)) <= ball_radius * ball_radius) ||
								   (((bricks_pos_x[i][j] - ball_pos_x)*(bricks_pos_x[i][j] - ball_pos_x)+(bricks_pos_y[i][j] + brick_height - ball_pos_y)*(bricks_pos_y[i][j] + brick_height - ball_pos_y)) <= ball_radius * ball_radius) ||
								   (((bricks_pos_x[i][j] - ball_pos_x)*(bricks_pos_x[i][j] - ball_pos_x)+(bricks_pos_y[i][j] - ball_pos_y)*(bricks_pos_y[i][j] - ball_pos_y)) <= ball_radius * ball_radius)
								)
								begin
									ball_pos_y_direction = ball_pos_y_direction * (-1);	
									ball_pos_x_direction = ball_pos_x_direction * (-1);	
									points = points + one_point;	
									bricks_mask[i][j] = 0;
								end
							end
						end
			end
			///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			ball_pos_x = ball_pos_x + ball_pos_x_direction;
			ball_pos_y = ball_pos_y + ball_pos_y_direction;
		end	
		else
		begin
			rocket_x_pos = (window_width/2) - (rocket_width/2);					
			rocket_y_pos = window_height - (2*border_width + rocket_height);	
		
			ball_pos_x = window_width/2;	
			ball_pos_y = 450 - ball_radius;	
			ball_pos_x_direction = 0;
			ball_pos_y_direction = 2;
			if(scan_code == bksp)
			begin
				for (int i = 0; i < bricks_columns; i++)
					for (int j = 0; j < bricks_rows; j++)
					begin
						bricks_mask[i][j] = 1;
					end		
				points = 0;
				lifes = 3;
			end
			reset = 0;
		end
	end
	
	always@(posedge VGA_clk)
	begin
		VGA_R = {10{R}};
		VGA_G = {10{G}};
		VGA_B = {10{B}};
	end 
endmodule // aghnoid

