package axis_slave_pkg;

   import uvm_pkg::*;
   import bfm_types_pkg::tready_policy_e;
   
   import axis_master_pkg::axis_seq_item_t; 
   import axis_master_pkg::axis_config; 
   import axis_master_pkg::axis_monitor;  
   
   `include "axis_slave_config.sv"
   `include "axis_slave_driver.sv"
   `include "axis_slave_agent.sv"

endpackage
