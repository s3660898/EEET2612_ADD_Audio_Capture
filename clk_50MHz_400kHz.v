/*actually 403.225... kHz*/
module clk_50MHz_400kHz(
  input clk_50MHz,
  output clk_400kHz
);

reg [5:0]r_count;
reg r_clk;

always @(posedge(clk_50MHz))
begin
  if(r_count == 61)
  begin
    r_count = 6'b0;
    r_clk = !r_clk;
  end
  else
    r_count = r_count + 1;
end

assign clk_400kHz = r_clk;

endmodule
