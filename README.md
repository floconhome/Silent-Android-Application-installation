Silent Android Application installation

**What is it for ?**
Batch application installation with no final user intervention.

**Prerequities**
be root
have a terminal application like termius (https://play.google.com/store/apps/details?id=com.server.auditor.ssh.client)
have knowledge in executing a shell script
have free disk space to hold applications to install
have knowledge in backuping applications (use for example OAndBackupX, an open source project: https://f-droid.org/fr/packages/com.machiav3lli.backup/)

**How to use ?**
extract zip
put your applications backup in the apps folder, following exactly one folder by application, without any subfloder, just to hold application apk(s)
run your terminal application, get root privileges, `cd` to the script folder
run script by typing `sh script.sh`

**Example of use**
extract zip to /storage/0000-0000/floconhome/saai
copy my applications apk(s) in /storage/0000-0000/floconhome/saai/apps:
/storage/0000-0000/floconhome/saai/apps/app1/base.apk
/storage/0000-0000/floconhome/saai/apps/app2/base.apk
/storage/0000-0000/floconhome/saai/apps/app2/split_xxxhdpi.apk
/storage/0000-0000/floconhome/saai/apps/app3/hello.apk
run termius, then typing:
```shell
su
cd /storage/0000-0000/floconhome/saai/
sh script.sh
```

**What does this message means ?**
Once installation is completed for an aplication, a status message is displayed. If the installation is successful, the script will just display "OK" message. If the installation could not be carried out, the message contains the root cause
Failure []: 



-----

*italic*
# h1
## h2
### h3
#### h4

- puce 1
- puce 2

1. n1
1. n2
1. n3

------------

[link](http:///www.google.fr "link")

[![titre](https://www.pngall.com/wp-content/uploads/2016/04/Free.png "titre")](https://www.pngall.com/wp-content/uploads/2016/04/Free.png "titre")

`dfhfhdf 
dfhdfhdf
dfhfd code inline`

```shell
cd /data/local/tmp
ls -al
echo coucou
i="456"
```

