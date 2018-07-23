#!/bin/bash
#for preprocessing DTI data in RSV study
#run in FSL enviornment. FSL 5.0.9
#about 4h per subject

while read DEM
do 

subject="$DEM"


echo ${subject}

raw_dir="/data/p_nro148/probands_mri_blood/${subject}/7T/nifti"
result_dir="/data/pt_nro148/7T/DTI/${subject}"
mask_dir="/nobackup/schiller2/RSV_7T_preprocessing/Copy_Data"

echo "=============================="
echo "get DWI and related file names"
echo "=============================="


	dti_name=/data/p_nro148/probands_mri_blood/RSV101/7T/nifti/S14_DWI_whole_brain_tra.nii
	echo $dti_name
	dti_arr=($dti_name)

	bvec_name=/data/p_nro148/probands_mri_blood/RSV101/7T/nifti/S14_DWI_whole_brain_tra.bvec
	echo $bvec_name
	bvec_arr=($bvec_name)

	bval_name=/data/p_nro148/probands_mri_blood/RSV101/7T/nifti/S14_DWI_whole_brain_tra.bval
	echo $bval_name
	bval_arr=($bval_name)

mkdir -p $result_dir


echo "====="
echo "Topup" #for EPI distortion correction
echo "====="

rm -f $result_dir/${subject}_APPA_B0
rm -f $result_dir/${subject}_AP_B0
rm -f $result_dir/${subject}_PA_B0

echo " - extracting first volume from AP dataset"
fslroi ${dti_arr[0]} $result_dir/${subject}_AP_B0 0 1
fslroi $raw_dir/*DWI_whole_brain_tra_P-A.nii $result_dir/${subject}_PA_B0 0 1

echo " - merging AP and PA B0 images"

fslmerge -t $result_dir/${subject}_APPA_B0 $result_dir/${subject}_AP_B0 $result_dir/${subject}_PA_B0

rm -f $result_dir/${subject}_acqparams_dwi.txt

echo " - creating file with acquisition parameters"

	printf "0 -1 0 0.12402\n0 1 0 0.12402" > $result_dir/${subject}_acqparams_dwi.txt
	#in acqparams_dwi_RSV.txt
	#--> Total readout time (FSL) = (number of echoes (EPI factor) - 1) * echo spacing = (160-1)*0.78ms=124.02 ms

echo " - executing topup"

	rm -f $result_dir/${subject}_topup_* $result_dir/${subject}_unwarped_b0.nii.gz

	topup --imain=$result_dir/${subject}_APPA_B0 --datain=$result_dir/${subject}_acqparams_dwi.txt --config=b02b0.cnf --out=$result_dir/${subject}_topup --fout=$result_dir/${subject}_topup_field --iout=$result_dir/${subject}_unwarped_b0



echo "==============="
echo "Skull stripping"
echo "==============="

rm -f $result_dir/${subject}_b0_brain*
rm -f $result_dir/${subject}_unwarped_b0_mean.nii.gz

echo " -creating brain mask using bet"

fslmaths $result_dir/${subject}_unwarped_b0 -Tmean $result_dir/${subject}_unwarped_b0_mean

fslstats $result_dir/${subject}_unwarped_b0_mean -C > $result_dir/${subject}_unwarped_b0.txt

X=`awk '{print $1}' $result_dir/${subject}_unwarped_b0.txt`
Y=`awk '{print $2}' $result_dir/${subject}_unwarped_b0.txt`
Z=`awk '{print $3}' $result_dir/${subject}_unwarped_b0.txt`

bet $result_dir/${subject}_unwarped_b0_mean $result_dir/${subject}_b0_brain -m -c $X $Y $Z -f 0.1



echo "===="
echo "Eddy" #eddy current and motion correction from the output of topup
echo "===="

rm -f $result_dir/${subject}_index.txt

echo " -creating index file"
indx=""
for ((i=1; i<=68; i+=1)); do indx="$indx 1"; done
echo $indx > $result_dir/${subject}_index.txt

rm -f $result_dir/${subject}_eddy_corrected.nii.gz


echo " -running eddy"

eddy --imain=${dti_arr[0]} --mask=$result_dir/${subject}_b0_brain_mask --acqp=$result_dir/${subject}_acqparams_dwi.txt --index=$result_dir/${subject}_index.txt --bvecs=${bvec_arr[0]} --bvals=${bval_arr[0]} --slm=linear --topup=$result_dir/${subject}_topup --out=$result_dir/${subject}_eddy_corrected
# --repol outlier replacement method is not supported with current version. RSV data looks fine



echo "========================"
echo "Compute diffusion tensor"
echo "========================"

rm -f ${subject}_dti_*

echo " - fitting the tensor"

dtifit -k $result_dir/${subject}_eddy_corrected -m $result_dir/${subject}_b0_brain_mask -r $result_dir/${subject}_eddy_corrected.eddy_rotated_bvecs -b ${bval_arr[0]} -o $result_dir/${subject}_dti


done < ${1}
