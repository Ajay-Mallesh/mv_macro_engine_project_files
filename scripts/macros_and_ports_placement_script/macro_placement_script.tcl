# read the file contains the locations of the macros
# make sure you have extracted Macro locations from the design

set macro_fh [open ./docs/macro_locations.tcl r]

# loop it, with line by line where line should not be with length 0

puts "RM-info: Macro Placement with coordinates started!"

while {[gets $macro_fh line] != -1} {

    # continue only if length of the line is > 0

    if {[llength $line] > 0} {

        # check if the are any other character is there in starting of the line, Eg : "#" for commented lines

        # change list into string for index 0
        set string_index_0 [lindex $line 0]

        #puts "string_length of index_0 is [string index $string_index_0 0]"

        # check if string index is not matched with "#"
        # if matched with "#" exclude that line

        # Example : #VDD DEFAULT 618.2440 617.7880 ; excludes this line

        # only extract the index 0 of line which "string index 0 is not equal to '#' "

        if {[string index $string_index_0 0] ne "#"} {

            set macro_name [lindex $line 0]

            set coordinates [lrange $line 1 2]

            set_cell_location [get_flat_cells $macro_name] -coordinates $coordinates
        }
    }
}

puts "RM-info: Macro Placement with coordinates Finishd !!! "

set_fixed_objects [get_flat_cells -filter "is_hard_macro"]

puts "RM-info: Macro Placed and Fixed"

create_keepout_margin -outer {1 1 1 1} [get_flat_cells -filter "is_hard_macro"]

puts "RM-info: Macro Keepout Margins created"

derive_placement_blockages

puts "RM-info: Placement Blockages are created"

close $macro_fh