## Copy camelyon dataset files to snedtn

### Copy camelyon17 files from nas4 to snedtn via sshfs. Filenaes provided via stdnin (one filename per line).

```bash
#cd to a dir with images
$ cd /mnt/nas4/datasets/ToReadme/CAMELYON17/centre_0
#copy images provided via stdnin to snetdn. Use Ctrl+D to mark end of input.
$ awk '{print $1}' | xargs -n 1 -I '{}' cp -v '{}' /mnt/snedtn/camelyon17/centre_0
```


E.g. provide the following imagenames via stdin. One line per imagename: 
* patient_005_node_1.tif
* patient_006_node_0.tif
* patient_012_node_0.tif
* patient_018_node_2.tif
* patient_019_node_2.tif
* patient_017_node_4.tif

Then do:
```bash
$ Enter
$ Ctrl+D
```

### After files have been copied compare md5 checksum

Pass the filenames to compare to stdin. One filename per line.

```bash
awk '{print $1}' | xargs -n 1 -I '{}' bash -c $'md5sum=$(md5sum {} | awk \'{ print $1 }\'); md5sum_other=$(md5sum /mnt/snedtn/camelyon17/centre_0/{} | awk \'{ print $1 }\'); if [ $md5sum != $md5sum_other ]; then echo "md5 does not match: {}"; else echo "{} match: $md5sum"; fi'

$ Enter
$ Ctrl+D
```

## Run script on VM (147.213.76.127)

### Copy private key for snedtn sshfs from local to VM

Make sure to also provide the correct private key for the VM.

```bash
$ scp -i ~/.ssh/id_rsa_linux ~/.ssh/id_rsa_process_uc1 ubuntu@147.213.76.127:/home/ubuntu/.ssh/
```
### Connect to VM

Make sure to provide the correct private key.

```bash
$ ssh -i ~/.ssh/id_rsa_linux ubuntu@147.213.76.127
```

### Clone this project from git

```bash
$ cd ~/
$ git clone https://github.com/ieggel/process-uc1-integration.git
```

### Test Run execution script on VM

Consider using byobu in order to continue running the process even when quitting ssh session.

```bash
$ byobu
````

Then execute:

```bash
$ cd /home/ubuntu/process-uc1-integration
$ ./process-uc1-execution-script-sshfs.sh
```
