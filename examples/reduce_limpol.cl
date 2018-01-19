##  Step 1: From flat-field images create file with edges + flat correction
## 

#Correction of bad pixel mapping
set raw = "../raw/"  ## any directory whre raw images are stored
lcpixmap raw$//@cflats.lst c ""

#Correction of bad columns and lines
## the bad pixel file bp_200...pl can be found at lirisdr$std/
llistdiff c//@cflats.lst output=cflats1.lst ## add a [1] to the images file.
fixpix @cflats1.lst bp_20061100.pl linterp=3 cinterp=2

## determine edges
lpedge cr912892[1] output="ipoltrimJ.dat" grow=2  verb- interac-
## must be run with extensions [1]

## Now it will trim image according to limits given in ipoltrim.dat, which can
## be computed in previous step or edited by hand. Then compute a 
## Normalized flat for each stripe
lpmkflat c//@flats.lst "" NflatJ ftrimsec="ipoltrimJ.dat" dbdir="./" flatdk="" flatbr="flatJ" \
   combine="median" scale="median" corrow- 
## can be run in images with no extensions


## Now go to science data 

#Correction of bad pixel mapping

set raw = "../raw/"

lcpixmap raw$//@field1.lst c ""


#Correction of bad columns and lines
## the bad pixel file bp_200...pl can be found at lirisdr$std/
llistdiff c//@field1.lst output=field1c.lst ## add a [1] to the images file.
fixpix @field1c.lst bp_20061100.pl linterp=3 cinterp=2



## setup parameters of lpdedither, the most relevant perhaps combine image using cycles, add a zero before combining,
##  to have right rejection algorithm (pclip, which will discard pixels above or below 25% from median)
lpdedither.rejmask=""
lpdedither.incmask=""
lpdedither.inmask=""
lpdedither.crtalk=no
lpdedither.intprow=no
lpdedither.skycomb="cycle"
lpdedither.corrow=no
lpdedither.zero="median"
lpdedither.scale="none"
lpdedither.reject="pclip"
lpdedither.skycpars=""
## restrict image size to avoid strange features at stripe edges 
lpdedither.xstr0=0.95
lpdedither.ystr0=0.95
lpdedither.xstr90=0.95
lpdedither.ystr90=0.95
lpdedither.xstr45=0.95
lpdedither.ystr45=0.95
lpdedither.xstr135=0.95
lpdedither.ystr135=0.95

## in this step the images will be trimmed, sky subtracted, flat-field corrected and finally combined to form a single frame
## for each polarization stage. It is very important to specify where the flat and file defining trim sections are located.
## Two auxiliary files are needed nflat.lst and dist.lst which contain  the list of flats and distortion correction per stripe
## Here there is an example of each:
## ### nflat.lst
## NflatJ_0
## NflatJ_90
## NflatJ_135
## NflatJ_45
## ### dist.lst
## 0 lgdistpol0_041001
## 90 lgdistpol90_041001
## 135 lgdistpol135_041001
## 45 lgdistpol45_041001
## The files containing the distortion correction must be copied into the working directory from the directory lirisdr$std/
set flatdir="../flats/"
set secdir="../flats/" 
lpdedither ("c//@field1.lst",  \
 "field1comb", ftrimsec="secdir$//ipoltrimJ.dat", match="wcs", expmask="", rejmask="",\
 subsky="combsky", insky="", outrow="", outcrtk="", outprps="", outfltc="f",\
 outmask="m", outsbsk="s", outcorr="g", outsky="", outshift="",inmask="",\
 incmask="", inflat="flatdir$//@nflat.lst", intrans="@dist.lst",\
 nditpts=5, adjshift=yes,verbose=yes,\
 tmpdir=")_.tmpdir", stddir=")_.stddir",bigbox=17, sherror=5., psf=4.)
