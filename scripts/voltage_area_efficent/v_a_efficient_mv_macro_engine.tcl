###########################################################################
# DYNAMIC DISJOINT VOLTAGE AREA (MANUAL HEIGHT CONTROL)
###########################################################################

# LOAD UPF
load_upf ./outputs/mv_macro_engine_top.upf

remove_voltage_area -all

set sum 0

###########################################################################
# 1. CALCULATE TOTAL AREA OF LP DOMAIN
###########################################################################

foreach area [get_attribute [get_flat_cells *u_lp_ram_subsystem*] area] {
    set sum [expr {$sum + $area}]
}

puts "Total logic area is : $sum"

###########################################################################
# 2. APPLY UTILIZATION AND SPLIT IN HALF
###########################################################################

set util 0.7
set total_voltage_area [expr {$sum / $util}]

puts "Total area of PD_LP with 0.7 utilization is : $total_voltage_area"

###########################################################################
# 3. MANUAL HEIGHT DIMENSIONS
###########################################################################

# Change this number to whatever height you want.
# The script will automatically calculate the width required to meet the area.

set height 235.0

# Snap height to Y-axis grid
set h [expr {ceil($height / 1.672) * 1.672}]

# Calculate required width based on area and snap to X-axis grid
set width [expr {$total_voltage_area / $height}]
set w [expr {ceil($width / 0.152) * 0.152}]

puts "Snapped Island Width  : $w"
puts "Snapped Island Height : $h"

###########################################################################
# 4. CALCULATE COORDINATES
###########################################################################

set llx1 10.016
set lly1 10.016

set urx1 [expr {$llx1 + $w}]
set ury1 [expr {$lly1 + $h}]

set island1 [list \
    [list $llx1 $lly1] \
    [list $urx1 $ury1]]

###########################################################################
# 5. CREATE THE DISJOINT VOLTAGE AREA
###########################################################################

create_voltage_area \
    -power_domain PD_LP \
    -region $island1 \
    -guard_band {{5.016 5.016}}

puts "RM-info : Disjoint PD_LP created with manual height!"