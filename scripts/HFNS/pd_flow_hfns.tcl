###########################################################################
# Library Setup
###########################################################################

# Search path for technology and reference libraries
set search_path "./inputs/CLIBs/"

# Reference libraries
set ref_libs {saed32_1p9m_tech.ndm saed32_hvt.ndm saed32_lvt.ndm saed32_rvt.ndm saed32_sram_lp.ndm}

# Create design library with reference libraries
create_lib -ref_libs $ref_libs ./outputs/work/MV_MACRO_ENGINE_HFSN.nlib

save_lib

###########################################################################
# Read Netlist and Create Initial Floorplan
###########################################################################

# Read synthesized netlist
read_verilog ./outputs/fixed_high_fanouts/mv_macro_engine_top_netlist_sfo.v

# Link design
link_block

# Launch GUI
start_gui

# Create initial R-shaped floorplan
initialize_floorplan -shape R -side_ratio {1 1} -core_utilization 0.7 -core_offset 5 -site_def unit -use_site_row

# Save initial floorplan
save_block -as hfns_r_shape_initial_fp
close_blocks -force

###########################################################################
# Port Placement
###########################################################################

# Open saved floorplan
open_block hfns_r_shape_initial_fp
link_block

# Get the Ports coordinates files into the required location

# Macro and Ports Location Extractor script:
# /home/ajaym/vg_10/projects/mv_macro_engine/scripts/macro_and_ports_extraction.tcl

# Ports Coordinates File:
# /home/ajaym/vg_10/projects/mv_macro_engine/docs/port_locations.tcl

# Place ports using extracted coordinates
source ./scripts/ports_placement.tcl

# Save design after port placement
save_block -as hfns_r_shape_ports_placed
close_blocks -force

###########################################################################
# Voltage Area Creation
###########################################################################

# Open design with ports placed
open_block hfns_r_shape_ports_placed
link_block

# Voltage Area script:
# /home/ajaym/vg_10/projects/mv_macro_engine/scripts/v_a_efficient.tcl

source ./scripts/v_a_efficient.tcl

###########################################################################
# Macro Placement
###########################################################################

# Get the Macros Location files into the required path
# (same script used for Macro Location Extraction)

# Macro and Ports Location Extractor script:
# /home/ajaym/vg_10/projects/mv_macro_engine/scripts/macro_and_ports_extraction.tcl

# Macros Location File:
# /home/ajaym/vg_10/projects/mv_macro_engine/docs/macro_locations.tcl

# Place macros using extracted coordinates
source ./scripts/macro_placement_script.tcl

# Save design after macro placement
save_block -as hfns_r_shape_macro_placed
close_blocks -force

###########################################################################
# Open Final Macro-Placed Design
###########################################################################

open_block hfns_r_shape_macro_placed
link_block