# Extract Ports to a clean file
set p_fp [open "./docs/port_locations.tcl" "w"]
foreach_in_collection port [get_ports] {
    set box [get_attribute $port bbox]
    if {$box != ""} {
        # Extracts just the first {x y} pair
        set loc [lindex $box 0]
        puts $p_fp "[get_object_name $port] $loc"
    }
}
close $p_fp

# Extract Macros to a clean file
set m_fp [open "./docs/macro_locations.tcl" "w"]
foreach_in_collection cell [get_cells -hierarchical -filter "is_hard_macro"] {
    set loc [get_attribute $cell origin]
    if {$loc != ""} {
        puts $m_fp "[get_object_name $cell] $loc"
    }
}
close $m_fp

puts "Extraction complete: port_locations.tcl and macro_locations.tcl generated."