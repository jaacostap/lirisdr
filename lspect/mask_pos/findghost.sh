#!/bin/bash 
# add   -xv for debugging

# This scripts locates the positions of the slits and the holes
# in the image of a mask (LIRIS)
# You might want to change some sextractor parameters.

# SYNTAX:  sex image.fits

# change to the directory where script is located
###DIR=/home/whtobs/liris/utils/mask_pos/
dd=`which $0`
DIR=`echo $dd | awk -F\/ '{for(i=1;i<NF;i++) printf("%s/", $i)}'`
echo $DIR

## NO MORE  CHANGES NEEDED BELOW THIS LINE
sex -c ${DIR}/mask.ghost.sex $1 \
	-PARAMETERS_NAME ${DIR}/mask.param\
	-FILTER_NAME ${DIR}/default.conv\
	-STARNNW_NAME default.nnw


# -VERBOSE_TYPE QUIET
ellip_ref=0.2
ellip_slit=0.7 

## get maskid from image header
#dfits $1 | fitsort -d lirslnam > hdr1.txt

#mask_id=`awk '{print $2}' hdr1.txt`


#\rm hdr1.txt

mask_id=$2
echo "maskid "$mask_id

sort -k 2,2n -k 1,1n mask.cat > mask1.cat
awk -v ellref="$ellip_ref" -v ellslt="$ellip_slit" '{
    if ($4<ellref) {
        rad = 2*2.1*$5; 
        print "REF",$1, $2, rad, rad
     }	
    if ($4 >ellslt) {
        len = 3.6*$5;
        wid = 4.*$6;
        print "SLIT", $1, $2, wid, len
     }
    }' mask1.cat > $mask_id".mask"


iref=0
islt=0
awk -v ellref="$ellip_ref" -v ellslt="$ellip_slit" '{
    if ($4<ellref) {
      iref += 1;
      rad = 2.1*$5; 
      print "image;circle(",$1,",",$2,",",rad,") # text={Ref ",iref,"}"
    }
    if ($4>ellslt) {
     islt += 1
     len = 3.6*$5;
     wid = 4.*$6;
     print "image;box(", $1,",",$2,",",wid,",",len,",0.) # text={Slt ",islt,"}"
    } 
    }' mask1.cat > $mask_id".reg"
    
   

#\rm mask1.cat
