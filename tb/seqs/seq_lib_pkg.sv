package seq_lib_pkg;

    import uvm_pkg::*;

    `include "../env/apb_regs_def.svh"
    import tb_params_pkg::*;

    import apb_master_pkg::apb_seq_item;
    import axis_master_pkg::axis_m_drv_seq_item;
    import rst_agent_pkg::rst_seq_item;

    import axis_master_pkg::axis_master_config;
    import rst_agent_pkg::rst_config;
    import matrix_calc_env_pkg::env_config;

    // Base_seqs
    `include "base_seqs/apb_seq_base.sv"
    `include "base_seqs/axis_m_seq_base.sv"
    `include "base_seqs/rst_seq_base.sv"

    // API_seqs
    `include "API_seqs/apb_read_seq.sv"
    `include "API_seqs/apb_write_seq.sv"
    `include "API_seqs/axis_m_send_seq.sv"
    `include "API_seqs/rst_start_seq.sv"

    // Work_seqs
    `include "work_seqs/axis_m_packet_send_seq.sv"
    `include "work_seqs/matrix_calc_op_vseq.sv"

    // Vseqs
    `include "top_vseq_base.sv"
    `include "test_vseq.sv"
    `include "reg_test_vseq.sv"
    `include "mat_test_vseq.sv"
    
    typedef top_vseq_base #(TEST::N, AXIS::DATA_W) top_vseq_base_t;
    typedef test_vseq #(TEST::N, AXIS::DATA_W) test_vseq_t;
    typedef reg_test_vseq #(TEST::N, AXIS::DATA_W) reg_test_vseq_t;
    typedef mat_test_vseq #(TEST::N, AXIS::DATA_W) mat_test_vseq_t;

endpackage