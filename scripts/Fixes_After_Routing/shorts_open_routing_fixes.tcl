# ====================================================================
# PROJECT CONFIGURATION (Change these for new designs!)
# ====================================================================
set my_pg_nets [list "VDD" "VSS" "VDDH"] 


# 1. Clear blockages so the router can access pins
# (Careful: If you have permanent blockages, delete this section)
set my_blockages [get_routing_blockages -quiet *]
if {[sizeof_collection $my_blockages] > 0} {
    remove_routing_blockages $my_blockages
}

# ====================================================================
# FLOATING & OPEN PG NETS FIXES
# ====================================================================
echo "Cleaning up floating PG wire pieces..."
trim_pg_mesh -nets $my_pg_nets

echo "Checking and inserting missing PG vias..."
check_pg_missing_vias

# ====================================================================
# STUBBORN SHORTS FIXES
# ====================================================================
set rpt_file "my_shorts.rpt"
redirect -file $rpt_file {check_lvs -max_errors 0}

if {![file exists $rpt_file]} {
    echo "Error: Could not find $rpt_file!"
    return
}

set file_handle [open $rpt_file r]
set file_data [read $file_handle]
close $file_handle

set bad_signal_nets [list]

# Parse for ANY shorts
foreach line [split $file_data "\n"] {
    if {[string match "*short violation*" $line]} {
        
        # Scrape formatting 1: "Net1: name"
        foreach {match net_name} [regexp -all -inline {Net[12]:\s+([^\.\s]+)} $line] {
            # If the net is NOT in our PG list, add it to the bad signals list
            if {[lsearch -exact $my_pg_nets $net_name] == -1} {
                lappend bad_signal_nets $net_name
            }
        }
        
        # Scrape formatting 2: "(Net: name)"
        foreach {match net_name} [regexp -all -inline {\(Net:\s+([^\)]+)\)} $line] {
            if {[lsearch -exact $my_pg_nets $net_name] == -1} {
                lappend bad_signal_nets $net_name
            }
        }
    }
}

set unique_bad_nets [lsort -unique $bad_signal_nets]

if {[llength $unique_bad_nets] > 0} {
    echo "Found [llength $unique_bad_nets] stubborn signal nets. Running high-effort ECO..."
    set net_objects [get_nets -quiet $unique_bad_nets]
    
    remove_routes -nets $net_objects -detail_route
    route_eco -nets $net_objects -reuse_existing_global_route true -max_detail_route_iterations 40
} else {
    echo "Parsed the file, but found zero signal nets to route."
}