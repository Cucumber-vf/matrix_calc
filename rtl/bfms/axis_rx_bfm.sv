interface axis_rx_bfm #(parameter N = 4, parameter DATA_W = 16) (input clk, input rst_n);

    // AXIS Slave Interface
    logic signed [DATA_W-1:0] s_tdata;
    logic                     s_tvalid;
    logic                     s_tlast;
    logic                     s_tready;
    
    // Ctrl signal
    logic                     flush; 

    // Mat and status signals
    logic signed [DATA_W-1:0] mat [N][N];
    logic                     recv_done;
    logic                     rx_err;

    // Ref_model for in vectors
    ref_model model;

    task axis_rx_rst;
        s_tvalid <= 0;
        flush    <= 0;
        s_tlast  <= 0;
    endtask

    task axis_send (
        input signed [DATA_W-1:0] data_array [N][N],
        input int min_delay   = 0,   
        input int max_delay   = 5,   
        input bit early_tlast = 0  
    );
        int delay;
        int early_tlast_idx;

        if (early_tlast) 
            early_tlast_idx = $urandom_range(0, N*N - 2);
        else 
            early_tlast_idx = -1;
        
        @(posedge clk);
        for (int i = 0; i < N*N; i++) begin
            s_tvalid <= 1;
            s_tdata  <= data_array[i/N][i%N];
            s_tlast  <= (i == N*N - 1) || (i == early_tlast_idx);
            do begin
                @(posedge clk);
            end while(~s_tready);
            s_tvalid <= 0;
            s_tlast  <= 0;
            #0;
            delay = $urandom_range(min_delay, max_delay);
            repeat(delay) @(posedge clk);
        end
    endtask

    task start_random_test;
        int last_t;
        $display ("===========================AXIS_rx random test start============================");              
        forever begin
            fork
                forever begin
                    fork
                        forever begin
                            for(int t = !last_t ? 0 : last_t + 1; t < model.TESTS; t++) begin
                                axis_send (model.vec_A[t], 0, 5, $urandom());
                                last_t = (t == model.TESTS - 1) ? 0 : t; 
                                flush <= 1;
                                @(posedge clk);
                                flush <= 0;
                            end 
                        end 
                    join_none
                    wait(rx_err);
                    disable fork;
                    flush <= 1;
                    @(posedge clk);
                    flush <= 0;
                    wait(~rx_err);
                end
            join_none
            wait(~rst_n);
            disable fork;
            axis_rx_rst();
            wait( rst_n);
        end
    endtask

endinterface