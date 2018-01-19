# lmoswavecal - compute wavelength calibration files
# Author : Jose Acosta  (jap@ll.iac.es)
# Version: 01. May. 2007
#          
##############################################################################
procedure lmoswavecal(input,fmaskpos)
string	input		{prompt="Arc input list"}
string	outroot		{prompt="Output root name for slitlets"}
string  fmaskpos	{prompt="File containing center of slitlets"}
string	coordlist	{"lirisdr$std/arxe.dat",prompt="Coordinate list"}
real	match		{30,prompt="Maximum difference for feature matching"}
string  database	{"database",prompt="Database in which to find feature data"}
string	specformat	{"lr_zj",enum="lr_zj|lr_hk|mr_k|hr_j|hr_h|hr_k",prompt="Grism used"}
int	nsum		{3,prompt="Number of lines to sum"}
int	nstep		{3,prompt="Step in lines for tracing an image"}
int	nlost 		{3,prompt="Maximum number of features which may be lost"}
bool	trimspec	{no,prompt="Trim frames?"}
bool	verbose		{yes,prompt="Verbose?"}

string *list1	{prompt="Ignore this parameter"}
# string *list2	{prompt="Ignore this parameter"}

begin	
  string 	fmaskpos1, inli, arclet, slttyp, slttyp1, sltid1, coordlist1, database1
  string	specformat1,idarclet1,lfiles
  string 	input1, outroot1,tempspec
  real		xc, cdelt, crval, crquad, crpix1, xoff, wstart, wend, gfwhm
  int		idumm, naxis1, naxis2	
  int		nsc,nsum1,nstep1,nlost1
  bool		verb1,trimspec1
  
  
  # expand input image list
  input1 = input
  outroot1 = outroot
  nsum1 = nsum
  nstep1 = nstep
  nlost1 = nlost

  verb1 = verbose
  trimspec1 = trimspec
    
  #sections(input,option="fullname", >inli)
  
 
  
  ## read and trim input arc if required
  if (trimspec1) {
    fmaskpos1 = fmaskpos
    if (!access(fmaskpos1)) 
      {
	print("ERROR: file ",fmaskpos1," does not exist")
	beep; beep; beep
	bye
      }     
    inli = mktemp("_lmswvclinput")	
    ltrimspec(input1,outroot1,fmaskpos1,outlist=inli,ismask=no)
  } else {
    inli = mktemp("_lmswvclin")
    sections(input1,>inli)
  }  
  
  coordlist1 = coordlist
  specformat1 = specformat
  database1 = database


  ## start loop over slitlets
  
  list1 = inli
#  list2 = fmaskpos1
  
  while (fscan(list1, arclet) != EOF) 
    {
        slttyp = "REF0"
	sltid1 = "CHECK"
	imgets(arclet,"i_naxis1")
	naxis1 = int(imgets.value)
	crpix1 = naxis1 / 2.
	imgets(arclet,"i_naxis2")
	naxis2 = int(imgets.value)
	xc = 0 
	imgets(arclet,"SLITID")
	idarclet = imgets.value
	imgets(arclet,"SLITXC")
	xc = real(imgets.value)
	
	lcentwave(specformat1,xc,crpix=crpix1)

        crval = lcentwave.crval 
	cdelt = lcentwave.cdelt
	
	## add info in the header 
	hedit(arclet,"CRVAL1",crval,ver-,upd+)
	hedit(arclet,"CDELT1",cdelt,ver-,upd+)
	hedit(arclet,"CRPIX1",crpix1,ver-,upd+)
	
	gfwhm = cdelt*2.5
        crquad= 0.
        # generate a ref spectrum 
	wstart = lcentwave.crval + (1-lcentwave.crpix)*lcentwave.cdelt
	wend = lcentwave.crval + (naxis1-lcentwave.crpix)*lcentwave.cdelt
	lfiles = "wavezj.dat"
	tempspec = mktemp("_lmstemp")
	print("writing template")
	mk1dspec(tempspec,ap=1,title="LMOS-template",ncols=naxis1,wstart=wstart,wend=wend,
	  continuum=0.,slope=0.,fnu=no,lines=lfiles,profile="gaussian",gfwhm=gfwhm)
	# call autoidentify based on the information provided by lcentwave
	aidpars.refspec=tempspec
        aidpars.crpix = lcentwave.crpix
	aidpars.crquad = crquad
	aidpars.reflist = "lirisdr$std/argon_ref.dat"
	aidpars.cddir = "sign"
	aidpars.aidord=3
        aidpars.ntarget = 20
	aidpars.nbins= 6
        if (verb1) {
 	  print ("  ")
	  print ("================================= ")
	  print ("arclet ",arclet)
	  print ("Doing wavelength calib. for slit id ",sltid1," using ",arclet)
	  print ("Slit center at col  ",xc)
	  print ("Ref. lambda is ",crval," at Ref pixel ",lcentwave.crpix)
	}
	print("Cdelt ",cdelt)
	print("crval ",crval)
	autoidentify(arclet,crval,cdelt,coordlist=coordlist1,section="middle line",
	    fwidth=5.,nsum=4,function="legendre",order=4,sample="*",niter=3,low_rej=3,
	    match=-20,high_rej=3.,dbwrite=yes,overwrite=yes,database=database1,threshold=500)

        # call reidentify
	reidentify(arclet,arclet,section="middle line",trace=yes,step=nstep1,nsum=nsum1,
	  nlost=nlost1,coordlist=coordlist1,inter+,newaps-) 
  
  
        # call fitcoords
	fitcoords(arclet,fitname="",interactive=yes,xorder=5,yorder=3)        

    } 
    

bye

noslitid: 
    print ("ERROR: slitid not found",idarclet)
  
end  
  
  
  	
