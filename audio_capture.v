module audio_capture(
  input clk_50MHz,
  input sw0,
  input key0,
  input key1,
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
  inout tri1 hdmi_i2c_scl,        /*hdmi config i2c scl*/

  /*adc related*/
  input  adc_sdo,
  output adc_convst,
  output adc_sck,
  output adc_sdi
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
  .start(!sw0),
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


/*key single shots*/
wire pulse_key0;
wire pulse_key1;
single_shot ss_key0(
  .clk(clk_50MHz),
  .rst(sw0),
  .start(!key0),
  .q(pulse_key0)
);

single_shot ss_key1(
  .clk(clk_50MHz),
  .rst(sw0),
  .start(!key1),
  .q(pulse_key1)
);

/*channel selection counter*/
wire [1:0] channel_selected;
counter #(
  .MAX(4),
  .MAX_BITWIDTH(2)
)channel_counter(
  .clk(clk_50MHz),
  .rst(sw0),
  .increment(pulse_key0),
  .decrement(pulse_key1),
  .count(channel_selected)
);

/*adc controller*/
wire w_adc_convst;
wire w_adc_sck;
wire w_adc_sdi;
wire w_adc_sdo;

wire [11:0] val;

adc_controller adc_c(
  .clk(clk_50MHz),
  .rst(sw0),

  .adc_conv(w_adc_convst),
  .adc_sck(w_adc_sck),
  .adc_sdi(w_adc_sdi),
  .adc_sdo(w_adc_sdo),

  .val(val)
);

assign w_adc_sdo = adc_sdo;
assign adc_convst = w_adc_convst;
assign adc_sdi = w_adc_sdi;
assign adc_sck = w_adc_sck;

/*hdmi presignal controller*/
wire hdmi_c_clk_out;
wire hdmi_c_h_sync;
wire hdmi_c_v_sync;
wire hdmi_c_data_en;
wire [11:0] hdmi_c_px_y;
wire [11:0] hdmi_c_px_x;

hdmi_control hdmi_c(
  .clk(clk_hdmi),
  .rst(sw0),

  .px_y(hdmi_c_px_y),
  .px_x(hdmi_c_px_x),
  .data_en(hdmi_c_data_en),

  .clk_out(hdmi_c_clk_out),
  .h_sync(hdmi_c_h_sync),
  .v_sync(hdmi_c_v_sync)
);

/*hdmi per-pixel colour controller*/
wire [7:0] hdmi_pc_r;
wire [7:0] hdmi_pc_g;
wire [7:0] hdmi_pc_b;

hdmi_pixel_colour hdmi_pc(
  .clk(hdmi_c_clk_out),
  .rst(sw0),

  .px_y(hdmi_c_px_y),
  .px_x(hdmi_c_px_x),
  .data_en(hdmi_c_data_en),

  .channel_select(channel_selected),
  .val(val),

  .r(hdmi_pc_r),
  .g(hdmi_pc_g),
  .b(hdmi_pc_b)
);

/*hdmi output signal generator*/
hdmi_signal hdmi_s(
  .clk(hdmi_c_clk_out),
  .rst(sw0),

  /*inputs*/
  .r(hdmi_pc_r),
  .g(hdmi_pc_g),
  .b(hdmi_pc_b),

  .in_h_sync(hdmi_c_h_sync),
  .in_v_sync(hdmi_c_v_sync),
  .in_data_en(hdmi_c_data_en),

  /*output*/
  .h_sync(hdmi_tx_hs),
  .v_sync(hdmi_tx_vs),
  .clk_out(hdmi_tx_clk),
  .data_en(hdmi_tx_de),
  .data(hdmi_tx_d)
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
