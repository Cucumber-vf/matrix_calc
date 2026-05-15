module mat_det #(
    parameter int N = 4,
    parameter int DATA_W = 16
) (
    //
    input  logic                       clk,
    input  logic                       rst_n,

    //
    input  logic signed [  DATA_W-1:0] mat_a [N][N],
    input  logic                       start,

    output logic signed [N*DATA_W-1:0] det,
    output logic                       singular,
    output logic                       calc_done
);

    localparam int INTERNAL_W = N * DATA_W;
    localparam int IDX_W      = $clog2(N);

    typedef enum logic [2:0] {
        IDLE,
        COPY,
        PIVOT_SEARCH,
        ELIMINATE,
        COMPUTE_DET
    } state_t;

    state_t state, next_state;

    logic signed [  INTERNAL_W-1:0] m [N][N];
    logic signed [  INTERNAL_W-1:0] pivot;
    logic signed [  INTERNAL_W-1:0] prev_pivot;

    logic signed [  INTERNAL_W-1:0] tmp_val [N];
    logic signed [2*INTERNAL_W-1:0] prod1, prod2;
    logic signed [  INTERNAL_W-1:0] elim_result;

    logic [IDX_W-1:0] k, i, j, swap_row;
    logic             sign_neg;

    logic             found;
    logic             pivot_is_zero;

    always_comb begin
        elim_result = 0;
        prod1 = 0; 
        prod2 = 0;
    
        if (state == ELIMINATE) begin
            prod1 = $signed({{INTERNAL_W{pivot[INTERNAL_W-1]}}, pivot}) * m[i][j];
            prod2 = $signed({{INTERNAL_W{m[i][k][INTERNAL_W-1]}}, m[i][k]}) * m[k][j];
       
        elim_result = (prod1 - prod2) / prev_pivot;
        end
    end

    always_comb begin
        found         = 0;
        pivot_is_zero = 0;
        swap_row      = k;
        tmp_val       = '{default:'0};

        if (state == PIVOT_SEARCH) begin
            if (m[k][k] == 0) begin
                pivot_is_zero = 1;
                for (int r = k + 1; r < N; r++) begin
                    if (m[r][k] != 0 && !found) begin
                        swap_row = r;
                        found    = 1;
                    end
                end
                if (found) begin
                    for (int c = 0; c < N; c++) begin
                        tmp_val[c] = m[k][c];
                    end
                end
            end
        end
    end

    always_comb begin
        next_state = state;
        case (state)
            IDLE:
                if (start) next_state = COPY;
            COPY:
                next_state = PIVOT_SEARCH;
            PIVOT_SEARCH:
                if (pivot_is_zero && !found)
                    next_state = COMPUTE_DET;
                else
                    next_state = ELIMINATE;
            ELIMINATE:
                if (i == N-1 && j == N-1)
                    if (k == N-2)
                        next_state = COMPUTE_DET;
                    else
                        next_state = PIVOT_SEARCH; 
                else
                    next_state = ELIMINATE;
            COMPUTE_DET:
                next_state = IDLE;
            default:
                next_state = IDLE;
        endcase
    end

    always_ff @(posedge clk) begin
        if (!rst_n)
            state <= IDLE;
        else
            state <= next_state;
    end

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            k          <= 0;
            i          <= 0;
            j          <= 0;
            pivot      <= 0;
            prev_pivot <= 1;
            sign_neg   <= 0;

            singular   <= 0;
            calc_done  <= 0;
            det        <= 0;

            for (int r = 0; r < N; r++)
                for (int c = 0; c < N; c++)
                    m[r][c] <= 0;
        end
        else begin

            case (state)
                IDLE: begin
                    if (start) begin
                        k          <= 0;
                        prev_pivot <= 1;
                        sign_neg   <= 0;
                        calc_done  <= 0;

                        singular   <= 0;
                        det        <= 0;
                    end
                end

                COPY: begin
                    for (int r = 0; r < N; r++)
                        for (int c = 0; c < N; c++)
                            m[r][c] <= mat_a[r][c];
                end

                PIVOT_SEARCH: begin
                    if (pivot_is_zero && !found) begin
                        singular <= 1;
                    end
                    else begin
                        i <= k + 1;
                        j <= k + 1;

                        if (found) begin
                            sign_neg <= ~sign_neg;
                            for (int c = 0; c < N; c++) begin
                                m[k][c]        <= m[swap_row][c];
                                m[swap_row][c] <= tmp_val[c];
                            end
                        end
                        
                        pivot <= m[k][k];
                    end
                end

                ELIMINATE: begin
                    m[i][j] <= elim_result;

                    if (j == N - 1) begin
                        j <= k + 1;
                        if (i == N - 1) begin
                            k <= k + 1;
                            prev_pivot <= pivot;
                        end
                        else
                            i <= i + 1;
                    end
                    else begin
                        j <= j + 1;
                    end
                end

                COMPUTE_DET: begin
                    if (singular)
                        det <= '0;
                    else
                        det <= sign_neg ? -m[N-1][N-1] : m[N-1][N-1];
                    
                    calc_done <= 1;
                end

            endcase
        end
    end

endmodule