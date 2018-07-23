#!/bin/bash
#for preprocessing DTI data in RSV study
#run in freesurfer enviornment, please use 'FREESURFER' instead of 'freesurfer'. Freesurfer 6.0.0
#about 2mins per subj

for subj in 32 #02 03 04 05 06 07 08 09 11 12 13 14 15 16 17 18 19 20 21 24 26 29 30 32 33 35 36 37 38 39 40 42 43 44 45 46 47 48 49 50 52 53 55 56 57 58 59 62 63
do 
for long in 0 1
do

	echo $subj $long

result_dir="/data/pt_nro148/7T/DTI/RSV${long}${subj}"

free_dir="/nobackup/schiller2/RSV_7T_preprocessing/Freesurfer/RSV${long}$subj/mri"
long_dir="/nobackup/schiller2/RSV_7T_preprocessing/Freesurfer/RSV${long}$subj.long.RSVX${subj}_template/mri"

mkdir -p $result_dir/roi_tse

rm -f $result_dir/roi_tse/$subj*


echo "================================="
echo "Freesurfer outputs of hippocampus"
echo "================================="

cd $long_dir

for j in lh.hippoSfLabels-T1-T2_woresampling.v10 rh.hippoSfLabels-T1-T2_woresampling.v10
do
echo "  -- "$j

mri_convert -ait transforms/RSV${long}${subj}_to_RSV${long}${subj}.long.RSVX${subj}_template.lta \
            -rl $free_dir/rawavg.mgz \
            -rt nearest -odt uchar --no_scale 1 \
            $long_dir/$j.mgz $result_dir/roi_tse/RSV${long}${subj}.$j-in-rawavg.mgz

#mri_label2vol --seg $free_dir/$j.mgz --temp $free_dir/rawavg.mgz --o $result_dir/roi_tse/rawavg.$j.mgz --regheader $free_dir/$j.mgz

#mri_vol2vol --mov $free_dir/$j.mgz --targ $free_dir/rawavg.mgz --regheader --o $result_dir/roi_tse/rawavg.$j.mgz --no-save-reg

mri_convert -it mgz -i $result_dir/roi_tse/RSV${long}${subj}.$j-in-rawavg.mgz -ot nii -o $result_dir/roi_tse/RSV${long}$subj.$j.nii.gz

echo "  -- cleaning up"

rm $result_dir/roi_tse/$j-in-rawavg.mgz


echo " --------------------------"
echo " - creating subfields' mask"
echo " --------------------------"


#for polling out the roi_tse of hippocampus using labels
echo "    -parasubiculum"
${FSLDIR}/bin/fslmaths $result_dir/roi_tse/RSV${long}${subj}.$j.nii.gz -uthr 203 -thr 203 -bin $result_dir/roi_tse/RSV${long}${subj}.$j.parasubiculum.nii.gz

echo "    -presubiculum"
${FSLDIR}/bin/fslmaths $result_dir/roi_tse/RSV${long}${subj}.$j.nii.gz -uthr 204 -thr 204 -bin $result_dir/roi_tse/RSV${long}${subj}.$j.presubiculum.nii.gz

echo "    -subiculum"
${FSLDIR}/bin/fslmaths $result_dir/roi_tse/RSV${long}${subj}.$j.nii.gz -uthr 205 -thr 205 -bin $result_dir/roi_tse/RSV${long}${subj}.$j.subiculum.nii.gz

echo "    -CA1"
${FSLDIR}/bin/fslmaths $result_dir/roi_tse/RSV${long}${subj}.$j.nii.gz -uthr 206 -thr 206 -bin $result_dir/roi_tse/RSV${long}${subj}.$j.CA1.nii.gz

#echo "    -CA2"
#${FSLDIR}/bin/fslmaths $result_dir/roi_tse/RSV${long}${subj}.$j.nii.gz -uthr 207 -thr 207 -bin $result_dir/roi_tse/RSV${long}${subj}.$j.CA2.nii.gz

echo "    -CA3"
${FSLDIR}/bin/fslmaths $result_dir/roi_tse/RSV${long}${subj}.$j.nii.gz -uthr 208 -thr 208 -bin $result_dir/roi_tse/RSV${long}${subj}.$j.CA3.nii.gz

echo "    -CA4"
${FSLDIR}/bin/fslmaths $result_dir/roi_tse/RSV${long}${subj}.$j.nii.gz -uthr 209 -thr 209 -bin $result_dir/roi_tse/RSV${long}${subj}.$j.CA4.nii.gz

echo "    -GC-DG"
${FSLDIR}/bin/fslmaths $result_dir/roi_tse/RSV${long}${subj}.$j.nii.gz -uthr 210 -thr 210 -bin $result_dir/roi_tse/RSV${long}${subj}.$j.GC-DG.nii.gz

echo "    -HATA"
${FSLDIR}/bin/fslmaths $result_dir/roi_tse/RSV${long}${subj}.$j.nii.gz -uthr 211 -thr 211 -bin $result_dir/roi_tse/RSV${long}${subj}.$j.HATA.nii.gz

echo "    -fimbria"
${FSLDIR}/bin/fslmaths $result_dir/roi_tse/RSV${long}${subj}.$j.nii.gz -uthr 212 -thr 212 -bin $result_dir/roi_tse/RSV${long}${subj}.$j.fimbria.nii.gz

echo "    -mo_layer_HP"
${FSLDIR}/bin/fslmaths $result_dir/roi_tse/RSV${long}${subj}.$j.nii.gz -uthr 214 -thr 214 -bin $result_dir/roi_tse/RSV${long}${subj}.$j.mo_layer_HP.nii.gz

echo "    -fissure"
${FSLDIR}/bin/fslmaths $result_dir/roi_tse/RSV${long}${subj}.$j.nii.gz -uthr 215 -thr 215 -bin $result_dir/roi_tse/RSV${long}${subj}.$j.fissure.nii.gz

echo "    -HP_tail"
${FSLDIR}/bin/fslmaths $result_dir/roi_tse/RSV${long}${subj}.$j.nii.gz -uthr 226 -thr 226 -bin $result_dir/roi_tse/RSV${long}${subj}.$j.HP_tail.nii.gz

done
done
done

