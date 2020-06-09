
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
*   OVERVIEW OF I2C
*
*            A6 A5 A4 A3 A2 A1 A0 RW ACK          D7 D6 D5 D4 D3 D2 D1 D0 ACK
*        _   __ __ __ __ __ __ __ __ __ ______    __ __ __ __ __ __ __ __ __     _
*   SDA:  \_/__X__X__X__X__X__x__X__X__/      \__/__X__X__X__X__X__X__X__X__\___/
*        __                                                                     __
*   SCL:   \_/\_/\_/\_/\_/\_/\_/\_/\_/\___________/\_/\_/\_/\_/\_/\_/\_/\_/\___/
*
* STATE:|--||-------------------------||-------||---------------------------|       
*        START                                    CONT    DATA
*            ADDRESS
*/

reg r_sda_pull;  /*pulls sda down to 0*/
reg r_scl_pull;  /*pulls scl down to 0*/
reg r_active;

localparam [2:0]
  STATE_START   = 3'd0,
  STATE_ADDRESS = 3'd1,
  STATE_CONT    = 3'd2,
  STATE_DATA    = 3'd3,
  STATE_END     = 3'd4;

/*for keeping track of the current state*/
reg [1:0] r_state;

/*for counting the transitions in the 'start' state*/
reg [1:0] r_state_start_count;

/*       
*   BIT_STATE: the state within the current bit,
*              for changing SDA & SDL positions
*
*               |  __|____|____|  __|____|____
*               |\/  |    |    |\/  |    |
*         SDA:  |/\__|____|____|/\__|____|____
*               |    |  __|    |    |  __|
*               |    | /  |\   |    | /  |\
*         SCL:  |____|/   | \__|____|/   | \__
*
* BIT_STATE_X:   |--| |--| |--| |--| |--| |--|
*                0    1    2    0    1    etc
*/

reg [1:0] r_bit_state;
reg [3:0] r_bit_count;

localparam [1:0]
  BIT_STATE_0 = 2'b00,
  BIT_STATE_1 = 2'b01,
  BIT_STATE_2 = 2'b10;

always @(posedge(clk))
begin

  /* reset behaviour*/
  if(rst)
  begin
    r_active = 0;
    r_sda_pull = 0;
    r_scl_pull = 0;
  end

  /* start behaviour (can't start when active)*/
  if(start && !r_active)
  begin
    r_active = 1;
    r_state = 0;
    r_state_start_count = 0;
  end

  /* state behaviour */
  if(r_active)
  begin

    /* 'state' switching*/
    case(r_state)

      STATE_START:
      begin
        /*exit condition, transition to address state*/
        if(r_state_start_count == 2)
        begin
          r_state = STATE_ADDRESS;
          r_bit_count = 0;
          r_bit_state = 0;
        end

        /*transition behaviour*/
        case(r_state_start_count)
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
        endcase

        /*incrementation*/
        r_state_start_count = r_state_start_count + 1;
      end

      STATE_ADDRESS:
      begin

        /*next bit condition*/
        if(r_bit_state == 3)
        begin
          r_bit_state = BIT_STATE_0;
          r_bit_count = r_bit_count + 1;
        end

        /*aknowledgement behaviour*/
        if(r_bit_count == 7)
        begin
          r_sda_pull = 0;

          /*exit condition to next state*/
          if(r_bit_state == 3)
          begin
            r_state = STATE_DATA;
            r_bit_state = BIT_STATE_0;
            r_bit_count = 0;
          end

          /*clocking on the aknowledgement signal*/
          case(r_bit_state)
            BIT_STATE_0:  r_scl_pull = 1;
            BIT_STATE_1:  r_scl_pull = 0;
            BIT_STATE_2:  r_scl_pull = 1;
          endcase

          r_bit_state = r_bit_state + 1;
        end

        /*for bits 0-6*/
        else
        begin

          /*BIT STATE transition switching*/
          case(r_bit_state)
            BIT_STATE_0:
            begin
              r_sda_pull = !cmd_address[6-r_bit_count];
              r_scl_pull = 1;
            end

            BIT_STATE_1:
            begin
              r_sda_pull = !cmd_address[6-r_bit_count];
              r_scl_pull = 0;
            end

            BIT_STATE_2:
            begin
              r_sda_pull = !cmd_address[6-r_bit_count];
              r_scl_pull = 1;
            end
          endcase

          r_bit_state = r_bit_state + 1;
        end
      endcase
    end
  end
end

assign sda = r_sda_pull ? 1'b0 : 1'bZ;
assign scl = r_scl_pull ? 1'b0 : 1'bZ;

endmodule
