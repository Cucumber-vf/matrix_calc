class test_vseq #(parameter int N = 4, parameter int DATA_W = 16) extends top_vseq_base #(N, DATA_W);

    `uvm_object_param_utils(test_vseq #(N, DATA_W))

    rst_start_seq                       rst;
    apb_read_seq                        apb_r;
    apb_write_seq                       apb_wr;
    axis_m_send_seq        #(   DATA_W) elem_a_seq;
    axis_m_send_seq        #(   DATA_W) elem_b_seq;

    axis_m_packet_send_seq #(N, DATA_W) mat_a_seq;
    axis_m_packet_send_seq #(N, DATA_W) mat_b_seq;
    matrix_calc_op_vseq    #(N, DATA_W) mat_calc_seq;

    function new (string name = "test_vseq");
        super.new(name);
    endfunction

    task body();
        if (env_cfg == null) get_config();
        if (!env_cfg_ready) return;

        rst          = rst_start_seq::type_id::create("rst");
        apb_r        = apb_read_seq::type_id::create("apb_r");
        apb_wr       = apb_write_seq::type_id::create("apb_wr");
        elem_a_seq   = axis_m_send_seq #(DATA_W)::type_id::create("elem_a_seq");
        elem_b_seq   = axis_m_send_seq #(DATA_W)::type_id::create("elem_b_seq");
        // mat_a_seq    = axis_m_packet_send_seq #(N, DATA_W)::type_id::create("mat_a_seq");
        // mat_b_seq    = axis_m_packet_send_seq #(N, DATA_W)::type_id::create("mat_b_seq");
        // mat_calc_seq = matrix_calc_op_vseq #(N, DATA_W)::type_id::create("mat_caclc_seq");

        // mat_calc_seq.apb_sqr = apb_sqr; 
        // mat_calc_seq.axis_a_sqr = axis_m_sqr_a; 
        // mat_calc_seq.axis_b_sqr = axis_m_sqr_b; 

        if (!rst.randomize()) `uvm_error(report_id, "Elem seq randomize failed")
        rst.start(rst_sqr);
        wait_end_of_rst();

        apb_wr.addr  = REG_OP;
        apb_wr.wdata = 2'b01;
        apb_wr.start(apb_sqr);

        apb_r.addr  = REG_OP;
        apb_r.start(apb_sqr);

        for (int i = 0; i < N*N; i++) begin
            if (!elem_a_seq.randomize() with {
                tdata   == i;
                is_last == (i == N*N - 1);
                delay   == 1;
            }) `uvm_error(report_id, "Elem seq randomize failed")
        
            elem_a_seq.start(axis_m_sqr_a, this);
        end

        for (int i = 0; i < N*N; i++) begin
            if (!elem_b_seq.randomize() with {
                tdata   == i;
                is_last == (i == N*N - 1);
                delay   == 2;
            }) `uvm_error(report_id, "Elem seq randomize failed")
        
            elem_b_seq.start(axis_m_sqr_b, this);
        end

        apb_wr.addr  = REG_CTRL;
        apb_wr.wdata = 2'b01;
        apb_wr.start(apb_sqr);

        wait_last_elem();
    endtask

endclass