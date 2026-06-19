import bfm_types_pkg::axis_seq_item_s;

interface axis_monitor_bfm (axis_if intf);

    time tvalid_start;
    bit  was_tvalid;

    task wait_hs (int clk_period, output axis_seq_item_s item);
        was_tvalid = 0;
        forever begin
            @(posedge intf.clk);
            if (intf.tvalid && ~was_tvalid) begin
                tvalid_start = $time;
                was_tvalid = 1;
            end
            if (intf.tvalid && intf.tready) begin
                item.tdata   = intf.tdata;
                item.is_last = intf.tlast;
                item.delay   = ($time - tvalid_start)/clk_period;
                return;
            end
        end
    endtask

    task wait_for_tvalid_assert();
        @(posedge intf.tvalid);
    endtask

    task wait_for_tvalid_deassert();
        @(negedge intf.tvalid);
    endtask

    task wait_for_tready_assert();
        @(posedge intf.tready);
    endtask

    task wait_for_tready_deassert();
        @(negedge intf.tready);
    endtask

    //================================================

    task wait_last_elem_hs;
        forever begin
            @(posedge intf.clk);
            if (intf.tvalid && intf.tready && intf.tlast) return;
        end
    endtask

    task wait_elem_hs;
        forever begin
            @(posedge intf.clk);
            if (intf.tvalid && intf.tready) return;
        end
    endtask

endinterface