class reg_test extends test_base;

    `uvm_component_utils(reg_test)

    function new (string name = "reg_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
    endfunction

    task run_phase (uvm_phase phase);
        reg_test_vseq_t t_seq = reg_test_vseq_t::type_id::create("t_seq");
        init_vseq (t_seq);

        phase.raise_objection(this, "REG_TEST Started"); 
        t_seq.start(null);
        #100;
        phase.drop_objection(this, "REG_TEST Finished");
    endtask

endclass