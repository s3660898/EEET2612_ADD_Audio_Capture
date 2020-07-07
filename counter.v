module counter #(
  parameter MAX = 10,
  parameter MAX_BITWIDTH = 5
)(
  input clk,
  input rst,

  input increment,
  input decrement,

  output [MAX_BITWIDTH-1:0] count
);

/*internal registers*/
reg [MAX_BITWIDTH-1:0] r_count;

always @(posedge(clk))
begin
  if(rst)
  begin
    r_count = 0;
  end
  else
  begin
    if(increment)
      r_count = r_count + 1'b1;
    else if(decrement)
      r_count = r_count - 1'b1;
  end
end

assign count = r_count;

endmodule
