proc audio_capture {} {

  # simultion initialisation
  restart -force -nowave

  add wave *

  #add wave *

  # clock setup
  force -deposit clk_250kHz 1 0, 0 {5ps} -repeat 10

  # inputs init
  force key0 1

  # reset init
  force sw0 1
  run 10
  force sw0 0
  run 50

  # starting
  force key0 0
  run 20
  force key0 1


  # to see all of the i2c signal being sent
  run 25000
}
