/*---------------------------------------------------------------*/
/*----------------module:                  ----------------------*/
/*-----------create_time:                  ----------------------*/
/*------------------name:yanghaidong       ----------------------*/
/*---------------------------------------------------------------*/
module seg_driver(
    input	wire		    clk		    ,
    input	wire		    rst_n	    ,
    //输入信号
    input   wire    [24:0]  seg_value   ,
    input   wire    [5:0]   dot         ,
    //输出信号
    output	reg     [7:0]	sel	        ,
    output	reg		[7:0]	seg	
);
    //内部信号
    parameter   TIME_200us   = 9999;

    localparam  N0          = 8'b1100_0000  ,
                N1          = 8'b1111_1001  ,
                N2          = 8'b1010_0100  ,
                N3          = 8'b1011_0000  ,
                N4          = 8'b1001_1001  ,
                N5          = 8'b1001_0010  ,
                N6          = 8'b1000_0010  ,
                N7          = 8'b1111_1000  ,
                N8          = 8'b1000_0000  ,
                N9          = 8'b1001_0000  ,
                NA          = 8'b1000_1000  ,
                NB          = 8'b1000_0011  ,
                NC          = 8'b1100_0110  ,
                ND          = 8'b1010_0001  ,
                NE          = 8'b1000_0110  ,
                NF          = 8'b1000_1110  ;
            
    //200us计数器
    reg     [25:0]  cnt_200us        ;
    wire            add_cnt_200us    ;
    wire            end_cnt_200us    ;
    reg             dot_r           ;

    //数码管显示数字
    wire    [3:0] 	sel0            ;//数码管0显示数字
    wire    [3:0] 	sel1            ;//数码管1显示数字
    wire    [3:0] 	sel2            ;//数码管2显示数字
    wire    [3:0] 	sel3            ;//数码管3显示数字
    wire    [3:0] 	sel4            ;//数码管4显示数字
    wire    [3:0] 	sel5            ;//数码管5显示数字
    reg     [4:0]   number          ;

    //内部逻辑
    //200us计数器，用于数码管位选切换
    always@(posedge clk or negedge rst_n)begin
        if (!rst_n) begin
            cnt_200us <= 26'd0;
        end
        else begin
            if (add_cnt_200us) begin
                if (end_cnt_200us) begin
                    cnt_200us <= 26'd0;
                end
                else begin
                    cnt_200us <= cnt_200us + 26'd1;
                end
            end
            else begin
                cnt_200us <= cnt_200us;
            end
        end
    end

    assign add_cnt_200us = 1'b1;
    assign end_cnt_200us = add_cnt_200us && cnt_200us == TIME_200us;


    //位选信号切换模块
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            sel <= 8'b00_000_001;               //初始化第一个数码管亮
        end 
        else if(end_cnt_200us)begin
            sel<={sel[6:0],sel[7]};      //每隔200us进行位移操作
        end 
        else begin
            sel <= sel;                     //其他时间保持不变
        end 
    end

    assign sel0    = seg_value % 10             ;   //从右向左数第一位
    assign sel1    = seg_value /10      % 10    ;   //从右向左数第二位
    assign sel2    = seg_value /100     % 10    ;   //从右向左数第三位
    assign sel3    = seg_value /1000    % 10    ;   //从右向左数第四位
    assign sel4    = seg_value /10000   % 10    ;   //从右向左数第五位
    assign sel5    = seg_value /100000          ;   //从右向左数第六位

    //确定number数值以及小数点位置。
    always @(*) begin
        case(sel)
            8'b00_000_001: begin
                number = sel0   ;
                dot_r = dot[5];
            end
            8'b00_000_010: begin
                number = sel1   ;
                dot_r = dot[4]  ;
            end
            8'b00_000_100: begin
                number = sel2   ;
                dot_r = dot[3]  ;
            end
            8'b00_001_000: begin
                number = sel3   ;
                dot_r = dot[2]  ;
            end
            8'b00_010_000: begin
                number = sel4   ;
                dot_r = dot[1]  ;
            end
            8'b00_100_000: begin
                number = sel5   ;
                dot_r = dot[0]  ;
            end
            default: begin   
                number = 4'd0  ;
                dot_r = 1'b1;
            end
        endcase 
    end

    //段选信号译码模块
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            seg <= N0;//初始化显示0
        end
        else begin
            case(number)
                5'd0    :	seg <= {dot_r,N0[6:0]};     
                5'd1    :	seg <= {dot_r,N1[6:0]};     
                5'd2    : 	seg <= {dot_r,N2[6:0]};     
                5'd3    : 	seg <= {dot_r,N3[6:0]};     
                5'd4    : 	seg <= {dot_r,N4[6:0]};     
                5'd5    : 	seg <= {dot_r,N5[6:0]};     
                5'd6    : 	seg <= {dot_r,N6[6:0]};     
                5'd7    : 	seg <= {dot_r,N7[6:0]};     
                5'd8    : 	seg <= {dot_r,N8[6:0]};     
                5'd9    :   seg <= {dot_r,N9[6:0]};     
                5'd10   :   seg <= {dot_r,NA[6:0]};
                5'd11   :   seg <= {dot_r,NB[6:0]};
                5'd12   :   seg <= {dot_r,NC[6:0]};
                5'd13   :   seg <= {dot_r,ND[6:0]};
                5'd14   :   seg <= {dot_r,NE[6:0]};
                5'd15   :   seg <= {dot_r,NF[6:0]};
                default:	seg <= {dot_r,N0[6:0]};     
            endcase 
        end
        
    end


endmodule