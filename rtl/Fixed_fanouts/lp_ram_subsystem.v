`timescale 1ns / 1ps

module lp_ram_subsystem (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] sys_data_in,
    output wire [31:0] context_data_out [0:15]
);

    (* syn_preserve = 1 *) reg [127:0] lp_logic_pipe [0:63];
    integer i;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 64; i = i + 1) lp_logic_pipe[i] <= 128'b0;
        end else begin
            lp_logic_pipe[0] <= {4{sys_data_in}} ^ 128'hA5A5A5A5_5A5A5A5A_12345678_87654321;
            for (i = 1; i < 64; i = i + 1) begin
                lp_logic_pipe[i] <= {lp_logic_pipe[i-1][126:0], lp_logic_pipe[i-1][127]} ^ 128'h5A5A_A5A5_1234_4321_0987_7890_CAFE_BABE;
            end
        end
    end

    wire [127:0] processed_data = lp_logic_pipe[63];

    genvar m;
    generate
        for (m = 0; m < 16; m = m + 1) begin : VDDL_MACRO_ARRAY
            SRAMLP2RW64x8 u_ram (
                .A1(processed_data[(m*6)+5 : m*6]), 
                .I1(processed_data[(m*8)+7 : m*8]), 
                .O1(context_data_out[m][7:0]),
                // Distributed Write Enable to prevent LINT multi-drive warnings
                .CE1(clk), .CSB1(1'b0), .WEB1(processed_data[127-m]), .OEB1(1'b0),
                
                .A2(6'b0), .I2(8'b0), .O2(context_data_out[m][15:8]),
                .CE2(1'b0), .CSB2(1'b1), .WEB2(1'b1), .OEB2(1'b1),
                .SD(1'b0), .DS1(1'b0), .DS2(1'b0), .LS1(1'b0), .LS2(1'b0)
            );
            assign context_data_out[m][31:16] = 16'b0;
        end
    endgenerate

endmodule