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

    logic btn_red_sync, btn_red_out;
    logic btn_blue_sync, btn_blue_out;
    logic [19:0] cnt_red = 0;
    logic [19:0] cnt_blue = 0;

    always_ff @(posedge clk) begin
        btn_red_sync <= btn_red;
        btn_blue_sync <= btn_blue;
        
    end

    always_ff @(posedge clk) begin
        // Red button debouncing logic
        if (btn_red_sync != btn_red_out) 
            cnt_red <= 0;
        else if(cnt_red < 1000000) 
            cnt_red <= cnt_red +1;
        else
            btn_red_out <= btn_red_sync;
        
        // Blue button debouncing logic
        if (btn_blue_sync != btn_blue_out) 
            cnt_blue <= 0;
        else if(cnt_blue < 1000000) 
            cnt_blue <= cnt_blue +1;
        else
            btn_blue_out <= btn_blue_sync;
    end

    always_ff @(posedge clk) begin
        if (btn_red_out) begin
            if (duty_cycle_red == 4'd9)
                duty_cycle_red <= 4'd0;
            else
                duty_cycle_red <= duty_cycle_red + 4'd1;
        end
    end

    always_ff @(posedge clk) begin
        if (btn_blue_out) begin
            if (duty_cycle_blue == 4'd9)
                duty_cycle_blue <= 4'd0;
            else
                duty_cycle_blue <= duty_cycle_blue + 4'd1;
        end
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
        case (duty_cycle_red)
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