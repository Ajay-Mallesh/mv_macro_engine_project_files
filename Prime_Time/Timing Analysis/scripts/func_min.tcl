# --- func_min.tcl (HOLD / MIN TIMING @ -40C) ---

# Kindly Read Timing Analysis Guide First
# Add path where your .db's are available

set search_path { /home/tools/libraries/28nm/lib/stdcell_hvt/db_nldm /home/tools/libraries/28nm/lib/stdcell_lvt/db_nldm /home/tools/libraries/28nm/lib/stdcell_rvt/db_nldm /home/tools/libraries/28nm/lib/sram_lp_new/db_nldm }

# # 1. FAST LIBRARIES AT -40C (0.95V Base + Domain Translation Libraries)
set_app_var link_library "* saed32lvt_ff0p95v_40c.db saed32rvt_ff0p95v_40c.db saed32hvt_ff0p95v_40c.db saed32hvt_ulvl_ff0p85vn40c_i0p85v.db saed32lvt_ulvl_ff0p85vn40c_i0p85v.db saed32rvt_ulvl_ff0p85vn40c_i0p85v.db saed32hvt_dlvl_ff0p85vn40c_i0p85v.db saed32lvt_dlvl_ff0p85vn40c_i0p85v.db saed32rvt_dlvl_ff0p85vn40c_i0p85v.db saed32sramlp_ff1p16vn40c_i1p16v.db"

# Change according to your file paths

read_verilog /home/ajaym/projects/mv_macro_engine/PRIMETIME/inputs/routed_mv_macro_netlist.v
current_design mv_macro_engine_top
set link_create_black_boxes false
link_design mv_macro_engine_top -force

load_upf /home/ajaym/projects/mv_macro_engine/PRIMETIME/inputs/mv_macro_engine_top.upf

# # 2. FAST SCALING GROUPS (Removed SRAM because it is fixed at 1.16V)
define_scaling_lib_group { saed32lvt_ff0p85vn40c.db saed32lvt_ff0p95vn40c.db }
define_scaling_lib_group { saed32rvt_ff0p85vn40c.db saed32rvt_ff0p95vn40c.db }
define_scaling_lib_group { saed32hvt_ff0p85vn40c.db saed32hvt_ff0p95vn40c.db }

# # 3. SET VOLTAGES
set_voltage 0.95 -object_list [get_supply_nets VDD_DEFAULT]
set_voltage 0.85 -object_list [get_supply_nets VDD_LP]

set_eco_options -physical_icc2_lib /home/ajaym/projects/mv_macro_engine/outputs/work/MV_MACRO_ENGINE_HFSN.nlib -physical_icc2_blocks pt_fix_1

# # 4. BEST PARASITICS & -40C SDC
read_parasitics /home/ajaym/projects/mv_macro_engine/PRIMETIME/inputs/MV_MACRO_ENGINE.cbest.spef -keep_capacitive_coupling
# read_sdc /home/ajaym/PRIMETIME/inputs/ff_m40.sdc
read_sdc /home/ajaym/projects/mv_macro_engine/PRIMETIME/inputs/ff_m40.sdc

# # 1. Force the tool to ignore the "Ideal" setting from the SDC
# set_propagated_clock [all_clocks]

# # 2. Tell PT to honor the physical hierarchy (fixes the UITE-451 warning)
# set_disable_clock_gating_check false

set si_enable_analysis true
set si_xtalk_composite_aggr_mode statistical
check_eco
update_timing -full

save_session ./sessions/func_min.session
report_global_timing