onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /data_ctrl_tb/data_ctrl_inst/clk
add wave -noupdate -radix unsigned /data_ctrl_tb/data_ctrl_inst/rst_n
add wave -noupdate -radix unsigned /data_ctrl_tb/data_ctrl_inst/temp_data
add wave -noupdate -radix unsigned /data_ctrl_tb/data_ctrl_inst/tx
add wave -noupdate -radix unsigned /data_ctrl_tb/data_ctrl_inst/tx_start
add wave -noupdate -radix hexadecimal /data_ctrl_tb/data_ctrl_inst/tx_data
add wave -noupdate -radix unsigned /data_ctrl_tb/data_ctrl_inst/tx_done
add wave -noupdate -radix unsigned /data_ctrl_tb/data_ctrl_inst/tx_idle
add wave -noupdate -radix unsigned /data_ctrl_tb/data_ctrl_inst/cnt_bit
add wave -noupdate -radix unsigned /data_ctrl_tb/data_ctrl_inst/add_cnt_bit
add wave -noupdate -radix unsigned /data_ctrl_tb/data_ctrl_inst/end_cnt_bit
add wave -noupdate -radix unsigned /data_ctrl_tb/data_ctrl_inst/cnt_1s
add wave -noupdate -radix unsigned /data_ctrl_tb/data_ctrl_inst/add_cnt_1s
add wave -noupdate -radix unsigned /data_ctrl_tb/data_ctrl_inst/end_cnt_1s
add wave -noupdate -radix unsigned /data_ctrl_tb/data_ctrl_inst/temp_data_r
add wave -noupdate -radix unsigned /data_ctrl_tb/data_ctrl_inst/number
add wave -noupdate -radix unsigned /data_ctrl_tb/data_ctrl_inst/start_flag
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {20607730000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {19787417405 ps} {21428042595 ps}
