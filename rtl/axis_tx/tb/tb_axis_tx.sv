module tb_axis_rx;

    localparam N      = 4;
    localparam DATA_W = 16;
    
    clk_bfm m_clk_bfm();
    rst_bfm m_rst_bfm();

    axis_tx_bfm #(.N(N), .DATA_W(DATA_W)) m_bfm (m_clk_bfm.clk, m_rst_bfm.rst_n);

    ref_model #(.N(N), .DATA_W(DATA_W)) m_ref;
    axis_tx_scrb m_scrb;

    axis_tx #(
        .N         (N),
        .DATA_W    (DATA_W)
    ) u_axis_tx (
        .clk       (m_clk_bfm.clk   ),
        .rst_n     (m_rst_bfm.rst_n ),
        .send      (m_bfm.send      ),
        .is_scalar (m_bfm.is_scalar ),
        .mat_in    (m_bfm.mat_in    ),
        .scalar_in (m_bfm.scalar_in ),
        .m_tdata   (m_bfm.m_tdata   ),
        .m_tvalid  (m_bfm.m_tvalid   ),
        .m_tlast   (m_bfm.m_tlast   ),
        .m_tready  (m_bfm.m_tready  )
    );

    initial begin
        m_ref  = new();
        m_scrb = new(m_bfm, m_ref.TESTS);

        m_bfm.model = m_ref;
    end

    initial m_clk_bfm.clk_gen(10);
    initial m_rst_bfm.rst_gen(20, 600);

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