############ INSERTING THE BUFFER ############

# Procedure to insert a buffer on the driver pin of a net
proc insert_buffer_cell {nn} {

    # Get driving output pin connected to the net
    set dpin [get_object_name \
        [get_pins [all_connected $nn -leaf] -filter "direction == out"]]

    # Example:
    # ISDRAM/U123/Y = dpin

    # Insert buffer cell
    set cn [insert_buffer $dpin NBUFFX8_LVT]

    # Get driver pin location
    set ploc [get_attribute [get_pins $dpin] location]

    # Move inserted buffer near the driver
    move_objects -to $ploc $cn
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

    # Process only valid violation lines
    if {[llength $line] == 5} {

        incr i
        puts "\nIteration : $i"

        # Get net name from first column
        set net_name [lindex $line 0]

        # Try buffer insertion
        set flag [catch {insert_buffer_cell $net_name}]

        if {$flag == 0} {

            puts "Buffer insertion completed successfully"
            incr m

        } else {

            puts "Failed to insert buffer"
            incr n
        }
    }
}

# Legalize placement after buffer insertion
legalize_placement -incremental

# Summary
puts "Number of buffers inserted : $m"
puts "Number of buffers failed   : $n"

# Close file
close $fh_read