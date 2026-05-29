import bfm_types_pkg::apb_seq_item_s;

interface apb_monitor_bfm (apb_if intf);

    task wait_hs (output apb_seq_item_s item);
        forever begin
            @(posedge intf.clk);
            if (intf.psel && intf.penable) begin
                item.paddr   = intf.paddr;
                item.pwrite  = intf.pwrite;
                item.pwdata  = intf.pwdata;
                item.prdata  = intf.prdata;
                item.pslverr = intf.pslverr;
                return;
            end
        end
    endtask

endinterface
    