# ==========================================================================
# mv_s_test.ss_125c.tcl
# ==========================================================================

# 1. CREATE THE CLOCK FIRST
create_clock -name clk -period 2.0 [get_ports clk]

# 2. APPLY CONSTRAINTS
set_max_transition 0.5 [current_design]
set_driving_cell -lib_cell NBUFFX4_RVT $mv_ports(sys_inputs)
set_clock_uncertainty -setup 0.1 [get_clocks clk]
set_clock_uncertainty -hold 0.05 [get_clocks clk]
set_clock_transition 0.1 [get_clocks clk]

set_input_delay 0.5 -clock clk $mv_ports(sys_inputs)
set_output_delay 0.3 -clock clk [concat $mv_ports(context_outputs) $mv_ports(pci_outputs) $mv_ports(sdram_outputs) $mv_ports(reg_outputs)]

set_timing_derate -early 0.95
set_timing_derate -late 1.00