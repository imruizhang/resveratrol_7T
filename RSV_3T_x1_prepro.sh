#!/bin/bash
#for preprocessing DTI data in RSV study
#start FSL enviornment first
#run in freesurfer enviornment, please use 'FREESURFER' instead of 'freesurfer'. Freesurfer 6.0.0
#about 2mins per subject

while read DEM
do 

subject="$DEM"

echo ${subject}


free_dir="/data/pt_nro148/3T/restingstate_and_freesurfer/preprocessing/freesurfer/$subject/mri"
result_dir="/data/pt_nro148/3T/DTI/${subject}"

mkdir -p $result_dir/roi

rm -f $result_dir/roi/$subject*

echo "================================="
echo "Freesurfer outputs of hippocampus"
echo "================================="

cd $free_dir

echo " - copy and convert mgz of freesurfer to nifti"

for i in brain posterior_left_CA1 posterior_left_CA2_3 posterior_left_CA4_DG posterior_left_fimbria posterior_left_hippocampal_fissure posterior_Left-Hippocampus posterior_left_presubiculum posterior_left_subiculum posterior_right_CA1 posterior_right_CA2_3 posterior_right_CA4_DG posterior_right_fimbria posterior_right_hippocampal_fissure posterior_Right-Hippocampus posterior_right_presubiculum posterior_right_subiculum 
do
echo $i

mri_vol2vol --mov $i.mgz --targ rawavg.mgz --regheader --o $result_dir/roi/rawavg.$i.mgz --no-save-reg

mri_convert -it mgz -i $result_dir/roi/rawavg.$i.mgz -ot nii -o $result_dir/roi/$subject.$i.nii.gz

echo " - cleaning up"

rm $result_dir/roi/rawavg.$i.mgz

echo " - reorienting into standard space"

${FSLDIR}/bin/fslreorient2std $result_dir/roi/$subject.$i.nii.gz $result_dir/roi/$subject.$i.nii.gz
# note that the default FSLDIR is /afs/cbs.mpg.de/software/fsl/5.0.9/ubuntu-xenial-amd64/share (30.01.2017)

done

echo " - creating subfields' mask"

for j in posterior_left_CA1 posterior_left_CA2_3 posterior_left_CA4_DG posterior_left_fimbria posterior_left_hippocampal_fissure posterior_Left-Hippocampus posterior_left_presubiculum posterior_left_subiculum posterior_right_CA1 posterior_right_CA2_3 posterior_right_CA4_DG posterior_right_fimbria posterior_right_hippocampal_fissure posterior_Right-Hippocampus posterior_right_presubiculum posterior_right_subiculum 
do
echo $j

${FSLDIR}/bin/fslmaths $result_dir/roi/$subject.$j.nii.gz -thr 150 -bin $result_dir/roi/$subject.$j.nii.gz

done


echo "=========================="
echo "Registration of DWI on T1W"
echo "=========================="

echo " - register b0 on T1"

${FSLDIR}/bin/flirt -in $result_dir/${subject}_b0_brain -ref $result_dir/roi/$subject.brain.nii.gz -out $result_dir/roi/${subject}_b0_reg -omat $result_dir/roi/${subject}_dwi2t1.mat -dof 6 -nosearch


echo " - apply transformation to tensor images"

for i in FA L1 L2 L3 MD MO S0 V1 V2 V3 
do

echo ${subject}_dti_$i

${FSLDIR}/bin/flirt -in $result_dir/${subject}_dti_$i.nii.gz -applyxfm -init $result_dir/roi/${subject}_dwi2t1.mat -ref $result_dir/roi/$subject.brain.nii.gz -out $result_dir/roi/${subject}_dti_$i.2t1


done 


done < ${1}
