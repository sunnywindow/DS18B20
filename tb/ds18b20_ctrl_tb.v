/*---------------------------------------------------------------	
                tb_module:                   						
                create_time:                  						
                name:yanghaidong       								
----------------------------------------------------------------*/
`timescale 1ns/1ns
module ds18b20_ctrl_tb();
    //内部信号
    parameter	CYCLE = 20;
    localparam      CLK_FREQ    =   50_000_000  ;//时钟频率
    localparam      BAUD_RATE   =   115200      ;//波特率(bps)
    localparam      BAUD_TIME   =   CLK_FREQ / BAUD_RATE;//波特率对应周期，单位(ns)
    reg             rx          ;
    reg		        clk		    ; 
    reg		        rst_n	    ;
    reg     [1:0]   key;
    wire            dq          ;
    wire    [5:0]   dot         ;
    wire    [24:0]  temp_data   ;
    //模块例化
    ds18b20_ctrl ds18b20_ctrl_inst(
    /* input   wire                */   .clk            (clk            ),
    /* input   wire                */   .rst_n          (rst_n          ),
    /* input   wire [1:0]          */   .key            (key            ),
    /* inout   wire                */   .dq             (dq             ),
    /* output  reg     [5:0]       */   .dot            (dot            ), 
    /* output  reg     [24:0]      */   .temp_data      (temp_data      ) 
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
    defparam ds18b20_ctrl_inst.TIME_750ms = 749_999;

    //测试逻辑
    initial begin
        clk		= 1'b0  ;
        rst_n	= 1'b0  ;
        key     = 2'b00 ;
    end

    always #(CYCLE/2) clk = ~clk;

    initial begin
        #(CYCLE+3) rst_n = 1'b1;
        // key = 2'b01;
        // #(CYCLE * 10);
        // key = 2'b00;
        
        #(CYCLE * 2000000);
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