module tb_matrix_calc;

    localparam T      = 10;
    localparam N      = 4;    
    localparam DATA_W = 16;   

    //=================================================

    logic        clk;
    logic        rst_n;   

    //
    logic        psel;
    logic        penable;
    logic        pwrite;
    logic [7:0]  paddr;
    logic [31:0] pwdata;
    logic [31:0] prdata;
    logic        pready;      
    logic        pslverr;

    //
    logic signed [DATA_W-1:0] s_axis_a_tdata;
    logic                     s_axis_a_tvalid;
    logic                     s_axis_a_tlast;   
    logic                     s_axis_a_tready;

    //
    logic signed [DATA_W-1:0] s_axis_b_tdata;
    logic                     s_axis_b_tvalid;
    logic                     s_axis_b_tlast;
    logic                     s_axis_b_tready;

    //
    logic signed [DATA_W-1:0] m_axis_res_tdata;
    logic                     m_axis_res_tvalid;
    logic                     m_axis_res_tlast; 
    logic                     m_axis_res_tready;

    //=================================================

    // DUT 
    matrix_calc #( .N(N), .DATA_W(DATA_W) ) dut (
        .*
    );
    
    //=================================================

    // Classes
    //apb_driver  apb_drv (.*); 

    //=================================================

    // Clock and Reset gen
    initial begin
        clk <= 0;
        forever begin
            #(T/2) clk <= ~clk;
        end
    end 

    initial begin

        @(posedge clk);
        rst_n <= 0;
        @(posedge clk);
        rst_n <= 1;
    end

    //=================================================

    initial begin

        
    end
    
    /*
    function void ref_mat_addsub #(
    parameter N      = 4,
    parameter DATA_W = 16
    )(
        input  signed [DATA_W-1:0] mat_a [N][N],
        input  signed [DATA_W-1:0] mat_b [N][N],
        input                      sub,
        output signed [DATA_W-1:0] mat_c [N][N],
        output                     overflow
    );
    int signed [DATA_W:0] sum;
    overflow = 1'b0;
    
    for (int r = 0; r < N; r++) begin
        for (int c = 0; c < N; c++) begin
            if (sub)
                sum = mat_a[r][c] - mat_b[r][c];
            else
                sum = mat_a[r][c] + mat_b[r][c];

            if (sum[DATA_W] != sum[DATA_W-1])
                overflow = 1'b1;
            
            mat_c[r][c] = sum[DATA_W-1:0];
        end
    end
    endfunction

    function void ref_mat_transpose #(
        parameter N      = 4,
        parameter DATA_W = 16
    )(
        input  signed [DATA_W-1:0] mat_a [N][N],
        output signed [DATA_W-1:0] mat_c [N][N]
    );
        for (int r = 0; r < N; r++) begin
            for (int c = 0; c < N; c++) begin
                mat_c[r][c] = mat_a[c][r];
            end
        end
    endfunction
    */
endmodule