class matrix_calc_op_vseq #(parameter int N = 4, parameter int DATA_W = 16) extends uvm_sequence #(uvm_sequence_item);

    `uvm_object_param_utils(matrix_calc_op_vseq #(N, DATA_W))

    const string report_id = "matrix_calc_op_seq";

    rand bit          [         1:0] op_code;
    rand logic signed [DATA_W - 1:0] matrix_a[N][N];
    rand logic signed [DATA_W - 1:0] matrix_b[N][N];

    uvm_sequencer_base apb_sqr;
    uvm_sequencer_base axis_a_sqr;
    uvm_sequencer_base axis_b_sqr;

    apb_write_seq                       apb_wr;
    axis_m_packet_send_seq #(N, DATA_W) mat_a_seq;
    axis_m_packet_send_seq #(N, DATA_W) mat_b_seq;

    function new (string name = "matrix_calc_op_seq");
        super.new(name);
    endfunction

    task body();
        apb_wr    = apb_write_seq::type_id::create("apb_wr");
        mat_a_seq = axis_m_packet_send_seq #(N, DATA_W)::type_id::create("mat_a_seq");
        mat_b_seq = axis_m_packet_send_seq #(N, DATA_W)::type_id::create("mat_b_seq");
        

        apb_wr.addr  = REG_OP;
        apb_wr.wdata = op_code;
        apb_wr.start(apb_sqr);

        fork
            begin
                mat_a_seq.matrix_data = matrix_a;
                mat_a_seq.correct_tlast = 1'b1;
                mat_a_seq.start(axis_a_sqr);
            end
            begin
                if (op_code inside {2'b00, 2'b01}) begin
                    mat_b_seq.matrix_data = matrix_b;
                    mat_b_seq.correct_tlast = 1'b1;
                    mat_b_seq.start(axis_b_sqr);
                end
            end
        join

        apb_wr.addr  = REG_CTRL;
        apb_wr.wdata = 32'd1;
        apb_wr.start(apb_sqr);

        `uvm_info(report_id, $sformatf("Operation %0d launched successfully", op_code), UVM_LOW)
    endtask

endclass