/*responsible for determining the colour of a pixel based on its x/y location,
* and other factors*/
module hdmi_pixel_colour(
  input clk,
  input rst,

  input [11:0] px_y,
  input [11:0] px_x,
  input data_en,

  output [7:0] r,
  output [7:0] g,
  output [7:0] b
);

reg [7:0] r_r;
reg [7:0] r_g;
reg [7:0] r_b;

always @(posedge(clk))
begin
  if(rst)
  begin
    r_r = 0;
    r_g = 0;
    r_b = 0;
  end
  else
  begin
    if(data_en)
    begin
      /*TODO test pattern*/
      r_r = px_x;
      r_g = px_y;
      r_b = 8'd150;
    end
  end
end

assign r = r_r;
assign g = r_g;
assign b = r_b;

endmodule
