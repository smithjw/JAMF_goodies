#!/bin/bash

templateDir="/Library/Application Support/Google/Chrome/External Extensions"

# Create Chrome extensions folder and ensure it has the correct permissions
sudo mkdir -p /Library/Application\ Support/Google/Chrome/External\ Extensions
sudo chown -R root:admin /Library/Application\ Support/Google/
sudo chmod -R 555 /Library/Application\ Support/Google/


# Create extension template
echo '{
"external_update_url": 
"https://clients2.google.com/service/update2/crx"
}

' > "$templateDir"/template.json

# Zoom Scheduler Extension
cp "$templateDir"/template.json "$templateDir"/kgjfgplpablkjnlkjmjdecgdpfankdle.json
# Okta Extension
cp "$templateDir"/template.json "$templateDir"/glnpjglilkicbckjpbgcfkogebgllemb.json
# LastPass Extension
cp "$templateDir"/template.json "$templateDir"/hdokiejnpimakedhajhdlcegeplioahd.json
# Trello Extension
cp "$templateDir"/template.json "$templateDir"/dmdidbedhnbabookbkpkgomahnocimke.json

exit 0