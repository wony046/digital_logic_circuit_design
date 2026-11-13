onerror {quit -code 1}
onbreak {quit -code 1}
set script_dir [file dirname [file normalize [info script]]]
cd $script_dir
if {![file exists work]} {vlib work}
vmap work work
vcom -2008 ../rs_latch.vhd ../d_latch.vhd ../d_flip_flop.vhd ../jk_flip_flop.vhd ../d_flip_flop_async.vhd vhdl_tb_sequential.vhd
vsim -voptargs=+acc work.tb_sequential
vcd file vhdl_waveforms.vcd
vcd add -r /tb_sequential/*
run -all
quit -code 0
