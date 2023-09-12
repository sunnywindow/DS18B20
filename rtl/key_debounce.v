module key_debounce (
    input   wire        clk     ,
    input   wire        rst_n   ,
    input   wire [3:0]  key_in  ,

    output  wire [3:0]  key_out
);
    parameter MAX_20ms = 20'd1_000_000;
    reg     [19:0] cnt_20ms ;
    reg     [3:0]  key_flag ;
    reg            start    ;   // 稳定信号开始
    reg     [3:0]  key_r0   ;  // 按键信号寄存器0
    reg     [3:0]  key_r1   ;  // 按键信号寄存器1
    wire    [3:0]  nedge    ;
    reg     [3:0]  flag     ;

    // 20ms 倒计时计数器设计
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            cnt_20ms <= 20'd0;
        end
        else if (nedge) begin
            cnt_20ms <= MAX_20ms;
        end
        else if(start) begin
            if(cnt_20ms == 1'd1)begin
                cnt_20ms <= 20'd0;
            end
            else begin
                cnt_20ms <= cnt_20ms - 1'd1; 
            end
        end
        else if(flag) begin
            cnt_20ms <= MAX_20ms;
        end
        else begin
            cnt_20ms <= cnt_20ms;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            key_r0 <= 4'b1111;
            key_r1 <= 4'b1111;
        end
        else begin
            key_r0 <= key_in;       // 打一拍，同步时钟域
            key_r1 <= key_r0;       // 打一拍，检测按键下降沿 
        end
    end

    // start 信号约束
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            start <= 1'b0;
        end
        else if(nedge) begin
            start <= 1'b1;
        end
        else if(cnt_20ms == 1'b1) begin
            start <= 1'b0;
        end
        else begin
            start <= start;
        end
    end
    // 约束 flag 信号
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            flag <= 4'b0000;
        end
        else if(cnt_20ms == 1'b1) begin
            flag <= ~key_r0;
        end
        else begin
            flag <= 4'b0000;
        end
    end

    assign nedge = ~key_r0 & key_r1;

    assign key_out = flag;
endmodule