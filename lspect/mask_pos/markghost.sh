#!/bin/bash 
# add   -xv for debugging

# This scripts locates the positions of the slits and the holes
# in the image of a mask (LIRIS)
# You might want to change some sextractor parameters.

# SYNTAX:  sex image.fits

# change to the directory where script is located
DIR=/home/jap/liris/roque/scripts/mask_pos/


## NO MORE  CHANGES NEEDED BELOW THIS LINE
sex -c ${DIR}/mask.default.sex $1 \
        -PARAMETERS_NAME ${DIR}/mask.param\
        -FILTER_NAME ${DIR}/default.conv\
        -STARNNW_NAME default.nnw


# -VERBOSE_TYPE QUIET
ellip_ref=0.2
ellip_slit=0.7 

mask_id=$2

sort -k 2,2n -k 1,1n mask.cat > mask1.cat

dfits $1 | fitsort -d lirslnam

## symmetry center valid for Jun2008
xsJ=496.
ysJ=501.
xsH=455.
ysH=475.5
xsK=447.
ysK=488.

awk  -v eref="$ellip_ref" -v eslit="$ellip_slit" -v xs=$xsJ -v ys=$ysJ '{
    if ($4<eref) {
      iref += 1;
      rad = 2*$5; 
      xgh = 2*xs - $1
      ygh = 2*ys - $2
      print "image;circle(",xgh,",",ygh,", ",rad,") # text={Ref ",iref,"}"
    }
    if ($4>eslit) {
      islt += 1
      len = 3.5*$5;
      wid = 4.*$6;
      xgh = 2*xs - $1
      ygh = 2*ys - $2
     print "image;box(", xgh,",",ygh,",",wid,",",len,",0.) # text={Slt ",islt,"}"
    } 
    }' mask1.cat > liris_$2_ghostJ.reg
    
awk  -v eref="$ellip_ref" -v eslit="$ellip_slit" -v xs=$xsH -v ys=$ysH '{
    if ($4<eref) {
      iref += 1;
      rad = 2*$5; 
      xgh = 2*xs - $1
      ygh = 2*ys - $2
      print "image;circle(",xgh,",",ygh,", ",rad,") # text={Ref ",iref,"}"
    }
    if ($4>eslit) {
      islt += 1
      len = 3.5*$5;
      wid = 4.*$6;
      xgh = 2*xs - $1
      ygh = 2*ys - $2
     print "image;box(", xgh,",",ygh,",",wid,",",len,",0.) # text={Slt ",islt,"}"
    } 
    }' mask1.cat > liris_$2_ghostH.reg
    
awk  -v eref="$ellip_ref" -v eslit="$ellip_slit" -v xs=$xsK -v ys=$ysK '{
    if ($4<eref) {
      iref += 1;
      rad = 2*$5; 
      xgh = 2*xs - $1
      ygh = 2*ys - $2
      print "image;circle(",xgh,",",ygh,", ",rad,") # text={Ref ",iref,"}"
    }
    if ($4>eslit) {
      islt += 1
      len = 3.5*$5;
      wid = 4.*$6;
      xgh = 2*xs - $1
      ygh = 2*ys - $2
     print "image;box(", xgh,",",ygh,",",wid,",",len,",0.) # text={Slt ",islt,"}"
    } 
    }' mask1.cat > liris_$2_ghostK.reg
    
  

\rm mask1.cat
