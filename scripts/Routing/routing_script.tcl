# ==========================================================================
# FILE: scripts/routing_script.tcl
# DESC: Production Routing & Signoff Optimization for Crypto_Top
# AUTHOR: Ajay Mallesh
# VERSION: 1.0
# DATE: May 21, 2026 | 16:30 IST
# ==========================================================================

# 1. Design Checks
check_design -checks pre_route_stage
# check_routability > ./reports/routability.rpt

# 2. Timing Driven Routing
set_app_options -name route.global.timing_driven -value true
set_app_options -name route.track.timing_driven -value true
set_app_options -name route.detail.timing_driven -value true

# 3. Crosstalk Aware Routing
set_app_options -name route.global.crosstalk_driven -value true
set_app_options -name route.track.crosstalk_driven -value true

# 4. Timing Check Options
set_app_options -name time.si_enable_analysis -value true
set_app_options -name time.si_xtalk_composite_aggr_mode -value statistical
set_app_options -name time.all_clocks_propagated -value true

# 5. Instance Prefixing
set_app_option -name opt.common.user_instance_name_prefix -value route_opt_

# 6. CTS Protection
set_dont_touch_network -clock_only [get_ports *clk*]

# 7. Antenna Rule File
source ./scripts/saed32nm_ant_1p9m.tcl

# Force the tool to respect M1-M5 macro restrictions if the NDM is missing them
set all_macros [get_cells -hierarchical -filter "is_macro == true"]
foreach_in_collection macro $all_macros {
    create_routing_blockage -layers {M1 M2 M3 M4 M5} -boundary [get_attribute $macro bbox]
}

# 8. Routing Execution
route_auto -save_after_global_route true -save_after_track_assignment true -save_after_detail_route true

# 9. Optimization & Save
route_opt
save_block -as route_opt_all