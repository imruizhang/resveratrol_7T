for subj in RSV149 RSV150 RSV152 RSV153 RSV155 RSV156 RSV157 RSV158 RSV159 RSV162 RSV163
do 

cd /nobackup/schiller2/RSV_7T_preprocessing/improve_t1_dwi_coregistration
mkdir $subj #/nobackup/schiller2/RSV_7T_preprocessing/Freesurfer/RSV002/mri/orig/001.mgz
cd ${subj}

cp /data/pt_nro148/7T/DTI/${subj}/roi/${subj}.rawavg.nii.gz orig.nii.gz

echo "running FAST"
fast orig.nii.gz


done
