import bfm_types_pkg::axis_m_drv_seq_item_s;

interface axis_monitor_bfm (axis_if intf);

    task wait_hs (output axis_m_drv_seq_item_s item);
        forever begin
            @(posedge intf.clk);
            if (intf.tvalid && intf.tready) begin
                item.tdata   = intf.tdata;
                item.is_last = intf.tlast;
                return;
            end
        end
    endtask

    task wait_last_elem;
        wait (intf.tvalid && intf.tlast);
    endtask

endinterface