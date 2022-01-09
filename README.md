# Silent Android Application installation
Batch application installation with no final user intervention.
   
## **Prerequities**
- be root
- have a terminal application like [termius](https://play.google.com/store/apps/details?id=com.server.auditor.ssh.client)
- have knowledge in executing a shell script
- have free disk space to hold applications to install
- have knowledge in backuping applications (use for example [OAndBackupX](https://f-droid.org/fr/packages/com.machiav3lli.backup/), an open source project)
   
## **How to use ?**
1. extract zip
1. put your applications backup in the apps folder, following exactly one folder by application, without any subfloder, just to hold application apk(s)
1. run your terminal application, get root privileges, `cd` to the script folder
1. run script by typing `sh script.sh`
   
## **Example of use**
- extract zip to /storage/0000-0000/floconhome/saai
- copy applications apk(s) in /storage/0000-0000/floconhome/saai/apps:
```shell
/storage/0000-0000/floconhome/saai/apps/app1/base.apk
/storage/0000-0000/floconhome/saai/apps/app2/base.apk
/storage/0000-0000/floconhome/saai/apps/app2/split_xxxhdpi.apk
/storage/0000-0000/floconhome/saai/apps/app3/hello.apk
```
- run termius, then typing:
```shell
su
cd /storage/0000-0000/floconhome/saai/
sh script.sh
```

## **What does this message means ?**  
   
Once installation is completed for an application, a status message is displayed: if installation is successfull, a "SUCCESS" message will be displayed; else, message will contain a root cause:
- `Failure [INSTALL_FAILED_ALREADY_EXISTS: Attempt to re-install {package name} without first uninstalling.]`: the version application is already installed; example: app v1.0.8 is already installed and you try to install the same version of the application
- `Failure [INSTALL_FAILED_INVALID_APK: No packages staged]`: an error occured during installation
- `Failure [INSTALL_FAILED_VERSION_DOWNGRADE]`: the version application is older than one installed; it is not possible to do this, the script goal is to install application not already installed or at leat upgrade one already installed
