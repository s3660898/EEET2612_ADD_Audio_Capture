// simple master spi module for the ADC LTC2308
// this module needs to be rst after use

module spi (
enable, rst, clk, wdata, miso, mosi, sck, fin

);
// LTC2308 ADC
// rising edge of CONVST  initiates a conversion, after conversion is finished, pull CONVST low to enable SDO
// sdi, configures the ADC and is latched on the rising edge of the first 6 sck pulses 
// sdo, outputs the data from previous conversion. sdo shifted out serially on the falling edge of each sck pulse

// input and outputs								
	input 	enable;									// enables the spi communication (acts like slave select SS)
	input 	rst;
	input 	clk;										// system clock
	input 	[5:0] wdata;								// data to send/config adc done in miso

	input 	tri1	miso; 							// master input slave output / sdo of adc
	output  	mosi; 									// master output slave input / sdi of adc
	
	output 	sck;										// serial clock
	output	fin;										// finish flag for top level module 
	
// setup sck
reg [7:0] counter;			// counter
reg gen_sck; 					// generated sck signal
reg sck_en;

parameter maxCount = 15; 	// dummy value for simulation

// setup tranmission of data
reg [4:0] cyclebit;
reg [3:0] wbit;
reg mosidata;
reg flag; // finish flag

// spi has different modes that can change the clock
// lets sample the data at the middle of a bit to avoid metastable condition

always @(posedge clk, posedge rst)
begin
	if (rst)
		begin
			counter = 0;
			gen_sck = 0;
	
		end	
	else if (enable)
		begin
			if (counter == maxCount)
			begin
				gen_sck = ~gen_sck;
				counter = 0;
			end
			else counter = counter + 1;
		end
end

// sample the data read/write during the rising edge of SCK
always @(posedge gen_sck, posedge rst)
begin
	if ((rst))
	begin
		cyclebit = 12;
		wbit = 6;
		flag = 0;
	end
	else if (enable)
	begin
				if (cyclebit != 0)
				begin
					sck_en = 1;
					if (wbit != 0)
					begin
						mosidata = wdata[wbit - 1];
						wbit = wbit - 1;
					end
					else if (wbit == 0) mosidata = 0;
					cyclebit = cyclebit - 1;
				end
				else if (cyclebit == 0)
				begin	
					sck_en = 0;
					flag = 1;
				end
	end
	
end

// assignment
assign sck = sck_en ? gen_sck: 1'b0;
assign mosi = mosidata;
assign fin = flag;


endmodule
