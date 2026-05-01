module matrix_calc #(
    parameter N      = 4,    
    parameter DATA_W = 16    
) (
    //
    input  logic        clk,
    input  logic        rst_n,        
    
    //
    input  logic        psel,
    input  logic        penable,
    input  logic        pwrite,
    input  logic [7:0]  paddr,
    input  logic [31:0] pwdata,

    output logic [31:0] prdata,
    output logic        pready,       
    output logic        pslverr,
    
    //
    input  logic signed [DATA_W-1:0] s_axis_a_tdata,
    input  logic                     s_axis_a_tvalid,
    input  logic                     s_axis_a_tlast,   
    output logic                     s_axis_a_tready,

    //
    input  logic signed [DATA_W-1:0] s_axis_b_tdata,
    input  logic                     s_axis_b_tvalid,
    input  logic                     s_axis_b_tlast,
    output logic                     s_axis_b_tready,

    //
    output logic signed [DATA_W-1:0] m_axis_res_tdata,
    output logic                     m_axis_res_tvalid,
    output logic                     m_axis_res_tlast,  
    input  logic                     m_axis_res_tready             
);

    apb_csr u_apb_csr (
        .clk     (clk),
        .rst_n   (rst_n),
        .psel    (psel),
        .penable (penable),
        .pwrite  (pwrite),
        .paddr   (paddr),
        .pwdata  (pwdata),
        .prdata  (prdata),
        .pready  (pready),
        .pslverr (pslverr)
    );
    
    axis_rx #(
        .N         (N),
        .DATA_W    (DATA_W)
    ) u_axis_rx_a (
        .clk       (clk),
        .rst_n     (rst_n),
        .s_tdate   (s_axis_a_tdata),
        .s_tvalid  (s_axis_a_tvalid),
        .s_tlast   (s_axis_a_tlast),
        .s_tready  (s_axis_a_tready),
        .flush     (flush),
        .mat       (mat_a),
        .recv_done (recv_a_done)
    );

    axis_rx #(
        .N         (N),
        .DATA_W    (DATA_W)
    ) u_axis_rx_b (
        .clk       (clk),
        .rst_n     (rst_n),
        .s_tdate   (s_axis_b_tdata),
        .s_tvalid  (s_axis_b_tvalid),
        .s_tlast   (s_axis_b_tlast),
        .s_tready  (s_axis_b_tready),
        .flush     (flush),
        .mat       (mat_b),
        .recv_done (recv_b_done)
    );

    mat_addsub #(
        .N        (N),
        .DATA_W   (DATA_W)
    ) u_mat_addsub (
        .mat_a    (mat_a),
        .mat_b    (mat_b),
        .op       (),
        .mat_res  (mat_addsub_res),
        .overflow (addsub_overflow)
    );

    mat_transpose #(
        .N        (N),
        .DATA_W   (DATA_W)
    ) u_mat_transpose (
        .mat_a    (mat_a),
        .mat_res  (mat_transpose_res)
    );

    mat_det #(
        .N        (N),
        .DATA_W   (DATA_W)
    ) u_mat_det (
        .clk      (clk),
        .rst_n    (rst_n),
        .mat_a    (mat_a),
        .det      (det),
        .overflow (det_overflow),
        .singular (det_singular)
    );

    axis_tx #(
        .N         (N),
        .DATA_W    (DATA_W)
    ) u_axis_tx (
        .clk       (clk),
        .rst_n     (rst_n),
        .send      (send),
        .is_scalar (is_scalar),
        .mat_in    (res_mat),
        .scalar    (res_mat[0][0]),
        .m_tdata   (m_axis_res_tdata),
        .m_tvalid  (m_axis_res_tvalid),
        .m_tlast   (m_axis_res_tlast),
        .m_tready  (m_axis_res_tready)
    );

endmodule