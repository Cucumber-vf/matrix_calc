interface apb_monitor_bfm (input clk, input rst_n);

    // APB_if
    logic        psel;
    logic        penable;
    logic        pwrite;
    logic [7:0]  paddr;
    logic [31:0] pwdata;

    logic [31:0] prdata;
    logic        pready;      
    logic        pslverr;

    apb_monitor mon;

    task run ();
        apb_seq_item item;
        forever begin
            @(posedge clk);
            if (psel && penable) begin
                item = apb_seq_item::type_id::create("apb_seq_item");
                item.pwrite  = pwrite;
                item.pwdata  = pwdata;
                item.prdata  = prdata;
                item.pslverr = pslverr;
                mon.notify_seq_item(item);
            end
        end
    endtask

endinterface
    