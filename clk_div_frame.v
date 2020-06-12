/*50Mhz in, 2Hz out for frame select*/
module clk_div_frame(
  input rst,
  input clk_in,
  output clk_out
);

/*to allow for different values in testing*/
reg [15:0]r_count;
reg r_clk;

always @(posedge(clk_in))
begin
  if(rst)
  begin
    r_count = 0;
    r_clk = 1;
  end
  else
  begin

    if(r_count == 24'b1011_1110_1011_1100_0001_1111)
    begin
      r_count = 8'b0;
      r_clk = !r_clk;
    end
    else
      r_count = r_count + 1'b1;

  end
end

assign clk_out = r_clk;

endmodule
