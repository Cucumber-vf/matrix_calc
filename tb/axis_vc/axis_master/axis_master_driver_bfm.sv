interface axis_master_driver_bfm #(parameter DATA_W = 16) (input clk, input rst_n);

    // AXIS Slave Interface
    logic signed [DATA_W-1:0] s_tdata;
    logic                     s_tvalid;
    logic                     s_tlast;
    logic                     s_tready;

    task axis_master_rst;
        s_tvalid <= 0;
        s_tlast  <= 0;
    endtask

    task drive (axis_seq_item item);
        @(posedge clk or negedge rst_n);
        if (~rst_n) begin
            axis_master_reset;
            wait(rst_n);
            @(posedge clk)
        end
        s_tvalid <= 1;
        s_tdata  <= item.tdata;
        s_tlast  <= item.is_last;
        do begin
            @(posedge clk);
        end while(~s_tready);
        s_tvalid <= 0;
        s_tlast  <= 0;
    endtask

endinterface