module mat_det #(
    parameter N      = 4
    parameter DATA_W = 16
) (
    input  logic                     clk,
    input  logic                     rst_n,        // сброс, активный низкий
    
    input  logic signed [DATA_W-1:0] mat_a [N][N],
    
    output logic signed [DATA_W-1:0] det   [N][N],

    output logic                     overflow,
    output logic                     singular
);

assign mat[0][0] = 0;

endmodule