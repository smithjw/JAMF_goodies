#!/bin/bash

# AWS Information
s3Bucket="$4"
s3Region="$5"
s3AccessKey="$6"
s3SecretKey="$7"
logFiles="$8"

# File Information
date=$(date +%Y%m%d)
loggedInUser=`/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }'`
fileName="${loggedInUser}-${date}-logs.zip"
relativePath="/${s3Bucket}/${fileName}"
contentType="application/zip"

# Other Variables
dateFormatted=$(date +"%a, %d %b %Y %T %z")
stringToSign="PUT\n\n$contentType\n$dateFormatted\n$relativePath"
signature=$(printf "${stringToSign}" | openssl sha1 -hmac "${s3SecretKey}" -binary | base64)

zip -FS ${fileName} ${logFiles}

curl -X PUT -T "${fileName}" \
	-H "Host: ${s3Bucket}.s3-${s3Region}.amazonaws.com" \
	-H "Date: ${dateFormatted}" \
	-H "Content-Type: ${contentType}" \
	-H "Authorization: AWS ${s3AccessKey}:${signature}" \
	http://${s3Bucket}.s3-${s3Region}.amazonaws.com/${fileName}

exit 0
