
/*i2c-esque module optimised for the HDMI phy*/
module i2c(
  input clk_400kHz,
  input [7:0] address,
  input [7:0] data_0,
  input [7:0] data_1,
  input send,

  inout  sda,
  output scl
);

reg r_sda_oen; /*SDA output enabled: 1 = output enabled, 0 = input enabled*/
reg r_sda;     /*internal SDA value register*/

assign sda = r_sda_oen ? r_sda : 1'b0; /*state control for sda pin*/

endmodule
