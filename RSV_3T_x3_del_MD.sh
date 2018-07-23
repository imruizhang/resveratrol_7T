#!/bin/bash
#for the Mean Diffusivity, FSL enviornment


dir="/data/pt_nro148/groupmember_analysis/Rui/MD/3T"



echo "Mean MD of the subfields"

for i in posterior_left_CA1 posterior_left_CA2_3 posterior_left_CA4_DG posterior_left_fimbria posterior_left_hippocampal_fissure posterior_Left-Hippocampus posterior_left_presubiculum posterior_left_subiculum posterior_right_CA1 posterior_right_CA2_3 posterior_right_CA4_DG posterior_right_fimbria posterior_right_hippocampal_fissure posterior_Right-Hippocampus posterior_right_presubiculum posterior_right_subiculum
do
echo $i


#delete two lines becasue they do not have freesurfer subfields' segmentation
sed -i '/RSV110/d' ${dir}/2017_RSV_3T_subfields_$i.txt
sed -i '/RSV143/d' ${dir}/2017_RSV_3T_subfields_$i.txt
sed -i '/RSV150/d' ${dir}/2017_RSV_3T_subfields_$i.txt
sed -i '/RSV160/d' ${dir}/2017_RSV_3T_subfields_$i.txt
sed -i '/RSV161/d' ${dir}/2017_RSV_3T_subfields_$i.txt

done 


