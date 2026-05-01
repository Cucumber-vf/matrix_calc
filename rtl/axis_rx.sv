module axis_rx #(
    parameter N      = 4,
    parameter DATA_W = 16
) (
    //
    input  logic                     clk,
    input  logic                     rst_n,
    
    //
    input  logic signed [DATA_W-1:0] s_tdata,
    input  logic                     s_tvalid,
    input  logic                     s_tlast,

    output logic                     s_tready,
    
    //
    input  logic                     flush, 

    output logic signed [DATA_W-1:0] mat [N][N],
    output logic                     recv_done,
    output logic                     rx_err
);
    
    localparam W_COL_ROW_CNT = $clog2(N);

    localparam TOTAL         = N * N;
    localparam W_CNT         = $clog2(TOTAL);
 
    typedef enum logic [1:0] {
        IDLE   = 2'b00,
        RECV   = 2'b01,
        RX_ERR = 2'b10
    } state_t;

    state_t state, next_state;

    logic [W_COL_ROW_CNT - 1:0] row_cnt, col_cnt;
    logic [W_CNT         - 1:0] cnt;

    always_ff @(posedge clk) begin
        if(~rst_n) begin
            cnt     <= '0;
            row_cnt <= '0;
            col_cnt <= '0;
        end else if(flush) begin
            cnt     <= '0;
            row_cnt <= '0;
            col_cnt <= '0;
        end else if(s_tvalid && s_tready) begin
            cnt <= cnt + 1;
            if(col_cnt == N - 1) begin
                col_cnt <= '0;
                row_cnt <= row_cnt + 1;
            end else begin
                col_cnt <= col_cnt + 1;
            end
        end
    end

    always_ff @(posedge clk)
        if(~rst_n)
            state <= IDLE;
        else
            state <= next_state;

    always_comb begin
        next_state = state

        case(state)
            IDLE: 
                if(s_tvalid && s_tready && s_tlast && (cnt == TOTAl - 1)) 
                    next_state = BUSY;
                else if(s_tvalid && s_tready && s_tlast && (cnt != TOTAl - 1)) 
                    next_state = RX_ERR;
            BUSY: 
                if(flush) next_state == IDLE;
            RX_ERR:
                if(flush) next_state == IDLE;
        endcase
    end

    always_ff @(posedge clk) begin
        if (s_tvalid && s_tready)
            mat [row_cnt][col_cnt] <= s_tdata;
    end

    assign s_tready  = (state == IDLE) && (next_sate == IDLE);
    assign recv_done = (state == BUSY);
    assign rx_err    = (state == RX_ERR);

endmodule
