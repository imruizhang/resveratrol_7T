# This is to share the processing steps that were done for resveratrol study

So far we published one paper with primary and secondary outcomes using 7T MRI data.

- Huhn et al. "Effects of resveratrol on memory performance, hippocampus connectivity and microstructure in older adults–A randomized controlled trial." NeuroImage 174 (2018): 177-190. [link](https://www.sciencedirect.com/science/article/pii/S1053811918302337) 

## 3T MRI data
- data has been preprocessed with standard FSL pipeline

- post processing including:
  + registration of T1 and b0 images
  + extraction of mean diffusivity value of the hippocampal subfields


## 7T MRI data

- data has been preprocessed with standard FSL pipeline

- the post processing of registration between T1 and DTI was done by Frauke Beyer (files in ./improve_coregistration)
