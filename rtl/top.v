module top (
    input clk,
    input btn0,
    input btn1,
    output led1,
    output led2,
    output led3,
    output led4,
    output led5,
    output led6
);

reg [31:0] plaintext = 32'h65656877;
reg mode = 0; // 0 = Simon, 1 = Speck

reg [24:0] debounce0 = 0;
reg [24:0] debounce1 = 0;
reg pressed0 = 0;
reg pressed1 = 0;
reg [23:0] blink_cnt = 0;

wire [31:0] simon_cipher;
wire [31:0] speck_cipher;
wire [31:0] cipher = mode ? speck_cipher : simon_cipher;

simon u_simon (
    .plain(plaintext),
    .key(64'h1918111009080100),
    .cipher(simon_cipher)
);

speck u_speck (
    .plain(plaintext),
    .key(64'h1918111009080100),
    .cipher(speck_cipher)
);

always @(posedge clk) begin
    if (~btn0) begin
        if (debounce0 < 25'd2700000) debounce0 <= debounce0 + 1;
        else if (!pressed0) begin
            plaintext <= plaintext + 1;
            pressed0 <= 1;
        end
    end else begin
        debounce0 <= 0;
        pressed0 <= 0;
    end

    if (~btn1) begin
        if (debounce1 < 25'd2700000) debounce1 <= debounce1 + 1;
        else if (!pressed1) begin
            mode <= ~mode;
            pressed1 <= 1;
        end
    end else begin
        debounce1 <= 0;
        pressed1 <= 0;
    end

    blink_cnt <= blink_cnt + 1;
end

wire [5:0] led_pattern = ~cipher[5:0];
assign {led1, led2, led3, led4, led5, led6} = (blink_cnt[23]) ? 6'b111111 : {led_pattern[4:0], mode};

endmodule
