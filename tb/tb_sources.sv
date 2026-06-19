`include "uvm_pkg.sv"
`ifdef XCELIUM
`ifndef ADDED_XCELIUM
  `define ADDED_XCELIUM
  `include "cdns_uvm_pkg.sv"
`endif
`endif
`include "uvm_macros.svh"

`include "if/apb_if.sv"
`include "if/axis_if.sv"

`include "tb_params_pkg.sv"

`include "bfms/bfm_types_pkg.sv"
`include "bfms/clk_bfm.sv"
`include "bfms/rst_driver_bfm.sv"
`include "bfms/rst_monitor_bfm.sv"
`include "bfms/apb_driver_bfm.sv"
`include "bfms/apb_monitor_bfm.sv"
`include "bfms/axis_master_driver_bfm.sv"
`include "bfms/axis_monitor_bfm.sv"
`include "bfms/axis_slave_driver_bfm.sv"

`include "agents/clk_vc/clk_agent_pkg.sv"
`include "agents/rst_vc/rst_agent_pkg.sv"
`include "agents/apb_vc/apb_master_pkg.sv"
`include "agents/axis_vc/axis_master/axis_master_pkg.sv"
`include "agents/axis_vc/axis_slave/axis_slave_pkg.sv"

`include "env/matrix_calc_env_pkg.sv"
`include "seqs/seq_lib_pkg.sv"

`include "tests/tests_pkg.sv"

//=====================
`include "../rtl/apb_csr/apb_csr.sv"
`include "../rtl/axis_rx/axis_rx.sv"
`include "../rtl/axis_tx/axis_tx.sv"
`include "../rtl/mat_op/mat_addsub.sv"
`include "../rtl/mat_op/mat_transpose.sv"
`include "../rtl/mat_op/mat_det.sv"
`include "../rtl/matrix_calc.sv"
//=====================

`include "matrix_calc_wrapper.sv"
`include "tb_top.sv"
