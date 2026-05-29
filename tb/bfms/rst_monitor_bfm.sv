interface rst_monitor_bfm (input bit rst_n);
    
    time rst_begin;

    task wait_reset_start(output int duration);
        @(negedge rst_n);
        rst_begin = $time;      
        duration = -1;  // flag for scrb that indicates begining of reset
    endtask

    task wait_reset_end(output int duration);
        @(posedge rst_n);
        duration = $time - rst_begin;
    endtask


    task wait_start_of_rst;
        @(negedge rst_n);
    endtask

    task wait_end_of_rst;
        @(posedge rst_n);
    endtask

endinterface