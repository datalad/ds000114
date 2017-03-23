
 mri_convert /scratch/users/chrisgor/ds114_test1/sub-01/anat/sub-01_T1w.nii.gz /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/sub-01/mri/orig/001.mgz 

#--------------------------------------------
#@# MotionCor Mon Sep 12 16:25:27 UTC 2016

 cp /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/sub-01/mri/orig/001.mgz /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/sub-01/mri/rawavg.mgz 


 mri_convert /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/sub-01/mri/rawavg.mgz /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/sub-01/mri/orig.mgz --conform 


 mri_add_xform_to_header -c /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/sub-01/mri/transforms/talairach.xfm /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/sub-01/mri/orig.mgz /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/sub-01/mri/orig.mgz 

#--------------------------------------------
#@# Talairach Mon Sep 12 16:25:36 UTC 2016

 mri_nu_correct.mni --n 1 --proto-iters 1000 --distance 50 --no-rescale --i orig.mgz --o orig_nu.mgz 


 talairach_avi --i orig_nu.mgz --xfm transforms/talairach.auto.xfm 


 cp transforms/talairach.auto.xfm transforms/talairach.xfm 

#--------------------------------------------
#@# Talairach Failure Detection Mon Sep 12 16:26:41 UTC 2016

 talairach_afd -T 0.005 -xfm transforms/talairach.xfm 


 awk -f /opt/freesurfer/bin/extract_talairach_avi_QA.awk /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/sub-01/mri/transforms/talairach_avi.log 


 tal_QC_AZS /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/sub-01/mri/transforms/talairach_avi.log 

#--------------------------------------------
#@# Nu Intensity Correction Mon Sep 12 16:26:41 UTC 2016

 mri_nu_correct.mni --i orig.mgz --o nu.mgz --uchar transforms/talairach.xfm --n 2 


 mri_add_xform_to_header -c /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/sub-01/mri/transforms/talairach.xfm nu.mgz nu.mgz 

#--------------------------------------------
#@# Intensity Normalization Mon Sep 12 16:27:44 UTC 2016

 mri_normalize -g 1 nu.mgz T1.mgz 

#--------------------------------------------
#@# Skull Stripping Mon Sep 12 16:29:35 UTC 2016

 mri_em_register -skull nu.mgz /opt/freesurfer/average/RB_all_withskull_2008-03-26.gca transforms/talairach_with_skull.lta 


 mri_watershed -T1 -brain_atlas /opt/freesurfer/average/RB_all_withskull_2008-03-26.gca transforms/talairach_with_skull.lta T1.mgz brainmask.auto.mgz 


 cp brainmask.auto.mgz brainmask.mgz 

#-------------------------------------
#@# EM Registration Mon Sep 12 16:53:03 UTC 2016

 mri_em_register -uns 3 -mask brainmask.mgz nu.mgz /opt/freesurfer/average/RB_all_2008-03-26.gca transforms/talairach.lta 

#--------------------------------------
#@# CA Normalize Mon Sep 12 17:13:25 UTC 2016

 mri_ca_normalize -c ctrl_pts.mgz -mask brainmask.mgz nu.mgz /opt/freesurfer/average/RB_all_2008-03-26.gca transforms/talairach.lta norm.mgz 

#--------------------------------------
#@# CA Reg Mon Sep 12 17:14:41 UTC 2016

 mri_ca_register -nobigventricles -T transforms/talairach.lta -align-after -mask brainmask.mgz norm.mgz /opt/freesurfer/average/RB_all_2008-03-26.gca transforms/talairach.m3z 

#--------------------------------------
#@# CA Reg Inv Mon Sep 12 21:38:54 UTC 2016

 mri_ca_register -invert-and-save transforms/talairach.m3z 

#--------------------------------------
#@# Remove Neck Mon Sep 12 21:40:02 UTC 2016

 mri_remove_neck -radius 25 nu.mgz transforms/talairach.m3z /opt/freesurfer/average/RB_all_2008-03-26.gca nu_noneck.mgz 

#--------------------------------------
#@# SkullLTA Mon Sep 12 21:41:14 UTC 2016

 mri_em_register -skull -t transforms/talairach.lta nu_noneck.mgz /opt/freesurfer/average/RB_all_withskull_2008-03-26.gca transforms/talairach_with_skull_2.lta 

#--------------------------------------
#@# SubCort Seg Mon Sep 12 22:00:37 UTC 2016

 mri_ca_label -align norm.mgz transforms/talairach.m3z /opt/freesurfer/average/RB_all_2008-03-26.gca aseg.auto_noCCseg.mgz 


 mri_cc -aseg aseg.auto_noCCseg.mgz -o aseg.auto.mgz -lta /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/sub-01/mri/transforms/cc_up.lta sub-01 

#--------------------------------------
#@# Merge ASeg Mon Sep 12 22:17:28 UTC 2016

 cp aseg.auto.mgz aseg.mgz 

#--------------------------------------------
#@# Intensity Normalization2 Mon Sep 12 22:17:28 UTC 2016

 mri_normalize -aseg aseg.mgz -mask brainmask.mgz norm.mgz brain.mgz 

#--------------------------------------------
#@# Mask BFS Mon Sep 12 22:20:02 UTC 2016

 mri_mask -T 5 brain.mgz brainmask.mgz brain.finalsurfs.mgz 

#--------------------------------------------
#@# WM Segmentation Mon Sep 12 22:20:03 UTC 2016

 mri_segment brain.mgz wm.seg.mgz 


 mri_edit_wm_with_aseg -keep-in wm.seg.mgz brain.mgz aseg.mgz wm.asegedit.mgz 


 mri_pretess wm.asegedit.mgz wm norm.mgz wm.mgz 

#--------------------------------------------
#@# Fill Mon Sep 12 22:21:41 UTC 2016

 mri_fill -a ../scripts/ponscc.cut.log -xform transforms/talairach.lta -segmentation aseg.auto_noCCseg.mgz wm.mgz filled.mgz 

#--------------------------------------------
#@# Tessellate lh Mon Sep 12 22:22:16 UTC 2016

 mri_pretess ../mri/filled.mgz 255 ../mri/norm.mgz ../mri/filled-pretess255.mgz 


 mri_tessellate ../mri/filled-pretess255.mgz 255 ../surf/lh.orig.nofix 


 rm -f ../mri/filled-pretess255.mgz 


 mris_extract_main_component ../surf/lh.orig.nofix ../surf/lh.orig.nofix 

#--------------------------------------------
#@# Smooth1 lh Mon Sep 12 22:22:20 UTC 2016

 mris_smooth -nw -seed 1234 ../surf/lh.orig.nofix ../surf/lh.smoothwm.nofix 

#--------------------------------------------
#@# Inflation1 lh Mon Sep 12 22:22:22 UTC 2016

 mris_inflate -no-save-sulc ../surf/lh.smoothwm.nofix ../surf/lh.inflated.nofix 

#--------------------------------------------
#@# QSphere lh Mon Sep 12 22:22:37 UTC 2016

 mris_sphere -q -seed 1234 ../surf/lh.inflated.nofix ../surf/lh.qsphere.nofix 

#--------------------------------------------
#@# Fix Topology lh Mon Sep 12 22:24:36 UTC 2016

 cp ../surf/lh.orig.nofix ../surf/lh.orig 


 cp ../surf/lh.inflated.nofix ../surf/lh.inflated 


 mris_fix_topology -mgz -sphere qsphere.nofix -ga -seed 1234 sub-01 lh 


 mris_euler_number ../surf/lh.orig 


 mris_remove_intersection ../surf/lh.orig ../surf/lh.orig 


 rm ../surf/lh.inflated 

#--------------------------------------------
#@# Make White Surf lh Mon Sep 12 22:42:24 UTC 2016

 mris_make_surfaces -noaparc -whiteonly -mgz -T1 brain.finalsurfs sub-01 lh 

#--------------------------------------------
#@# Smooth2 lh Mon Sep 12 22:45:10 UTC 2016

 mris_smooth -n 3 -nw -seed 1234 ../surf/lh.white ../surf/lh.smoothwm 

#--------------------------------------------
#@# Inflation2 lh Mon Sep 12 22:45:12 UTC 2016

 mris_inflate ../surf/lh.smoothwm ../surf/lh.inflated 


 mris_curvature -thresh .999 -n -a 5 -w -distances 10 10 ../surf/lh.inflated 


#-----------------------------------------
#@# Curvature Stats lh Mon Sep 12 22:46:12 UTC 2016

 mris_curvature_stats -m --writeCurvatureFiles -G -o ../stats/lh.curv.stats -F smoothwm sub-01 lh curv sulc 

#--------------------------------------------
#@# Sphere lh Mon Sep 12 22:46:14 UTC 2016

 mris_sphere -seed 1234 ../surf/lh.inflated ../surf/lh.sphere 

#--------------------------------------------
#@# Surf Reg lh Mon Sep 12 23:01:20 UTC 2016

 mris_register -curv ../surf/lh.sphere /opt/freesurfer/average/lh.average.curvature.filled.buckner40.tif ../surf/lh.sphere.reg 

#--------------------------------------------
#@# Jacobian white lh Mon Sep 12 23:12:54 UTC 2016

 mris_jacobian ../surf/lh.white ../surf/lh.sphere.reg ../surf/lh.jacobian_white 

#--------------------------------------------
#@# AvgCurv lh Mon Sep 12 23:12:55 UTC 2016

 mrisp_paint -a 5 /opt/freesurfer/average/lh.average.curvature.filled.buckner40.tif#6 ../surf/lh.sphere.reg ../surf/lh.avg_curv 

#-----------------------------------------
#@# Cortical Parc lh Mon Sep 12 23:12:56 UTC 2016

 mris_ca_label -l ../label/lh.cortex.label -aseg ../mri/aseg.mgz -seed 1234 sub-01 lh ../surf/lh.sphere.reg /opt/freesurfer/average/lh.curvature.buckner40.filled.desikan_killiany.2010-03-25.gcs ../label/lh.aparc.annot 

#--------------------------------------------
#@# Make Pial Surf lh Mon Sep 12 23:13:21 UTC 2016

 mris_make_surfaces -white NOWRITE -mgz -T1 brain.finalsurfs sub-01 lh 

#--------------------------------------------
#@# Surf Volume lh Mon Sep 12 23:19:11 UTC 2016

 mris_calc -o lh.area.mid lh.area add lh.area.pial 


 mris_calc -o lh.area.mid lh.area.mid div 2 


 mris_calc -o lh.volume lh.area.mid mul lh.thickness 

#-----------------------------------------
#@# WM/GM Contrast lh Mon Sep 12 23:19:11 UTC 2016

 pctsurfcon --s sub-01 --lh-only 

#-----------------------------------------
#@# Parcellation Stats lh Mon Sep 12 23:19:16 UTC 2016

 mris_anatomical_stats -mgz -cortex ../label/lh.cortex.label -f ../stats/lh.aparc.stats -b -a ../label/lh.aparc.annot -c ../label/aparc.annot.ctab sub-01 lh white 

#-----------------------------------------
#@# Cortical Parc 2 lh Mon Sep 12 23:19:22 UTC 2016

 mris_ca_label -l ../label/lh.cortex.label -aseg ../mri/aseg.mgz -seed 1234 sub-01 lh ../surf/lh.sphere.reg /opt/freesurfer/average/lh.destrieux.simple.2009-07-29.gcs ../label/lh.aparc.a2009s.annot 

#-----------------------------------------
#@# Parcellation Stats 2 lh Mon Sep 12 23:19:51 UTC 2016

 mris_anatomical_stats -mgz -cortex ../label/lh.cortex.label -f ../stats/lh.aparc.a2009s.stats -b -a ../label/lh.aparc.a2009s.annot -c ../label/aparc.annot.a2009s.ctab sub-01 lh white 

#-----------------------------------------
#@# Cortical Parc 3 lh Mon Sep 12 23:19:58 UTC 2016

 mris_ca_label -l ../label/lh.cortex.label -aseg ../mri/aseg.mgz -seed 1234 sub-01 lh ../surf/lh.sphere.reg /opt/freesurfer/average/lh.DKTatlas40.gcs ../label/lh.aparc.DKTatlas40.annot 

#-----------------------------------------
#@# Parcellation Stats 3 lh Mon Sep 12 23:20:23 UTC 2016

 mris_anatomical_stats -mgz -cortex ../label/lh.cortex.label -f ../stats/lh.aparc.DKTatlas40.stats -b -a ../label/lh.aparc.DKTatlas40.annot -c ../label/aparc.annot.DKTatlas40.ctab sub-01 lh white 

#--------------------------------------------
#@# Tessellate rh Mon Sep 12 23:20:30 UTC 2016

 mri_pretess ../mri/filled.mgz 127 ../mri/norm.mgz ../mri/filled-pretess127.mgz 


 mri_tessellate ../mri/filled-pretess127.mgz 127 ../surf/rh.orig.nofix 


 rm -f ../mri/filled-pretess127.mgz 


 mris_extract_main_component ../surf/rh.orig.nofix ../surf/rh.orig.nofix 

#--------------------------------------------
#@# Smooth1 rh Mon Sep 12 23:20:33 UTC 2016

 mris_smooth -nw -seed 1234 ../surf/rh.orig.nofix ../surf/rh.smoothwm.nofix 

#--------------------------------------------
#@# Inflation1 rh Mon Sep 12 23:20:35 UTC 2016

 mris_inflate -no-save-sulc ../surf/rh.smoothwm.nofix ../surf/rh.inflated.nofix 

#--------------------------------------------
#@# QSphere rh Mon Sep 12 23:20:50 UTC 2016

 mris_sphere -q -seed 1234 ../surf/rh.inflated.nofix ../surf/rh.qsphere.nofix 

#--------------------------------------------
#@# Fix Topology rh Mon Sep 12 23:22:49 UTC 2016

 cp ../surf/rh.orig.nofix ../surf/rh.orig 


 cp ../surf/rh.inflated.nofix ../surf/rh.inflated 


 mris_fix_topology -mgz -sphere qsphere.nofix -ga -seed 1234 sub-01 rh 


 mris_euler_number ../surf/rh.orig 


 mris_remove_intersection ../surf/rh.orig ../surf/rh.orig 


 rm ../surf/rh.inflated 

#--------------------------------------------
#@# Make White Surf rh Mon Sep 12 23:36:54 UTC 2016

 mris_make_surfaces -noaparc -whiteonly -mgz -T1 brain.finalsurfs sub-01 rh 

#--------------------------------------------
#@# Smooth2 rh Mon Sep 12 23:39:32 UTC 2016

 mris_smooth -n 3 -nw -seed 1234 ../surf/rh.white ../surf/rh.smoothwm 

#--------------------------------------------
#@# Inflation2 rh Mon Sep 12 23:39:34 UTC 2016

 mris_inflate ../surf/rh.smoothwm ../surf/rh.inflated 


 mris_curvature -thresh .999 -n -a 5 -w -distances 10 10 ../surf/rh.inflated 


#-----------------------------------------
#@# Curvature Stats rh Mon Sep 12 23:40:33 UTC 2016

 mris_curvature_stats -m --writeCurvatureFiles -G -o ../stats/rh.curv.stats -F smoothwm sub-01 rh curv sulc 

#--------------------------------------------
#@# Sphere rh Mon Sep 12 23:40:35 UTC 2016

 mris_sphere -seed 1234 ../surf/rh.inflated ../surf/rh.sphere 

#--------------------------------------------
#@# Surf Reg rh Mon Sep 12 23:56:03 UTC 2016

 mris_register -curv ../surf/rh.sphere /opt/freesurfer/average/rh.average.curvature.filled.buckner40.tif ../surf/rh.sphere.reg 

#--------------------------------------------
#@# Jacobian white rh Tue Sep 13 00:07:45 UTC 2016

 mris_jacobian ../surf/rh.white ../surf/rh.sphere.reg ../surf/rh.jacobian_white 

#--------------------------------------------
#@# AvgCurv rh Tue Sep 13 00:07:46 UTC 2016

 mrisp_paint -a 5 /opt/freesurfer/average/rh.average.curvature.filled.buckner40.tif#6 ../surf/rh.sphere.reg ../surf/rh.avg_curv 

#-----------------------------------------
#@# Cortical Parc rh Tue Sep 13 00:07:47 UTC 2016

 mris_ca_label -l ../label/rh.cortex.label -aseg ../mri/aseg.mgz -seed 1234 sub-01 rh ../surf/rh.sphere.reg /opt/freesurfer/average/rh.curvature.buckner40.filled.desikan_killiany.2010-03-25.gcs ../label/rh.aparc.annot 

#--------------------------------------------
#@# Make Pial Surf rh Tue Sep 13 00:08:13 UTC 2016

 mris_make_surfaces -white NOWRITE -mgz -T1 brain.finalsurfs sub-01 rh 

#--------------------------------------------
#@# Surf Volume rh Tue Sep 13 00:13:50 UTC 2016

 mris_calc -o rh.area.mid rh.area add rh.area.pial 


 mris_calc -o rh.area.mid rh.area.mid div 2 


 mris_calc -o rh.volume rh.area.mid mul rh.thickness 

#-----------------------------------------
#@# WM/GM Contrast rh Tue Sep 13 00:13:50 UTC 2016

 pctsurfcon --s sub-01 --rh-only 

#-----------------------------------------
#@# Parcellation Stats rh Tue Sep 13 00:13:54 UTC 2016

 mris_anatomical_stats -mgz -cortex ../label/rh.cortex.label -f ../stats/rh.aparc.stats -b -a ../label/rh.aparc.annot -c ../label/aparc.annot.ctab sub-01 rh white 

#-----------------------------------------
#@# Cortical Parc 2 rh Tue Sep 13 00:14:01 UTC 2016

 mris_ca_label -l ../label/rh.cortex.label -aseg ../mri/aseg.mgz -seed 1234 sub-01 rh ../surf/rh.sphere.reg /opt/freesurfer/average/rh.destrieux.simple.2009-07-29.gcs ../label/rh.aparc.a2009s.annot 

#-----------------------------------------
#@# Parcellation Stats 2 rh Tue Sep 13 00:14:30 UTC 2016

 mris_anatomical_stats -mgz -cortex ../label/rh.cortex.label -f ../stats/rh.aparc.a2009s.stats -b -a ../label/rh.aparc.a2009s.annot -c ../label/aparc.annot.a2009s.ctab sub-01 rh white 

#-----------------------------------------
#@# Cortical Parc 3 rh Tue Sep 13 00:14:37 UTC 2016

 mris_ca_label -l ../label/rh.cortex.label -aseg ../mri/aseg.mgz -seed 1234 sub-01 rh ../surf/rh.sphere.reg /opt/freesurfer/average/rh.DKTatlas40.gcs ../label/rh.aparc.DKTatlas40.annot 

#-----------------------------------------
#@# Parcellation Stats 3 rh Tue Sep 13 00:15:02 UTC 2016

 mris_anatomical_stats -mgz -cortex ../label/rh.cortex.label -f ../stats/rh.aparc.DKTatlas40.stats -b -a ../label/rh.aparc.DKTatlas40.annot -c ../label/aparc.annot.DKTatlas40.ctab sub-01 rh white 

#--------------------------------------------
#@# Cortical ribbon mask Tue Sep 13 00:15:09 UTC 2016

 mris_volmask --label_left_white 2 --label_left_ribbon 3 --label_right_white 41 --label_right_ribbon 42 --save_ribbon sub-01 

#--------------------------------------------
#@# ASeg Stats Tue Sep 13 00:19:47 UTC 2016

 mri_segstats --seg mri/aseg.mgz --sum stats/aseg.stats --pv mri/norm.mgz --empty --brainmask mri/brainmask.mgz --brain-vol-from-seg --excludeid 0 --excl-ctxgmwm --supratent --subcortgray --in mri/norm.mgz --in-intensity-name norm --in-intensity-units MR --etiv --surf-wm-vol --surf-ctx-vol --totalgray --euler --ctab /opt/freesurfer/ASegStatsLUT.txt --subject sub-01 

#-----------------------------------------
#@# AParc-to-ASeg Tue Sep 13 00:21:51 UTC 2016

 mri_aparc2aseg --s sub-01 --volmask 


 mri_aparc2aseg --s sub-01 --volmask --a2009s 

#-----------------------------------------
#@# WMParc Tue Sep 13 00:23:13 UTC 2016

 mri_aparc2aseg --s sub-01 --labelwm --hypo-as-wm --rip-unknown --volmask --o mri/wmparc.mgz --ctxseg aparc+aseg.mgz 


 mri_segstats --seg mri/wmparc.mgz --sum stats/wmparc.stats --pv mri/norm.mgz --excludeid 0 --brainmask mri/brainmask.mgz --in mri/norm.mgz --in-intensity-name norm --in-intensity-units MR --subject sub-01 --surf-wm-vol --ctab /opt/freesurfer/WMParcStatsLUT.txt --etiv 

#--------------------------------------------
#@# BA Labels lh Tue Sep 13 00:30:05 UTC 2016

 mri_label2label --srcsubject fsaverage --srclabel /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/fsaverage/label/lh.BA1.label --trgsubject sub-01 --trglabel ./lh.BA1.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/fsaverage/label/lh.BA2.label --trgsubject sub-01 --trglabel ./lh.BA2.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/fsaverage/label/lh.BA3a.label --trgsubject sub-01 --trglabel ./lh.BA3a.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/fsaverage/label/lh.BA3b.label --trgsubject sub-01 --trglabel ./lh.BA3b.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/fsaverage/label/lh.BA4a.label --trgsubject sub-01 --trglabel ./lh.BA4a.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/fsaverage/label/lh.BA4p.label --trgsubject sub-01 --trglabel ./lh.BA4p.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/fsaverage/label/lh.BA6.label --trgsubject sub-01 --trglabel ./lh.BA6.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/fsaverage/label/lh.BA44.label --trgsubject sub-01 --trglabel ./lh.BA44.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/fsaverage/label/lh.BA45.label --trgsubject sub-01 --trglabel ./lh.BA45.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/fsaverage/label/lh.V1.label --trgsubject sub-01 --trglabel ./lh.V1.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/fsaverage/label/lh.V2.label --trgsubject sub-01 --trglabel ./lh.V2.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/fsaverage/label/lh.MT.label --trgsubject sub-01 --trglabel ./lh.MT.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/fsaverage/label/lh.perirhinal.label --trgsubject sub-01 --trglabel ./lh.perirhinal.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/fsaverage/label/lh.BA1.thresh.label --trgsubject sub-01 --trglabel ./lh.BA1.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/fsaverage/label/lh.BA2.thresh.label --trgsubject sub-01 --trglabel ./lh.BA2.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/fsaverage/label/lh.BA3a.thresh.label --trgsubject sub-01 --trglabel ./lh.BA3a.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/fsaverage/label/lh.BA3b.thresh.label --trgsubject sub-01 --trglabel ./lh.BA3b.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/fsaverage/label/lh.BA4a.thresh.label --trgsubject sub-01 --trglabel ./lh.BA4a.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/fsaverage/label/lh.BA4p.thresh.label --trgsubject sub-01 --trglabel ./lh.BA4p.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/fsaverage/label/lh.BA6.thresh.label --trgsubject sub-01 --trglabel ./lh.BA6.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/fsaverage/label/lh.BA44.thresh.label --trgsubject sub-01 --trglabel ./lh.BA44.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/fsaverage/label/lh.BA45.thresh.label --trgsubject sub-01 --trglabel ./lh.BA45.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/fsaverage/label/lh.V1.thresh.label --trgsubject sub-01 --trglabel ./lh.V1.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/fsaverage/label/lh.V2.thresh.label --trgsubject sub-01 --trglabel ./lh.V2.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/fsaverage/label/lh.MT.thresh.label --trgsubject sub-01 --trglabel ./lh.MT.thresh.label --hemi lh --regmethod surface 


 mris_label2annot --s sub-01 --hemi lh --ctab /opt/freesurfer/average/colortable_BA.txt --l lh.BA1.label --l lh.BA2.label --l lh.BA3a.label --l lh.BA3b.label --l lh.BA4a.label --l lh.BA4p.label --l lh.BA6.label --l lh.BA44.label --l lh.BA45.label --l lh.V1.label --l lh.V2.label --l lh.MT.label --l lh.perirhinal.label --a BA --maxstatwinner --noverbose 


 mris_label2annot --s sub-01 --hemi lh --ctab /opt/freesurfer/average/colortable_BA.txt --l lh.BA1.thresh.label --l lh.BA2.thresh.label --l lh.BA3a.thresh.label --l lh.BA3b.thresh.label --l lh.BA4a.thresh.label --l lh.BA4p.thresh.label --l lh.BA6.thresh.label --l lh.BA44.thresh.label --l lh.BA45.thresh.label --l lh.V1.thresh.label --l lh.V2.thresh.label --l lh.MT.thresh.label --a BA.thresh --maxstatwinner --noverbose 


 mris_anatomical_stats -mgz -f ../stats/lh.BA.stats -b -a ./lh.BA.annot -c ./BA.ctab sub-01 lh white 


 mris_anatomical_stats -mgz -f ../stats/lh.BA.thresh.stats -b -a ./lh.BA.thresh.annot -c ./BA.thresh.ctab sub-01 lh white 

#--------------------------------------------
#@# BA Labels rh Tue Sep 13 00:32:20 UTC 2016

 mri_label2label --srcsubject fsaverage --srclabel /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/fsaverage/label/rh.BA1.label --trgsubject sub-01 --trglabel ./rh.BA1.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/fsaverage/label/rh.BA2.label --trgsubject sub-01 --trglabel ./rh.BA2.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/fsaverage/label/rh.BA3a.label --trgsubject sub-01 --trglabel ./rh.BA3a.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/fsaverage/label/rh.BA3b.label --trgsubject sub-01 --trglabel ./rh.BA3b.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/fsaverage/label/rh.BA4a.label --trgsubject sub-01 --trglabel ./rh.BA4a.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/fsaverage/label/rh.BA4p.label --trgsubject sub-01 --trglabel ./rh.BA4p.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/fsaverage/label/rh.BA6.label --trgsubject sub-01 --trglabel ./rh.BA6.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/fsaverage/label/rh.BA44.label --trgsubject sub-01 --trglabel ./rh.BA44.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/fsaverage/label/rh.BA45.label --trgsubject sub-01 --trglabel ./rh.BA45.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/fsaverage/label/rh.V1.label --trgsubject sub-01 --trglabel ./rh.V1.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/fsaverage/label/rh.V2.label --trgsubject sub-01 --trglabel ./rh.V2.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/fsaverage/label/rh.MT.label --trgsubject sub-01 --trglabel ./rh.MT.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/fsaverage/label/rh.perirhinal.label --trgsubject sub-01 --trglabel ./rh.perirhinal.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/fsaverage/label/rh.BA1.thresh.label --trgsubject sub-01 --trglabel ./rh.BA1.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/fsaverage/label/rh.BA2.thresh.label --trgsubject sub-01 --trglabel ./rh.BA2.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/fsaverage/label/rh.BA3a.thresh.label --trgsubject sub-01 --trglabel ./rh.BA3a.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/fsaverage/label/rh.BA3b.thresh.label --trgsubject sub-01 --trglabel ./rh.BA3b.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/fsaverage/label/rh.BA4a.thresh.label --trgsubject sub-01 --trglabel ./rh.BA4a.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/fsaverage/label/rh.BA4p.thresh.label --trgsubject sub-01 --trglabel ./rh.BA4p.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/fsaverage/label/rh.BA6.thresh.label --trgsubject sub-01 --trglabel ./rh.BA6.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/fsaverage/label/rh.BA44.thresh.label --trgsubject sub-01 --trglabel ./rh.BA44.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/fsaverage/label/rh.BA45.thresh.label --trgsubject sub-01 --trglabel ./rh.BA45.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/fsaverage/label/rh.V1.thresh.label --trgsubject sub-01 --trglabel ./rh.V1.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/fsaverage/label/rh.V2.thresh.label --trgsubject sub-01 --trglabel ./rh.V2.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /scratch/users/chrisgor/ds114_test1/derivatives/freesurfer/fsaverage/label/rh.MT.thresh.label --trgsubject sub-01 --trglabel ./rh.MT.thresh.label --hemi rh --regmethod surface 


 mris_label2annot --s sub-01 --hemi rh --ctab /opt/freesurfer/average/colortable_BA.txt --l rh.BA1.label --l rh.BA2.label --l rh.BA3a.label --l rh.BA3b.label --l rh.BA4a.label --l rh.BA4p.label --l rh.BA6.label --l rh.BA44.label --l rh.BA45.label --l rh.V1.label --l rh.V2.label --l rh.MT.label --l rh.perirhinal.label --a BA --maxstatwinner --noverbose 


 mris_label2annot --s sub-01 --hemi rh --ctab /opt/freesurfer/average/colortable_BA.txt --l rh.BA1.thresh.label --l rh.BA2.thresh.label --l rh.BA3a.thresh.label --l rh.BA3b.thresh.label --l rh.BA4a.thresh.label --l rh.BA4p.thresh.label --l rh.BA6.thresh.label --l rh.BA44.thresh.label --l rh.BA45.thresh.label --l rh.V1.thresh.label --l rh.V2.thresh.label --l rh.MT.thresh.label --a BA.thresh --maxstatwinner --noverbose 


 mris_anatomical_stats -mgz -f ../stats/rh.BA.stats -b -a ./rh.BA.annot -c ./BA.ctab sub-01 rh white 


 mris_anatomical_stats -mgz -f ../stats/rh.BA.thresh.stats -b -a ./rh.BA.thresh.annot -c ./BA.thresh.ctab sub-01 rh white 

#--------------------------------------------
#@# Ex-vivo Entorhinal Cortex Label lh Tue Sep 13 00:34:35 UTC 2016

 mris_spherical_average -erode 1 -orig white -t 0.4 -o sub-01 label lh.entorhinal lh sphere.reg lh.EC_average lh.entorhinal_exvivo.label 


 mris_anatomical_stats -mgz -f ../stats/lh.entorhinal_exvivo.stats -b -l ./lh.entorhinal_exvivo.label sub-01 lh white 

#--------------------------------------------
#@# Ex-vivo Entorhinal Cortex Label rh Tue Sep 13 00:34:44 UTC 2016

 mris_spherical_average -erode 1 -orig white -t 0.4 -o sub-01 label rh.entorhinal rh sphere.reg rh.EC_average rh.entorhinal_exvivo.label 


 mris_anatomical_stats -mgz -f ../stats/rh.entorhinal_exvivo.stats -b -l ./rh.entorhinal_exvivo.label sub-01 rh white 

