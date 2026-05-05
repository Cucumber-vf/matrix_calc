module axis_driver #(
    parameter N      = 4,
    parameter DATA_W = 16
) (
    input  logic                     clk,
    input  logic                     rst_n,
    
    output logic signed [DATA_W-1:0] m_tdata,
    output logic                     m_tvalid,
    output logic                     m_tlast,

    input  logic                     m_tready
);

    task reset_axis

        wait(~rst_n);
        m_tvalid <= 0;
        m_tlast  <= 0;
        wait(rst_n);

    endtask

    task axis_send (input signed [DATA_W-1:0] data_array [N][N]);
    
        @(posedge clk);
        for (i = 0; i < N*N; i++) begin
            col = i % N;
            row = i / N;
            
            m_tvalid <= 1;
            m_tdata  <= data_array[col][row];
            m_tlast  <= (i == N*N - 1);
            while(~m_tredy) begin
                @(posedge clk);
            end
            m_tvalid <= 0;
            m_tlast  <= 0;
             repeat ($urandom_range(0, 5)) @(posedge clk);
        end

    endtask

endmodule