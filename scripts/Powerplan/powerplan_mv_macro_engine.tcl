#===========================================================================
# FINAL MASTER POWER PLAN (M7/M8 MESH + M5/M6 RINGS + MACRO PINS)
# AUTHOR         : AJAYMALLESH
# PROJECT        : Multi-Voltage Macro Engine
# DATE           : 23/06/2026
#===========================================================================
remove_pg_strategies -all
remove_pg_patterns -all
remove_pg_regions -all
remove_pg_via_master_rules -all
remove_pg_strategy_via_rules -all
remove_routes -net_types {power ground} -ring -stripe -macro_pin_connect -lib_cell_pin_connect
remove_routes -net_types {power ground} -ring -global_route -detail_route
remove_vias [get_vias]

#===========================================================================
# 1. EXPLICIT LOGICAL NET DEFINITION & UPF BINDING
#===========================================================================
create_net -power VDD_DEFAULT
create_net -power VDD_LP
create_net -ground VSS

# Names perfectly match UPF; automatic binding resolves all connections
connect_pg_net

#===========================================================================
# 2. SETUP VIA MASTERS & MACRO COLLECTIONS
#===========================================================================
set_pg_via_master_rule pgvia_8x10 -via_array_dimension {8 10}

set all_macros [get_cells -hierarchical -filter "is_hard_macro"]
set hm_lp_macros [get_flat_cells -filter "is_hard_macro" u_lp_ram_subsystem/*]
set hm_top [remove_from_collection $all_macros $hm_lp_macros]

suppress_message PGR-599

#===========================================================================
# 3. MAIN POWER MESH (M7/M8 Coarse & M2 Fine)
#===========================================================================
create_pg_mesh_pattern P_top_two -layers { \
    {{horizontal_layer: M7} {width: 1.104} {spacing: interleaving} {pitch: 13.376} {offset: 0.856} {trim: true}} \
    {{vertical_layer: M8} {width: 4.64} {spacing: interleaving} {pitch: 19.456} {offset: 6.00} {trim: true}} \
} -via_rule {{intersection: adjacent} {via_master: pgvia_8x10}}

create_pg_mesh_pattern P_m2_triple -layers { \
    {{vertical_layer: M2} {track_alignment: track} {width: 0.44 0.192 0.192} {spacing: 2.724 3.456} {pitch: 9.728} {offset: 1.216} {trim: true}} \
}

#===> PG Strategy for M7 and M8 straps
set_pg_strategy S_default_vddvss -core -pattern {{name: P_top_two} {nets: {VSS VDD_DEFAULT}} {offset_start: {0 0}}} -blockage {{nets: VDD_DEFAULT} {voltage_areas: PD_LP}} -extension {{stop: design_boundary_and_generate_pin}}
set_pg_strategy S_va_vdd_lp -voltage_areas PD_LP -pattern {{name: P_top_two} {nets: {- VDD_LP}} {offset_start: {0 0}}} -extension {{direction: BL} {stop: design_boundary_and_generate_pin}}

#===> PG strategy for lower mesh - M2
set_pg_strategy S_m2_vddvss -core -pattern {{name: P_m2_triple} {nets: {VDD_DEFAULT VSS VSS}} {offset_start: {0 0}}} -blockage { {{nets: VDD_DEFAULT} {voltage_areas: PD_LP}} {macros_with_keepout: $all_macros} } -extension {{stop: keep_floating_wire_pieces}}
set_pg_strategy S_m2_vdd_lp -voltage_areas PD_LP -pattern {{name: P_m2_triple} {nets: {VDD_LP - -}} {offset_start: {0 0}}} -extension {{direction: B} {stop: design_boundary_and_generate_pin}}

# EXACT MATCH TO ORCATOP REFERENCE (No checker_board skip, exact brace structure)
set_pg_strategy_via_rule S_via_m2_m7 -via_rule { \
    { {{strategies: {S_m2_vddvss S_m2_vdd_lp}} {layers: {M2}} {nets: {VDD_DEFAULT VDD_LP}}} {{strategies: {S_default_vddvss S_va_vdd_lp}} {layers: {M7}}} {via_master: {default}} } \
    { {{strategies: {S_m2_vddvss S_m2_vdd_lp}} {layers: {M2}} {nets: {VSS}}} {{strategies: {S_default_vddvss S_va_vdd_lp}} {layers: {M7}}} {via_master: {default}} } \
}

compile_pg -strategies {S_va_vdd_lp S_m2_vdd_lp}
compile_pg -strategies {S_default_vddvss S_m2_vddvss} -via_rule {S_via_m2_m7}

#===========================================================================
# 4. MACRO RINGS
#===========================================================================
create_pg_ring_pattern MACRO_RING_PATTERN \
    -horizontal_layer M5 -vertical_layer M6 \
    -horizontal_width 0.52 -vertical_width 0.52

set_pg_strategy MACRO_RING_VDD_STRATEGY -pattern {{name: MACRO_RING_PATTERN} {nets: {VDD_DEFAULT VSS}} {offset: {0.5 0.5}}} -macros $hm_top
set_pg_strategy MACRO_RING_VDD_LP_STRATEGY -pattern {{name: MACRO_RING_PATTERN} {nets: {VDD_LP VSS}} {offset: {0.5 0.5}}} -macros $hm_lp_macros

set_pg_strategy_via_rule S_ring_vias -via_rule { \
    {{{strategies: MACRO_RING_VDD_STRATEGY MACRO_RING_VDD_LP_STRATEGY} {layers: {M5}}} {existing: {strap}} {via_master: {default}}} \
    {{{strategies: MACRO_RING_VDD_STRATEGY MACRO_RING_VDD_LP_STRATEGY} {layers: {M6}}} {existing: {strap}} {via_master: {default}}} \
}

compile_pg -strategies {MACRO_RING_VDD_STRATEGY MACRO_RING_VDD_LP_STRATEGY} -via_rule S_ring_vias

#===========================================================================
# 5. MACRO PIN CONNECTIONS
#===========================================================================
create_pg_macro_conn_pattern P_HM_pin -pin_conn_type scattered_pin -layers {M5 M6}
set_pg_strategy S_HM_top_pins -macros $hm_top -pattern {{pattern: P_HM_pin} {nets: {VSS VDD_DEFAULT}}}
set_pg_strategy S_HM_lp_pins -macros $hm_lp_macros -pattern {{pattern: P_HM_pin} {nets: {VSS VDD_LP}}}

compile_pg -strategies {S_HM_top_pins S_HM_lp_pins}

#===========================================================================
# 6. STANDARD CELL RAILS
#===========================================================================
create_pg_std_cell_conn_pattern P_std_cell_rail

set_pg_strategy S_std_cell_rail_VSS_VDD -core -blockage { {{nets: VDD_DEFAULT} {voltage_areas: PD_LP}} {macros_with_keepout: $all_macros} } -pattern {{pattern: P_std_cell_rail} {nets: {VSS VDD_DEFAULT}}}
set_pg_strategy S_std_cell_rail_VDD_LP -voltage_areas PD_LP -blockage { {macros_with_keepout: $all_macros} } -pattern {{pattern: P_std_cell_rail} {nets: {VDD_LP}}}

set_pg_strategy_via_rule S_via_stdcellrail -via_rule {{{intersection: adjacent} {via_master: VIA12SQ}}}

compile_pg -strategies {S_std_cell_rail_VSS_VDD S_std_cell_rail_VDD_LP} -via_rule {S_via_stdcellrail}

#===========================================================================
# 7. VERIFICATION
#===========================================================================
check_pg_missing_vias
check_pg_drc -ignore_std_cells
check_pg_connectivity -check_std_cell_pins none