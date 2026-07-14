# ==========================================================================
# MULTI-VOLTAGE SYNTHESIS SCRIPT (WLM Single-Corner Setup)
# ==========================================================================
# PROJECT     : Multi-Voltage Macro Engine
# AUTHOR      : AJAYMALLESH
# VERSION     : 4.0 (WLM Compatible, Typo-Free)
# DESCRIPTION : Script for SYNTHESIS (dc_shell)
# ==========================================================================

suppress_message UCN-4

# 1. PATHS & VARIABLES SETUP
set search_path "./inputs"
set UPF_FILE "./inputs/mv_power_intent.upf"
set SDC_FILE "./inputs/mv_constraints.sdc"

# 2. LIBRARY SETUP (FIXED: vn40c instead of vm40c)
set target_library "saed32rvt_ss0p95v125c.db saed32rvt_ss0p75v125c.db saed32rvt_ff1p16vn40c.db saed32rvt_ulvl_ss0p95v125c_i0p75v.db saed32rvt_dlvl_ss0p75v125c_i0p95v.db"
set link_library "* $target_library"

# 3. READ & ELABORATE RTL 
analyze -format sverilog { \
    ./inputs/sram_stub.v \
    ./inputs/sram_stub_pci.v \
    ./inputs/sram_stub_reg.v \
    ./inputs/lp_ram_subsystem.v \
    ./inputs/mv_macro_engine_top.v \
}

elaborate mv_macro_engine_top
current_design mv_macro_engine_top
link

# Lock down all three unique macro types as Black Boxes
set_dont_touch [get_designs SRAMLP2RW64x8] true
set_dont_touch [get_designs SRAMLP2RW32x4] true
set_dont_touch [get_designs SRAMLP2RW128x16] true

# ==========================================================================
# 4 & 5. READ POWER INTENT & WORST-CASE CONSTRAINTS
# ==========================================================================
load_upf $UPF_FILE

# Set voltages manually here so the UPF checker doesn't panic (Fixes UPF-057)
set_voltage 0.95 -object_list {VDD_DEFAULT}
set_voltage 0.75 -object_list {VDD_LP}
set_voltage 0.00 -object_list {VSS}

# Use the single Worst-Case Setup SDC for WLM Synthesis
suppress_message UID-401
read_sdc $SDC_FILE

# Operating conditions for the worst-case library
set_operating_conditions -library saed32rvt_ss0p95v125c ss0p95v125c

check_mv_design

# ==========================================================================
# 5.5 MULTI-VOLTAGE PRE-COMPILATION FIXES
# ==========================================================================
remove_attribute [get_lib_cells */TIE*] dont_use
set_input_transition 0.1 [get_ports rst_n]

set auto_insert_level_shifters_on_ideal_nets all

# FORCED CLOCK LEVEL SHIFTER INSERTION
set auto_insert_level_shifters_on_clocks all 

set compile_enable_multivoltage_dr_fix true

# ==========================================================================
# 5.6 VDD_LP DOMAIN BOUNDARY CONTROL 
# ==========================================================================
set_ungroup [get_cells u_lp_ram_subsystem] false
set_boundary_optimization [get_cells u_lp_ram_subsystem] false

# ==========================================================================
# 6. MAIN COMPILATION
# ==========================================================================
uniquify -force
set_fix_multiple_port_nets -all -buffer_constants [get_designs *]
compile_ultra -scan -no_autoungroup -gate_clock -retime

insert_mv_cells
compile_ultra -incremental

# ==========================================================================
# 7. DFT & SCAN CHAIN INSERTION
# ==========================================================================
create_port scan_en -direction in
create_port scan_in_1 -direction in
create_port scan_out_1 -direction out

set_dft_signal -view existing_dft -type ScanClock -port clk -timing {45 55}
set_dft_signal -view existing_dft -type Reset -port rst_n -active_state 0
set_dft_signal -view spec -type ScanEnable -port scan_en -active_state 1
set_dft_signal -view spec -type ScanDataIn -port scan_in_1
set_dft_signal -view spec -type ScanDataOut -port scan_out_1

set_dft_configuration -fix_reset enable -fix_clock enable
set_scan_configuration -chain_count 1

create_test_protocol
dft_drc
preview_dft
insert_dft

# ==========================================================================
# 8. RENAME & EXPORT DATA
# ==========================================================================
change_names -rules verilog -hierarchy

# --- A. SCANDEF ---
write_scan_def -output ./outputs/mv_macro_engine_top.scandef

# --- B. UPF ---
save_upf ./outputs/mv_macro_engine_top.upf

set file_name "./outputs/mv_macro_engine_top.upf"
set in_file [open $file_name r]
set file_data [read $in_file]
close $in_file

regsub -all {\[([0-9]+)\]_UPF} $file_data {_\1_UPF} file_data

set out_file [open $file_name w]
puts $out_file "# =========================================================================="
puts $out_file "# PROJECT     : Multi-Voltage Macro Engine"
puts $out_file "# AUTHOR      : \\\[AJAYMALLESH\\\]"
puts $out_file "# VERSION     : 1.0 (Silicon-Ready)"
puts $out_file "# DATE        : [clock format [clock seconds] -format {%B %d, %Y}]"
puts $out_file "# ==========================================================================\n"
puts $out_file $file_data
close $out_file

# --- C. SDC (SINGLE EXPORT FOR WLM) ---
write_sdc ./outputs/mv_macro_engine_top_synth.sdc

set file_name "./outputs/mv_macro_engine_top_synth.sdc"
set in_file [open $file_name r]; set file_data [read $in_file]; close $in_file
set out_file [open $file_name w]
puts $out_file "# =========================================================================="
puts $out_file "# PROJECT     : Multi-Voltage Macro Engine"
puts $out_file "# AUTHOR      : \\\[AJAYMALLESH\\\]"
puts $out_file "# VERSION     : 1.0 (Mapped Timing Constraints)"
puts $out_file "# ==========================================================================\n"
puts $out_file $file_data
close $out_file

# --- D. NETLIST ---
write -format verilog -hierarchy -output ./outputs/mv_macro_engine_top_netlist.v
set file_name "./outputs/mv_macro_engine_top_netlist.v"
set in_file [open $file_name r]; set file_data [read $in_file]; close $in_file
set out_file [open $file_name w]
puts $out_file "// =========================================================================="
puts $out_file "// PROJECT     : Multi-Voltage Macro Engine"
puts $out_file "// AUTHOR      : \\\[AJAYMALLESH\\\]"
puts $out_file "// VERSION     : 1.0 (Mapped Gate-Level Netlist)"
puts $out_file "// ==========================================================================\n"
puts $out_file $file_data
close $out_file

# exit