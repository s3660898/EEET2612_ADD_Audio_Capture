module hdmi_signal(
  input clk,
  input rst,

  /*hdmi output*/
  output [23:0] data,
  output h_sync,
  output v_sync,
  output clk_out,
  output data_en

);

/*2 16x16 sprites*/
parameter NONE    = 23'h000000;
parameter RED     = 23'hb13425;
parameter YELLOW  = 23'he39d25;
parameter BROWN   = 23'h6a6b04;
reg [23:0] img[1:0][15:0][15:0];

/*1080p configuration settings*/
parameter V_TOTAL          = 12'd1125;
parameter V_FRONT_PORCH    = 12'd4;
parameter V_BACK_PORCH     = 12'd36;
parameter V_SYNC_DURATION  = 12'd5;

parameter H_TOTAL          = 12'd2200;
parameter H_FRONT_PORCH    = 12'd88;
parameter H_BACK_PORCH     = 12'd148;
parameter H_SYNC_DURATION  = 12'd44;

reg [11:0] r_h_count;
reg [11:0] r_v_count;

reg [23:0] r_data;
reg [7:0] r_r;
reg [7:0] r_g;
reg [7:0] r_b;

reg r_h_sync;
reg r_v_sync;
reg r_data_en;

reg [11:0] r_px_x;
reg [11:0] r_px_y;

always @(posedge(clk))
begin

  /*reset logic*/
  if(rst)
  begin
    r_h_count = 0;
    r_v_count = 0;
    r_h_sync = 0;
    r_v_sync = 0;
    r_data_en = 0;
    r_px_x = 0;
    r_px_y = 0;
    r_data = 0;

    /*sprites*/
    img[0][ 0][ 0] = NONE;
    img[0][ 0][ 1] = NONE;
    img[0][ 0][ 2] = NONE;
    img[0][ 0][ 3] = NONE;
    img[0][ 0][ 4] = NONE;
    img[0][ 0][ 5] = RED;
    img[0][ 0][ 6] = RED;
    img[0][ 0][ 7] = RED;
    img[0][ 0][ 8] = RED;
    img[0][ 0][ 9] = RED;
    img[0][ 0][10] = NONE;
    img[0][ 0][11] = NONE;
    img[0][ 0][12] = NONE;
    img[0][ 0][13] = NONE;
    img[0][ 0][14] = NONE;
    img[0][ 0][15] = NONE;

    img[0][ 1][ 0] = NONE;
    img[0][ 1][ 1] = NONE;
    img[0][ 1][ 2] = NONE;
    img[0][ 1][ 3] = NONE;
    img[0][ 1][ 4] = RED;
    img[0][ 1][ 5] = RED;
    img[0][ 1][ 6] = RED;
    img[0][ 1][ 7] = RED;
    img[0][ 1][ 8] = RED;
    img[0][ 1][ 9] = RED;
    img[0][ 1][10] = RED;
    img[0][ 1][11] = RED;
    img[0][ 1][12] = RED;
    img[0][ 1][13] = NONE;
    img[0][ 1][14] = NONE;
    img[0][ 1][15] = NONE;

    img[0][ 2][ 0] = NONE;
    img[0][ 2][ 1] = NONE;
    img[0][ 2][ 2] = NONE;
    img[0][ 2][ 3] = NONE;
    img[0][ 2][ 4] = BROWN;
    img[0][ 2][ 5] = BROWN;
    img[0][ 2][ 6] = BROWN;
    img[0][ 2][ 7] = YELLOW;
    img[0][ 2][ 8] = YELLOW;
    img[0][ 2][ 9] = BROWN;
    img[0][ 2][10] = YELLOW;
    img[0][ 2][11] = NONE;
    img[0][ 2][12] = NONE;
    img[0][ 2][13] = NONE;
    img[0][ 2][14] = NONE;
    img[0][ 2][15] = NONE;

    img[0][ 3][ 0] = NONE;
    img[0][ 3][ 1] = NONE;
    img[0][ 3][ 2] = NONE;
    img[0][ 3][ 3] = BROWN;
    img[0][ 3][ 4] = YELLOW;
    img[0][ 3][ 5] = BROWN;
    img[0][ 3][ 6] = YELLOW;
    img[0][ 3][ 7] = YELLOW;
    img[0][ 3][ 8] = YELLOW;
    img[0][ 3][ 9] = BROWN;
    img[0][ 3][10] = YELLOW;
    img[0][ 3][11] = YELLOW;
    img[0][ 3][12] = YELLOW;
    img[0][ 3][13] = NONE;
    img[0][ 3][14] = NONE;
    img[0][ 3][15] = NONE;

    img[0][ 4][ 0] = NONE;
    img[0][ 4][ 1] = NONE;
    img[0][ 4][ 2] = NONE;
    img[0][ 4][ 3] = BROWN;
    img[0][ 4][ 4] = YELLOW;
    img[0][ 4][ 5] = BROWN;
    img[0][ 4][ 6] = BROWN;
    img[0][ 4][ 7] = YELLOW;
    img[0][ 4][ 8] = YELLOW;
    img[0][ 4][ 9] = YELLOW;
    img[0][ 4][10] = BROWN;
    img[0][ 4][11] = YELLOW;
    img[0][ 4][12] = YELLOW;
    img[0][ 4][13] = YELLOW;
    img[0][ 4][14] = NONE;
    img[0][ 4][15] = NONE;

    img[0][ 5][ 0] = NONE;
    img[0][ 5][ 1] = NONE;
    img[0][ 5][ 2] = NONE;
    img[0][ 5][ 3] = BROWN;
    img[0][ 5][ 4] = BROWN;
    img[0][ 5][ 5] = YELLOW;
    img[0][ 5][ 6] = YELLOW;
    img[0][ 5][ 7] = YELLOW;
    img[0][ 5][ 8] = YELLOW;
    img[0][ 5][ 9] = BROWN;
    img[0][ 5][10] = BROWN;
    img[0][ 5][11] = BROWN;
    img[0][ 5][12] = BROWN;
    img[0][ 5][13] = NONE;
    img[0][ 5][14] = NONE;
    img[0][ 5][15] = NONE;

    img[0][ 6][ 0] = NONE;
    img[0][ 6][ 1] = NONE;
    img[0][ 6][ 2] = NONE;
    img[0][ 6][ 3] = NONE;
    img[0][ 6][ 4] = NONE;
    img[0][ 6][ 5] = YELLOW;
    img[0][ 6][ 6] = YELLOW;
    img[0][ 6][ 7] = YELLOW;
    img[0][ 6][ 8] = YELLOW;
    img[0][ 6][ 9] = YELLOW;
    img[0][ 6][10] = YELLOW;
    img[0][ 6][11] = YELLOW;
    img[0][ 6][12] = NONE;
    img[0][ 6][13] = NONE;
    img[0][ 6][14] = NONE;
    img[0][ 6][15] = NONE;

    img[0][ 7][ 0] = NONE;
    img[0][ 7][ 1] = NONE;
    img[0][ 7][ 2] = NONE;
    img[0][ 7][ 3] = NONE;
    img[0][ 7][ 4] = BROWN;
    img[0][ 7][ 5] = BROWN;
    img[0][ 7][ 6] = RED;
    img[0][ 7][ 7] = BROWN;
    img[0][ 7][ 8] = BROWN;
    img[0][ 7][ 9] = BROWN;
    img[0][ 7][10] = NONE;
    img[0][ 7][11] = NONE;
    img[0][ 7][12] = NONE;
    img[0][ 7][13] = NONE;
    img[0][ 7][14] = NONE;
    img[0][ 7][15] = NONE;

    img[0][ 8][ 0] = NONE;
    img[0][ 8][ 1] = NONE;
    img[0][ 8][ 2] = NONE;
    img[0][ 8][ 3] = BROWN;
    img[0][ 8][ 4] = BROWN;
    img[0][ 8][ 5] = BROWN;
    img[0][ 8][ 6] = RED;
    img[0][ 8][ 7] = RED;
    img[0][ 8][ 8] = RED;
    img[0][ 8][ 9] = RED;
    img[0][ 8][10] = BROWN;
    img[0][ 8][11] = BROWN;
    img[0][ 8][12] = BROWN;
    img[0][ 8][13] = NONE;
    img[0][ 8][14] = NONE;
    img[0][ 8][15] = NONE;

    img[0][ 9][ 0] = NONE;
    img[0][ 9][ 1] = NONE;
    img[0][ 9][ 2] = BROWN;
    img[0][ 9][ 3] = BROWN;
    img[0][ 9][ 4] = BROWN;
    img[0][ 9][ 5] = BROWN;
    img[0][ 9][ 6] = RED;
    img[0][ 9][ 7] = RED;
    img[0][ 9][ 8] = RED;
    img[0][ 9][ 9] = RED;
    img[0][ 9][10] = BROWN;
    img[0][ 9][11] = BROWN;
    img[0][ 9][12] = BROWN;
    img[0][ 9][13] = BROWN;
    img[0][ 9][14] = NONE;
    img[0][ 9][15] = NONE;

    img[0][10][ 0] = NONE;
    img[0][10][ 1] = NONE;
    img[0][10][ 2] = YELLOW;
    img[0][10][ 3] = YELLOW;
    img[0][10][ 4] = BROWN;
    img[0][10][ 5] = RED;
    img[0][10][ 6] = YELLOW;
    img[0][10][ 7] = RED;
    img[0][10][ 8] = RED;
    img[0][10][ 9] = YELLOW;
    img[0][10][10] = RED;
    img[0][10][11] = BROWN;
    img[0][10][12] = YELLOW;
    img[0][10][13] = YELLOW;
    img[0][10][14] = NONE;
    img[0][10][15] = NONE;

    img[0][11][ 0] = NONE;
    img[0][11][ 1] = NONE;
    img[0][11][ 2] = YELLOW;
    img[0][11][ 3] = YELLOW;
    img[0][11][ 4] = YELLOW;
    img[0][11][ 5] = RED;
    img[0][11][ 6] = RED;
    img[0][11][ 7] = RED;
    img[0][11][ 8] = RED;
    img[0][11][ 9] = RED;
    img[0][11][10] = RED;
    img[0][11][11] = YELLOW;
    img[0][11][12] = YELLOW;
    img[0][11][13] = YELLOW;
    img[0][11][14] = NONE;
    img[0][11][15] = NONE;

    img[0][12][ 0] = NONE;
    img[0][12][ 1] = NONE;
    img[0][12][ 2] = YELLOW;
    img[0][12][ 3] = YELLOW;
    img[0][12][ 4] = RED;
    img[0][12][ 5] = RED;
    img[0][12][ 6] = RED;
    img[0][12][ 7] = RED;
    img[0][12][ 8] = RED;
    img[0][12][ 9] = RED;
    img[0][12][10] = RED;
    img[0][12][11] = RED;
    img[0][12][12] = YELLOW;
    img[0][12][13] = YELLOW;
    img[0][12][14] = NONE;
    img[0][12][15] = NONE;

    img[0][13][ 0] = NONE;
    img[0][13][ 1] = NONE;
    img[0][13][ 2] = NONE;
    img[0][13][ 3] = NONE;
    img[0][13][ 4] = RED;
    img[0][13][ 5] = RED;
    img[0][13][ 6] = RED;
    img[0][13][ 7] = NONE;
    img[0][13][ 8] = NONE;
    img[0][13][ 9] = RED;
    img[0][13][10] = RED;
    img[0][13][11] = RED;
    img[0][13][12] = NONE;
    img[0][13][13] = NONE;
    img[0][13][14] = NONE;
    img[0][13][15] = NONE;

    img[0][14][ 0] = NONE;
    img[0][14][ 1] = NONE;
    img[0][14][ 2] = NONE;
    img[0][14][ 3] = BROWN;
    img[0][14][ 4] = BROWN;
    img[0][14][ 5] = BROWN;
    img[0][14][ 6] = NONE;
    img[0][14][ 7] = NONE;
    img[0][14][ 8] = NONE;
    img[0][14][ 9] = NONE;
    img[0][14][10] = BROWN;
    img[0][14][11] = BROWN;
    img[0][14][12] = BROWN;
    img[0][14][13] = NONE;
    img[0][14][14] = NONE;
    img[0][14][15] = NONE;

    img[0][15][ 0] = NONE;
    img[0][15][ 1] = NONE;
    img[0][15][ 2] = BROWN;
    img[0][15][ 3] = BROWN;
    img[0][15][ 4] = BROWN;
    img[0][15][ 5] = BROWN;
    img[0][15][ 6] = NONE;
    img[0][15][ 7] = NONE;
    img[0][15][ 8] = NONE;
    img[0][15][ 9] = NONE;
    img[0][15][10] = BROWN;
    img[0][15][11] = BROWN;
    img[0][15][12] = BROWN;
    img[0][15][13] = BROWN;
    img[0][15][14] = NONE;
    img[0][15][15] = NONE;

    /*sprite 1*/
    img[1][ 0][ 0] = NONE;
    img[1][ 0][ 1] = NONE;
    img[1][ 0][ 2] = NONE;
    img[1][ 0][ 3] = NONE;
    img[1][ 0][ 4] = NONE;
    img[1][ 0][ 5] = NONE;
    img[1][ 0][ 6] = NONE;
    img[1][ 0][ 7] = NONE;
    img[1][ 0][ 8] = NONE;
    img[1][ 0][ 9] = NONE;
    img[1][ 0][10] = NONE;
    img[1][ 0][11] = NONE;
    img[1][ 0][12] = NONE;
    img[1][ 0][13] = NONE;
    img[1][ 0][14] = NONE;
    img[1][ 0][15] = NONE;

    img[1][ 1][ 0] = NONE;
    img[1][ 1][ 1] = NONE;
    img[1][ 1][ 2] = NONE;
    img[1][ 1][ 3] = NONE;
    img[1][ 1][ 4] = NONE;
    img[1][ 1][ 5] = RED;
    img[1][ 1][ 6] = RED;
    img[1][ 1][ 7] = RED;
    img[1][ 1][ 8] = RED;
    img[1][ 1][ 9] = RED;
    img[1][ 1][10] = NONE;
    img[1][ 1][11] = NONE;
    img[1][ 1][12] = NONE;
    img[1][ 1][13] = NONE;
    img[1][ 1][14] = NONE;
    img[1][ 1][15] = NONE;

    img[1][ 2][ 0] = NONE;
    img[1][ 2][ 1] = NONE;
    img[1][ 2][ 2] = NONE;
    img[1][ 2][ 3] = NONE;
    img[1][ 2][ 4] = RED;
    img[1][ 2][ 5] = RED;
    img[1][ 2][ 6] = RED;
    img[1][ 2][ 7] = RED;
    img[1][ 2][ 8] = RED;
    img[1][ 2][ 9] = RED;
    img[1][ 2][10] = RED;
    img[1][ 2][11] = RED;
    img[1][ 2][12] = RED;
    img[1][ 2][13] = NONE;
    img[1][ 2][14] = NONE;
    img[1][ 2][15] = NONE;

    img[1][ 3][ 0] = NONE;
    img[1][ 3][ 1] = NONE;
    img[1][ 3][ 2] = NONE;
    img[1][ 3][ 3] = NONE;
    img[1][ 3][ 4] = BROWN;
    img[1][ 3][ 5] = BROWN;
    img[1][ 3][ 6] = BROWN;
    img[1][ 3][ 7] = YELLOW;
    img[1][ 3][ 8] = YELLOW;
    img[1][ 3][ 9] = BROWN;
    img[1][ 3][10] = YELLOW;
    img[1][ 3][11] = NONE;
    img[1][ 3][12] = NONE;
    img[1][ 3][13] = NONE;
    img[1][ 3][14] = NONE;
    img[1][ 3][15] = NONE;

    img[1][ 4][ 0] = NONE;
    img[1][ 4][ 1] = NONE;
    img[1][ 4][ 2] = NONE;
    img[1][ 4][ 3] = NONE;
    img[1][ 4][ 4] = BROWN;
    img[1][ 4][ 5] = BROWN;
    img[1][ 4][ 6] = BROWN;
    img[1][ 4][ 7] = YELLOW;
    img[1][ 4][ 8] = YELLOW;
    img[1][ 4][ 9] = BROWN;
    img[1][ 4][10] = YELLOW;
    img[1][ 4][11] = NONE;
    img[1][ 4][12] = NONE;
    img[1][ 4][13] = NONE;
    img[1][ 4][14] = NONE;
    img[1][ 4][15] = NONE;

    img[1][ 5][ 0] = NONE;
    img[1][ 5][ 1] = NONE;
    img[1][ 5][ 2] = NONE;
    img[1][ 5][ 3] = BROWN;
    img[1][ 5][ 4] = YELLOW;
    img[1][ 5][ 5] = BROWN;
    img[1][ 5][ 6] = BROWN;
    img[1][ 5][ 7] = YELLOW;
    img[1][ 5][ 8] = YELLOW;
    img[1][ 5][ 9] = YELLOW;
    img[1][ 5][10] = BROWN;
    img[1][ 5][11] = YELLOW;
    img[1][ 5][12] = YELLOW;
    img[1][ 5][13] = YELLOW;
    img[1][ 5][14] = NONE;
    img[1][ 5][15] = NONE;

    img[1][ 6][ 0] = NONE;
    img[1][ 6][ 1] = NONE;
    img[1][ 6][ 2] = NONE;
    img[1][ 6][ 3] = BROWN;
    img[1][ 6][ 4] = BROWN;
    img[1][ 6][ 5] = YELLOW;
    img[1][ 6][ 6] = YELLOW;
    img[1][ 6][ 7] = YELLOW;
    img[1][ 6][ 8] = YELLOW;
    img[1][ 6][ 9] = BROWN;
    img[1][ 6][10] = BROWN;
    img[1][ 6][11] = BROWN;
    img[1][ 6][12] = BROWN;
    img[1][ 6][13] = NONE;
    img[1][ 6][14] = NONE;
    img[1][ 6][15] = NONE;

    img[1][ 7][ 0] = NONE;
    img[1][ 7][ 1] = NONE;
    img[1][ 7][ 2] = NONE;
    img[1][ 7][ 3] = NONE;
    img[1][ 7][ 4] = NONE;
    img[1][ 7][ 5] = YELLOW;
    img[1][ 7][ 6] = YELLOW;
    img[1][ 7][ 7] = YELLOW;
    img[1][ 7][ 8] = YELLOW;
    img[1][ 7][ 9] = YELLOW;
    img[1][ 7][10] = YELLOW;
    img[1][ 7][11] = YELLOW;
    img[1][ 7][12] = NONE;
    img[1][ 7][13] = NONE;
    img[1][ 7][14] = NONE;
    img[1][ 7][15] = NONE;

    img[1][ 8][ 0] = NONE;
    img[1][ 8][ 1] = NONE;
    img[1][ 8][ 2] = NONE;
    img[1][ 8][ 3] = NONE;
    img[1][ 8][ 4] = BROWN;
    img[1][ 8][ 5] = BROWN;
    img[1][ 8][ 6] = BROWN;
    img[1][ 8][ 7] = BROWN;
    img[1][ 8][ 8] = RED;
    img[1][ 8][ 9] = BROWN;
    img[1][ 8][10] = NONE;
    img[1][ 8][11] = YELLOW;
    img[1][ 8][12] = NONE;
    img[1][ 8][13] = NONE;
    img[1][ 8][14] = NONE;
    img[1][ 8][15] = NONE;

    img[1][ 9][ 0] = NONE;
    img[1][ 9][ 1] = NONE;
    img[1][ 9][ 2] = NONE;
    img[1][ 9][ 3] = YELLOW;
    img[1][ 9][ 4] = BROWN;
    img[1][ 9][ 5] = BROWN;
    img[1][ 9][ 6] = BROWN;
    img[1][ 9][ 7] = BROWN;
    img[1][ 9][ 8] = BROWN;
    img[1][ 9][ 9] = BROWN;
    img[1][ 9][10] = YELLOW;
    img[1][ 9][11] = YELLOW;
    img[1][ 9][12] = YELLOW;
    img[1][ 9][13] = NONE;
    img[1][ 9][14] = NONE;
    img[1][ 9][15] = NONE;

    img[1][10][ 0] = NONE;
    img[1][10][ 1] = NONE;
    img[1][10][ 2] = YELLOW;
    img[1][10][ 3] = YELLOW;
    img[1][10][ 4] = RED;
    img[1][10][ 5] = BROWN;
    img[1][10][ 6] = BROWN;
    img[1][10][ 7] = BROWN;
    img[1][10][ 8] = BROWN;
    img[1][10][ 9] = BROWN;
    img[1][10][10] = YELLOW;
    img[1][10][11] = YELLOW;
    img[1][10][12] = NONE;
    img[1][10][13] = NONE;
    img[1][10][14] = NONE;
    img[1][10][15] = NONE;

    img[1][11][ 0] = NONE;
    img[1][11][ 1] = NONE;
    img[1][11][ 2] = BROWN;
    img[1][11][ 3] = BROWN;
    img[1][11][ 4] = RED;
    img[1][11][ 5] = RED;
    img[1][11][ 6] = RED;
    img[1][11][ 7] = RED;
    img[1][11][ 8] = RED;
    img[1][11][ 9] = RED;
    img[1][11][10] = RED;
    img[1][11][11] = NONE;
    img[1][11][12] = NONE;
    img[1][11][13] = NONE;
    img[1][11][14] = NONE;
    img[1][11][15] = NONE;

    img[1][12][ 0] = NONE;
    img[1][12][ 1] = NONE;
    img[1][12][ 2] = BROWN;
    img[1][12][ 3] = RED;
    img[1][12][ 4] = RED;
    img[1][12][ 5] = RED;
    img[1][12][ 6] = RED;
    img[1][12][ 7] = RED;
    img[1][12][ 8] = RED;
    img[1][12][ 9] = RED;
    img[1][12][10] = RED;
    img[1][12][11] = NONE;
    img[1][12][12] = NONE;
    img[1][12][13] = NONE;
    img[1][12][14] = NONE;
    img[1][12][15] = NONE;

    img[1][13][ 0] = NONE;
    img[1][13][ 1] = BROWN;
    img[1][13][ 2] = BROWN;
    img[1][13][ 3] = RED;
    img[1][13][ 4] = RED;
    img[1][13][ 5] = RED;
    img[1][13][ 6] = NONE;
    img[1][13][ 7] = RED;
    img[1][13][ 8] = RED;
    img[1][13][ 9] = RED;
    img[1][13][10] = NONE;
    img[1][13][11] = NONE;
    img[1][13][12] = NONE;
    img[1][13][13] = NONE;
    img[1][13][14] = NONE;
    img[1][13][15] = NONE;

    img[1][14][ 0] = NONE;
    img[1][14][ 1] = BROWN;
    img[1][14][ 2] = NONE;
    img[1][14][ 3] = NONE;
    img[1][14][ 4] = NONE;
    img[1][14][ 5] = NONE;
    img[1][14][ 6] = BROWN;
    img[1][14][ 7] = BROWN;
    img[1][14][ 8] = BROWN;
    img[1][14][ 9] = NONE;
    img[1][14][10] = NONE;
    img[1][14][11] = NONE;
    img[1][14][12] = NONE;
    img[1][14][13] = NONE;
    img[1][14][14] = NONE;
    img[1][14][15] = NONE;

    img[1][15][ 0] = NONE;
    img[1][15][ 1] = NONE;
    img[1][15][ 2] = NONE;
    img[1][15][ 3] = NONE;
    img[1][15][ 4] = NONE;
    img[1][15][ 5] = NONE;
    img[1][15][ 6] = BROWN;
    img[1][15][ 7] = BROWN;
    img[1][15][ 8] = BROWN;
    img[1][15][ 9] = BROWN;
    img[1][15][10] = NONE;
    img[1][15][11] = NONE;
    img[1][15][12] = NONE;
    img[1][15][13] = NONE;
    img[1][15][14] = NONE;
    img[1][15][15] = NONE;

  end

  /*running logic*/
  else
  begin

    if(r_data_en)
    begin
      /*x and y pixel coordinates*/
      r_px_x = r_h_count - (H_SYNC_DURATION + H_BACK_PORCH);
      r_px_y = r_v_count - (V_SYNC_DURATION + V_BACK_PORCH);

      /*img with 4x scale*/
      r_r = img[1][r_px_y>>2][r_px_x>>2][23:16];
      r_g = img[1][r_px_y>>2][r_px_x>>2][15: 8];
      r_b = img[1][r_px_y>>2][r_px_x>>2][ 7: 0];

      r_data[23:16] = r_r;
      r_data[15: 8] = r_g;
      r_data[ 7: 0] = r_b;
    end


    /*updating h & v sync, data enable*/
    r_h_sync = (r_h_count < H_SYNC_DURATION);
    r_data_en = (
                  (r_v_count >= V_SYNC_DURATION + V_BACK_PORCH) &&
                  (r_v_count <= V_TOTAL - V_FRONT_PORCH - 1)    &&
                  (r_h_count >= H_SYNC_DURATION + H_BACK_PORCH) &&
                  (r_h_count <= H_TOTAL - H_FRONT_PORCH - 1)
                );
    if(r_v_count == 0 && r_h_count == 0)
      r_v_sync = 1'b1;
    else if(r_v_count == V_SYNC_DURATION && r_h_count == 0)
      r_v_sync = 1'b0;

    /*horizontal counting*/
    if(r_h_count < H_TOTAL-1)
      r_h_count = r_h_count + 1'b1;
    else
      r_h_count = 0;

    /*vertical counting*/
    if(r_h_count == H_TOTAL-1)
    begin
      if(r_v_count < V_TOTAL-1)
        r_v_count = r_v_count + 1'b1;
      else
        r_v_count = 0;
    end
  end
end

assign clk_out = !clk;
/*
assign data = 24'b_0000_0000__0000_0000__1111_1111;
*/
assign data = r_data;
assign h_sync = r_h_sync;
assign v_sync = r_v_sync;
assign data_en = r_data_en;

endmodule
