interface axis_slave_monitor_bfm #(parameter DATA_W = 16) (input clk, input rst_n);

    // AXIS Master Interface
    logic signed [DATA_W-1:0] m_tdata;
    logic                     m_tvalid;
    logic                     m_tlast;
    logic                     m_tready;

    axis_slave_monitor mon;

    task run ();
        axis_seq_item item;
        forever begin
            @(posedge clk)
            if (m_tvalid && m_tready) begin
                item = axis_seq_item::type_id::create("axis_seq_item");
                item.tdata   = m_tdata;
                item.is_last = m_tlast;
                mon.notify_seq_item(item);
            end
        end
    endtask

endinterface