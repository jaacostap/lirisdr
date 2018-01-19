## create a list containing the names of frames to be reduced.
##  It should contain files corresponding to a single object and the 
## same instrument config.
## The raw data can be in a different directory for example
set raw = /scratch/liris/raw/

## The first step is mandatory and correct for pixel mapping problem
## The output files have the same name with added prefix c
lcpixmap raw$//@raw.lst c ""

## correct bad pixel 
llistdiff c//@raw.lst output=raw1.lst
#bad pixel mask is common to all grisms and bands
fixpix @raw1.lst bp_20061100.pl linterp=3 cinterp=2

## create a master flat-field

lmkflat @flat.lst 

## Determination of slitlet limits using a flat-field image or an arc
## It uses a file which contains the id of the slitlet, the position of the 
## center along spectral axis and the limits along the spatial axis.
lfindmosaper flat_zj mask_mdf.txt mask_slits.pos grow=1 tol=10 showreg+ 

## Wavelength Calibration 
lmoswavecal mask_slits.pos



## 2.SKY SUBTRACTION
## -----------------
## Depending on the observing mode, 2 or 3 nod points. 
## If 2 point nod then do simple sky subtraction A-B (B-A). 
## The subtracted files are formed like A-B = "s"//nameA_nameB
## It is useful to have a file list (subobj.lst) with the list of 
## subtracted files to be used as input for the next routine.
lspskynod("c"//"@obj.lst",output="s",outlist="subobj.lst",zero=no)

## If 3 point nod 
lspskynod3pt 

