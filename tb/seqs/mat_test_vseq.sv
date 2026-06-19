class mat_test_vseq #(parameter int N = 4, parameter int DATA_W = 16) extends top_vseq_base #(N, DATA_W);

    `uvm_object_param_utils(mat_test_vseq #(N, DATA_W))

    const string report_id = "mat_test_vseq";
    // =================================== //
    localparam int NUM_RANDOM_VECTORS = 10; 
    // =================================== //

    bit add_disable;
    bit sub_disable;
    bit transpose_disable;
    bit det_disable;

    logic signed [DATA_W-1:0] matrix_a[N][N];
    logic signed [DATA_W-1:0] matrix_b[N][N];
    opcodes_e op;

    int vec_idx;

    rst_start_seq                       rst_seq;
    apb_read_seq                        apb_r_seq;
    apb_write_seq                       apb_wr;
    axis_m_packet_send_seq #(N, DATA_W) mat_a_seq;
    axis_m_packet_send_seq #(N, DATA_W) mat_b_seq;

    function new(string name = "mat_test_vseq");
        super.new(name);
    endfunction

    task body();
        if (env_cfg == null) get_config();
        if (!env_cfg_ready) return;

        rst_seq   = rst_start_seq::type_id::create("rst_seq");
        apb_r_seq = apb_read_seq::type_id::create("apb_r_seq");
        apb_wr    = apb_write_seq::type_id::create("apb_wr_seq");
        mat_a_seq = axis_m_packet_send_seq #(N, DATA_W)::type_id::create("mat_a_seq");
        mat_b_seq = axis_m_packet_send_seq #(N, DATA_W)::type_id::create("mat_b_seq");

        if (!rst_seq.randomize()) `uvm_error(report_id, "Rst seq randomize failed")
        rst_seq.start(rst_sqr);
        wait_end_of_rst();

        wait_for_clock(1);

        foreach (opcodes[i]) begin
            op = opcodes_e'(opcodes[i]);

            if ((op == ADD && add_disable) ||
                (op == SUB && sub_disable) ||
                (op == TRANSPOSE && transpose_disable) ||
                (op == DET && det_disable)) begin
                `uvm_info(report_id, $sformatf("Skipping OP=%s (disabled)", op.name()), UVM_MEDIUM)
                continue;
            end

            #1;
            `uvm_info(report_id, $sformatf("Testing operation OP=%s", op.name()), UVM_MEDIUM)

            apb_wr.addr  = REG_OP;
            apb_wr.wdata = op;
            apb_wr.start(apb_sqr);

            for (int j = 0; j < NUM_RANDOM_VECTORS; j++) begin
                if (op == DET && j == 0) begin
                    vec_idx = 0;
                end else begin
                    if (op == DET) begin
                        vec_idx = $urandom_range(1, get_tests_num() - 1);
                    end else begin
                        vec_idx = $urandom_range(0, get_tests_num() - 1);
                    end
                end
                
                get_vec_A(vec_idx, matrix_a);
                push_chan_a(vec_idx);

                get_vec_B(vec_idx, matrix_b);
                push_chan_b(vec_idx);

                fork
                    begin
                        mat_a_seq.matrix_data = matrix_a;
                        mat_a_seq.correct_tlast = 1'b1;
                        mat_a_seq.start(axis_m_sqr_a);
                    end
                    begin
                        if (op inside {ADD, SUB}) begin
                            mat_b_seq.matrix_data = matrix_b;
                            mat_b_seq.correct_tlast = 1'b1;
                            mat_b_seq.start(axis_m_sqr_b);
                        end
                    end
                join

                apb_wr.addr  = REG_CTRL;
                apb_wr.wdata = 32'd1;
                apb_wr.start(apb_sqr);

                fork
                    begin
                        apb_r_seq.addr = REG_STATUS;    // Read status reg to check busy and overflow flags
                        apb_r_seq.start(apb_sqr, this);

                        if (op == DET) begin            // For det operation wait end of computing (start of result transmission)
                                                        // to check singular flag
                            wait_res_elem_hs();
                            apb_r_seq.addr = REG_STATUS;
                            apb_r_seq.start(apb_sqr, this);

                        end
                    end
                    begin
                        wait_last_res_elem_hs();
                    end
                join 

                #1;
                `uvm_info(report_id, $sformatf("  OP=%s, vec=%0d completed", 
                             op.name(), j), UVM_MEDIUM)
            end
    
            #1;
            `uvm_info(report_id, $sformatf("Check operation OP=%s", op.name()), UVM_LOW)
            $stop(); 
        end
    endtask

endclass