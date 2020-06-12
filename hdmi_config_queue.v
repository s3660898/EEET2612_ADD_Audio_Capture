module hdmi_config_queue(

  /*control inputs*/
  input clk,
  input rst,

  /*functional inputs*/
  input start,
  input i2c_busy,

  /*data outputs for i2c*/
  output [6:0] address,
  output [7:0] data_0,
  output [7:0] data_1,

  /*functional output*/
  output i2c_start

);

parameter INSTRUCTION_COUNT = 31;

/*command queue, instructions*/
reg [7:0] inst [INSTRUCTION_COUNT-1:0][1:0]; /*30 setup instructions x 2 (data_0, data_1)*/
reg [5:0] r_inst_count;

/*output registers*/
reg [7:0] r_data_0;
reg [7:0] r_data_1;
reg       r_i2c_start;

/*firing control registers*/
reg r_started;
reg r_internal_busy;

always @(posedge(clk))
begin

  /*reset behaviour*/
  if(rst)
  begin
    r_i2c_start = 0;
    r_started  = 0;
    r_inst_count = 5'b0;
    r_internal_busy = 0;
    r_data_0 = 8'b0;
    r_data_1 = 8'b0;

    inst[ 0][0] = 8'h98; inst[ 0][1] = 8'h03;  /*must be set to 0x03*/
    inst[ 1][0] = 8'h01; inst[ 1][1] = 8'h00;  /*set n to 6144*/
    inst[ 2][0] = 8'h02; inst[ 2][1] = 8'h18;  /*set n to 6144*/
    inst[ 3][0] = 8'h03; inst[ 3][1] = 8'h00;  /*set n to 6144*/
    inst[ 4][0] = 8'h14; inst[ 4][1] = 8'h70;  /*ch count in the channel stat to 8*/
    inst[ 5][0] = 8'h15; inst[ 5][1] = 8'h20;  /*input 444 with separate syncs, 48khz fs*/
    inst[ 6][0] = 8'h16; inst[ 6][1] = 8'h30;  /*output format 444, 24-bit input*/
    inst[ 7][0] = 8'h18; inst[ 7][1] = 8'h46;  /*disable csc*/
    inst[ 8][0] = 8'h40; inst[ 8][1] = 8'h80;  /*general control packet enable*/
    inst[ 9][0] = 8'h41; inst[ 9][1] = 8'h10;  /*power down control*/
    inst[10][0] = 8'h49; inst[10][1] = 8'ha8;  /*set dither mode 12-10 bit*/
    inst[11][0] = 8'h55; inst[11][1] = 8'h10;  /*set rgb in avi infoframe*/
    inst[12][0] = 8'h56; inst[12][1] = 8'h08;  /*set active format aspect*/
    inst[13][0] = 8'h96; inst[13][1] = 8'hf6;  /*set interrupt*/
    inst[14][0] = 8'h73; inst[14][1] = 8'h07;  /*info frame ch count to 8*/
    inst[15][0] = 8'h76; inst[15][1] = 8'h1f;  /*set speaker allocation for 8 channels*/
    inst[16][0] = 8'h98; inst[16][1] = 8'h03;  /*must be set to 0x03 for proper operation*/
    inst[17][0] = 8'h99; inst[17][1] = 8'h02;  /*must be set to default value*/
    inst[18][0] = 8'h9a; inst[18][1] = 8'he0;  /*must be set to 0b1110000*/
    inst[19][0] = 8'h9c; inst[19][1] = 8'h30;  /*pll filter r1 value*/
    inst[20][0] = 8'h9d; inst[20][1] = 8'h61;  /*set clock divide*/
    inst[21][0] = 8'ha2; inst[21][1] = 8'ha4;  /*must be set to 0xa4 for proper operation*/
    inst[22][0] = 8'ha3; inst[22][1] = 8'ha4;  /*must be set to 0xa4 for proper operation*/
    inst[23][0] = 8'ha5; inst[23][1] = 8'h04;  /*must be set to default value*/
    inst[24][0] = 8'hab; inst[24][1] = 8'h40;  /*must be set to default value*/
    inst[25][0] = 8'haf; inst[25][1] = 8'h16;  /*select hdmi mode*/
    inst[26][0] = 8'hba; inst[26][1] = 8'h60;  /*no clock delay*/
    inst[27][0] = 8'hd1; inst[27][1] = 8'hff;  /*must be set to default value*/
    inst[28][0] = 8'hde; inst[28][1] = 8'h10;  /*must be set to default for proper operation*/
    inst[29][0] = 8'he4; inst[29][1] = 8'h60;  /*must be set to default value*/
    inst[30][0] = 8'hfa; inst[30][1] = 8'h7d;  /*nbr of times to look for good phase*/

  end
  else
  begin

    /*start condition*/
    if(r_started == 0 && start)
    begin
      r_started = 1;
      r_inst_count = 0;
    end

    /*i2c start command only for one clk cycle*/
    if(r_i2c_start)
      r_i2c_start = 0;

    /*running logic*/
    if(r_started)
    begin

      /*
      * if i2c not busy,
      *   update internal instruction registers
      *   tell i2c to send instructions
      *   increment instruction counter
      */
      if(!i2c_busy && !r_internal_busy)
      begin
        /*i2c_busy double shot bugfix*/
        r_internal_busy = 1;
        
        /*update internal instruction registers*/
        r_data_0 = inst[r_inst_count][0];
        r_data_1 = inst[r_inst_count][1];

        /*tell i2c to send instructions*/
        r_i2c_start = 1;

        /*increment  instruction counter*/
        if(r_inst_count + 1 == INSTRUCTION_COUNT)
        begin
          r_started = 0;
        end
        else
          r_inst_count = r_inst_count + 1'b1;
      end

      /*internal busy management, to fix i2c_busy double shot*/
      else if(r_internal_busy)
        r_internal_busy = 0;

    end
  end

end

assign address = 7'h39;
assign data_0  = r_data_0;
assign data_1  = r_data_1;
assign i2c_start = r_i2c_start;

endmodule
