module counter_frame(
  input rst,
  input clk,
  output [1:0] frame_select
);

reg [1:0] r_count;

always @(posedge(clk))
begin
  if(rst)
  begin
    r_count = 0;
  end
  else
  begin
    if(r_count + 1 == 4)
      r_count = 0;
    else
      r_count = r_count + 1'b1;
  end
end

assign frame_select = r_count;

endmodule

