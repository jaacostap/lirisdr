# lspctcombine - combine spectral images considering AB cases
# Author : Miguel Charcos (mcharcos@ll.iac.es)
# Version: 09. Jun. 2004
##############################################################################
procedure lspctcombine(input,output)

string	input		{prompt="List of images to combine"}
string	output		{prompt="Output image"}
string	outspectr	{"",prompt="Prefix of result spectres"}
string	outlist		{"",prompt="Name of spectra list"}

string	combine		{"average",enum="average|median",prompt="Type of combine operation"}

# Spectral caracteristics
string	typespct	{"AB",enum="single|AB",prompt="Type of spectral image (single|AB)"}
int 	line		{INDEF,prompt="Dispersion line"}
int	nsum		{10,prompt="Number of dispersion lines to sum or median"}

# apall parametres
pset	combapall	{prompt="Apall configuration parametres"}

# combine parametres
pset	combspct	{prompt="Imcombine configuration parametres"}

string  tmpdir  	{")_.tmpdir",prompt="Temporary directory for file conversion"}
string  stddir  	{")_.stddir",prompt="Parametre directory for transformations"}

bool	intersel	{yes,prompt="Interactive spectral selection"}
bool	interap		{no,prompt="Interactive spectral extraction"}
bool	verbose		{no,prompt="Verbose?"}

string *list1	{prompt="Ignore this parameter(list1)"}

begin

  string	ino,outspct
  string	fname,iminv
  string	logf
  string	tmpl,inli,invli,totli,apli,apliaux,redli,outli,resultli
  string	offset
  int		nsc,b1,b2
  
      
  ######
  # Analyse of option choosen
  ######
  
  # decide if to show output
  if ( verbose )
    logf = "STDOUT"
  else
    logf = ""
    
  
  
  ######
  # Verification of correct input variables
  ######
  
  # expand input and output image names.
  inli = mktemp(tmpdir//"lspctcombineinli")
  sections(input,option="fullname", > inli)
  
  ino = output
  outspct = outspectr
  outli = outlist
  
  # expand output image name.
  tmpl = mktemp(tmpdir//"lspctcombine")
  sections(ino,option="fullname",> tmpl)
  list1 = tmpl
  nsc = fscan(list1, fname)
  delete(tmpl,yes,verify=no)

  # check if output image exists
  limgaccess(fname//"*", verbose=no)
  if ( limgaccess.exists )
    {
    beep
    print("")
    print("ERROR: operation would override output file "//fname)
    print("lspectr aborted")
    print("")
    beep
    bye
    }

  
  ###############################################
  # Variables verified. Start program.
  ###############################################
  
  # We look for the dispertion axis
  list1 = inli
  nsc = fscan(list1,fname)
  imgets(image=fname,param="DISPAXIS")
    
  if (imgets.value == "1")
    {
    if (verbose) print "INFO: Dispertion axis is "//imgets.value
    b1 = 1024
    b2 = 1
    }
  else if (imgets.value == "2")
    {
    if (verbose) print "INFO: Dispertion axis is "//imgets.value
    b1 = 1
    b2 = 1024
    }
  else 
    {
    if (verbose) 
      {
      print "WARNING: Dispertion axis have not be found"
      print "	      default dispertion axis is 2"
      }
    b1 = 1
    b2 = 1024
    }
  
  
  # If spectral type is AB spectra A and spectra B are separated and new list
  # created spectra A and B mixed.
  if (typespct != "single")
    {
    invli = mktemp (tmpdir//"lspctcombineinvli")
    totli = mktemp (tmpdir//"lspctcombinetotli")
    resultli = mktemp (tmpdir//"lspctcombineresultli")
    list1 = inli
    While (fscan(list1,fname) != EOF)
      {
      lfilename(fname)
      iminv = mktemp(tmpdir//"lspctcombineiminv")//"_"//lfilename.reference//"B"
      imcalc (input = fname,
     	     output = iminv,
     	     equals = "-im1",
     	    pixtype = "old",
     	    nullval = 0.,
     	    verbose = verbose)
      
      print(iminv,>> invli)
      print(fname,>> totli)
      print(iminv,>> totli)
      print(fname//"A",>> resultli)
      print(iminv,>> resultli)
      
      } # end of While (fscan(list1=inli,fname) != EOF)
    
    }
  else 
    {totli = inli}
  
  # We extract A and B spectra 
  if (outspct == "") 
    outspct = mktmp ("lspctcombineimap")
  
  apli = mktemp (tmpdir//"lspctcombineapli")
  lnamelist (input = "@"//totli,
  	    output = apli,
  	     bname = "",
  	     pname = outspct,
  	   refname = "@"//totli,
  	    extens = "fits",
  	    maxnum = INDEF,
  	    tmpdir = tmpdir)
    
  apall (input = "@"//totli,
	 nfind = 1,
     	output = "@"//apli,
     apertures = "",
     	format = "strip",
    references = "",
      profiles = "",
   interactive = interap,
     	  find = combapall.find,
      recenter = combapall.recenter,
     	resize = combapall.resize,
     	  edit = combapall.edit,
     	 trace = combapall.trace,
      fittrace = combapall.fittrace,
       extract = combapall.extract,
     	extras = combapall.extras,
     	review = combapall.review,
     	  line = line,
     	  nsum = nsum,
     	 lower = combapall.lower,
     	 upper = combapall.upper,
     apidtable = combapall.apidtable,
    b_function = combapall.b_function,
       b_order = combapall.b_order,
      b_sample = combapall.b_sample,
    b_naverage = combapall.b_naverage,
    b_niterate = combapall.b_niterate,
  b_low_reject = combapall.b_low_reject,
  b_high_rejec = combapall.b_high_rejec,
     	b_grow = combapall.b_grow,
     	 width = combapall.width,
     	radius = combapall.radius,
     threshold = combapall.threshold,
     	minsep = combapall.minsep,
     	maxsep = combapall.maxsep,
     	 order = combapall.order,
    aprecenter = combapall.aprecenter,
     	npeaks = combapall.npeaks,
     	 shift = combapall.shift,
     	llimit = combapall.llimit,
     	ulimit = combapall.ulimit,
     	ylevel = combapall.ylevel,
     	  peak = combapall.peak,
     	   bkg = combapall.bkg,
     	r_grow = combapall.r_grow,
     avglimits = combapall.avglimits,
     	t_nsum = combapall.t_nsum,
     	t_step = combapall.t_step,
       t_nlost = combapall.t_nlost,
    t_function = combapall.t_function,
       t_order = combapall.t_order,
      t_sample = combapall.t_sample,
    t_naverage = combapall.t_naverage,
    t_niterate = combapall.t_niterate,
  t_low_reject = combapall.t_low_reject,
  t_high_rejec = combapall.t_high_rejec,
     	t_grow = combapall.t_grow,
    background = combapall.background,
     	skybox = combapall.skybox,
       weights = combapall.weights,
     	  pfit = combapall.pfit,
     	 clean = combapall.clean,
    saturation = combapall.saturation,
     readnoise = combapall.readnoise,
     	  gain = combapall.gain,
     	lsigma = combapall.lsigma,
     	usigma = combapall.usigma,
       nsubaps = combapall.nsubaps)

  apliaux = mktemp (tmpdir//"lspctcombineapliaux") 
  lnamelist (input = "@"//totli,
  	    output = apliaux,
  	     bname = "",
  	     pname = outspct,
  	   refname = "@"//totli,
  	    extens = "0001.fits",
  	    maxnum = INDEF,
  	    tmpdir = tmpdir)
  imrename ("@"//apliaux,"@"//resultli,ver-)
  delete (apliaux,yes,ver-)
  
  # We select interactively spectra if option choosen
  # and we calculate offset between spectra
  if (outli == "") redli = mktemp (tmpdir//"lspctcombineredli")
  else redli = outli
    
  offset = mktemp(tmpdir//"lspctcombineoffset")
  lspctoffset ( input = "@"//resultli,
               output = redli,
              offsetf = offset,
     	      predisp = intersel,
    	     postdisp = no,
	      verbose = verbose,
               tmpdir = tmpdir) 
    
  # We combine images
  imcombine (input = "@"//redli,
  	    output = ino,
  	   rejmask = "",
#  	    plfile = combspct.plfile,  # not valid for IRAF v2.12.2
  	     sigma = combspct.sigma,
  	   logfile = logf,
  	   combine = combine,
  	    reject = combspct.reject,
  	   project = no,
  	   outtype = combspct.outtype,
  	   offsets = offset,
  	  masktype = "none",
  	 maskvalue = 0.,
  	     blank = 0.,
  	     scale = combspct.scale,
  	      zero = combspct.zero,
  	    weight = combspct.weight,
  	   statsec = combspct.statsec,
  	   expname = combspct.expname,
  	lthreshold = INDEF,
  	hthreshold = INDEF,
  	      nlow = combspct.nlow,
  	     nhigh = combspct.nhigh,
  	     nkeep = combspct.nkeep,
  	     mclip = no,
  	    lsigma = combspct.lsigma,
  	    hsigma = combspct.hsigma,
  	   rdnoise = combspct.rdnoise,
  	      gain = combspct.gain,
  	    snoise = combspct.snoise,
  	  sigscale = combspct.sigscale,
  	     pclip = combspct.pclip,
  	      grow = combspct.grow)


  delete (inli,yes,ver-)
  if (typespct != "single") 
    {
    imdelete ("@"//invli,yes,ver-, >>&"/dev/null")
    delete (invli,yes,ver-, >>&"/dev/null")
    }
    
  delete (totli,yes,ver-, >>&"/dev/null")
  delete (apli,yes,ver-, >>&"/dev/null")
  
  if (outspct == "") imdelete ("@"//resultli,yes,ver-, >>&"/dev/null")
  delete (resultli,yes,ver-, >>&"/dev/null")

  
  if (outspct == "") delete (redli,yes,ver-, >>&"/dev/null")
  
  delete (offset,yes,ver-, >>&"/dev/null")
  
  list1 = ""

end
