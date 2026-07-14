// =========================================================================
// File Name     : mv_macro_engine_top_sfo.v
// Module Name   : mv_macro_engine_top
// Author        : Ajaymallesh
// Version       : v2.0
// Date          : 2026-06-06
// Description   : Multi-voltage macro engine top-level module. 
// sfo           : splitted fan outs
// Revision History:
//   v1.0 - Initial design (Single high-fanout routing net)
//   v2.0 - Architectural Load Isolation: Duplicated final-stage 
//          registers to isolate SRAM loads and fix ICC2 max_cap violations.
// =========================================================================

`timescale 1ns / 1ps

module mv_macro_engine_top (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] sys_data_in,
    
    output reg  [31:0]  context_sig_out,
    output reg  [127:0] pci_sig_out,
    output reg  [63:0]  sdram_sig_out,
    output reg  [31:0]  reg_sig_out
);

    wire [31:0] context_data_out [0:15]; 
    wire [7:0]  pci_fifo_out [0:59];     
    wire [7:0]  sdram_fifo_out [0:11];   
    wire [31:0] reg_file_out [0:11];     

    lp_ram_subsystem u_lp_ram_subsystem (
        .clk(clk), .rst_n(rst_n), .sys_data_in(sys_data_in), .context_data_out(context_data_out)
    );

    // ---------------------------------------------------------------------
    // MACRO LOAD ISOLATION UPDATE
    // Array reduced to 127 stages. The 128th stage is duplicated below.
    // 
    // NO SYN_PRESERVE TAGS HERE! 
    // This allows Design Compiler to map them to real silicon for DFT.
    // ---------------------------------------------------------------------
    reg [511:0] data_path_fabric [0:126];
    
    reg [511:0] routing_data_pci;
    reg [511:0] routing_data_sdram;
    reg [511:0] routing_data_reg;
    reg [511:0] routing_data_core;
    
    integer h;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (h = 0; h < 127; h = h + 1) data_path_fabric[h] <= 512'b0;
            routing_data_pci   <= 512'b0;
            routing_data_sdram <= 512'b0;
            routing_data_reg   <= 512'b0;
            routing_data_core  <= 512'b0;
        end else begin
            data_path_fabric[0] <= {16{sys_data_in}};
            for (h = 1; h < 127; h = h + 1) begin
                data_path_fabric[h] <= {data_path_fabric[h-1][510:0], data_path_fabric[h-1][511]} ^ 512'hDEADBEEF_CAFEBABE_12345678_87654321_DEADBEEF_CAFEBABE_12345678_87654321_DEADBEEF_CAFEBABE_12345678_87654321_DEADBEEF_CAFEBABE_12345678_87654321; 
            end
            
            // Parallel Fanout Split: All 4 registers perform the exact same logical step
            // but physically isolate the routing nets from each other.
            routing_data_pci   <= {data_path_fabric[126][510:0], data_path_fabric[126][511]} ^ 512'hDEADBEEF_CAFEBABE_12345678_87654321_DEADBEEF_CAFEBABE_12345678_87654321_DEADBEEF_CAFEBABE_12345678_87654321_DEADBEEF_CAFEBABE_12345678_87654321;
            routing_data_sdram <= {data_path_fabric[126][510:0], data_path_fabric[126][511]} ^ 512'hDEADBEEF_CAFEBABE_12345678_87654321_DEADBEEF_CAFEBABE_12345678_87654321_DEADBEEF_CAFEBABE_12345678_87654321_DEADBEEF_CAFEBABE_12345678_87654321;
            routing_data_reg   <= {data_path_fabric[126][510:0], data_path_fabric[126][511]} ^ 512'hDEADBEEF_CAFEBABE_12345678_87654321_DEADBEEF_CAFEBABE_12345678_87654321_DEADBEEF_CAFEBABE_12345678_87654321_DEADBEEF_CAFEBABE_12345678_87654321;
            routing_data_core  <= {data_path_fabric[126][510:0], data_path_fabric[126][511]} ^ 512'hDEADBEEF_CAFEBABE_12345678_87654321_DEADBEEF_CAFEBABE_12345678_87654321_DEADBEEF_CAFEBABE_12345678_87654321_DEADBEEF_CAFEBABE_12345678_87654321;
        end
    end

    genvar p;
    generate
        for (p = 0; p < 60; p = p + 1) begin : PCI_FIFO_ARRAY
            SRAMLP2RW32x4 PCI_FIFO_RAM (
                .A1(routing_data_pci[(p*5)+4 : p*5]), .I1(routing_data_pci[(p*4)+3 : p*4]), .O1(pci_fifo_out[p][3:0]),
                .CE1(clk), .CSB1(1'b0), .WEB1(routing_data_pci[p]), .OEB1(1'b0),
                .A2(5'b0), .I2(4'b0), .O2(pci_fifo_out[p][7:4]),
                .CE2(1'b0), .CSB2(1'b1), .WEB2(1'b1), .OEB2(1'b1),
                .SD(1'b0), .DS1(1'b0), .DS2(1'b0), .LS1(1'b0), .LS2(1'b0)
            );
        end
    endgenerate

    genvar s;
    generate
        for (s = 0; s < 12; s = s + 1) begin : SDRAM_FIFO_ARRAY
            SRAMLP2RW32x4 SD_FIFO_RAM (
                .A1(routing_data_sdram[(s*5)+4 : s*5]), .I1(routing_data_sdram[(s*4)+3 : s*4]), .O1(sdram_fifo_out[s][3:0]),
                .CE1(clk), .CSB1(1'b0), .WEB1(routing_data_sdram[s]), .OEB1(1'b0),
                .A2(5'b0), .I2(4'b0), .O2(sdram_fifo_out[s][7:4]),
                .CE2(1'b0), .CSB2(1'b1), .WEB2(1'b1), .OEB2(1'b1),
                .SD(1'b0), .DS1(1'b0), .DS2(1'b0), .LS1(1'b0), .LS2(1'b0)
            );
        end
    endgenerate

    genvar r;
    generate
        for (r = 0; r < 12; r = r + 1) begin : REG_FILE_ARRAY
            SRAMLP2RW128x16 REG_FILE_RAM (
                .A1(routing_data_reg[(r*7)+6 : r*7]), .I1(routing_data_reg[(r*16)+15 : r*16]), .O1(reg_file_out[r][15:0]),
                .CE1(clk), .CSB1(1'b0), .WEB1(routing_data_reg[r]), .OEB1(1'b0),
                .A2(7'b0), .I2(16'b0), .O2(reg_file_out[r][31:16]),
                .CE2(1'b0), .CSB2(1'b1), .WEB2(1'b1), .OEB2(1'b1),
                .SD(1'b0), .DS1(1'b0), .DS2(1'b0), .LS1(1'b0), .LS2(1'b0)
            );
        end
    endgenerate

    integer i;
    reg [31:0]  buf_context;
    reg [127:0] buf_pci;
    reg [63:0]  buf_sdram;
    reg [31:0]  buf_reg;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            context_sig_out <= 32'b0;
            pci_sig_out     <= 128'b0;
            sdram_sig_out   <= 64'b0;
            reg_sig_out     <= 32'b0;
        end else begin
            buf_context = 32'b0;
            buf_pci     = 128'b0;
            buf_sdram   = 64'b0;
            buf_reg     = 32'b0;
            
            for (i = 0; i < 16; i = i + 1) buf_context = buf_context ^ context_data_out[i];
            
            for (i = 0; i < 15; i = i + 1)  buf_pci[31:0]   = buf_pci[31:0]   ^ {24'b0, pci_fifo_out[i]};
            for (i = 15; i < 30; i = i + 1) buf_pci[63:32]  = buf_pci[63:32]  ^ {24'b0, pci_fifo_out[i]};
            for (i = 30; i < 45; i = i + 1) buf_pci[95:64]  = buf_pci[95:64]  ^ {24'b0, pci_fifo_out[i]};
            for (i = 45; i < 60; i = i + 1) buf_pci[127:96] = buf_pci[127:96] ^ {24'b0, pci_fifo_out[i]};
            
            for (i = 0; i < 6; i = i + 1)  buf_sdram[31:0]  = buf_sdram[31:0]  ^ {24'b0, sdram_fifo_out[i]};
            for (i = 6; i < 12; i = i + 1) buf_sdram[63:32] = buf_sdram[63:32] ^ {24'b0, sdram_fifo_out[i]};
            
            for (i = 0; i < 12; i = i + 1) buf_reg = buf_reg ^ reg_file_out[i];
            
            // THE ULTIMATE LINT FIX: Updated to fold ALL 4 registers!
            // No bits left floating = No DFT crashes.
            for (i = 0; i < 16; i = i + 1) begin
                buf_reg = buf_reg ^ routing_data_core[i*32 +: 32]
                                  ^ routing_data_pci[i*32 +: 32]
                                  ^ routing_data_sdram[i*32 +: 32]
                                  ^ routing_data_reg[i*32 +: 32];
            end

            context_sig_out <= buf_context;
            pci_sig_out     <= buf_pci;
            sdram_sig_out   <= buf_sdram;
            reg_sig_out     <= buf_reg;
        end
    end

endmodule