module tb_mat_op;
    localparam N      = 4;
    localparam DATA_W = 16;
    
    clk_bfm m_clk_bfm();
    rst_bfm m_rst_bfm();

    mat_op_bfm #(.N(N), .DATA_W(DATA_W)) m_bfm (m_clk_bfm.clk, m_rst_bfm.rst_n);

    ref_model #(.N(N), .DATA_W(DATA_W)) m_ref;
    mat_op_scrb m_scrb;
    
    mat_addsub #(
        .N        (N),
        .DATA_W   (DATA_W)
    ) u_mat_addsub (
        .mat_a    (m_bfm.mat_a          ),
        .mat_b    (m_bfm.mat_b          ),
        .sub      (|m_bfm.op            ),
        .mat_c    (m_bfm.mat_addsub_res ),
        .overflow (m_bfm.addsub_overflow)
    );

    mat_transpose #(
        .N      (N),
        .DATA_W (DATA_W)
    ) u_mat_transpose (
        .mat_a (m_bfm.mat_a            ),
        .mat_c (m_bfm.mat_transpose_res)
    );

    mat_det #(
        .N        (N),
        .DATA_W   (DATA_W)
    ) u_mat_det (
        .clk       (m_clk_bfm.clk          ),
        .rst_n     (m_rst_bfm.rst_n        ),
        .mat_a     (m_bfm.mat_a            ),
        .det       (m_bfm.det              ),
        .start     (m_bfm.op && m_bfm.start),
        .singular  (m_bfm.det_singular     ),
        .calc_done (m_bfm.calc_done        ) 
    );

    initial begin
        m_ref  = new();
        m_scrb = new(m_bfm, m_ref);

        m_bfm.model = m_ref;
    end

    initial m_clk_bfm.clk_gen(10);
    initial m_rst_bfm.rst_gen(20, -1);

    initial begin
        fork
            m_scrb.do_monitor();
            m_bfm.start_test();
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