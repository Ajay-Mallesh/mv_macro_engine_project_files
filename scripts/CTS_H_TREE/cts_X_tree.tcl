# ==========================================================================
# AUTHOR         : AJAYMALLESH
# PROJECT        : Multi-Voltage Crypto Core
# DESCRIPTION    : Production-Grade X-Tree Clock Tree Synthesis Script
#                  (ANCHORED TOPOLOGY - M7/M8 RESERVED FOR PDN)
# ==========================================================================

puts "--- <CTS_INIT> Initializing Clock Tree Synthesis Flow ---"

# ==========================================================================
# 0. PRE-CTS CLEANUP: REMOVE IDEAL NETWORKS AND DONT_TOUCH 
# ==========================================================================
# 1. Remove placement restrictions
set_dont_touch [get_nets clk] false
set_dont_touch [get_cells -hierarchical -filter "ref_name=~LSDNSSX1*"] false

# 2. THE CRITICAL FIX: Strip the ideal network flags so CTS sees the physical load
remove_ideal_network [all_fanout -flat -clock_tree]
remove_ideal_network [get_pins -hierarchical *clk*]
remove_ideal_network [get_pins -hierarchical u_lp_ram_subsystem/*]

# 3. Force the database to acknowledge the clocks will be physical
set_propagated_clock [all_clocks]

# ==========================================================================
# 1. LIB CELL PURPOSE & REFERENCE SETUP
# ==========================================================================
set_lib_cell_purpose -exclude cts [get_lib_cells]
source ./scripts/cts_include_refs.tcl
set_lib_cell_purpose -include cts [get_lib_cells "*/NBUFF*LVT */NBUFF*RVT */INVX*_LVT */INVX*_RVT */*DFF* */LSDNSSX1*"]

# ==========================================================================
# 2. NON-DEFAULT ROUTING (NDR) & LAYER CONSTRAINTS (X-TREE SPECIFIC)
# ==========================================================================
remove_routing_rules -all

# X-Tree staircase routing requires double width and double spacing to mitigate RC
create_routing_rule X_TREE_NDR \
    -default_reference_rule \
    -multiplier_width 2 \
    -multiplier_spacing 2 \
    -taper_distance 0.4 \
    -driver_taper_distance 0.4

# Strictly capping at M6 to reserve M7/M8 for the Power Delivery Network (PDN)
set_clock_routing_rules -net_type sink -rules X_TREE_NDR -min_routing_layer M4 -max_routing_layer M5
set_clock_routing_rules -net_type root -rules X_TREE_NDR -min_routing_layer M5 -max_routing_layer M6
set_clock_routing_rules -net_type internal -rules X_TREE_NDR -min_routing_layer M5 -max_routing_layer M6

# ==========================================================================
# 3. GLOBAL CTS CONSTRAINTS
# ==========================================================================
current_mode func
set_max_transition 0.15 -clock_path [get_clocks] -corners [all_corners]
set_clock_tree_options -target_skew 0.05 -corners [get_corners ss_125c]
set_clock_tree_options -target_skew 0.02 -corners [get_corners ff_m40c]

foreach_in_collection scen [all_scenarios] {
    current_scenario $scen
    set_clock_uncertainty 0.1 -setup [all_clocks]
    set_clock_uncertainty 0.05 -hold [all_clocks]
}

set_app_options -name time.remove_clock_reconvergence_pessimism -value true

# ==========================================================================
# 4. HOLD FIXING PREPARATION
# ==========================================================================
set_lib_cell_purpose -exclude hold [get_lib_cells]
set_lib_cell_purpose -include hold [get_lib_cells "*/DELLN*_HVT */NBUFFX2_HVT */NBUFFX4_HVT */NBUFFX8_HVT"]

# ==========================================================================
# 5. NAMING PREFIX CONFIGURATIONS
# ==========================================================================
set_app_options -name cts.common.user_instance_name_prefix -value clock_opt_clock_
set_app_options -name opt.common.user_instance_name_prefix -value clock_opt_opt_

# ==========================================================================
# 5.5 X-TREE TOPOLOGY ANCHOR PLACEMENT
# ==========================================================================
# Dynamically extract core bounding box to calculate exact X-Tree node coordinates
set bbox [get_attribute [current_block] core_area]
set llx [lindex [lindex $bbox 0] 0]
set lly [lindex [lindex $bbox 0] 1]
set urx [lindex [lindex $bbox 1] 0]
set ury [lindex [lindex $bbox 1] 1]

# Calculate Center and Quadrant Midpoints
set cx [expr {($llx + $urx) / 2.0}]
set cy [expr {($lly + $ury) / 2.0}]
set q1x [expr {($cx + $urx) / 2.0}]
set q1y [expr {($cy + $ury) / 2.0}]
set q2x [expr {($llx + $cx) / 2.0}]
set q2y [expr {($cy + $ury) / 2.0}]
set q3x [expr {($llx + $cx) / 2.0}]
set q3y [expr {($lly + $cy) / 2.0}]
set q4x [expr {($cx + $urx) / 2.0}]
set q4y [expr {($lly + $cy) / 2.0}]

# Manually instantiate and freeze heavy drive buffers to form the "X" structure
set anchor_ref [get_lib_cells */NBUFFX16_RVT]

create_cell u_xtree_center $anchor_ref
set_cell_location -coordinates [list $cx $cy] u_xtree_center

create_cell u_xtree_q1 $anchor_ref
set_cell_location -coordinates [list $q1x $q1y] u_xtree_q1

create_cell u_xtree_q2 $anchor_ref
set_cell_location -coordinates [list $q2x $q2y] u_xtree_q2

create_cell u_xtree_q3 $anchor_ref
set_cell_location -coordinates [list $q3x $q3y] u_xtree_q3

create_cell u_xtree_q4 $anchor_ref
set_cell_location -coordinates [list $q4x $q4y] u_xtree_q4

set_placement_status fixed [get_cells u_xtree_*]

# Force CTS to treat these physical locations as absolute stop pins before branching
set_clock_tree_exceptions -stop_pins [get_pins u_xtree_*/A]

# ==========================================================================
# 6. X-TREE SYNTHESIS & ROUTING
# ==========================================================================
remove_routes -global_route

# REMOVE the LSDNSSX1 from driver_objects. 
# Only use the standard buffers (NBUFF) to build the tree backbone.
set_multisource_clock_subtree_options \
    -clock [all_clocks] \
    -driver_objects [get_flat_cells -filter "ref_name=~NBUFFX2_LVT"]

# Explicitly tell the tool that the Level Shifter is a transparent component
# This allows the CTS engine to 'see' through the level shifter to the registers on the other side.
set_lib_cell_purpose -include cts [get_lib_cells "*/NBUFF*LVT */NBUFF*RVT */LSDNSSX1*"]

puts "--- <CTS_EXEC> Running clock_opt ---"
clock_opt -to build_clock
save_block -as build_clock_done_fixed
clock_opt -to route_clock
save_block -as cts_done_fixed

# ==========================================================================
# 7. POST-CTS OPTIMIZATION
# ==========================================================================
set_app_options -name clock_opt.flow.skip_hold -value false
set_app_options -name opt.timing.effort -value high
set_app_options -name ccd.hold_control_effort -value high
set_app_options -name opt.dft.clock_aware_scan_reorder -value true

clock_opt -from final_opto
save_block -as clock_opt_all_fixed

# ==========================================================================
# 8. QOR REPORTING
# ==========================================================================
#file mkdir ./report
#report_clock_qor > ./report/cts_qor.rpt
#report_timing -delay_type max > ./report/post_cts_setup.rpt
#report_timing -delay_type min > ./report/post_cts_hold.rpt