
#编译仿真库
#建立 verilog_libs仿真库
	transcript on
	if ![file isdirectory verilog_libs] {
		file mkdir verilog_libs
	}

#PLL、ROM、RAM、FIFO等IP需要用到的仿真库
 #	vlib verilog_libs/altera_mf_ver
 #	vmap altera_mf_ver ./verilog_libs/altera_mf_ver
 #	vlog -vlog01compat -work altera_mf_ver {d:/intelfpga/18.1A/quartus/eda/sim_lib/altera_mf.v}
	# d:/intelfpga/18.1A/quartus/eda/sim_lib/ 该路径为Quartus Prime 本地安装路径

#检查是否存在rtl_work,如果存在，则删除
	if {[file exists rtl_work]} {
		vdel -lib rtl_work -all
	}

#建立 rtl_work
	vlib rtl_work

#将“rtl_work”映射到工作区“work”
	vmap work rtl_work

#编译    测试文件
	vlog     top_tb.v

#编译      设计文件
	vlog ../rtl/*.v

#编译      IP文件
#    vlog  ../ip/fifo_8x256/fifo_8x256.v

#指定仿真顶层
	#不涉及IP库
	vsim -t 1ps -L rtl_work -L work -novopt rtl_work.top_tb
	#涉及IP库
	#vsim -t 1ps -L altera_mf_ver -L rtl_work -L work -L verilog_libs -novopt rtl_work.data_ctrl_tb


#调用保存着波形相关设置的do文件
	do wave.do

#执行全部
	run -all

