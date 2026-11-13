onerror {quit -code 1}
onbreak {quit -code 1}
set found 0
foreach candidate [list [pwd] [file join [pwd] verification] [file join [pwd] assignment_3 verification]] {
    if {[file exists [file join $candidate vhdl_tb_sequential.vhd]]} {
        cd $candidate
        set found 1
        break
    }
}
if {!$found} {error "Run from the repository, assignment_3, or verification directory."}
if {![file exists modelsim.ini]} {vmap -c}
if {![file exists work/_info]} {vlib work}
vmap work work
vcom -2008 ../rs_latch.vhd ../d_latch.vhd ../d_flip_flop.vhd ../jk_flip_flop.vhd ../d_flip_flop_async.vhd vhdl_tb_sequential.vhd
vsim -voptargs=+acc work.tb_sequential
vcd file vhdl_waveforms.vcd
vcd add -r /tb_sequential/*
run -all
quit -code 0
