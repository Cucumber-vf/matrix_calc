class mat_test_vseq #(parameter int N = 4, parameter int DATA_W = 16) extends top_vseq_base #(N, DATA_W);

    `uvm_object_param_utils(mat_test_vseq #(N, DATA_W))

    const string report_id = "mat_test_vseq";
    // =================================== //
    localparam int NUM_RANDOM_VECTORS = 3; // Set the number of random vectors for operation
    // =================================== //

    bit add_disable;
    bit sub_disable;
    bit transpose_disable;
    bit det_disable;

    logic signed [DATA_W-1:0] matrix_a[N][N];
    logic signed [DATA_W-1:0] matrix_b[N][N];
    opcodes_e op_code;

    int vec_idx;

    rst_start_seq                    rst_seq;
    apb_read_seq                     apb_r_seq;
    matrix_calc_op_vseq #(N, DATA_W) mat_op_seq;

    function new(string name = "mat_test_vseq");
        super.new(name);
    endfunction

    task body();
        if (env_cfg == null) get_config();
        if (!env_cfg_ready) return;

        rst_seq      = rst_start_seq::type_id::create("rst_seq");
        apb_r_seq    = apb_read_seq::type_id::create("apb_r_seq");
        mat_op_seq   = matrix_calc_op_vseq #(N, DATA_W)::type_id::create("mat_op_seq");

        mat_op_seq.apb_sqr    = apb_sqr;
        mat_op_seq.axis_a_sqr = axis_m_sqr_a;
        mat_op_seq.axis_b_sqr = axis_m_sqr_b;

        if (!rst_seq.randomize()) `uvm_error(report_id, "Rst seq randomize failed")
        rst_seq.start(rst_sqr);
        wait_end_of_rst();

        foreach (opcodes[i]) begin

            op_code = opcodes[i];

            if ((op_code == ADD && add_disable) ||
                (op_code == SUB && sub_disable) ||
                (op_code == TRANSPOSE && transpose_disable) ||
                (op_code == DET && det_disable)) begin
                `uvm_info(report_id, $sformatf("Skipping OP=%s (disabled)", op_code.name()), UVM_MEDIUM)
                continue;
            end

            `uvm_info(report_id, $sformatf("Testing operation OP=%s", op_code.name()), UVM_LOW)

            for (int j = 0; j < NUM_RANDOM_VECTORS; j++) begin
                `uvm_info(report_id, $sformatf("  Vector %0d", j), UVM_MEDIUM)
                
                if (op_code == DET && j == 0) begin
                    vec_idx = 0;
                end else begin
                    if (op_code == DET) begin
                        vec_idx = $urandom_range(1, get_tests_num() - 1);
                    end else begin
                        vec_idx = $urandom_range(0, get_tests_num() - 1);
                    end
                end
                
                get_vec_A(vec_idx, matrix_a);
                get_vec_B(vec_idx, matrix_b);

                mat_op_seq.op_code   = op_code;
                mat_op_seq.matrix_a  = matrix_a;
                mat_op_seq.matrix_b  = matrix_b;
                mat_op_seq.start(null, this);

                wait_last_elem();

                apb_r_seq.addr = REG_STATUS;
                apb_r_seq.start(apb_sqr, this);

                `uvm_info(report_id, $sformatf("  OP=%s, vec=%0d completed", 
                             op_code.name(), j), UVM_MEDIUM)
            end
    
            $stop(); 
            `uvm_info(report_id, $sformatf("Check operation OP=%s", op_code.name()), UVM_LOW)

        end
    endtask

endclass