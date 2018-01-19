# lmksky - generate combined sky image from dither images 
# Author : JOse Acosta (jap@ll.iac.es)
# Version: 2. Nov. 2004
#        
#        
##############################################################################
procedure lmksky(input,outsky)
string	input		{"",prompt="Name of input dither images"}
string	outsky		{"",prompt="name of output sky image"}
string 	masktype	{"none",prompt="Type of pixel masking to use. (none|badvalue|goodvalue|!<keyword>)"}
int	maskval		{0,prompt="Mask value used with the masktype parameter"}
# Combining options
pset	skycomb		{prompt="Parameter set for sky image combination"}
string	scale		{"none",prompt="Scaling images before combination (none|mode|median|mean|<keyword>)"} 
string	zero		{"median",prompt="Add zero offset before combination (none|mode|median|mean|<keyword>)"} 
string	reject		{"none",enum="none|minmax|ccdclip|crreject|sigclip|avsigclip|pclip",prompt="Type of rejection"}
int	nlow		{0,prompt="Number of low pixels to reject"}
int	nhigh		{0,prompt="Number of high pixels to reject"}
int	nkeep		{2,prompt="Minimum to keep (pos) or maximum to reject (neg)"}
string	statsec		{"",prompt="Image region to compute statistics"}

# Directories
string	tmpdir		{")_.tmpdir",prompt="Temporary directory for file conversion"}

#string	scale		{"none",prompt="Scale images (none|mode|median|mean|<keyword>)"}
bool	verbose		{no,prompt="Verbose"}
  
string *list1	{prompt="Ignore this parameter(list1)"}
string *list2	{prompt="Ignore this parameter(list2)"}
  
begin  
  
  string	skyli

  # expand input image name.
  skyli = mktemp(tmpdir//"_ldithskyinli")
  sections(input,option="fullname",> skyli)
  
    
  # combine sky input images if necessary or combine 
  # input images to create sky image
  if (verbose)
    {
      print ""
      print "Combining images to compute sky image ...."
      if (lmksky.reject == "minmax")
        {
	print "INFO: number of rejected pixels is "
	print "	       lower = "//nlow
	print "	       upper = "//nhigh
	print "	       nkeep = "//skycomb.nkeep
	}
      else
        {
	print "INFO: no minmax pixel rejection"
	}
    }
 
   print ""   
   print "List de imagenes a combinar "
   type (skyli)
   imcombine (input = "@"//skyli,
    	     output = outsky,
	      rejmask = "",
###		       plfile = "",  ## not valid in iraf 2.12.2
		 sigma = "",
	       logfile = "STDOUT",
		 combine = liskycpars.combine,
		 reject = reject,
		project = no,
		outtype = "real",
		offsets = "",
	       masktype = masktype,
	      maskvalue = maskval,
		  blank = 0.,
		  scale = scale,
		   zero = zero,
		 weight = "none",
		statsec = statsec,
		expname = "",
	     lthreshold = INDEF,
	     hthreshold = INDEF,
		    nlow = nlow,
		   nhigh = nhigh,
		   nkeep = nkeep,
		   mclip = yes,
		  lsigma = liskycpars.lsigma,
		  hsigma = liskycpars.hsigma,
		 rdnoise = liskycpars.rdnoise,
		    gain = liskycpars.gain,
		  snoise = liskycpars.snoise,
		sigscale = liskycpars.sigscale,
		   pclip = liskycpars.pclip,
		     grow = liskycpars.grow)
    

  # Deleting temporary files.  
  delete (skyli,yes,ver-)


end  

