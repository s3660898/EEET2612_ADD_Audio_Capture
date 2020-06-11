/*actually 403.225... kHz*/
module clk_50MHz_250kHz(
  input clk_50MHz,
  output clk_250kHz
);

reg [7:0]r_count;
reg r_clk;

always @(posedge(clk_50MHz))
begin
  if(r_count == 99)
  begin
    r_count = 8'b0;
    r_clk = !r_clk;
  end
  else
    r_count = r_count + 1'b1;
end

assign clk_250kHz = r_clk;

endmodule
