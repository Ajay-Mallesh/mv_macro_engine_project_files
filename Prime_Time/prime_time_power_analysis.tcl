
remove_design -all

set_app_var search_path ./inputs/

set_app_var link_library {saed32rvt_ff1p16vn40c.db saed32rvt_ss0p75v125c.db saed32rvt_ss0p95v125c.db saed32rvt_dlvl_ss0p75v125c_i0p95v.db saed32rvt_ulvl_ss0p95v125c_i0p75v.db}

read_verilog ./outputs/fixed_high_fanouts/mv_macro_engine_top_netlist_sfo.v

# do list_designs
# 1. If you are not able to see "mv_macro_engine_top"
# remove_design -all

# 2. read_verilog ./outputs/fixed_high_fanouts/mv_macro_engine_top_netlist_sfo.v
# current_design mv_macro_engine_top

link

# check current_design
# current_design mv_macro_engine_top

# Enable the analysis engine
set_app_var power_enable_analysis true

# 1. Apply a default toggle rate (e.g., 20% toggle rate, 50% static probability)
# This simulates a design that is moderately active
set_switching_activity -toggle_rate 0.2 -static_probability 0.5 [all_inputs]

# 2. Propagate this activity to all internal registers and gates
# This is the step that was missing before!
update_power

# Update the design to propagate this activity through the gates
update_power

# Create the folder if it doesn't exist
file mkdir ./pwr_report

# Generate the high-accuracy report
report_power -hierarchy -verbose -nosplit > ./pwr_report/mv_macro_power_report.rpt

# -hierarchy tells it to list the sub-modules
# -levels 2 will show you the first two levels of your hierarchy
report_power -hierarchy -levels 2 -verbose > ./pwr_report/mv_macro_power_breakdown.rpt

# Report leakage power grouped by cell type
report_power -cell_power -verbose > ./pwr_report/leakage_by_cell.rpt

report_power -instance [get_designs *] -hierarchy -verbose > ./pwr_report/instance_power_breakdown.rpt

report_power -hierarchy -verbose [get_designs mv_macro_engine_top] > ./pwr_report/power_breakdown.rpt

