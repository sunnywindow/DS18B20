/*---------------------------------------------------------------	
            module		:                   						
            create_time	:                  							
            name		:yanghaidong       							
----------------------------------------------------------------*/
module one_wire(
    input	wire		    clk		,
    input	wire		    rst_n	,
    //输入信号
    input	wire	[1:0]   cmd	    ,
    input	wire            dq_in	,
    input   wire    [7:0]   data    ,
    //输出信号
    output  reg     [2:0]   cmd_ok  ,
    output  reg     [15:0]  rec_data,
    output  reg             end_init,
    output  reg             end_bit ,
    output	reg             dq_out	,
    output	reg		        dq_oe	        	
);
    //内部信号
    parameter   TIME_1000us = 16'd49999 ;//1000us
    parameter   TIME_500us  = 16'd24999 ;//500us
    parameter   TIME_80us   = 12'd3999  ;//80us
    parameter   TIME_70us   = 12'd3499  ;//70us
    parameter   TIME_60us   = 12'd2999  ;//60us
    parameter   TIME_12us   = 12'd599   ;//12us
    parameter   TIME_7us    = 12'd349   ;//7us
    parameter   TIME_3us    = 8'd150    ;//3us

    //init状态
    //状态总计数器
    reg     [15:0]  cnt_1000us      ;
    wire            add_cnt_1000us  ;
    wire            end_cnt_1000us  ;
    //ds18b20拉低至少60us总线
    reg     [15:0]  cnt_60us        ;
    wire            add_cnt_60us    ;
    wire            end_cnt_60us    ;

    //dq_out发送数据
    reg     [15:0]  cnt_us          ;//us计数器
    wire            add_cnt_us      ;
    wire            end_cnt_us      ;

    reg     [3:0]   cnt_bit         ;//bit计数器
    wire            add_cnt_bit     ;
    wire            end_cnt_bit     ;

    reg             start_flag      ;//us计数器开始标志
    reg     [1:0]   cmd_r           ;//

    reg             cnt_byte        ;//接收16bit数据，第8bit数据接收完成时拉高。

    //内部逻辑
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cmd_r <= 2'd0;
        end
        else begin
            case (cmd)
                2'd0: cmd_r <= cmd_r;
                2'd1: cmd_r <= 2'd1 ;
                2'd2: cmd_r <= 2'd2 ;
                2'd3: cmd_r <= 2'd3 ;
                default: cmd_r <= 2'd0;
            endcase
        end
    end
    //INIT
    //1000ms计数器
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt_1000us <= 16'd0;
        end
        else if (cmd_r != 2'd1) begin
            cnt_1000us <= 16'd0;
        end
        else begin
            if (add_cnt_1000us) begin
                if (end_cnt_1000us) begin
                    cnt_1000us <= 16'd0;
                end
                else begin
                    cnt_1000us <= cnt_1000us + 16'd1;
                end
            end
            else begin
                cnt_1000us <= cnt_1000us;
            end
        end
    end

    assign add_cnt_1000us = cmd_r == 2'd1;
    assign end_cnt_1000us = add_cnt_1000us && cnt_1000us == TIME_1000us;

    //60us计数器
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt_60us <= 16'd0;
        end
        else if (cmd_r != 2'd1) begin
            cnt_60us <= 16'd0;
        end
        else begin
            if (add_cnt_60us) begin
                if (end_cnt_60us) begin
                    cnt_60us <= 16'd0;
                end
                else begin
                    cnt_60us <= cnt_60us + 16'd1;
                end
            end
            else begin
                cnt_60us <= cnt_60us;
            end
        end
    end

    assign add_cnt_60us = cnt_1000us > TIME_500us && dq_in == 1'b0;
    assign end_cnt_60us = add_cnt_60us && end_cnt_1000us;

    //打一拍输出初始化结束标志信号
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            end_init <= 1'b0;
        end
        else if (end_cnt_1000us) begin
            end_init <= 1'b1;
        end
        else begin
            end_init <= 1'b0;
        end
    end

    //发送数据
    //us计数器开始标志
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            start_flag <= 1'b0;
        end
        else if (end_cnt_bit) begin
            start_flag <= 1'b0;
        end
        else if (cnt_byte) begin
            start_flag <= 1'b1;
        end
        else if (cmd == 2'd2 || cmd == 2'd3) begin
            start_flag <= 1'b1;
        end
        else begin
            start_flag <= start_flag;
        end
    end
    //us计数器
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt_us <= 15'd0;
        end
        else begin
            if (add_cnt_us) begin
                if (end_cnt_us) begin
                    cnt_us <= 15'd0;
                end
                else begin
                    cnt_us <= cnt_us + 15'd1;
                end
            end
            else begin
                cnt_us <= cnt_us;
            end
        end
    end

    assign add_cnt_us = start_flag;
    assign end_cnt_us = add_cnt_us && cnt_us == TIME_80us;

    // bit计数器
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt_bit <= 3'd0;
        end
        else if (add_cnt_bit) begin
            if (end_cnt_bit) begin
                cnt_bit <= 3'd0;
            end
            else begin
                cnt_bit <= cnt_bit + 3'd1;
            end
        end
        else begin
            cnt_bit <= cnt_bit;
        end
    end
    assign add_cnt_bit = end_cnt_us;
    assign end_cnt_bit = add_cnt_bit && cnt_bit >= 3'd7;

    //打一拍传输8bit数据结束
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            end_bit <= 1'b0;
        end
        else if (end_cnt_bit) begin
            end_bit <= 1'b1;
        end
        else begin
            end_bit <= 1'b0;
        end
    end
    //发送8bit
    always @(*) begin
        if (cmd_r == 2'd1) begin
            if (cnt_1000us <= TIME_500us) begin
                dq_oe   = 1'b1;
                dq_out  = 1'b0;
            end
            else begin
                dq_oe   = 1'b0;
                dq_out  = 1'bz;
            end
        end
        else if (cmd_r == 2'd2) begin
            if (data[cnt_bit]) begin // 发送1
                if (cnt_us <= TIME_7us) begin // 7um低电平
                    dq_oe  = 1'b1;
                    dq_out = 1'b0;
                end
                else begin
                    dq_oe  = 1'b0;
                    dq_out = 1'bz;
                end
            end
            else begin // 发送0
                if (cnt_us <= TIME_70us) begin // 前70um低电平
                    dq_oe  = 1'b1;
                    dq_out = 1'b0;
                end
                else begin
                    dq_oe  = 1'b0;
                    dq_out = 1'bz; // 后10um高阻态
                end
            end
        end
        else if (cmd_r == 2'd3) begin
            if (cnt_us <= TIME_3us) begin
                dq_oe  = 1'b1;
                dq_out = 1'b0;
            end
            else begin
                dq_oe  = 1'b0;
                dq_out = 1'bz;
            end
        end
        else begin
            dq_oe  = 1'b0;
            dq_out = 1'bz;
        end
    end

    //接收16bit温度数据
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt_byte <= 1'b0;
        end
        else if (cmd_r != 2'd3) begin
            cnt_byte <= 1'b0;
        end
        else if (end_cnt_bit && cmd_r == 2'd3) begin
            cnt_byte <= ~cnt_byte;
        end
        else begin
            cnt_byte <= cnt_byte;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rec_data <= 16'd0;
        end
        else if (cmd_r == 2'd3) begin
            if (cnt_us == TIME_12us) begin
                case (cnt_byte)
                    1'b0: rec_data[cnt_bit] <= dq_in;
                    1'b1: rec_data[ 8 + cnt_bit] <= dq_in;   
                    default: rec_data <= 16'd0;
                endcase
            end
        end
    end

    //命令完成情况
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cmd_ok <= 2'd0;
        end
        else if (cmd_r == 2'd1) begin
            if (end_cnt_1000us && cnt_60us >= TIME_60us) begin
                cmd_ok[0] <= 1'b1;
            end
            else begin
                cmd_ok <= 2'd0;
            end
        end
        else if (cmd_r == 2'd2) begin
            if (end_cnt_bit) begin
                cmd_ok[1] <= 1'b1;
            end
            else begin
                cmd_ok <= 2'd0;
            end
        end
        else if (cmd_r == 2'd3) begin
            if (cnt_byte && end_cnt_bit) begin
                cmd_ok[2] <= 1'b1;
            end
            else begin
                cmd_ok <= 2'd0;
            end
        end
        else begin
            cmd_ok <= 2'd0;
        end
    end

endmodule