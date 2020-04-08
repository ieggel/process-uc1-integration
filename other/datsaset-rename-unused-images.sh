#!/bin/bash

#------------------------------------------------------------------------
#Warning: This script was written for Ubuntu 16.04. Please test on other 
#systems first before using there.
#**********
#This script renames tif images that do not have a corresponding xml file
#so that they will not be picked up by the script.
#Execute this script in the dataset root dir
#------------------------------------------------------------------------

xml_files_suffix='*.xml'
xml_dir='lesion_annotations'
image_dirs='centre_0 centre_1 centre_2 centre_3 centre_4 centre_4_new'

new_suffix_image_no_corr_xml='.HAS_NO_XML'

xml_filenames=$( find $xml_dir -type f -iname "$xml_files_suffix" -execdir echo {} ';' )

for image_dir in $image_dirs; do
    imagenames=$( find ${image_dir} -type f -iname "*.tif" -execdir echo {} ';' )

    for imagename in $imagenames; do
        imagename_no_suffix=$( echo $imagename | cut -f 2 -d '.' )
        image_has_xml=0
        for xml_filename in $xml_filenames; do
            xml_filename_no_suffix=$( echo $xml_filename | cut -f 2 -d '.' )

	        if [[ $xml_filename_no_suffix == $imagename_no_suffix ]];then
                image_has_xml=1
                break
            fi
        done
        
        if [[ $image_has_xml -eq 0 ]];then
            old_image_rel_path=${image_dir}/${imagename}
            new_image_rel_path=${old_image_rel_path}${new_suffix_image_no_corr_xml}
            echo "rename ${old_image_rel_path} to ${new_image_rel_path}"
            mv "$old_image_rel_path" "$new_image_rel_path"
        else
            echo "image ${imagename} has corresponding xml: will not be renamed"
        fi
    done
done
