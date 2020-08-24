#!/bin/bash

#------------------------------------------------------------------------
#Warning: This script was written for Ubuntu 16.04. Please test on other 
#systems first before using there.
#**********
#This script moves tif images that do not have a corresponding xml file
#so that they will not be picked up by the script.
#The images will be moved to $dest_dir. The structure with center will be 
#preserved in $dest_dir
#Execute this script in the dataset root dir
#------------------------------------------------------------------------

xml_files_suffix='*.xml'
xml_dir='lesion_annotations'
image_dirs='centre_0 centre_1 centre_2 centre_3 centre_4 centre_4_new'
dest_dir='IMAGES_NO_XML'

if [[ ! -d "$dest_dir" ]]; then
    mkdir "$dest_dir"
    for im_dir in $image_dirs; do
        mkdir "${dest_dir}/${im_dir}"
    done
fi

xmlpaths_rel=$( find $xml_dir -type f -iname "$xml_files_suffix" -exec echo {} ';' )

for image_dir in $image_dirs; do
    imagepaths_rel=$( find ${image_dir} -type f -iname "*.tif" -exec echo {} ';' )

    for imagepath_rel in $imagepaths_rel; do
        imagename_no_suffix=$( echo "$(basename $imagepath_rel)" | cut -f 1 -d '.' )

        image_do_not_move=0
        for xmlpath_rel in $xmlpaths_rel; do
            xmlname_no_suffix=$( echo "$(basename $xmlpath_rel)" | cut -f 1 -d '.' )
            #Corresponding xml file for image
            if [[ "$imagename_no_suffix" == "$xmlname_no_suffix" ]]; then
                image_do_not_move=1
                break
            fi
        done

        if [[ $image_do_not_move -eq 1 ]]; then
            echo "image ${imagepath_rel} will not be moved"
        else
            target_imagepath_rel="${dest_dir}/${imagepath_rel}"
            echo "image ${imagepath_rel} will be moved to ${target_imagepath_rel}"
            mv "$imagepath_rel" "$target_imagepath_rel"
        fi
    done
done
