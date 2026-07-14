###########################################################################
# 1. INITIALIZATION & SETUP
###########################################################################

# copy_block -from *all_error* -to initial_placement
# open_block initial_placement

link

check_design -checks pre_placement_stage

# set_fixed_objects [get_flat_cells -filter "is_hard_macro"]

read_def ./outputs/fixed_high_fanouts/mv_macro_engine_top.scandef

source ./inputs/mcmm_files/mcmm_mv_macro_setup.tcl

###########################################################################
# 2. LIBRARY CONSTRAINTS
###########################################################################

set_attribute [get_lib_cells */*TIE*] dont_touch false
set_attribute [get_lib_cells */*TIE*] dont_use false

###########################################################################
# 3. PLACEMENT & ROUTING SETTINGS
###########################################################################

set_app_options -name place.legalize.enable_advanced_legalizer -value true
set_app_options -name place.legalize.legalizer_search_and_repair -value true
set_app_options -name place.coarse.max_density -value 0.75
set_app_options -name opt.common.max_fanout -value 25

set_ideal_network [all_fanout -clock_tree]

set_ignored_layers -min_routing_layer M2 -max_routing_layer M6
set_app_options -name route.common.net_max_layer_mode -value hard
set_app_options -name route.common.net_min_layer_mode -value allow_pin_connection

###########################################################################
# 4. BLOCKAGES & PLACEMENT EXECUTION
###########################################################################

remove_placement_blockages -all
derive_placement_blockages

# create_placement
# legalize_placement

###########################################################################
# 5. ANALYSIS & SAVING
###########################################################################

# report_congestion -rerun_global_router
# refine_placement -congestion_effort high
# save_block
# report_timing

place_opt

save_block -as r_shape_hfns_placement_done