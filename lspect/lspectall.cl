# lspectr - generate combined image from spectrum acquisition
# Author : Miguel Charcos (mcharcos@ll.iac.es)
# Version: 19. Aug. 2003
##############################################################################
procedure lspectall(input,output)

string	input		{prompt="List of dither images"}
string	output		{prompt="Name of output file"}
string	spcombine	{"onedspec",enum="onedspec|twodspec",prompt="Method used to combine images (onedspec|twodspec)"}
string	subsky		{"combsky",enum="none|usrsky|combsky",prompt="Subtract sky (none|usrsky|combsky)"}
string  insky		{"",prompt="name of input sky image"}

# Names for outputs saved images
string	outAB		{"",prompt="prefix name of A-B sustracted images"}
string	outap		{"",prompt="Prefix name of individual output spectra"}

# correction parameters and directories
string  inmask  	{"",prompt="name of input mask file"}
string 	trspat		{"default",prompt="name of spatial correction file (default|<filename>)"}
string 	trspec		{"default",prompt="name of spectral correction file (default|<filename>)"}
string  tmpdir  	{")_.tmpdir",prompt="Temporary directory for file conversion"}
string  stddir  	{")_.stddir",prompt="Parametre directory for transformations"}

# Spectral caracteristics
int	numspct		{1,prompt="Number of spectra to extract"} 
int 	line		{750,prompt="Dispersion line"}
int	nsum		{50,prompt="Number of dispersion lines to sum or median"}

# correction options
bool 	corrow		{"no",prompt="Change bad rows?"}
bool 	ressky		{no,prompt="Delete line sky residue"}

# apall parametres
pset	lapopt	{prompt="Apall configuration parametres"}

# combine parametres
pset	combopt		{prompt="Imcombine configuration parametres"}

# display and interactive options
bool	verbose		{yes,prompt="Verbose"}
pset	dispstep	{prompt="Steps display parameter configuration"}		
bool 	interactive	{yes,prompt="Set spectre selection interactively?"}


string *list1	{prompt="Ignore this parameter(list1)"}

begin 

  string	ini,ino,prefout,isi,imk,imkcorrect,imtspatial,imtlambda
  string	tmpl,inli,tmplaux
  string	prepostli,corrowli,subli,transli,resli,reslired,axisli,apli
  string 	imAli,imBli
  string	imsubsky,skysub
  string	corref
  string	logf,fname,imref,imA,imB,imAB,sky,imcross,imaux
  string	junk1,junk2,junk3
  string	typespct
  string	prefixAB
  int		nsc,value,cont,contmax,numberimg
  int		dispax,fitax,i
  bool		first,oneimage,correction,delprepostli


  # --------------------------------------------------------------------
  # Verifications
  # --------------------------------------------------------------------
  ################
  #
  #  The first step consist in verify options and correct input variables.
  #
  #  Checked options are:
  #
  #		- mask used
  #		- spatial and spectral correction
  #		- show output option STDOUT or log file
  #
  #
  #  The variables verified are:
  #
  #		- output image: if exist --> error because overwrite
  #		- mask introduced and do not exist --> error because do not exist
  #		- geometric correction files introduced and do not exist (or
  #		  its format is wrong) --> error because wrong files
  #					
  #
  #
  ################
  
  if (verbose) 
    {
    print ""
    print "verification of variables"
    }

  # copy input arguments to force definition at the beginning of the script
  ini = input
  ino = output
  isi = insky
  prefout = outap
  
  
  ######
  # Analysis of choosen options
  ######
  
  if (prefout == "") 
    {prefout = "lspectr"}
  
  # check if mask will be used
  if (inmask == "") {imk = ""}
  else {imk = stddir//inmask}
  
  # check if spatial distorsion correction will be applied
  if (trspat == "") {imtspatial = ""}
  else if (trspat == "default") {imtspatial = "default"}
  else {imtspatial = "fc"//trspat}
  # check if wavelength calibration will be applied
  if (trspec == "") {imtlambda = ""}
  else if (trspec == "default") {imtlambda = "default"}
  else {imtlambda = "fc"//trspec}
  
  # decide if to show output
  if ( verbose )
    logf = "STDOUT"
  else
    logf = ""
  
  # check if input sky image exists
  if (subsky == "usrsky")
    {
    limgaccess(isi, verbose=no)
    if ( limgaccess.exists )
      {print("INFO: input sky image found.")}
    else
      {
      print("WARNING: input sky image not found")
      subsky = "none"
      }
    }

  # expand input image names.
  inli = mktemp(tmpdir//"lspectrinli")
  sections(ini,option="fullname",> inli)
  
  # check how many input images were introduced
  numberimg = 0
  first = yes
  list1 = inli
  while (fscan(list1, fname) != EOF)
    {
    numberimg = numberimg +1
    if (first)
      {
      if (verbose) print("INFO: ",fname," is de reference image")
      first = no
      }
    }
  if (verbose) print "INFO: image list have "//numberimg//" images"
  
  prefixAB = outAB
  if (prefixAB == "") 
    {
    if (verbose) print "INFO: sky sustracted images will not be saved"
    prefixAB = "lspectr"
    }
  else
    {
    if (verbose) print "INFO: sky sustracted images will be saved"
    }
  
  ######
  # Verification of correct input variables
  ######
  
  
  # expand output image name.
  tmpl = mktemp(tmpdir//"lspectr")
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

   
  # check if mask file exist
  lmaskaccess(imk, verbose=no)
  if ( lmaskaccess.exists)
    {
    print("INFO: input mask image found")
    }
  else if (imk == "")
    {
    print("INFO: no input mask image")
    }
  else #if (imk != "")
    {
    beep
    print("")
    print("ERROR: input mask image not found")
    print("lspectr aborted")
    print("")
    beep
    bye
    }
  
  
  # check if geometric correction file exist
  correction = yes  
  
  
  # if default options for transform we search files
  if (imtspatial == "default" || imtlambda == "default")
    {
    list1 = inli
    nsc = fscan (list1,fname)
    lcorrfile (input = fname,
             fbpmask = lirisdr.bpmdb,
             fbcmask = lirisdr.bcmdb,      
            fgeodist = lirisdr.gdistdb,    
             ftransf = lirisdr.fcdb, 
	      stddir = stddir,
             verbose = verbose) 
    
    if (imtspatial == "default")
      {
      imtspatial = lcorrfile.trspat
      if (imtspatial == "none" || imtspatial == "unknown")
        {
	if (verbose) print "WARNING: default spatial transform file not found"
	imtspatial = ""
	  }
      }
    if (imtlambda == "default")
      {
      imtlambda = lcorrfile.trspec
      if (imtlambda == "none" || imtlambda == "unknown")
        {
	if (verbose) print "WARNING: default spectral transform file not found"
	imtlambda = ""
	}
      }
    
    }
  
  if (imtspatial != "")
    {
    if ( access(stddir//imtspatial))
      {if (verbose) print("INFO: spatial transform file found")}
    else 
      {
      if (verbose) 
        {
	print "WARNING: spatial transform file not found"
	print "         spatial transformation will not be done"
	}
      imtspatial = ""
      correction = no
      }
    } # end of if (imtspatial != "" && imtspatial != "default")
  
  if (imtlambda != "")
    { 
    if ( access(stddir//imtlambda))
      {if (verbose) print("INFO: spectral transform file found")}
    else 
      {
      if (verbose) 
        {
	  print "WARNING: spectral transform file not found"
	  print "         spectral transformation will not be done"
	  }
      imtlambda = ""
      }
    } # end of if (imtlambda != "" && imtlambda != "default")

  if (imtspatial == "" && imtlambda == "")
    {
    correction = no
    print "WARNING: no correct correction file format"
    }
  else 
    {
    if (imtspatial != "")
      {
      i = strlen(imtspatial)
      imtspatial = substr(imtspatial,3,i)
      }
    if (imtlambda != "")
      {
      i = strlen(imtlambda)
      imtlambda = substr(imtlambda,3,i)
      }
    }

  if (verbose)
    {
    print ("variables verified")
    print ""
    }
  
  ######################################################################
  #
  #  Variables created: 
  #		- numberimg: control how many images are
  #		- inli: list with input images
  #		- imk: name of mask image if inmask introduced
  #		       else imk=""
  #		- imtspatial: name of spatial correction file if trspat introduced
  #		       else imtspatial=""
  #		- imtlambda: name of spatial correction file if trspec introduced
  #		       else imtlambda=""
  #		- logf: if verbose STDOUT else "" 
  #		- secondstep = subsky == "combsky" && stmask
  #
  #
  #  Variable erased: none variable erased
  #
  #  Variable created + erased: none variable
  #		
  #  Temporary variables used localy and existing yet: 
  #		- ini: force definition of input image list
  #		- ino: force definition of output image name
  #		- isi: force definition of input sky name
  #		- tmpl: expand output file
  #		- first: control oneinsky, numberimg
  #		- fname: check existance of output image, reference image
  #			 
  #  
  #  State of files and images:
  #     
  #		- always inli --> contain name of input images
  #
  ######################################################################
  # --------------------------------------------------------------------
  # End of verifications
  # --------------------------------------------------------------------

    
  ######################################################################
  #  Row and lines bad pixel corrections
  #---------------------------------------------------------------------
  
  ##########
  # We change rows if bad original images and we interpolate central rows
  # and lines if choosen
  ##########
  
  if (corrow)
    {
    if (verbose)
      {
      print ""
      print "correcting bad rows and lines..."
      }
      
    corrowli = mktemp(tmpdir//"lspectrcorrowli")
    lcpixmap (input = "@"//osfn(inli),     
    	     output = "lspectrimcorrow_", 
    	    outlist = corrowli,   
    	    verbose = verbose,
             tmpdir = tmpdir,
    	     stddir = stddir)
    
    if (verbose)
      {
      print "bad rows and lines corrected"
      print ""
      }
    }      
  else  
    {
    if (verbose)
      {
      print ""
      print "INFO: Bad rows and lines no corrected"
      print ""
      }
    corrowli = inli
    }
    
  #---------------------------------------------------------
  # End of bad row correction
  ##########################################################
  
  # --------------------------------------------------------------------
  #  Verify image format and have pre-post treatment if necesary
  #  Image result can be unique format
  # --------------------------------------------------------------------
  # Check if they are already pre read subtracted images containing a wcs
  if (verbose)
    {
    print ""
    print "verifying image format ..."
    }
  
  prepostli = mktemp(tmpdir//"lspectrprepostli")
  
  llistdiff (input = "@"//corrowli,         
            output = prepostli,             
             pname = mktemp("lspectr")//"_",  
           verbose = no,
            tmpdir = tmpdir)
  
  delprepostli = !llistdiff.original && !lcpixmap.original
  
  if (verbose)
    {
    print "image format verified"
    print ""
    }
  
  ######################################################################
  #
  #  Variables created: 
  #		- prepostli
  #
  #
  #  Variable erased: none variable erased
  #
  #  Variable created + erased: none variable
  #		
  #  Temporary variables used localy and existing yet: none variable
  #		
  #			 
  #  
  #  State of files and images:
  #     
  #		- always inli --> contain name of input images
  #		- prepostli --> contain list of images prepost treated
  #		- if prepost-treated @prepostli --> input images
  #		  else	@prepostli --> if !delprepostli = input image names
  #				       else = temporary images 
  #
  ######################################################################
  # --------------------------------------------------------------------
  #  End of pre-post treatment
  # -------------------------------------------------------------------- 

  # --------------------------------------------------------------------
  # Verify if sky would have to be substracted of image and substract sky 
  # if it is necesary
  # --------------------------------------------------------------------
  #################
  #
  #  In this step we substract sky of the images making A-B or
  #  substracting directly input user sky
  #  Task used is lspctsky
  #
  #################
    
  if ( subsky == "none" )
    {
    if (verbose) print "None sky image substracted"
    subli = prepostli
    typespct = "single"
    } # end of if ( subsky == "none" )
  else #if ( subsky != "none" )
    {
    if (verbose)
      {
      print ""
      print "sky treatment"
      }
    
    subli = mktemp(tmpdir//"lspectrsubli")
    
    if ( subsky == "combsky")
      {
      combspsky.nlow = int(0.5+0.05*numberimg)
      combspsky.nhigh = int(0.5+0.25*numberimg)
      combspsky.scale = combopt.scale
      lspctsky ( input = "@"//prepostli,    
        	output = prefixAB,          
               outlist = subli,
        	 insky = "",	       
        	outsky = "",	       
        	tmpdir = tmpdir,      
               verbose = verbose)
      
      typespct = "AB"
      } # end of if ( subsky == "combsky")
    if ( subsky == "usrsky" )
      {
      combspsky.nlow = int(0.5+0.05*numberimg)
      combspsky.nhigh = int(0.5+0.25*numberimg)
      combspsky.scale = combopt.scale
      lspctsky ( input = "@"//prepostli,      
        	output = prefixAB,          
               outlist = subli,  
        	 insky = isi,	       
        	outsky = "",	       
        	tmpdir = tmpdir,        
               verbose = verbose)
      
      typespct = "single"
      } #end of if ( subsky == "usrsky")
    
    if (verbose)
      {
      print "sky treated"
      print ""
      }
    
    } # end of else [if ( subsky == "none" )]
  
  
  ######################################################################
  #
  #  Variables created: 
  #		- subli (if  (subsky no "none"))
  #
  #
  #  Variable erased: none variable erased
  #
  #  Variable created + erased: none variable
  #		
  #  Temporary variables used localy and existing yet: none variable
  #		
  #			 
  #  
  #  State of files and images:
  #     
  #		- always inli --> contain name of input images
  #		- prepostli --> contain list of images prepost treated
  #		- if prepost-treated @prepostli --> input images
  #		  else	@prepostli --> if !delprepostli = input image names
  #				       else = temporary images 
  #		- if (corrow) corrowli --> contain list of images corrected
  #		  else corrowli = prepostli
  #		- if (corrow) @corrowli --> temporary images
  #		- if (subsky != "none") subli --> contain list with sky sub images
  #		  else subli = corrowli
  #		- if (subsky != "none") @subli --> temporary images
  #					       	   
  #
  ######################################################################  
  # --------------------------------------------------------------------
  #  End of substraction of sky
  # --------------------------------------------------------------------


  # --------------------------------------------------------------------
  #  If images are original we copy their in new file for edit header 
  # --------------------------------------------------------------------
  if (delprepostli == no && subsky == "none" && corrow == no)
    {
    axisli = mktemp (tmpdir//"lspectraxisli")
    lnamelist( input = "@"//prepostli,    
              output = axisli,	  
               bname = "lspectrimaxis",	     
               pname = "",
	     refname = "@"//(inli),
	      maxnum = INDEF,
              extens = "")
    imcopy ("@"//prepostli,"@"//axisli,ver-)
    }
  else
    {axisli = subli}
  # --------------------------------------------------------------------
  #  End of image copy
  # --------------------------------------------------------------------
  
  # --------------------------------------------------------------------
  #  Determine of general offset between inages
  #  Determine global shift using image headers
  # --------------------------------------------------------------------
  #################
  #
  #  Add BPM field in the image headers.
  #  No variables have been created.
  #
  #################
  
  if (verbose)
    {
    print ""
    print "adding BPM field header of images of list"
    }
    
  list1 = axisli
  nsc = fscan(list1, fname)
  lcheckfile(fname,verbose=no)
  if (lcheckfile.format == "ImpB") dispax = 2
  else if (lcheckfile.format == "UDAS") dispax = 1
  else if (lcheckfile.format == "UNIC") dispax = 1
  else if (lcheckfile.format == "unknown") dispax = 2
    
  list1 = axisli
  while (fscan(list1, fname) != EOF)
    {
    if ( imk != "" )
      {
      hedit(images=fname,fields="BPM",value=imk,add+,del-,ver-,show-,upd+)
      }
    hedit(images=fname,fields="DISPAXIS",value=dispax,add+,del-,ver-,show-,upd+)
    }
  
  if (verbose)
    {
    print "BPM field header added"
    print ""
    }
  # --------------------------------------------------------------------
  #  End of dispertion axis calculation
  # -------------------------------------------------------------------- 


  # --------------------------------------------------------------------
  #  Spatial and spectral correction
  # --------------------------------------------------------------------
  ###################
  #
  #  We correct images in spectral and spatial direction using
  #  transform task. If correction mask is also corrected.
  #
  ###################
  
  
  if (correction)
    {
    if (verbose)
      {
      print ""
      print "correcting distortion ..."
      }
     
    transli = mktemp(tmpdir//"lspectrtransli")
    lnamelist (input = "@"//(axisli),
              output = transli,
               bname = "lspectrtransli",
               pname = "",
	     refname = "@"//(axisli),
              maxnum = INDEF,
              extens = "",
              tmpdir = tmpdir)   
    
    if (imk != "") {imkcorrect = mktemp(tmpdir//"lspectrimkcor")}  
    else {imkcorrect = ""} 
    lfilename(imk)
    
    ltransform ( input = "@"//(axisli),              
        	output = "@"//(transli),
        	trspat = imtspatial,
        	trspec = imtlambda,
        	inmask = lfilename.root,
               outmask = imkcorrect,
        	tmpdir = tmpdir,
        	stddir = stddir,
               verbose = verbose,
        	    x1 = INDEF,
        	    x2 = INDEF,
        	    nx = INDEF,
        	    y1 = INDEF,
        	    y2 = INDEF,
        	    ny = INDEF,
            interptype = "spline3")
    
    if (verbose)
      {
      print "distortion corrected"
      print ""
      }
    
    # We can visualise result (every images corrected)
    if (disptransf && interactive)
      {
      list1 = transli
      While (fscan(list1,fname) != EOF)
        {
	print ""
	print "******** Press q to quit *********"
	print ""
        display(fname,1)
        imexamine
        }
      }
    
    } # end of if (correction)
  else
    {
    if (verbose)
      {
      print ""
      print "INFO: no correction"
      print ""
      }
    imkcorrect = imk
    transli = subli
    }
    
  ######################################################################
  #
  #  Variables created: 
  #		- imkcorrect (if mask and correction)
  #		- transli (if correction)
  #
  #  Variable erased: none variable erased
  #
  #  Variable created + erased: none variable
  #		
  #  Temporary variables used localy and existing yet: none variable
  #		
  #  State of files and images:
  #     
  #		- always inli --> contain name of input images
  #		- prepostli --> contain list of images prepost treated
  #		- if prepost-treated @prepostli --> input images
  #		  else	@prepostli --> if !delprepostli = input image names
  #				       else = temporary images
  #		- if (corrow) corrowli --> contain list of images corrected
  #		  else corrowli = prepostli
  #		- if (corrow) @corrowli --> temporary images
  #		- if (subsky != "none") subli --> contain list with sky sub images
  #		  else subli = corrowli
  #		- if (subsky != "none") @subli --> temporary images 
  #		- if correction transli --> contain list with images corrected
  #		  else transli = subli
  #		- if (correction) @transli --> temporary images
  #		- if (imk!="") imkcorrect --> if (correction) corrected mask
  #		  		  	      else imkcorrected = imk
  #					       	   
  #
  ###################################################################### 
  # --------------------------------------------------------------------
  #  End of spatial and spectral correction
  # --------------------------------------------------------------------
  
  
    
  # --------------------------------------------------------------------
  #  Erase sky residue
  # --------------------------------------------------------------------
  ##################
  #
  #  When sky is substracted some residual lines stay at the image
  #  Task fit1d allow to delete these lines. The result is saved 
  #  with the same name.
  #
  ##################
  
  if (ressky)
    {
    if (verbose)
      {
      print ""
      print "deleting residual sky lines ..."
      }
    
    if (dispax == 1)  fitax = 2
    else fitax = 1
    
    resli = mktemp(tmpdir//"lspectrresli")
    lnamelist (input = "@"//(transli),
              output = resli,
               bname = "lspectrresli",
               pname = "",
	     refname = "@"//(transli),
              maxnum = INDEF,
              extens = "",
              tmpdir = tmpdir) 
    
    fit1d (input = "@"//osfn(transli),
    	  output = "@"//osfn(resli),
    	    type = "difference",
    	    axis = fitax,
     interactive = no,
    	  sample = "*",
    	naverage = -9,
    	function = "spline3",
    	   order = 3,
      low_reject = 3.,
     high_reject = 3,
    	niterate = 3,
    	    grow = 3.,
    	graphics = "stdgraph",
    	  cursor = "")
     
    if (verbose)
      { 
      print "residual lines deleted"
      print ""
      }
    
    # Visualise result  
    if (dispsubresidu && interactive)
      {
      list1 = resli
      While (fscan(list1,fname) != EOF)
        {
	print ""
	print "******** Press q to quit *********"
	print ""
        display(fname,1)
	imexamine
        }
      }
    }
  else 
    {
    resli = transli
    if (verbose)
      {
      print ""
      print "INFO: Residual sky lines do not be delete"
      print ""
      }
    }
    
  ######################################################################
  #
  #  Variables created: 
  #		- resli (if ressky)
  #
  #
  #  Variable erased: none variable erased
  #
  #  Variable created + erased: none variable
  #		
  #  Temporary variables used localy and existing yet: none variable
  #		
  #  State of files and images:
  #     
  #		- always inli --> contain name of input images
  #		- prepostli --> contain list of images prepost treated
  #		- if prepost-treated @prepostli --> input images
  #		  else	@prepostli --> if !delprepostli = input image names
  #				       else = temporary images 
  #		- if (corrow) corrowli --> contain list of images corrected
  #		  else corrowli = prepostli
  #		- if (corrow) @corrowli --> temporary images
  #		- if (subsky != "none") subli --> contain list with sky sub images
  #		  else subli = corrowli
  #		- if (subsky != "none") @subli --> temporary images 
  #		- if correction transli --> contain list with images corrected
  #		  else transli = subli
  #		- if (correction) @transli --> temporary images
  #		- if (imk!="") imkcorrect --> if (correction) corrected mask
  #		  		  	      else imkcorrected = imk
  #		- if (ressky) resli --> contain list of substracted residual lines
  #		  else resli = transli
  #		- if (ressky) @resli --> temporary images
  #					       	   
  #
  ###################################################################### 
  # --------------------------------------------------------------------
  #  End of sky residue deleting
  # --------------------------------------------------------------------
  
  # --------------------------------------------------------------------
  #  Combine images 
  # --------------------------------------------------------------------
  ###############
  #
  #  Now we coadd images if we want combinated result or we present
  #  images treated and selected by user without coadd
  #
  ###############
  
  if ( spcombine == "twodspec" )
    {
    if (verbose)
      {
      print ""
      print "coadding images ...."
      }
    
    reslired = mktemp(tmpdir//"lspectrreslired")
    
    # Definition of combine parametres
    combspct.plfile     =  combopt.plfile 		 
    combspct.sigma      =  combopt.sigma   
    combspct.reject     =  combopt.reject  
    combspct.outtype    =  combopt.outtype 
    combspct.scale      =  combopt.scale 
    combspct.zero       =  combopt.zero 
    combspct.weight     =  combopt.weight 
    combspct.statsec    =  combopt.statsec 
    combspct.expname    =  combopt.expname  
    combspct.nlow       =  combopt.nlow 
    combspct.nhigh      =  combopt.nhigh
    combspct.nkeep      =  combopt.nkeep
    combspct.lsigma     =  combopt.lsigma 
    combspct.hsigma     =  combopt.hsigma 
    combspct.rdnoise    =  combopt.rdnoise 
    combspct.gain       =  combopt.gain 
    combspct.snoise     =  combopt.snoise 
    combspct.sigscale   =  combopt.sigscale 
    combspct.pclip      =  combopt.pclip 
    combspct.grow       =  combopt.grow 
    
    
    combapall.find      = lapopt.find
    combapall.recenter  = lapopt.recenter
    combapall.resize    = lapopt.resize
    combapall.edit      = lapopt.edit
    combapall.trace     = lapopt.trace
    combapall.fittrace  = lapopt.fittrace
    combapall.extract   = lapopt.extract
    combapall.extras    = lapopt.extras
    combapall.review    = lapopt.review

    combapall.lower     = lapopt.lower
    combapall.upper     = lapopt.upper
    combapall.apidtable = lapopt.apidtable
    
    combapall.b_function    = lapopt.b_function
    combapall.b_order       = lapopt.b_order
    combapall.b_sample      = lapopt.b_sample
    combapall.b_naverage    = lapopt.b_naverage
    combapall.b_niterate    = lapopt.b_niterate
    combapall.b_low_reject  = lapopt.b_low_reject
    combapall.b_high_reject = lapopt.b_high_reject
    combapall.b_grow        = lapopt.b_grow

    combapall.width     = lapopt.width
    combapall.radius    = lapopt.radius
    combapall.threshold = lapopt.threshold

    combapall.minsep = lapopt.minsep
    combapall.maxsep = lapopt.maxsep
    combapall.order  = lapopt.order

    combapall.aprecenter = lapopt.minsep
    combapall.npeaks     = lapopt.npeaks
    combapall.shift      = lapopt.shift

    combapall.llimit    = lapopt.llimit
    combapall.ulimit    = lapopt.ulimit
    combapall.ylevel    = lapopt.ylevel
    combapall.peak      = lapopt.peak
    combapall.bkg       = lapopt.bkg
    combapall.r_grow    = lapopt.r_grow
    combapall.avglimits = lapopt.avglimits

    combapall.t_nsum        = lapopt.t_nsum
    combapall.t_step        = lapopt.t_step
    combapall.t_nlost       = lapopt.t_nlost
    combapall.t_function    = lapopt.t_function
    combapall.t_order       = lapopt.t_order
    combapall.t_sample      = lapopt.t_sample
    combapall.t_naverage    = lapopt.t_naverage
    combapall.t_niterate    = lapopt.t_niterate
    combapall.t_low_reject  = lapopt.t_low_reject
    combapall.t_high_reject = lapopt.t_high_reject
    combapall.t_grow        = lapopt.t_grow

    combapall.background = lapopt.background
    combapall.skybox     = lapopt.skybox
    combapall.weights    = lapopt.weights
    combapall.pfit       = lapopt.pfit
    combapall.clean      = lapopt.clean
    combapall.saturation = lapopt.saturation
    combapall.readnoise  = lapopt.readnoise
    combapall.gain       = lapopt.gain
    combapall.lsigma     = lapopt.lsigma
    combapall.usigma     = lapopt.usigma
    combapall.nsubaps    = lapopt.nsubaps

    
    lspctcombine (input = "@"//osfn(resli),
             	 output = ino,
	      outspectr = prefout,
	      #outspectr = "lspectr",
	        outlist = reslired,
                combine = "average",
               typespct = typespct,
	           line = line,
		   nsum = nsum,
             	 tmpdir = tmpdir,
             	 stddir = stddir,
               intersel = (dispstep.dispsel && interactive), 
	        interap = (dispstep.dispext && interactive), 	  
                verbose = verbose)
      

    if (verbose)
      {
      print "images coadded"
      print ""
      }
    }
  else # if ( spcombine == "onedspec" )
    {
    if (verbose) 
      {
      print ""
      print "Extraction process ..."
      }
      
    
    reslired = mktemp(tmpdir//"lspectrreslired")
    
    # Definition of combine parametres
    apcomb.plfile     =  combopt.plfile 	          
    apcomb.sigma      =  combopt.sigma 	 	                  
    apcomb.reject     =  combopt.reject  	     
    apcomb.outtype    =  combopt.outtype 	     
    apcomb.scale      =  combopt.scale  	     
    apcomb.zero       =  combopt.zero 		     
    apcomb.weight     =  combopt.weight 	     
    apcomb.statsec    =  combopt.statsec 	     
    apcomb.expname    =  combopt.expname  
    apcomb.nlow       =	 combopt.nlow 		     
    apcomb.nhigh      =	 combopt.nhigh		     
    apcomb.nkeep      =	 combopt.nkeep	 
    apcomb.lsigma     =	 combopt.lsigma 	     
    apcomb.hsigma     =	 combopt.hsigma 	     
    apcomb.rdnoise    =  combopt.rdnoise 	     
    apcomb.gain       =  combopt.gain 
    apcomb.sigscale   =  combopt.sigscale 
    apcomb.pclip      =	 combopt.pclip 
    apcomb.grow       =	  combopt.grow  	 

    
    lspctapall (input = "@"//resli,              
               outspectr = prefout, 
	      #outspectr = "lspectr",               
              outlist = reslired,
	       output = ino,
           references = "",
	    apertures = "",
	     typespct = typespct,
	      numspct = numspct,
                 line = line,
                 nsum = nsum,
              interap = (dispstep.dispext && interactive),
           interapref = (dispstep.dispextref && interactive),
             intersel = (dispstep.dispsel && interactive),
		  statsel = (dispstep.dispstat && interactive),
	       tmpdir = tmpdir,
              verbose = verbose,
               tmpdir = tmpdir) 
    
    #if (prefout != "lspectr")
    #  {
    #  for (i=1;  i <= numspct ;  i += 1)
    #    {
    #    apli = mktemp (tmpdir//"lspectrapli")
    #	  lnamelist (input = "@"//(reslired)//"_"//i,
    #            output = apli,
    #             bname = "",
    #             pname = prefout,
    #	         refname = "@"//(reslired)//"_"//i,
    #            maxnum = INDEF,
    #            extens = "",
    #            tmpdir = tmpdir) 
    # 		    
    #	  imrename ("@"//reslired//"_"//i,"@"//apli,ver-)}
    #	  #delete (apli,yes,ver-)
    #    } 
    # end of for (i=1;  i <= numspct ;  i += 1)
    } # end of else if ( spcombine == "onedspec" )
    
  ######################################################################
  #
  #  Variables created: 
  #		- ino (if coaddition)
  #		- @ino_value (if no coaddition)
  #
  #
  #  Variable erased: none variable erased
  #
  #  Variable created + erased: none variable
  #		
  #  Temporary variables used localy and existing yet: 
  #		- fname (if no coadd): change name of reslired list
  #		- value (if no coadd): change name of reslired list
  #		
  #  State of files and images:
  #     
  #		- always inli --> contain name of input images
  #		- prepostli --> contain list of images prepost treated
  #		- if prepost-treated @prepostli --> input images
  #		  else	@prepostli --> if !delprepostli = input image names
  #				       else = temporary images 
  #		- if (corrow) corrowli --> contain list of images corrected
  #		  else corrowli = prepostli
  #		- if (corrow) @corrowli --> temporary images
  #		- if (subsky != "none") subli --> contain list with sky sub images
  #		  else subli = corrowli
  #		- if (subsky != "none") @subli --> temporary images 
  #		- if correction transli --> contain list with images corrected
  #		  else transli = subli
  #		- if (correction) @transli --> temporary images
  #		- if (imk!="") imkcorrect --> if (correction) corrected mask
  #		  		  	      else imkcorrected = imk
  #		- if (ressky) resli --> contain list of substracted residual lines
  #		  else resli = transli
  #		- if (ressky) @resli --> temporary images
  #		- if (combine) ino --> final result
  #		- if (!combine) @ino_value --> final results
  #					       	   
  #
  ######################################################################
  # --------------------------------------------------------------------
  #  End of combine images 
  # --------------------------------------------------------------------
   
   
  # --------------------------------------------------------------------
  #  Showing results 
  # --------------------------------------------------------------------
  if (dispres && interactive)
    {
    print ""
    print "presenting results"
    
    if (spcombine == "twodspec") 
      {
      display(ino,2)
      print "result image displayed"
      print ""
      print "******** Press q to quit *********"
      print ""
      imexamine
      }
    else # if (spcombine == "onedspec")
      {
      for (i=1;  i <= numspct ;  i += 1)
        {
        implot(ino//"_"//i)
        print ""
        print "******** Press q to quit *********"
        print ""
        } # end of for (i=1;  i <= numspct ;  i += 1)
      }  
    print "results presented"
    print ""
    }
  # --------------------------------------------------------------------
  #  End of result presentation 
  # --------------------------------------------------------------------
  
  
  
  # --------------------------------------------------------------------
  #  Empty memory and erase temporary files 
  # --------------------------------------------------------------------
  
  delete(inli, yes,ver-)
   
  if (delprepostli) imdelete ("@"//prepostli,yes,ver-) 
  delete (prepostli,yes,ver-)
  
  if (corrow) imdelete ("@"//corrowli,yes,ver-)
  if (corrow) delete (corrowli,yes,ver-)
  
  if (subsky != "none" && outAB == "") imdelete ("@"//subli,yes,ver-)
  if (subsky != "none") delete (subli,yes,ver-)
  
  if (correction) imdelete ("@"//transli,yes,ver-)
  if (correction) delete (transli,yes,ver-)
  
  if (ressky) imdelete ("@"//resli,yes,ver-, >>&"/dev/null")
  if (ressky) delete (resli,yes,ver-)
  
  if (imk != "" && correction) imdelete(imkcorrect,yes,ver-)
  
  delete (reslired//"*",yes,ver-, >>&"/dev/null")
  
    
  ######################################################################
  #
  #  Variables created: none variable
  #
  #
  #  Variable erased: ...
  #
  #  Variable created + erased: 
  #		- inli (always)
  #		- prepostli (always)
  #		
  #  Temporary variables used localy and existing yet: none variable
  #		
  #  State of files and images:
  #     
  #		- if (combine) ino --> final result
  #		- if (!combine) @ino_value --> final results
  #					       	   
  #
  ######################################################################
   
    
  # clear lists
  list1 = ""
 
 
end
