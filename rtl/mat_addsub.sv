module mat_addsub #(
    parameter N      = 4
    parameter DATA_W = 16
) (
    input  logic                       op,
    
    input  logic signed [DATA_W-1:0]   mat_a   [N][N],
    input  logic signed [DATA_W-1:0]   mat_b   [N][N],
    
    output logic signed [DATA_W-1:0]   mat_res [N][N],
    output logic                       overflow
);

    logic signed [DATA_W:0] sum_ext; 
    logic overflow_comb [N][N];
    
    genvar i, j;
    generate
        for (i = 0; i < N; i++) begin : gen_row
            for (j = 0; j < N; j++) begin : gen_col
                if (op) begin
                    assign sum_ext = mat_a[i][j] - mat_b[i][j];
                    assign mat_res[i][j] = sum_ext[DATA_W-1:0];

                    assign overflow_comb[i][j] = (mat_a[i][j][DATA_W-1] != mat_b[i][j][DATA_W-1]) &&
                                                 (mat_b[i][j][DATA_W-1] == mat_res[i][j][DATA_W-1]);
                end else begin
                    assign sum_ext = mat_a[i][j] + mat_b[i][j];
                    assign mat_res[i][j] = sum_ext[DATA_W-1:0];
                    
                    assign overflow_comb[i][j] = (mat_a[i][j][DATA_W-1] == mat_b[i][j][DATA_W-1]) &&
                                                 (mat_a[i][j][DATA_W-1] != mat_res[i][j][DATA_W-1]);
                end
            end
        end
    endgenerate
    
    assign overflow = |overflow_comb;
            
endmodule