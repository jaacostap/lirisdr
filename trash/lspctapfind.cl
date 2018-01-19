# lextract - lextract spectr from combined image
# Author : Miguel Charcos (mcharcos@ll.iac.es)
# Version: 03. Dec. 2003
##############################################################################
procedure lextract(input,output,outlist)

string	input		{prompt="Spectral input image list"}
string	output		{prompt="Prefix of result spectres"}
string	outlist		{prompt="Extracted spectral image name list file"}
  
string	references 	{"",prompt="Reference images"}

# Spectral caracteristics
string	typespct	{"AB",prompt="Type of spectral image (AB|single)"}
int	numspct		{1,prompt="Number of spectres to extract"} 
int 	line		{INDEF,prompt="Dispersion line"}
int	nsum		{10,prompt="Number of dispersion lines to sum or median"}

# interactive parametres
bool	interap		{no,prompt="Interactive spectral extraction"}
bool	intersel	{yes,prompt="Interactive spectral selection"}
bool	verbose		{no,prompt="Verbose"}

# apall parametres
pset	apallopt	{prompt="Apall parametre configuration"}

string  tmpdir  	{")_.tmpdir",prompt="Temporary directory for file conversion"}

int	imnum		{prompt="Return minimum number of output spectres"}

string *list1	{prompt="Ignore this parameter(list1)"}

begin

  string	ino
  string	fname,iminv,imref
  string 	inli,outli,spctli,invli
  int 		nsc,i	
  bool		first,stop	


  # expand input and output image names.
  inli = mktemp(tmpdir//"lspctapallinli")
  sections(input,option="fullname", > inli)
  
  ino = output
  
  spctli = mktemp(tmpdir//"lspctapallspctli")
  
  outli = outlist
  #verify if output images already exist
  if (access(outli))  
    {
    beep
    print("")
    print("ERROR: operation would overwrite output list file ")
    print("lspctapall aborted")
    print("")
    beep
    bye
    }
   
  list1 = inli
  first = yes
  imref = ""
  While (fscan(list1,fname) != EOF)
    {
    
    if (typespct == "AB")
      {
      if (first) 
        {
	invli = mktemp(tmpdir//"lspctapallinvli")
	first = no
	}
      else 
        {
	if (interap) 
	  {
	  print "Do you want use last image like reference image?"
	  scanf("%b",stop)
	  if (!stop) imref="" 
	  interap = no
	  }
	}
      
      iminv = mktemp(tmpdir//"lspctapalliminv")
      imcalc (input = fname,
     	     output = iminv,
     	     equals = "-im1",
     	    pixtype = "old",
     	    nullval = 0.,
     	    verbose = verbose)
      print (iminv,>>invli)
      
      lfilename(fname)
      fname = lfilename.root
      apall (input = fname//","//iminv,
             nfind = numspct,
            output = ino//fname//"_A,"//ino//fname//"_B",
         apertures = "",
            format = "onedspec",
        references = imref,
          profiles = "",
       interactive = interap,
             find = apallopt.find,
     	  recenter = apallopt.recenter,
     	    resize = apallopt.resize,
     	      edit = apallopt.edit,
     	     trace = apallopt.trace,
     	  fittrace = apallopt.fittrace,
     	   extract = apallopt.extract,
     	    extras = apallopt.extras,
     	    review = apallopt.review,
     	      line = line,
     	      nsum = nsum,
     	     lower = apallopt.lower,
     	     upper = apallopt.upper,
     	 apidtable = apallopt.apidtable,
     	b_function = apallopt.b_function,
     	   b_order = apallopt.b_order,
     	  b_sample = apallopt.b_sample,
     	b_naverage = apallopt.b_naverage,
     	b_niterate = apallopt.b_niterate,
      b_low_reject = apallopt.b_low_reject,
      b_high_rejec = apallopt.b_high_rejec,
     	    b_grow = apallopt.b_grow,
     	     width = apallopt.width,
     	    radius = apallopt.radius,
     	 threshold = apallopt.threshold,
     	    minsep = apallopt.minsep,
     	    maxsep = apallopt.maxsep,
     	     order = apallopt.order,
     	aprecenter = apallopt.aprecenter,
     	    npeaks = apallopt.npeaks,
     	     shift = apallopt.shift,
     	    llimit = apallopt.llimit,
     	    ulimit = apallopt.ulimit,
     	    ylevel = apallopt.ylevel,
     	      peak = apallopt.peak,
     	       bkg = apallopt.bkg,
     	    r_grow = apallopt.r_grow,
     	 avglimits = apallopt.avglimits,
     	    t_nsum = apallopt.t_nsum,
     	    t_step = apallopt.t_step,
     	   t_nlost = apallopt.t_nlost,
     	t_function = apallopt.t_function,
     	   t_order = apallopt.t_order,
     	  t_sample = apallopt.t_sample,
     	t_naverage = apallopt.t_naverage,
     	t_niterate = apallopt.t_niterate,
      t_low_reject = apallopt.t_low_reject,
      t_high_rejec = apallopt.t_high_rejec,
     	    t_grow = apallopt.t_grow,
     	background = apallopt.background,
     	    skybox = apallopt.skybox,
     	   weights = apallopt.weights,
     	      pfit = apallopt.pfit,
     	     clean = apallopt.clean,
     	saturation = apallopt.saturation,
     	 readnoise = apallopt.readnoise,
     	      gain = apallopt.gain,
     	    lsigma = apallopt.lsigma,
     	    usigma = apallopt.usigma,
     	   nsubaps = apallopt.nsubaps)
 
    
      imref = fname//","//iminv
      
      for (i=1;  i <= numspct ;  i += 1) 
        {
        print (ino//fname//"_A"//".000"//i, >> spctli//"_"//i)
        print (ino//fname//"_B"//".000"//i, >> spctli//"_"//i)
	}
      
      }
    else if (typespct == "single")
      {
      if (first) first = no
      else 
        {
	if (interap) 
	  {
	  print "Do you want use last image like reference image?"
	  scanf("%b",stop)
	  if (!stop) imref="" 
	  interap = no
	  }
	}
      apall (input = fname,
             nfind = numspct,
            output = ino//fname,
         apertures = "",
            format = "onedspec",
        references = imref,
          profiles = "",
       interactive = interap,
     	      find = apallopt.find,
    	  recenter = apallopt.recenter,
    	    resize = apallopt.resize,
    	      edit = apallopt.edit,
    	     trace = apallopt.trace,
    	  fittrace = apallopt.fittrace,
    	   extract = apallopt.extract,
    	    extras = apallopt.extras,
    	    review = apallopt.review,
    	      line = line,
    	      nsum = nsum,
    	     lower = apallopt.lower,
    	     upper = apallopt.upper,
    	 apidtable = apallopt.apidtable,
    	b_function = apallopt.b_function,
    	   b_order = apallopt.b_order,
    	  b_sample = apallopt.b_sample,
    	b_naverage = apallopt.b_naverage,
    	b_niterate = apallopt.b_niterate,
      b_low_reject = apallopt.b_low_reject,
      b_high_rejec = apallopt.b_high_rejec,
    	    b_grow = apallopt.b_grow,
    	     width = apallopt.width,
    	    radius = apallopt.radius,
    	 threshold = apallopt.threshold,
    	    minsep = apallopt.minsep,
    	    maxsep = apallopt.maxsep,
    	     order = apallopt.order,
    	aprecenter = apallopt.aprecenter,
    	    npeaks = apallopt.npeaks,
    	     shift = apallopt.shift,
    	    llimit = apallopt.llimit,
    	    ulimit = apallopt.ulimit,
    	    ylevel = apallopt.ylevel,
    	      peak = apallopt.peak,
    	       bkg = apallopt.bkg,
    	    r_grow = apallopt.r_grow,
    	 avglimits = apallopt.avglimits,
    	    t_nsum = apallopt.t_nsum,
    	    t_step = apallopt.t_step,
    	   t_nlost = apallopt.t_nlost,
    	t_function = apallopt.t_function,
    	   t_order = apallopt.t_order,
    	  t_sample = apallopt.t_sample,
    	t_naverage = apallopt.t_naverage,
    	t_niterate = apallopt.t_niterate,
      t_low_reject = apallopt.t_low_reject,
      t_high_rejec = apallopt.t_high_rejec,
    	    t_grow = apallopt.t_grow,
    	background = apallopt.background,
    	    skybox = apallopt.skybox,
    	   weights = apallopt.weights,
    	      pfit = apallopt.pfit,
    	     clean = apallopt.clean,
    	saturation = apallopt.saturation,
    	 readnoise = apallopt.readnoise,
    	      gain = apallopt.gain,
    	    lsigma = apallopt.lsigma,
    	    usigma = apallopt.usigma,
    	   nsubaps = apallopt.nsubaps)
      
      imref = fname
      for (i=1;  i <= numspct ;  i += 1) 
        {print (ino//fname//".000"//i, >> spctli//"_"//i)}

      }
    
    } # end of While (fscan(list1,fname) != EOF)

  if (intersel)
    {
    spplotopt.apertures = ""
    spplotopt.bands = "1"
    spplotopt.autolayout = no
    spplotopt.autoscale = no
    spplotopt.fraction = 0.
    spplotopt.units = ""
    spplotopt.scale = "1."
    spplotopt.offset = "0."
    spplotopt.step = 0.
    spplotopt.ptype = "1"
    spplotopt.labels = "user"
    spplotopt.ulabels = ""
    spplotopt.xlpos = 1.02
    spplotopt.ylpos = 0.
    spplotopt.sysid = yes
    spplotopt.yscale = no
    spplotopt.title = ""
    spplotopt.xlabel = ""
    spplotopt.ylabel = ""
    spplotopt.xmin = INDEF
    spplotopt.xmax = INDEF
    spplotopt.ymin = INDEF
    spplotopt.ymax = INDEF
    
    if (numspct == 1)
      {
      lspecplot (input = "@"//spctli//"_"//1,
        	output = outli,
              delnosel = yes,
               indepf1 = "",
               indepf2 = "",
        	tmpdir = tmpdir,
               verbose = verbose)
 
      imnum = lspecplot.imnum
      } # end of if (numspct == 1)
    else
      {
      imnum = 100
      for (i=1;  i <= numspct ;  i += 1)
        {
        lspecplot (input = "@"//spctli//"_"//i,
        	  output = outli//"_"//i,
        	delnosel = yes,
                 indepf1 = "",
                 indepf2 = "",
        	  tmpdir = tmpdir,
                 verbose = verbose)
 
        if (imnum > lspecplot.imnum) {imnum = lspecplot.imnum}
	}
      } # end of else [if (numspct == 1)]
    # We verify that there are some images in the list because we need 
    # almost one to make correlation    
    if (imnum == 0)
      {
      beep
      print("")
      print "ERROR: You must choose almost one spectre"
      print("lspctapall finished")
      print("")
      beep
      bye
      }
    } # end of if (interactive)
  else
    {
    if (numspct == 1)
      {sections("@"//spctli//"_"//1,option="fullname",>>outli)}
    else
      {
      for (i=1;  i <= numspct ;  i += 1) 
        {sections("@"//spctli//"_"//i,option="fullname",>>outli//"_"//i)}
      }  
    
    imnum = sections.nimages
    }
  
  
  imdelete ("@"//invli,yes,ver-)
  
  for (i=1;  i <= numspct ;  i += 1) 
    {delete (spctli//"_"//i,yes,ver-)}

  list1 = ""
  
end
