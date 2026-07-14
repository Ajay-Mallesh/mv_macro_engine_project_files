set TECH_LIB_NAME [file rootname [file tail $TECH_LIB]]
# Slow corner uses maxTLU parasitics
set_parasitic_parameters -library $TECH_LIB_NAME -early_spec maxTLU -late_spec maxTLU

set_temperature 125
set_process_label slow

# Explicitly matching the names from your UPF 2.0 script
set_voltage 0.95 -object_list [get_supply_nets VDD_DEFAULT]
set_voltage 0.75 -object_list [get_supply_nets VDD_LP]
set_voltage 0.00 -object_list [get_supply_nets VSS]