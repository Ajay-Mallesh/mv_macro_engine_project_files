#pt_shell -multi_scenario -output_log_file ./outputs/$DATE.log

# Kindly Read Timing Analysis Guide First

file delete -force ./work
set multi_scenario_working_directory ./work
set multi_scenario_merged_error_log ./work/error_log.txt
set host_options -name my_hosts -num_processes 2 [info hostname] -max_cores 1
create_scenario -image ./sessions/func_max.session/ -name func_max
create_scenario -image ./sessions/func_min.session/ -name func_min
start_hosts
current_session -all
#set_eco_scenarios -ignore -type {setup} {func_min}
#set_eco_scenarios -ignore -type {hold} {func_max}
check_eco

###### MAX TRANS ##

report_constraints -max_transition -all_violators -significant_digits 5

fix_eco_drc -buffer_list {NBUFFX2_RVT NBUFFX4_RVT NBUFFX8_RVT NBUFFX16_RVT} -physical_mode occupied_site -type max_transition

fix_eco_drc -buffer_list {NBUFFX2_RVT NBUFFX4_RVT NBUFFX8_RVT NBUFFX16_RVT} -type max_transition -unfixable_reasons_format text -unfixable_reasons_prefix mtv

remote_execute {
set_eco_options -physical_enable_clock_data
}

fix_eco_drc -type max_transition -buffer_list {NBUFFX2_RVT NBUFFX4_RVT NBUFFX8_RVT NBUFFX16_RVT} -cell_type clock_network
report_constraints -max_transition -all_violators -significant_digits 5

### MAX _CAP

## MAX CAP ##

report_constraints -max_capacitance -all_violators -significant_digits 5

fix_eco_drc -buffer_list {NBUFFX2_RVT NBUFFX4_RVT NBUFFX8_RVT NBUFFX16_RVT} -physical_mode occupied_site -type max_capacitance

fix_eco_drc -buffer_list {NBUFFX2_RVT NBUFFX4_RVT NBUFFX8_RVT NBUFFX16_RVT} -type max_capacitance -unfixable_reasons_format text -unfixable_reasons_prefix mcv

fix_eco_drc -type max_capacitance -buffer_list {NBUFFX2_RVT NBUFFX4_RVT NBUFFX8_RVT NBUFFX16_RVT} -cell_type clock_network
report_constraints -max_capacitance -all_violators -significant_digits 5

# XTALK

#####

report_noise -nworst_pins 10

#Xtalk_noise
fix_eco_drc -type noise -buffer_list {NBUFFX2_RVT NBUFFX4_RVT NBUFFX8_RVT NBUFFX16_RVT}

#Xtalk_delay
fix_eco_drc -type delta_delay -buffer_list {NBUFFX2_RVT NBUFFX4_RVT NBUFFX8_RVT NBUFFX16_RVT} -delta_delay_threshold 0.01

fix_eco_drc -type delta_delay -buffer_list {NBUFFX2_RVT NBUFFX4_RVT NBUFFX8_RVT NBUFFX16_RVT} -delta_delay_threshold 0.01 -cell_type clock_network

#################### BOTTLENECK #############

report_si_bottleneck

## SETUP ##

report_global_timing
fix_eco_timing -type setup -physical_mode occupied_site

fix_eco_timing -type setup -physical_mode occupied_site -verbose

fix_eco_timing -type setup -cell_type sequential

#### HOLD #

report_global_timing

fix_eco_timing -type hold -physical_mode occupied_site -buffer_list {NBUFFX2_HVT NBUFFX4_HVT NBUFFX8_HVT NBUFFX16_HVT NBUFFX32_HVT}

### HOLD fix after fixing 1st hold in the design ###
fix_eco_timing -type hold -buffer_list {NBUFFX2_HVT NBUFFX4_HVT NBUFFX8_HVT NBUFFX16_HVT NBUFFX32_HVT}


###############################################
report_analysis_coverage
report_noise -nworst_pins 10

#### Output ######

write_changes -format icc2tcl -output ./outputs/Multi_scenario.tcl

#IN ICC2
source ../PRIMETIME/outputs/Multi_scenario.tcl

check_legality

legalize_placement -incremental -moveable_distance 50

#legalize_placement -incremental

check_legality

connect_pg_net

route_eco -utilize_dangling_wires true -reuse_existing_global_route true -reroute_modified_nets_first_then_others

#save_block -as prac1

check_routes

check_lvs -max_errors 0

optimize_routes

check_routes

check_lvs -max_errors 0

check_pg_drc -do_not_check_in_hier_blocks

report_global_timing


#DO the signoff again -> generate spef -> primetime -> dmsa

check_routes

check_lvs -max_errors 0

check_pg_drc -do_not_check_shapes_in_hier_blocks

save_block -as prac3