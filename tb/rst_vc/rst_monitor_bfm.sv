interface rst_monitor_bfm;

    bit rst_n;

    time rst_begin;
    time rst_end;

    rst_monitor mon;

    task run ();
        rst_seq_item item;
        forever begin
            @(negedge rst_n);
            rst_begin = $time;

            item = rst_seq_item::type_id::create("rst_seq_item");
            item.duration = -1; // flag for scrb that indicates begining of reset
            mon.notify_seq_item(item);

            @(posedge rst_n);
            rst_end = $time;

            item = rst_seq_item::type_id::create("rst_seq_item");
            item.duration = rst_end - rst_begin;
            mon.notify_seq_item(item);
        end
    endtask

endinterface