class ref_model #(
    parameter N = 4,
    parameter DATA_W = 16
);

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

    function new();
        load_vectors();
    endfunction

    function void load_vectors();
        int fd;

        fd = $fopen("vectors.dat", "r");
        if (fd == 0) $fatal(1, "File vectors.dat not found. Run gen_vectors.py");

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
        $display("[ref_model] Loaded %0d test vectors     %0t", TESTS, $time);
    endfunction

endclass