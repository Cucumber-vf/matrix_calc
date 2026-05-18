interface axis_master_monitor_bfm #(parameter DATA_W = 16) (input clk, input rst_n);

    // AXIS Slave Interface
    logic signed [DATA_W-1:0] s_tdata;
    logic                     s_tvalid;
    logic                     s_tlast;
    logic                     s_tready;

    axis_master_monitor mon;

    task run ();
        axis_seq_item item;
        forever begin
            @(posedge clk)
            if (s_tvalid && s_tready) begin
                item = axis_seq_item::type_id::create("axis_seq_item");
                item.tdata   = s_tdata;
                item.is_last = s_tlast;
                mon.notify_seq_item(item);
            end
        end
    endtask

endinterface