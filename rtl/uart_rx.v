/*---------------------------------------------------------------	
            module		:                   						
            create_time	:                  							
            name		:yanghaidong       							
----------------------------------------------------------------*/
module uart_rx#(
    parameter   CLK_FREQ    =   50_000_000, //时钟频率
    // parameter   BAUD        =   9600      , //波特率(bps)
    parameter   BIT_W   =   8
)(
    input	wire		            clk		    ,
    input	wire		            rst_n	    ,
    //输入信号
    input   wire    [31:0]          BAUD        ,//波特率
    input	wire                    rx	        ,//接收数据
    input   wire                    key         ,//切换检验位
    input   wire                    tx_idle     ,
    //输出信号
    output	reg     [BIT_W  :0]     rx_data	    ,//接收到的数据
    output  reg     [1:0]           choose      ,//0为无校验，1为奇校验ODD，2为偶校验EVEN
    output	reg		    	        rx_done	     //接收结束
);
    //内部信号
    // localparam  MAX_BAUD        =   CLK_FREQ / BAUD - 1;
    // localparam  HALF_BAUD       =   MAX_BAUD / 2 - 1;// 波特率对应计数值/2
    localparam     
                IDLE    = 4'b0001   ,
                START   = 4'b0010   ,
                RECEIVE = 4'b0100   ,
                STOP    = 4'b1000   ;

    reg     [3:0]       cstate,nstate   ;//状态机现态和次态
    wire                idle2start      ;//状态跳转条件
    wire                start2receive   ;
    wire                start2idle      ;
    wire                receive2stop    ;
    wire                receive2idle    ;
    wire                stop2idle       ;

    wire    [31:0]      MAX_BAUD        ;//波特率计数器最大值
    wire    [23:0]      HALF_BAUD       ;//一半时取值做为数据

    reg                 rx_r0           ;//打三拍
    reg                 rx_r1           ;
    reg                 rx_r2           ;
    wire                nedge           ;//下降沿检测

    reg     [23:0]      cnt_baud        ;//波特率计数器
    wire                add_cnt_baud    ;
    wire                end_cnt_baud    ;

    reg     [3:0]       cnt_bit         ;//接收BIT计数器
    wire                add_cnt_bit     ;
    wire                end_cnt_bit     ;

    reg                 check           ;//判断接收数据是否满足协议，高电平表示正确，低电平表示错误

    wire                add_choose      ;
    wire                end_choose      ;

    wire                check_bit       ;//校验数据

    //模块例化
    // ODDorEVEN ODDorEVEN_inst(
    // /* input	wire    [1:0]    */ .choose     (choose     ),
    // /* input	wire	[7:0]    */ .data	    (rx_data    ),
    // /* output	reg              */ .check_bit	(check_bit  )
    // );

    //内部逻辑
    //波特计数值
    assign MAX_BAUD = CLK_FREQ / BAUD - 1;
    assign HALF_BAUD = MAX_BAUD / 2 - 1;
    //打三拍减小亚稳态
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_r0 <= 1'b0;
            rx_r1 <= 1'b0;
            rx_r2 <= 1'b0;
        end
        else begin
            rx_r0 <= rx;
            rx_r1 <= rx_r0;
            rx_r2 <= rx_r1;
        end
    end

    //下降沿检测
    assign nedge = (~rx_r1)&&rx_r2;

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
                if (start2receive) begin
                    nstate = RECEIVE;
                end
                else if (start2idle) begin
                    nstate = IDLE;
                end
                else begin
                    nstate = START;
                end
            end
            RECEIVE :begin
                if (receive2stop) begin
                    nstate = STOP;
                end
                else begin
                    nstate = RECEIVE;
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
    assign idle2start       = cstate == IDLE    && (nedge                           );
    assign start2receive    = cstate == START   && (end_cnt_baud  && check          );
    assign start2idle       = cstate == START   && (check == 1'b0                   );
    assign receive2stop     = cstate == RECEIVE && (end_cnt_bit                     );
    assign stop2idle        = cstate == STOP    && (end_cnt_baud  || check == 1'b0  );

    //第三段状态机
    //校验位切换
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            choose <= 2'd0;
        end
        else begin
            if (add_choose) begin
                if (end_choose) begin
                    choose <= 2'd0;
                end
                else begin
                    choose <= choose + 2'd1;
                end
            end
            else begin
                choose <= choose;
            end
        end
    end
    

    assign add_choose = cstate == IDLE && key;
    assign end_choose = add_choose && choose == 2'd2;

    //接收bit计数器
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt_bit <= 4'd0;
        end
        else if (check == 1'b0) begin
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

    assign add_cnt_bit = (cstate == RECEIVE) && end_cnt_baud;
    //choose为0无校验位，位宽为BIT_W- 1，choose为1或者2都有检验为，位宽为BIT_W
    assign end_cnt_bit = add_cnt_bit && ((choose== 2'b0) ?( (cnt_bit == BIT_W -1) ? 1'b1:1'b0 ) :( (cnt_bit == BIT_W ) ? 1'b1:1'b0 ));

    //接收数据保存
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_data <= 8'd0;
        end
        else if (check == 1'b0) begin
            rx_data <= 8'd0;
        end
        else begin
            case (cstate)
                IDLE    : begin
                    rx_data <= 8'h00;
                end
                START   : begin
                    rx_data <= 8'h00;
                end
                RECEIVE : begin
                    if (cnt_baud == HALF_BAUD) begin
                        rx_data[cnt_bit] = rx_r2;
                    end
                    else begin
                        rx_data <= rx_data;
                    end
                end
                STOP    : begin
                    rx_data <= rx_data;
                end
                default: rx_data <= rx_data; 
            endcase
        end
    end

    //进行数据检测，要求在START状态满足低电平，在STOP状态满足高电平，同时满足奇校验。check高电平表示正确，低电平表示错误
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            check <= 1'd1;
        end
        else begin
            case (cstate)
                IDLE,RECEIVE    : check <= 1'b1;
                START   : begin
                    if (cnt_baud == HALF_BAUD) begin
                        if (rx_r2 == 1'b0) begin
                            check <= 1'b1;
                        end
                        else begin
                            check <= 1'b0;
                        end
                    end
                    else begin
                        check <= check;
                    end
                end
                STOP    : begin
                    if (cnt_baud == HALF_BAUD) begin
                        if (rx_r2 == 1'b1) begin
                            check <= 1'b1;
                        end
                        else begin
                            check <= 1'b0;
                        end
                    end
                    else if ((choose != 2'd0) && (check_bit != rx_data[BIT_W])) begin
                        check <= 1'b0;
                    end
                    else begin
                        check <= check;
                    end
                end
                default: check <= check;
            endcase
        end
    end

    //接收结束
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_done <= 1'b0;
        end
        else if (cstate == IDLE) begin
            rx_done <= 1'b0;
        end
        else if(cstate == STOP && end_cnt_baud) begin
            rx_done <=  1'b1;
        end
        else begin
            rx_done <= rx_done;
        end
    end

    //波特率计数
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt_baud <= 24'd0;
        end
        else if (cstate == IDLE) begin
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


endmodule