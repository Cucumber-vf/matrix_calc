class flush_and_rst_test extends test_base;

    `uvm_component_utils(flush_and_rst_test)

    function new(string name = "flush_and_rst_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    task run_phase(uvm_phase phase);
        flush_and_rst_test_vseq_t t_seq = flush_and_rst_test_vseq_t::type_id::create("t_seq");
        init_vseq(t_seq);

        phase.raise_objection(this, "RECV_FEATURES_TEST Started"); 
        t_seq.start(null);
        #100;
        phase.drop_objection(this, "RECV_FEATures_TEST Finished");
    endtask

endclass