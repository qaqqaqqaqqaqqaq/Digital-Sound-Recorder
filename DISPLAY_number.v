module DISPLAY_number(
output [6:0]hex4, hex5,
input [6:0]TIME
);
reg [6:0] number[1:0];
wire [6:0] hex_buffer[1:0];
reg isoutofphase;
always @(*) begin
	number[0]=TIME%4'd10;
	number[1]=TIME/4'd10;	
	if ( number[1]== 4'd9  && number[0]== 4'd9) begin
		isoutofphase = 1'b1;
	end
	else begin
		isoutofphase = 1'b0;
	end
end

LIGHT_number sec_1(hex_buffer[0], number[0], isoutofphase);
LIGHT_number sec_10(hex_buffer[1], number[1], isoutofphase);

assign hex4 = hex_buffer[0];
assign hex5 = hex_buffer[1];
endmodule

//////////////////////////////    module  LIGHT (number) ///////////////////////////////

module LIGHT_number(
output	[6:0]hex,
input 	[6:0]number,
input 	isoutofphase
);
reg [6:0]buffer;
assign hex = buffer;
always @(*) begin
if (isoutofphase == 1'b1)begin
	buffer = 7'b0010000; // 9 
end
else begin
	case(number)
		0 : buffer=7'b1000000;
		1 : buffer=7'b1111001;
		2 : buffer=7'b0100100;
		3 : buffer=7'b0110000;
		4 : buffer=7'b0011001;
		5 : buffer=7'b0010010;
		6 : buffer=7'b0000010;
		7 : buffer=7'b1111000;
		8 : buffer=7'b0000000;
		9 : buffer=7'b0010000;
		default : buffer = 7'b1000000;// 0 
	endcase
end
end

endmodule
