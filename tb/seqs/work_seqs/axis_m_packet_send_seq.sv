class axis_m_packet_send_seq #(parameter int N = 4, parameter int DATA_W = 16) extends axis_m_seq_base #(DATA_W);

    `uvm_object_param_utils(axis_m_packet_send_seq #(N, DATA_W))

    const string report_id = "axis_m_packet_send_seq";

    rand logic signed [DATA_W - 1:0] matrix_data[N][N];
    bit correct_tlast = 1'b1;

    axis_m_send_seq #(DATA_W) elem_seq;

    function new (string name = "axis_m_packet_send_seq");
        super.new(name);
    endfunction

    task body();
        if (axis_m_cfg == null) get_config();
        if (!axis_m_cfg_ready) return;

        elem_seq = axis_m_send_seq #(DATA_W)::type_id::create("elem_seq");

        for (int i = 0; i < N*N; i++) begin
            if (correct_tlast) begin
                if (!elem_seq.randomize() with {
                    tdata   == local::matrix_data[i/N][i%N];
                    is_last == (i == N*N - 1);
                }) `uvm_error(report_id, "Elem seq randomize failed")
            end else begin
                if (!elem_seq.randomize() with {
                    tdata   == local::matrix_data[i/N][i%N];
                }) `uvm_error(report_id, "Elem seq randomize failed")
            end
        
            elem_seq.start(m_sequencer);

            if (elem_seq.is_last) break;
        end
    endtask

endclass