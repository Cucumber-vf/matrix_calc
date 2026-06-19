class flush_and_rst_test_vseq #(parameter int N = 4, parameter int DATA_W = 16) extends top_vseq_base #(N, DATA_W);
 
    `uvm_object_param_utils(flush_and_rst_test_vseq #(N, DATA_W))
 
    const string report_id = "flush_and_rst_test_vseq";
    // =================================== //
    localparam int NUM_RST_CYCLES   = 8;  
    localparam int RST_DELAY_MIN_CK = 20; 
    localparam int RST_DELAY_MAX_CK = 400;
    localparam int RST_ASYNC_MAX_NS = 20;
    // =================================== //
 
    logic signed [DATA_W-1:0] matrix_a[N][N];
    logic signed [DATA_W-1:0] matrix_b[N][N];
 
    int  vec_idx;
    int  flush_hs_idx;
    bit  rst_happened;
 
    rst_start_seq                       rst_seq;
    apb_write_seq                       apb_wr_seq;
    apb_read_seq                        apb_r_seq;
    axis_m_packet_send_seq #(N, DATA_W) mat_a_seq;
    axis_m_packet_send_seq #(N, DATA_W) mat_b_seq;
 
    function new(string name = "flush_and_rst_test_vseq");
        super.new(name);
    endfunction
 
    task body();
        if (env_cfg == null) get_config();
        if (!env_cfg_ready) return;
 
        rst_seq      = rst_start_seq::type_id::create("rst_seq");
        apb_wr_seq   = apb_write_seq::type_id::create("apb_wr_seq");
        apb_r_seq    = apb_read_seq::type_id::create("apb_r_seq");
        mat_a_seq    = axis_m_packet_send_seq #(N, DATA_W)::type_id::create("mat_a_seq");
        mat_b_seq    = axis_m_packet_send_seq #(N, DATA_W)::type_id::create("mat_b_seq");
 
        if (!rst_seq.randomize()) `uvm_error(report_id, "Initial rst_seq randomize failed")
        rst_seq.start(rst_sqr);
        wait_end_of_rst();
 
        for (int i = 0; i < NUM_RST_CYCLES; i++) begin
            wait_for_clock(1);
            
            #1;
            `uvm_info(report_id,
                $sformatf("=== RST cycle %0d / %0d ===", i + 1, NUM_RST_CYCLES), UVM_MEDIUM)
 
            rst_happened = 0;
 
            fork
                begin : proc_a
                    forever begin
 
                        if (rst_happened) break;
 
                        vec_idx = $urandom_range(0, get_tests_num() - 1);

                        get_vec_A(vec_idx, matrix_a);
                        get_vec_B(vec_idx, matrix_b);

                        push_chan_a(vec_idx);
                        push_chan_b(vec_idx);
 
                        flush_hs_idx = $urandom_range(0, N*N);
 
                        fork
                            begin : inner_i
                                if (!apb_wr_seq.randomize() with { addr == REG_OP; })
                                    `uvm_error(report_id, "apb_wr_seq OP randomize failed")
                                apb_wr_seq.start(apb_sqr, this);

                                if (!rst_happened) begin
                                    fork
                                        begin
                                            mat_a_seq.matrix_data = matrix_a;
                                            mat_a_seq.correct_tlast = 1'b1;
                                            mat_a_seq.start(axis_m_sqr_a);
                                        end
                                        begin
                                            mat_b_seq.matrix_data = matrix_b;
                                            mat_b_seq.correct_tlast = 1'b1;
                                            mat_b_seq.start(axis_m_sqr_b);
                                        end
                                    join
                                end
                            end : inner_i
 
                            begin : inner_ii
                                fork
                                    begin
                                        repeat (flush_hs_idx) wait_in0_elem_hs();
                                    end
                                    begin
                                        wait_start_of_rst();
                                    end
                                join_any
                                disable fork;
 
                                if (!rst_happened) begin
                                    if (!apb_wr_seq.randomize() with {
                                        addr     == REG_CTRL;
                                        wdata[0] == 1'b0;
                                    }) `uvm_error(report_id, "apb_ctrl_seq randomize failed")
                                    apb_wr_seq.start(apb_sqr, this);
                                end
                            end : inner_ii
                        join
 
                        if (rst_happened) break;
 
                        if (!apb_wr_seq.wdata[1]) begin
                            apb_wr_seq.addr  = REG_CTRL;
                            apb_wr_seq.wdata = 32'd1;
                            apb_wr_seq.start(apb_sqr, this);
 
                            if (rst_happened) break;
 
                            fork
                                wait_last_res_elem_hs();
                                wait_start_of_rst();
                            join_any
                            disable fork;
 
                            if (!rst_happened) begin
                                `uvm_info(report_id, "Result received", UVM_MEDIUM)
                            end
                        end 
                        else begin
                            apb_wr_seq.addr  = REG_CTRL;
                            apb_wr_seq.wdata = 32'd2; 
                            apb_wr_seq.start(apb_sqr, this);
 
                            apb_r_seq.addr = REG_STATUS;
                            apb_r_seq.start(apb_sqr, this);
                        end
 
                    end 
                end : proc_a

                begin : proc_b
                    wait_for_clock($urandom_range(RST_DELAY_MIN_CK, RST_DELAY_MAX_CK));
                    #($urandom_range(0, RST_ASYNC_MAX_NS));
 
                    rst_happened = 1;
 
                    if (!rst_seq.randomize()) `uvm_error(report_id, "Rst seq randomize failed")
                    rst_seq.start(rst_sqr);
                end : proc_b
            join
 
            wait_end_of_rst();
 
            `uvm_info(report_id, $sformatf("RST cycle %0d complete", i + 1), UVM_MEDIUM)
        end
    endtask
 
endclass