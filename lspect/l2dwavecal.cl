# l2dwavecal - compute wavelength calibration files
# Author : Jose Acosta  (jap@ll.iac.es)
# Version: 01. May. 2007
#          
##############################################################################
procedure l2dwavecal(input)
string	input		{prompt="Arc input list"}
string	outroot		{prompt="Output root name for slitlets"}
string	coordlist	{"lirisdr$std/arxe.dat",prompt="Coordinate list"}
string 	section		{"middle line",prompt="Section to the extraction along spatial axis"}
real	match		{30,prompt="Maximum difference for feature matching"}
real	threshold	{0,prompt="Feature threshold for centering"}
int	nsum		{10,prompt="Number of lines to sum along spatial axis"}
string  database	{"database",prompt="Database in which to find feature data"}
string	specformat	{"lr_zj",enum="lr_zj|lr_hk|mr_k|hr_j|hr_h|hr_k",prompt="Grism used"}
bool	verbose		{yes,prompt="Verbose?"}

string *list1	{prompt="Ignore this parameter"}
# string *list2	{prompt="Ignore this parameter"}

begin	
  string 	inli, arclet, slttyp, slttyp1, sltid1, coordlist1, database1
  string	specformat1,idarclet1,lfiles
  string 	input1, outroot1,tempspec,section1
  real		xc, cdelt, crval, crquad, crpix0, xoff, wstart, wend, gfwhm,threshold1
  int		idumm, naxis1, naxis2, nsum1	
  bool		verb1
  
  
  # expand input image list
  input1 = input
  outroot1 = outroot

  verb1 = verbose
    
  
  coordlist1 = coordlist
  specformat1 = specformat
  database1 = database
  nsum1 = nsum
  threshold1 = threshold
  section1 = section


  ## start loop over slitlets
  
  
        slttyp = "REF0"
	sltid1 = "CHECK"
	imgets(input1,"i_naxis1")
	naxis1 = int(imgets.value)
	imgets(input1,"i_naxis2")
	naxis2 = int(imgets.value)
	xc = 530.
	lcentwave(specformat1,xc,crpix=naxis1/2.)

        crval = lcentwave.crval 
	cdelt = lcentwave.cdelt
	gfwhm = cdelt*2.5
        crquad= -0.1e-5
        # generate a ref spectrum 
	wstart = lcentwave.crval + (1-lcentwave.crpix)*lcentwave.cdelt
	wend = lcentwave.crval + (naxis1-lcentwave.crpix)*lcentwave.cdelt
	lfiles = "wavezj.dat"
	tempspec = mktemp("_lmstemp")
	mk1dspec(tempspec,ap=1,title="LMOS-template",ncols=naxis1,wstart=wstart,wend=wend,
	  continuum=0.,slope=0.,fnu=no,lines=lfiles,profile="gaussian",gfwhm=gfwhm)
	# call autoidentify based on the information provided by lcentwave
	aidpars.refspec= tempspec
	print ("crpix ",lcentwave.crpix)
	print ("crval ",lcentwave.crval)
	print ("cdelt ",lcentwave.cdelt)
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
	  print ("Input image ",input1)
	  print ("Slit center at col  ",xc)
	  print ("Ref. lambda is ",crval," at Ref pixel ",lcentwave.crpix)
	}
	hedit(input1,"CRVAL1",lcentwave.crval,upd+,ver-)
	hedit(input1,"CD1_1",lcentwave.cdelt,upd+,ver-)
	hedit(input1,"CRPIX1",lcentwave.crpix,upd+,ver-)
	autoidentify(input1,crval,cdelt,coordlist=coordlist1,section="middle line",
	    fwidth=5.,nsum=nsum1,function="legendre",order=4,sample="*",niter=3,low_rej=3,
	    match=-20,high_rej=3.,dbwrite=yes,overwrite=yes,database=database1,threshold=threshold1)

        # call reidentify
	reidentify(input1,input1,section=section1,trace=yes,step=nsum1,nsum=nsum1,
	  nlost=4,coordlist=coordlist1,inter+) 
  
  
        # call fitcoords
	fitcoords(input1,fitname="",interactive=yes,xorder=5,yorder=3)        
    

bye

noslitid: 
    print ("ERROR: slitid not found",idarclet)
  
end  
  
  
  	
