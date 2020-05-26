module audio_capture(
  input clk_50MHz,
  output gpio_00, /*sda*/
  output gpio_01, /*scl*/
  output gpio_02, /*clk_400kHz*/
  output gpio_03  /*gnd*/
);

wire clk_400kHz;

/*clock divider*/
clk_50MHz_400kHz clk_50MHz_400kHz(
  .clk_50MHz(clk_50MHz),
  .clk_400kHz(clk_400kHz)
);

/*test i2c controller*/
i2c i2c(
  .clk_400kHz(clk_400kHz),
  .address(8'b1100_1100),
  .data_0(8'b0001_0001),
  .data_1(8'b0011_0011),
  .sda(gpio_00),
  .scl(gpio_01)
);

assign gpio_02 = clk_400kHz;
assign gpio_03 = 1'b0;

endmodule
