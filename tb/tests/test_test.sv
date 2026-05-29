class test_test extends test_base;

    `uvm_component_utils(test_test)

    function new (string name = "test_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
    endfunction

    task run_phase (uvm_phase phase);
        test_vseq_t t_seq = test_vseq_t::type_id::create("t_seq");
        init_vseq (t_seq);

        phase.raise_objection(this, "Test Started"); 
        t_seq.start(null);
        #100;
        phase.drop_objection(this, "Test Finished");
    endtask

endclass