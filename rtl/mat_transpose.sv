module mat_transpose #(
    parameter N      = 4,
    parameter DATA_W = 16
) (
    input  logic signed [DATA_W-1:0]   mat_a   [N][N],

    output logic signed [DATA_W-1:0]   mat_res [N][N]
);

    genvar i, j;
    generate
        for (i = 0; i < N; i++) begin : gen_row
            for (j = 0; j < N; j++) begin : gen_col
                assign mat_res[i][j] = mat_a[j][i];
            end
        end  
    endgenerate

endmodule