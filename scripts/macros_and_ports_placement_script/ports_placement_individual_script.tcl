# read the file contains the locations of the ports
# make sure you have extracted Ports locations from the design

set port_fh [open ./docs/port_locations.tcl r]

# loop it, with line by line where line should not be with length o

while {[gets $port_fh line] != -1} {

    # continue only if length of the line is > 0

    if {[llength $line] > 0} {

        # check if the are any other character is there in starting of the line, Eg : "#" for commented lines

        # change list into string for index 0
        set string_index [lindex $line 0]

        #puts "string_length of index 0 is [string index $string_index 0]"

        # check if string index is not matched with "#"
        # if matched with "#" exclude that line

        # Example : #VDD DEFAULT 618.2440 617.7880 ; excludes this line

        # only extract the index 0 of line which "string index 0 is not equal to '#'

        if {[string index $string_index 0] ne "#"} {

            set port_name [lindex $line 0]

            if {[lindex $line 1] >= 1230.0000} {

                set port_coordinates_start [expr {[lindex $line 1] - 7.0000}]
                set port_coordinates_new [list $port_coordinates_start [lindex $line 2]]

                puts "list are $port_coordinates_new"

                #set port_coordinates_reduced [lrange $port_coordinates_new 0 1]

                set_individual_pin_constraints -ports $port_name -location $port_coordinates_new -allowed_layers {M5 M6}
                place_pins -ports $port_name

            } else {

                # set port_name [lindex $line 0]
                set port_coordinates [lrange $line 1 2]

                # puts "index 0 is [lindex $line 0]"
                # puts "index 1 & 2 are [lrange $line 1 2]"

                set_individual_pin_constraints -ports $port_name -location $port_coordinates -allowed_layers {M5 M6}
                place_pins -ports $port_name
            }
        }
    }
}

close $port_fh