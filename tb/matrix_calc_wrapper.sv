module matrix_calc_wrapper #(
    parameter N      = 4,    
    parameter DATA_W = 16    
) (
    input clk,
    input rst_n,

    apb_if  apb_intf,
    axis_if axis_a_intf,
    axis_if axis_b_intf,
    axis_if axis_res_intf
);

    matrix_calc #(
        .N      (N),
        .DATA_W (DATA_W)
    ) dut (
        .clk               (clk),
        .rst_n             (rst_n),

        .psel              (apb_intf.psel),
        .penable           (apb_intf.penable),
        .pwrite            (apb_intf.pwrite),
        .paddr             (apb_intf.paddr),
        .pwdata            (apb_intf.pwdata),
        .prdata            (apb_intf.prdata),
        .pready            (apb_intf.pready),
        .pslverr           (apb_intf.pslverr),

        .s_axis_a_tdata    (axis_a_intf.tdata),
        .s_axis_a_tvalid   (axis_a_intf.tvalid),
        .s_axis_a_tlast    (axis_a_intf.tlast),
        .s_axis_a_tready   (axis_a_intf.tready),

        .s_axis_b_tdata    (axis_b_intf.tdata),
        .s_axis_b_tvalid   (axis_b_intf.tvalid),
        .s_axis_b_tlast    (axis_b_intf.tlast),
        .s_axis_b_tready   (axis_b_intf.tready),

        .m_axis_res_tdata  (axis_res_intf.tdata),
        .m_axis_res_tvalid (axis_res_intf.tvalid),
        .m_axis_res_tlast  (axis_res_intf.tlast),
        .m_axis_res_tready (axis_res_intf.tready)
    );

endmodule