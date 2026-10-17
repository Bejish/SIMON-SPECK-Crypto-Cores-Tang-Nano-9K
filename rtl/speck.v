module speck (
    input [31:0] plain,
    input [63:0] key,
    output [31:0] cipher
);

wire [15:0] rk [0:22];
assign rk[0] = key[63:48];

wire [15:0] l_up [0:21];
assign l_up[0] = key[15:0];
assign l_up[1] = key[31:16];
assign l_up[2] = key[47:32];

genvar i;
generate
for (i = 0; i < 22; i = i + 1) begin : ks
    wire [15:0] temp = l_up[i] + rk[i] ^ i;
    wire [15:0] ror3 = {temp[2:0], temp[15:3]};
    wire [15:0] new_l = rk[i] ^ ror3;
    assign rk[i+1] = {rk[i][7:0], rk[i][15:8]} ^ new_l;
    if (i < 19) assign l_up[i+3] = new_l;  // Only assign when i+3 <= 21 (safe, no warning/error)
end
endgenerate

wire [15:0] x_r [0:22];
wire [15:0] y_r [0:22];

assign x_r[0] = plain[31:16];
assign y_r[0] = plain[15:0];

generate
for (i = 0; i < 22; i = i + 1) begin : rounds
    wire [15:0] x_rol8 = {x_r[i][7:0], x_r[i][15:8]};
    wire [15:0] sum = x_rol8 + y_r[i];
    wire [15:0] x_new = sum ^ rk[i];
    wire [15:0] y_rol3 = {y_r[i][12:0], y_r[i][15:13]};
    assign x_r[i+1] = x_new;
    assign y_r[i+1] = y_rol3 ^ x_new;
end
endgenerate

assign cipher = {x_r[22], y_r[22]};

endmodule
