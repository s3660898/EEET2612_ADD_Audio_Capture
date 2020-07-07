module hdmi_control(
  input clk,
  input rst,

  /*pixel location and whether or not it is on screen*/
  output [11:0] px_x,
  output [11:0] px_y, 
  output data_en,

  /*would-be hdmi output for the next module*/
  output [23:0] data,
  output h_sync,
  output v_sync,
  output clk_out

);

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

    r_r = 0;
    r_g = 0;
    r_b = 0;
  end

  /*running logic*/
  else
  begin

    if(r_data_en)
    begin

      /*x and y pixel coordinates*/
      r_px_x = r_h_count - (H_SYNC_DURATION + H_BACK_PORCH);
      r_px_y = r_v_count - (V_SYNC_DURATION + V_BACK_PORCH);

      r_r = 100;
      r_g = 255;
      r_b = 250;

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

assign px_x = r_px_x;
assign px_y = r_px_y;

assign clk_out = !clk;
assign data = r_data;
assign h_sync = r_h_sync;
assign v_sync = r_v_sync;
assign data_en = r_data_en;

endmodule
