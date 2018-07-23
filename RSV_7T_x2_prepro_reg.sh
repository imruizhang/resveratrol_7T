#!/bin/bash
#for registeration of FA to T1 after cbstools scanner transform in RSV study
#run in FSL enviornment. FSL 5.0.9


while read DEM
do 

subject="$DEM"

echo ${subject}

trans_dir="/nobackup/aventurin4/RSV/RSV_transform_FA"
result_dir="/data/pt_nro148/7T/DTI"


echo "==============================="
echo "Register FA to T1 of FREESURFER"
echo "==============================="

echo " - copy scanner transformed images to study folder"

rm -f $result_dir/${subject}/${subject}_dti_FA_2trg_clone_transform.nii.gz
rm -f $result_dir/${subject}/${subject}_dti_MD_2trg_clone_transform.nii.gz

cp $trans_dir/${subject}* $result_dir/${subject}


echo " - register transformed FA to T1 brain"

rm -f $result_dir/${subject}/${subject}_dti_FA_transform_2t1.nii.gz
rm -f $result_dir/${subject}/${subject}_dti_FA_transform_2t1.mat

flirt -in $result_dir/${subject}/${subject}_dti_FA_2trg_clone_transform.nii.gz -ref $result_dir/${subject}/roi/$subject.rawavg.nii.gz -out $result_dir/${subject}/${subject}_dti_FA_transform_2t1.nii.gz -omat $result_dir/${subject}/${subject}_dti_FA_transform_2t1.mat -dof 6 -cost mutualinfo -interp spline -nosearch 

echo " - apply registeration matrix on transformed MD"

rm -f $result_dir/${subject}/${subject}_dti_MD_transform_2t1.nii.gz

flirt -in $result_dir/${subject}/${subject}_dti_MD_2trg_clone_transform.nii.gz -applyxfm -init $result_dir/${subject}/${subject}_dti_FA_transform_2t1.mat -ref $result_dir/${subject}/roi/$subject.rawavg.nii.gz -out $result_dir/${subject}/${subject}_dti_MD_transform_2t1.nii.gz



done < ${1}
