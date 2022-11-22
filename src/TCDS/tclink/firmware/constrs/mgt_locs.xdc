# Reset the LOC constraints applied by the IP XDC file, so that the board level pin/location constraints can be applied.
# NOTE: It is easier to use 'set_property LOC {}' here than to use 'reset_property LOC'.
set_property LOC {} [get_cells -hierarchical -regexp -filter {REF_NAME =~ {.*GT(H|Y)E(3|4)_CHANNEL.*} && NAME =~ {.*timing.*}}]