package bfm_types_pkg;

    import tb_params_pkg::*;

    typedef struct {
        logic [31:0] paddr;
        logic        pwrite;
        logic [31:0] pwdata;

        logic [31:0] prdata;
        logic        pslverr;
    } apb_seq_item_s;

    typedef struct {
        logic signed [AXIS::DATA_W - 1:0] tdata; 
        logic                             is_last;

        int                               delay;
    } axis_seq_item_s;

    typedef enum {ALWAYS_HIGH, TOGGLE} tready_policy_e;

endpackage