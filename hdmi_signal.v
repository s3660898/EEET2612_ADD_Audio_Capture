module hdmi_signal(
  input clk,
  input rst,

  /*current pixel colour input*/
  input [7:0] r,
  input [7:0] g,
  input [7:0] b,

  /*input signals from hdmi control*/
  input in_h_sync,
  input in_v_sync,
  input in_data_en,

  /*would-be hdmi output for the next module*/
  output [23:0] data,
  output h_sync,
  output v_sync,
  output clk_out,
  output data_en

);

reg [23:0] r_data;
reg r_h_sync;
reg r_v_sync;
reg r_data_en;

always @(posedge(clk))
begin
  if(rst)
  begin
    r_data = 0;
    r_h_sync = 0;
    r_v_sync = 0;
    r_data_en = 0;
  end

  else
  begin
    /*assigning colours*/
    r_data[23:16] = r;
    r_data[15: 8] = g;
    r_data[ 7: 0] = b;

    /*buffering other input values for synchronisation*/
    r_data_en = in_data_en;
    r_h_sync = in_h_sync;
    r_v_sync = in_v_sync;
  end
end

assign data = r_data;
assign h_sync = r_h_sync;
assign v_sync = r_v_sync;
assign data_en = r_data_en;
assign clk_out = !clk;

endmodule
