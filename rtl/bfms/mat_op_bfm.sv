interface mat_op_bfm #(parameter N = 4, parameter DATA_W = 16) (input clk, input rst_n);

    // Control_signals
    logic [1:0]                 op;
    logic                       start;

    // In_matrices
    logic signed [  DATA_W-1:0] mat_a [N][N];
    logic signed [  DATA_W-1:0] mat_b [N][N];

    // Addsub_res
    logic signed [  DATA_W-1:0] mat_addsub_res [N][N];
    logic                       addsub_overflow;
    
    // Transpose_res
    logic signed [  DATA_W-1:0] mat_transpose_res [N][N];

    // Det_res
    logic signed [N*DATA_W-1:0] det;
    logic                       det_singular;
    logic                       calc_done;

    int t; // test number

    // Ref_model for in vectors
    ref_model model;

    task mat_calc_rst;
        op <= 0;
        start <= 0;
    endtask

    task send_matrices (input logic signed [DATA_W-1:0] in_a [N][N], input logic signed [DATA_W-1:0] in_b [N][N]);
        @(posedge clk);
        for (int i = 0; i < N; i++) begin
            for (int j = 0; j < N; j++) begin
                mat_a[i][j] <= in_a[i][j];
                mat_b[i][j] <= in_b[i][j];
            end
        end
    endtask

    task start_test;
        wait (!rst_n);
        mat_calc_rst();
        wait (rst_n);
        op <= 2'b00; 
        $display ("=========================Starting add and transpose test=========================");
        for (t = 0; t < model.TESTS; t++) begin
            send_matrices(model.vec_A[t], model.vec_B[t]);
            @(posedge clk);
            start <= 1;
            @(posedge clk);
            start <= 0;
        end
        op <= 2'b11;
        $display ("=========================Starting determinant and sub test=======================");
        for (t = 0; t < model.TESTS; t++) begin
            send_matrices(model.vec_A[t], model.vec_B[t]);
            @(posedge clk);
            start <= 1;
            @(posedge clk);
            start <= 0;
            @(posedge clk);
            wait (calc_done);
        end
        $display ("=========================Matrix operation test finished==========================");
            
        $finish();
    endtask

endinterface