module top (
    input logic clk,
    input logic btn_red,
    input logic btn_blue,
    input logic sw,
    output logic [6:0] seg,
    output logic dp,
    output logic led_red,
    output logic led_blue
);

    logic [3:0] duty_cycle_red = 4'd0;
    logic [3:0] duty_cycle_blue = 4'd0;
    logic [3:0] pwm_cnt = 0;
    logic [3:0] display_value;

    logic btn_red_sync = 1'b0;
    logic btn_red_out = 1'b0;
    logic btn_blue_sync = 1'b0;
    logic btn_blue_out = 1'b0;
    logic btn_red_prev = 1'b0;
    logic btn_blue_prev = 1'b0;
    logic [19:0] cnt_red = 0;
    logic [19:0] cnt_blue = 0;

    // Add an intermediate signal for the first stage
    logic btn_red_meta = 1'b0;
    logic btn_blue_meta = 1'b0;

    always_ff @(posedge clk) begin
        // Stage 1: Captures the asynchronous input (can go metastable)
        btn_red_meta <= btn_red;
        btn_blue_meta <= btn_blue;
        
        // Stage 2: Captures the stabilized output of stage 1
        btn_red_sync <= btn_red_meta; 
        btn_blue_sync <= btn_blue_meta;
    end

    always_ff @(posedge clk) begin
        // Red button debouncing logic
        if (btn_red_sync != btn_red_out) begin
            if (cnt_red < 1000000)
                cnt_red <= cnt_red + 1;
            else if (cnt_red >= 1000000) begin
                btn_red_out <= btn_red_sync;
                cnt_red <= 0;
            end
        end else begin
            cnt_red <= 0; // reset counter if input is stable
        end
        if (btn_blue_sync != btn_blue_out) begin
            if (cnt_blue < 1000000)
                cnt_blue <= cnt_blue + 1;
            else if (cnt_blue >= 1000000) begin
                btn_blue_out <= btn_blue_sync;
                cnt_blue <= 0;
            end
        end else begin
            cnt_blue <= 0; // reset counter if input is stable
        end
    end

    always_ff @(posedge clk) begin
        if (btn_red_out && !btn_red_prev) begin
            if (duty_cycle_red == 4'd9)
                duty_cycle_red <= 4'd0;
            else
                duty_cycle_red <= duty_cycle_red + 4'd1;
        end

        if (btn_blue_out && !btn_blue_prev) begin
            if (duty_cycle_blue == 4'd9)
                duty_cycle_blue <= 4'd0;
            else
                duty_cycle_blue <= duty_cycle_blue + 4'd1;
        end

        btn_red_prev <= btn_red_out;
        btn_blue_prev <= btn_blue_out;
    end

    always_ff @(posedge clk) begin
        if (pwm_cnt == 4'd9)
            pwm_cnt <= 4'd0;
        else
            pwm_cnt <= pwm_cnt + 4'd1;
    end

    assign led_red = (pwm_cnt < duty_cycle_red);
    assign led_blue = (pwm_cnt < duty_cycle_blue);

    assign display_value = sw ? duty_cycle_blue : duty_cycle_red;

    assign dp = sw;

    always_comb begin
        case (display_value)
            4'd0:  seg = 7'b0111111;
            4'd1:  seg = 7'b0000110;
            4'd2:  seg = 7'b1011011;
            4'd3:  seg = 7'b1001111;
            4'd4:  seg = 7'b1100110;
            4'd5:  seg = 7'b1101101;
            4'd6:  seg = 7'b1111101;
            4'd7:  seg = 7'b0000111;
            4'd8:  seg = 7'b1111111;
            4'd9:  seg = 7'b1101111;
            default: seg = 7'b0000000;
        endcase
    end

endmodule