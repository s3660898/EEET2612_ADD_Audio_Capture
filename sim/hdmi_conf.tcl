proc hdmi_conf {} {

  # simultion initialisation
  restart -force -nowave

  add wave *

  #add wave *

  # clock setup
  force -deposit clk 1 0, 0 {5ps} -repeat 10

  # external setup
  force i2c_busy 0

  # reset init
  force rst 1
  run 10
  force rst 0
  run 10

  #force cmd_address 7'b_101_0101
  force start 1
  run 10
  force i2c_busy 1
  force start 0
  run 100
  force i2c_busy 0
  run 10
  force i2c_busy 1
  run 100
}
