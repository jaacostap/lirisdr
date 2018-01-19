# lspctapall - extract spectras from list image and combine selected spectra
# Author : Miguel Charcos (mcharcos@ll.iac.es)
# Version: 03. Dec. 2003
##############################################################################
procedure lspctapall(input,outspectr,outlist)

string	input		{prompt="Spectral input image list"}
string	outspectr	{prompt="Prefix of result spectres"}
string	outlist		{prompt="Name of spectra list"}

string	output		{"",prompt="Combined spectra image"}
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
bool	statsel		{no,prompt="Interactive spectral statistical selection"}
bool	intersel	{yes,prompt="Interactive spectral plot selection"}
bool	verbose		{yes,prompt="Verbose"}

# apall parametres
pset	lapopt	{prompt="Apall parametre configuration "}
pset	lapplot	{prompt="lspecplot parametre configuration"}
pset	apstatplot	{prompt="lstatplot parametre configuration"}
pset	apcomb		{prompt="imcombine parametre configuration"}


string  tmpdir  	{")_.tmpdir",prompt="Temporary directory for file conversion"}

int	imnum		{prompt="Return minimum number of output spectres"}

string *list1	{prompt="Ignore this parameter(list1)"}
string *list2	{prompt="Ignore this parameter(list2)"}

begin

  string	ino,outspct
  string	fname,iminv,imref,imrefinv,fnameref
  string 	inli,inliaux,outli,statli,spctli,invli
  string	imcomb,imcombinv,offsetcomb,combli
  string	subcomb,subcombinv
  int 		nsc,i	
  int		dimx,dimy,xmin,xmax,ymin,ymax
  real	x,y,xr,yr
  int 	offpeakAB,o1,d1,o2,d2,o3,d3,x1,y1,x2,y2,x3,y3
  string	readsample1,readsample2,readsample3
  string	ABbg
  bool		first,interaction	
  char		stop

  
  # expand input and output image names.
  inliaux = mktemp(tmpdir//"lspctapallinliaux")
  sections(input,option="fullname", > inliaux)
  
  ino = output
  interaction = interap
  outspct = outspectr
  spctli = mktemp(tmpdir//"lspctapallspctli")
  statli = mktemp(tmpdir//"lspctapallstatli")
  outli = outlist
  
  # Verify image list file existence
  for (i=1;  i <= numspct ;  i += 1)
    {
    #verify if output image already exist
    if (access(outli//"_"//i))
      {
      beep
      print("")
      print("ERROR: operation would overwrite spectra list file ",outli//"_"//i)
      print("lspctapall aborted")
      print("")
      beep
      bye
      }
    } # End of for (i=1;  i <= numspct ;  i += 1)
  
  # Verify output images
  if (ino != "")
    {
    if (numspct == 1)
      {
      limgaccess(ino,ver-)
      if (limgaccess.exists)
        {
        print("WARNING: operation would overwrite output spectra image",ino)
        print("         spectras will not be combined")
        ino = ""
        }
      } # End of if (numspct == 1)
    else # if (numspct != 1)
      {
      for (i=1;  i <= numspct ;  i += 1)
        {
        limgaccess(ino//"_"//i,ver-)
        if (limgaccess.exists)
          {
          print("WARNING: operation would overwrite output spectra image",ino//"_"//i)
          print("         spectras will not be combined")
          ino = ""
          }
        } # End of for (i=1;  i <= numspct ;  i += 1)
      } # End of else [if (numspct == 1)]
    } # End of if (ino != "")
  
  if (references == "combine")
    {
    if (verbose)
      {
      print ""
      print "combining images for aperture search ..."
      }
    
    inli = mktemp (tmpdir//"lspctapallinli")
    offsetcomb = mktemp (tmpdir//"lspctapalloffsetcomb")
    lspctoffset ( input = "@"//inliaux,
                 output = inli,
                offsetf = offsetcomb,
     		predisp = intersel,
    	       postdisp = no,
	        verbose = verbose,
                 tmpdir = tmpdir) 
    delete (inliaux, yes, ver-)
        
    imcomb = mktemp(tmpdir//"lspctapallimcomb")
    imcombine (\
   	  input = "@"//osfn(inli),
   	 output = imcomb,
   	rejmask = "",
#   	 plfile = "",    # not valid for IRAF v2.12.2
   	  sigma = "",
   	logfile = "",
   	combine = "average",
   	 reject = "sigclip",
   	project = no,
   	outtype = "real",
   	offsets = offsetcomb,
       masktype = "goodvalue",
      maskvalue = 0.,
   	  blank = 1.,
   	  scale = "none",
   	   zero = "none",
   	 weight = "none",
   	statsec = "",
   	expname = "EXPTIM",
     lthreshold = INDEF,
     hthreshold = INDEF,
   	   nlow = 1,
   	  nhigh = 1,
   	  nkeep = 1,
   	  mclip = yes,
   	 lsigma = 1.,
   	 hsigma = 1.,
   	rdnoise = "0.",
   	   gain = "1.",
   	 snoise = "0.",
       sigscale = 0.1,
   	  pclip = -0.5,
   	   grow = 0.)

    combli = mktemp(tmpdir//"lspctapallcombli")
    	   
    if (typespct == "AB")
      {
      imcombinv = mktemp(tmpdir//"lspctapallimcombinv")
      imcalc (input = imcomb,
     	     output = imcombinv,
     	     equals = "-im1",
     	    pixtype = "old",
     	    nullval = 0.,
     	    verbose = verbose, >>&"/dev/null")
      
      }
    
    
    # --------------------------------------------------------------------
    #  Calculation of some parameters of image that will be treated
    # --------------------------------------------------------------------
    #########
    #
    #  We read x dimention and y dimentio of the header image. If we can not
    #  dimentions value are 1024x1024.
    #  This step is important to make difference between corrected and no corrected
    #  images dimention
    #
    #########
 
    list1 = inli
    if (fscan(list1,fname) != EOF)
      {
      imgets(image=fname,param="i_naxis1")
      dimx = int(imgets.value)
      imgets(image=fname,param="i_naxis2")
      dimy = int(imgets.value)
      }
    else
      {
      print "WARNING: image dimension does not be calculated"
      print " default value is 1024,1024"
      dimx = 1024
      dimy = 1024
      }
    
    
    # --------------------------------------------------------------------
    #  We search position of the reference image in the result image
    # --------------------------------------------------------------------
    ############
    #
    #  We need know the position of images in the coadded image. 
    #  Because we know shift of images with reference image it is important 
    #  know where reference image is in coadded image.
    #
    ############
    
    
    list1 = offsetcomb
    nsc = fscan(list1,x,y)
    xr=x
    yr=y
    While (fscan(list1,x,y) != EOF)
      {
      if (x<=xr) {xr=x}
      if (y<=yr) {yr=y}
      }
    xr=-xr
    yr=-yr
    if (verbose) print ("reference image shift is ",xr,",",yr)
    
    list1 = offsetcomb
    While (fscan(list1,x,y) != EOF)
      {
      x=x+xr
      y=y+yr
      
      xmin = 1 + x
      ymin = 1 + y
      xmax = dimx + x
      ymax = dimy + y
      
      if (xmin < 1) 
        {
	print "WARNING: min x pixel "//xmin//" "//fname//" approximation to 1"
	xmin = 1
	}
      if (ymin < 1) 
        {
	print "WARNING: min y pixel "//ymin//" "//fname//" approximation to 1"
	ymin = 1
	}
      
      imgets(image=imcomb,param="i_naxis1")
      if (xmax > int(imgets.value)) 
        {
	print "WARNING: max x pixel "//xmax//" "//fname//" approximation to "//imgets.value
	xmax = int(imgets.value)
	}
      
      imgets(image=imcomb,param="i_naxis2")
      if (ymax > int(imgets.value)) 
        {
	print "WARNING: max y pixel "//ymax//" "//fname//" approximation to "//imgets.value
	ymax = int(imgets.value)
	}
      
      subcomb = mktemp (tmpdir//"lspctapallsubcomb")
      imcopy (imcomb//"["//xmin//":"//xmax//","//ymin//":"//ymax//"]",subcomb,ver-)
      apfind (input = subcomb,  
              nfind = numspct,     
          apertures = "",	     
         references = "",	     
        interactive = interapref,	     
               find = yes,	     
           recenter = no,     
             resize = no,	     
               edit = yes,	     
               line = INDEF,	     
               nsum = -dimy/2,     
             minsep = lapopt.minsep,
             maxsep = lapopt.maxsep,
              order = lapopt.order)
      
      print(subcomb,>>combli)
      
      if (typespct == "AB")
        {
	subcombinv = mktemp (tmpdir//"lspctapallsubcombinv")
        imcopy (imcombinv//"["//xmin//":"//xmax//","//ymin//":"//ymax//"]",subcombinv,ver-)
	apfind (input = subcombinv,  
     		nfind = numspct,
     	    apertures = "",
     	   references = "",
     	  interactive = interapref,
     		 find = yes,
     	     recenter = no,
     	       resize = no,
     		 edit = yes,
     		 line = INDEF,
     		 nsum = -dimy/2,
     	       minsep = lapopt.minsep,
     	       maxsep = lapopt.maxsep,
     		order = lapopt.order)
	print(subcombinv,>>combli)
	}
      
      
      } # end of While(fscan(list1,fname) != EOF)
    
    imdelete(imcomb,yes,ver-)
    if (typespct == "AB") {imdelete(imcombinv,yes,ver-)}
    delete(offsetcomb,yes,ver-)
    
    } # end of if (references == "combine")
  else # if (references != "combine")
    {
    inli = inliaux
    } # end of else [if (references == "combine")]
  
  if (verbose) print "extracting spectra ..." 
  list1 = inli
  if (references == "combine") {list2 = combli}
  first = yes
  imref = ""
  imrefinv = ""
  While (fscan(list1,fname) != EOF)
    {
    
    if (typespct == "AB")
      {

	#  Calcualte backgroud sample of AB spectra using distance between
	#  the two spectra A and B
	# Se supone que offpeakAB es la distancia entre el pico A y B que 
	# hay que calcular a partir de la imagen
	# offpeakAB = 10
	# La opcion todavia no esta disponible por la dificultad de calcular la distancia
	# entre los picos y de saber si el pico A esta a la derecha o a la izquierda del B
	# El formaro de los intervalos leidos en lapopt es <o1,d1/o2,d2/o3,d3>
	# los valores de o1,o2,o3 indican la posicion del centro de los tres intervalos
	# cogiendo como origen el centro entre los dos picos. d1,d2,d3 son los tamanos de los
	# intervalos. Todas las longitudes y distancias se toman considerando la distancia
	# entre los dos picos igual a 1 (distancia de referencia). La distancia entre los dos 
	# picos esta insertada en offpeakAB
	
	#if (fscanf(lapopt.b_ab_sample,"%d,%d/%d,%d/%d,%d",o1,d1,o2,d2,o3,d3) != EOF)
	#  {
	
	#  x1 = o1-offpeakAB-d1*offpeakAB/2
	#  y1 = x1+d1*offpeakAB
	#  x2 = o2-offpeakAB-d2*offpeakAB/2
	#  y2 = x2+d2*offpeakAB
	#  x3 = o3-offpeakAB-d3*offpeakAB/2
	#  y3 = x3+d3*offpeakAB
	#  ABbg = x1//":"//y1//","//x2//":"//y2//","//x3//":"//y3
	#  }
	#else 
	#  {
	#  ABbg =lapopt.b_sample
	#  if (verbose) print "WARNING: wrong b_samble AB format"
	#  }  
      
	
	if (first) 
        {
	  invli = mktemp(tmpdir//"lspctapallinvli")
	  first = no
	  }
      else 
        {
	if (interaction) 
	  {
	  print "Do you want use last image like reference image? (y/n)"
	  scanf("%c",stop)
	  if (stop != "y") 
	    {
	    imref = "" 
	    imrefinv = ""
	    }
	  else 
	    {
	    print "Do you want verify result interactivly? (y/n)"
	    scanf("%c",stop)
	    if (stop != "y") interaction = no
	    }
	  }
	} # end of else [if (first)]
      
      if (references == "combine" && imref == "")
        {
        # the portion of the combined image is readen if reference image 
        # put to combine 
	  nsc = fscan (list2,subcomb)
	  nsc = fscan (list2,subcombinv)
	  imref = subcomb
	  imrefinv = subcombinv
        }
      
	lfilename(fname)
      iminv = mktemp(tmpdir//"lspctapalliminv")//"_"//lfilename.reference
      imcalc (input = fname,
     	     output = iminv,
     	     equals = "-im1",
     	    pixtype = "old",
     	    nullval = 0.,
     	    verbose = verbose, >>&"/dev/null")
      print (iminv,>>invli)
      
      fname = lfilename.root
      fnameref = lfilename.reference
      apall (input = fname,
             nfind = numspct,
            output = outspct//fnameref//"A",
         apertures = "",
            format = "onedspec",
        references = imref,
          profiles = "",
       interactive = interaction,
              find = lapopt.find,
     	  recenter = lapopt.recenter,
     	    resize = lapopt.resize,
     	      edit = lapopt.edit,
     	     trace = lapopt.trace,
     	  fittrace = lapopt.fittrace,
     	   extract = lapopt.extract,
     	    extras = lapopt.extras,
     	    review = lapopt.review,
     	      line = line,
     	      nsum = nsum,
     	     lower = lapopt.lower,
     	     upper = lapopt.upper,
     	 apidtable = lapopt.apidtable,
     	b_function = lapopt.b_function,
     	   b_order = lapopt.b_order,
     	  b_sample = lapopt.b_sample,
#        b_sample = ABbg,
     	b_naverage = lapopt.b_naverage,
     	b_niterate = lapopt.b_niterate,
      b_low_reject = lapopt.b_low_reject,
      b_high_rejec = lapopt.b_high_rejec,
     	    b_grow = lapopt.b_grow,
     	     width = lapopt.width,
     	    radius = lapopt.radius,
     	 threshold = lapopt.threshold,
     	    minsep = lapopt.minsep,
     	    maxsep = lapopt.maxsep,
     	     order = lapopt.order,
     	aprecenter = lapopt.aprecenter,
     	    npeaks = lapopt.npeaks,
     	     shift = lapopt.shift,
     	    llimit = lapopt.llimit,
     	    ulimit = lapopt.ulimit,
     	    ylevel = lapopt.ylevel,
     	      peak = lapopt.peak,
     	       bkg = lapopt.bkg,
     	    r_grow = lapopt.r_grow,
     	 avglimits = lapopt.avglimits,
     	    t_nsum = lapopt.t_nsum,
     	    t_step = lapopt.t_step,
     	   t_nlost = lapopt.t_nlost,
     	t_function = lapopt.t_function,
     	   t_order = lapopt.t_order,
     	  t_sample = lapopt.t_sample,
     	t_naverage = lapopt.t_naverage,
     	t_niterate = lapopt.t_niterate,
      t_low_reject = lapopt.t_low_reject,
      t_high_rejec = lapopt.t_high_rejec,
     	    t_grow = lapopt.t_grow,
     	background = lapopt.background,
     	    skybox = lapopt.skybox,
     	   weights = lapopt.weights,
     	      pfit = lapopt.pfit,
     	     clean = lapopt.clean,
     	saturation = lapopt.saturation,
     	 readnoise = lapopt.readnoise,
     	      gain = lapopt.gain,
     	    lsigma = lapopt.lsigma,
     	    usigma = lapopt.usigma,
     	   nsubaps = lapopt.nsubaps)
      
      apall (input = iminv,
             nfind = numspct,
            output = outspct//fnameref//"B",
         apertures = "",
            format = "onedspec",
        references = imrefinv,
          profiles = "",
       interactive = interaction,
              find = lapopt.find,
     	  recenter = lapopt.recenter,
     	    resize = lapopt.resize,
     	      edit = lapopt.edit,
     	     trace = lapopt.trace,
     	  fittrace = lapopt.fittrace,
     	   extract = lapopt.extract,
     	    extras = lapopt.extras,
     	    review = lapopt.review,
     	      line = line,
     	      nsum = nsum,
     	     lower = lapopt.lower,
     	     upper = lapopt.upper,
     	 apidtable = lapopt.apidtable,
     	b_function = lapopt.b_function,
     	   b_order = lapopt.b_order,
     	  b_sample = lapopt.b_sample,
#        b_sample = ABbg,
     	b_naverage = lapopt.b_naverage,
     	b_niterate = lapopt.b_niterate,
      b_low_reject = lapopt.b_low_reject,
      b_high_rejec = lapopt.b_high_rejec,
     	    b_grow = lapopt.b_grow,
     	     width = lapopt.width,
     	    radius = lapopt.radius,
     	 threshold = lapopt.threshold,
     	    minsep = lapopt.minsep,
     	    maxsep = lapopt.maxsep,
     	     order = lapopt.order,
     	aprecenter = lapopt.aprecenter,
     	    npeaks = lapopt.npeaks,
     	     shift = lapopt.shift,
     	    llimit = lapopt.llimit,
     	    ulimit = lapopt.ulimit,
     	    ylevel = lapopt.ylevel,
     	      peak = lapopt.peak,
     	       bkg = lapopt.bkg,
     	    r_grow = lapopt.r_grow,
     	 avglimits = lapopt.avglimits,
     	    t_nsum = lapopt.t_nsum,
     	    t_step = lapopt.t_step,
     	   t_nlost = lapopt.t_nlost,
     	t_function = lapopt.t_function,
     	   t_order = lapopt.t_order,
     	  t_sample = lapopt.t_sample,
     	t_naverage = lapopt.t_naverage,
     	t_niterate = lapopt.t_niterate,
      t_low_reject = lapopt.t_low_reject,
      t_high_rejec = lapopt.t_high_rejec,
     	    t_grow = lapopt.t_grow,
     	background = lapopt.background,
     	    skybox = lapopt.skybox,
     	   weights = lapopt.weights,
     	      pfit = lapopt.pfit,
     	     clean = lapopt.clean,
     	saturation = lapopt.saturation,
     	 readnoise = lapopt.readnoise,
     	      gain = lapopt.gain,
     	    lsigma = lapopt.lsigma,
     	    usigma = lapopt.usigma,
     	   nsubaps = lapopt.nsubaps)
	   
      if (interaction) 
	  {
	  imref = fname
	  imrefinv = iminv
	  }
      
      for (i=1;  i <= numspct ;  i += 1) 
        {
        print (outspct//fnameref//"A"//".000"//i, >> spctli//"_"//i)
        print (outspct//fnameref//"B"//".000"//i, >> spctli//"_"//i)
	}
      
      }
    else if (typespct == "single")
      {
      if (first) first = no
      else 
        {
	if (interaction) 
	  {
	  print "Do you want use last image like reference image? (y/n)"
	  scanf("%c",stop)
	  if (stop != "y") imref="" 
	  else 
	    {
	    print "Do you want verify result interactivly? (y/n)"
	    scanf("%c",stop)
	    if (stop != "y") interaction = no
	    }
	  }
	}
      
      if (references == "combine" && imref == "")
        {
        # the portion of the combined image is readen if reference image 
        # put to combine 
	nsc = fscan (list2,subcomb)
	imref = subcomb
        }
      
      lfilename(fname)
      fnameref = lfilename.reference
      apall (input = fname,
             nfind = numspct,
            output = outspct//fnameref,
         apertures = "",
            format = "onedspec",
        references = imref,
          profiles = "",
       interactive = interaction,
     	      find = lapopt.find,
    	  recenter = lapopt.recenter,
    	    resize = lapopt.resize,
    	      edit = lapopt.edit,
    	     trace = lapopt.trace,
    	  fittrace = lapopt.fittrace,
    	   extract = lapopt.extract,
    	    extras = lapopt.extras,
    	    review = lapopt.review,
    	      line = line,
    	      nsum = nsum,
    	     lower = lapopt.lower,
    	     upper = lapopt.upper,
    	 apidtable = lapopt.apidtable,
    	b_function = lapopt.b_function,
    	   b_order = lapopt.b_order,
    	  b_sample = lapopt.b_sample,
    	b_naverage = lapopt.b_naverage,
    	b_niterate = lapopt.b_niterate,
      b_low_reject = lapopt.b_low_reject,
      b_high_rejec = lapopt.b_high_rejec,
    	    b_grow = lapopt.b_grow,
    	     width = lapopt.width,
    	    radius = lapopt.radius,
    	 threshold = lapopt.threshold,
    	    minsep = lapopt.minsep,
    	    maxsep = lapopt.maxsep,
    	     order = lapopt.order,
    	aprecenter = lapopt.aprecenter,
    	    npeaks = lapopt.npeaks,
    	     shift = lapopt.shift,
    	    llimit = lapopt.llimit,
    	    ulimit = lapopt.ulimit,
    	    ylevel = lapopt.ylevel,
    	      peak = lapopt.peak,
    	       bkg = lapopt.bkg,
    	    r_grow = lapopt.r_grow,
    	 avglimits = lapopt.avglimits,
    	    t_nsum = lapopt.t_nsum,
    	    t_step = lapopt.t_step,
    	   t_nlost = lapopt.t_nlost,
    	t_function = lapopt.t_function,
    	   t_order = lapopt.t_order,
    	  t_sample = lapopt.t_sample,
    	t_naverage = lapopt.t_naverage,
    	t_niterate = lapopt.t_niterate,
      t_low_reject = lapopt.t_low_reject,
      t_high_rejec = lapopt.t_high_rejec,
    	    t_grow = lapopt.t_grow,
    	background = lapopt.background,
    	    skybox = lapopt.skybox,
    	   weights = lapopt.weights,
    	      pfit = lapopt.pfit,
    	     clean = lapopt.clean,
    	saturation = lapopt.saturation,
    	 readnoise = lapopt.readnoise,
    	      gain = lapopt.gain,
    	    lsigma = lapopt.lsigma,
    	    usigma = lapopt.usigma,
    	   nsubaps = lapopt.nsubaps)
      
      if (interaction) {imref = fname}
      for (i=1;  i <= numspct ;  i += 1) 
        {print (outspct//fnameref//".000"//i, >> spctli//"_"//i)}

      }
    
    } # end of While (fscan(list1,fname) != EOF)


  
  if (statsel)
    {
    imnum = 100
    for (i=1;  i <= numspct ;  i += 1)
      {
      lspecstat (input = "@"//spctli//"_"//i,
    		output = statli//"_"//i,
    	      delnosel = no,
	    statinterv = "[*]",
    		tmpdir = tmpdir,
               verbose = yes)
    	     
 
      if (imnum > lspecstat.imnum) {imnum = lspecstat.imnum}
      }
      
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
    } # End of if (statsel)
  else # if (!statsel)
    {
    for (i=1;  i <= numspct ;  i += 1) 
      {sections("@"//spctli//"_"//i,option="fullname",>>statli//"_"//i)}
    } # End of else [if (statsel)]

    
    
  if (intersel)
    {
    spplotopt.apertures = lapplot.apertures
    spplotopt.bands = lapplot.bands
    spplotopt.autolayout = lapplot.autolayout
    spplotopt.autoscale = lapplot.autoscale
    spplotopt.fraction = lapplot.fraction
    spplotopt.units = lapplot.units
    spplotopt.scale = lapplot.scale
    spplotopt.offset = lapplot.offset
    spplotopt.step = lapplot.step 
    spplotopt.ptype = lapplot.ptype
    spplotopt.labels = lapplot.labels
    spplotopt.ulabels = lapplot.ulabels
    spplotopt.xlpos = lapplot.xlpos
    spplotopt.ylpos = lapplot.ylpos
    spplotopt.sysid = lapplot.sysid
    spplotopt.yscale = lapplot.yscale
    spplotopt.title = lapplot.title
    spplotopt.xlabel = lapplot.xlabel
    spplotopt.ylabel = lapplot.ylabel
    spplotopt.xmin = lapplot.xmin
    spplotopt.xmax = lapplot.xmax
    spplotopt.ymin = lapplot.ymin
    spplotopt.ymax = lapplot.ymax
    
    spplotopt.logfile = lapplot.logfile
    spplotopt.graphics = lapplot.graphics
    spplotopt.cursor = lapplot.cursor
    
    
    
    imnum = 100
    for (i=1;  i <= numspct ;  i += 1)
      {
      lspecplot (input = "@"//statli//"_"//i,
    		output = outli//"_"//i,
    	      delnosel = no,
    		tmpdir = tmpdir,
               verbose = yes)
    	     
 
      if (imnum > lspecplot.imnum) {imnum = lspecplot.imnum}
      }
      
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
    } # end of if (intersel)
  else
    {
    imnum = 100
    for (i=1;  i <= numspct ;  i += 1) 
      {
      #lnamelist ( input = "@"//statli//"_"//i,
      #  	 output = outli//"_"//i,
      #  	  bname = "",
      #  	  pname = "",
      #  	refname = "@"//statli//"_"//i,
      #  	 maxnum = INDEF,
      #  	 extens = "" )
      sections("@"//statli//"_"//i,option="fullname",>>outli//"_"//i)
      if (imnum > sections.nimages) {imnum = sections.nimages}
      }  
    }
    
  # Aqui hay que combinar los diferentes espectros sustraidos  
  if (ino != "")
    {
    if (numspct == 1)
      {
      imcombine (\
            input = "@"//osfn(outli)//"_"//1,
           output = ino,
          rejmask = "",
#           plfile = apcomb.plfile,  # not valid for IRAF v2.12.2
            sigma = apcomb.sigma,
          logfile = apcomb.logfile,
          combine = "average",
           reject = apcomb.reject,
          project = apcomb.project,
          outtype = apcomb.outtype,
          offsets = "",
         masktype = "none",
        maskvalue = 0.,
            blank = 1.,
            scale = apcomb.scale,
             zero = apcomb.zero,
           weight = apcomb.weight,
          statsec = apcomb.statsec,
          expname = apcomb.expname,
       lthreshold = apcomb.lthreshold,
       hthreshold = apcomb.hthreshold,
             nlow = apcomb.nlow,
            nhigh = apcomb.nhigh,
            nkeep = apcomb.nkeep,
            mclip = apcomb.mclip,
           lsigma = apcomb.lsigma,
           hsigma = apcomb.hsigma,
          rdnoise = apcomb.rdnoise,
             gain = apcomb.gain,
           snoise = apcomb.snoise,
         sigscale = apcomb.sigscale,
            pclip = apcomb.pclip,
             grow = apcomb.grow)
      
      } # End of if (numspct == 1)
    else # if (numspct != 1)
      {
      for (i=1;  i <= numspct ;  i += 1)
        {
        imcombine (\
    	      input = "@"//osfn(outli)//"_"//i,
    	     output = ino//"_"//i,
    	    rejmask = "",
#    	     plfile = apcomb.plfile, # not valid for IRAF v2.12.2
    	      sigma = apcomb.sigma,
    	    logfile = apcomb.logfile,
    	    combine = "average",
    	     reject = apcomb.reject,
    	    project = apcomb.project,
    	    outtype = apcomb.outtype,
    	    offsets = "",
    	   masktype = "none",
    	  maskvalue = 0.,
    	      blank = 1.,
    	      scale = apcomb.scale,
    	       zero = apcomb.zero,
    	     weight = apcomb.weight,
    	    statsec = apcomb.statsec,
    	    expname = apcomb.expname,
    	 lthreshold = apcomb.lthreshold,
    	 hthreshold = apcomb.hthreshold,
    	       nlow = apcomb.nlow,
    	      nhigh = apcomb.nhigh,
    	      nkeep = apcomb.nkeep,
    	      mclip = apcomb.mclip,
    	     lsigma = apcomb.lsigma,
    	     hsigma = apcomb.hsigma,
    	    rdnoise = apcomb.rdnoise,
    	       gain = apcomb.gain,
    	     snoise = apcomb.snoise,
    	   sigscale = apcomb.sigscale,
    	      pclip = apcomb.pclip,
    	       grow = apcomb.grow)
 
        } # end of for (i=1;  i <= numspct ;  i += 1)
      } # End of else [if (numspct == 1)]
    } # End of if (ino != "")
  
  
  #################################
  # Delete temporary variables
  #--------------------------------
  imdelete ("@"//invli,yes,ver-)
  delete (invli,yes,ver-)
  delete (inli, yes, ver-)
  if (references == "combine")
    {
    imdelete ("@"//combli,yes,ver-)
    delete (combli,yes,ver-)
    }
  
  for (i=1;  i <= numspct ;  i += 1) 
    {
    delete (spctli//"_"//i,yes,ver-)
    delete (statli//"_"//i,yes,ver-)
    }

  list1 = ""
  list2 = ""
  
end
