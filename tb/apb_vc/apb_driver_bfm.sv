interface apb_driver_bfm (input clk, input rst_n);

    // APB_if
    logic        psel;
    logic        penable;
    logic        pwrite;
    logic [7:0]  paddr;
    logic [31:0] pwdata;

    logic [31:0] prdata;
    logic        pready;      
    logic        pslverr;

    task apb_reset ();
        penable <= 0;
        psel    <= 0;
        pwrite  <= 0;
    endtask
    
    task drive (apb_seq_item item);
        @(posedge clk or negedge rst_n);
        if (~rst_n) begin
            apb_reset;
            wait(rst_n);
            @(posedge clk)
        end
        penable <= 0;
        psel    <= 1;
        pwrite  <= item.pwrite;
        if (item.pwrite) begin
            pwdata  <= item.pwdata;
        end
        @(posedge clk);
        penable <= 1;
        do begin
            @(posedge clk);
        end while (~pready);
        item.prdata  = prdata;
        item.pslverr = pslverr;
        penable <= 0;
        psel    <= 0;
    endtask

endinterface