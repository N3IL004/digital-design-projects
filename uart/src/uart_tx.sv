module uart_tx #(
    parameter WIDTH = 8
)
(
    input logic clk,
    input logic n_rst,
    input logic tx_start,
    input logic [WIDTH-1:0] tx_data,
    input logic baud_tick,
    output logic tx_busy,
    output logic tx_out
);
enum logic [1:0] {IDLE, START, DATA, STOP} state, next_state;
int i;
logic [WIDTH-1:0] shift_reg;

always_comb begin
    case(state)
        IDLE: begin
            if(tx_start) begin
                next_state = START;
            end else begin
                next_state = IDLE;
            end
        end
        START: begin
            if(baud_tick) begin
                next_state = DATA;
            end else begin
                next_state = START;
            end
        end
        DATA: begin
            if(baud_tick && (i == WIDTH - 1)) begin
                next_state = STOP;
            end else begin
                next_state = DATA;
            end
        end
        STOP: begin
            if(baud_tick) begin
                next_state = IDLE;
            end else begin
                next_state = STOP;
            end
        end
        default: begin
            next_state = IDLE;
        end
    endcase
end

always_ff @( posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        tx_busy <= 1'b0;
        tx_out <= 1'b1; 
        state <= IDLE;
        i <= 0;
    end else begin
        case(state)
            IDLE: begin
                tx_busy <= 1'b0;
                tx_out <= 1'b1;
                if(tx_start) begin
                    shift_reg <= tx_data;
                    i <= 0;
                end
            end
            START: begin
                tx_busy <= 1'b1;
                tx_out <= 1'b0; 
            end
            DATA: begin
                tx_busy <= 1'b1;
                tx_out <= shift_reg[i];
                if (baud_tick)
                    i <= i + 1; 
            end
            STOP: begin
                tx_busy <= 1'b1;
                tx_out <= 1'b1; 
            end
        endcase
        state <= next_state;
    end
end



endmodule