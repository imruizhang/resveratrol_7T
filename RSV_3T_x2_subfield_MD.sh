#!/bin/bash
#for the Mean Diffusivity, FSL enviornment

while read DEM
do 

subject="$DEM"

result_dir="/data/pt_nro148/3T/DTI/${subject}/roi"
dir="/data/pt_nro148/groupmember_analysis/Rui/MD/3T"

echo $subject 

echo "Median MD of the subfields"

for i in posterior_left_CA1 posterior_left_CA2_3 posterior_left_CA4_DG posterior_left_fimbria posterior_left_hippocampal_fissure posterior_Left-Hippocampus posterior_left_presubiculum posterior_left_subiculum posterior_right_CA1 posterior_right_CA2_3 posterior_right_CA4_DG posterior_right_fimbria posterior_right_hippocampal_fissure posterior_Right-Hippocampus posterior_right_presubiculum posterior_right_subiculum
do
echo $i

#extract median MD of each subfield and threshold out values below 0 and above 0.002
a="`fslstats $result_dir/${subject}_dti_MD.2t1.nii.gz -k $result_dir/$subject.$i.nii.gz -l 0 -u 0.002 -p 50`"
echo $subject $a >> ${dir}/2017_RSV_3T_subfields_$i.txt



done 

done < ${1}
