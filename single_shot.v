module single_shot(
  input clk,
  input rst,
  input start,
  output q
);

reg can_fire;
reg r_q;

always @(posedge(clk))
begin
  if(rst)
  begin
    can_fire = 0;
    r_q = 0;
  end
  else
  begin
    if(r_q ==1)
      r_q = 0;

    if(can_fire && start)
    begin
      r_q = 1;
      can_fire = 0;
    end

    if(!start)
      can_fire = 1;
  end
end

assign q = r_q;

endmodule
