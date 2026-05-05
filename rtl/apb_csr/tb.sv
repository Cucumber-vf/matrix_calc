module tb;
    //======= Signals ===================================

    logic        clk;
    logic        rst_n; 
     
    //
    logic        psel;
    logic        penable;
    logic        pwrite;
    logic [7:0]  paddr;
    logic [31:0] pwdata;

    logic [31:0] prdata;
    logic        pready;       
    logic        pslverr;

    //
    logic [1:0]  op;
    logic        start;
    logic        flush;
    
    logic        done_i;
    logic        busy_i;
    logic        overflow_i;
    logic        singular_i;
    logic        rx_err_i;

    //======= DUT and drv ===============================

    apb_csr u_apb_csr (
        .clk        (clk       ),
        .rst_n      (rst_n     ),
        .psel       (psel      ),
        .penable    (penable   ),
        .pwrite     (pwrite    ),
        .paddr      (paddr     ),
        .pwdata     (pwdata    ),
        .prdata     (prdata    ),
        .pready     (pready    ),
        .pslverr    (pslverr   ),
        .op         (op        ),
        .start      (start     ),
        .done_i     (done_i    ),
        .busy_i     (busy_i    ),
        .overflow_i (overflow_i),
        .singular_i (singular_i),
        .rx_err_i   (rx_err_i  )
    );

    apb_m_drv apb_drv (
        .clk        (clk       ),
        .rst_n      (rst_n     ),
        .psel       (psel      ),
        .penable    (penable   ),
        .pwrite     (pwrite    ),
        .paddr      (paddr     ),
        .pwdata     (pwdata    ),
        .prdata     (prdata    ),
        .pready     (pready    ),
        .pslverr    (pslverr   )
    );

    //======= Clock and Reset gen =======================

    // Clock and Reset gen
    initial begin
        clk <= 0;
        forever begin
            #(T/2) clk <= ~clk;
        end
    end 

    initial begin
        @(posedge clk);
        rst_n <= 0;
        @(posedge clk);
        rst_n <= 1;
    end

    //======= TEST ======================================

    int addr, rdata, wdata;

    initial begin

        // ======== APB_csr direct test start ========
        // base op check (00)
        apb_drv.apb_reset();
        apb_drv.apb_read(8'h00, rdata);
        if (rdata != 0)
            $error("[APB CSR  ] ERROR: Unexpected read op value after reset: op=%02b at time %0t",
                    rdata, $time);

        // read/write check
        addr  = 8'h00;
        wdata = 2;
        apb_drv.apb_write(addr, wdata);
        apb_drv.apb_read(addr, rdata);
        if (rdata != wdata)
            $error("[APB CSR  ] ERROR: Unexpected read/write value for addr=0x%02H: wdata=0x%08H rdata = 0x%08H at time %0t",
                     addr, wdata, rdata, $time);
    
        // inv addr write check (pslverr = 1)
        apb_drv.apb_write(8'h0A, 2'd2);
        // RO reg write check (pslverr = 1)
        apb_drv.apb_write(8'h08, 2'd2);

        // inv addr write check (pslverr = 1)
        apb_drv.apb_read(8'h10, rdata);
        
        // self-reset check 
        apb_drv.apb_write(8'h04, 2'd3);
        @(posedge clk);
        if (start != 0)
            $error("[APB CSR  ] ERROR: start self_reset error at time %0t",$time);
        if (flush != 0)
            $error("[APB CSR  ] ERROR: flush self_reset error at time %0t",$time);

        @(posedge clk);

        // ======== APB_csr direct test finish =======

        $finish();
    end

endmodule