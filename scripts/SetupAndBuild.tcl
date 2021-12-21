puts $argc
puts $argv

if { $argc == 2 } {
    set build_name       [lindex $argv 1]
    set apollo_root_path [lindex $argv 0]
} elseif {$argc == 1} {
    set build_name "xc7z035"
    set apollo_root_path [lindex $argv 0]
} else {
    set build_name "xc7z035"
    set apollo_root_path ".."
}

set autogen_path configs/${build_name}/autogen
file mkdir ${apollo_root_path}/$autogen_path

set BD_PATH ${apollo_root_path}/bd

puts "Using path: ${apollo_root_path}"
puts "Building: ${build_name}"

set start_time [clock seconds]
source ${apollo_root_path}/scripts/Setup.tcl
set setup_end_time [clock seconds]
source ${apollo_root_path}/scripts/Build.tcl
set build_end_time [clock seconds]

puts -nonewline "Setup time: " 
puts -nonewline [expr (${setup_end_time} - ${start_time})/60.0]
puts " minutes"

puts -nonewline "Build time: " 
puts -nonewline [expr (${build_end_time} - ${setup_end_time})/60.0]
puts " minutes"
