import apb_package::* ;

interface apb_csr_bfm (input clk, input rst_n);

    // APB_if
    logic        psel;
    logic        penable;
    logic        pwrite;
    logic [7:0]  paddr;
    logic [31:0] pwdata;

    logic [31:0] prdata;
    logic        pready;      
    logic        pslverr;

    // APB_regs
    logic [1:0]  op;

    logic        start;
    logic        flush;
    
    logic [4:0]  reg_status;


    task apb_csr_reset ();
        penable <= 0;
        psel    <= 0;
        pwrite  <= 0;

        reg_status <= '0;
    endtask

    task apb_write (input [7:0] addr, input [31:0] data);
        @(posedge clk);
        penable <= 0;
        psel    <= 1;
        pwrite  <= 1;
        paddr   <= addr;
        pwdata  <= data;
        @(posedge clk);
        penable <= 1;
        do begin
            @(posedge clk);
        end
        while (~pready);
        penable <= 0;
        psel    <= 0;
    endtask

    task apb_read (input [7:0] addr);
        @(posedge clk);
        penable <= 0;
        psel    <= 1;
        pwrite  <= 0;
        paddr   <= addr;
        @(posedge clk);
        penable <= 1;
        do begin
            @(posedge clk);
        end
        while (~pready);
        penable <= 0;
        psel    <= 0;
    endtask

    //
    task start_direct_test();  
        // direct_test with fly reset: -> write '1 to all registers (self-reset, write RO regs check)
        //                               -> read all registers 
        //                               -> write inv addr -> read inv addr
        //                               -> assert busy -> write op
        //                               -> finish       
        int last_wi, last_ri;
        logic [7:0] addr;
        bit inv_addr_w_done, inv_addr_r_done;
        $display ("===========================APB_csr direct test start============================");              
        forever begin
            fork
                begin
                    for(int wi = !last_wi ? 0 : last_wi + 1; wi < valid_addresses.size(); wi++) begin
                        addr = valid_addresses[wi];
                        apb_write (addr, {32{1'b1}});
                        last_wi = wi;
                    end 

                    reg_status[OVERFLOW] <= 1;

                    for(int ri = !last_ri ? 0 : last_ri + 1; ri < valid_addresses.size(); ri++) begin
                        addr = valid_addresses[ri];
                        apb_read  (addr);
                        last_ri = ri;
                    end
                    
                    if (!inv_addr_w_done) begin
                        apb_write (8'h10, {32{1'b1}});
                        inv_addr_w_done = 1;
                    end
                    if (!inv_addr_r_done) begin
                        apb_read (8'h10);
                        inv_addr_r_done = 1;
                    end

                    reg_status[BUSY] <= 1;
                    apb_write (REG_OP, 2'b10);
                    @(posedge clk);

                    $display ("===========================APB_csr direct test finish===========================");
                    $finish();
                end 
            join_none
            wait(~rst_n);
            disable fork;
            apb_csr_reset();
            wait( rst_n);
        end
    endtask

endinterface