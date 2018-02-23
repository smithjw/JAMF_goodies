#!/bin/bash

###
#
#            Name:  configureFirefox.sh
#     Description:  This script configures Firefox to block Flash
#            Note:
#		   Author:  James Smith <james@smithjw.me>
#         Created:  
#   Last Modified:  2018-02-23
#         Version:  1.0
#
###

# Write autoconfig.js into Firefox
echo '// Auto Config file for Firefox
pref("general.config.filename", "mozilla.cfg");
pref("general.config.obscure_value", 0);
' > /Applications/Firefox.app/Contents/Resources/defaults/pref/autoconfig.js

# Write mozilla.cfg into Firefox
echo '// Restrict Flash from running within Firefox
lockPref("plugin.state.flash", 0);
' > /Applications/Firefox.app/Contents/Resources/mozilla.cfg

exit 0
