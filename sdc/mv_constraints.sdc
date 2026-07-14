# ==========================================================================
# SYNTHESIS TIMING CONSTRAINTS (Aggressive Setup & Hold Targets)
# ==========================================================================
# PROJECT     : Multi-Voltage Macro Engine
# AUTHOR      : AJAYMALLESH
# VERSION     : 3.0 (Overclocked for ICC2 Optimization Practice)
# ==========================================================================

# 1. UNIT DEFINITIONS 
set_units -time ns -resistance MOhm -capacitance ff -voltage V -current uA

# 2. OPERATING CONDITIONS (Worst-Case Slow-Slow)
set_operating_conditions -library saed32rvt_ss0p95v125c ss0p95v125c

# 3. CLOCK DEFINITION (Overclocked to 1.25 GHz to force Setup violations)
create_clock -name clk -period 0.8 [get_ports clk]
set_clock_uncertainty -setup 0.15 [get_clocks clk]
set_clock_uncertainty -hold 0.05 [get_clocks clk]
set_clock_transition 0.1 [get_clocks clk]

# 4. DRIVE & LOAD PROFILING
set_driving_cell -lib_cell NBUFFX4_RVT [get_ports sys_data_in*]
set_load 0.05 [get_ports {context_sig_out* pci_sig_out* sdram_sig_out* reg_sig_out*}]

# ==========================================================================
# 5. I/O TIMING DELAYS (Split for Max/Min Analysis)
# ==========================================================================
# SETUP (MAX): 0.65ns eats up 80% of your 0.8ns clock, forcing setup failures.
# HOLD (MIN): Tiny/Negative delays mean data disappears instantly, forcing 
# the tool to insert delay buffers to fix hold violations.

# --- INPUTS ---
set_input_delay -max  0.65 -clock clk [get_ports sys_data_in*]
set_input_delay -min  0.05 -clock clk [get_ports sys_data_in*]

# --- OUTPUTS ---
set_output_delay -max  0.65 -clock clk [get_ports {context_sig_out* pci_sig_out* sdram_sig_out* reg_sig_out*}]
set_output_delay -min -0.10 -clock clk [get_ports {context_sig_out* pci_sig_out* sdram_sig_out* reg_sig_out*}]

# ==========================================================================
# 6. DESIGN EXCEPTIONS
# ==========================================================================
set_false_path -from [get_ports rst_n]