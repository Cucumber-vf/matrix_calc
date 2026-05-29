class regs_model extends uvm_object;
 
    `uvm_object_utils(regs_model)

    typedef struct {
        logic [31:0] value;
        bit   [31:0] valid_bits;
    
        e_reg_acces_type acces_type;
    } s_apb_reg;

    s_apb_reg reg_op, reg_ctrl, reg_status;
    s_apb_reg apb_regs[e_regs_addresses];

    function new (name = "regs_model");
        super.new(name);

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

    function void write_to_reg (logic [7:0] addr, logic [31:0] wdata);
        if (addr inside {valid_addresses} && apb_regs[e_regs_addresses'(addr)].acces_type == RW) begin
            apb_regs[e_regs_addresses'(addr)].value = wdata & apb_regs[e_regs_addresses'(addr)].valid_bits;
        end
    endfunction

    function void read_reg (logic [7:0] addr, output logic [31:0] rdata);
        if (addr inside {valid_addresses}) begin
            rdata = apb_regs[e_regs_addresses'(addr)].value;
        end
    endfunction

endclass