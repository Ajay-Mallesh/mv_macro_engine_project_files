# --- func_max.tcl (SETUP / MAX TIMING @ 125C) ---

# Kindly Read Timing Analysis Guide First
# Add path where your .db's are available

set search_path { /home/tools/libraries/28nm/lib/stdcell_hvt/db_nldm /home/tools/libraries/28nm/lib/stdcell_lvt/db_nldm /home/tools/libraries/28nm/lib/stdcell_rvt/db_nldm /home/tools/libraries/28nm/lib/sram_lp_new/db_nldm }

# 1. SLOW LIBRARIES AT 125C (Complete 0.95V Base + Domain Translation Libraries)
set_app_var link_library "* saed32lvt_ss0p95v125c.db saed32rvt_ss0p95v125c.db saed32hvt_ss0p95v125c.db saed32lvt_ulvl_ss0p95v125c_i0p75v.db saed32rvt_ulvl_ss0p95v125c_i0p75v.db saed32hvt_ulvl_ss0p95v125c_i0p75v.db saed32lvt_dlvl_ss0p75v125c_i0p95v.db saed32rvt_dlvl_ss0p75v125c_i0p95v.db saed32hvt_dlvl_ss0p75v125c_i0p95v.db saed32sramlp_ss0p95v125c_i0p95v.db"

# Change according to your file paths

read_verilog /home/ajaym/projects/mv_macro_engine/PRIMETIME/inputs/routed_mv_macro_netlist.v
current_design mv_macro_engine_top
set link_create_black_boxes false
link_design mv_macro_engine_top -force

load_upf /home/ajaym/projects/mv_macro_engine/PRIMETIME/inputs/mv_macro_engine_top.upf

# 2. SLOW SCALING GROUPS at 125C
define_scaling_lib_group { saed32lvt_ss0p75v125c.db saed32lvt_ss0p95v125c.db }
define_scaling_lib_group { saed32rvt_ss0p75v125c.db saed32rvt_ss0p95v125c.db }
define_scaling_lib_group { saed32hvt_ss0p75v125c.db saed32hvt_ss0p95v125c.db }
define_scaling_lib_group { saed32sramlp_ss0p75v125c_i0p75v.db saed32sramlp_ss0p95v125c_i0p95v.db }

# 3. SET LOWEST VOLTAGES (Slows down logic for worst-case Setup)
set_voltage 0.95 -object_list [get_supply_nets VDD_DEFAULT]
set_voltage 0.75 -object_list [get_supply_nets VDD_LP]

set_eco_options -physical_icc2_lib /home/ajaym/projects/mv_macro_engine/outputs/work/MV_MACRO_ENGINE_HFSN.nlib -physical_icc2_blocks pt_fix_1

# 4. WORST PARASITICS & 125C SDC
read_parasitics /home/ajaym/ projects/mv_macro_engine/PRIMETIME/inputs/MV_MACRO_ENGINE.cworst.spef -keep_capacitive_coupling
#read_sdc /home/ajaym/PRIMETIME/inputs/ss_125.sdc
read_sdc /home/ajaym/projects/mv_macro_engine/PRIMETIME/inputs/ss_125.sdc

# remove_ideal_network [get_pins {u_lp_ram_subsystem/clk}]

# set_propagated_clock [get_clocks clk]

set si_enable_analysis true
set si_xtalk_composite_aggr_mode statistical
check_eco
update_timing -full

save_session ./sessions/func_max.session
report_global_timing
report_global_timing -pba_mode path