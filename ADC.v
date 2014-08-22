module ADC(
input enable,
input BCLK,
input ADCLRCK,
input ADCDAT,
output reg [15:0] data_o,
output reg writeclk
);

reg ADCLRCKtemp;
reg [4:0]countinputBit,countinputBitnext;
reg [15:0] data_o_temp;

always @(posedge BCLK) begin // useposedge
	if (ADCLRCKtemp != ADCLRCK) begin
		countinputBit <= 1'b0;
		ADCLRCKtemp <= ADCLRCK;
	end
	else
		countinputBit <= countinputBitnext;

		
		
end

always @(negedge BCLK) begin
	data_o[countinputBit - 5'd1 ] <= data_o_temp[countinputBit - 5'd1];
end

always @(*) begin
	if (enable) begin
		if (countinputBit != 5'd17) begin
			countinputBitnext = countinputBit + 5'd1;
			writeclk = 1'b0;
		end
		else begin
			countinputBitnext = countinputBit;
			writeclk = 1'b1;
		end
	end
	else begin
		countinputBitnext = countinputBit;
		writeclk = 1'b1;
	end
end

always @(*) begin
	if (countinputBit == 5'b0) begin 
		data_o_temp[countinputBit - 5'd1] = 1'bx;
	end
	else begin
		if (enable && countinputBit < 5'd17)
			data_o_temp[countinputBit - 5'd1] = ADCDAT;
		else
			data_o_temp[countinputBit - 5'd1] = 1'bx;
	end
end

endmodule
