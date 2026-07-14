set TECH_LIB_NAME [file rootname [file tail $TECH_LIB]]
set_parasitic_parameters -library $TECH_LIB_NAME -early_spec minTLU -late_spec minTLU

set_temperature -40
set_process_number 1.01
set_process_label fast

# Explicitly matching the names from your UPF 2.0 script
set_voltage 0.95 -object_list [get_supply_nets VDD_DEFAULT]
set_voltage 0.75 -object_list [get_supply_nets VDD_LP]
set_voltage 0.00 -object_list [get_supply_nets VSS]