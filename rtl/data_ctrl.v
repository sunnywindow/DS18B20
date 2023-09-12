/*---------------------------------------------------------------	
            module		:                   						
            create_time	:                  							
            name		:yanghaidong       							
----------------------------------------------------------------*/
module data_ctrl(
    input	wire		    clk		    ,
    input	wire		    rst_n	    ,
    //输入信号
    input   wire            rx          ,
    input   wire            sign        ,
    input	wire	[24:0]  temp_data   ,
    //输出信号
    output  reg     [1:0]   ratio_num   ,
    output  reg             ratio_en    ,
    output	wire			tx	
);
    //内部信号
    parameter TIME_1s   = 28'd49_999_999;
    parameter BIT_NUM   = 5'd16;
    localparam 
                ASCII0  = 8'h30,//0
                ASCII1  = 8'h31,//1
                ASCII2  = 8'h32,//2
                ASCII3  = 8'h33,//3
                ASCII4  = 8'h34,//4
                ASCII5  = 8'h35,//5
                ASCII6  = 8'h36,//6
                ASCII7  = 8'h37,//7
                ASCII8  = 8'h38,//8
                ASCII9  = 8'h39,//9
                ASCIIdot= 8'h2e,//.
                ASCIIhx = 8'h0A,// /n
                ASCIIw  = 8'hCE,//温
                ASCIIe  = 8'hC2,
                ASCIId  = 8'hB6,//度
                ASCIIu  = 8'hC8,
                ASCIImh = 8'h3A,//:
                ASCIISHE= 8'hA1,//℃
                ASCIISHI= 8'hE6,//
                ASCIIA  = 8'h41,//A
                ASCIIB  = 8'h42,//B
                ASCIIC  = 8'h43,//C
                ASCIIa  = 8'h61,//a
                ASCIIb  = 8'h62,//b
                ASCIIc  = 8'h63,//c
                ASCIIFU = 8'h2D,//-
                ASCIIZHE= 8'h2B;//+

    reg             tx_start        ;           
    reg     [7:0]   tx_data         ;
    wire            tx_done         ;
    wire            tx_idle         ;
    wire    [1:0]   choose          ;
    wire            rx_done         ;
    wire    [7:0]   rx_data         ;
    reg     [7:0]   rx_data_r       ;

    reg     [5:0]   cnt_bit         ;
    wire            add_cnt_bit     ;
    wire            end_cnt_bit     ;

    reg     [27:0]  cnt_1s          ;//每1s存1个数据
    wire            add_cnt_1s      ;
    wire            end_cnt_1s      ;

    reg     [24:0]  temp_data_r     ;//寄存温度数据，全部发送完成再读下一个
    reg     [7:0]   number          ;

    reg             start_flag      ;


    //模块例化
    uart_rx#(
        .CLK_FREQ   (50_000_000 ), //时钟频率
        .BIT_W      (8          )
    )uart_rx_inst(
        /* input	wire		     */ .clk        (clk            ),
        /* input	wire		     */ .rst_n      (rst_n          ),
        /* input	wire             */ .rx         (rx             ),
        /* input	wire	[23:0]   */ .BAUD       (115200         ), //波特率(bps)
        /* input    wire             */ .key        (1'b0           ),
        /* input    wire             */ .tx_idle    (tx_idle        ),
        /* output   reg     [1:0]    */ .choose     (choose         ),
        /* output	reg     [7:0]    */ .rx_data    (rx_data        ),
        /* output	reg		    	 */ .rx_done    (rx_done        )
    );

    uart_tx#(
        .CLK_FREQ   (28'd50_000_000 ), //时钟频率
        .BIT_W      (4'd8           )
    )uart_tx_inst(
        /* input	wire		     */ .clk        (clk            ),
        /* input	wire		     */ .rst_n	    (rst_n	        ),
        /* input	wire	[23:0]   */ .BAUD       (115200         ), //波特率(bps)
        /* input	wire             */ .tx_start   (tx_start       ),
        /*input	    wire    [1:0]    */ .choose     (choose         ),
        /* input	wire    [7:0]    */ .tx_data    (tx_data        ),
        /* output	reg		    	 */ .tx_idle    (tx_idle        ),//发送状态，1为空闲，0为正在发送
        /*output  reg                */ .tx_done    (tx_done        ),//发送结束
        /* output	reg		    	 */ .tx	    	(tx	    	    )
    );

    //内部逻辑
    //保存输入数据
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_data_r <= 8'h0;
        end
        else if (rx_done) begin
            rx_data_r <= rx_data;
        end
        else begin
            rx_data_r <= rx_data_r;
        end
    end
    //根据输入值判断分辨率
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ratio_num <= 2'd0;
        end
        else begin
            case (rx_data_r)
                ASCII9: ratio_num <= 2'd3;
                ASCIIA,ASCIIa: ratio_num <= 2'd2;
                ASCIIB,ASCIIb: ratio_num <= 2'd1;
                ASCIIC,ASCIIc: ratio_num <= 2'd0;
                default: ratio_num <= ratio_num;
            endcase
        end
    end
    //分辨率改变使能
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ratio_en <= 1'b0;
        end
        else if (rx_done) begin
            ratio_en <= 1'b1;
        end
        else begin
            ratio_en <= 1'b0;
        end
    end
    //1s计数器
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt_1s <= 28'd0;
        end
        else begin
            if (add_cnt_1s) begin
                if (end_cnt_1s) begin
                    cnt_1s <= 28'd0;
                end
                else begin
                    cnt_1s <= cnt_1s + 28'd1;
                end
            end
            else begin
                cnt_1s <= cnt_1s;
            end
        end
    end
    assign add_cnt_1s = 1'b1;
    assign end_cnt_1s = add_cnt_1s && cnt_1s == TIME_1s;

    //发送开始信号
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx_start <= 1'b0;
        end
        else if (end_cnt_bit) begin
            tx_start <= 1'b0;
        end
        else if (end_cnt_1s) begin
            tx_start <= 1'b1;
        end
        else begin
            tx_start <= tx_start;
        end
    end
    //寄存温度数据
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            temp_data_r <= 25'd0;
        end
        else if(end_cnt_bit) begin
            temp_data_r <= temp_data;
        end
        else begin
            temp_data_r <= temp_data_r;
        end
    end
    //发送当前bit计数器
    always @(posedge clk or negedge rst_n)begin 
		if(!rst_n)begin
			start_flag <= 1'b0;
		end  
		else if(end_cnt_bit)begin
			start_flag <= 1'b0;
		end  
		else if(tx_start)begin
			start_flag <= 1'b1;
		end
		else begin
			start_flag <= start_flag;
		end
	end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt_bit <= 5'd0;
        end
        else begin
            if (add_cnt_bit) begin
                if (end_cnt_bit) begin
                    cnt_bit <= 5'd0;
                end
                else begin
                    cnt_bit <= cnt_bit + 5'd1;
                end
            end
            else begin
                cnt_bit <= cnt_bit;
            end
        end
    end

    assign add_cnt_bit = tx_done && start_flag;
    assign end_cnt_bit = add_cnt_bit && cnt_bit == BIT_NUM - 1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            number <= 5'd0;
        end
        else begin 
            case (cnt_bit)
                5'd0    : number = 8'd30;//温
                5'd1    : number = 8'd31;
                5'd2    : number = 8'd32;//度
                5'd3    : number = 8'd33;
                5'd4    : number = 8'd34;//：
                5'd5    : number = sign?8'd37:8'd38;//+\-
                5'd6    : number = temp_data_r / 100000     ;
                5'd7    : number = temp_data_r / 10000  % 10;
                5'd8    : number = 8'd20;//.
                5'd9    : number = temp_data_r / 1000   % 10;
                5'd10   : number = temp_data_r / 100    % 10;
                5'd11   : number = temp_data_r / 10     % 10;
                5'd12   : number = temp_data_r          % 10;
                5'd13   : number = 8'd35;//℃
                5'd14   : number = 8'd36;
                5'd15   : number = 8'd21;//换行
                default: number = number;
            endcase
        end
    end

    always @(*) begin
        case (number)
            8'd0    : tx_data <= ASCII0     ;
            8'd1    : tx_data <= ASCII1     ;
            8'd2    : tx_data <= ASCII2     ;
            8'd3    : tx_data <= ASCII3     ;
            8'd4    : tx_data <= ASCII4     ;
            8'd5    : tx_data <= ASCII5     ;
            8'd6    : tx_data <= ASCII6     ;
            8'd7    : tx_data <= ASCII7     ;
            8'd8    : tx_data <= ASCII8     ;
            8'd9    : tx_data <= ASCII9     ;
            8'd20   : tx_data <= ASCIIdot   ;
            8'd21   : tx_data <= ASCIIhx    ;
            8'd30   : tx_data <= ASCIIw     ;
            8'd31   : tx_data <= ASCIIe     ;
            8'd32   : tx_data <= ASCIId     ;
            8'd33   : tx_data <= ASCIIu     ;
            8'd34   : tx_data <= ASCIImh    ;
            8'd35   : tx_data <= ASCIISHE   ;
            8'd36   : tx_data <= ASCIISHI   ;
            8'd37   : tx_data <= ASCIIFU    ;
            8'd38   : tx_data <= ASCIIZHE   ;
            default: tx_data <= 8'h0;
        endcase
    end
endmodule