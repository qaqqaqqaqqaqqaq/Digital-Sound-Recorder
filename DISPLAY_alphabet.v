module DISPLAY_alphabet(
output [6:0]hex0, hex1, hex2, hex3,
input [1:0]state
);
parameter PLAY = 2'b11;
parameter STOP = 2'b00;
parameter REC  = 2'b10;
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
parameter whatever = 4'b1111;

reg [4:0] alp[3:0];
wire [6:0] hex_buffer[3:0];
reg isoutofphase;

always @(*) begin
	if 		( state == PLAY) 	begin
		alp[3]=P;
		alp[2]=L;
		alp[1]=A;
		alp[0]=Y;
	end
	else if ( state == STOP ) 	begin
		alp[3]=S;
		alp[2]=T;
		alp[1]=O;
		alp[0]=P;
	end
	else if ( state == REC )	begin
		alp[3]=whatever;
		alp[2]=R;
		alp[1]=E;
		alp[0]=C;
	end
	else						begin
		alp[3]=whatever;
		alp[2]=whatever;
		alp[1]=whatever;
		alp[0]=whatever;	
	end
end

LIGHT_alphabet alp00(hex_buffer[0], alp[0]);
LIGHT_alphabet alp01(hex_buffer[1], alp[1]);
LIGHT_alphabet alp02(hex_buffer[2], alp[2]);
LIGHT_alphabet alp03(hex_buffer[3], alp[3]);

assign hex0 = hex_buffer[0];
assign hex1 = hex_buffer[1];
assign hex2 = hex_buffer[2];
assign hex3 = hex_buffer[3];
endmodule
