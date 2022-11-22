# When creating design for 5G/10G, the tool tries to read XDC from the
# non-instantiated transceiver. This is not a real problem, so let's
# turn it into an INFO message instead.
set_msg_config -id {[Designutils 20-1280]} -new_severity "INFO" -regexp -string {".*timing.* The XDC file .*"}

# Turn the messages due to the multiple applications of the same
# constraint in the IP XDC file from critical warnings into plain info
# messages.
set_msg_config -new_severity "INFO" -regexp -string {".*Cannot set LOC property of instance .*timing.*"}

# The relocation of the MGT locations in mgt_locs.xdc leads to a critical warning complaint from
# Vivado. Let's turn that into a plain INFO message as well.
set_msg_config -new_severity "INFO" -regexp -string {".*You are overriding a physical property set by a constraint that originated in a read only source. .*timing.*"}
