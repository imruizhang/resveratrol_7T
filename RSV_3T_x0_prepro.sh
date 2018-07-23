#!/bin/bash
#for preprocessing DTI data in RSV study
#run in FSL enviornment. FSL 5.0.9
#about 4h per subject

while read DEM
do 

subject="$DEM"


echo ${subject}

raw_dir="/data/p_nro148/probands_mri_blood/${subject}/3T/nifti"
result_dir="/data/pt_nro148/3T/DTI_test/${subject}"

mkdir -p $result_dir


echo "====="
echo "Topup" #for EPI distortion correction
echo "====="

#echo " - extracting first volume from AP dataset"
#fslroi $raw_dir/cmrrmbep2ddiff.nii.gz $result_dir/${subject}_AP_B0 0 1
#skip this step because both AP_unwarp and PA_unwarp images were already acquired

rm -f $result_dir/${subject}_APPA_B0.nii.gz

echo " - merging AP and PA B0 images"

fslmerge -t $result_dir/${subject}_APPA_B0 $raw_dir/cmrrmbep2dseAPunwarpdiff.nii.gz $raw_dir/cmrrmbep2dsePAunwarpdiff.nii.gz

rm -f $result_dir/${subject}_acqparams_dwi.txt

echo " - creating file with acquisition parameters"

	printf "0 -1 0 0.04914\n0 1 0 0.04914" > $result_dir/${subject}_acqparams_dwi.txt
	#in acqparams_dwi_RSV.txt
	#--> Total readout time (FSL) = (number of echoes - 1) * echo spacing = (128-1)*0.78ms=99.06 ms
#--> Total readout time (FSL) = (number of echoes - 1) * echo spacing = (64-1)*0.78ms=49.14 ms #bcuz of GRAPPA
echo " - executing topup"

	rm -f $result_dir/${subject}_topup_* $result_dir/${subject}_unwarped_b0.nii.gz

	topup --imain=$result_dir/${subject}_APPA_B0 --datain=$result_dir/${subject}_acqparams_dwi.txt --config=b02b0.cnf --out=$result_dir/${subject}_topup --fout=$result_dir/${subject}_topup_field --iout=$result_dir/${subject}_unwarped_b0



echo "==============="
echo "Skull stripping"
echo "==============="

rm -f $result_dir/${subject}_b0_brain*

echo " -creating brain mask using bet"

fslmaths $result_dir/${subject}_unwarped_b0 -Tmean $result_dir/${subject}_unwarped_b0

bet $result_dir/${subject}_unwarped_b0 $result_dir/${subject}_b0_brain -R -m -f 0.2



echo "===="
echo "Eddy" #eddy current and motion correction from the output of topup
echo "===="

rm -f $result_dir/${subject}_index.txt

echo " -creating index file"
indx=""
for ((i=1; i<=67; i+=1)); do indx="$indx 1"; done
echo $indx > $result_dir/${subject}_index.txt

rm -f $result_dir/${subject}_eddy_corrected.nii.gz

echo " -running eddy"

eddy --imain=$raw_dir/cmrrmbep2ddiff.nii.gz --mask=$result_dir/${subject}_b0_brain_mask --acqp=$result_dir/${subject}_acqparams_dwi.txt --index=$result_dir/${subject}_index.txt --bvecs=$raw_dir/cmrrmbep2ddiff.bvec --bvals=$raw_dir/cmrrmbep2ddiff.bval --slm=linear --topup=$result_dir/${subject}_topup --out=$result_dir/${subject}_eddy_corrected
# --repol outlier replacement method is not supported with current version. RSV data looks fine



echo "========================"
echo "Compute diffusion tensor"
echo "========================"

rm -f ${subject}_dti_*

echo " - fitting the tensor"

dtifit -k $result_dir/${subject}_eddy_corrected -m $result_dir/${subject}_b0_brain_mask -r $result_dir/${subject}_eddy_corrected.eddy_rotated_bvecs -b $raw_dir/cmrrmbep2ddiff.bval -o $result_dir/${subject}_dti



done < ${1}
