module adc_controller(
  input  clk,
  input  rst,

  output adc_conv,
  output adc_sck,
  output adc_sdi,
  input  adc_sdo,

  output [11:0] val
);

/*
 *                __________________________________________________                                                            ________________
 * ADC_CONV:  ___/<- 1.6us, 80 clks at 50MHz ->|<- nap/sleep time ->\__________________________________________________________/
 *                                  20ns/tick      however long?                                                               |
 *                                                                                                                             |
 *                                                                     _   _   _   _   _   _   _   _   _   _   _   _           |
 *  ADC_SCK: _________________________________________________________/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \__________|________________
 *                                                                    1   2   3   4   5   6   7   8   9   10  11  12,  12 clocks at max 40MHz
 *                                                                                            |----------T_ACQ, min 240ns------|
 *                                                                   ___ ___ ___ ___ ___ ___                                   |
 *  ADC_SDI: _______________________________________________________/___X___X___X___X___X___\__________________________________|________________
 *                                                                  S/D O/S S1  S0  UNI SLP                                    |
 *                                                                   ___ ___ ___ ___ ___ ___ ___ ___ ___ ___ ___ ___           |
 *  ADC_SD0: ---(HIGH Z)--------------------------------------------X___X___X___X___X___X___X___X___X___X___X___X___\__________|----------------
 *                                                                  B11 B10 B9  B8  B7  B6  B5  B4  B3  B2  B1  B0
 *
 *
 */

reg r_conv;
reg r_sck;
reg r_sdi;

reg enabled;             /*whether the whole controller system is active*/
reg [6:0] conv_counter;  /*responsible for keeping CONV high for 1.6us*/
reg [3:0] sck_count;     /*the current clock number, 0-11*/
reg sck_state;           /*0-1, represeting the above states*/

reg [4:0] t_aco_count;   /*counting from the 7th clk for 240ns, 12 cycles*/

reg [11:0] val_temp;     /*for recording the values of sdo*/
reg [11:0] r_val;        /*holds the final sdo value transmitted*/

always @(posedge(clk))
begin
  if(rst)
  begin
    r_conv = 0;
    r_sck  = 0;
    r_sdi  = 0;

    enabled = 0;
    conv_counter = 0;
    sck_count = 0;
    sck_state = 1;
    t_aco_count = 0;

    val_temp = 0;
    r_val = 0;
  end
  else
  begin

    if(enabled)
    begin

      /*conv completed*/
      if(conv_counter == 80)
      begin

        if(sck_count < 12)
        begin
          /*toggle conv state*/
          sck_state = !sck_state;

          /*recording sdo*/
          val_temp[11-sck_count] = adc_sdo;

          /*setting output state*/
          r_conv = 0;
          r_sck = sck_state;

          /*incrementing the count when sck_state moves to high*/
          if(sck_state)
            sck_count = sck_count + 1'b1;
        end

        /*after the clocks*/
        else
        begin
          r_sck = 0;

          /*outputting the value retrieved from the adc_sdo serial*/
          r_val[11:0] = val_temp[11:0];

          if(t_aco_count < 12)
          begin
            /*incrementing count*/
            t_aco_count = t_aco_count + 1'b1;
          end

          /*clean up at final point*/
          else
          begin
            enabled = 0;
          end
        end
      end

      /*waiting for CONV time*/
      else
      begin
        conv_counter = conv_counter + 1'b1;

        /*output state*/
        r_conv = 1;
        r_sck  = 0;
        r_sdi  = 0;
      end
    end

    /*setup for a new run*/
    if(!enabled)
    begin
      conv_counter = 0;
      enabled = 1;
      t_aco_count = 0;
      sck_count = 0;
      sck_state = 1;
    end
  end
end

assign adc_conv = r_conv;
assign adc_sck  = r_sck;
assign adc_sdi  = r_sdi;

assign val = r_val;

endmodule
