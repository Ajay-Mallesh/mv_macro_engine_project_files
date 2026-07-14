`timescale 1ns / 1ps

// Empty stub for Design Compiler Black-Boxing (Context RAMs)
module SRAMLP2RW64x8 (
    // Port 1
    input  wire [5:0] A1,   // Address 1 (6 bits for 64 depth)
    input  wire [7:0] I1,   // Data In 1 (8 bits)
    output wire [7:0] O1,   // Data Out 1 (8 bits)
    input  wire       CE1,  // Clock Enable 1
    input  wire       CSB1, // Chip Select Bar 1
    input  wire       WEB1, // Write Enable Bar 1
    input  wire       OEB1, // Output Enable Bar 1

    // Port 2
    input  wire [5:0] A2,   // Address 2
    input  wire [7:0] I2,   // Data In 2
    output wire [7:0] O2,   // Data Out 2
    input  wire       CE2,  // Clock Enable 2
    input  wire       CSB2, // Chip Select Bar 2
    input  wire       WEB2, // Write Enable Bar 2
    input  wire       OEB2, // Output Enable Bar 2

    // Power/Sleep Control Pins
    input  wire       SD,   // Shut Down
    input  wire       DS1,  // Deep Sleep 1
    input  wire       DS2,  // Deep Sleep 2
    input  wire       LS1,  // Light Sleep 1
    input  wire       LS2   // Light Sleep 2
);

    // Empty inside. No logic.

endmodule