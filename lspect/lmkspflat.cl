# lmkspflat - generate combined image from dither
#             could make two ldedither iteration using star mask in the second
# 		step
#  	      The non-linear pixel mask can be derived
# Author : Jose Acosta (jap@ll.iac.es)
# Version: 15. Oct. 2010
##############################################################################
procedure lmkspflat (iflatbr, nflat)

string	iflatbr		{prompt="File list of bright flat field images"}
string	iflatdk		{prompt="File list of dark flat field images"}
string	nflat		{"Nflat",prompt="Name of normalize flat"}
string  flatdk		{"Flatdk",prompt="Name of dark flat"}
string  flatbr 		{"Flatbr",prompt="Name of bright flat"}
string  combine		{"median",prompt="Type of combine operation"}
string	scale		{"median",prompt="Image scaling"}
string	reject		{"ccdclip",enum="none|minmax|ccdclip",prompt="Type of rejection"}
string  gain		{"5.5",prompt="ccdclip: gain (electrons/ADU)"}
string  rdnoise		{"13",prompt="ccdclip: readout noise (electrons)"}
bool	corrow		{no,prompt="Correct bad pixel mapping?"}
string  outrow		{"c",prompt="prefix of image with pixel mapping corrected"}

bool	interactive	{yes,prompt="Fit normalization spectrum interactively?"}
real 	threshold	{INDEF,prompt="Response threshold"}
string	function	{"spline3",enum="spline3|legendre|chebyshev|spline1",prompt="Fitting function"}
int	order		{1,prompt="Order of fitting function"}
real	high_reject	{0.,prompt="Low rejection in sigma of fit"}
real	low_reject	{0.,prompt="High rejection in sigma of fit"}
int	niterate	{0,prompt="Number of rejection iterations"}	
bool    verbose 	{yes,prompt="Verbose"}

# Directories
string  tmpdir  {")_.tmpdir",prompt="Temporary directory for file conversion"}

begin

string	inlibr,inlidk,corrowlibr,corrowlidk,prepostlibr,prepostlidk
string 	nflattmp,ofltdk,ofltbr,rfunct1
real	threshold1,hr1,lr1
int	niter1,order1 
bool 	origcpixprepost,interactive1
  
  niter1 = niterate
  threshold1 = threshold
  hr1 = high_reject
  lr1 = low_reject 
  rfunct1 = function
  order1 = order
  interactive1 = interactive
  
  # expand input image names.
  inlibr = mktemp(tmpdir//"lmkfltinbr")
  sections(iflatbr,option="fullname",> inlibr)
  
  if (iflatdk != "") 
    {
      inlidk = mktemp(tmpdir//"lmkfltindk")
      sections(iflatdk,option="fullname",> inlidk)
    }
     
  ##########################################################
  # Correction of pixel mapping problem
  #---------------------------------------------------------
  if (corrow)
    {

    if (verbose)
      {
      print ""
      print "correcting bad rows and lines..."
      } 
      
    corrowlibr = mktemp(tmpdir//"_lmkfltcrowlibr")
    corrowlidk = mktemp(tmpdir//"_lmkfltcrowlibr")
    if (outrow == "")
      {
      lcpixmap (input = "@"//inlibr,     
               output = "lmkfcrow_", 
              outlist = corrowlibr,   
              verbose = verbose,
	       tmpdir = tmpdir)
      if (iflatdk != "")
        { 
          lcpixmap (input = "@"//inlidk,     
                   output = "lmkfcrow_", 
                  outlist = corrowlidk,   
                  verbose = verbose,
	           tmpdir = tmpdir)	
	}              
      }
    else
      {
      lcpixmap (input = "@"//inlibr,     
               output = outrow, 
              outlist = corrowlibr,   
              verbose = verbose,
	       tmpdir = tmpdir)
      if (iflatdk != "")
        { 
          lcpixmap (input = "@"//inlidk,     
                   output = outrow, 
                  outlist = corrowlidk,   
                  verbose = verbose,
	           tmpdir = tmpdir)	
	}              
	       
      }
      
    origcpixprepost = lcpixmap.original

    }    
  else 
    {
    if (verbose)
      {
      print ""
      print "INFO: No need to correct wrong pixel mapping"
      print ""
      }
    corrowlibr = inlibr
    if (iflatdk != "") 
       corrowlidk = inlidk
    else 
       corrowlidk = ""   
    origcpixprepost = yes
    }
  
  #---------------------------------------------------------
  # End of bad row correction
  ##########################################################
    
  # --------------------------------------------------------------------
  #  Verify image format and perfom pre-post treatment if necesary
  #  Image result can be unique format
  # --------------------------------------------------------------------
  # Check if they are already pre read subtracted images containing a wcs
  if (verbose)
    {
    print ""
    print "verification of image format"
    }
  
   prepostlibr = mktemp(tmpdir//"lmkfppli")
   prepostlidk = mktemp(tmpdir//"lmkfppli")
  
   llistdiff (input = "@"//corrowlibr,         
              output = prepostlibr,             
               pname = mktemp("lmkf")//"_",     
             verbose = verbose,
              tmpdir = tmpdir)
	      
   if (iflatdk != "") 
      llistdiff (input = "@"//corrowlidk,         
                output = prepostlidk,             
                 pname = mktemp("lmkf")//"_",     
               verbose = verbose,
                tmpdir = tmpdir)	      

 
  if (verbose)
    {
    print "image format verified"
    print ""
    }

# create an intermediate flat, not normalized
  nflattmp = mktemp(tmpdir//"lmkfltntmp")

# combine bright and dark flats
  if (flatbr != "")
    ofltbr = mktemp(tmpdir//"_lmkofltbr")
  else 
    ofltbr = flatbr  
  imcombine ("@"//prepostlibr,flatbr,headers="",bpmasks="",rejmasks="",
    nrejmasks="",expmasks="",sigmas="",combine=combine,reject=reject,
    project=no,offsets="",masktype="none",scale=scale,zero="none",statsec="")

  if (iflatdk != "") 
    {
      if (flatdk != "")
	ofltdk = mktemp(tmpdir//"_lmkofltbr")
      else 
	ofltdk = flatdk  
      imcombine ("@"//prepostlidk,flatdk,headers="",bpmasks="",rejmasks="",
        nrejmasks="",expmasks="",sigmas="",combine=combine,reject=reject,
        project=no,offsets="",masktype="none",scale=scale,zero="none",statsec="",
        gain=gain,rdnoise=rdnoise)
      imarith (flatbr,"-",flatdk,nflattmp)
    }
   else
      imcopy (flatbr,nflattmp,ver-) 
  
     
   ## final step is to normalize using the task response
   response(nflattmp,nflattmp,nflat,interactive=interactive1,
     threshold=threshold,sample="*",function=rfunct1,order=order1,
     niterate=niter1,low_reject=lr1,high_reject=hr1)
    
   ## clean up 
   delete(inlibr,ver-,>>& "/dev/null")  
   delete(prepostlibr,ver-,>>& "/dev/null")
   imdel(nflattmp,ver-,>>& "/dev/null")
   if (flatbr == "")
      imdel(ofltbr,ver-,>>& "/dev/null")
   if (iflatdk != "") 
     {
       delete(inlidk,ver-,>>& "/dev/null")
       delete(prepostlidk)
       if (flatdk == "")
         imdel(ofltdk,ver-,>>& "/dev/null")
     }
     

  bye
  

end