// ticks_per_bit = clk_freq / baud_rate
module baud_generator #(
    parameter int BAUD_RATE = 10,
    parameter int CLK_FREQ = 100
) 
(
    input logic clk,
    input logic n_rst_in,
    output logic baud_tick
);

localparam int ticks_per_bit = CLK_FREQ / BAUD_RATE;
int counter;

always_ff @(posedge clk or negedge n_rst_in) begin
    if (!n_rst_in) begin
        baud_tick <= 1'b0;
        counter <= 0;
    end else begin
        if (counter == ticks_per_bit - 1) begin
            baud_tick <= 1;
            counter <= 0;
        end else begin
            counter <= counter + 1;
            baud_tick <= 0;
        end
    end
end
endmodule