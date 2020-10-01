puts $argc
puts $argv
if { $argc >= 1 } {
    set apollo_root_path [lindex $argv 0]
} else { 
    set apollo_root_path ".."
}
puts "Using path: ${apollo_root_path}"

source ${apollo_root_path}/scripts/Setup.tcl
source ${apollo_root_path}/scripts/Build.tcl
