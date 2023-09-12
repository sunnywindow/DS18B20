/*---------------------------------------------------------------	
                tb_module:                   						
                create_time:                  						
                name:yanghaidong       								
----------------------------------------------------------------*/
`timescale 1ns/1ns
module top_tb();
    //内部信号
    parameter	CYCLE = 20;
    localparam      CLK_FREQ    =   50_000_000  ;//时钟频率
    localparam      BAUD_RATE   =   115200      ;//波特率(bps)
    localparam      BAUD_TIME   =   CLK_FREQ / BAUD_RATE;//波特率对应周期，单位(ns)
    reg		clk		; 
    reg		rst_n	;
    reg     rx      ;
    wire    dq      ;
    wire    tx      ;
    wire    DS      ;
    wire    SH_CP   ;
    wire    ST_CP   ;
    //模块例化
    top top_inst(
    /* input	wire		   */   .clk        (clk	    ),
    /* input	wire		   */   .rst_n	    (rst_n	    ),
    /* inout   wire           */    .dq         (dq         ),
    /* input   wire           */    .rx         (rx         ),
    /* output  wire           */    .tx         (tx         ),
    /* output  wire           */    .SH_CP      (SH_CP      ),
    /* output  wire           */    .ST_CP      (ST_CP      ),
    /* output  wire           */    .DS         (DS         )
    );
    ds18b20_model #(
		.SIG_DATA   (0      ) 	, //0：正数、1：负数
		.INT_DATA   (30     ) 	, //温度数据整数部分，有效输入 -40 ~ +125
		.DEC_DATA   (4'b1101) 	, //温度数据小数部分，仅接受4bit-binary输入
		.MAX_WAIT   (750_000)     //温度转换等待最长时间 12bit-750ms
    ) ds18b20_model_inst (
	/* input        */  .Rst_n      (rst_n      ), //
	/* inout 		 */ .dq         (dq         )  //
    );
    defparam top_inst.ds18b20_ctrl_inst.TIME_750ms = 749_999;


    //测试逻辑
    initial begin
        clk		= 1'b0;
        rst_n	= 1'b0;
        rx      = 1'b1;
    end

    always #(CYCLE/2) clk = ~clk;

    initial begin
        #(CYCLE+3) rst_n = 1'b1;
        rxd_1_byte(8'h62);
        wait(top_inst.ds18b20_ctrl_inst.cmd_ok[2]);
        #(CYCLE * 100);
        rxd_1_byte(8'h39);
        wait(top_inst.ds18b20_ctrl_inst.cmd_ok[2]);
        #(CYCLE * 5000);
        $stop(2);
    end

    task rxd_1_byte;
        input [7:0] data;
    integer i;
    begin
        rx  = 0;
        #(CYCLE * BAUD_TIME);
        for (i = 0; i<8; i=i+1) begin
            rx = data[i];
            #(CYCLE * BAUD_TIME);
        end
        rx  = 1;
        #(CYCLE * BAUD_TIME);
    end
    endtask
endmodule