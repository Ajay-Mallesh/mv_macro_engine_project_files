############ UPSIZING THE DRIVER ############

# Procedure to upsize the driver cell connected to a given net
proc upsize_cell {nn} {

    # Get driver instance name connected to the net
    set dn [get_object_name \
        [get_flat_cells -of_objects \
        [get_pins [all_connected $nn -leaf] -filter "direction == out"]]]

    # $dn = instance name

    # Get current reference cell name
    set drn [get_attribute [get_flat_cells $dn] ref_name]

    # Example:
    # $drn = NBUFFX2LVT

    puts "driver_name : $dn  driver_ref_name : $drn"

    # Split ref name into:
    # rn = base name
    # ds = drive strength
    # vt = threshold type
    regexp -nocase {(.+X)([0-9]+)(.+)} $drn temp rn ds vt

    # Example:
    # rn = NBUFFX
    # ds = 2
    # vt = LVT

    # If drive strength is 0, make it 1
    if {$ds == 0} {
        set ds 1
    } else {

        # Double the drive strength
        set ds [expr {$ds * 2}]
    }

    # Example:
    # New cell = NBUFFX4LVT

    # Resize the cell
    size_cell $dn ${rn}${ds}${vt}

    # Get updated reference name
    set drn [get_attribute [get_cell $dn] ref_name]

    puts "driver_name : $dn  new_ref_name : $drn"
}

############ END OF PROC ############


# Input violation report file
set file_name "/home/ajaym/vg_10/pd/docs/max_cap_vio.txt"

# Open file in read mode
set fh_read [open $file_name r]

# Counters
set m 0
set n 0
set i 0

# Read file line by line
while {[gets $fh_read line] >= 0} {

    # Process only lines having 5 fields
    if {[llength $line] == 5} {

        incr i
        puts "\nIteration : $i"

        # Get net name from first column
        set net_name [lindex $line 0]

        # Try upsizing
        set flag [catch {upsize_cell $net_name}]

        if {$flag == 0} {

            puts "Upsize completed successfully"
            incr m

        } else {

            puts "Failed to upsize"
            incr n
        }

        # Print summary
        puts "Number of cells upsized : $m"
        puts "Number of cells failed  : $n"
    }
}

# Close file
close $fh_read