module mat_det #(
    parameter N = 4,
    parameter DATA_W = 16
) (
    input  logic                         clk,
    input  logic                         rst_n,
    input  logic signed [DATA_W-1:0]     mat_a [N][N],
    input  logic                         start,
    output logic signed [N*DATA_W-1:0]   det,
    output logic                         singular,
    output logic                         overflow,
    output logic                         calc_done
);
    localparam INTERNAL_W = N * DATA_W;

    typedef enum logic [1:0] {
        IDLE,
        COPY,
        ELIMINATE,
        COMPUTE_DET
    } state_t;

    state_t state, next_state;

    logic signed [INTERNAL_W-1:0] m [N][N];
    logic signed [INTERNAL_W-1:0] pivot;
    logic signed [INTERNAL_W-1:0] prev_pivot;
    logic        [$clog2(N)-1 :0] k;
    logic        [$clog2(N)-1 :0] i;
    logic        [$clog2(N)-1 :0] j;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= IDLE;
        else
            state <= next_state;
    end

    always_comb begin
        next_state = state;
        case (state)
            IDLE:         if (start) next_state = COPY;
            COPY:         next_state = ELIMINATE;
            ELIMINATE:    if (k == N-1) next_state = COMPUTE_DET;
            COMPUTE_DET:  next_state = IDLE;
            default:      next_state = IDLE;
        endcase
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            k          <= 0;
            i          <= 0;
            j          <= 0;
            pivot      <= 0;
            prev_pivot <= 0;
            done       <= 0;
            det        <= 0;
            singular   <= 0;
            overflow   <= 0;

            for (int r = 0; r < N; r++)
                for (int c = 0; c < N; c++)
                    m[r][c] <= 0;
        end
        else begin
            case (state)
                IDLE: begin
                    done     <= 0;
                    det      <= 0;
                    singular <= 0;
                    overflow <= 0;
                    k        <= 0;
                    i        <= 0;
                    j        <= 0;
                    if (start) begin
                        prev_pivot <= 1;
                    end
                end

                COPY: begin
                    for (int r = 0; r < N; r++)
                        for (int c = 0; c < N; c++)
                            m[r][c] <= mat_a[r][c];
                end

                ELIMINATE: begin
                    if (k == 0 && i == 0 && j == 0) begin
                        pivot <= m[0][0];
                    end

                    if (m[k][k] == 0) begin
                        logic found;
                        found = 0;
                        for (int r = k+1; r < N; r++) begin
                            if (m[r][k] != 0 && !found) begin
                                for (int c = 0; c < N; c++) begin
                                    m[k][c] <= m[r][c];
                                    m[r][c] <= m[k][c];
                                end
                                found = 1;
                            end
                        end
                        if (!found) begin
                            singular <= 1;
                        end
                    end

                    if (i < N && j < N) begin
                        if (i > k && j > k) begin
                            m[i][j] <= (pivot * m[i][j] - m[i][k] * m[k][j]) / prev_pivot;
                        end

                        if (j == N-1) begin
                            j <= 0;
                            if (i == N-1) begin
                                i <= k + 2;
                                j <= k + 2;
                                k <= k + 1;
                                if (k + 1 < N) begin
                                    pivot      <= m[k+1][k+1];
                                    prev_pivot <= pivot;
                                end
                            end
                            else begin
                                i <= i + 1;
                            end
                        end
                        else begin
                            j <= j + 1;
                        end
                    end
                end

                COMPUTE_DET: begin
                    logic signed [INTERNAL_W-1:0] result;
                    result = m[N-1][N-1];

                    if (singular) begin
                        det <= 0;
                    end
                    else begin
                        det <= result;

                        if (result[DATA_W-1] == 1'b0)
                            overflow <= |result[INTERNAL_W-1:DATA_W];
                        else
                            overflow <= ~(&result[INTERNAL_W-1:DATA_W]);
                    end

                    calc_done <= 1;
                end
            endcase
        end
    end
endmodule