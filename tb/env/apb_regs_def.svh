typedef enum logic [7:0] {
    REG_OP     = 8'h00,
    REG_CTRL   = 8'h04,
    REG_STATUS = 8'h08
} e_regs_addresses;

typedef enum logic [1:0] {
    ADD       = 2'b00,
    SUB       = 2'b01,
    TRANSPOSE = 2'b10,
    DET       = 2'b11
} opcodes_e;

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
const logic [1:0] opcodes [] = { ADD, SUB, TRANSPOSE, DET };
