
/*i2c-esque module optimised for the HDMI phy*/
module i2c(
  input clk,
  input rst,

  /* command related */
  input [6:0] cmd_address,

  /* data for sending related */
  input [7:0] data_0,
  input [7:0] data_1,

  input start,

  /* i2c phy io related */
  inout tri1 scl,
  inout tri1 sda,

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
  STATE_START   = 3'd0, /*for the initial sda/scl pulling down*/
  STATE_ADDRESS = 3'd1, /*for sending the address, write*/
  STATE_DATA_0  = 3'd2, /*for sending the first data packet*/
  STATE_DATA_1  = 3'd3, /*for sending the second data packet*/
  STATE_END     = 3'd4; /*for the final sda/scl transition up*/

/*for keeping track of the current state*/
reg [2:0] r_state;

/*for counting the transitions in the 'start' state*/
reg [1:0] r_state_start_count;

/*for countig the transitions in the 'end' state*/
reg [2:0] r_state_end_count;

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

localparam [1:0]
  BIT_STATE_0 = 2'b00,
  BIT_STATE_1 = 2'b01,
  BIT_STATE_2 = 2'b10;

reg [1:0] r_bit_state;
reg [3:0] r_bit_count;

reg [8:0] r_address_qualified;
reg [8:0] r_data_qualified;

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
          r_address_qualified[8:2] = cmd_address[6:0]; /*address*/
          r_address_qualified[1]   = 0;                /*write*/
          r_address_qualified[0]   = 1;                /*ack*/
        end

        /* if not transitioning to address sending state*/
        else
        begin
          /*i2c start sda/scl transition behaviour*/
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
      end

      STATE_ADDRESS:
      begin

        /*next bit condition*/
        if(r_bit_state == 3)
        begin
          r_bit_state = BIT_STATE_0;
          r_bit_count = r_bit_count + 1;
        end

        /*next state exit condition, transition to data state*/
        if(r_bit_count == 9)
        begin
          r_state = STATE_DATA_0;
          r_bit_count = 0;
          r_data_qualified[8:1] = data_0[7:0]; /*data to be sent next*/
          r_data_qualified[0]   = 1;           /*pull up for ack*/
        end

        /*if not transitioning to data sending state*/
        else
        begin

          /*BIT STATE transition switching*/
          r_sda_pull = !r_address_qualified[8-r_bit_count];
          case(r_bit_state)
            BIT_STATE_0:  r_scl_pull = 1;
            BIT_STATE_1:  r_scl_pull = 0;
            BIT_STATE_2:  r_scl_pull = 1;
          endcase

          r_bit_state = r_bit_state + 1;
        end
      end

      STATE_DATA_0:
      begin
        /*next bit condition*/
        if(r_bit_state == 3)
        begin
          r_bit_state = BIT_STATE_0;
          r_bit_count = r_bit_count + 1;
        end

        /*next state exit condition, transition to data state*/
        if(r_bit_count == 9)
        begin
          r_state = STATE_DATA_1;
          r_bit_count = 0;
          r_data_qualified[8:1] = data_1[7:0]; /*data to be sent next*/
          r_data_qualified[0]   = 1;           /*pull up for ack*/
        end

        /*if not transitioning to data sending state*/
        else
        begin

          /*BIT STATE transition switching*/
          r_sda_pull = !r_data_qualified[8-r_bit_count];
          case(r_bit_state)
            BIT_STATE_0:  r_scl_pull = 1;
            BIT_STATE_1:  r_scl_pull = 0;
            BIT_STATE_2:  r_scl_pull = 1;
          endcase

          r_bit_state = r_bit_state + 1;
        end
      end

      STATE_DATA_1:
      begin
        /*next bit condition*/
        if(r_bit_state == 3)
        begin
          r_bit_state = BIT_STATE_0;
          r_bit_count = r_bit_count + 1;
        end

        /*next state exit condition, transition to data state*/
        if(r_bit_count == 9)
        begin
          r_state = STATE_END;
          r_bit_count = 0;
          r_state_end_count = 0;
          r_data_qualified[8:1] = data_1[7:0]; /*data to be sent next*/
          r_data_qualified[0]   = 1;           /*pull up for ack*/
        end

        /*if not transitioning to data sending state*/
        else
        begin

          /*BIT STATE transition switching*/
          r_sda_pull = !r_data_qualified[8-r_bit_count];
          case(r_bit_state)
            BIT_STATE_0:  r_scl_pull = 1;
            BIT_STATE_1:  r_scl_pull = 0;
            BIT_STATE_2:  r_scl_pull = 1;
          endcase

          r_bit_state = r_bit_state + 1;
        end
      end

      STATE_END:
      begin

        /*final exit transition*/
        if(r_state_end_count == 3)
        begin
          r_active = 0;
        end
        else
        begin

          case(r_state_end_count)
            0:
            begin
              r_sda_pull = 1;
              r_scl_pull = 1;
            end

            1:
            begin
              r_sda_pull = 1;
              r_scl_pull = 0;
            end

            2:
            begin
              r_sda_pull = 0;
              r_scl_pull = 0;
            end
          endcase

          r_state_end_count = r_state_end_count + 1;

        end
      end

    endcase
  end
end

assign sda = r_sda_pull ? 1'b0 : 1'bZ;
assign scl = r_scl_pull ? 1'b0 : 1'bZ;
assign busy = r_active;

endmodule
