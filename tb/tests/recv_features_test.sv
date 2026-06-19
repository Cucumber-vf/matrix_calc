class recv_features_test extends test_base;

    `uvm_component_utils(recv_features_test)

    function new(string name = "recv_features_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    task run_phase(uvm_phase phase);
        recv_features_test_vseq_t t_seq = recv_features_test_vseq_t::type_id::create("t_seq");
        init_vseq(t_seq);

        phase.raise_objection(this, "RECV_FEATURES_TEST Started"); 
        t_seq.start(null);
        #100;
        phase.drop_objection(this, "RECV_FEATures_TEST Finished");
    endtask

endclass