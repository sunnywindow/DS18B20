/*---------------------------------------------------------------	
            module		:                   						
            create_time	:                  							
            name		:yanghaidong       							
----------------------------------------------------------------*/
module ds18b20_ctrl(
    input	wire		    clk		    ,
    input	wire		    rst_n	    ,
    //输入信号
    inout   wire            dq          ,
    input   wire    [1:0]   ratio_num   ,//分辨率计数 0:8'h7f、1:8'h5f 、2:8'h3f、3:8'h1f
    input   wire            ratio_en    ,
    //输出信号
    output  wire            sign        ,
    output  reg     [5:0]   dot         ,
    output  reg     [24:0]  temp_data
);
    //内部信号
    parameter   TIME_750ms  = 28'd37_499_999    ;//750ms
    parameter   TIME_1ms   = 20'd49_999        ;//1ms
    localparam 
                IDLE        = 8'b00_000_001,
                INIT        = 8'b00_000_010,
                SKROM       = 8'b00_000_100,
                SET         = 8'b00_001_000,
                CONVERT     = 8'b00_010_000,
                WAIT        = 8'b00_100_000,
                READ        = 8'b01_000_000,
                READ_TEMP   = 8'b10_000_000;

    localparam 
                SKIP_ROM            =   8'hcc       ,
                WRITE_SCRATCHPAD    =   8'h4e       ,//写数据(分辨率、最高温、最低温)
                CONVERT_T           =   8'h44       ,//温度转换
                READ_SCRATCHPAD     =   8'hbe       ,//读转换的温度数据
                temp_hight          =   8'h2d       ,//报警最高温度
                temp_low            =   8'hf6       ;//报警最低温度

    reg     [7:0]   cstate,nstate   ;
    wire            idle2init       ;
    wire            init2skrom      ;
    wire            init2idle       ;

    wire            skrom2set       ;
    wire            set2idle        ;

    wire            skrom2convert   ;
    wire            convert2wait    ;
    wire            wait2idle       ;

    wire            skrom2read      ;
    wire            read2read_temp  ;
    wire            read_temp2idle  ;

    reg     [1:0]   cmd             ;//指令，cmd[1]为初始化，cmd[2]为发送命令，cmd[3]为接收数据
    wire    [2:0]   cmd_ok          ;

    wire            dq_in           ;//三态门
    wire            dq_out          ;
    wire            dq_oe           ;

    wire    [15:0]  rec_data        ;//接收的16bit初始温度数据
    reg     [7:0]   send_data       ;//发送给DS18b20的命令
    wire            end_init        ;//结束初始化
    wire            end_bit         ;//命令发送完成

    reg     [19:0]  cnt_1ms         ;//1ms计数器
    wire            add_cnt_1ms     ;
    wire            end_cnt_1ms     ;

    reg     [27:0]  cnt_750ms       ;//750ms计数器
    wire            add_cnt_750ms   ;
    wire            end_cnt_750ms   ;

    reg             convert_read    ;//0为温度转换，1为读取转换的温度。

    reg             set_flag        ;//设定分辨率
    reg     [7:0]   ratio           ;
    reg     [1:0]   set_byte        ;//设置分辨率命令byte
    wire            add_byte        ;
    wire            end_byte        ;

    //模块例化
    one_wire one_wire_inst(
    /* input	wire		     */ .clk		(clk	    ),
    /* input	wire		     */ .rst_n	    (rst_n	    ),
    /* input	wire	[1:0]    */ .cmd	    (cmd	    ),
    /* input	wire             */ .dq_in	    (dq_in	    ),
    /* input   wire    [7:0]    */  .data       (send_data  ),
    /* output  wire              */ .end_init   (end_init   ),
    /* output  wire              */ .end_bit    (end_bit    ),
    /* output  reg     [2:0]    */  .cmd_ok     (cmd_ok     ),
    /* output  reg     [16:0]   */  .rec_data   (rec_data   ),
    /* output	reg              */ .dq_out	    (dq_out	    ),
    /* output	reg		         */ .dq_oe	    (dq_oe	    )    	
    );

    //内部逻辑
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
            IDLE    :begin
                if (idle2init) begin
                    nstate = INIT;
                end
                else begin
                    nstate = IDLE;
                end
            end
            INIT    :begin
                if (init2idle) begin
                    nstate = IDLE;
                end
                else if (init2skrom) begin
                    nstate = SKROM;
                end
                else begin
                    nstate = INIT;
                end
            end
            SKROM   :begin
                if (skrom2set) begin
                    nstate = SET;
                end
                else if (skrom2convert) begin
                    nstate = CONVERT;
                end
                else if (skrom2read) begin
                    nstate = READ;
                end
                else begin
                    nstate = SKROM;
                end
            end
            SET     :begin
                if (set2idle) begin
                    nstate = IDLE;
                end
                else begin
                    nstate = SET;
                end
            end
            CONVERT :begin
                if (convert2wait) begin
                    nstate = WAIT;
                end
                else begin
                    nstate = CONVERT;
                end
            end
            WAIT    :begin
                if (wait2idle) begin
                    nstate = IDLE;
                end
                else begin
                    nstate = WAIT;
                end
            end
            READ    :begin
                if (read2read_temp) begin
                    nstate = READ_TEMP;
                end
                else begin
                    nstate = READ;
                end
            end
            READ_TEMP:begin
                if (read_temp2idle) begin
                    nstate = IDLE;
                end
                else begin
                    nstate = READ_TEMP;
                end
            end
            default: nstate = IDLE;
        endcase
    end

    assign idle2init        = cstate == IDLE        && end_cnt_1ms                  ;
    assign init2idle        = cstate == INIT        && !cmd_ok[0]    && end_init    ;
    assign init2skrom       = cstate == INIT        && cmd_ok[0]     && end_init    ;

    assign skrom2set        = cstate == SKROM       && set_flag      && end_bit     ;
    assign set2idle         = cstate == SET         && end_byte                     ;

    assign skrom2convert    = cstate == SKROM       && !convert_read && end_bit     ;
    assign convert2wait     = cstate == CONVERT     && cmd_ok[1]                    ;
    assign wait2idle        = cstate == WAIT        && end_cnt_750ms                ;

    assign skrom2read       = cstate == SKROM       && convert_read  && end_bit     ;
    assign read2read_temp   = cstate == READ        && cmd_ok[1]                    ;
    assign read_temp2idle   = cstate == READ_TEMP   && cmd_ok[2]                    ;

    //第三段状态机
    // 设置警报触发值使能信号
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            set_flag <= 1'b0;
        end
        else if (ratio_en) begin
            set_flag <= 1'b1;
        end
        else if (set2idle) begin
            set_flag <= 1'b0;
        end
        else begin
            set_flag <= set_flag;
        end
    end
    //分辨率
    always @(*) begin
        case (ratio_num)
            2'd0: ratio = 8'h7f;
            2'd1: ratio = 8'h5f;
            2'd2: ratio = 8'h3f;
            2'd3: ratio = 8'h1f;
            default: ratio = 8'h7f;
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            set_byte <= 2'd0;
        end
        else begin
            if (add_byte) begin
                if (end_byte) begin
                    set_byte <= 2'd0;
                end
                else begin
                    set_byte <= set_byte + 2'd1;
                end
            end
            else begin
                set_byte <= set_byte;
            end
        end
    end
    assign add_byte = cstate == SET && end_bit;
    assign end_byte = add_byte && set_byte == 2'd3;

    //发送数据赋值
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            send_data <= 8'h0;
        end
        else begin
            case (nstate)
                IDLE,INIT,WAIT,READ_TEMP    : send_data <= 8'h0             ;
                SKROM                       : send_data <= SKIP_ROM         ;
                CONVERT                     : send_data <= CONVERT_T        ;
                READ                        : send_data <= READ_SCRATCHPAD  ;
                SET                         :begin
                    case (set_byte)
                        2'd0: send_data <= WRITE_SCRATCHPAD ;
                        2'd1: send_data <= temp_hight       ;
                        2'd2: send_data <= temp_low         ;
                        2'd3: send_data <= ratio            ;
                        default: send_data <= send_data;
                    endcase
                end
                default : send_data <= 8'h0  ;
            endcase
        end
    end
    //cmd赋值
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cmd <= 2'd0;
        end
        else if (idle2init) begin
            cmd <= 2'd1;
        end
        else if (init2skrom || skrom2convert || skrom2read || skrom2set || add_byte) begin
            cmd <= 2'd2;
        end
        else if (read2read_temp) begin
            cmd <= 2'd3;
        end
        else begin
            cmd <= 2'd0;
        end
    end

    //1ms计数器
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt_1ms <= 20'd0;
        end
        else begin
            if (add_cnt_1ms) begin
                if (end_cnt_1ms) begin
                    cnt_1ms <= 20'd0;
                end
                else begin
                    cnt_1ms <= cnt_1ms + 20'd1;
                end
            end
            else begin
                cnt_1ms <= cnt_1ms;
            end
        end
    end

    assign add_cnt_1ms = cstate == IDLE;
    assign end_cnt_1ms = add_cnt_1ms && cnt_1ms == TIME_1ms;

    //750ms计数器
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt_750ms <= 28'd0;
        end
        else begin
            if (add_cnt_750ms) begin
                if (end_cnt_750ms) begin
                    cnt_750ms <= 28'd0;
                end
                else begin
                    cnt_750ms <= cnt_750ms + 28'd1;
                end
            end
            else begin
                cnt_750ms <= cnt_750ms;
            end
        end
    end

    assign add_cnt_750ms = cstate == WAIT;
    assign end_cnt_750ms = add_cnt_750ms && cnt_750ms == TIME_750ms;

    //先转换完温度后才能读取温度
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            convert_read <= 1'b0;
        end
        else if (set2idle) begin
            convert_read <= 1'b0;
        end
        else if (wait2idle) begin
            convert_read <= 1'b1;
        end
        else if (read_temp2idle) begin
            convert_read <= 1'b0;
        end
        else begin
            convert_read <= convert_read;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            temp_data <= 25'd0;
        end
        else if (!rec_data[15]) begin
            temp_data <= rec_data[10:0] * 11'd625 ;
            dot <= 6'b111_101;
        end
        else if (rec_data[15]) begin
            temp_data <= (~rec_data[10:0] + 1'b1)* 11'd625  ;
            dot <= 6'b111_101;
        end
        else begin
            temp_data <= temp_data;
            dot <= dot;
        end
    end

    assign dq_in = dq;
    assign dq = dq_oe ? dq_out : 1'bz;
    assign sign = rec_data[15];
endmodule