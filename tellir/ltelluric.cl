# ltelluric - correct tellurique lines 
# Author : Miguel Charcos (mcharcos@ll.iac.es)
# Version: 17. Feb. 2004
##############################################################################
procedure ltelluric(input,output,instar)

string	input		{prompt="Input list of images to correct"}
string	output		{prompt="Name list of corrected image"}
string	instar		{prompt="Input star image"}

string	outfunct	{prompt="Name of correction function"}

real	temperature	{5000,prompt="Temperature of input star"}

string	susttype	{"divition",prompt="Type of sustraction (divition|telluric)"}
# blackbody pset configuration
pset 	teluropt	{prompt="mk1dspec parametre configuration"}

bool	verbose		{no,prompt="Verbose?"}
bool	internorm	{no,prompt="Check interactively normalisation interval"}
bool	intertel	{no,prompt="Check interactively telluric correction"}

# Directories
string	tmpdir		{")_.tmpdir",prompt="Temporary directory for file conversion"}
string	stddir		{")_.stddir",prompt="Parametre directory"}


struct 	*list1		{prompt="Ignore this parametre (list1)"}
struct 	*list2		{prompt="Ignore this parametre (list2)"}

begin

  string	inli,outli,inst,outf
  string 	fname,corfunct,imout,imaux
  
  int		dispax,spctax,i,numspct,dispnum
  string 	interv
  int		b1,b2
  	 
  real	airmass,threshold,lag,shift,scale,dshift,dscale,offset,smooth
  bool	ignoreaps,xcorr,tweakrms
  string	sample,answer
	   
  
  inli = mktemp (tmpdir//"ltelluricinli")
  sections (input,option="fullname",>inli)

  outli = mktemp (tmpdir//"ltelluricoutli")
  sections (output,option="fullname",>outli)
  # Check if output images already exist
  list1 = outli
  While (fscan(list1,fname) != EOF)
    {
    imgaccess(fname,ver-)
    if (imgaccess.exists)
      {
      beep
      print("")
      print("ERROR: "//fname//" image already exists")
      print("ltelluric aborted")
      print("")
      beep
      bye
      }
    } # End of While (fscan(list1=outli,fname) != EOF)
  
  outf = outfunct
  imgaccess(outf,ver-)
  if (imgaccess.exists == yes)
    {
    print("WARNING: "//outf//" image already exists")
    print("         image will not be saved")
    outf = ""
    }
  inst = instar
  imgaccess(inst,ver-)
  if (imgaccess.exists == no)
    {
    beep
    print("")
    print("ERROR: "//inst//" image does not exist")
    print("ltelluric aborted")
    print("")
    beep
    bye
    }
  
  #################################################################
  #  Calcule telurique correction function
  #----------------------------------------------------------------
  corfunct = mktemp (tmpdir//"ltelluriccorfunct")
  lfcalib (input = inst,
         outtel = corfunct,
          outbb = "",
        outnorm = "",
    temperature = temperature,
        verbose = verbose,
      internorm = internorm,
         tmpdir = tmpdir,
         stddir = stddir)  
  
  
  #################################################################
  #  Search shift between telluric star bands and telluric stars
  #----------------------------------------------------------------
  list1 = inli
  While (fscan(list1,fname) != EOF)
    {
    if (verbose) print "searching shift of image "//fname//" ..."
    
    } 
  
  
  
  #################################################################
  #  Correct spectra images
  #----------------------------------------------------------------
  
  
  list1 = inli
  list2 = outli
  While (fscan(list1,fname) != EOF && fscan(list2,imout) != EOF)
    {
    
    lhgets(fname,param="i_naxis")
    if (lhgets.value == "1")
      {
	if (verbose) 
	  {print "Correcting single spectra ..."}
	
	
      if (susttype == "telluric")
        {
	telluric ( input = fname,
                output = imout,
                   cal = corfunct,
               airmass = 1.,
                answer = "yes",
             ignoreaps = no,
                 xcorr = yes,
              tweakrms = yes,
           interactive = intertel,
                sample = "*",
             threshold = 0.1,
                   lag = 10,
                 shift = 0.1,
                 scale = 1.,
                dshift = 0.1,
                dscale = 0.2,
                offset = 1.,
                smooth = 1,
                cursor = "")
	}
      else if (susttype == "divition")
        {  
   	imcalc ( input = fname//","//corfunct,
   	   output = imout,
   	   equals = "im1/im2",
   	  pixtype = "old",
   	  nullval = 1.,
   	  verbose = no)
	}
      }
    else
      {
	if (verbose) 
	  {print "Correcting extend spectra ..."}
	
      lcheckfile(fname,ver-)
      if (lcheckfile.format == "ImpB") dispax = 2
      else if (lcheckfile.format == "UDAS") dispax = 1
      else if (lcheckfile.format == "UNIC") dispax = 1
      else if (lcheckfile.format == "unknown") dispax = 2
      
	if (dispax == 1) spctax = 2
	else spctax = 1
	
	lhgets(fname,param="i_naxis"//spctax)
      numspct = int(lhgets.value)
	
	lhgets(fname,param="i_naxis"//dispax)
      dispnum = int(lhgets.value)
	
  	if (dispax == 1)
  	  {
  	  b1 = 1
  	  b2 = 1024
  	  }
  	else if (dispax == 2)
  	  {
  	  b1 = 1024
  	  b2 = 1
  	  }
  	else
  	  {
  	  if (verbose)
  	    {
  	    print "WARNING: Dispertion axis have not be found"
  	    print " 	  default dispertion axis is 1"
  	    }
  	  b1 = 1
  	  b2 = 1024
  	  }
 
      imaux = mktemp (tmpdir//"ltelluricimaux")
  	blkavg ( input = fname,
  		  output = imaux,
    			b1 = b1,
    			b2 = b2,
    		  option = "average")
	
      if (susttype == "telluric")
        {
	telluric ( input = imaux,
                output = imaux,
                   cal = corfunct,
               airmass = 1.5,
                answer = "yes",
             ignoreaps = no,
                 xcorr = yes,
              tweakrms = yes,
           interactive = intertel,
                sample = "*",
             threshold = 0.1,
                   lag = 10,
                 shift = 0.1,
                 scale = 1.,
                dshift = 0.1,
                dscale = 0.2,
                offset = 1.,
                smooth = 1,
                cursor = "")
      imdelete (imaux,yes,ver-)
	
      ignoreaps = telluric.ignoreaps
      xcorr = telluric.xcorr
      tweakrms = telluric.tweakrms
      sample = telluric.sample
      threshold = telluric.threshold
      lag = telluric.lag
      shift = telluric.shift
      scale = telluric.scale
      dshift = telluric.dshift
      dscale = telluric.dscale
      offset = telluric.offset
      smooth = telluric.smooth
	
	if (verbose)
	  {
	  print "ignoreaps = "//ignoreaps
	  print "xcorr     = "//xcorr
	  print "tweakrms  = "//tweakrms
	  print "sample    = "//sample
	  #print "threshold = "//threshold
	  print "lag       = "//lag
	  print "shift     = "//shift
	  print "scale     = "//scale
	  print "dshift    = "//dshift
	  print "dscale    = "//dscale
	  print "offset    = "//offset
	  print "smooth    = "//smooth
	  }
	
	imarith (operand1 = fname,
                     op = "-",
               operand2 = fname,
                 result = imout,
                  title = "",
                divzero = 0.,
                hparams = "",
                pixtype = "",
               calctype = "",
                verbose = no,
                  noact = no)
	
	for (i=1;  i <= numspct ;  i += 1)
        {
	  if (dispax == 1)
	    {
	    interv = "[1:"//dispnum//","//i//"]"
	    }
	  else
	    {
	    interv = "["//i//",1:"//dispnum//"]"
	    }
	  
	      
        imaux = mktemp (tmpdir//"ltelluricimaux")
	  
	  telluric ( input = fname//interv,
            	output = imaux,
            	   cal = corfunct,
                 airmass = 1.5,
            	answer = "yes",
               ignoreaps = ignoreaps,
            	 xcorr = no,
                tweakrms = no,
             interactive = no,
            	sample = sample,
               threshold = threshold,
            	   lag = lag,
            	 shift = shift,
            	 scale = scale,
            	dshift = 0,
            	dscale = 0,
            	offset = offset,
            	smooth = smooth,
            	cursor = "")
	  
	  imcopy (imaux,imout//interv,ver+)
        imdelete (imaux,yes,ver-)
	  } # End of for (i=1;  i <= numspct ;  i += 1)
        }
      else if (susttype == "divition")
        { 
        #imaux = mktemp (tmpdir//"ltelluricimaux")
        #imcalc ( input = fname//interv//","//corfunct,
        #        output = imaux,
        #        equals = "im1/im2",
        #       pixtype = "old",
        #       nullval = 1.,
        #       verbose = no) 
	
	sarith (input1 = fname,
                    op = "/", 
                input2 = corfunct,
                output = imout,
                    w1 = INDEF,
                    w2 = INDEF,
             apertures = "",
                 bands = "",
                 beams = "",
             apmodulus = 0,
               reverse = no,
             ignoreaps = yes,
                format = "multispec",
              renumber = no,
                offset = 0,
               clobber = no,
                 merge = no,
                 rebin = yes,
                errval = 0.,
               verbose = no)  
        } 
      }
    
    } # End of While (fscan(list1=outli,fname) != EOF)
    
  
  if (verbose) print "ltelluric finished"  
  #################################################################
  #  Correct spectra images
  #----------------------------------------------------------------
  delete(inli,yes,ver-)
  delete(outli,yes,ver-)
  
  if ( outf == "" )
    imdelete(corfunct,yes,ver-)
  else 
    imrename(corfunct,outf,ver-)

  list1 = ""
  list2 = ""
  
end
