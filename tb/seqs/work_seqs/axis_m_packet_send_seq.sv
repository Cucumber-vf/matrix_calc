class axis_m_packet_send_seq #(parameter int N = 4, parameter int DATA_W = 16) extends uvm_sequence #(uvm_sequence_item);

    `uvm_object_param_utils(axis_m_packet_send_seq #(N, DATA_W))

    const string report_id = "axis_m_packet_send_seq";

    logic signed [DATA_W - 1:0] matrix_data[N][N];
    bit correct_tlast;
    int cnt;

    axis_m_send_seq #(DATA_W) elem_seq;

    function new (string name = "axis_m_packet_send_seq");
        super.new(name);
    endfunction

    task body();
        elem_seq = axis_m_send_seq #(DATA_W)::type_id::create("elem_seq");

        cnt = 0;

        for (int i = 0; i < 2*N*N; i++) begin
            if (cnt == N*N) cnt = 0;

            if (correct_tlast) begin
                if (!elem_seq.randomize() with {
                    tdata   == local::matrix_data[cnt/N][cnt%N];
                    is_last == (cnt == N*N - 1);
                }) `uvm_error(report_id, "Elem seq randomize failed")
            end 
            else if (i == 2*N*N-1) begin
                if (!elem_seq.randomize() with {
                    tdata   == local::matrix_data[cnt/N][cnt%N];
                    is_last == 1;
                }) `uvm_error(report_id, "Elem seq randomize failed")
            end
            else begin
                if (!elem_seq.randomize() with {
                    tdata   == local::matrix_data[cnt/N][cnt%N];
                }) `uvm_error(report_id, "Elem seq randomize failed")
            end
        
            elem_seq.start(m_sequencer);

            if (elem_seq.is_last) break;
            else cnt++;
        end
    endtask

endclass