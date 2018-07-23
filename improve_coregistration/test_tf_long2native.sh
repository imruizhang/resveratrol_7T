mri_convert -ait /nobackup/schiller2/RSV_7T_preprocessing/Freesurfer/RSV057.long.RSVX57_template/mri/transforms/RSV057_to_RSV057.long.RSVX57_template.lta             -rl /nobackup/schiller2/RSV_7T_preprocessing/Freesurfer/RSV057/mri/norm.mgz             -rt nearest -odt uchar    --no_scale 1          /nobackup/schiller2/RSV_7T_preprocessing/Freesurfer/RSV057.long.RSVX57_template/mri/rh.hippoSfLabels-T1-T2_woresampling.v10.mgz    /nobackup/schiller2/RSV_7T_preprocessing/Freesurfer/RSV057/mri/test_subfields2tp.mgz


mri_convert -ait /nobackup/schiller2/RSV_7T_preprocessing/Freesurfer/RSV057.long.RSVX57_template/mri/transforms/RSV057_to_RSV057.long.RSVX57_template.lta \
            -rl /nobackup/schiller2/RSV_7T_preprocessing/Freesurfer/RSV057/mri/rawavg.mgz \
            -rt nearest -odt uchar \
            /nobackup/schiller2/RSV_7T_preprocessing/Freesurfer/RSV057.long.RSVX57_template/mri/aseg.mgz /nobackup/schiller2/RSV_7T_preprocessing/Freesurfer/RSV057/mri/aseg-in-rawavg.mgz
