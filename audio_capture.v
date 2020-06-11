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
  output gpio_04, /*gnd*/

  /*hdmi data output*/
  output [23:0] hdmi_tx_d,    /*data*/
  output        hdmi_tx_clk,  /*video clock*/
  output        hdmi_tx_de,   /*data enable*/
  output        hdmi_tx_hs,   /*hoizontal sync*/
  output        hdmi_tx_vs,   /*vertical sync*/

  /*hdmi control output*/
  output hdmi_i2c_sda,        /*hdmi config i2c sda*/
  output hdmi_i2c_scl         /*hdmi config i2c scl*/
);

wire clk_250kHz;

/*hdmi control internal wire*/
wire w_hdmi_i2c_scl,
     w_hdmi_i2c_sda;

/*clock divider*/
clk_50MHz_250kHz clk_50MHz_250kHz(
  .clk_50MHz(clk_50MHz),
  .clk_250kHz(clk_250kHz)
);

/*pulse for i2c debugging*/
wire pulse;
wire i2c_busy;
wire i2c_start;

wire [6:0] address;
wire [7:0] data_0;
wire [7:0] data_1;

single_shot ss(
  .clk(clk_250kHz),
  .rst(sw0),
  .start(!key0),
  .q(pulse)
);

/*test i2c controller*/
i2c i2c(
  .clk(clk_250kHz),
  .start(i2c_start),
  .rst(sw0),
  .cmd_address(address),
  .data_0(data_0),
  .data_1(data_1),
  .sda(w_hdmi_i2c_sda),
  .scl(w_hdmi_i2c_scl),
  .busy(i2c_busy)
);

/*hdmi config queue controller*/
hdmi_config_queue hdmi_cq(
  .clk(clk_250kHz),
  .rst(sw0),
  .start(pulse),
  .i2c_busy(i2c_busy),
  .address(address),
  .data_0(data_0),
  .data_1(data_1),
  .i2c_start(i2c_start)
);

/*general debug*/
assign gpio_02 = clk_250kHz;
assign gpio_03 = 1'b0;
assign gpio_04 = 1'b0;

/*for debugging the i2c signals*/
assign gpio_00 = w_hdmi_i2c_sda;
assign gpio_01 = w_hdmi_i2c_scl;

/*hdmi i2c config*/
/*
assign hdmi_i2c_sda = w_hdmi_i2c_sda;
assign hdmi_i2c_scl = w_hdmi_i2c_scl;
*/

endmodule
