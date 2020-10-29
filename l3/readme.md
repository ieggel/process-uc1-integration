## Dev/Testing
For dev/testing purposes, data resides on our internal NAS drive(s). The script process-uc1-l3-exec-nas.sh has to be launched.

## Production
----------
For prodution, the data should be available in snetdn via SSHFS. The script process-uc1-l3-exec-ssh.sh has to be launched.

1. Check if data on snetdn is up to date (Ask Mara if anything changed). If anything changed:
- /mnt/nas2/results/IntermediateResults/Camelyon$ `cp -r all500 /home/ivan/snedtn/L3/data/IntermediateResults/Camelyon/`
- /mnt/nas2/results/IntermediateResults/Mara$ `cp -r camnet_models /home/ivan/snedtn/L3/data/IntermediateResults/Mara/`
- /mnt/nas2/results/IntermediateResults/Mara$ `cp -r imagenet_models /home/ivan/snedtn/L3/data/IntermediateResults/Mara/`

2. Copy SSH key id_rsa_procecc_uc1 to production server ==> makes it possible to connect to snetdn via SSHFS

3. Make sure the executing user on production server VM has sudo rights and no password 