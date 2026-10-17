module simon (
    input [31:0] plain,
    input [63:0] key,
    output [31:0] cipher
);

wire [15:0] subkey[31:0];

assign subkey[0] = key[15:0];
assign subkey[1] = key[31:16];
assign subkey[2] = key[47:32];
assign subkey[3] = key[63:48];

wire [61:0] z = 62'b11111010001001010110000111001101111101000100101011000011100110;

genvar i;
generate
for (i = 4; i <= 31; i = i + 1) begin : key_gen
    wire [15:0] k_m1 = subkey[i-1];
    wire [15:0] k_m3 = subkey[i-3];
    wire [15:0] tmp = {k_m1[2:0], k_m1[15:3]}; // ror3
    wire [15:0] tmp_xor = tmp ^ k_m3;
    wire [15:0] ror1_tmp = {tmp_xor[0], tmp_xor[15:1]}; // ror1
    wire [15:0] tmp_final = tmp_xor ^ ror1_tmp;
    localparam integer idx = (i - 4) % 62;
    wire zbit = z[61 - idx];
    assign subkey[i] = 16'hfffc ^ {15'b0, zbit} ^ subkey[i-4] ^ tmp_final;
end
endgenerate

wire [15:0] left_in = plain[31:16];
wire [15:0] right_in = plain[15:0];

wire [15:0] left[32:0];
wire [15:0] right[32:0];

assign left[0] = left_in;
assign right[0] = right_in;

generate
for (i = 0; i < 32; i = i + 1) begin : enc_gen
    wire [15:0] l = left[i];
    wire [15:0] f1 = {l[14:0], l[15]}; // rol1
    wire [15:0] f8 = {l[7:0], l[15:8]}; // rol8
    wire [15:0] f2 = {l[13:0], l[15:14]}; // rol2
    wire [15:0] f = (f1 & f8) ^ f2;
    assign left[i+1] = right[i] ^ f ^ subkey[i];
    assign right[i+1] = left[i];
end
endgenerate

assign cipher = {left[32], right[32]};

endmodule
