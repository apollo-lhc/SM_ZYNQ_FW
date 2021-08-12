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

puts "Using path: ${apollo_root_path}"
puts "Building: ${build_name}"

source ${apollo_root_path}/scripts/settings_${build_name}.tcl

#reset IPs
for {set j 0} {$j < [llength $xci_files ] } {incr j} {
    set filename "${apollo_root_path}/[lindex $xci_files $j]"
    set ip_name [file rootname [file tail $filename]]
    set current_ip [read_ip -quiet $filename]
    puts "Upgrading $ip_name"
    upgrade_ip [get_ips $ip_name]
    export_ip_user_files -of_objects [get_ips $ip_name] -no_script -sync -force -quiet    
}

