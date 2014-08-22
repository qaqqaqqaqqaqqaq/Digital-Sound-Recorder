module sram_control_light(
input reset,
input [1:0] rw,//11 for r, 10 for w else for wait
input clk,//50MHz
input readclk,
input writeclk,
input forward, //1 forward, 0 backward
input [3:0] speed,
input slow,
input [15:0] data_i,
output [15:0] data_o,
output ce,
output we,
output oe,
output [19:0] addr,
inout [15:0] DQ,
output [6:0] play_time_out,
output [6:0] record_time_out,
output record_full,
output [20:0] debug
);

//wire,reg assignment
wire clks;
wire [3:0] step;
assign step = ((slow)? 1'b1 : (speed + 1'b1));
reg full;
reg [2:0] state;
reg [2:0] next_state;
reg [20:0] read_ptr, write_ptr;//be assigned to addr
reg [20:0] read_ptr_next, write_ptr_next;
reg [6:0] play_time, play_time_next;
reg [6:0] record_time, record_time_next;
reg [25:0] one_sec_counter, one_sec_counter_next;
reg one_sec;
assign ce = 1'b1/*(state != 3'd0)*/;
assign we = ((rw == 2'b10/*state == 3'd3 || state == 3'd4*/)? 1'b1 : 1'b0);
assign oe = ((rw == 2'b11/*state == 3'd1 || state == 3'd2*/)? 1'b1 : 1'b0);
assign data_o = (oe? DQ : 16'bzzzz_zzzz_zzzz_zzzz);
assign DQ = (we? data_i : 16'bzzzz_zzzz_zzzz_zzzz);
assign addr = (rw[0]? read_ptr : write_ptr);
assign clks = (rw[0]? readclk : writeclk);
assign state1 = read_ptr[2:0];
assign play_time_out = read_ptr[19:13];//play_time;
assign record_time_out = write_ptr[19:13];//record_time;
assign record_full = full;

//constant assignment
parameter ADDR_BEGIN = 20'b0000_0000_0000_0000_0000;
parameter ADDR_END   = 20'b1111_1111_1111_1111_1111;


//finite state machine
parameter waiting = 3'd0;//start state
parameter read_ini = 3'd1;//for setting ptr, timer
parameter read = 3'd2;
parameter write_ini = 3'd3;
parameter write = 3'd4;
parameter backward = 3'd5;



always @(posedge clk) begin
	if (reset == 1'b1) begin
		state <= waiting;
	end
	else begin
		state <= next_state;
	end
end

reg resett;
reg enablereset;

always @(*) begin
	if (reset == 1'b1)
	//	enablereset <= 1'b1;
		resett <= ~enablereset;
end

always @(posedge clks) begin
	if (enablereset != resett) begin
		if (read_ptr == 1'b0 && write_ptr == 1'b0) begin
			enablereset <= resett;
		end
		else begin
			read_ptr <= 21'd0;
			write_ptr <= 21'd0;
		end
	end
	else begin
		read_ptr <= read_ptr_next;
		write_ptr <= write_ptr_next;
	end
end


wire [20:0] xx = read_ptr - step;
//handle ptr
always @(*) begin
	if (reset == 1'b1) begin
		read_ptr_next = 1'b0;
		write_ptr_next = 1'b0;
	end
	else begin
		if (read_ptr == {1'b0,ADDR_END})	
			full = 1'b1;
		else
			full = 1'b0;
	case (state)
		read_ini : begin
			read_ptr_next = read_ptr;
			write_ptr_next = write_ptr;
		end
		read : begin
			if(forward == 1'b1) begin
				if (read_ptr + step <= write_ptr)
					read_ptr_next = read_ptr + step/*1'b1*/;
				else
					read_ptr_next = write_ptr;//if repeat, turn to ADDR_BEGIN
			end
			else begin
				if (xx[20] != 1'b1/*read_ptr > ADDR_BEGIN*/)
					read_ptr_next = read_ptr - step/*1'b1*/;
				else
					read_ptr_next = ADDR_BEGIN;//if repeat, turn to ADDR_BEGIN
			end
			write_ptr_next = write_ptr;
		end
		write_ini : begin
			read_ptr_next = read_ptr;
			write_ptr_next = write_ptr;//consider rec continue?
		end
		write : begin
			if (write_ptr != ADDR_END)
				write_ptr_next = write_ptr + 1'b1;
			else
				write_ptr_next = write_ptr;
			read_ptr_next = read_ptr;
		end
	default : begin
		read_ptr_next = read_ptr;
		write_ptr_next = write_ptr;
	end
	endcase
	end
end

//finite state machinne
always @(*) begin
	case (state)
		waiting : begin
			if (rw == 2'b11)
				next_state = read_ini;
			else if (rw == 2'b10)
				next_state = write_ini;
			else
				next_state = state;
		end
		read_ini : begin
	//		if (read_ptr == ADDR_BEGIN)
				next_state = state + 1'b1;
	//		else
	//			next_state = state;
		end
		read : begin
			if (rw == 2'b00)
				next_state = waiting;
			else
				next_state = state;
		end
		write_ini : begin
	//		if (write_ptr != ADDR_BEGIN)
	//			next_state = state;
	//		else
				next_state = state + 1'b1;
		end
		write : begin
			if (rw == 2'b00)
				next_state = waiting;
			else
				next_state = state;
		end
		default : next_state = waiting;
	endcase
end

//handle timer

//timer
always @(posedge clk) begin
	if(one_sec_counter <= 26'd25000000) begin
		one_sec_counter <= one_sec_counter_next;
		one_sec <= one_sec;
	end
	else begin
		one_sec_counter <= 26'b0;
		one_sec <= ~one_sec;
	end
end

always @(*) begin
	if (state == read_ini || state == read)
		one_sec_counter_next = one_sec_counter + step;
	else
		one_sec_counter_next = one_sec_counter + 1'b1;
end

always @(posedge one_sec) begin
	if (reset == 1'b1) begin
		play_time <= 1'b0;
		record_time <=1'b0;
	end
	else begin
		play_time <= play_time_next;
		record_time <= record_time_next;
	end
end

//handle next_time
always @(*) begin
	case (state)
		read_ini : begin
			play_time_next = play_time;
			record_time_next = record_time;
		end
		read : begin
			if (forward == 1'b1) begin
				if (read_ptr != write_ptr)
					play_time_next = play_time + 1'b1;
				else
					play_time_next = play_time;//if repeat, turn to 0
			end
			else begin
				if (read_ptr != ADDR_BEGIN)
					play_time_next = play_time - 1'b1;
				else
					play_time_next = play_time;//if repeat, turn to 0
			end
			record_time_next = record_time;
		end
		write_ini : begin
			play_time_next = play_time;
			record_time_next = record_time;//consider rec continue?
		end
		write : begin
			if (write_ptr != ADDR_END)
				record_time_next = record_time +1'b1;
			else
				record_time_next = record_time;
			play_time_next = play_time;
		end
	default : begin
		play_time_next = play_time;
		record_time_next = record_time;
	end
	endcase
end

endmodule



















