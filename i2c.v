
/*i2c-esque module optimised for the HDMI phy*/
module i2c(
  input clk,
  input rst,

  /* command related */
  input [6:0] cmd_address,

  /* data output (sending) related */
  output [7:0] data_out,

  input start,

  /* i2c io related */
  tri1 scl,
  tri1 sda,

  /* status related */
  output busy
);

/*
*            A6  A5  A4  A3  A2  A1  A0 R/W ACK            D7  D6  D5  D4  D3  D2  D1  D0 ACK
*      _    ___ ___ ___ ___ ___ ___ ___ ___     ______    ___ ___ ___ ___ ___ ___ ___ ___ ___     _
* SDA:  \__/___X___X___X___X___X___x___X___\___/      \__/___X___X___X___X___X___X___X___X___\___/
*      __    _   _   _   _   _   _   _   _   _             _   _   _   _   _   _   _   _   _     __
* SCL:   \__/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \___________/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \___/
*
*/

reg r_sda_pull;  /*pulls sda down to 0*/
reg r_scl_pull;  /*pulls scl down to 0*/
reg [15:0]r_count;
reg r_active;

always @(posedge(clk))
begin

  /* reset behaviour*/
  if(rst)
  begin
    r_count = 0;
    r_active = 0;
    r_sda_pull = 0;
    r_scl_pull = 0;
  end

  /* start behaviour (can't start when active)*/
  if(start && !r_active)
  begin
    r_active = 1;
    r_count = 0;
  end

  /* state behaviour */
  if(r_active)
  begin
    case(r_count)
      0:
      begin
        r_sda_pull = 1;
        r_scl_pull = 0;
      end

      1:
      begin
        r_sda_pull = 1;
        r_scl_pull = 1;
      end

      2: 
      begin
        r_sda_pull = 1;
        r_scl_pull = 1;
      end

      3: 
      begin
        r_sda_pull = !cmd_address[6];
        r_scl_pull = 1;
      end

      4: 
      begin
        r_sda_pull = !cmd_address[6];
        r_scl_pull = 0;
      end

      5:
      begin
        r_sda_pull = !cmd_address[6];
        r_scl_pull = 0;
      end

      5:
      begin
        r_sda_pull = !cmd_address[6];
        r_scl_pull = 0;
      end
    endcase

    /*incrementation*/
    r_count = r_count + 1;

    /*exit condition*/
    if(r_count == 10)
    begin
      r_active = 0;
    end
  end
end

assign sda = r_sda_pull ? 1'b0 : 1'bZ;
assign scl = r_scl_pull ? 1'b0 : 1'bZ;

endmodule
