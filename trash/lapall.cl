# lspctapall - extract spectra from combined image
# Author : Miguel Charcos (mcharcos@ll.iac.es)
# Version: 30. Jan. 2004
##############################################################################
procedure lapall(input,output)

string	input		{prompt="Spectral input image list"}
string	output		{prompt="Output spectra result"}
  
string	references 	{"",prompt="Reference images (combine|<keywords>)"}
string	apertures   	{"",prompt="Apertures"}

# Spectral caracteristics
string	typespct	{"AB",prompt="Type of spectral image (AB|single)"}
int	numspct		{1,prompt="Number of spectres to extract"} 
int 	line		{INDEF,prompt="Dispersion line"}
int	nsum		{10,prompt="Number of dispersion lines to sum or median"}

# interactive parametres
bool	interap		{no,prompt="Interactive spectral extraction"}
bool	interapref	{no,prompt="Interactive spectral extraction when combine option"}
bool	intersel	{yes,prompt="Interactive spectral selection"}
bool	verbose		{no,prompt="Verbose"}

# apall parametres
pset	apallopt	{prompt="Apall parametre configuration "}
pset	apallplot	{prompt="lspecplot parametre configuration"}
pset 	apallcomb	{prompt="combine parametre configuration"}

string  tmpdir  	{")_.tmpdir",prompt="Temporary directory for file conversion"}


begin

  string	ino,inli
  string	redli
  
  
  # expand input and output image names.
  inli = mktemp(tmpdir//"lapallinli")
  sections(input,option="fullname", > inli)
  
  ino = output 
  for (i=1;  i <= numspct ;  i += 1)
    {
    imgaccess(ino//"_"//i)
  
    #verify if output images already exist
    if (imgaccess.exists)  
      {
      beep
      print("")
      print("ERROR: operation would overwrite output list file ")
      print("lspctapall aborted")
      print("")
      beep
      bye
      }
    } # end of for (i=1;  i <= numspct ;  i += 1)
    
  if (verbose) {print "extracting spectres ... "}
    
  redli = mktemp(tmpdir//"lapallredli") 
  lspctapall (input = "@"//inli,	       
  	     output = "lapall",	       
  	    outlist = redli,
  	 references = references,
          apertures = apertures,
           typespct = typespct,
            numspct = numspct,
  	       line = line,
  	       nsum = nsum,
  	    interap = interap,
  	 interapref = interapref,
  	   intersel = intersel,
             tmpdir = tmpdir,
  	    verbose = verbose,
  	     tmpdir = tmpdir) 
    
    
  # We combine extracted spectras  
  for (i=1;  i <= numspct ;  i += 1)
    {
    imcombine (\
  	  input = "@"//osfn(redli)//"_"//i,
  	 output = ino//"_"//i,
  	rejmask = apallcomb.rejmask,
  	 plfile = apallcomb.plfile,
  	  sigma = apallcomb.sigma,
  	logfile = apallcomb.logfile,
  	combine = apallcomb.combine,
  	 reject = apallcomb.reject,
  	project = apallcomb.project,
  	outtype = apallcomb.outtype,
  	offsets = apallcomb.offsets,
       masktype = apallcomb.masktype,
      maskvalue = apallcomb.maskvalue,
  	  blank = apallcomb.blank,
  	  scale = apallcomb.scale,
  	   zero = apallcomb.zero,
  	 weight = apallcomb.weight,
  	statsec = apallcomb.statsec,
  	expname = apallcomb.expname,
     lthreshold = apallcomb.lthreshold,
     hthreshold = apallcomb.hthreshold,
  	   nlow = apallcomb.nlow,
  	  nhigh = apallcomb.nhigh,
  	  nkeep = apallcomb.nkeep,
  	  mclip = apallcomb.mclip,
  	 lsigma = apallcomb.lsigma,
  	 hsigma = apallcomb.hsigma,
  	rdnoise = apallcomb.rdnoise,
  	   gain = apallcomb.gain,
  	 snoise = apallcomb.snoise,
       sigscale = apallcomb.sigscale,
  	  pclip = apallcomb.pclip,
  	   grow = apallcomb.grow)
    
    imdelete ("@"//redli//"_"//i,yes,ver-)
    delete (redli//"_"//i,yes,ver-)
    } # end of for (i=1;  i <= numspct ;  i += 1)


end    
