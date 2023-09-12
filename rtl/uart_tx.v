/*---------------------------------------------------------------	
            module		:                   						
            create_time	:                  							
            name		:yanghaidong       							
----------------------------------------------------------------*/
module uart_tx#(
    parameter   CLK_FREQ    =   28'd50_000_000, //时钟频率
    // parameter   BAUD        =   9600      , //波特率(bps)
    parameter   BIT_W       =   4'd8
)(
    input	wire		            clk		    ,
    input	wire		            rst_n	    ,
    //输入信号
    input   wire    [31:0]          BAUD        ,//波特率
    input   wire    [1:0]           choose      ,
    input	wire                    tx_start	,//开始发送信号
    input	wire    [BIT_W - 1:0]   tx_data	    ,//发送的数据
    //输出信号
    output	reg		    	        tx_idle	    ,//发送状态，1为空闲，0为正在发送
    output  reg                     tx_done     ,//发送结束
    output	reg		    	        tx	    	 //发送端口
);
    //内部信号                  
    localparam     
                IDLE  = 4'b0001 ,
                START = 4'b0010 ,
                SEND  = 4'b0100 ,
                STOP  = 4'b1000 ;

    reg     [3:0]       cstate,nstate   ;//状态机及状态跳转条件
    wire                idle2start      ;
    wire                start2send      ;
    wire                send2stop       ;
    wire                stop2idle       ;

    wire    [31:0]      MAX_BAUD        ;
    reg     [BIT_W:0]   data_r          ;//数据寄存,8位数据位+1bit奇校验位

    reg     [23:0]      cnt_baud        ;//波特率计数器
    wire                add_cnt_baud    ;
    wire                end_cnt_baud    ;

    reg     [3:0]       cnt_bit         ;//发送BIT计数器
    wire                add_cnt_bit     ;
    wire                end_cnt_bit     ;


    //模块例化
    // ODDorEVEN ODDorEVEN_inst(
    // /* input	wire    [1:0]    */ .choose     (choose   ),
    // /* input	wire	[7:0]    */ .data	    (data_r   ),
    // /* output	reg              */ .check_bit	(check_bit)
    // );

    //内部逻辑
    assign MAX_BAUD = CLK_FREQ / BAUD - 1;
    //第一段状态机
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cstate <= IDLE;
        end
        else begin
            cstate <= nstate;
        end
    end

    //第二段状态机
    always @(*) begin
        case (cstate)
            IDLE :begin
                if (idle2start) begin
                    nstate = START;
                end
                else begin
                    nstate = IDLE;
                end
            end
            START:begin
                if (start2send) begin
                    nstate = SEND;
                end
                else begin
                    nstate = START;
                end
            end
            SEND :begin
                if (send2stop) begin
                    nstate = STOP;
                end
                else begin
                    nstate = SEND;
                end
            end
            STOP :begin
                if (stop2idle) begin
                    nstate = IDLE;
                end
                else begin
                    nstate = STOP;
                end
            end 
            default: nstate = IDLE;
        endcase
    end

    assign idle2start   = cstate == IDLE    && (tx_start    && tx_idle  );
    assign start2send   = cstate == START   && (end_cnt_baud            );
    assign send2stop    = cstate == SEND    && (end_cnt_bit             );
    assign stop2idle    = cstate == STOP    && (end_cnt_baud            );

    //第三段状态机
    //数据寄存
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_r <= 8'd0;
        end
        else if (cstate == START) begin
            data_r <= tx_data;
        end
        else begin
            data_r <= data_r;
        end
    end

    //发送状态，1为空闲，0为正在发送
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx_idle <= 1'd1;
        end
        else if (cstate == START) begin
            tx_idle <= 1'b0;
        end
        else if (cstate == STOP && end_cnt_baud) begin
            tx_idle <= 1'd1;
        end
        else begin
            tx_idle <= tx_idle;
        end
    end
    //发送结束
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx_done <= 1'b0;
        end
        else if (cstate == IDLE) begin
            tx_done <= 1'b0;
        end
        else if (cstate == STOP && end_cnt_baud) begin
            tx_done <= 1'b1;
        end
        else begin
            tx_done <= tx_done;
        end
    end
    //波特率计数
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt_baud <= 24'd0;
        end
        else begin
            if (add_cnt_baud) begin
                if (end_cnt_baud) begin
                    cnt_baud <= 24'd0;
                end
                else begin
                    cnt_baud <= cnt_baud + 24'd1;
                end
            end
            else begin
                cnt_baud <= 24'd0;
            end
        end
    end

    assign add_cnt_baud = cstate != IDLE;
    assign end_cnt_baud = add_cnt_baud && cnt_baud == MAX_BAUD;

    //发送哪一位bit计数器
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt_bit <= 4'd0;
        end
        else begin
            if (add_cnt_bit) begin
                if (end_cnt_bit) begin
                    cnt_bit <= 4'd0;
                end
                else begin
                    cnt_bit <= cnt_bit + 4'd1;
                end
            end
            else begin
                cnt_bit <= cnt_bit;
            end
        end
    end

    assign add_cnt_bit = (cstate == SEND) && end_cnt_baud;
    assign end_cnt_bit = add_cnt_bit && cnt_bit == BIT_W -1;

    //发送数据
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx <= 1'b1;
        end
        else begin
            case (cstate)
                IDLE    : tx <= 1'b1;
                START   : tx <= 1'b0;
                SEND    : tx <= data_r[cnt_bit];
                STOP    : tx <= 1'b1;
                default: tx <= 1'b1;
            endcase
        end
    end

endmodule