class vectors_db #(parameter N = 4, parameter DATA_W = 16) extends uvm_object;

    `uvm_object_utils(vectors_db #(N, DATA_W))

    // Test_params
    localparam TESTS = 10;
    localparam TOTAL = N * N;
    localparam DET_W = N * DATA_W;
    
    // In_vectors
    bit signed [DATA_W-1:0] vec_A         [TESTS][N][N];
    bit signed [DATA_W-1:0] vec_B         [TESTS][N][N];

    // Exp_res_vectors
    bit signed [DATA_W-1:0] exp_res_add   [TESTS][N][N];
    bit signed [DATA_W-1:0] exp_res_sub   [TESTS][N][N];
    bit signed [DATA_W-1:0] exp_res_trans [TESTS][N][N];
    bit                     exp_ovf_add   [TESTS];
    bit                     exp_ovf_sub   [TESTS];

    bit signed [DET_W-1 :0] exp_res_det   [TESTS];

    // Queues for scrb
    int chan_a_test_id_q[$];
    int chan_b_test_id_q[$];

    function new(name = "vectors_db");
        super.new(name);
        load_vectors();
    endfunction

    function void load_vectors;
        int fd;

        fd = $fopen("vectors.dat", "r");
        if (fd == 0) `uvm_fatal("VECTORS_DB", "File vectors.dat not found. Run gen_vectors.py")

        for (int t = 0; t < TESTS; t++) begin
            int dummy_id;
            void'( $fscanf(fd, "%d", dummy_id) ); // skip test ID 

            // Reading A and B
            for (int k = 0; k < TOTAL; k++) void'( $fscanf(fd, "%h", vec_A[t][k/N][k%N]) );
            for (int k = 0; k < TOTAL; k++) void'( $fscanf(fd, "%h", vec_B[t][k/N][k%N]) );

            // Reading expected results
            for (int k = 0; k < TOTAL; k++) void'( $fscanf(fd, "%h", exp_res_add[t][k/N][k%N]) );
            for (int k = 0; k < TOTAL; k++) void'( $fscanf(fd, "%h", exp_res_sub[t][k/N][k%N]) );
            for (int k = 0; k < TOTAL; k++) void'( $fscanf(fd, "%h", exp_res_trans[t][k/N][k%N]) );

            // Reading determinant (one word)
            void'( $fscanf(fd, "%h", exp_res_det[t]) );
        
            // Reading expected overflow flags
            void'( $fscanf(fd, "%b %b\n", exp_ovf_add[t], exp_ovf_sub[t]) );
        end
        $fclose(fd);
    endfunction

    // ===========================
    // API functions
    // =========================== 

    function void get_input_A(int test_id, output logic signed [DATA_W-1:0] matrix[N][N]);
        if (test_id < 0 || test_id >= TESTS) begin
            `uvm_error("VECTORS_DB", $sformatf("Invalid test_id %0d for get_input_A", test_id))
            return;
        end
        matrix = vec_A[test_id];
    endfunction

    function void get_input_B(int test_id, output logic signed [DATA_W-1:0] matrix[N][N]);
        if (test_id < 0 || test_id >= TESTS) begin
            `uvm_error("VECTORS_DB", $sformatf("Invalid test_id %0d for get_input_B", test_id))
            return;
        end
        matrix = vec_B[test_id];
    endfunction

    function int get_tests_num();
        return TESTS;
    endfunction

    // For scoreboard
    function void get_expected_add(int test_id, output logic signed [DATA_W-1:0] matrix[N][N], output bit overflow);
        if (test_id < 0 || test_id >= TESTS) begin 
            `uvm_error("VECTORS_DB", "Invalid test_id"); 
            return; 
        end
        matrix = exp_res_add[test_id];
        overflow = exp_ovf_add[test_id];
    endfunction

    function void get_expected_sub(int test_id, output logic signed [DATA_W-1:0] matrix[N][N], output bit overflow);
        if (test_id < 0 || test_id >= TESTS) begin 
            `uvm_error("VECTORS_DB", "Invalid test_id"); 
            return; 
        end
        matrix = exp_res_sub[test_id];
        overflow = exp_ovf_sub[test_id];
    endfunction

    function void get_expected_trans(int test_id, output logic signed [DATA_W-1:0] matrix[N][N]);
        if (test_id < 0 || test_id >= TESTS) begin 
            `uvm_error("VECTORS_DB", "Invalid test_id"); 
            return; 
        end
        matrix = exp_res_trans[test_id];
    endfunction

    function logic signed [DET_W-1:0] get_expected_det(int test_id);
        if (test_id < 0 || test_id >= TESTS) begin 
            `uvm_error("VECTORS_DB", "Invalid test_id"); 
            return '0; 
        end
        return exp_res_det[test_id];
    endfunction

    // Queues
    function void clear_queues();
        chan_a_test_id_q.delete();
        chan_b_test_id_q.delete();
    endfunction

    function bit chan_a_empty(); return (chan_a_test_id_q.size() == 0); endfunction
    function bit chan_b_empty(); return (chan_b_test_id_q.size() == 0); endfunction

    function int chan_a_size(); return chan_a_test_id_q.size(); endfunction
    function int chan_b_size(); return chan_b_test_id_q.size(); endfunction

    localparam int GARBAGE_ID = -1;

    function void push_chan_a(int id); chan_a_test_id_q.push_back(id); endfunction
    function void push_chan_b(int id); chan_b_test_id_q.push_back(id); endfunction

    function void mark_garbage_a(); chan_a_test_id_q.push_back(GARBAGE_ID); endfunction
    function void mark_garbage_b(); chan_b_test_id_q.push_back(GARBAGE_ID); endfunction

    function int pop_chan_a();
        if (chan_a_test_id_q.size() == 0) return -1;
        return chan_a_test_id_q.pop_front();
    endfunction

    function int pop_chan_b();
        if (chan_b_test_id_q.size() == 0) return -1;
        return chan_b_test_id_q.pop_front();
    endfunction

endclass