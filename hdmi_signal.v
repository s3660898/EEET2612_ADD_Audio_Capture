module hdmi_signal(
  input clk,
  input rst,
  
  /*hdmi output*/
  output [23:0] data,
  output h_sync,
  output v_sync,
  output clk_out

);

/*1080p configuration settings*/
parameter V_TOTAL        = 12'd1125;
parameter V_FRONT_PORCH  = 12'd4;
parameter V_BACK_PORCH   = 12'd36;
parameter V_SYNC         = 12'd5;

parameter H_TOTAL        = 12'd2200;
parameter H_FRONT_PORCH  = 12'd88;
parameter H_BACK_PORCH   = 12'd148;
parameter H_SYNC         = 12'd44;

reg [11:0] r_h_count;
reg [11:0] r_v_count;


reg r_h_sync;
reg r_v_sync;
reg r_data_en;

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
  end

  /*running logic*/
  else
  begin

    /*updating h & v sync, data enable*/
    r_h_sync = (r_h_count < H_SYNC);
    r_data_en = (
                  (r_v_count >= V_SYNC + V_BACK_PORCH)        &&
                  (r_v_count <= V_TOTAL - V_FRONT_PORCH - 1)  &&
                  (r_h_count >= V_SYNC + H_BACK_PORCH)        &&
                  (r_h_count <= H_TOTAL - H_FRONT_PORCH - 1)
                );
    if(r_v_count == 0 && r_h_count == 0)
      r_v_sync = 1'b1;
    else if(r_v_count == V_SYNC && r_h_count == 0)
      r_v_sync = 1'b0;

    /*horizontal counting*/
    if(r_h_count < H_TOTAL-1)
      r_h_count = r_h_count + 1;
    else
      r_h_count = 0;

    /*vertical counting*/
    if(r_h_count == H_TOTAL-1)
    begin
      if(r_v_count < V_TOTAL-1)
        r_v_count = r_v_count + 1;
      else
        r_v_count = 0;
    end
  end
end

assign clk_out = !clk;
assign data = 24'b_0000_0000__0000_0000__1111_1111;
assign h_sync = r_h_sync;
assign v_sync = r_v_sync;

endmodule
