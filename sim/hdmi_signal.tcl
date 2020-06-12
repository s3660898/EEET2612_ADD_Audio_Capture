proc hdmi_signal {} {

  # simultion initialisation
  restart -force -nowave

  add wave *

  #add wave *

  # clock setup
  force -deposit clk 1 0, 0 {5ps} -repeat 10

  # external setup
  force frame_select 0

  # reset init
  force rst 1
  run 10
  force rst 0
  run 1000

  #force cmd_address 7'b_101_0101
}
