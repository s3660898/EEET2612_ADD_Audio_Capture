proc i2c {} {

  # simultion initialisation
  restart -force -nowave
  add wave /i2c/clk
  add wave /i2c/rst
  add wave /i2c/sda
  add wave /i2c/scl

  add wave *

  # clock setup
  force -deposit clk 1 0, 0 {5ps} -repeat 10

  # reset init
  force rst 1
  run 10
  force rst 0
  run 10

  force cmd_address 7'b_101_0101
  force data_out 8'b_1010_1010
  force start 1
  run 10
  force start 0
  run 200
}
