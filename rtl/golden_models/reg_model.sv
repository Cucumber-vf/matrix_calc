class reg_model;
 
    typedef struct {
        logic [31:0] value;
        bit   [31:0] valid_bits;
    
        e_reg_acces_type acces_type;
    } s_apb_reg;

    s_apb_reg reg_op, reg_ctrl, reg_status;
    s_apb_reg apb_regs[e_reg_addreses];

    function new();
        reg_op = '{
            value     :    '0,
            valid_bits: 2'b11,
            acces_type:    RW
        };
        reg_ctrl = '{
            value     :    '0,
            valid_bits: 2'b11,
            acces_type:    RW
        };
        reg_status = '{
            value     :       '0,
            valid_bits: 5'b11111,
            acces_type:       RO
        };

        apb_regs[REG_OP]     = reg_op;
        apb_regs[REG_CTRL]   = reg_ctrl;
        apb_regs[REG_STATUS] = reg_status;
    endfunction

    function void reset_regs;
        foreach (apb_regs[i]) begin
            apb_regs[i].value = '0;
        end
    endfunction

endclass