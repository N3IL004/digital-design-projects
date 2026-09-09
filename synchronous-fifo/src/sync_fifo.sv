module sync_fifo #(
    parameter DEPTH,
    parameter DATA_WIDTH
) 
(
    input logic clk_in,
    input logic rst_n,
    input logic wr_en,
    input logic rd_en, 
    input logic [DATA_WIDTH-1:0] data_in,
    output logic [DATA_WIDTH-1:0] data_out,
    output logic full,
    output logic empty
);

// internal variables
localparam ADDR_WIDTH = $clog2(DEPTH);
logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];
logic [ADDR_WIDTH:0] wr_ptr, rd_ptr;

always_comb begin
    full = (wr_ptr[ADDR_WIDTH] != rd_ptr[ADDR_WIDTH]) && (wr_ptr[ADDR_WIDTH-1:0] == rd_ptr[ADDR_WIDTH-1:0]);
    empty = (wr_ptr == rd_ptr);
    data_out = mem[rd_ptr[ADDR_WIDTH-1:0]];
end

always_ff @(posedge clk_in or negedge rst_n) begin
    if (!rst_n) begin
        wr_ptr <= 0;
        rd_ptr <= 0;
    end else begin
        if (wr_en && !full) begin
            mem[wr_ptr[ADDR_WIDTH-1:0]] <= data_in;
            wr_ptr <= wr_ptr + 1;
        end
        if (rd_en && !empty) begin
            rd_ptr <= rd_ptr + 1;
        end
    end
end

endmodule
