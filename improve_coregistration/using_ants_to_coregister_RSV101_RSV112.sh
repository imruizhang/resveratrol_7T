#!/bin/bash

for subj in RSV158 RSV159 RSV162 RSV163 #RSV113 RSV115 RSV116 RSV117 RSV118 RSV119 RSV120 RSV121 RSV124 RSV126 RSV129 RSV130 RSV132 RSV133 RSV135 RSV136 RSV138 RSV139 RSV140 RSV142 RSV143 RSV144 RSV145 RSV146 RSV147 RSV148 RSV149 RSV150 RSV152 RSV153 RSV155 RSV156 RSV157 RSV158 RSV159 RSV162 RSV163 #RSV055  
do
#coregistering CSF maps from DWI to CSF map from t1

cd /nobackup/schiller2/RSV_7T_preprocessing/improve_t1_dwi_coregistration
mkdir $subj #/nobackup/schiller2/RSV_7T_preprocessing/Freesurfer/RSV002/mri/orig/001.mgz
cd ${subj}


cp /data/pt_nro148/7T/DTI/${subj}/roi/${subj}.rawavg.nii.gz orig.nii.gz
if [ ! -f orig_pve_0.nii.gz ];
then
echo "running FAST"
fast orig.nii.gz
else
echo "already done FAST"
fi

#crop_vals="0 -1 30 270 90 185" #for RSV055
crop_vals="`fslstats /data/pt_nro148/7T/DTI/${subj}/${subj}_dti_MD_2trg_clone_transform.nii.gz -w`"
echo "creating MD csf mask by thresholding MD @ 0.001 and cropping it to minimum size"
#t1 from fast orig.nii.gz (=skull-stripped T1-weighted FS-input)
fslmaths /data/pt_nro148/7T/DTI/${subj}/${subj}_dti_MD_2trg_clone_transform.nii.gz -thr 0.001 /nobackup/schiller2/RSV_7T_preprocessing/improve_t1_dwi_coregistration/$subj/${subj}_dti_MD_2trg_clone_transform_CSF_mask_0.001.nii.gz
fslroi /nobackup/schiller2/RSV_7T_preprocessing/improve_t1_dwi_coregistration/$subj/${subj}_dti_MD_2trg_clone_transform_CSF_mask_0.001.nii.gz /nobackup/schiller2/RSV_7T_preprocessing/improve_t1_dwi_coregistration/$subj/${subj}_dti_MD_2trg_clone_transform_CSF_mask_0.001_cropped.nii.gz ${crop_vals}
echo "making a slab from T1-data and cropping it to the same size"
fslmaths /data/pt_nro148/7T/DTI/${subj}/${subj}_dti_MD_2trg_clone_transform.nii.gz -thr 0 ${subj}_dti_MD_2trg_clone_transform_mask.nii.gz
fslmaths orig_pve_0.nii.gz -mas ${subj}_dti_MD_2trg_clone_transform_mask.nii.gz orig_pve_0_slabbed.nii.gz
fslroi orig_pve_0_slabbed.nii.gz orig_pve_0_slabbed_cropped.nii.gz ${crop_vals}

if [ ! -f transform1Warp.nii.gz ];
then
echo "running ANTSREG"
#using ANTS (better quality than FNIRT)
antsRegistration --collapse-output-transforms 1 --dimensionality 3 --initial-moving-transform [ orig_pve_0_slabbed_cropped.nii.gz, ${subj}_dti_MD_2trg_clone_transform_CSF_mask_0.001_cropped.nii.gz, 1 ] --initialize-transforms-per-stage 0 --interpolation Linear --output [ transform, transform_Warped.nii.gz, transform_InverseWarped.nii.gz ] --transform Rigid[ 0.1 ] --metric MI[ orig_pve_0_slabbed_cropped.nii.gz, ${subj}_dti_MD_2trg_clone_transform_CSF_mask_0.001_cropped.nii.gz, 1, 32, Regular, 0.25 ] --convergence [ 1000x500x250x100, 1e-06, 10 ] --smoothing-sigmas 3.0x2.0x1.0x0.0vox --shrink-factors 8x4x2x1 --use-histogram-matching 1 --transform Affine[ 0.1 ] --metric MI[ orig_pve_0_slabbed_cropped.nii.gz, ${subj}_dti_MD_2trg_clone_transform_CSF_mask_0.001_cropped.nii.gz, 1, 32, Regular, 0.25 ] --convergence [ 1000x500x250x100, 1e-06, 10 ] --smoothing-sigmas 3.0x2.0x1.0x0.0vox --shrink-factors 8x4x2x1 --use-histogram-matching 1 --transform SyN[ 0.1, 3.0, 0.0 ] --metric CC[ orig_pve_0_slabbed_cropped.nii.gz, ${subj}_dti_MD_2trg_clone_transform_CSF_mask_0.001_cropped.nii.gz, 1, 4, None, 1 ] --convergence [ 100x70x50x20, 1e-06, 10 ] --smoothing-sigmas 3.0x2.0x1.0x0.0vox --shrink-factors 8x4x2x1 --use-histogram-matching 1 --winsorize-image-intensities [ 0.005, 0.995 ]  --write-composite-transform 0
else
echo "already done ANTSREG"

fi


fslroi /data/pt_nro148/7T/DTI/${subj}/${subj}_dti_MD_2trg_clone_transform.nii.gz ${subj}_dti_MD_2trg_clone_transform_cropped.nii.gz ${crop_vals}

antsApplyTransforms --default-value 0 --dimensionality 3 --input ${subj}_dti_MD_2trg_clone_transform_cropped.nii.gz  --input-image-type 3 --interpolation Linear --output ${subj}_MD_antswarped.nii.gz --reference-image orig_pve_0_slabbed_cropped.nii.gz --transform transform0GenericAffine.mat --transform transform1Warp.nii.gz

#echo "flirt MD CSF to original CSF"
#flirt -ref orig_pve_0_cropped.nii.gz -in ${subj}_dti_MD_2trg_clone_transform_CSF_mask_0.001_cropped.nii.gz -omat flirt_csf_dti_to_t1.nii.mat -o flirt_csf_dti_to_t1.nii.gz -v

#echo "fnirt MD CSF to original CSF"
#fnirt --ref=orig_pve_0_cropped.nii.gz --in=${subj}_dti_MD_2trg_clone_transform_CSF_mask_0.001_cropped.nii.gz --aff=flirt_csf_dti_to_t1.nii.mat -v

#echo "applywarp to CSF"
#applywarp --ref=orig_pve_0_cropped.nii.gz --in=${subj}_dti_MD_2trg_clone_transform_CSF_mask_0.001_cropped.nii.gz --out=dti2t1.nii -w ${subj}_dti_MD_2trg_clone_transform_CSF_mask_0_warpcoef.nii.gz --premat=flirt_csf_dti_to_t1.nii.mat
#applywarp to MD
#applywarp --ref=orig_pve_0_slabbed_cropped.nii.gz --in=${subj}_dti_MD_2trg_clone_transform_cropped.nii.gz --out=md2t1.nii -w ${subj}_dti_MD_2trg_clone_transform_CSF_mask_0_warpcoef.nii.gz --premat=flirt_csf_dti_to_t1.nii.mat


#crop MD image not binarized
echo "cropping orig MD image and hippocampal subfields"
fslroi /data/pt_nro148/7T/DTI/${subj}/roi/${subj}.lh.hippoSfLabels-T1.v10.nii.gz ${subj}.lh.hippoSfLabels-T1.v10_cropped.nii.gz ${crop_vals}
fslroi /data/pt_nro148/7T/DTI/${subj}/roi/${subj}.rh.hippoSfLabels-T1.v10.nii.gz ${subj}.rh.hippoSfLabels-T1.v10_cropped.nii.gz ${crop_vals}

#cropping other images for comparison
fslroi /data/pt_nro148/7T/DTI/${subj}/${subj}_dti_MD_transform_2t1.nii.gz ${subj}_dti_MD_transform_2t1_cropped.nii.gz ${crop_vals}
fslroi orig.nii.gz orig_cropped.nii.gz ${crop_vals}
a="`fslstats ${subj}_MD_antswarped.nii.gz -k ${subj}.lh.hippoSfLabels-T1.v10_cropped.nii.gz -m -p 50 -s`"
echo $subj $a lh >> /data/pt_nro148/groupmember_analysis/Frauke/MD_analysis/ants_MD2t1_registration.txt
a="`fslstats ${subj}_MD_antswarped.nii.gz -k ${subj}.rh.hippoSfLabels-T1.v10_cropped.nii.gz -m -p 50 -s`"
echo $subj $a rh >> /data/pt_nro148/groupmember_analysis/Frauke/MD_analysis/ants_MD2t1_registration.txt

a="`fslstats /data/pt_nro148/7T/DTI/${subj}/${subj}_dti_MD_transform_2t1.nii.gz -k /data/pt_nro148/7T/DTI/${subj}/roi/${subj}.lh.hippoSfLabels-T1.v10.nii.gz -m -p 50 -s`"
echo $subj $a lh >> /data/pt_nro148/groupmember_analysis/Frauke/MD_analysis/old_MD2t1_registration.txt
a="`fslstats /data/pt_nro148/7T/DTI/${subj}/${subj}_dti_MD_transform_2t1.nii.gz -k /data/pt_nro148/7T/DTI/${subj}/roi/${subj}.rh.hippoSfLabels-T1.v10.nii.gz -m -p 50 -s`" 
echo $subj $a rh >> /data/pt_nro148/groupmember_analysis/Frauke/MD_analysis/old_MD2t1_registration.txt


done
#



#apply transform to MD image

#
