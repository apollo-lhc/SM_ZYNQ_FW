proc md5 {string} {
    #tcllib way:
#    package require md5
#    string tolower [::md5::md5 -hex $string]

    #BSD way:
    #exec -- md5 -q -s $string

    #Linux way:
    exec -- echo -n $string | md5sum | sed "s/\ *-/\ \ /"

    #Solaris way:
    #lindex [exec -- echo -n $string | md5sum] 0

    #OpenSSL way:
    #exec -- echo -n $string | openssl md5
}


proc printNode {node level outFile} {
    set child_nodes [get_cells -quiet -hierarchical -filter "!IS_PRIMITIVE && (PARENT == $node)"]
    foreach child $child_nodes {
	if { [string first "inst" $child] >= 0 } {
	    continue
	}
	if { [string first "U0" $child] >= 0} {
	    continue
	}
	if { [string first "auto_pc" $child] >= 0} {
	    continue
	}
	if { [string first "auto_cc" $child] >= 0} {
	    continue
	}
	if { [string first "pacd" $child] >= 0} {
	    continue
	}


	if {$node == {""}} {
	    puts  -nonewline $outFile "\""
	    puts  -nonewline $outFile [md5 "top"]
	    puts  $outFile "\" \[label=\"top\"\];"
	    puts  -nonewline $outFile "\""
	    puts  -nonewline $outFile [md5 "top"]
	    puts  -nonewline $outFile "\""
	} else {
	    puts  -nonewline $outFile "\""
	    puts -nonewline $outFile  [md5 $node]
	    puts  -nonewline $outFile "\""
	}
	set child_hash [md5 [get_property NAME $child]]
        puts  -nonewline $outFile  " -> \"" 
	puts  -nonewline $outFile $child_hash
        puts  -nonewline $outFile "\""
	puts $outFile ";"
        puts  -nonewline $outFile "\""
	puts  -nonewline $outFile $child_hash
	puts  -nonewline $outFile "\" \[label=\""
	puts  -nonewline $outFile  [string range [get_property NAME $child] [string last / [get_property NAME $child]]+1 10000]
	puts $outFile "\"\];"
	if {$level <= 4} {
	    printNode $child [expr {$level + 1}] $outFile
	}
    }
}

proc printGraph {} {
    set outFile [open "graph.gv" w+]
    puts $outFile "digraph Top {"
    printNode {""} 0 $outFile
    puts $outFile "}"
    close $outFile
}
