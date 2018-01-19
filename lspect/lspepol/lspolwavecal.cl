# lspolwavecal - compute wavelength calibration files for spectropolarimetry
# Author : Jose Acosta  (jap@ll.iac.es)
# Version: 15. Jun. 2010
#          
##############################################################################
procedure lspolwavecal(input,ftrimsec)
string	input		{"",prompt="Arc input list"}
string	out		{"",prompt="Output prefix for sliced images"}
string  ftrimsec	{")_.ftrimsec",prompt="File containing trim sections"}
string	coordlist	{"lirisdr$std/arxe.dat",prompt="Coordinate list"}
real	match		{30,prompt="Maximum difference for feature matching"}
string  database	{"database",prompt="Database in which to find feature data"}
bool	slicespec	{yes,prompt="Slice spectra?"}
bool	verbose		{yes,prompt="Verbose?"}

string *list1	{prompt="Ignore this parameter"}
# string *list2	{prompt="Ignore this parameter"}

begin	
  string 	ftrimsec1, inli, arclet, slttyp, slttyp1, sltid1, coordlist1, database1
  string	idarclet1,lfiles
  string 	input1, outroot1,tempspec,arcsec[4]
  real		xc, cdelt, crval, crquad, crpix1, xoff, wstart, wend, gfwhm
  int		idumm, naxis1, naxis2, isec	
  int		nsc
  bool		verb1,trimspec1
  
  
  # expand input image list
  input1 = input
  outroot1 = out

  verb1 = verbose
  trimspec1 = slicespec
    
  #sections(input,option="fullname", >inli)
  
 
  
  ## read and trim input arc if required
  if (trimspec1) {
    ftrimsec1 = ftrimsec
    if (!access(ftrimsec1)) 
      {
	print("ERROR: file ",ftrimsec1," does not exist")
	beep; beep; beep
	bye
      }     
    inli = mktemp("_lspwvclinput")
    if (verb1) print("slicing images")	
    lfilename(input1)
    outroot1 = out//lfilename.root
    ltrimspol(input1,outroot1,ftrimsec1,outlist=inli,ismask=no)
  } else {
    inli = mktemp("_lspwvclin")
    sections(input1,>inli)
  }  
  
  coordlist1 = coordlist
  database1 = database

  ## start loop over polarization stages, identify each section 
  
  list1 = inli
  
  while (fscan(list1, arclet) != EOF) 
    {
        
	imgets(arclet,"i_naxis1")
	naxis1 = int(imgets.value)
	crpix1 = naxis1 / 2.
	imgets(arclet,"i_naxis2")
	naxis2 = int(imgets.value)
	imgets(arclet,"LPOLVECT")
	isec = int(imgets.value)
	
	switch (isec) {
	  case 0: 
             {
               arcsec[1] = arclet
               if (verb1) print ("Selecting pol. vect 0 ")
             }  
	  case 90:
             {
               arcsec[2] = arclet
               if (verb1) print ("Selecting pol. vect 90 ")
             }  
	  case 135:
             {
               arcsec[3] = arclet
               if (verb1) print ("Selecting pol. vect 135 ")
             }  
	  case 45: 
             {
               arcsec[4] = arclet
               if (verb1) print ("Selecting pol. vect 45 ")
             }  
	  default: 
             {
	       print("Error: not possible to identify polarization stage")
	       bye
	     }     
        }

    }
	
	
	## add info in the image header
	#laddwave() 	

        ## pol 0, 90, 135, 45
        for (i=1; i <=4; i +=1)
        {
           identify(arcsec[i],section="middle line",coordlist=coordlist1,function="legendre", 
             order=4,niter=0,nsum=10,database=database1)
 
           ## extend wavelength calibration to other regions and pol. vectors call reidentify
           reidentify(arcsec[i],arcsec[i],newaps=yes,refit=yes,override=no,nlost=3)

           fitcoords(arcsec[i],fitname="",xorder=4,yorder=3,database=database1)
        }
        

        ## if (verb1) {
 	##   print ("  ")
	##   print ("================================= ")
	##   print ("arclet ",arclet)
	##   print ("Doing wavelength calib. for slit id ",sltid1," using ",arclet)
	##   print ("Slit center at col  ",xc)
	##   print ("Ref. lambda is ",crval," at Ref pixel ",lcentwave.crpix)
	## }
  
## clean up
delete(inli,>dev&null)


bye


  
end  
  
