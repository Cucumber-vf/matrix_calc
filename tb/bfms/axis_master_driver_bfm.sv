import bfm_types_pkg::axis_m_drv_seq_item_s;

interface axis_master_driver_bfm (axis_if intf);

    task axis_m_reset ();
        intf.tvalid <= 0;
        intf.tlast  <= 0;

        intf.tdata  <= 'x;
    endtask

    task wait_reset ();
        wait(~intf.rst_n);
        axis_m_reset();
    endtask

    task drive (axis_m_drv_seq_item_s item);
        repeat (item.delay) @(posedge intf.clk);
        intf.tvalid <= 1;
        intf.tdata  <= item.tdata;
        intf.tlast  <= item.is_last;
        do begin
            @(posedge intf.clk);
        end while(~intf.tready);
        intf.tvalid <= 0;
        intf.tlast  <= 0;
    endtask

    task drive_txn (axis_m_drv_seq_item_s item);
        fork
            drive(item);
            wait_reset();
        join_any
        disable fork;
    endtask

endinterface