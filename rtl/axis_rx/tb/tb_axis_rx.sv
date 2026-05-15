module tb_axis_rx;

    localparam N      = 4;
    localparam DATA_W = 16;
    
    clk_bfm m_clk_bfm();
    rst_bfm m_rst_bfm();

    axis_rx_bfm #(.N(N), .DATA_W(DATA_W)) m_bfm (m_clk_bfm.clk, m_rst_bfm.rst_n);

    ref_model #(.N(N), .DATA_W(DATA_W)) m_ref;
    axis_rx_scrb m_scrb;

    axis_rx #(
        .N         (N),
        .DATA_W    (DATA_W)
    ) u_axis_rx (
        .clk       (m_clk_bfm.clk   ),
        .rst_n     (m_rst_bfm.rst_n ),
        .s_tdata   (m_bfm.s_tdata   ),
        .s_tvalid  (m_bfm.s_tvalid  ),
        .s_tlast   (m_bfm.s_tlast   ),
        .s_tready  (m_bfm.s_tready  ),
        .flush     (m_bfm.flush     ),
        .mat       (m_bfm.mat       ),
        .recv_done (m_bfm.recv_done ),
        .rx_err    (m_bfm.rx_err    )
    );

    initial begin
        m_ref  = new();
        m_scrb = new(m_bfm, m_ref.TESTS);

        m_bfm.model = m_ref;
    end

    initial m_clk_bfm.clk_gen(10);
    initial m_rst_bfm.rst_gen(20, 2000);

    initial begin
        fork
            m_scrb.do_monitor();
            m_bfm.start_random_test();
        join_none
        timeout();
    end

    task timeout;
        begin
            #100000;
            $error("[  tb     ] TEST TIMEOUT");
            $finish;
        end
    endtask

endmodule