module key_debounce(
input key,
input clk,
output key_out
);

reg [1:0]state;
reg [1:0]clks;
reg [1:0]next_state;
reg key_buffer;
reg out;

initial begin
clks = 7'd0;
state = 2'b00;
next_state = 2'b00;
end

always @(posedge clk) begin
	clks <= clks + 1'b1;
	state <= next_state;
end

always @(posedge clks[1]) begin
	key_buffer <= key;
end

always @(*) begin
	case (state)
	2'b00: 
		begin 
			out = 1'b1;
			if (key_buffer == 1'b0)	next_state = 2'b01;
			else next_state = 2'b00;
		end
	2'b01: 
		begin 
			out = 1'b1;
			if (key_buffer == 1'b0)	next_state = 2'b10;
			else next_state = 2'b00;
		end
	2'b10: 
		begin 
			out = 1'b0;
			if (key_buffer == 1'b0)	next_state = 2'b10;
			else next_state = 2'b11;
		end
	2'b11:
		begin 
			out = 1'b0;
			if (key_buffer == 1'b0)	next_state = 2'b10;
			else next_state = 2'b00;
		end
	endcase
end

assign key_out = out;

endmodule
