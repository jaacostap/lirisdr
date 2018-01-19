## create a list containing the names of frames to be reduced.
##  It should contain files corresponding to a single object and the 
## same instrument config.
## The raw data can be in a different directory for example
set raw = /scratch/liris/raw/

## The first step is mandatory and correct for pixel mapping problem
## The output files have the same name with added prefix c
lcpixmap raw$//@obj.lst c ""

## Now do simple sky subtraction A-B (B-A). 
## The subtracted files are formed like A-B = "s"//nameA_nameB
## It is useful to have a file list (subobj.lst) with the list of 
## subtracted files to be used as input for the next routine.
lspskynod("c"//"@obj.lst",output="s",outlist="subobj.lst",zero=no)

## Now combine the spectra, do wavelength calibration and flat
## 
## if double is selected then the residual sky lines are subtracted by
## interpolating 
## In this example the name of  flat image is flatspec, the arc is called
## arccal (suppose to be obtained from fitcoords).
## The  flatfield corrected images can be stored by specifing a prefix
## ffpref. 
## The wavelength corrected images can be stored by 
## Selecting doubles=yes, a second sky subtraction will be done, by
## interpolating along columns, after wavelength calibration. This step
## is not needed in most cases, specially when frame exposure times are
## short
lspnodcomb("@subobj.lst","redobj",ftrimsec="",trspec="arccal",\
 database="./database",flatcor="flat",ffpref="f",otpref="t",doubles=yes)
