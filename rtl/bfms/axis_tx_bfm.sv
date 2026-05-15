interface axis_tx_bfm #(parameter N = 4, parameter DATA_W = 16) (input clk, input rst_n);

    // Ctrl signals
    logic                       send;
    logic                       is_scalar;

    // Values to send
    logic signed [  DATA_W-1:0] mat_in [N][N];
    logic signed [N*DATA_W-1:0] scalar_in;
    
    // AXIS Master Interface
    logic signed [  DATA_W-1:0] m_tdata;
    logic                       m_tvalid;
    logic                       m_tlast;

    logic                       m_tready;

    // Ref_model for in vectors
    ref_model model;

    task axis_tx_rst;
        m_tready <= 0;
        send     <= 0;
    endtask

    task send_data (input logic signed [DATA_W-1:0] in_mat [N][N], input logic signed [N*DATA_W-1:0] in_scalar);
        @(posedge clk);
        for (int i = 0; i < N; i++) begin
            for (int j = 0; j < N; j++) begin
                mat_in[i][j] <= in_mat[i][j];
            end
        end
        scalar_in <= in_scalar;
    endtask

    task axis_recieve (input min_delay = 0, input max_delay = 5);
        forever begin
            repeat ($urandom_range(min_delay, max_delay)) @(posedge clk);
            m_tready <= 1;
            @(posedge clk);
            m_tready <= 0;
        end
    endtask

    task start_random_test;
        int last_t;
        $display ("===========================AXIS_tx random test start============================");              
        forever begin
            fork
                axis_recieve();
                forever begin
                    for (int t = !last_t ? 0 : last_t + 1; t < model.TESTS; t++) begin
                        send_data(model.vec_A[t], model.exp_res_det[t]);
                        is_scalar <= $urandom();
                        @(posedge clk);
                        send <= 1;
                        @(posedge clk);
                        send <= 0;
                        @(posedge clk);
                        wait (m_tlast && m_tvalid && m_tready);
                        last_t = (t == model.TESTS - 1) ? 0 : t; 
                    end
                end
            join_none
            wait(~rst_n);
            disable fork;
            axis_tx_rst();
            wait( rst_n);
        end
    endtask

endinterface