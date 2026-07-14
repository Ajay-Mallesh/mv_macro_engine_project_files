`timescale 1ns / 1ps

// Empty stub for Design Compiler Black-Boxing (RISC Register File)
module SRAMLP2RW128x16 (
    // Port 1
    input  wire [6:0]  A1,   // Address 1 (7 bits for 128 depth)
    input  wire [15:0] I1,   // Data In 1 (16 bits)
    output wire [15:0] O1,   // Data Out 1 (16 bits)
    input  wire        CE1,
    input  wire        CSB1,
    input  wire        WEB1,
    input  wire        OEB1,

    // Port 2
    input  wire [6:0]  A2,   // Address 2
    input  wire [15:0] I2,   // Data In 2
    output wire [15:0] O2,   // Data Out 2
    input  wire        CE2,
    input  wire        CSB2,
    input  wire        WEB2,
    input  wire        OEB2,

    // Power/Sleep Control Pins
    input  wire        SD,   
    input  wire        DS1,  
    input  wire        DS2,  
    input  wire        LS1,  
    input  wire        LS2   
);

    // Empty inside. No logic.

endmodule