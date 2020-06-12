proc spi {} {

  # simultion initialisation
  restart -force -nowave

add wave *

  # clock setup
  force -deposit clk 1 0, 0 {5ps} -repeat 10

  # reset init
  force rst 1
  force enable 0
  run 10
  force rst 0
  run 10

  force wdata 6'b_10_0101
  run 10
  force enable 1
  run 5000
}
