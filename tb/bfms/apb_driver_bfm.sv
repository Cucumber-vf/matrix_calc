import bfm_types_pkg::apb_seq_item_s;

interface apb_driver_bfm (apb_if intf);

    task apb_reset ();
        intf.penable <= 0;
        intf.psel    <= 0;
        intf.pwrite  <= 0;

        intf.paddr   <= 'x;
        intf.pwdata  <= 'x;
    endtask

    task wait_reset ();
        wait(~intf.rst_n);
        apb_reset();
    endtask

    task drive (inout apb_seq_item_s item);
        @(posedge intf.clk)
        intf.penable <= 0;
        intf.psel    <= 1;
        intf.pwrite  <= item.pwrite;
        intf.paddr   <= item.paddr;
        if (item.pwrite) begin
            intf.pwdata  <= item.pwdata;
        end
        @(posedge intf.clk);
        intf.penable <= 1;
        do begin
            @(posedge intf.clk);
        end while (~intf.pready);
        item.prdata  = intf.prdata;
        item.pslverr = intf.pslverr;
        intf.penable <= 0;
        intf.psel    <= 0;
    endtask

    task drive_txn (apb_seq_item_s item);
        fork
            drive(item);
            wait_reset();
        join_any
        disable fork;
        item.prdata  = intf.prdata;
        item.pslverr = intf.pslverr;
    endtask

endinterface