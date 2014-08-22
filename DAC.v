module DAC(
input enable,
input BCLK,
input DACLRCK,
output reg DACDAT,
input [15:0] data_i,//from sram
output reg readclk
);


reg DACLRCKtemp;
reg [4:0] countoutputBit,countoutputBitnext;
reg DACDATtemp;


always @(posedge BCLK) begin // useposedge
	if (DACLRCKtemp != DACLRCK) begin
		countoutputBit <= 1'b0;
		DACLRCKtemp <= DACLRCK;
	end
	else
		countoutputBit <= countoutputBitnext;
	DACDAT = DACDATtemp;
end

always @(*) begin
	if (countoutputBit != 5'd16) begin
		countoutputBitnext = countoutputBit + 1'b1;
		readclk = 1'b0;
		if (enable)
			DACDATtemp = data_i[countoutputBit];
		else
			DACDATtemp = 1'bz;
	end
	else begin
		countoutputBitnext = countoutputBit;
		readclk = 1'b1;
		DACDATtemp = 1'bz;
	end
end

endmodule
