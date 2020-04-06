# process-uc1-integration

## docker (folder)

Contains everything needed to build the docker image.

_NOTE:_ process-uc1-execution-script-davfs.sh is outdated. We now do mount via wwebdav anymore bit via sshfs.

## process-uc1-execution-script-sshfs.sh

Script that prepares the VM, launches the docker container for the usecase and cleans up resources after termination.

VM preparation:
- Install sshfs
- Config sshfs
- Creates target mount dir /mnt/snedtn
- Mounts target mount dir with lobcder

Launch docker container:
- Mounts /mnt/snedtn/camelyon17 from host to /process-uc1/data/camelyon17 in container
- Run bin/cnn --config-file etc/config.ini extract
- Results saved to snedtn : snetdn/uc1-results

Resource cleanup:
- Unmounts target mount dir (just to be sure, might flush cache)


## install_mount-fstab-lobcder.sh (not used)

Script that installs davfs2 or, creates mount target dir, creates webdav secrets file for lobcder credentials, creates fstab entry and mounts target dir.

This script is not used in the cloud (or VM), but is rather meant to run locally to mount lobcder.

## process-uc1-execution-script-davfs.sh (not used)

Script that prepares the VM, launches the docker container for the usecase and cleans up resources after termination.

VM preparation:
- Install davfs2
- Creates entry for lobcder credentaisl in /etc/davfs2/secrets
- Creates target mount dir /mnt/lobcder
- Mounts target mount dir with lobcder

Launch docker container:
- Mounts /mnt/lobcder/snedtn/camelyon17 from host to /process-uc1/data/camelyon17 in container
- Run bin/cnn --config-file etc/config.ini extract
- Results saved to lobcder : snetdn/uc1-results

Resource cleanup:
- Unmounts target mount dir (in order to to force cash to be flushed and written to remote resource)
