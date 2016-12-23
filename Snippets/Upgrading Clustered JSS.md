- Login to AWS Console and take a snapshot of all 4 instances (only for major versions)
- Mount each instance in Coda and upload latest `jssinstaller.run` to home dir
- SSH into each instance
- Shutdown TOMCAT using `sudo /etc/init.d/jamf.tomcat8 stop`
- Run installer on Admin 1 `sudo sh jssinstaller.run`
- Once completed, verify that Admin 1 is reachable "https://10.40.10.25:8443"
- Run installer on other three instances
- 🙌🏽

