# lfcalib - generate blackbody with input image 
# Author : Miguel Charcos (mcharcos@ll.iac.es)
# Version: 09. Feb. 2004
##############################################################################
procedure lfcalib(input)

string	input		{prompt="Input star image"}

string	outtel		{"",prompt="Output telurique profile file name"}
string	outbb		{"",prompt="Output template file name"}
string	outnorm		{"",prompt="Output normalized image file name"}
string	outfit		{"",prompt="Output fit image file name"}
string	outlines	{"",prompt="Output line corrected image file name"}
string	outmfit		{"",prompt="Output fit model file name"}
string	outmlines	{"",prompt="Output line corrected model file name"}

bool	stfeature	{no,prompt="Delete stellar features"}
string	mfeature	{"none",enum="none|interfet|samefet|sameinter",prompt="Delete model features (none|interfet|samefet|sameinter)"}

string	startype	{"A0V",prompt="Type of calibration star"}
string	stmodel		{"bbody",prompt="Model type used (bbody|model|<filename>)"}
string 	database	{"ltccal",prompt="Star model database"}

# blackbody pset configuration
pset 	bodyopt		{prompt="mk1dspec parametre configuration"}

bool	verbose		{no,prompt="Verbose?"}
bool	internorm	{no,prompt="Check interactively normalisation interval"}

# Directories
string	tmpdir		{")_.tmpdir",prompt="Temporary directory for file conversion"}
string	stddir		{")_.stddir",prompt="Parametre directory"}

string *list1	{prompt="Ignore this parameter(list1)"}

begin

  string	ini,inobb,inotel,inonorm,infit,inlines,inmfit,inmlines
  string	imgbbody,imgbbody_aux,imgnorm,imgtel
  string	imgfit,imglines,imgbbodyfit,imgbbodylines
  
  string	dbfile,aux1,aux2,aux3
  string	fsttyperead,fmodelread,fsttype,fmodel,path
  real		tempread,temperature
  string	stmod
  
  string 	fitinterv,intervli,mfint
  bool		fitdone, delimglines, delmodel
  
  real		wave_start,wave_end
  real		temp,colums
  
  int		stat_inf,stat_sup
  real		norm_factor
  
  
  ##########################################################################
  #  Verify input variables
  #-------------------------------------------------------------------------
  
  # force input definition
  ini = input
  
  # Check for input image
  imgaccess(ini,ver-)
  if (imgaccess.exists == no)
    {
    beep
    print("")
    print("ERROR: "//ini//" image does not exist")
    print("lfcalib aborted")
    print("")
    beep
    bye
    }
  
  
  # force output definitions
  inobb = outbb
  inotel = outtel
  inonorm = outnorm
  infit = outfit
  inlines = outlines
  inmfit = outmfit
  inmlines = outmlines
  dbfile = stddir//database
  stmod = stmodel
  fsttype = startype
  
  mfint = mfeature
  
  # Check for output images
  if (inobb != "")
    {
    imgaccess(inobb,ver-)
    if (imgaccess.exists)
      {
      if (verbose)
    	{
    	print "WARNING: "//inobb//" already exist"
    	print " 	no black body output will be done"
    	}
      inobb = ""
      }
    }
     
  if (inotel != "")
    {
    imgaccess(inotel,ver-)
    if (imgaccess.exists)
      {
      if (verbose)
    	{
    	print "WARNING: "//inotel//" already exist"
    	print " 	no telurique correction output function will be done"
    	}
      inotel = ""
      }
    }
    
  if (inonorm != "")
    {
    imgaccess(inonorm,ver-)
    if (imgaccess.exists)
      {
      if (verbose)
    	{
    	print "WARNING: "//inonorm//" already exist"
    	print " 	no normalized output image will be done"
    	}
      inonorm = ""
      }
    }
    
  if (infit != "")
    {
    imgaccess(infit,ver-)
    if (imgaccess.exists)
      {
      if (verbose)
    	{
    	print "WARNING: "//infit//" already exist"
    	print " 	no normalized output image will be done"
    	}
      infit = ""
      }
    }
    
  if (inlines != "")
    {
    imgaccess(inlines,ver-)
    if (imgaccess.exists)
      {
      if (verbose)
    	{
    	print "WARNING: "//inlines//" already exist"
    	print " 	no normalized output image will be done"
    	}
      inlines = ""
      }
    }
    
  if (inmfit != "")
    {
    imgaccess(inmfit,ver-)
    if (imgaccess.exists)
      {
      if (verbose)
    	{
    	print "WARNING: "//inmfit//" already exist"
    	print " 	no normalized output image will be done"
    	}
      infit = ""
      }
    }
    
  if (inmlines != "")
    {
    imgaccess(inmlines,ver-)
    if (imgaccess.exists)
      {
      if (verbose)
    	{
    	print "WARNING: "//inmlines//" already exist"
    	print " 	no normalized output image will be done"
    	}
      inlines = ""
      }
    }
    
  if (inobb == "" && inotel == "" && inonorm == "" && inlines == "" && infit == "")
    {
    beep
    print("")
    print("ERROR: no output file")
    print("lfcalib aborted")
    print("")
    beep
    bye
    }  
  
  if (stmod != "bbody" && stmod != "model")
    {
    imgaccess(stmod,ver-)
    if (imgaccess.exists == no)
      {
      if (verbose)
        {
	print "WARNING: no star image "//stmod//" file found"
	print "         black body model will be used"
	}
      stmod = "bbody"
      } 
    }
  
  if (stmod == "bbody" || stmod == "model")
    {
    if (access(dbfile) == no)
      {
      beep
      print("")
      print("ERROR: no database file "//dbfile//" found")
      print("lfcalib aborted")
      print("")
      beep
      bye
      } 
    }
    
  ##########################################################################
  #  Search spectra calibration parametres in database
  #-------------------------------------------------------------------------
  
  if (stmod == "bbody" || stmod == "model")
    {
    list1 = dbfile
    if (fscan(list1,aux1,aux2,path) == EOF)
      {
      beep
      print("")
      print("ERROR: star database file wrong")
      print("lfcalib aborted")
      print("")
      beep
      bye
      }
    else
      {
      if (aux1 != "Model" || aux2 != "path")
    	{
    	beep
    	print("")
    	print("ERROR: star database file wrong")
    	print("lfcalib aborted")
    	print("")
    	beep
    	bye
    	}
      }
  
    if (fscan(list1,aux1,aux2,aux3) == EOF)
      {
      beep
      print("")
      print("ERROR: star database file wrong")
      print("lfcalib aborted")
      print("")
      beep
      bye
      }
    else
      {
      if (aux1 != "Type" || aux2 != "Temp" || aux3 != "Model")
    	{
    	beep
    	print("")
    	print("ERROR: star database file wrong")
    	print("lfcalib aborted")
    	print("")
    	beep
    	bye
    	}
      }
  
    temperature = 0.
    fmodel = ""
    While (fscan(list1,fsttyperead,tempread,fmodelread)!=EOF)
      {
      if (fsttype == fsttyperead)
    	{
    	temperature = tempread
    	fmodel = fmodelread
    	}
      }
 
    if (temperature == 0.)
      {
      beep
      print("")
      print("ERROR: no star found")
      print("lfcalib aborted")
      print("")
      beep
      bye
      }
    
    if (stmod == "model")
      {
      imgaccess(path//fmodel,ver-)
      if (imgaccess.exists == no)
        {
	if (verbose) 
	  {
	  print "WARNING: "//fmodel//" image not found"
	  print "         black body model will be used"  
	  }
	stmodel = "bbody"
	}
      }
      	
    if (verbose)
      {
      if (stmod == "bbody") print "INFO: black body option ("//temperature//"K)"
      if (stmod == "model") print "INFO: image model option ("//fmodel//")"
      }
      
    } # End of if (stmod == "bbody" || stmod == "model")
    
    
  ##########################################################################
  #  Delete features of input spectra
  #-------------------------------------------------------------------------
  if (stfeature)
    {
    if (verbose) print "Deleting image features lines ..."
    print " *** Fit process - interactive analyse  ***"
    print " *** Press '?' key to obtain commands ***"
    print " *** Press 'q' key to quit ***" 
    imgfit = mktemp(tmpdir//"lfcalibimgfit")
    
    sfit ( input = ini,               
          output = imgfit,               
             ask = "yes",          
           lines = "*",           
           bands = "1",           
            type = "fit",         
         replace = no,            
       wavescale = yes,           
        logscale = no,            
        override = no,            
        listonly = no,            
        logfiles = "logfile",     
     interactive = yes,           
          sample = "*",           
        naverage = 3,             
        function = "spline3",     
           order = 20,             
      low_reject = 2.,            
     high_reject = 2.,            
        niterate = 3,             
            grow = 1.,            
         markrej = yes,           
        graphics = "stdgraph",    
          cursor = "")  
    
    fitdone = no
    print ("Do you want to correct lines (0=no/1=yes) ")
    scanf ("  %d",stat_inf)
    stat_sup = -1
    if (stat_inf != 0) 
      {
      delimglines = yes
      imglines = mktemp (tmpdir//"lfcalibimglines")
      intervli = mktemp (tmpdir//"lfcalibintervli")
      imcopy (ini,imglines,ver-)
      print " *** Feature process - interactive analyse  ***"
      print " *** Press 'space' key to examine pixel positions ***"
      print " *** Press 'q' key to quit ***" 
      print (":.help", >gcur)
      implot (ini)
      print (gcur)
      }
    else 
      {
      imglines = ini
      delimglines = no
      if (mfint == "samefet" || mfint == "sameinter") 
        {
	if (verbose) print "WARNING: model feature treatment changed to inter"
	mfint = interfet
	}
      }
    
    While (stat_inf != 0 && stat_sup != 0)
      {
      print ("Introduce intervale to replace (0 to quit, neg to correct) : ")
      print ("  Minimum value =")
      scanf ("  %d",stat_inf)
      if (stat_inf > 0)
        {
	print ("  Maximum value =")
        scanf ("  %d",stat_sup)
	if (stat_sup > 0)
	  {
	  fitinterv = "["//stat_inf//":"//stat_sup//"]"
	  fitdone = yes
	  print (fitinterv,>>intervli)
	  imcopy(imgfit//fitinterv,imglines//fitinterv,ver-)
	  }
	}
      }
    }
  else 
    {
    imglines = ini
    delimglines = no
    }
      
  ##########################################################################
  #  Normalize input spectra
  #-------------------------------------------------------------------------
  if (internorm) 
    {
    print ""
    print " *** Normalisation process - interactive analyse  ***"
    print " *** Press 'space' key to examine pixel positions ***"
    print " *** Press 'q' key to quit ***" 
    implot (imglines) 
    }
  
  print ""
  print ("Introduce intervale to normalise spectra: ")
  print ("  Minimum value =")
  scanf ("  %d",stat_inf)
  print ("  Maximum value =")
  scanf ("  %d",stat_sup)
  if (stat_inf >= stat_sup)
    {
    beep
    print("")
    print("ERROR: input data wrong")
    print("lfcalib aborted")
    print("")
    beep
    bye
    }  
    
  lstatist ( image = imglines//"["//stat_inf//":"//stat_sup//"]",
           nsigrej = 5.,
           maxiter = 10,
             print = no,
           verbose = no,
         addheader = no,
	  oneparam = "mean",
             lower = INDEF,
             upper = INDEF)          
  
  norm_factor = lstatist.mean
  
  if (norm_factor == 0)
    {
    beep
    print("")
    print("ERROR: factor scale")
    print("lfcalib aborted")
    print("")
    beep
    bye
    }
  
  if (verbose) print "INFO: level factor = "//norm_factor
  
  norm_factor = 1/norm_factor
  
  imgnorm = mktemp (tmpdir//"lfcalibimgnorm")
  imcalc ( input = imglines,
          output = imgnorm,
          equals = "im1*"//norm_factor,
         pixtype = "old",
         nullval = 1.,
         verbose = no)   
  
  ##########################################################################
  #  Make black body spectra with the same flux than normalized spectra
  #     3 cases: bbody | model| infile
  #-------------------------------------------------------------------------
  if ( inobb != "" || inotel != "" || mfint != "none")
    {
    # Check input image parametres
    imgets(image=ini,param="i_naxis1")
    colums = int(imgets.value)
 
    imgets(image=ini,param="CRVAL1")
    wave_start = int(imgets.value)
 
    imgets(image=ini,param="CD1_1")
    wave_end = int(imgets.value)*colums + wave_start
 

    #######
    # Black body option
    #######
    if (stmod == "bbody")
      {
      if (verbose) print "processing black body spectra ..."
      # Build black body spectra
      imgbbody_aux = mktemp (tmpdir//"lfcalibimgbbodyaux")
      mk1dspec ( input = imgbbody_aux,
        	output = "",
        	    ap = bodyopt.ap,
        	    rv = bodyopt.rv,
        	     z = bodyopt.z,
        	 title = "Blackbody "//temperature,
        	 ncols = colums,
        	  naps = 1,
        	header = ini,
        	wstart = wave_start,
        	  wend = wave_end,
             continuum = bodyopt.continuum,
        	 slope = bodyopt.slope,
           temperature = temperature,
        	   fnu = bodyopt.fnu,
        	 lines = bodyopt.lines,
        	nlines = bodyopt.nlines,
               profile = bodyopt.profile,
        	  peak = bodyopt.peak,
        	 gfwhm = bodyopt.gfwhm,
        	 lfwhm = bodyopt.lfwhm,
        	  seed = bodyopt.seed,
              comments = bodyopt.comments)
      } # End of if (stmodel == "bbody")
    #######
    # Model option
    #######
    else 
      {
      if (stmod == "model")
        {
        if (verbose) 
	  {
	  print ""
	  print "processing model spectra "//fmodel//" ..."
	  }
        # Adapt spectra to current range
        imgbbody_aux = mktemp (tmpdir//"lfcalibimgbbodyaux")
  	dispcor (    input = path//fmodel,
  		    output = imgbbody_aux,
  		 linearize = yes,
  		  database = "database",
  		     table = "",
  			w1 = wave_start,
  			w2 = wave_end,
  			dw = INDEF,
  			nw = colums,
  		       #log = no,
  		      flux = yes,
  		  samedisp = no,
  		    global = no,
  		 ignoreaps = no,
  		   confirm = no,
  		  listonly = no,
  		   verbose = yes,
  		   logfile = "")
  	} # End of if (stmod == "model")
      else #if (stmod == filename)
  	{
  	if (verbose) 
	  {
	  print ""
	  print "processing input spectra ..."
	  }
	  
  	# Adapt spectra to current range
  	imgbbody_aux = mktemp (tmpdir//"lfcalibimgbbodyaux")
  	dispcor (    input = stmod,
  		    output = imgbbody_aux,
  		 linearize = yes,
  		  database = "database",
  		     table = "",
  			w1 = wave_start,
  			w2 = wave_end,
  			dw = INDEF,
  			nw = colums,
  		       #log = no,
  		      flux = yes,
  		  samedisp = no,
  		    global = no,
  		 ignoreaps = no,
  		   confirm = no,
  		  listonly = no,
  		   verbose = yes,
  		   logfile = "")
 
        } # End of else #if (stmod == filename)
      }
    # Normalize black body with star flux
    lstatist ( image = imgbbody_aux//"["//stat_inf//":"//stat_sup//"]",
    	     nsigrej = 5.,
    	     maxiter = 10,
    	       print = no,
    	     verbose = no,
    	   addheader = no,
    	    oneparam = "mean",
    	       lower = INDEF,
    	       upper = INDEF)
 
    norm_factor = lstatist.mean
 
    if (norm_factor == 0)
      {
      beep
      print("")
      print("ERROR: black body factor scale")
      print("lfcalib aborted")
      print("")
      beep
      bye
      }
 
    norm_factor = 1/norm_factor
    
    imgbbody = mktemp (tmpdir//"lfcalibimgbbody")
    imcalc ( input = imgbbody_aux,
    	    output = imgbbody,
    	    equals = "im1*"//norm_factor,
    	   pixtype = "old",
    	   nullval = 1.,
    	   verbose = no)
    
    imdelete (imgbbody_aux,yes,ver-)
    }# End of if ( inobb != "" || inotel != "")
    
      
  ##########################################################################
  #  Delete model features 
  #-------------------------------------------------------------------------
  if (mfint != "none" && stmod != "bbody" \
      && (inobb != "" || inotel != "" \
      || inmfit != ""|| inmlines != ""))
    {
    if (verbose) print "Deleting features of model ..."
    imgbbodyfit = mktemp(tmpdir//"lfcalibimgbbodyfit")
    
    sfit ( input = imgbbody,               
          output = imgbbodyfit,               
             ask = "yes",          
           lines = "*",           
           bands = "1",           
            type = "fit",         
         replace = no,            
       wavescale = yes,           
        logscale = no,            
        override = no,            
        listonly = no,            
        logfiles = "logfile",     
     interactive = yes,           
          sample = "*",           
        naverage = 3,             
        function = "spline3",     
           order = 2,             
      low_reject = 2.,            
     high_reject = 2.,            
        niterate = 3,             
            grow = 1.,            
         markrej = yes,           
        graphics = "stdgraph",    
          cursor = "")  
    
    imgbbodylines = mktemp (tmpdir//"lfcalibimgbbodylines")
    imcopy (imgbbody,imgbbodylines,ver-)
    delmodel = yes
    
    if ((mfint == "samefet" || mfint == "sameinter") && fitdone)
      {
      list1 = intervli 
      While (fscan(list1,fitinterv) != EOF)
        {
        if (verbose) print "changing interval "//fitinterv//"..."
        imcopy(imgbbodyfit//fitinterv,imgbbodylines//fitinterv,ver-)
        }
      }
        
	
    if (mfint == "interfet" || mfint == "sameinter")
      {
      print ("Do you want to correct lines (0=no/1=yes) ")
      scanf ("  %d",stat_inf)
      stat_sup = -1
      if (stat_inf != 0) 
        {
        print " *** Feature process - interactive analyse  ***"
        print " *** Press 'space' key to examine pixel positions ***"
        print " *** Press 'q' key to quit ***" 
        implot (imgbbodylines)
        }
    
    
      While (stat_inf != 0 && stat_sup != 0)
        {
        print ("Introduce intervale to replace (0 to quit, neg to correct) : ")
        print ("  Minimum value =")
        scanf ("  %d",stat_inf)
        if (stat_inf > 0)
          {
          print ("  Maximum value =")
          scanf ("  %d",stat_sup)
          if (stat_sup > 0)
            {
            fitinterv = "["//stat_inf//":"//stat_sup//"]"
            imcopy(imgbbodyfit//fitinterv,imgbbodylines//fitinterv,ver-)
            }
          }
        }
      }
    }
  else if (inotel != "")
    {
    delmodel = no
    imgbbodylines = imgbbody
    }

  
    
  ##########################################################################
  #  Made tellurique correction funtion
  #-------------------------------------------------------------------------
  if ( inotel != "" )
    {
    if (verbose) print "processing tellurique correction function ..."
    
    imgtel = mktemp (tmpdir//"lfcalibimgtel")
    imarith (operand1 = imgnorm,
                   op = "/",
             operand2 = imgbbodylines,
               result = imgtel,
                title = "",	     
              divzero = 0.,	     
              hparams = "",	     
              pixtype = "",	     
             calctype = "",	     
              verbose = no) 
    }
  
  
  ##########################################################################
  #  Delete temporary files
  #-------------------------------------------------------------------------
  if (stfeature)
    { 
    if (infit == "") imdelete (imgfit,yes,ver-)
    else imrename (imgfit, infit, ver-)
    
    if (inlines == "" && delimglines) imdelete (imglines,yes,ver-)
    else if (delimglines) imrename (imglines, inlines, ver-)
    
    if (fitdone) delete (intervli,yes,ver-, >>&"/dev/null")
    }
  
  if (mfint != "none")
    { 
    if (inmfit == "" && delmodel) imdelete (imgbbodyfit,yes,ver-)
    else if (delmodel) imrename (imgbbodyfit, inmfit, ver-)
    
    if (inmlines == "" && delmodel) imdelete (imgbbodylines,yes,ver-)
    else if (delmodel) imrename (imgbbodylines, inmlines, ver-)
    }
  
  if (inobb != "") imrename (imgbbody, inobb, ver-, >>&"/dev/null")
  if (inotel != "" || mfint != "none") imdelete (imgbbody,yes,ver-, >>&"/dev/null")
  # else imgbbody does not exist 
  
  if (inotel != "") imrename (imgtel, inotel, ver-)
  # else imgtel does not exist
  
  if (inonorm == "") imdelete (imgnorm,yes,ver-)
  else imrename (imgnorm, inonorm, ver-)
  
  list1 = ""

end
