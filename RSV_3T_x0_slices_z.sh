#!/bin/bash

#set FSL environment!
#for visually checking the brain mask on DTI images

while read DEM
do 


subject="${DEM}"

result_dir="/data/pt_nro148/3T/DTI/"


mkdir -p $result_dir/QC_mask

echo "-----------------------------------"
echo "Creating slices check of ${subject}"
echo "-----------------------------------"

cd $result_dir/$subject

echo $subject


for k in 20 25 30 35 40 45 50 55 60 65 70
do
echo $k

slicer -L -e 0.0001 ${subject}_eddy_corrected.nii.gz ${subject}_b0_brain_mask.nii.gz -z -$k $result_dir/QC_mask/ecc$k.png


done

cd $result_dir/QC_mask

${FSLDIR}/bin/pngappend ecc20.png + ecc25.png + ecc30.png + ecc35.png + ecc40.png + ecc45.png + ecc50.png + ecc55.png + ecc60.png + ecc65.png + ecc70.png $subject.all.png
    /bin/rm -f ecc?.png
echo '<a href="'$subject'.all.png"><img src="'$subject'.all.png" >' $subject.all.png'</a><br>' >> index.html

done < ${1}

