class mat_test extends test_base;

    `uvm_component_utils(mat_test)

    bit add_disable;
    bit sub_disable;
    bit transpose_disable;
    bit det_disable;

    function new(string name = "mat_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        if ($test$plusargs("add_disable"))       add_disable       = 1'b1;
        if ($test$plusargs("sub_disable"))       sub_disable       = 1'b1;
        if ($test$plusargs("transpose_disable")) transpose_disable = 1'b1;
        if ($test$plusargs("det_disable"))       det_disable       = 1'b1;

        super.build_phase(phase);
    endfunction

    task run_phase(uvm_phase phase);
        mat_test_vseq_t t_seq = mat_test_vseq_t::type_id::create("t_seq");
        init_vseq(t_seq);

        t_seq.add_disable       = add_disable;
        t_seq.sub_disable       = sub_disable;
        t_seq.transpose_disable = transpose_disable;
        t_seq.det_disable       = det_disable;

        phase.raise_objection(this, "MAT_TEST Started"); 
        t_seq.start(null);
        #100;
        phase.drop_objection(this, "MAT_TEST Finished");
    endtask

endclass