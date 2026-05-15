module tb_apb_csr;

    clk_bfm m_clk_bfm();
    rst_bfm m_rst_bfm();

    apb_csr_bfm m_bfm (m_clk_bfm.clk, m_rst_bfm.rst_n);

    reg_model ref_model;
    apb_csr_scrb m_scrb;

    apb_csr u_apb_csr (
        .clk        (m_clk_bfm.clk   ),
        .rst_n      (m_rst_bfm.rst_n ),

        .psel       (m_bfm.psel      ),
        .penable    (m_bfm.penable   ),
        .pwrite     (m_bfm.pwrite    ),
        .paddr      (m_bfm.paddr     ),
        .pwdata     (m_bfm.pwdata    ),
        .prdata     (m_bfm.prdata    ),
        .pready     (m_bfm.pready    ),
        .pslverr    (m_bfm.pslverr   ),

        .op         (m_bfm.op        ),
        .start      (m_bfm.start     ),
        .flush      (m_bfm.flush     ),

        .done_i     (m_bfm.reg_status[DONE    ] ),
        .busy_i     (m_bfm.reg_status[BUSY    ] ),
        .overflow_i (m_bfm.reg_status[OVERFLOW] ),
        .singular_i (m_bfm.reg_status[SINGULAR] ),
        .rx_err_i   (m_bfm.reg_status[RX_ERR  ] )
    );
    
    initial begin
        ref_model = new();
        m_scrb = new(m_bfm, ref_model);
    end

    initial m_clk_bfm.clk_gen(10);
    initial m_rst_bfm.rst_gen(20, 150);

    initial begin
        fork
            m_scrb.do_monitor();
            m_bfm.start_direct_test(); 
        join_none
        timeout();
    end

    task timeout;
        begin
            #10000;
            $error("[  tb     ] TEST TIMEOUT");
            $finish;
        end
    endtask

endmodule