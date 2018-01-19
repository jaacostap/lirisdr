## First step is to correct of bad pixel mapping. IT IS MANDATORY
set raw = "../raw/"   ## define the directory where to find raw data. The list of files is allima.lst
lcpixmap("raw$//@allima.lst","c","")  ## corrected images will have prefix c

###########################  FLAT-FIELD  ##############################
## correct jump between quadrants before combining flat-field frames
leququad c//@flatJ.lst gc//@flatJ.lst corro-

## create a flat-field image
lmkflat gc//@flatJ.lst "" "NgflatJ" flatbr="FlatJ_br" combine="median" 
lmkflat gc//@flatKs_br.lst gc//flatKs_dk.lst "NgflatKs" flatbr="FlatKs_br" flatdk="FlatKs_dk" combine="median"


########################## SCIENCE FRAMES ###############################
## introduce rough astrometry based on TCS. Later, it should be finely adjusted 
lwcsedit c//@ima_Ks.lst instrument="liris"


# check this parameters 
skycpars.maskobj=yes   # mask objects during creation of sky images?
skycpars.corvgrad=yes  # correct residual vertical gradient after sky subtraction ? 

# perform sky subtraction using the dither images, correct flat 
ldedither.skycomb="cycle"    # will combine images to construct sky frames using 
                             #  subsets of 5 images, if repeated exposures at the same point, 
			     #  they will be combined separately.   
ldedither.nditpts=5    #  dither pattern  use 5 different points, specify according to observations!!!

ldedither.inflat="Nflat_Ks"  # flat field image is Nflat_Ks.fits, if set to "" no flat-field correction  
ldedither.intrans="default"  # correct geometrical distortion using default params, if set to "" no correction

## at this point all images will be sky subtracted, flat-fielded, geom. distortion corrected and finally 
## combined to form the final image

ldedither("c//@ima_Ks.lst","target_Ks",expmask="target_Ks_exp",\
 rejmask="target_Ks_rej",subsky="combsky",outrow="c",outcorr="g",\
 outmask="m",outsbsk="s",corrow=no,\
 outsky="sky_Ks",match="wcs",adjshift=yes,zero="median",reject="pclip", \
 incmask="default",skycomb="cycle",inmask="default")

