module mat_det #(
    parameter N = 4,
    parameter DATA_W = 16
) (
    input  logic                     clk,
    input  logic                     rst_n,
    input  logic signed [DATA_W-1:0] mat_a [N][N],
    
    output logic signed [DATA_W-1:0] det,
    output logic                     singular,
    output logic                     overflow
);
    localparam INTERNAL_W = 2 * DATA_W;

    function automatic logic signed [INTERNAL_W-1:0] determinant_laplace(
        input logic signed [DATA_W-1:0] m [N][N],
        input int size
    );
        logic signed [DATA_W-1    :0] submatrix [N][N];
        logic signed [INTERNAL_W-1:0] result;
        int i, j, sub_i, sub_j;
        int sign;

        if (size == 1) begin
            return m[0][0];
        end

        if (size == 2) begin
            return (m[0][0] * m[1][1]) - (m[0][1] * m[1][0]);
        end

        result = 0;
        sign   = 1;

        for (j = 0; j < size; j++) begin
            sub_i = 0;
            for (i = 1; i < size; i++) begin
                sub_j = 0;
                for (int k = 0; k < size; k++) begin
                    if (k != j) begin
                        submatrix[sub_i][sub_j] = m[i][k];
                        sub_j++;
                    end
                end
                sub_i++;
            end

            result = result + (sign * m[0][j]) * determinant_laplace(submatrix, size - 1);
            sign = -sign;
        end

        return result;
    endfunction

    logic signed [INTERNAL_W-1:0] det_ext;

    always_comb begin
        det_ext  = determinant_laplace(mat_a, N);
        det      = det_ext[DATA_W-1:0];
        singular = (det_ext == 0);

        if (det_ext[DATA_W-1] == 1'b0)
            overflow = |det_ext[INTERNAL_W-1:DATA_W];
        else
            overflow = ~(&det_ext[INTERNAL_W-1:DATA_W]);
    end
endmodule