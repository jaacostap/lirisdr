## create a list containing the names of frames to be reduced.
##  It should contain files corresponding to a single object and the 
## same instrument config.
## The raw data can be in a different directory for example
set raw = "../raw/"

## The first step is mandatory and correct for a pixel mapping problem
## The output files have the same name with added prefix c 
lcpixmap raw$//@raw.lst c ""

## correct bad pixel 
llistdiff c//@raw.lst output=raw1.lst
#bad pixel mask is common to all grisms and bands
set imlib="lirisdr$std/"
fixpix @raw1.lst imlib$bp_20061100.pl linterp=3 cinterp=2



## Determination of slitlet limits using a flat-field image or an arc
## It uses a file which contains the id of the slitlet, the position of the 
## center along spectral axis and the limits along the spatial axis.
## DS9 must be active. It will display the flat image and will overlay the
## boundaries found for each slitlet.
## All apertures will be calibrated. 
## Map of lines can be found at lirisdr$std/lr_*jpg for LR_ZJ, they are also
## good for higher resolution
## In the case of lr_zj, second order will appear beyond 15000AA
lfindmosaper cr1293849[1] mask_fp.txt mask_slits.pos grow=1 tol=10 showreg+ 


## Wavelength Calibration 
imcopy cr1293812[1] arc_zj 
lmoswavecal arc_zj mask_slits.pos outroot="arc_zj" trimspec+ 

## in case only few slitlets are  to be calibrated a list containing only those slitlets should be 
## used, although the spectra have to be trimmed a priori, in this case select trimspec=no
lmoswavecal @arc_2.lst mask_slits.pos outroot="arc_zj1" trimspec-

## 2.SKY SUBTRACTION
## -----------------
## Depending on the observing mode, 2 or 3 nod points. 
## If 2 point nod then do simple sky subtraction A-B (B-A). 
## The subtracted files are formed like A-B = "s"//nameA_nameB
## It is useful to have a file list (subobj.lst) with the list of 
## subtracted files to be used as input for the next routine.
lspskynod "c"//"@obj.lst" output="s" outlist="subobj.lst" 

## If 3 point nod was used then there is a different routine which combines 
# iamges in the following way: for a sequence A1-B1-C1-A2-B2-C2, it will do
## B1_withoutsky = B1 - (A1+C1)/2, C1_withoutsky = C1 - (B1+A2)/2, 
lspskynod3pt('c'//'@obj.lst',output="s",oflist="subobj.lst")

## Now trim spectra for the different slitlets, wavelength calibrate and 
## flat-field correct and combine the spectra. There is a slit which contains
## a reference star, always visible which permits to measure the offsets.
## If this is not the case you have to use ishift="wcs" which is the 
## offset determined from the telescope pointings.
combspct.reject="pclip"
lspnodcomb @subobj.lst obj ftrimsec="mask_slits_sh.pos" iref=7 ishift="crosscor" \
  trspec="@arc_zj.lst" doublesky+ flatcor=""


