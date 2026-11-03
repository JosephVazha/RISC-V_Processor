
module rgb_controller (
    input  logic clk,
    output logic RGB_R,
    output logic RGB_G,
    output logic RGB_B
);

    // 12 MHz clk, 6 colors per sec -  2,000,000 clock cycles.
    localparam integer COLOR_TICKS = 2_000_000;

    logic [20:0] clk_count;
    logic [2:0] color;

    // Color change
    always_ff @(posedge clk) begin
        if (clk_count == COLOR_TICKS - 1) begin
            clk_count <= 21'd0;

            if (color == 3'd5)
                color <= 3'd0;
            else
                color <= color + 3'd1;
        end
        else begin
            clk_count <= clk_count + 21'd1;
        end
    end

    
    always_comb begin
        case (color)

            //r
            3'd0: begin
                RGB_R = 1'b0;
                RGB_G = 1'b1;
                RGB_B = 1'b1;
            end

            // y
            3'd1: begin
                RGB_R = 1'b0;
                RGB_G = 1'b0;
                RGB_B = 1'b1;
            end

            //g 
            3'd2: begin
                RGB_R = 1'b1;
                RGB_G = 1'b0;
                RGB_B = 1'b1;
            end

            // cyan
            3'd3: begin
                RGB_R = 1'b1;
                RGB_G = 1'b0;
                RGB_B = 1'b0;
            end

            // b
            3'd4: begin
                RGB_R = 1'b1;
                RGB_G = 1'b1;
                RGB_B = 1'b0;
            end

            // magenta
            3'd5: begin
                RGB_R = 1'b0;
                RGB_G = 1'b1;
                RGB_B = 1'b0;
            end

	    default: begin
                RGB_R = 1'b1;
                RGB_G = 1'b1;
                RGB_B = 1'b1;
            end

        endcase
    end

endmodule


