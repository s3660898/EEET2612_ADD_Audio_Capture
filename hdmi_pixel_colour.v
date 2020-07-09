/*responsible for determining the colour of a pixel based on its x/y location,
* and other factors*/
module hdmi_pixel_colour(
  input clk,
  input rst,

  /*required, hdmi-related input*/
  input [11:0] px_y,
  input [11:0] px_x,
  input data_en,
  
  /*'custom' input*/
  input [1:0] channel_select,

  output [7:0] r,
  output [7:0] g,
  output [7:0] b
);

reg [7:0] r_r;
reg [7:0] r_g;
reg [7:0] r_b;

function text_is_white;
  input [11:0] px_y;
  input [11:0] px_x;
  input [1:0] num;

  reg is_white = 0;

  `define SCALE_FACTOR 2
  if((px_x>>`SCALE_FACTOR) < 8 && (px_y>>`SCALE_FACTOR) < 12)
  begin
    reg [11:0] px_x_text;
    reg [11:0] px_y_text;
    px_x_text = px_x>>`SCALE_FACTOR;
    px_y_text = px_y>>`SCALE_FACTOR;

    case(num)
      2'd0:
      /*channel number 1*/
      case({px_y_text[3:0], px_x_text[2:0]})
        {4'd1,3'd4}: is_white = 1'b1;
        {4'd2,3'd3}: is_white = 1'b1;
        {4'd2,3'd4}: is_white = 1'b1;
        {4'd3,3'd1}: is_white = 1'b1;
        {4'd3,3'd2}: is_white = 1'b1;
        {4'd3,3'd3}: is_white = 1'b1;
        {4'd3,3'd4}: is_white = 1'b1;
        {4'd4,3'd3}: is_white = 1'b1;
        {4'd4,3'd4}: is_white = 1'b1;
        {4'd5,3'd3}: is_white = 1'b1;
        {4'd5,3'd4}: is_white = 1'b1;
        {4'd6,3'd3}: is_white = 1'b1;
        {4'd6,3'd4}: is_white = 1'b1;
        {4'd7,3'd3}: is_white = 1'b1;
        {4'd7,3'd4}: is_white = 1'b1;
        {4'd8,3'd3}: is_white = 1'b1;
        {4'd8,3'd4}: is_white = 1'b1;
        {4'd9,3'd1}: is_white = 1'b1;
        {4'd9,3'd2}: is_white = 1'b1;
        {4'd9,3'd3}: is_white = 1'b1;
        {4'd9,3'd4}: is_white = 1'b1;
        {4'd9,3'd5}: is_white = 1'b1;
        {4'd9,3'd6}: is_white = 1'b1;
      endcase

      /*channel number 2*/
      2'd1:
      case({px_y_text[3:0], px_x_text[2:0]})
        {4'd1,3'd2}: is_white = 1'b1;
        {4'd1,3'd3}: is_white = 1'b1;
        {4'd1,3'd4}: is_white = 1'b1;
        {4'd1,3'd5}: is_white = 1'b1;
        {4'd2,3'd1}: is_white = 1'b1;
        {4'd2,3'd2}: is_white = 1'b1;
        {4'd2,3'd5}: is_white = 1'b1;
        {4'd2,3'd6}: is_white = 1'b1;
        {4'd3,3'd1}: is_white = 1'b1;
        {4'd3,3'd2}: is_white = 1'b1;
        {4'd3,3'd5}: is_white = 1'b1;
        {4'd3,3'd6}: is_white = 1'b1;
        {4'd4,3'd5}: is_white = 1'b1;
        {4'd4,3'd6}: is_white = 1'b1;
        {4'd5,3'd4}: is_white = 1'b1;
        {4'd5,3'd5}: is_white = 1'b1;
        {4'd6,3'd3}: is_white = 1'b1;
        {4'd6,3'd4}: is_white = 1'b1;
        {4'd7,3'd2}: is_white = 1'b1;
        {4'd7,3'd3}: is_white = 1'b1;
        {4'd8,3'd1}: is_white = 1'b1;
        {4'd8,3'd2}: is_white = 1'b1;
        {4'd8,3'd5}: is_white = 1'b1;
        {4'd8,3'd6}: is_white = 1'b1;
        {4'd9,3'd1}: is_white = 1'b1;
        {4'd9,3'd2}: is_white = 1'b1;
        {4'd9,3'd3}: is_white = 1'b1;
        {4'd9,3'd4}: is_white = 1'b1;
        {4'd9,3'd5}: is_white = 1'b1;
        {4'd9,3'd6}: is_white = 1'b1;
      endcase

      /*channel number 3*/
      2'd2:
      case({px_y_text[3:0], px_x_text[2:0]})
        {4'd1,3'd2}: is_white = 1'b1;
        {4'd1,3'd3}: is_white = 1'b1;
        {4'd1,3'd4}: is_white = 1'b1;
        {4'd1,3'd5}: is_white = 1'b1;
        {4'd2,3'd1}: is_white = 1'b1;
        {4'd2,3'd2}: is_white = 1'b1;
        {4'd2,3'd5}: is_white = 1'b1;
        {4'd2,3'd6}: is_white = 1'b1;
        {4'd3,3'd5}: is_white = 1'b1;
        {4'd3,3'd6}: is_white = 1'b1;
        {4'd4,3'd5}: is_white = 1'b1;
        {4'd4,3'd6}: is_white = 1'b1;
        {4'd5,3'd3}: is_white = 1'b1;
        {4'd5,3'd4}: is_white = 1'b1;
        {4'd5,3'd5}: is_white = 1'b1;
        {4'd6,3'd5}: is_white = 1'b1;
        {4'd6,3'd6}: is_white = 1'b1;
        {4'd7,3'd5}: is_white = 1'b1;
        {4'd7,3'd6}: is_white = 1'b1;
        {4'd8,3'd1}: is_white = 1'b1;
        {4'd8,3'd2}: is_white = 1'b1;
        {4'd8,3'd5}: is_white = 1'b1;
        {4'd8,3'd6}: is_white = 1'b1;
        {4'd9,3'd2}: is_white = 1'b1;
        {4'd9,3'd3}: is_white = 1'b1;
        {4'd9,3'd4}: is_white = 1'b1;
        {4'd9,3'd5}: is_white = 1'b1;
      endcase

      /*channel number 3*/
      2'd3:
      case({px_y_text[3:0], px_x_text[2:0]})
        {4'd1,3'd5}: is_white = 1'b1;
        {4'd1,3'd6}: is_white = 1'b1;
        {4'd2,3'd4}: is_white = 1'b1;
        {4'd2,3'd5}: is_white = 1'b1;
        {4'd2,3'd6}: is_white = 1'b1;
        {4'd3,3'd3}: is_white = 1'b1;
        {4'd3,3'd4}: is_white = 1'b1;
        {4'd3,3'd5}: is_white = 1'b1;
        {4'd3,3'd6}: is_white = 1'b1;
        {4'd4,3'd2}: is_white = 1'b1;
        {4'd4,3'd3}: is_white = 1'b1;
        {4'd4,3'd5}: is_white = 1'b1;
        {4'd4,3'd6}: is_white = 1'b1;
        {4'd5,3'd1}: is_white = 1'b1;
        {4'd5,3'd2}: is_white = 1'b1;
        {4'd5,3'd5}: is_white = 1'b1;
        {4'd5,3'd6}: is_white = 1'b1;
        {4'd6,3'd1}: is_white = 1'b1;
        {4'd6,3'd2}: is_white = 1'b1;
        {4'd6,3'd3}: is_white = 1'b1;
        {4'd6,3'd4}: is_white = 1'b1;
        {4'd6,3'd5}: is_white = 1'b1;
        {4'd6,3'd6}: is_white = 1'b1;
        {4'd6,3'd7}: is_white = 1'b1;
        {4'd7,3'd5}: is_white = 1'b1;
        {4'd7,3'd6}: is_white = 1'b1;
        {4'd8,3'd5}: is_white = 1'b1;
        {4'd8,3'd6}: is_white = 1'b1;
        {4'd9,3'd4}: is_white = 1'b1;
        {4'd9,3'd5}: is_white = 1'b1;
        {4'd9,3'd6}: is_white = 1'b1;
        {4'd9,3'd7}: is_white = 1'b1;
      endcase
    endcase
  end

  text_is_white = is_white;

endfunction

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
      /*channel number in top left*/
      reg is_white = 1'b0;
      `define SCALE_FACTOR 2

      /*rest of screen (giving channel number preference*/
      if(text_is_white(px_y, px_x, channel_select))
      begin
        r_r = 8'd255;
        r_g = 8'd255;
        r_b = 8'd255;
      end
      else
      begin
        case(channel_select)
          2'd0:
          begin
            r_r = 8'd200;
            r_g = 8'd110;
            r_b = 8'd60;
          end

          2'd1:
          begin
            r_r = 8'd120;
            r_g = 8'd200;
            r_b = 8'd100;
          end

          2'd2:
          begin
            r_r = 8'd50;
            r_g = 8'd180;
            r_b = 8'd200;
          end

          2'd3:
          begin
            r_r = 8'd100;
            r_g = 8'd100;
            r_b = 8'd100;
          end
        endcase
      end
    end
  end
end

assign r = r_r;
assign g = r_g;
assign b = r_b;

endmodule
