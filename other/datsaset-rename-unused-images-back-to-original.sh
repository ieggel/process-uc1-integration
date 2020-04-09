#!/bin/bash

#------------------------------------------------------------------------
#Warning: This script was written for Ubuntu 16.04. Please test on other 
#systems first before using there.
#**********
#This script renames image.'$suffix_image_no_corr_xml' images back to image.tif
#Execute this script in the dataset root dir
#------------------------------------------------------------------------

d
image_dirs='centre_0 centre_1 centre_2 centre_3 centre_4 centre_4_new'

suffix_image_no_corr_xml='.HAS_NO_XML'


for image_dir in $image_dirs; do
    imagepaths_rel=$( find ${image_dir} -type f -iname "*$suffix_image_no_corr_xml" -exec echo {} ';' )
    for imagepath_rel in $imagepaths_rel; do
        target_path="$(echo $imagepath_rel | cut -f 1 -d '.').tif"
        echo "perform rename from ${imagepath_rel} to ${target_path}"
        mv "$imagepath_rel" "$target_path"
    done
done