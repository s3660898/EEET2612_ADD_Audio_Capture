proc single_shot {} {

  # simultion initialisation
  restart -force -nowave

  add wave *

  # clock setup
  force -deposit clk 1 0, 0 {10} -repeat 20

  # inputs init
  force rst 0
  force start 0

  run 10
  
  force rst 1
  run 10

  force rst 0
  force start 1
  run

  # reset init

}
