module mat_addsub #(
    parameter N = 4,
    parameter DATA_W = 16
) (
    input  logic signed [DATA_W-1:0] mat_a [N][N],
    input  logic signed [DATA_W-1:0] mat_b [N][N],
    input  logic                     sub,
    
    output logic signed [DATA_W-1:0] mat_c [N][N],
    output logic                     overflow
);
    logic signed [DATA_W:0] result_ext [N][N];
    logic [N-1:0][N-1:0] elem_overflow;

    genvar r, c;
    generate
        for (r = 0; r < N; r++) begin : gen_row
            for (c = 0; c < N; c++) begin : gen_col
                assign result_ext[r][c] = sub
                    ? mat_a[r][c] - mat_b[r][c]
                    : mat_a[r][c] + mat_b[r][c];

                assign elem_overflow[r][c] = 
                    result_ext[r][c][DATA_W] ^ result_ext[r][c][DATA_W-1];

                assign mat_c[r][c] = elem_overflow[r][c]
                    ? '1 : result_ext[r][c][DATA_W-1:0];
            end
        end
    endgenerate

    assign overflow = |elem_overflow;
endmodule