package apb_package;

    typedef enum logic [7:0] {
        REG_OP     = 8'h00,
        REG_CTRL   = 8'h04,
        REG_STATUS = 8'h08
    } e_reg_addreses;

    typedef enum bit [2:0] {
        DONE     = 0,
        BUSY     = 1,
        OVERFLOW = 2,
        SINGULAR = 3,
        RX_ERR   = 4
    } e_status_bits;

    typedef enum bit {
        RO = 0,
        RW = 1
    } e_reg_acces_type;
    
    const logic [7:0] valid_addresses [] = { REG_OP, REG_CTRL, REG_STATUS };
    
endpackage