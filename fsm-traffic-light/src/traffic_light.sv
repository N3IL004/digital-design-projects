module traffic_light (
    input logic clk_in,
    input logic n_rst_in,
    input logic tick_in,
    output logic red_out,
    output logic amber_out,
    output logic green_out
);


enum logic [1:0] {RED = 2'b00, RED_AMBER = 2'b01, GREEN = 2'b10, AMBER = 2'b11} state, next_state;
int tickCount;

always_ff @(posedge clk_in) begin
    if (!n_rst_in) begin
        tickCount <= 1;
        state <= RED;
    end else begin
        if (tick_in) begin
            tickCount <= tickCount + 1;
        end else begin
            tickCount <= tickCount;
        end
        if (state != next_state) begin
            tickCount <= 1;
            state <= next_state;
        end
        
    end
end

always_comb begin
    case (state)
        RED: begin
            if (tickCount == 4)
                next_state = RED_AMBER;
            else
                next_state = RED;
        end
        RED_AMBER: begin
            if (tickCount == 1) 
                next_state = GREEN;
            else
                next_state = RED_AMBER;
        end
        GREEN: begin
            if (tickCount == 4) 
                next_state = AMBER;
            else
                next_state = GREEN;
        end
        AMBER: begin
            if (tickCount == 1) 
                next_state = RED;
            else
                next_state = AMBER;
        end
        default: begin
            next_state = RED;
        end
    endcase
end

always_comb begin
    red_out = (state == RED || state == RED_AMBER);
    amber_out = (state == AMBER || state == RED_AMBER);
    green_out = (state == GREEN);
end

endmodule