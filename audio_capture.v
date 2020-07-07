module audio_capture(
  input clk_50MHz,
  input sw0,
  input key0,
  inout gpio_00, /*sda*/
  inout gpio_01, /*scl*/
  output gpio_02, /*clk_60kHz*/
  output gpio_03, /*gnd*/
  output gpio_04, /*gnd*/

  /*hdmi data output*/
  output [23:0] hdmi_tx_d,    /*data*/
  output        hdmi_tx_clk,  /*video clock*/
  output        hdmi_tx_de,   /*data enable*/
  output        hdmi_tx_hs,   /*hoizontal sync*/
  output        hdmi_tx_vs,   /*vertical sync*/

  /*hdmi control output*/
  inout tri1 hdmi_i2c_sda,        /*hdmi config i2c sda*/
  inout tri1 hdmi_i2c_scl         /*hdmi config i2c scl*/
);

wire clk_hdmi;

/*hdmi 1080p 148.5MHz pll clk*/
pll_hdmi_clk pll_hdmi_clk(
  .refclk(clk_50MHz),
  .rst(sw0),
  .outclk_0(clk_hdmi),
  .locked()
);

/*50MHz -> 60kHz clock divider for i2c*/
wire clk_60kHz;
clk_div clk_d(
  .rst(sw0),
  .clk_in(clk_50MHz),
  .clk_out(clk_60kHz)
);

/*pulse for i2c debugging*/
wire pulse;
wire i2c_busy;
wire i2c_start;

wire [6:0] address;
wire [7:0] data_0;
wire [7:0] data_1;

single_shot ss(
  .clk(clk_60kHz),
  .rst(sw0),
  .start(!key0),
  .q(pulse)
);

/*test i2c controller*/
i2c i2c(
  .clk(clk_60kHz),
  .start(i2c_start),
  .rst(sw0),
  .cmd_address(address),
  .data_0(data_0),
  .data_1(data_1),
  .sda(hdmi_i2c_sda),
  .scl(hdmi_i2c_scl),
  .busy(i2c_busy)
);

/*hdmi config queue controller*/
hdmi_config_queue hdmi_cq(
  .clk(clk_60kHz),
  .rst(sw0),
  .start(pulse),
  .i2c_busy(i2c_busy),
  .address(address),
  .data_0(data_0),
  .data_1(data_1),
  .i2c_start(i2c_start)
);

/*hdmi output signal generator*/
hdmi_signal hdmi_s(
  .clk(clk_hdmi),
  .rst(sw0),

  .data(hdmi_tx_d),
  .h_sync(hdmi_tx_hs),
  .v_sync(hdmi_tx_vs),
  .clk_out(hdmi_tx_clk),
  .data_en(hdmi_tx_de)
);

/*general debug*/
assign gpio_02 = clk_60kHz;
assign gpio_03 = 1'b0;
assign gpio_04 = 1'b0;

/*for debugging the i2c signals*/
assign gpio_00 = hdmi_i2c_sda;
assign gpio_01 = hdmi_i2c_scl;
/*
assign gpio_00 = w_hdmi_i2c_sda;
assign gpio_01 = w_hdmi_i2c_scl;
*/

endmodule
