class recv_features_test_vseq #(parameter int N = 4, parameter int DATA_W = 16) extends top_vseq_base #(N, DATA_W);
 
    `uvm_object_param_utils(recv_features_test_vseq #(N, DATA_W))
 
    const string report_id = "recv_features_test_vseq";
    // =================================== //
    localparam int NUM_ITERATIONS = 10;    
    // =================================== //
 
    logic signed [DATA_W-1:0] matrix_a[N][N];
    logic signed [DATA_W-1:0] matrix_b[N][N];
 
    int vec_idx;
    int op_hs_idx; 
 
    rst_start_seq                       rst_seq;
    apb_write_seq                       apb_wr_seq;
    apb_read_seq                        apb_r_seq;
    axis_m_packet_send_seq #(N, DATA_W) mat_a_seq;
    axis_m_packet_send_seq #(N, DATA_W) mat_b_seq;
 
    function new(string name = "recv_features_test_vseq");
        super.new(name);
    endfunction
 
    task body();
        if (env_cfg == null) get_config();
        if (!env_cfg_ready) return;
 
        rst_seq    = rst_start_seq::type_id::create("rst_seq");
        apb_wr_seq = apb_write_seq::type_id::create("apb_wr_seq");
        apb_r_seq  = apb_read_seq::type_id::create("apb_r_seq");
        mat_a_seq  = axis_m_packet_send_seq #(N, DATA_W)::type_id::create("mat_a_seq");
        mat_b_seq  = axis_m_packet_send_seq #(N, DATA_W)::type_id::create("mat_b_seq");
 
        if (!rst_seq.randomize()) `uvm_error(report_id, "Rst seq randomize failed")
        rst_seq.start(rst_sqr);
        wait_end_of_rst();

        wait_for_clock(1);
 
        for (int i = 0; i < NUM_ITERATIONS; i++) begin
            #1;
            `uvm_info(report_id, $sformatf("=== Iteration %0d / %0d ===", i+1, NUM_ITERATIONS), UVM_MEDIUM)
 
            vec_idx = $urandom_range(0, get_tests_num() - 1);

            get_vec_A(vec_idx, matrix_a);
            get_vec_B(vec_idx, matrix_b);

            push_chan_a(vec_idx);
            push_chan_b(vec_idx);
 
            op_hs_idx = $urandom_range(0, N*N - 1);
 
            fork
                begin
                    mat_a_seq.matrix_data = matrix_a;
                    mat_a_seq.correct_tlast = $urandom();
                    mat_a_seq.start(axis_m_sqr_a);
                end
 
                begin
                    mat_b_seq.matrix_data = matrix_b;
                    mat_b_seq.correct_tlast = $urandom();
                    mat_b_seq.start(axis_m_sqr_b);
                end
 
                begin
                    fork
                        begin
                            repeat (op_hs_idx) wait_in0_elem_hs();
                        end
                        begin
                            fork
                                wait_last_in0_elem_hs();
                                wait_last_in1_elem_hs();
                            join
                        end
                    join_any
                    disable fork;
                    if (!apb_wr_seq.randomize() with { addr == REG_OP; })
                        `uvm_error(report_id, "apb_wr_seq OP randomize failed")
                    apb_wr_seq.start(apb_sqr, this);
                end
            join
 
            apb_r_seq.addr = REG_STATUS;
            apb_r_seq.start(apb_sqr, this);
 
            if (!get_rx_err_status()) begin
                apb_wr_seq.addr  = REG_CTRL;
                apb_wr_seq.wdata = 32'd1;
                apb_wr_seq.start(apb_sqr, this);

                if (!apb_wr_seq.randomize() with { addr == REG_OP; })
                    `uvm_error(report_id, "apb_wr_seq OP randomize failed")
                apb_wr_seq.start(apb_sqr, this);
 
                wait_last_res_elem_hs();

                #1;
                `uvm_info(report_id, $sformatf("Iter %0d: result received", i+1), UVM_MEDIUM)
            end 
            else begin
                #1;
                `uvm_info(report_id, $sformatf("Iter %0d: RX_ERR set, sending FLUSH", i+1), UVM_MEDIUM)
 
                apb_wr_seq.addr  = REG_CTRL;
                apb_wr_seq.wdata = 32'd2;
                apb_wr_seq.start(apb_sqr, this);
            end
        end
    endtask
 
endclass
 