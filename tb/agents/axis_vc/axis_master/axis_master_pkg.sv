package axis_master_pkg;

   import uvm_pkg::*;
   import bfm_types_pkg::axis_m_drv_seq_item_s;
   import tb_params_pkg::AXIS;
   
   `include "../axis_seq_item.sv"
   typedef axis_seq_item #(AXIS::DATA_W) axis_seq_item_t;
   `include "axis_m_drv_seq_item.sv"
   typedef axis_m_drv_seq_item #(AXIS::DATA_W) axis_m_drv_seq_item_t;
   
   `include "../axis_config.sv"
   `include "axis_master_config.sv"
   `include "axis_master_driver.sv"
   `include "../axis_monitor.sv"
   `include "axis_master_agent.sv"

endpackage