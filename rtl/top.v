/*---------------------------------------------------------------	
            module		:                   						
            create_time	:                  							
            name		:yanghaidong       							
----------------------------------------------------------------*/
module top(
    input	wire		    clk		,
    input	wire		    rst_n	,
    inout   wire            dq      ,
    //输入信号
    input   wire            rx      ,
    //输出信号
    output  wire            tx      ,
    output  wire            SH_CP   ,
    output  wire            ST_CP   ,
    output  wire            DS      
);
    //内部信号
    wire    [1:0]   key_out     ;
    wire    [24:0]  temp_data   ;
    wire    [5:0]   dot         ;

    wire            tx_idle     ;
    wire            tx_done     ;
    wire    [7:0]   tx_data     ;
    wire            tx_start    ;

    wire    [7:0]   sel         ;
    wire    [7:0]   seg         ;

    wire    [1:0]   ratio_num   ;
    wire            ratio_en    ;
    wire            sign        ;
    //模块例化
    // key_debounce u_key_debounce (
    // /* input   wire        */           .clk                (clk                ),
    // /* input   wire        */           .rst_n              (rst_n              ),
    // /* input   wire [3:0]  */           .key_in             ({2'b11,key}        ),

    // /* output  wire [3:0]  */           .key_out            (key_out            )
    // );
    ds18b20_ctrl ds18b20_ctrl_inst(
    /* input   wire                */   .clk            (clk            ),
    /* input   wire                */   .rst_n          (rst_n          ),
    /* input   wire [1:0]          */   .ratio_num      (ratio_num      ),//分辨率计数 0:12、1:11 、2:10、3:9
    /* input   wire                */   .ratio_en       (ratio_en       ),//分辨率改变使能
    /* inout   wire                */   .dq             (dq             ),
    /* output  wire                */   .sign           (sign           ),//温度正负标志，0为正，1为负
    /* output  reg     [5:0]       */   .dot            (dot            ),//温度小数点
    /* output  reg     [24:0]      */   .temp_data      (temp_data      ) //温度数据
    );
    seg_driver seg_driver_inst(
    /* input	wire		     */     .clk		    (clk		    ),
    /* input	wire		     */     .rst_n	        (rst_n	        ),
    /* input   wire    [24:0]   */      .seg_value      (temp_data      ),//温度数据
    /* input   wire    [5:0]    */      .dot            (dot            ),//温度小数点
    /* output	reg     [7:0]	 */     .sel	        (sel	        ),//数码管位选
    /* output	reg		[7:0]	 */     .seg	        (seg	        ) //数码管段选
    );

    data_ctrl  data_ctrl_inst(
    /* input	wire		  */        .clk            (clk	        ),
    /* input	wire		  */        .rst_n          (rst_n	        ),
    /* input    wire          */        .rx             (rx             ),//以ASCII码编码方式输入9为9分辨率，a/A为10,，b/B为11，c/C为12
    /* input    wire          */        .sign           (sign           ),
    /* input	wire	[24:0]*/        .temp_data      (temp_data      ),//温度数据
    /* output	reg	    [1:0] */        .ratio_num      (ratio_num      ),//分辨率计数 0:12、1:11 、2:10、3:9
    /* output	wire          */        .ratio_en       (ratio_en       ),//分辨率改变使能
    /* output	wire          */        .tx             (tx             )
    );

    HC595_Driver u_HC595_Driver(
        .clk            (clk                ),
        .rst_n          (rst_n              ),
        .Data           ({seg,sel }         ),
        .S_EN           (1'b1               ),

        .SH_CP          (SH_CP              ),
        .ST_CP          (ST_CP              ),
        .DS             (DS                 )
    );


    //内部逻辑









endmodule