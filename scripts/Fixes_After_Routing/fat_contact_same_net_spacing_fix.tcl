### To fix fat contact issue and Same Net spacing issues

# 1. Ensure all nets are unlocked so the detail router has permission to add the fat contacts
remove_attribute [get_nets -hierarchical *] dont_touch

# 2. Fire the surgical detail router to fix the remaining spacing and contact DRCs
route_detail -incremental true

# 3. Verify the final physical layout rules
check_routes