# ==========================================================================
# FILE: scripts/signoff_script.tcl
# DESC: Signoff Extraction (StarRC) and PrimeTime Handoff 
# PROJECT: MV_MACRO_ENGINE
# AUTHOR: AJAYMALLESH
# DATE: 21-Jun-26
# ==========================================================================

puts "--- <SIGNOFF> Initiating PrimeTime & StarRC Handoff Exports ---"

# 1. GENERATE SIGNOFF NETLIST
# Strip abstract routing and dump pure gate-level Verilog
write_verilog -compress false ./outputs/mv_macro_engine_routed.v

# 2. GENERATE SIGNOFF CONSTRAINTS (SDC)
# Extracting exact timing constraints for the active MCMM corners
write_sdc -scenario func.ss_125c -output ./outputs/mv_macro_engine_ss_125c.sdc
write_sdc -scenario func.ff_m40c -output ./outputs/mv_macro_engine_ff_m40c.sdc

# 3. EXPORT DESIGN FOR STARRC (Golden SPEF Generation)
# To generate highly accurate signoff SPEF, StarRC requires the fully routed DEF.
# The external StarRC engine will map this DEF to the 32nm NXTGRD files.
write_def -version 5.8 -routing -all_blocks ./outputs/mv_macro_engine_routed.def

# 4. EXPORT NATIVE PARASITICS (Optional / Baseline Estimation)
# If you need immediate ICC2 internal SPEF before the external StarRC job finishes:
write_parasitics -corner ss_125c -output ./outputs/mv_macro_engine_ss_125c_icc2.spef
write_parasitics -corner ff_m40c -output ./outputs/mv_macro_engine_ff_m40c_icc2.spef

# 5. PREPARE UPF FOR PRIMETIME
# PrimeTime absolutely needs the multi-voltage boundaries to accurately analyze 
# the 0.95V (VDD) and 0.75V (VDDL) domain crossings.
file copy -force ./inputs/mv_macro_engine.upf ./outputs/

puts "--- <SIGNOFF> Handoff Files Generated in ./outputs/ ---"


# ==========================================================================
# PRIMETIME EXECUTION BLOCK (To be executed inside pt_shell)
# ==========================================================================
# Once StarRC has processed the DEF and generated the golden SPEF, 
# use these commands in PrimeTime to load the complete database:

# read_verilog ./outputs/mv_macro_engine_routed.v
# current_design mv_macro_engine_top
# link

# source ./outputs/mv_macro_engine_ss_125c.sdc
# load_upf ./outputs/mv_macro_engine.upf

# # Read the StarRC generated SPEF (Ensure capacitive coupling is kept for SI analysis)
# read_parasitics ./outputs/starrc/mv_macro_engine_cworst.spef -keep_capacitive_coupling

# report_timing -delay_type max
# report_timing -delay_type min
# ==========================================================================