/*---------------------------------------------------------------	
                tb_module:                   						
                create_time:                  						
                name:yanghaidong       								
----------------------------------------------------------------*/
`timescale 1ns/1ns
module data_ctrl_tb();
    //内部信号
    parameter	        CYCLE = 20  ;
    reg		            clk		    ; 
    reg		            rst_n	    ;
    reg     [24:0]      temp_data   ;
    wire                tx          ;

    //模块例化
    data_ctrl  data_ctrl_inst(
    /* input	wire		  */        .clk        (clk	        ),
    /* input	wire		  */        .rst_n      (rst_n	        ),
    /* input	wire	[24:0]*/        .temp_data  (temp_data      ),
    // /* input    wire          */        .tx_idle    (tx_idle        ),
    // /* input    wire          */        .tx_done    (tx_done        ),
    // /* output	reg		[7:0] */	    .tx_data    (tx_data        ),
    // /*output	reg		      */        .tx_start	(tx_start       )
    /* /*output	wire          */        .tx         (tx             )
    );
    defparam data_ctrl_inst.TIME_1s = 999_999;
    //测试逻辑
    initial begin
        clk		    = 1'b0;
        rst_n	    = 1'b0;
        temp_data   = 25'h0;
    end

    always #(CYCLE/2) clk = ~clk;

    initial begin
        #(CYCLE+3) rst_n = 1'b1;
        temp_data = 25'd274527;
        // wait(data_ctrl_inst.end_cnt_bit);

        #(CYCLE * 10000000);
        // temp_data = 25'd294527;
        // wait(data_ctrl_inst.end_cnt_bit);
        $stop(2);
    end
endmodule