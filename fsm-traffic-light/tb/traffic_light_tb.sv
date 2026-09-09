`timescale 1ns/1ps

module traffic_light_tb;

    localparam logic [1:0] RED = 2'b00, RED_AMBER = 2'b01,
                         GREEN = 2'b10, AMBER = 2'b11;

    logic clk = 0;
    logic n_rst_in = 0;
    logic tick_in = 0;
    logic red_out;
    logic amber_out;
    logic green_out;

    int passes = 0;
    int errors = 0;

    logic [1:0] expected_state;
    logic [1:0] expected_next_state;
    int expected_count;

    traffic_light dut (
        .clk_in(clk),
        .n_rst_in(n_rst_in),
        .tick_in(tick_in),
        .red_out(red_out),
        .amber_out(amber_out),
        .green_out(green_out)
    );

    always #5 clk = ~clk;

    task compute_expected_next_state();
        case (expected_state)
            RED: begin
                if (expected_count == 4)
                    expected_next_state = RED_AMBER;
                else
                    expected_next_state = RED;
            end
            RED_AMBER: begin
                if (expected_count == 1)
                    expected_next_state = GREEN;
                else
                    expected_next_state = RED_AMBER;
            end
            GREEN: begin
                if (expected_count == 4)
                    expected_next_state = AMBER;
                else
                    expected_next_state = GREEN;
            end
            AMBER: begin
                if (expected_count == 1)
                    expected_next_state = RED;
                else
                    expected_next_state = AMBER;
            end
            default: expected_next_state = RED;
        endcase
    endtask

    task step_model();
        compute_expected_next_state();
        if (tick_in) begin
            expected_count++;
        end else begin
            expected_count = expected_count;
        end

        if (expected_state != expected_next_state) begin
            expected_count = 1;
            expected_state = expected_next_state;
        end
    endtask

    task check();
        logic exp_red, exp_amber, exp_green;
        case (expected_state)
            RED: begin 
                exp_red=1; exp_amber=0; exp_green=0; 
            end
            RED_AMBER: begin 
                exp_red=1; exp_amber=1; exp_green=0; 
            end
            GREEN: begin 
                exp_red=0; exp_amber=0; exp_green=1; 
            end
            AMBER: begin 
                exp_red=0; exp_amber=1; exp_green=0; 
            end
            default: begin 
                exp_red=0; exp_amber=0; exp_green=0; 
            end
        endcase

        if (dut.state !== expected_state) begin
            errors++;
            $display("FAIL: expected state %0d, but got %0d", expected_state, dut.state);
        end else begin
            passes++;
        end

        if (red_out !== exp_red || amber_out !== exp_amber || green_out !== exp_green) begin
            errors++;
            $display("FAIL: outputs wrong for state %0d: got r=%b a=%b g=%b, expected r=%b a=%b g=%b", expected_state, red_out, amber_out, green_out, exp_red, exp_amber, exp_green);
        end else begin
            passes++;
        end
    endtask

    initial begin
        $dumpfile("traffic_light.vcd");
        $dumpvars(0, traffic_light_tb);

        n_rst_in = 0;
        tick_in  = 1;
        repeat (2) @(posedge clk);
        n_rst_in = 1;
        #1;

        if (dut.state == RED) begin
            passes++;
            $display("PASS: state is RED immediately after reset");
        end else begin
            errors++;
            $display("FAIL: expected RED after reset, but got %0d", dut.state);
        end
        expected_state = RED;
        expected_count = 1;

        repeat (30) begin
            @(posedge clk);
            step_model();
            #1;
            check();
        end

        tick_in = 0;
        repeat (3) begin
            @(posedge clk);
            step_model();
            #1;
            check();
        end
        tick_in = 1;

        repeat (10) begin
            @(posedge clk);
            step_model();
            #1;
            check();
        end

        $display("\n==== TEST SUMMARY ====");
        $display("Passed: %0d", passes);
        $display("Failed: %0d", errors);
        if (errors == 0) $display("ALL TESTS PASSED");
        else $display("SOME TESTS FAILED");
        $finish;
    end

endmodule