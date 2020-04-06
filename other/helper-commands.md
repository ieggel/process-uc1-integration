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
