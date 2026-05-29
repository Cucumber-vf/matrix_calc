import uvm_pkg::*;
import tb_params_pkg::*;
import test_base_pkg::*;
import tests_pkg::*;

module tb_top;

    logic clk;
    logic rst_n;

    apb_if                  apb_intf      (clk, rst_n);
    axis_if #(AXIS::DATA_W) axis_a_intf   (clk, rst_n);
    axis_if #(AXIS::DATA_W) axis_b_intf   (clk, rst_n);
    axis_if #(AXIS::DATA_W) axis_res_intf (clk, rst_n);

    // ===========================
    // BFMs
    // =========================== 

    clk_bfm                clk_drv_bfm      (clk                  );
    rst_driver_bfm         rst_drv_bfm      (rst_n                );
    rst_monitor_bfm        rst_mon_bfm      (rst_n                );

    apb_driver_bfm         apb_drv_bfm      (apb_intf.master      );
    apb_monitor_bfm        apb_mon_bfm      (apb_intf.monitor     );

    axis_master_driver_bfm axis_m_a_drv_bfm (axis_a_intf.master   );
    axis_monitor_bfm       axis_m_a_mon_bfm (axis_a_intf.monitor  );

    axis_master_driver_bfm axis_m_b_drv_bfm (axis_b_intf.master   );
    axis_monitor_bfm       axis_m_b_mon_bfm (axis_b_intf.monitor  );

    axis_slave_driver_bfm  axis_s_drv_bfm   (axis_res_intf.slave  );
    axis_monitor_bfm       axis_s_mon_bfm   (axis_res_intf.monitor);

    // ===========================
    // DUT
    // =========================== 

    matrix_calc_wrapper #(
        .N      (TEST::N     ),
        .DATA_W (AXIS::DATA_W)
    ) dut_wrapped (
        .clk           (clk                 ),
        .rst_n         (rst_n               ),

        .apb_intf      (apb_intf.slave      ),
        .axis_a_intf   (axis_a_intf.slave   ),
        .axis_b_intf   (axis_b_intf.slave   ),
        .axis_res_intf (axis_res_intf.master)
    );

    // ===========================
    // Test
    // =========================== 

    initial begin
        uvm_config_db#(virtual clk_bfm               )::set(null, "uvm_test_top", "clk_drv_bfm",      clk_drv_bfm     );
        uvm_config_db#(virtual rst_driver_bfm        )::set(null, "uvm_test_top", "rst_drv_bfm",      rst_drv_bfm     );
        uvm_config_db#(virtual rst_monitor_bfm       )::set(null, "uvm_test_top", "rst_mon_bfm",      rst_mon_bfm     );

        uvm_config_db#(virtual apb_driver_bfm        )::set(null, "uvm_test_top", "apb_drv_bfm",      apb_drv_bfm     );
        uvm_config_db#(virtual apb_monitor_bfm       )::set(null, "uvm_test_top", "apb_mon_bfm",      apb_mon_bfm     );

        uvm_config_db#(virtual axis_master_driver_bfm)::set(null, "uvm_test_top", "axis_m_a_drv_bfm", axis_m_a_drv_bfm);
        uvm_config_db#(virtual axis_monitor_bfm      )::set(null, "uvm_test_top", "axis_m_a_mon_bfm", axis_m_a_mon_bfm);

        uvm_config_db#(virtual axis_master_driver_bfm)::set(null, "uvm_test_top", "axis_m_b_drv_bfm", axis_m_b_drv_bfm);
        uvm_config_db#(virtual axis_monitor_bfm      )::set(null, "uvm_test_top", "axis_m_b_mon_bfm", axis_m_b_mon_bfm);

        uvm_config_db#(virtual axis_slave_driver_bfm )::set(null, "uvm_test_top", "axis_s_drv_bfm",   axis_s_drv_bfm  );
        uvm_config_db#(virtual axis_monitor_bfm      )::set(null, "uvm_test_top", "axis_s_mon_bfm",   axis_s_mon_bfm  );
    end

    initial begin
        run_test();
    end

endmodule