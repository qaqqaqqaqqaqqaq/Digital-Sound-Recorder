//////////////// for howtodisplay alphabet /////////////////////

module LIGHT_alphabet(
output	[6:0]hex,
input	[3:0]alphabet
);

parameter A = 4'b0000;
parameter C = 4'b0001;
parameter D = 4'b0010;
parameter E = 4'b0011;
parameter L = 4'b0100;
parameter O = 4'b0101;
parameter P = 4'b0110;
parameter R = 4'b0111;
parameter S = 4'b1000;
parameter T = 4'b1001;
parameter Y = 4'b1010;
parameter F = 4'b1011;

reg [6:0]buffer;
assign hex = buffer;
always @(*) begin
	case(alphabet)
		A : buffer=7'b0001000;	
		C : buffer=7'b1000110;
		D : buffer=7'b1000000;
		E : buffer=7'b0000110;
		L : buffer=7'b1000111;
		O : buffer=7'b1000000;
		P : buffer=7'b0001100;
		R : buffer=7'b0001000;
		S : buffer=7'b0010010;
		T : buffer=7'b1111000;
		Y : buffer=7'b0011001;
		F : buffer=7'b0001110;
		default : buffer = 7'b1111111;
	endcase
end

endmodule
