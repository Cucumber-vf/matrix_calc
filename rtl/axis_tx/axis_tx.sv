module axis_tx #(
    parameter N      = 4,
    parameter DATA_W = 16
) (
    input  logic                       clk,
    input  logic                       rst_n,

    input  logic                       send,
    input  logic                       is_scalar,

    input  logic signed [  DATA_W-1:0] mat_in [N][N],
    input  logic signed [N*DATA_W-1:0] scalar_in,
    
    output logic signed [  DATA_W-1:0] m_tdata,
    output logic                       m_tvalid,
    output logic                       m_tlast,

    input  logic                       m_tready
);

    localparam W_COL_ROW_CNT = $clog2(N);

    localparam TOTAL         = N * N;
    localparam W_CNT         = $clog2(TOTAL);
 
    typedef enum logic {
        IDLE = 1'b0,
        SEND = 1'b1
    } state_t;

    state_t state, next_state;

    logic [W_COL_ROW_CNT - 1:0] row_cnt, col_cnt;
    logic [W_CNT         - 1:0] cnt;

    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            cnt         <= '0;
            row_cnt     <= '0;
            col_cnt     <= '0;
        end 
        else if (next_state == IDLE) begin  
            cnt         <= '0;
            row_cnt     <= '0;
            col_cnt     <= '0;
        end 
        else if (state == SEND) begin
            if (m_tvalid && m_tready) begin
                cnt <= cnt + 1;
                if (col_cnt == N - 1) begin
                    col_cnt <= '0;
                    row_cnt <= row_cnt + 1;
                end else begin
                    col_cnt <= col_cnt + 1;
                end
            end
        end
    end
    
    always_ff @(posedge clk or negedge rst_n)
        if (~rst_n)
            state <= IDLE;
        else
            state <= next_state;

    always_comb begin
        next_state = state;

        case (state)
            IDLE: 
                if (send) next_state = SEND;
            SEND: 
                if (m_tvalid && m_tready && m_tlast) next_state = IDLE;
        endcase
    end

    always_comb begin
        if (state == SEND) begin
            if(is_scalar) begin
                m_tdata = scalar_in[cnt * DATA_W +: DATA_W];
            end
            else begin
                m_tdata = mat_in [row_cnt][col_cnt];
            end
        end
        m_tvalid = (state == SEND);
        m_tlast  = (state == SEND) && ((cnt == TOTAL - 1) || (is_scalar && (cnt == N - 1)));
    end

endmodule
