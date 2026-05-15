import apb_package::* ;

class apb_csr_scrb;

    reg_model ref_model; 

    virtual apb_csr_bfm vbfm;

    function new (virtual apb_csr_bfm vbfm, reg_model ref_model);
        this.vbfm = vbfm;
        this.ref_model = ref_model;
    endfunction


    task do_monitor;
        forever begin
            @(posedge vbfm.clk);
            if (|vbfm.reg_status)
                ref_model.apb_regs[REG_STATUS].value = vbfm.reg_status; // reg_status is drived by scrb for entire tb, 
                                                                       // for apb_csr_tb reg_status signals is drived by bfm

            if (ref_model.apb_regs[REG_CTRL].value[0] || ref_model.apb_regs[REG_CTRL].value[1]) begin
                self_reset_ctrl_check();
            end
            if (~vbfm.rst_n)
                process_rst();
            if (vbfm.psel && vbfm.penable && vbfm.pready)
                process_transaction();
        end
    endtask


    task process_transaction();
        if (!(vbfm.paddr inside {valid_addresses}) & !vbfm.pslverr) // Inv addreses
                $error("[ scrb  ] ERROR: PSLVERR not asserted on inv addr                           (time %0t)", $time);
        else                                                        // Valid addreses
        if (vbfm.pwrite) begin // Writing
            if ((ref_model.apb_regs[vbfm.paddr].acces_type == RW) && !((vbfm.paddr == REG_OP) && vbfm.reg_status[BUSY])) begin
                ref_model.apb_regs[vbfm.paddr].value = vbfm.pwdata & ref_model.apb_regs[vbfm.paddr].valid_bits;
            end

            if (vbfm.pslverr && (ref_model.apb_regs[vbfm.paddr].acces_type == RW))
                $error("[ scrb  ] ERROR: PSLVERR asserted when write to RW for valid addr=0x%02H    (time %0t)",
                    vbfm.paddr, $time);
            else
            if (!vbfm.pslverr && (ref_model.apb_regs[vbfm.paddr].acces_type == RO))
                $error("[ scrb  ] ERROR: PSLVERR not asserted when write to RO reg                  (time %0t)",
                    vbfm.paddr, $time);
            else begin 
                #1; // Write checks for apb_csr_tb
                if ((vbfm.paddr == REG_OP) && vbfm.reg_status[BUSY] && 
                    (vbfm.op != ref_model.apb_regs[REG_OP].value))
                    $error("[ scrb  ] ERROR: It has writed OP when BUSY asserted                        (time %0t)", $time);
                else 
                if ((vbfm.paddr == REG_OP) && !vbfm.reg_status[BUSY] && (vbfm.op != vbfm.pwdata[1:0])) 
                    $error("[ scrb  ] ERROR: Write error at addr=0x%02H, data: act=0x%08H exp=%08H      (time %0t)", 
                        vbfm.paddr, vbfm.op, vbfm.pwdata[1:0], $time);
                else
                if ((vbfm.paddr == REG_CTRL) && ({vbfm.start, vbfm.flush} != vbfm.pwdata[1:0]))
                    $error("[ scrb  ] ERROR: Write error at addr=0x%02H, data: act=0x%08H exp=%08H      (time %0t)", 
                        vbfm.paddr, {vbfm.start, vbfm.flush}, vbfm.pwdata[1:0], $time);
            end
        end
        else begin // Reading
            if (vbfm.prdata != ref_model.apb_regs[vbfm.paddr].value)
                $error("[ scrb  ] ERROR: PRDATA error for addr=0x%02H, rdata: act=0x%08H exp=%08H   (time %0t)", 
                    vbfm.paddr, vbfm.prdata, ref_model.apb_regs[vbfm.paddr].value, $time);
        end
    endtask


    task process_rst();
        ref_model.reset_regs();
        #1; // Rst reg values check for apb_csr_tb
        if (vbfm.op != 0)
            $error("[ scrb  ] ERROR: Unexpected reset OP value: op=%02b exp = 00                (time %0t)",
                    vbfm.op, $time);
        if (vbfm.start != 0)
            $error("[ scrb  ] ERROR: START asserted after reset                                 (time %0t)", $time);
        if (vbfm.flush != 0)
            $error("[ scrb  ] ERROR: FLUSH asserted after reset                                 (time %0t)", $time);
    endtask
    

    task self_reset_ctrl_check();
        ref_model.apb_regs[REG_CTRL].value[1:0] = 0;
        #1; // Ctrl reg self-reset check for apb_csr_tb
        if (vbfm.start != 0)
            $error("[ scrb  ] ERROR: START wasn't reset after assert                            (time %0t)", $time);
        if (vbfm.flush != 0)
            $error("[ scrb  ] ERROR: FLUSH wasn't reset after assert                            (time %0t)", $time);
    endtask

endclass