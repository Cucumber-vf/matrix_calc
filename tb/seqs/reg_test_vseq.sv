class reg_test_vseq #(parameter int N = 4, parameter int DATA_W = 16) extends top_vseq_base #(N, DATA_W);
    
    `uvm_object_param_utils(reg_test_vseq #(N, DATA_W))

    const string report_id = "reg_test_vseq";
    // =================================== //
    localparam int INV_ADDR_TXNS_NUM = 10; 
    // =================================== //
    rst_start_seq rst_seq;
    apb_read_seq  apb_r_seq;
    apb_write_seq apb_wr_seq;

    function new(string name = "reg_test_vseq");
        super.new(name);
    endfunction

    task body();
        if (env_cfg == null) get_config();
        if (!env_cfg_ready) return;

        rst_seq    = rst_start_seq::type_id::create("rst_seq");
        apb_r_seq  = apb_read_seq::type_id::create("apb_r_seq");
        apb_wr_seq = apb_write_seq::type_id::create("apb_wr_seq");

        if (!rst_seq.randomize()) `uvm_error(report_id, "Rst seq randomize failed")
        rst_seq.start(rst_sqr);
        wait_end_of_rst();
        
        foreach (valid_addresses[i]) begin
            apb_r_seq.addr = valid_addresses[i];
            apb_r_seq.start(apb_sqr, this);
        end

        foreach (valid_addresses[i]) begin
            apb_wr_seq.addr = valid_addresses[i];
            apb_wr_seq.wdata = 32'hFFFFFFFF;
            apb_wr_seq.start(apb_sqr, this);
        end
    
        foreach (valid_addresses[i]) begin
            apb_r_seq.addr = valid_addresses[i];
            apb_r_seq.start(apb_sqr, this);
        end

        apb_wr_seq.c_addr.constraint_mode(0); // Ready to txns for inv addresses
        apb_r_seq.c_addr.constraint_mode(0);  // Ready to txns for inv addresses

        for (int i = 0; i < INV_ADDR_TXNS_NUM; i++) begin
            if (!apb_wr_seq.randomize() with {
                !(addr inside {valid_addresses});
            }) `uvm_error(report_id, "APB_wr_seq with invalid address randomize failed")
            apb_wr_seq.start(apb_sqr, this);

            if (!apb_r_seq.randomize() with {
                !(addr inside {valid_addresses});
            }) `uvm_error(report_id, "APB_r_seq with invalid address randomize failed")
            apb_r_seq.start(apb_sqr, this);
        end

        apb_wr_seq.c_addr.constraint_mode(1);
        apb_r_seq.c_addr.constraint_mode(1);
    endtask

endclass