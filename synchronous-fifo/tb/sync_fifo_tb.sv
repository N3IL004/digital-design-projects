`timescale 1ns/1ps

module sync_fifo_tb;
    localparam DATA_WIDTH = 8;
    localparam DEPTH = 4;

    logic clk_in;
    logic rst_n;
    logic wr_en;
    logic rd_en; 
    logic [DATA_WIDTH-1:0] data_in;
    logic [DATA_WIDTH-1:0] data_out;
    logic full;
    logic empty;

    int passes;
    int errors;

    logic [DATA_WIDTH-1:0] expected_queue[$];
    
    sync_fifo #(
        .DEPTH(DEPTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk_in(clk_in),
        .rst_n(rst_n),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .data_in(data_in),
        .data_out(data_out),
        .full(full),
        .empty(empty)
    );

    initial clk_in = 0;
    always #5 clk_in = ~clk_in;

    initial begin
        $dumpfile("sync_fifo.vcd");
        $dumpvars(0, sync_fifo_tb);
    end

    task do_write(input logic [DATA_WIDTH-1:0] data);
        @(negedge clk_in);
        wr_en = 1;
        data_in = data;
        if (!full)
            expected_queue.push_back(data);
        @(posedge clk_in);
        #1;
        wr_en = 0;
    endtask

    task read_and_check();
        logic [DATA_WIDTH-1:0] expected;
        logic was_empty;
        @(negedge clk_in);
        was_empty = empty;
        if (!was_empty)
            expected = expected_queue[0];
        rd_en = 1;
        #1;
        if (!was_empty) begin
            if (data_out === expected) begin
                passes++;
            end else begin
                $display("Error: Expected %0d, got %0d", expected, data_out);
                errors++;
            end
            void'(expected_queue.pop_front());
        end else begin
            passes++;
        end
        @(posedge clk_in);
        #1;
        rd_en = 0;
    endtask

    initial begin
        rst_n = 0;
        wr_en = 0;
        rd_en = 0;
        data_in = 0;
        passes = 0;
        errors = 0;
        expected_queue.delete();

        @(posedge clk_in);
        rst_n = 1;

        do_write(8'hAA);
        do_write(8'hBB);
        do_write(8'hCC);
        do_write(8'hDD);

        read_and_check();
        read_and_check();
        read_and_check();
        read_and_check();

        read_and_check();

        $display("Test completed with %0d passes and %0d errors", passes, errors);

        $finish;
    end

endmodule