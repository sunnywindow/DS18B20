/* ================================================ *\
Filename           : ds18b20_model.v
Author             : Adolph
Description        : DS18B20仿真模型
Called by          : 
Revision History   : 2023-7-12 12:31:15
Revision           : 1.0
Email              : ***@gmail.com
Company            : AWCloud...Std 
NOTE：
	2023-7-12 15:02:42 v1.0 
		仅考虑正数温度数据的读取,以及分辨率的设计;
		ROM指令只支持8'hCC;
		指令接收错误时，会打印消息，并暂停仿真系统的执行.
	2023-8-22 11:06:50 V1.1
		支持负数温度输入;
		添加弱上拉操作;
		修改最大等待时间支持自定义.
	2023-8-22 17:16:48 V1.2
		负数温度数据显示错乱修正.
	2023-8-23 10:48:09 V1.3
		修正：内部 cnt_bit_tx 未清空，导致第二次读出数据错乱的问题
	2023-8-23 14:01:51 V1.4
		添加：复位脉冲后的总线释放时间-60us
\* ================================================ */
`timescale 1ns/1ps

module ds18b20_model #(parameter
		SIG_DATA   = 0       	, //0：正数、1：负数
		INT_DATA   = 37      	, //温度数据整数部分，有效输入 -40 ~ +125
		DEC_DATA   = 4'b0000 	, //温度数据小数部分，仅接受4bit-binary输入
		MAX_WAIT   = 750_000//_000  //温度转换等待最长时间 12bit-750ms
	)(
	input       Rst_n , //
	inout 		dq      //
);
//Parameter Declarations
	localparam 
		tRstPluse 	= 24000 	 	, //复位脉冲480us
		tINIT_rel   = 3000 			, //初始化 总线释放时间 60us
		tEPulse   	= 10000 	 	, //存在脉冲200us
		tSEND 		= 3000 	 	 	, //数据发送持续时间60us
		tSAMPLE 	= 2000 	 	 	, //采样时间点 40us
		tCONV     	= MAX_WAIT 		; //最大等待750ms

	localparam  //独热码定义状态参数
		IDLE      	= 8'b0000_0001 	, // 空闲状态
		INIT_RST    = 8'b0000_0010 	, // 接收复位脉冲状态
		INIT_EXI    = 8'b0000_0100 	, // 发送存在脉冲状态
		ROM_CMD     = 8'b0000_1000 	, // 接收ROM指令状态
		DS_CMD 		= 8'b0001_0000 	, // 接收功能指令状态
		TX_DATA 	= 8'b0010_0000 	, // 发送数据状态
		WAIT 		= 8'b0100_0000 	, // 温度转换等待状态
		WR_DATA 	= 8'b1000_0000  ; // 修改暂存器内容

	localparam
		CMD_SKIP_ROM = 8'hCC,
		CMD_COVT 	 = 8'h44,
		CMD_WRITE 	 = 8'h4E,
		CMD_READ 	 = 8'hBE;

//Internal wire/reg declarations
	reg      	[63:00]		STC_MACHINE 		; //
	
	wire 					dq_in 				;
	reg                     dq_oe 				; //  
	reg                     dq_out 				; //
	reg      	[01:00]     dq_r 				; //
	wire  					dq_neg,dq_pos 		;
	
	reg 		[07:00] 	Memory [04:00]		; // temperature-2byte 、warning-2byte 、Resolution
	reg         [07:00]     state_c, state_n	; //状态变量声明

	reg                     init_flag 			; //
	reg  					sample_flag 		; //
	reg      	[07:00] 	data_rx_tmp 		; //
	reg      	[31:00]     tDelay				; //
	reg      	[07:00]     data_tx_tmp 		; //	

	reg 		[03:00]		cnt_bit    			; //Counter  
	wire                    add_cnt_bit			; //Counter Enable
	wire                    end_cnt_bit			; //Counter Reset 
	
	reg 		[03:00]		cnt_byte_rx    		; //Counter 
	wire                    add_cnt_byte_rx		; //Counter Enable
	wire                    end_cnt_byte_rx		; //Counter Reset 

	reg 		[03:00]		cnt_bit_tx     		;//Counter  
	wire                    add_cnt_bit_tx 		;//Counter Enable
	wire                    end_cnt_bit_tx 		;//Counter Reset 
	
	reg 		[03:00]		cnt_byte_tx    		; //Counter 
	wire                    add_cnt_byte_tx		; //Counter Enable
	wire                    end_cnt_byte_tx		; //Counter Reset 
	
	wire    	[10:00]    	Original_code 		; //
	wire    	[10:00]    	Inverse_code 		; //
	wire    	[10:00]    	Supplement_code 	; //

	reg 		[15:00]		delay_cnt    		;//Counter  
	wire                    add_delay_cnt		;//Counter Enable
	wire                    end_delay_cnt		;//Counter Reset 

	reg 		[10:00]		cnt_sample    		; //Counter 
	wire                    add_cnt_sample		; //Counter Enable
	wire                    end_cnt_sample		; //Counter Reset 

	reg          [15:00]    cnt_exi    			; //Counter 
	wire                    add_cnt_exi			; //Counter Enable
	wire                    end_cnt_exi			; //Counter Reset 

	reg          [15:00]    cnt_wr_delay     	; //Counter    
	wire                    add_cnt_wr_delay 	; //Counter Enable
	wire                    end_cnt_wr_delay 	; //Counter Reset
	
//Logic Description
	// 生成时钟
	reg 		Clk 	 	;//50MHz
	initial 	Clk = 0 	;
	always #10 Clk = ~Clk 	;

	integer i = 0 ;

	initial begin
		$timeformat(-9,0," ns",15); //精度、小数位数、附带字符串内容、整体最小长度
		i=0;
		repeat(5) begin
			#1;
			case(i)
				0 : begin Memory[0] = 8'h00; end
				1 : begin Memory[1] = 8'h00; end
				2 : begin Memory[2] = 8'h40; end
				3 : begin Memory[3] = 8'h10; end
				4 : begin Memory[4] = 8'h7F; end
				default: ;
			endcase
			i = i + 1;
		end
	end
	
	always @(posedge Clk or negedge Rst_n)begin  
		if(!Rst_n)begin  
			delay_cnt <= 'd0; 
		end  
		else if(add_delay_cnt)begin  
			if(end_delay_cnt)begin  
				delay_cnt <= delay_cnt; 
			end  
			else begin  
				delay_cnt <= delay_cnt + 1'b1; 
			end  
		end  
		else begin  
			delay_cnt <= 'd0;
		end  
	end //always end
	
	assign add_delay_cnt = ~dq & state_c != INIT_EXI; //产生存在脉冲期间，不考虑复位
	assign end_delay_cnt = add_delay_cnt && delay_cnt >= tRstPluse; 
	
	always @(posedge Clk or negedge Rst_n)begin  
		if(!Rst_n)begin  
			cnt_sample <= 'd0; 
		end  
		else if(dq_neg)begin
			cnt_sample <= 'd0; 
		end
		else if(add_cnt_sample)begin  
			if(end_cnt_sample)begin  
				cnt_sample <= tSEND; 
			end  
			else begin  
				cnt_sample <= cnt_sample + 1'b1; 
			end  
		end  
		else begin  
			cnt_sample <= 'd0;  
		end  
	end //always end
	
	assign add_cnt_sample = (state_c == ROM_CMD || state_c == DS_CMD || state_c == WR_DATA); 
	assign end_cnt_sample = add_cnt_sample && cnt_sample >= tSEND; 
	
	always @(posedge Clk or negedge Rst_n)begin  
		if(!Rst_n)begin  
			cnt_exi <= 'd0; 
		end  
		else if(add_cnt_exi)begin  
			if(end_cnt_exi)begin  
				cnt_exi <= cnt_exi; 
			end  
			else begin  
				cnt_exi <= cnt_exi + 1'b1; 
			end  
		end  
		else begin  
			cnt_exi <= 'd0;  
		end  
	end //always end
	
	assign add_cnt_exi = state_c == INIT_EXI; 
	assign end_cnt_exi = add_cnt_exi && cnt_exi >= tEPulse + tINIT_rel - 1; 
	
	always @(posedge Clk or negedge Rst_n)begin
		if(!Rst_n)begin  
			cnt_wr_delay <= 'd0; 
		end  
		else if(dq_neg)begin
			cnt_wr_delay <= 'd0; 
		end
		else if(add_cnt_wr_delay)begin  
			if(end_cnt_wr_delay)begin  
				cnt_wr_delay <= tSEND; 
			end  
			else begin  
				cnt_wr_delay <= cnt_wr_delay + 1'b1; 
			end  
		end  
		else begin  
			cnt_wr_delay <= 'd0;  
		end  
	end 		
	assign add_cnt_wr_delay = state_c == TX_DATA; 
	assign end_cnt_wr_delay = add_cnt_wr_delay && cnt_wr_delay >= tSEND; 
	
//三段式状态机
	//第一段设置状态转移空间
	always@(posedge Clk or negedge Rst_n)begin
		if(!Rst_n)begin
			state_c <= IDLE;
		end
		else if(init_flag & dq_pos)begin //任何时候，接收到复位脉冲都直接进入 存在脉冲产生阶段
			state_c <= INIT_EXI;
		end
		else begin
			state_c <= state_n;
		end
	end //always end
	
	//第二段、组合逻辑定义状态转移
	always@(*)begin
		case(state_c)
			IDLE    :begin 
				if(1'b1)begin
					state_n = INIT_RST;
				end
				else begin
					state_n = IDLE;
				end
			end 
			INIT_RST:begin 
				if(init_flag & dq_pos)begin //检测到主机释放总线才接管总线控制权
					state_n = INIT_EXI;
					$display("%t:  ds18b20.model: Reset  Pulse is received. ",$realtime);
				end 
				else begin 
					state_n = INIT_RST; 
				end 
			end 
			INIT_EXI:begin 
				// #(tEPulse * 20);
				if(end_cnt_exi && dq_neg)begin
					state_n = ROM_CMD;
				end
				else begin
					state_n = INIT_EXI;
				end
			end 
			ROM_CMD :begin 
				if(end_cnt_bit)begin
					if(data_rx_tmp == CMD_SKIP_ROM)begin
						state_n = DS_CMD;
						$display("%t:  ds18b20.model: ROM Command received. ",$realtime);
					end
					else begin
						state_n = IDLE;
						#20;
						$display("%t:  ds18b20.model: Error received ROM Command !!! \n ",$realtime);
						$stop(2);
					end
				end
				else begin
					state_n = ROM_CMD;
				end
			end 
			DS_CMD 	:begin 
				if(end_cnt_bit)begin
					if(data_rx_tmp == CMD_WRITE)begin
						state_n = WR_DATA;
						$display("%t:  ds18b20.model: Write data Command received. ",$realtime);
					end
					else if(data_rx_tmp == CMD_COVT)begin
						state_n = WAIT;
						$display("%t:  ds18b20.model: Convert Command received. ",$realtime);
					end
					else if(data_rx_tmp == CMD_READ)begin
						state_n = TX_DATA;
						$display("%t:  ds18b20.model: Read data Command received. ",$realtime);
					end
					else begin
						state_n = IDLE;
						#20;
						$display("%t:  ds18b20.model: Error received Function Command !!! \n ",$realtime);
						$stop(0);
					end
				end 
				else begin
					state_n = DS_CMD;
				end
			end 
			TX_DATA :begin //read data				
				if(end_cnt_byte_tx)begin
					state_n = IDLE;
				end
				else begin
					state_n = TX_DATA;
				end
			end 
			WR_DATA :begin //write data
				if(end_cnt_byte_rx)begin
					state_n = IDLE;
					$display("%t:  ds18b20.model: Write data done. ",$realtime);
				end
				else begin
					state_n = WR_DATA;
				end
			end 
			WAIT 	:begin //convert time
				# tDelay;
				$display("%t:  ds18b20.model: Convert time is OK. ",$realtime);
				state_n = IDLE;
			end 
			default: begin
				state_n = IDLE;
			end
		endcase
	end //always end		

	//第三段，定义状态机输出情况，可以时序逻辑，也可以组合逻辑
	always @(posedge Clk or negedge Rst_n)begin 
		if(!Rst_n)begin
			dq_r <= 2'b11;
		end  
		else begin
			dq_r <= {dq_r[0],dq};
		end
	end //always end
	assign dq_pos = ~dq_r[1] & dq_r[0];
	assign dq_neg = dq_r[1] & ~dq_r[0];
	
	always @(posedge Clk or negedge Rst_n)begin 
		if(!Rst_n)begin
			init_flag <= 1'b0;
		end  
		else if(delay_cnt >= tRstPluse)begin //复位脉冲时间满足
			init_flag <= 1'b1;
		end  
		else begin
			init_flag <= 1'b0;
		end
	end //always end

	always @(posedge Clk or negedge Rst_n)begin 
		if(!Rst_n)begin
			data_rx_tmp <= 8'd0;
		end  
		else begin
			data_rx_tmp[cnt_bit] <= (cnt_sample == tSAMPLE) ? dq : data_rx_tmp[cnt_bit];
		end  
	end //always end		

	always @(posedge Clk or negedge Rst_n)begin 
		if(!Rst_n)begin
			sample_flag <= 1'b0;
		end  
		else begin
			sample_flag <= cnt_sample == tSAMPLE;
		end
	end //always end
		
	always @(posedge Clk or negedge Rst_n)begin  
		if(!Rst_n)begin  
			cnt_bit <= 'd0; 
		end  
		else if(init_flag)begin
			cnt_bit <= 'd0; 
		end
		else if(add_cnt_bit)begin  
			if(end_cnt_bit)begin  
				cnt_bit <= 'd0; 
			end  
			else begin  
				cnt_bit <= cnt_bit + 1'b1; 
			end  
		end  
		else begin  
			cnt_bit <= cnt_bit;
		end  
	end //always end
	
	assign add_cnt_bit = (state_c == ROM_CMD || state_c == DS_CMD || state_c == WR_DATA) && sample_flag; 
	assign end_cnt_bit = add_cnt_bit && cnt_bit >= 4'd7; 
	
	always @(posedge Clk or negedge Rst_n)begin  
		if(!Rst_n)begin  
			cnt_byte_rx <= 'd0; 
		end  
		else if(init_flag)begin 
			cnt_byte_rx <= 'd0;
		end
		else if(add_cnt_byte_rx)begin  
			if(end_cnt_byte_rx)begin  
				cnt_byte_rx <= 'd0; 
			end  
			else begin  
				cnt_byte_rx <= cnt_byte_rx + 1'b1; 
			end  
		end  
		else begin  
			cnt_byte_rx <= cnt_byte_rx;  
		end  
	end //always end
	
	assign add_cnt_byte_rx = (state_c == WR_DATA) && end_cnt_bit; 
	assign end_cnt_byte_rx = add_cnt_byte_rx && cnt_byte_rx >= 4'd2; 
	
	always @(*)begin 
		case(Memory[4][6:5])
			0: tDelay = tCONV >> 3;
			1: tDelay = tCONV >> 2;
			2: tDelay = tCONV >> 1;
			3: tDelay = tCONV >> 0;
			default: tDelay = tCONV;
		endcase
	end //always end
	
    //Memory data
	assign Original_code = {INT_DATA[6:0],DEC_DATA[3:0]};
	assign Inverse_code  = ~Original_code;
	assign Supplement_code = Inverse_code + 11'd1;

	always @(posedge Clk )begin 
		if(state_c == WR_DATA && end_cnt_bit)begin //数据写入
			case(cnt_byte_rx)
				0,1: Memory[cnt_byte_rx+2] <= data_rx_tmp;//预警值上下限
				default:Memory[cnt_byte_rx+2] <= {1'b0,data_rx_tmp[6:5],5'h1f};//修改分辨率
			endcase
		end  
		else begin
			if(|SIG_DATA)begin //负数温度数据
				Memory[0] = Supplement_code[07:00];
				Memory[1] = {{5{|SIG_DATA}},Supplement_code[10:08]};
			end
			else begin //正数温度数据
				Memory[0] = Original_code[07:00];
				Memory[1] = {{5{|SIG_DATA}},Original_code[10:08]};
			end
		end
	end //always end
	
	always @(posedge Clk or negedge Rst_n)begin  
		if(!Rst_n)begin  
			cnt_bit_tx <= 'd0; 
		end  
		else if(state_c == INIT_EXI)begin
			cnt_bit_tx <= 'd0; //此处清空，可保证多次数据读取不错乱
		end
		else if(add_cnt_bit_tx)begin  //有效计数范围 1-8
			if(end_cnt_bit_tx)begin  
				cnt_bit_tx <= 'd1; 
			end  
			else begin  
				cnt_bit_tx <= cnt_bit_tx + 1'b1; 
			end  
		end  
	end //always end	
	assign add_cnt_bit_tx = state_c == TX_DATA && dq_neg; 
	assign end_cnt_bit_tx = add_cnt_bit_tx && cnt_bit_tx >= 4'd8; 
	
	always @(posedge Clk or negedge Rst_n)begin  
		if(!Rst_n)begin  
			cnt_byte_tx <= 'd0; 
		end  
		else if(init_flag)begin
			cnt_byte_tx <= 'd0; 
		end
		else if(add_cnt_byte_tx)begin  
			if(end_cnt_byte_tx)begin  
				cnt_byte_tx <= 'd0; 
			end  
			else begin  
				cnt_byte_tx <= cnt_byte_tx + 1'b1; 
			end  
		end  
	end //always end	
	assign add_cnt_byte_tx = end_cnt_bit_tx; 
	assign end_cnt_byte_tx = add_cnt_byte_tx && cnt_byte_tx >= 4'd4; 
	
	// 存在脉冲和数据发送
	always @(posedge Clk or negedge Rst_n)begin 
		if(!Rst_n)begin
			dq_oe <= 1'b0;
			dq_out <= 1'b0;
			data_tx_tmp <= 8'd0;
		end  
		else if(state_c == INIT_EXI)begin
			if(cnt_exi < tINIT_rel)begin
				dq_oe <= 1'b0; //总线释放恢复时间
			end
			else if(end_cnt_exi)begin
				dq_oe <= 1'b0; //交出总线控制权
			end
			else begin
				dq_oe <= 1'b1; //存在脉冲
				dq_out <= 1'b0;
			end			
		end  
		else if(state_c == TX_DATA)begin //发送数据
			data_tx_tmp <= Memory[cnt_byte_tx];
			if(/*cnt_wr_delay >= 100 && */cnt_wr_delay < tSEND && cnt_bit_tx != 0)begin
				dq_oe <= 1'b1; 
				dq_out <= data_tx_tmp[cnt_bit_tx - 1]; 
			end
			else begin
				dq_oe <= 1'b0;
				dq_out <= 1'b0;
			end
		end
		else begin
			dq_oe <= 1'b0;
			dq_out <= 1'b0;
		end
	end //always end
	
	pullup (dq);//设置弱上拉操作
	assign dq = dq_oe ? dq_out : 1'bz;
	assign dq_in = dq;

	// ASCII显示状态机现态变量
	always @(*)begin 
		case(state_c)
			IDLE    :STC_MACHINE = "IDLE    ";
			INIT_RST:STC_MACHINE = "INIT_RST";
			INIT_EXI:STC_MACHINE = "INIT_EXI";
			ROM_CMD :STC_MACHINE = "ROM_CMD ";
			DS_CMD 	:STC_MACHINE = "DS_CMD 	";
			TX_DATA :STC_MACHINE = "TX_DATA ";
			WAIT 	:STC_MACHINE = "WAIT 	";
			WR_DATA :STC_MACHINE = "WR_DATA ";
			default :STC_MACHINE = "IDLE    ";
		endcase
	end //always end

endmodule 