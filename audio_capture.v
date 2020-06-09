module single_shot(
  input clk,
  input rst,
  input start,
  output q
);

reg can_fire;
reg r_q;

always @(posedge(clk))
begin
  if(rst)
  begin
    can_fire = 0;
    r_q = 0;
  end
  else
  begin
    if(r_q ==1)
      r_q = 0;

    if(can_fire && start)
    begin
      r_q = 1;
      can_fire = 0;
    end

    if(!start)
      can_fire = 1;
  end
end

assign q = r_q;

endmodule

module audio_capture(
  input clk_50MHz,
  input sw0,
  input key0,
  output gpio_00, /*sda*/
  output gpio_01, /*scl*/
  output gpio_02, /*clk_250kHz*/
  output gpio_03, /*gnd*/
  output gpio_04  /*gnd*/
);

wire clk_250kHz;

/*clock divider*/
clk_50MHz_250kHz clk_50MHz_250kHz(
  .clk_50MHz(clk_50MHz),
  .clk_250kHz(clk_250kHz)
);

/*pulse for i2c debugging*/
wire pulse;

single_shot ss(
  .clk(clk_250kHz),
  .rst(sw0),
  .start(!key0),
  .q(pulse)
);

/*test i2c controller*/
i2c i2c(
  .clk(clk_250kHz),
  .start(pulse),
  .rst(sw0),
  .cmd_address(8'b100_1100),
  .data_0(8'b0001_0001),
  .data_1(8'b0011_0011),
  .sda(gpio_00),
  .scl(gpio_01)
);

assign gpio_02 = clk_250kHz;
assign gpio_03 = 1'b0;
assign gpio_04 = 1'b0;

endmodule
