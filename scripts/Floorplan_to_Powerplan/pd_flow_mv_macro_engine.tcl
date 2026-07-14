#########################################################################
# Library Setup
#########################################################################

# Set search path for reference libraries
set search_path ./inputs/CLIBs/

# Define reference libraries
set ref_libs {saed32_1p9m_tech.ndm saed32_hvt.ndm saed32_lvt.ndm saed32_rvt.ndm saed32_sram_lp.ndm}

#########################################################################
# Create Working Directory
#########################################################################

# Create work directory
sh mkdir -p ./outputs/work

#########################################################################
# Create Design Library
#########################################################################

# Create ICC2 design library using reference libraries
create_lib -ref_libs $ref_libs ./outputs/work/MV_MACRO_ENGINE.nlib

# Save library
save_lib

#########################################################################
# Read Netlist and Link Design
#########################################################################

# Read synthesized Verilog netlist
read_verilog ./outputs/mv_macro_engine_top_netlist.v

# Link the design
link_block

#########################################################################
# Start GUI
#########################################################################

# Launch ICC2 GUI
start_gui

#########################################################################
# Initialize Floorplan
#########################################################################

# Create rectangular floorplan with 70% utilization
initialize_floorplan -shape R -side_ratio {1 1} -core_utilization 0.7 -core_offset 5 -site_def unit -use_site_row

# Save initial floorplan
save_block -as r_shape_initial_floorplan

#########################################################################
# Open Saved Floorplan
#########################################################################

# Close current block
close_blocks -force

# Open saved floorplan block
open_block r_shape_initial_floorplan

#########################################################################
# Input Pin Placement
#########################################################################

# Create guide region for all input pins except clock pins
create_pin_guide -boundary {{0.0000 1153.7920} {5.0000 1209.5880}} -layers M5 [remove_from_collection [all_inputs] [get_ports *clk*]]

# Place input pins
place_pins -ports [remove_from_collection [all_inputs] [get_ports *clk*]]

#########################################################################
# Output Pin Placement
#########################################################################

# Create guide region for output pins
create_pin_guide -boundary {{1231.4880 588.5280} {1236.4880 1125.2460}} -layers M5 [all_outputs]

# Place output pins
place_pins -ports [all_outputs]

#########################################################################
# Clock Pin Placement
#########################################################################

# Create guide region for clock ports
create_pin_guide -boundary {{597.4960 1230.5760} {681.0310 1235.5760}} -layers M6 [get_ports *clk*]

# Place clock pins
place_pins -ports [get_ports *clk*]

#########################################################################
# Save Floorplan with Pins
#########################################################################

# Save floorplan after pin placement
save_block -as r_shape_port_placed

#########################################################################
# Reopen Updated Block
#########################################################################

# Close current block
close_blocks -force

# Open port-placed floorplan
open_block r_shape_port_placed