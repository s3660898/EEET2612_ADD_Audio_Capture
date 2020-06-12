proc audio_capture {} {

  # simultion initialisation
  restart -force -nowave

  add wave *

  #add wave *

  # clock setup
  force -deposit clk_50MHz 1 0, 0 {10ns} -repeat 20ns

  # inputs init
  force key0 1

  # reset init
  force sw0 1
  run 20us
  force sw0 0
  run 20us


  # starting
  run 20us
  force key0 0
  run 20us
  force key0 1

  # add wave /audio_capture/clk_50MHz_250kHz/*
  add wave /audio_capture/hdmi_s/*

  # to see all of the i2c signal being sent
  run 1ms
}
