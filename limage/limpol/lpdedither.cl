##############################################################################
#         
# lpdedither - generate combined polarization images from dither sequence 
#             call ldedither for each polarization angle 
# 
# Author : Jose Acosta (jap@ll.iac.es)
# Version: 18. Feb. 2007
#         
##############################################################################
procedure lpdedither (input, output)
 
string  input	{prompt="Name of file list of dither images"}
string	output	{prompt="Name of output file"}
string  ftrimsec{"default",prompt="File containing sections of each polarization"} 
string	match	{"wcs",prompt="Method used to match images (wcs|manual|pick1|<filename>)"}
string  expmask	{"",prompt="Name of exposure mask (optional)"}
string	rejmask	{"",prompt="Name of rejection masks (optional)"}
string	subsky	{"combsky",enum="none|usrsky|combsky",prompt="Subtract sky"}
string	insky	{"",prompt="name of input sky list image"}

# Names for outputs saved images
string	outrow	 {"",prompt="prefix of image with pixel mapping corrected"}
string	outcrtk	 {"",prompt="prefix of row cross-talk corrected image "}
string	outprps	 {"",prompt="prefix of saved pre-post treated images"}
string  outfltc  {"f",prompt="prefix of flat-field corrected images"}
string  outvgrad {"v",prompt="prefix of vertical gradient corrected images"}
string	outmask	 {"m",prompt="prefix for individual object masks"}
string	outsbsk	 {"s",prompt="prefix of saved images - sky result"}
string	outcorr	 {"g",prompt="prefix of saved geometric distortion corrected images"}
string	outsky	 {"",prompt="name of output sky image"}
string	outshift {"",prompt="name of output image shift file"}

# Correction parameter files
string	inmask	 {"default",prompt="name of common mask file (default|<filename>)"}
string	incmask	 {"default",prompt="name of common fixpix mask file (default|<filename>)"}
string	inflat	 {"",prompt="name of flatfield correction file"}
string	intrans	 {"",prompt="name of geometric distortion correction file"}
bool 	corrow	 {no,prompt="Correct bad pixel mapping?"}
bool 	crtalk	 {no,prompt="Correct row cross talk?"}
bool	intprow	 {no,prompt="Interpolate central bad pixel rows"}
bool	slice	 {yes,prompt="Slice images [needed if images have not been previously sliced]"}
bool	cvgrad   {yes,prompt="Correct vertical gradient?"}
#bool	stmask	 {"yes",prompt="Make and apply individual star masks"}
string	skycomb  {"cycle",enum="cycle|run|single",prompt="Sky combination mode"}
int     nditpts  {5,prompt="Number of dithern points per cycle"}
bool	combimg  {yes,prompt="Combine processed frames into an output image?"}
bool	adjshift {yes,prompt="Adjust the calculated shift from image headers"}
#bool	surfsub	 {no,prompt="Surfit sky-substracted images"}
string  reject   {"none",enum="none|minmax|sigclip|pclip",prompt="Type of rejection when combining images"}
string  zero	 {"none",prompt="Image zero point offset when combining"}
string  scale	 {"none",prompt="Image scaling factor when combining"}

real	nlow     {0.05,prompt="Number or fraction of low pixels to reject to create image"}
real	nhigh    {0.25,prompt="Number of fraction of high pixels to reject to create image"}

pset    liskycpars     {prompt="Parameter set for sky image combination"}
pset    lcvgradpars    {prompt="Parameter set for vertical gradient correction"}
pset    lstarfindpars  {prompt="Parameter set for star finding algorithm"}
pset    lpgeodistpars  {prompt="Parameter set for geometrical distortion correction"}

bool    normexp  {no,prompt="Normalize combined image by exposure time?"}

bool	verbose	{yes,prompt="Verbose"}

# Directories
string	tmpdir	{")_.tmpdir",prompt="Temporary directory for file conversion"}
string	stddir	{")_.stddir",prompt="Parametre directory"}


# check options
bool	dispstep{"no",prompt="Display dedither steps"}
pset	dispopt2{prompt="Option display"}
bool 	choffset{"no",prompt="Check for offset result?"}

# imcentroid parameters
int	bigbox	{17,prompt="Size of the coarse centering box"}
real    sherror	{5.,prompt="Maximum error in pixels on offset"}
real 	psf     {4.,prompt="Value of the PSF - FWHM (pixels) to find reference stars"}


string *list1	{prompt="Ignore this parameter(lpdedither.list1)"}
string *list2	{prompt="Ignore this parameter(lpdedither.list2)"}
string *list3	{prompt="Ignore this parameter(lpdedither.list3)"}


begin
string fsec,fsecext,trlist,proclist,comblist,ldthlist
string inli,imorig,imosec,imext,outimg,shiftref,icombsuf
string lflat1,iflatsec,flattmp_0,flattmp_90,flattmp_45,flattmp_135
string geopardb,intrans1,igdistsec,gdisttmp_0,gdisttmp_90,gdisttmp_45,gdisttmp_135
string imask1,ibp,bpmask1_0,bpmask1_90,bpmask1_45,bpmask1_135 
string bpmask1lst,bptrim1,match90,match0,match45,match135,matchout
string oflc,frcomb_90
int    isec,nditpts1,xoff,yoff,idrt
real   bdrx1,bdry1
bool   verb1,slice1,combimg1,drn1

verb1 = verbose
slice1 = slice
nditpts1 = nditpts
combimg1 = combimg


outimg = output


if (outfltc != "")
 oflc = outfltc 
else  
 oflc = "f"

## construct suffix to be applied to image combination
icombsuf = ""
## flat-fielding ?
if (inflat != "") 
    icombsuf = oflc//icombsuf

## vertical gradient?
if (cvgrad) 
  icombsuf = outvgrad//icombsuf
 
## sky subtraction ?
if (subsky != "none") 
  icombsuf = outsbsk//icombsuf

## geometrical distortion
if (intrans != "")
      icombsuf = outcorr//icombsuf


if (slice1) 
  drn1 = no
else 
  drn1 = yes
  
if (ftrimsec == "default")
  fsec = "lirisdr$std/ipoltrim.dat"
else 
  fsec = ftrimsec
  
fsecext = "lirisdr$std/ipoltrim.ext"  
  
  
inli = mktemp(tmpdir//"_lpddth")
sections(input,option="fullname",>inli)  

## correct pixel mapping

## Individual Flat fields will be applied to each piece 
if (inflat != "") 
  {
    lflat1 = mktemp(tmpdir//"_lpddthflt") 
    sections(inflat,option="fullname",>lflat1) 
    list1 = lflat1
    while(fscan(list1,iflatsec) != EOF)
      {
	 imgets(iflatsec,"LPOLVECT")
	 isec = int(imgets.value)
         switch (isec) {
	 case 0: 
	    flattmp_0 = iflatsec
	 case 90: 
	    flattmp_90 = iflatsec
	 case 135: 
	    flattmp_135 = iflatsec
	 case 45: 
	    flattmp_45 = iflatsec
	 default :
	    {
	      print("Error: wrong number of flat field images")
	      bye
	    }     
         }
      }
  }
else 
  {
    flattmp_0   = ""
    flattmp_90  = ""
    flattmp_135 = ""
    flattmp_45  = ""
  }  
  
#print ("flattmp_90 ",flattmp_90)  
#print ("flattmp_0 ",flattmp_0)  
#print ("flattmp_45 ",flattmp_45)  
#print ("flattmp_135 ",flattmp_135)  
 
## Bad pixels masks have to be cut in the same way as the images. 
## A complete image should be provided. 

if (inmask != "") 
  {
     imask1 = inmask
     bptrim1 = mktemp("_bptrim")
     bpmask1lst = mktemp("_bpmask1lst")
     if (verb1 && slice1) print ("Trimming bad pixel image ",imask1)
     ltrimpol(imask1,bptrim1,fsec,outlist=bpmask1lst,ismask=yes,dryrun=drn1)
     list1 = bpmask1lst
     while (fscan(list1,ibp) != EOF)
       {
         if (verb1) 
            print ("Creating bad pixel masks")
	 imgets(ibp,"LPOLVECT")
	 isec = int(imgets.value)
         switch (isec) {
	 case 0: 
	    bpmask1_0 = ibp
	 case 90: 
	    bpmask1_90 = ibp
	 case 135: 
	    bpmask1_135 = ibp
	 case 45: 
	    bpmask1_45 = ibp
	 default :
	    {
	      print("Error: wrong number of section images")
	      bye
	    }    
         }
       }
  }
else
  {
     bpmask1_0 = ""
     bpmask1_90 = ""
     bpmask1_135 = ""
     bpmask1_45 = ""
  }
  
## There will be a geometrical distortion correction to be applied to each 
## piece. A file containing the list of files must be provided.

if (intrans != "")
   {
      igdistsec=""
      isec = 999
      geopardb = osfn(lpgeodistpars.database)
      print ("geopardb ",geopardb)
      #intrans1 = mktemp(tmpdir//"_lpddthtrn") 
      #sections(intrans,option="fullname",>intrans1) 
      list1 = intrans
    while(fscanf(list1,"%d %s",isec,igdistsec) != EOF)
      {
         switch (isec) {
	 case 0: 
            { 
              gdisttmp_0 = geopardb//igdistsec
              if (verbose) print ("Geometrical distortion correction at 0 ",gdisttmp_0)
            }
	 case 90: 
            { 
	      gdisttmp_90 = geopardb//igdistsec
              if (verbose) print ("Geometrical distortion correction at 90 ",gdisttmp_90)
            }
	 case 135: 
            { 
	      gdisttmp_135 = geopardb//igdistsec
              if (verbose) print ("Geometrical distortion correction at 135 ",gdisttmp_135)
            }
	 case 45: 
            { 
	      gdisttmp_45 = geopardb//igdistsec
              if (verbose) print ("Geometrical distortion correction at 45 ",gdisttmp_45)
            }
	 default :
	    {
	      print("Error: wrong number of geometric distortion corrections")
	      bye
	    }     
         }
      }
  }
else 
  {
    gdisttmp_0   = ""
    gdisttmp_90  = ""
    gdisttmp_135 = ""
    gdisttmp_45  = ""
  }  



## create lists per section

comblist = mktemp(tmpdir//"_lpdocblst")
proclist = mktemp(tmpdir//"_lpdoprlst")

ldthlist = mktemp(tmpdir//"_lpddthlst")
 

list1 = inli    
if (slice) {
   llistdiff("@"//inli,output=ldthlist)
   list2 = ldthlist
}
while (fscan(list1,imorig) != EOF) 
  {
     if (slice) {
	if (fscan(list2,imext) == EOF)
           {
    	      print "ERROR: Input files are not correct"
    	      beep ; beep ; beep
    	      bye
    	   }
     } else 
       imext = imorig	

     
	
     trlist = mktemp(tmpdir//"_lpddtrlst")
     # imext is the image name contains possible extensions,
     # imorig is the original name of image
     if (verb1 && slice1) print("Trimming into  polarization vectors ",imext)
     ltrimpol(imext,imorig,fsec,outlist=trlist,ismask=no,dryrun=drn1)
     ## adding wcs telescope coordinates
     if (slice1) lpwcsedit(imorig,instrument="liris")
     
     list3 = trlist
     while (fscan(list3,imosec) != EOF)
       {
	 imgets(imosec,"LPOLVECT")
	 isec = int(imgets.value)
         switch (isec) {
	 case 0: 
	    print(imosec,>>proclist//"_0")
	 case 90: 
	    print(imosec,>>proclist//"_90")
	 case 135: 
	    print(imosec,>>proclist//"_135")
	 case 45: 
	    print(imosec,>>proclist//"_45")
	 default :
	    {
	      print("Error: wrong number of image sections")
	      bye
	    }     
         }
       }
     delete(tmpdir//"_lpddtrlst*",verify-)  
  }
  
  
## now apply ldedither to each image section. 
   ## avoid to use vertical correction per quadrant just in case it is selected
   lcvgradpars.quadran=no 
## The offsets will be determined from the central sections (2 or 3) and
## applied to the rest. 
   #  90 deg. pol.
   shiftref = mktemp(tmpdir//"_shiftref")
   match90 = match
   bdrx1 = lpgeodistpars.xstr90
   bdry1 = lpgeodistpars.ystr90
   if (verb1) 
      print("Processing image section with polarization at 90 deg.")
    ldedither("@"//proclist//"_90",outimg//"_90",match=match90,outsbsk=outsbsk,
         outshift=shiftref,outfltc=outfltc,outcorr=outcorr,cvgrad=cvgrad,
         subsky=subsky,inflat=flattmp_90,inmask=bpmask1_90,nditpts=nditpts1,
         intrans=gdisttmp_90,xstrech=bdrx1,ystrech=bdry1,psf=psf,adjshift=adjshift,
         zero=zero,scale=scale,combimg=no)

   
   #  0 deg. pol.
   match0 = shiftref       
   bdrx1 = lpgeodistpars.xstr0
   bdry1 = lpgeodistpars.ystr0
   if (verb1) 
      print("Processing image section with polarization at 0 deg.") 
   ldedither("@"//proclist//"_0",outimg//"_0",match=match0,outsbsk=outsbsk,	 
         outshift="",outfltc=outfltc,outcorr=outcorr,cvgrad=cvgrad,
         subsky=subsky,inflat=flattmp_0,inmask=bpmask1_0,nditpts=nditpts1,
	 intrans=gdisttmp_0,xstrech=bdrx1,ystrech=bdry1,psf=psf,adjshift=no,
         zero=zero,scale=scale,combimg=no) 

   #  135 deg. pol.
   match135 = shiftref
   bdrx1 = lpgeodistpars.xstr135
   bdry1 = lpgeodistpars.ystr135
   if (verb1) 
      print("Processing image section with polarization at 135 deg.") 
   ldedither("@"//proclist//"_135",outimg//"_135",match=match135,outsbsk=outsbsk,	 
         outshift="",outfltc=outfltc,outcorr=outcorr,cvgrad=cvgrad,
         subsky=subsky,inflat=flattmp_135,inmask=bpmask1_135,nditpts=nditpts1,
         intrans=gdisttmp_135,xstrech=bdrx1,ystrech=bdry1,psf=psf,adjshift=no,
         zero=zero,scale=scale,combimg=no) 

   #  45 deg. pol.
   match45 = shiftref
   bdrx1 = lpgeodistpars.xstr45
   bdry1 = lpgeodistpars.ystr45
   if (verb1) 
      print("Processing image section with polarization at 45 deg.") 
   ldedither("@"//proclist//"_45",outimg//"_45",match=match45,outsbsk=outsbsk,	 
         outshift="",outfltc=outfltc,outcorr=outcorr,cvgrad=cvgrad,
         subsky=subsky,inflat=flattmp_45,inmask=bpmask1_45,nditpts=nditpts1,
         intrans=gdisttmp_45,xstrech=bdrx1,ystrech=bdry1,psf=psf,adjshift=no,
         zero=zero,scale=scale,combimg=no) 

# now combine the image section from pol 90

if (combimg1) {
   ldedither(icombsuf//"@"//proclist//"_90",outimg//"_90",match=match90,
         outshift=shiftref,cvgrad=no,reject=reject,
         subsky="none",inflat="",inmask=bpmask1_90,nditpts=nditpts1,
         intrans="",psf=psf,adjshift=adjshift,
         zero=zero,scale=scale,combimg=yes,normexp=normexp)


   # now use the offsets from 90 degrees to combine the frames at 0, 45 and 135
   ## use the same shift file, here it is not considered if one or more files are discarded in the combination
   list2 = shiftref
   frcomb_90 = ""
   while (fscanf(list2,"%s %d %d",frcomb_90,xoff,yoff) != EOF) 
     {
       idrt = strldx("_90",frcomb_90) - 3 
       print(substr(frcomb_90,1,idrt)//"_0",>>comblist//"_0")
       print(substr(frcomb_90,1,idrt)//"_45",>>comblist//"_45")
       print(substr(frcomb_90,1,idrt)//"_135",>>comblist//"_135")      
     }
    

   ldedither("@"//comblist//"_0",outimg//"_0",match=shiftref,
         outshift=shiftref,cvgrad=no,reject=reject,
         subsky="none",inflat="",inmask=bpmask1_0,nditpts=nditpts1,
         intrans="",psf=psf,adjshift=no,
         zero=zero,scale=scale,combimg=yes,normexp=normexp)

   ldedither("@"//comblist//"_45",outimg//"_45",match=shiftref,
         outshift=shiftref,cvgrad=no,reject=reject,
         subsky="none",inflat="",inmask=bpmask1_45,nditpts=nditpts1,
         intrans="",psf=psf,adjshift=no,
         zero=zero,scale=scale,combimg=yes,normexp=normexp)

   ldedither("@"//comblist//"_135",outimg//"_135",match=shiftref,
         outshift=shiftref,cvgrad=no,reject=reject,
         subsky="none",inflat="",inmask=bpmask1_135,nditpts=nditpts1,
         intrans="",psf=psf,adjshift=no,
         zero=zero,scale=scale,combimg=yes,normexp=normexp)
}

delete(tmpdir//"_lpdocblst*",verify-)
delete(tmpdir//"_lpdoprlst*",verify-)
delete(tmpdir//"_lpddth*",verify-)
delete(tmpdir//"_shiftref*",verify-)  

end
