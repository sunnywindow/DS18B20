onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group sim:/top_tb/top_inst/ds18b20_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/ds18b20_ctrl_inst/clk
add wave -noupdate -expand -group sim:/top_tb/top_inst/ds18b20_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/ds18b20_ctrl_inst/rst_n
add wave -noupdate -expand -group sim:/top_tb/top_inst/ds18b20_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/ds18b20_ctrl_inst/dq
add wave -noupdate -expand -group sim:/top_tb/top_inst/ds18b20_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/ds18b20_ctrl_inst/ratio_num
add wave -noupdate -expand -group sim:/top_tb/top_inst/ds18b20_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/ds18b20_ctrl_inst/ratio_en
add wave -noupdate -expand -group sim:/top_tb/top_inst/ds18b20_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/ds18b20_ctrl_inst/sign
add wave -noupdate -expand -group sim:/top_tb/top_inst/ds18b20_ctrl_inst/Group1 -radix binary /top_tb/top_inst/ds18b20_ctrl_inst/dot
add wave -noupdate -expand -group sim:/top_tb/top_inst/ds18b20_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/ds18b20_ctrl_inst/temp_data
add wave -noupdate -expand -group sim:/top_tb/top_inst/ds18b20_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/ds18b20_ctrl_inst/cstate
add wave -noupdate -expand -group sim:/top_tb/top_inst/ds18b20_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/ds18b20_ctrl_inst/nstate
add wave -noupdate -expand -group sim:/top_tb/top_inst/ds18b20_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/ds18b20_ctrl_inst/idle2init
add wave -noupdate -expand -group sim:/top_tb/top_inst/ds18b20_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/ds18b20_ctrl_inst/init2skrom
add wave -noupdate -expand -group sim:/top_tb/top_inst/ds18b20_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/ds18b20_ctrl_inst/init2idle
add wave -noupdate -expand -group sim:/top_tb/top_inst/ds18b20_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/ds18b20_ctrl_inst/skrom2set
add wave -noupdate -expand -group sim:/top_tb/top_inst/ds18b20_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/ds18b20_ctrl_inst/set2idle
add wave -noupdate -expand -group sim:/top_tb/top_inst/ds18b20_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/ds18b20_ctrl_inst/skrom2convert
add wave -noupdate -expand -group sim:/top_tb/top_inst/ds18b20_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/ds18b20_ctrl_inst/convert2wait
add wave -noupdate -expand -group sim:/top_tb/top_inst/ds18b20_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/ds18b20_ctrl_inst/wait2idle
add wave -noupdate -expand -group sim:/top_tb/top_inst/ds18b20_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/ds18b20_ctrl_inst/skrom2read
add wave -noupdate -expand -group sim:/top_tb/top_inst/ds18b20_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/ds18b20_ctrl_inst/read2read_temp
add wave -noupdate -expand -group sim:/top_tb/top_inst/ds18b20_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/ds18b20_ctrl_inst/read_temp2idle
add wave -noupdate -expand -group sim:/top_tb/top_inst/ds18b20_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/ds18b20_ctrl_inst/cmd
add wave -noupdate -expand -group sim:/top_tb/top_inst/ds18b20_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/ds18b20_ctrl_inst/cmd_ok
add wave -noupdate -expand -group sim:/top_tb/top_inst/ds18b20_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/ds18b20_ctrl_inst/dq_in
add wave -noupdate -expand -group sim:/top_tb/top_inst/ds18b20_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/ds18b20_ctrl_inst/dq_out
add wave -noupdate -expand -group sim:/top_tb/top_inst/ds18b20_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/ds18b20_ctrl_inst/dq_oe
add wave -noupdate -expand -group sim:/top_tb/top_inst/ds18b20_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/ds18b20_ctrl_inst/rec_data
add wave -noupdate -expand -group sim:/top_tb/top_inst/ds18b20_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/ds18b20_ctrl_inst/send_data
add wave -noupdate -expand -group sim:/top_tb/top_inst/ds18b20_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/ds18b20_ctrl_inst/end_init
add wave -noupdate -expand -group sim:/top_tb/top_inst/ds18b20_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/ds18b20_ctrl_inst/end_bit
add wave -noupdate -expand -group sim:/top_tb/top_inst/ds18b20_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/ds18b20_ctrl_inst/cnt_1ms
add wave -noupdate -expand -group sim:/top_tb/top_inst/ds18b20_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/ds18b20_ctrl_inst/add_cnt_1ms
add wave -noupdate -expand -group sim:/top_tb/top_inst/ds18b20_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/ds18b20_ctrl_inst/end_cnt_1ms
add wave -noupdate -expand -group sim:/top_tb/top_inst/ds18b20_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/ds18b20_ctrl_inst/cnt_750ms
add wave -noupdate -expand -group sim:/top_tb/top_inst/ds18b20_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/ds18b20_ctrl_inst/add_cnt_750ms
add wave -noupdate -expand -group sim:/top_tb/top_inst/ds18b20_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/ds18b20_ctrl_inst/end_cnt_750ms
add wave -noupdate -expand -group sim:/top_tb/top_inst/ds18b20_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/ds18b20_ctrl_inst/convert_read
add wave -noupdate -expand -group sim:/top_tb/top_inst/ds18b20_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/ds18b20_ctrl_inst/set_flag
add wave -noupdate -expand -group sim:/top_tb/top_inst/ds18b20_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/ds18b20_ctrl_inst/ratio
add wave -noupdate -expand -group sim:/top_tb/top_inst/ds18b20_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/ds18b20_ctrl_inst/set_byte
add wave -noupdate -expand -group sim:/top_tb/top_inst/ds18b20_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/ds18b20_ctrl_inst/add_byte
add wave -noupdate -expand -group sim:/top_tb/top_inst/ds18b20_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/ds18b20_ctrl_inst/end_byte
add wave -noupdate -expand -group sim:/top_tb/top_inst/data_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/data_ctrl_inst/clk
add wave -noupdate -expand -group sim:/top_tb/top_inst/data_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/data_ctrl_inst/rst_n
add wave -noupdate -expand -group sim:/top_tb/top_inst/data_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/data_ctrl_inst/rx
add wave -noupdate -expand -group sim:/top_tb/top_inst/data_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/data_ctrl_inst/sign
add wave -noupdate -expand -group sim:/top_tb/top_inst/data_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/data_ctrl_inst/temp_data
add wave -noupdate -expand -group sim:/top_tb/top_inst/data_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/data_ctrl_inst/ratio_num
add wave -noupdate -expand -group sim:/top_tb/top_inst/data_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/data_ctrl_inst/ratio_en
add wave -noupdate -expand -group sim:/top_tb/top_inst/data_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/data_ctrl_inst/tx
add wave -noupdate -expand -group sim:/top_tb/top_inst/data_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/data_ctrl_inst/tx_start
add wave -noupdate -expand -group sim:/top_tb/top_inst/data_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/data_ctrl_inst/tx_data
add wave -noupdate -expand -group sim:/top_tb/top_inst/data_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/data_ctrl_inst/tx_done
add wave -noupdate -expand -group sim:/top_tb/top_inst/data_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/data_ctrl_inst/tx_idle
add wave -noupdate -expand -group sim:/top_tb/top_inst/data_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/data_ctrl_inst/choose
add wave -noupdate -expand -group sim:/top_tb/top_inst/data_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/data_ctrl_inst/rx_done
add wave -noupdate -expand -group sim:/top_tb/top_inst/data_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/data_ctrl_inst/rx_data
add wave -noupdate -expand -group sim:/top_tb/top_inst/data_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/data_ctrl_inst/rx_data_r
add wave -noupdate -expand -group sim:/top_tb/top_inst/data_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/data_ctrl_inst/cnt_bit
add wave -noupdate -expand -group sim:/top_tb/top_inst/data_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/data_ctrl_inst/add_cnt_bit
add wave -noupdate -expand -group sim:/top_tb/top_inst/data_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/data_ctrl_inst/end_cnt_bit
add wave -noupdate -expand -group sim:/top_tb/top_inst/data_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/data_ctrl_inst/cnt_1s
add wave -noupdate -expand -group sim:/top_tb/top_inst/data_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/data_ctrl_inst/add_cnt_1s
add wave -noupdate -expand -group sim:/top_tb/top_inst/data_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/data_ctrl_inst/end_cnt_1s
add wave -noupdate -expand -group sim:/top_tb/top_inst/data_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/data_ctrl_inst/temp_data_r
add wave -noupdate -expand -group sim:/top_tb/top_inst/data_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/data_ctrl_inst/number
add wave -noupdate -expand -group sim:/top_tb/top_inst/data_ctrl_inst/Group1 -radix unsigned /top_tb/top_inst/data_ctrl_inst/start_flag
add wave -noupdate -expand -group sim:/top_tb/ds18b20_model_inst/Group1 -radix unsigned /top_tb/ds18b20_model_inst/Rst_n
add wave -noupdate -expand -group sim:/top_tb/ds18b20_model_inst/Group1 -radix unsigned /top_tb/ds18b20_model_inst/dq
add wave -noupdate -expand -group sim:/top_tb/ds18b20_model_inst/Group1 -radix unsigned /top_tb/ds18b20_model_inst/STC_MACHINE
add wave -noupdate -expand -group sim:/top_tb/ds18b20_model_inst/Group1 -radix unsigned /top_tb/ds18b20_model_inst/dq_in
add wave -noupdate -expand -group sim:/top_tb/ds18b20_model_inst/Group1 -radix unsigned /top_tb/ds18b20_model_inst/dq_oe
add wave -noupdate -expand -group sim:/top_tb/ds18b20_model_inst/Group1 -radix unsigned /top_tb/ds18b20_model_inst/dq_out
add wave -noupdate -expand -group sim:/top_tb/ds18b20_model_inst/Group1 -radix unsigned /top_tb/ds18b20_model_inst/dq_r
add wave -noupdate -expand -group sim:/top_tb/ds18b20_model_inst/Group1 -radix unsigned /top_tb/ds18b20_model_inst/dq_neg
add wave -noupdate -expand -group sim:/top_tb/ds18b20_model_inst/Group1 -radix unsigned /top_tb/ds18b20_model_inst/dq_pos
add wave -noupdate -expand -group sim:/top_tb/ds18b20_model_inst/Group1 -radix unsigned /top_tb/ds18b20_model_inst/state_c
add wave -noupdate -expand -group sim:/top_tb/ds18b20_model_inst/Group1 -radix unsigned /top_tb/ds18b20_model_inst/state_n
add wave -noupdate -expand -group sim:/top_tb/ds18b20_model_inst/Group1 -radix unsigned /top_tb/ds18b20_model_inst/init_flag
add wave -noupdate -expand -group sim:/top_tb/ds18b20_model_inst/Group1 -radix unsigned /top_tb/ds18b20_model_inst/sample_flag
add wave -noupdate -expand -group sim:/top_tb/ds18b20_model_inst/Group1 -radix unsigned /top_tb/ds18b20_model_inst/data_rx_tmp
add wave -noupdate -expand -group sim:/top_tb/ds18b20_model_inst/Group1 -radix unsigned /top_tb/ds18b20_model_inst/tDelay
add wave -noupdate -expand -group sim:/top_tb/ds18b20_model_inst/Group1 -radix unsigned /top_tb/ds18b20_model_inst/data_tx_tmp
add wave -noupdate -expand -group sim:/top_tb/ds18b20_model_inst/Group1 -radix unsigned /top_tb/ds18b20_model_inst/cnt_bit
add wave -noupdate -expand -group sim:/top_tb/ds18b20_model_inst/Group1 -radix unsigned /top_tb/ds18b20_model_inst/add_cnt_bit
add wave -noupdate -expand -group sim:/top_tb/ds18b20_model_inst/Group1 -radix unsigned /top_tb/ds18b20_model_inst/end_cnt_bit
add wave -noupdate -expand -group sim:/top_tb/ds18b20_model_inst/Group1 -radix unsigned /top_tb/ds18b20_model_inst/cnt_byte_rx
add wave -noupdate -expand -group sim:/top_tb/ds18b20_model_inst/Group1 -radix unsigned /top_tb/ds18b20_model_inst/add_cnt_byte_rx
add wave -noupdate -expand -group sim:/top_tb/ds18b20_model_inst/Group1 -radix unsigned /top_tb/ds18b20_model_inst/end_cnt_byte_rx
add wave -noupdate -expand -group sim:/top_tb/ds18b20_model_inst/Group1 -radix unsigned /top_tb/ds18b20_model_inst/cnt_bit_tx
add wave -noupdate -expand -group sim:/top_tb/ds18b20_model_inst/Group1 -radix unsigned /top_tb/ds18b20_model_inst/add_cnt_bit_tx
add wave -noupdate -expand -group sim:/top_tb/ds18b20_model_inst/Group1 -radix unsigned /top_tb/ds18b20_model_inst/end_cnt_bit_tx
add wave -noupdate -expand -group sim:/top_tb/ds18b20_model_inst/Group1 -radix unsigned /top_tb/ds18b20_model_inst/cnt_byte_tx
add wave -noupdate -expand -group sim:/top_tb/ds18b20_model_inst/Group1 -radix unsigned /top_tb/ds18b20_model_inst/add_cnt_byte_tx
add wave -noupdate -expand -group sim:/top_tb/ds18b20_model_inst/Group1 -radix unsigned /top_tb/ds18b20_model_inst/end_cnt_byte_tx
add wave -noupdate -expand -group sim:/top_tb/ds18b20_model_inst/Group1 -radix unsigned /top_tb/ds18b20_model_inst/Original_code
add wave -noupdate -expand -group sim:/top_tb/ds18b20_model_inst/Group1 -radix unsigned /top_tb/ds18b20_model_inst/Inverse_code
add wave -noupdate -expand -group sim:/top_tb/ds18b20_model_inst/Group1 -radix unsigned /top_tb/ds18b20_model_inst/Supplement_code
add wave -noupdate -expand -group sim:/top_tb/ds18b20_model_inst/Group1 -radix unsigned /top_tb/ds18b20_model_inst/delay_cnt
add wave -noupdate -expand -group sim:/top_tb/ds18b20_model_inst/Group1 -radix unsigned /top_tb/ds18b20_model_inst/add_delay_cnt
add wave -noupdate -expand -group sim:/top_tb/ds18b20_model_inst/Group1 -radix unsigned /top_tb/ds18b20_model_inst/end_delay_cnt
add wave -noupdate -expand -group sim:/top_tb/ds18b20_model_inst/Group1 -radix unsigned /top_tb/ds18b20_model_inst/cnt_sample
add wave -noupdate -expand -group sim:/top_tb/ds18b20_model_inst/Group1 -radix unsigned /top_tb/ds18b20_model_inst/add_cnt_sample
add wave -noupdate -expand -group sim:/top_tb/ds18b20_model_inst/Group1 -radix unsigned /top_tb/ds18b20_model_inst/end_cnt_sample
add wave -noupdate -expand -group sim:/top_tb/ds18b20_model_inst/Group1 -radix unsigned /top_tb/ds18b20_model_inst/cnt_exi
add wave -noupdate -expand -group sim:/top_tb/ds18b20_model_inst/Group1 -radix unsigned /top_tb/ds18b20_model_inst/add_cnt_exi
add wave -noupdate -expand -group sim:/top_tb/ds18b20_model_inst/Group1 -radix unsigned /top_tb/ds18b20_model_inst/end_cnt_exi
add wave -noupdate -expand -group sim:/top_tb/ds18b20_model_inst/Group1 -radix unsigned /top_tb/ds18b20_model_inst/cnt_wr_delay
add wave -noupdate -expand -group sim:/top_tb/ds18b20_model_inst/Group1 -radix unsigned /top_tb/ds18b20_model_inst/add_cnt_wr_delay
add wave -noupdate -expand -group sim:/top_tb/ds18b20_model_inst/Group1 -radix unsigned /top_tb/ds18b20_model_inst/end_cnt_wr_delay
add wave -noupdate -expand -group sim:/top_tb/ds18b20_model_inst/Group1 -radix unsigned /top_tb/ds18b20_model_inst/Clk
add wave -noupdate -expand -group sim:/top_tb/ds18b20_model_inst/Group1 -radix unsigned /top_tb/ds18b20_model_inst/i
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {17165330472 ps} 0}
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
WaveRestoreZoom {0 ps} {58990123500 ps}
