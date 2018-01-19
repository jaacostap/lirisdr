# ldedither - generate combined image from dither
#             could make two ldedither iteration using star mask in the second
# 		step
# Author : Miguel Charcos (mcharcos@ll.iac.es)
# Version: 15. Sep. 2003
#          28may04 - Possibility to zero offset when creating sky image (Jacosta)
# Version: 15 Nov 2004 - JAcosta
#	   The use of star masks is now done during the sky subtraction (JAcosta)
# Version: 21 Sep 2006 - JAcosta
#          Changed to be used as lirisdr 
# Version: 5 Jan 2007 - JAcosta
#	   Added two new parameters to create an exposure mask and a rejection 
#          mask (JAcosta)
# Version: March 2008 - JAcosta
#	   Image offsets can be fraction of pixels, use imshift to do interpolation
#	   of the fractional part and later imcombine offset integer offset to
#          avoid loosing part of the mosaic
# 	   Added possibility to use sigclip when combining images	
# Version: April-June 2011 - JAcosta
#          Move the sections where offsets are computed to a new module called
#          ligetoffset 
##############################################################################
procedure ldedither (input, output)

string	input	 {prompt="Name of file list of dither images"}
string	output	 {prompt="Name of output file"}
string	match	 {"wcs",prompt="Method used to match images (wcs|manual|pick1|<filename>)"}
bool	adjshift {no,prompt="Adjust the calculated shift from image headers"}
string  expmask	 {"",prompt="Name of exposure mask (optional)"}
string	rejmask	 {"",prompt="Name of rejection masks (optional)"}
string	subsky	 {"combsky",enum="none|usrsky|combsky",prompt="Subtract sky"}
string	insky	 {"",prompt="name of input sky list image"}

#Sky subtraction parameters
string	skycomb  {"cycle",enum="cycle|run|single",prompt="Sky combination mode"}
int     nditpts  {5,prompt="Number of dithern points per cycle"}

# Correction parameter files
string	inmask	 {"default",prompt="name of common mask file (default|<filename>)"}
string	incmask	 {"default",prompt="name of common fixpix mask file (default|<filename>)"}
string	inflat	 {"",prompt="name of flatfield correction file"}
string	intrans	 {"",prompt="name of geometric distortion correction file"}
string  weight   {"",prompt="Image  weights (applied when combining)"}   
bool 	corrow	 {no,prompt="Correct bad pixel mapping?"}
bool 	crtalk	 {no,prompt="Correct row cross talk?"}
bool	intprow	 {no,prompt="Interpolate central bad pixel rows?"}
bool	cvgrad   {yes,prompt="Correct vertical gradient?"}

# Names for outputs saved images
string	outrow	  {"c",prompt="prefix of image with pixel mapping corrected"}
string	outcrtk	  {"r",prompt="prefix of row cross-talk corrected image "}
string	outprps	  {"p",prompt="prefix of saved pre-post treated images"}
string  outfltc   {"f",prompt="prefix of flat-field corrected images"}
string	outmask	  {"m",prompt="prefix for individual object masks"}
string	outsbsk	  {"s",prompt="prefix of sky subtracted images"}
string	outvgrad  {"v",prompt="prefix of vertical gradient corrected images"}
string	outcorr	  {"g",prompt="prefix of saved geometric distortion corrected images"}
string	outfshift {"i",prompt="Prefix to be added after image shifted images"}
string	outsky	  {"",prompt="name of output sky image"}
string	outshift  {"",prompt="name of output image shift file (integer)"}

# Combination parameters
bool	combimg	 {yes,prompt="Combine processed frames into an output image"}
string  reject   {"none",enum="none|minmax|sigclip|pclip",prompt="Type of rejection when combining images"}
string  zero	 {"none",prompt="Image zero point offset when combining"}
string  scale	 {"none",prompt="Image scaling factor when combining"}
bool    use_subpixel  {yes,prompt="Use subpixel scale when combining"}
string  inter_typ     {"drizzle[0.4]",prompt="Interpolant type (nearest,linear,sinc,drizzle,poly3,poly5,spline3"}
string  starpos	 {"",prompt="File with star positions used to align images"}

real	nlow     {0.05,prompt="Number or fraction of low pixels to reject to create image"}
real	nhigh    {0.25,prompt="Number of fraction of high pixels to reject to create image"}
real	pclip    {0.5,prompt="Percentile clipping parameter [reject:pclip]"}
real	lowrej   {5.,prompt="Lower sigma clipping factor [reject:sigclip|pclip]"}
real	highrej  {5.,prompt="Higher sigma clipping factor [reject:sigclip|pclip]"}

pset    liskycpars     {prompt="Parameter set for sky image combination"}
pset    lcvgradpars    {prompt="Parameter set for vertical gradient correction"}
pset    lstarfindpars  {prompt="Parameter set for star finding algorithm"}

real	xstrech	 {1,prompt="Streching factor along x-axis due to geometrical distortion"}
real	ystrech	 {1,prompt="Streching factor along y-axis due to geometrical distortion"}

bool	normexp  {no,prompt="Normalize combined image by exposure time?"}
string	exptime  {"EXPTIME",prompt="Exposure time keyword"}


bool	verbose	{yes,prompt="Verbose"}

# Directories
string	tmpdir	{")_.tmpdir",prompt="Temporary directory for file conversion"}
string	stddir	{")_.stddir",prompt="Parametre directory"}


# check options
bool	dispstep{no,prompt="Display dedither steps"}
pset	dispopt2{prompt="Option display"}
bool 	choffset{no,prompt="Check for offset result?"}

# imcentroid parameters
int	bigbox	{17,prompt="Size of the coarse centering box"}
real    sherror	{5.,prompt="Maximum error in pixels on offset"}
real 	psf     {4.,prompt="Value of the PSF - FWHM (pixels) to find reference stars"}



string *list1	{prompt="Ignore this parameter(list1)"}
string *list2	{prompt="Ignore this parameter(list2)"}


begin

  string	inli,ini,ino2,iso,sho
  string	offsetplus, foffsetplus
  string	imt,imt_msk,imk,imkcorrect,imkstar,imaux,imkst,imf,imflat,cmask
  string	logf,fname,key, imref, refimage
  string	junk1,gtransf
  string	refshiftwcs,icombli,ishiftli
  string 	prefcyc
  string	inmatch,ofs,starpos1
  file      tmpl,tmplaux,subli,prepostli,correctli,vgradli,ocorrectli,corrowli
  file      vgradskyli,corvgskyli
  file      interpli,interp2li,flatli, shcorrectli,corvgli,weight1
  bool		delprepostli,delskyli,origcpixprepost,origcpixsky
  file		mkstli,skyli,skyliaux,skyliaux2,fli,ofit1d
  file 		tf2, tfstar,offset,foffset
  file		shiftwcs,shiftwcsadj,shiftfwcsadj,shiftaux1,shiftaux2
  real		x,y,xr,yr,xs,ys,dimx,dimy
  real		xmax,xmin,ymax,ymin,xminaux,xmaxaux,yminaux,ymaxaux
  real		contrdisp
  real		diffshift,fxoffset,fyoffset
  int		wcs,nsc, nst, actnlow, actnhigh
  int		numberimg
  int		round1,ixoffset,iyoffset
  bool		first,oneinsky,oneflat
  bool		saveprps,savesbsk,savesky,savecorr,savecorrow,savemkst
  bool		corfield,corffimage,cvgrad1,combimg1
  bool		adjshwcs, use_subpix1
  bool		normexp1
  real		exptime_val
  string	kexptime1, inttype1
  real		lsig1,hsig1,pclp1, bdrx1, bdry1
  
  # --------------------------------------------------------------------
  # Verifications
  # --------------------------------------------------------------------
  print ""
  print "verification of variables"
 
  
  ######
  #
  #  During this step we verify true of input variables and we determine 
  #  values of local variables using input options
  #  
  #  
  #  The option checked are: 
  #
  #		- mask used
  #		- geometric correction used
  #		- show output option STDOUT or log file
  #		- second step with individual mask star and intermediate 
  #		  result name
  #		- sky input image:  not correct --> subsky mode = "none"
  #				    correct     --> verify if one or more sky images
  #		- intermediate images saved: 
  #				    prepost images = saveprps
  #			            row corrected img = savecorrow
  #				    sky-substracted images = savesbsk
  #				    calculated sky = savesky
  #				    individual mask stars = savemkst
  #
  #
  #  The variables verified are:
  #
  #		- output image: if exist --> error because overwrite
  #		- output sky: if exist --> error because overwrite
  #		- mask introduced and do not exist --> error because do not exist
  #		- geometric correction file introduced and do not exist (or
  #		  its format is wrong) --> error because wrong file
  #					
  #
  ######

  # copy input arguments to force definition at the beginning of the script
  ini = input
  ino2 = output
  iso = outsky
  sho = outshift
  
  normexp1 = normexp
  weight1 = ""
  if (weight != "") 
    weight1 = "@"//weight
  
  inttype1 = inter_typ
  
  lsig1 = lowrej
  hsig1 = highrej
  pclp1 = pclip
  
  cvgrad1 = cvgrad
  combimg1 = combimg
  
  
  bdrx1 = xstrech
  bdry1 = ystrech 
  ######
  # Analysis of selected options
  ######
  
  # Mask will be used
  imk = inmask
  
  # Flatfield file will be used
  imf = inflat
  if (imf != "") 
    {
    fli = mktemp(tmpdir//"_ldeditherfli")
    sections(imf,option="fullname",> fli)
    }
  
  
  # Will geometric distortion correction be apply
  imt = intrans
     
    
  # decide if to show output
  if ( verbose )
    logf = "STDOUT"
  else
    logf = ""

  # use subpixel when doing image combination
  use_subpix1 = use_subpixel
  
  # in case that adjshift=no set use_subpix1 to no
  if (!adjshift)
    {
      use_subpix1 = no
      if (verbose)
       {
         print ""
         print "Warning: Not using subpixel offsets"
       }
    }

  if (use_subpix1) 
    round1 = 2
  else 
    round1 = 0   

   
  # check if input sky image exists and select true option
  if (subsky == "usrsky")
    {
      skyli = mktemp(tmpdir//"ldeditherskyli")
      sections(insky,option="fullname",> skyli)
      list1 = skyli
      first = yes
      oneinsky = no
      While (fscan (list1,fname) != EOF)
	{
	if (first) 
	  {
	  oneinsky = yes
	  first = no
	  }
	else 
	  {
	  oneinsky = no
	  break
	  }
	}

      if (first) 
	{
	if (verbose) print "WARNING: no input sky image found"
	subsky = "none"
	}
      else {if (verbose) print("INFO: one input sky image found.")}
    }
   
  
   
  # Verify if some images should be saved
  if (outrow != ""  && (corrow || intprow)) {savecorrow=yes}
  else {savecorrow=no}
  if (outprps == "") {saveprps=no}
  else {saveprps=yes}
  if (outsbsk == "") {savesbsk=no}
  else {savesbsk=yes}
  if (outsky == "") {savesky=no}
  else {savesky=yes}
  if (outcorr != "") {savecorr=yes}
  else {savecorr=no}
  #if (outmkst == "") {savemkst=no}
  #else {savemkst=yes}
  
  # expand input image names.
  inli = mktemp(tmpdir//"_ldeditherinli")
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
      refimage = fname
      if (verbose) print("INFO: ",fname," is the reference image")
      first = no
      }
    }
  if (verbose) print "INFO: image list have "//numberimg//" images"
  
  delskyli = no
  ######
  # Verification of correct input variables
  ######
 
  
  # We verify if output image already exist 
  # expand output image name.
  tmpl = mktemp(tmpdir//"ldedithertmpl")
  sections(ino2,option="fullname",> tmpl)
  list1 = tmpl
  nsc = fscan(list1, fname)
  delete(tmpl,yes,verify=no)

  # check if output image exists
  limgaccess(fname, verbose=no)
  if ( limgaccess.exists )
    {
    beep
    print("")
    print("ERROR: operation would override output file "//fname)
    print("ldedither aborted")
    print("")
    beep ; beep
    bye
    }
    
  # check if output sky image exists
  limgaccess(iso, verbose=no)
  if ( limgaccess.exists )
    {
    beep
    print("")
    print("ERROR: operation would override "//iso//" output sky file")
    print("ldedither aborted")
    print("")
    beep
    bye
    }
    
  # check if output sky image exists
  if ( access(sho) )
    {
    print("WARNING: shift file "//sho//" already exists")
    print("         data will not be saved")
    }
  
  # Search default mask if option choosen
  if ( imk == "default" )
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

    imk = stddir//lcorrfile.bpmask
    if (imk == "none" || imk == "unknown")
      {
      if (verbose) print "WARNING: default bad pixel mask file not found"
      imk = ""
	}
    }
     
  # check if mask file exist
  #print("imk ",imk)
  lmaskaccess(imk, verbose=no)
  if ( lmaskaccess.exists)
    {
    if (verbose) print("INFO: input mask image found")
    }
  else if (imk == "")
    {
    if (verbose) print("INFO: no input mask image")
    }
  else #if (imk != "")
    {
    beep
    print("")
    print("ERROR: input mask "//imk//" image not found")
    print("ldedither aborted")
    print("")
    beep
    bye
    }
     
  # check if flatfield image exists
  if (imf != "")
    {
    first = yes
    oneflat = no
    imf = ""
    list1 = fli
    While (fscan(list1,imf) != EOF)
      {
      if (first)
   	{
   	first=no
   	oneflat = yes
   	}
      else {
        print ("ERROR: more than one flat field image found")
	oneflat = no
	bye
	   }
 
      limgaccess(imf, verbose=no)
      if ( limgaccess.exists )
   	{if (verbose) print "INFO: flatfield file "//imf//" found"}
      else
   	{
   	if (verbose)
   	  {
   	  print "WARNING: flatfield file "//imf//" not found"
   	  print "	  no flatfield correction considered"
   	  }
   	imf = ""
   	}
      } # End of While (fscan(list1=fli,imf) != EOF)
    } # End of if (imf != "")
    
  if (imf == "") corfield = no
  else corfield = yes
    
  
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
  #		- imt: name of geometric correction file if intrans introduced
  #		       else imt=""
  #		- gtransf: transform file name 
  #		- logf: if verbose STDOUT else "" 
  #		- subsky == "combsky" && stmask
  #		- ino2: force definition of output image
  #		        else ino1=ino2
  #		- skyli: contain list of input sky images (only if subsky=usrsky)
  #		- oneinsky: if sky is single image yes else no (only if subsky=usrsky)
  #		- savecorrow = outrow != ""  && (corrow || intprow)
  #		- saveprps = outprps != ""
  #		- savebsk = outsbsk != ""
  #		- savesky = outsky != ""
  #		- savecorr = outcorr != "" 
  #
  #
  #  Variable erased: none variable erased
  #
  #  Variable created + erased:
  #		- tmpl: expand ino2
  #		
  #  Temporary variables used localy and existing yet: 
  #		- ini: force definition of input image list
  #		- iso: force definition of output sky name
  #		
  #		- first: control oneinsky, numberimg
  #		- fname: check existance of output image, insky, reference image
  #			 
  #  
  #  State of files and images:
  #     
  #		- always --> inli contain name of input images
  #		- gtransf --> transform file name
  #		- if subsky=usrsky --> skyli contain name of input sky images 
  #
  ######################################################################
  
  # --------------------------------------------------------------------
  # End of verifications
  # --------------------------------------------------------------------
  
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
      
    corrowli = mktemp(tmpdir//"ldedithercorrowli")
    if (outrow == "")
      {
      lcpixmap (input = "@"//osfn(inli),     
               output = "ldeditherimcorrow_", 
              outlist = corrowli,   
              verbose = verbose,
	       tmpdir = tmpdir,
               stddir = stddir)
      }
    else
      {
      lcpixmap (input = "@"//osfn(inli),     
               output = outrow, 
              outlist = corrowli,   
              verbose = verbose,
	       tmpdir = tmpdir,
               stddir = stddir)
	       
      }
      
    origcpixprepost = lcpixmap.original
    if (dispopt2.dispcorrow && dispstep) 
      {
      list1 = corrowli
      While(fscan(list1,fname) != EOF) 
        {
	display(fname,1)
	imexamine
	}
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
  
  prepostli = mktemp(tmpdir//"_ldeditherprepostli")
        
  if (outprps != "")
    {
    llistdiff (input = "@"//corrowli,         
              output = prepostli,             
               pname = outprps,     
             verbose = verbose,
              tmpdir = tmpdir)
    }
  else
    {
    llistdiff (input = "@"//corrowli,         
              output = prepostli,             
               pname = mktemp("ldedither")//"_",     
             verbose = verbose,
              tmpdir = tmpdir)
    }
  delprepostli = (!llistdiff.original || !origcpixprepost) && !saveprps
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
  #  Temporary variables used localy and existing yet: none files
  #			 
  #  
  #  State of files and images:
  #     
  #		- always --> inli contain name of input images
  #		- gtransf --> transform file name
  #		- if subsky=usrsky --> skyli contain name of input sky images 
  #		- prepostli --> contain list of images prepost treated
  #		- if prepost-treated @prepostli --> input images
  #		  else	@prepostli --> if outprps="" = input image names
  #				       esle = images to save
  #
  ######################################################################
  # --------------------------------------------------------------------
  #  End of pre-post treatment
  # --------------------------------------------------------------------   
        
  ######################################################################
  #
  #  Variables created: 
  #		- corrowli (if correction done)
  #
  #
  #  Variable erased: none variable erased
  #
  #  Variable created + erased: none variable
  #		
  #  Temporary variables used localy and existing yet: 
  #		- fname: display correction result
  #			 
  #  
  #  State of files and images:
  #     
  #		- always --> inli contain name of input images
  #		- gtransf --> transform file name
  #		- if subsky=usrsky --> skyli contain name of input sky images 
  #		- prepostli --> contain list of images prepost treated
  #		- if prepost-treated @prepostli --> input images
  #		  else	@prepostli --> if outprps="" = input image names
  #				       esle = images to save
  #		- if (corrow|intprow) corrowli --> contain list of images corrected
  #		  else: corrowli = prepostli
  #		- if (corrow|intprow) @corrowli --> if outrow="" = temporary images
  #				                    esle = images to save
  #
  ######################################################################

    interpli = prepostli
    
  # --------------------------------------------------------------------
  #  Flatfield correction of object images
  # --------------------------------------------------------------------
  if (corfield)
    {
    if (verbose) 
      {
      print ""
      print "Doing flatfield correction..."
      }
        
    if (oneflat)
      {
      list1 = fli
      nsc = fscan(list1,imf)
      }
    else 
      {
      print ("ERROR: more than 1 flatfield image found")
      }  
        
    flatli = mktemp(tmpdir//"_ldeditherflatli")
    list1 = interpli
    While (fscan(list1,fname) != EOF)
      {
      print("fname ",fname)
      if (outfltc == "") 
         imflat = mktemp(tmpdir//"ldeditherimflat")
      else
         { 
           lfilename(fname)
	   imflat = lfilename.path//outfltc//lfilename.root
	   if (verbose) print ("Flatfielding image ",lfilename.root)
	 }
	 
      # check if flatfield was already performed 
      corffimage = yes
      # check if the original image was already flatfield corrected
      #print("fname ",fname)
      imgets(fname,"FLATCOR")
      if (imgets.value == "1")
        corffimage = no 
      # check if output image exists and is flatfield corrected	
      limgaccess(imflat,verbose=no)
      if (limgaccess.exists) 
      {
         imgets(imflat,"FLATCOR")
	 if (imgets.value == "1")
	   corffimage = no
       }
      #  print ("CHECK: flatco ",corffimage) 
      if (corffimage) 	 
        liflatcor (fname,outfltc,imf,corrow=no) 	 
      
      print (imflat, >>flatli)
      }
    
    if (oneflat == no) imdelete (imf,yes,ver-)
    
    } # End of if (corfield)
  else 
    {
    flatli = interpli
    if (verbose) 
      {
      print ""
      print "No flatfield correction performed"
      print ""
      }
    }
  # --------------------------------------------------------------------
  # End of flatfield correction for object images
  # --------------------------------------------------------------------

  

  # --------------------------------------------------------------------
  #  Correction of vertical gradient
  # -------------------------------------------------------------------- 
  #############
  #
  #  Now we apply correction of the likely vertical gradient due to reset 
  #  anomaly. In principle it should be applied to image already sky 
  #  subtracted. Raise a warning in case this correction is selected but 
  #  sky subtraction is not performed.
  #
  #############

  if (cvgrad1) 
  {
    if (verbose) {
      print ("correcting vertical gradient ....") 
    }
    vgradli = mktemp(tmpdir//"_ldedithervgrdli")
	print("flatli:",flatli)
	print("flatli:",flatli)
    # We create names in correctli list
    if (outvgrad == "")
      {
      lnamelist ( input = "@"//flatli,    
                 output = vgradli,     
                  bname = "_lddthrvdoorr",		
                  pname = "",
		refname = "@"//inli,		
		 maxnum = INDEF,
                 extens = "")
      }
    else
      {
	  print("voy por no vacio")
	  print("inli ",inli)
	  print("outvgrad ",outvgrad)
	  print("vgradli ",vgradli)
      lnamelist ( input = "@"//flatli,    
                 output = vgradli,     
                  bname = "",		
                  pname = outvgrad,
#            refname = "",		
		refname = "@"//inli,		             
	         maxnum = INDEF,
                 extens = "")
      }

    corvgli = mktemp(tmpdir//"_ldthcvgdlst")
    list1 = flatli
    while (fscan(list1, fname) != EOF)
      {
         ## check if image has been already corrected
	 imgets(fname,"VGRADCOR")
	 
	 if (imgets.value != "1") 
	  {
            ofit1d = mktemp(tmpdir//"_ldithskyfit1d")
            ## check if object mask will be used  (TBD)
            licvgrad(input = fname, 
               output = ofit1d,
               ctype = lcvgradpars.ctype,
               quad = lcvgradpars.quadran,
               keepcounts = lcvgradpars.kpcts,
               nsamp = lcvgradpars.sample,
               nxaver = lcvgradpars.nxaver,
               nyaver = lcvgradpars.nyaver,
               sfitsec = lcvgradpars.sfitsec,
               btsfitsec = lcvgradpars.btsfitsec,
               tpsfitsec = lcvgradpars.tpsfitsec,
               function = lcvgradpars.function,
               xorder = lcvgradpars.xorder,
               yorder = lcvgradpars.yorder,
               low_reject = lcvgradpars.lrej,
               high_reject = lcvgradpars.hrej,
               niterate = lcvgradpars.niter)
	  }
	 else 
	  {
	    print("Warning: Image ",fname," already corrected for vertical gradient. Doing nothing")
	    imcopy(fname,ofit1d)
	  }  
	    	  
         print (ofit1d, >> corvgli)
		  
      }

     imrename ("@"//osfn(corvgli),"@"//vgradli,verbose=verbose) 
     delete (corvgli,yes,ver-, >>&"/dev/null")
      
  } else {
     ## in case nothing is done use the previous list
     vgradli = flatli
  
  }
   
  

  # --------------------------------------------------------------------
  # Verify if sky would have to be substracted of image and substract sky 
  # if it is necesary
  # --------------------------------------------------------------------
  #######
  #
  #  This step consist in build and substract sky image of images
  #  if subsky option is "none" no operation is done. Else we use
  #  ldithsky with correct parameters 
  #  
  #######
  
  if (subsky != "none")
    {
      if (verbose)
      {
        print ""
        print "sky treatment"
      }
		
      # First we process input image sky if needed
      if ( subsky == "usrsky" )
      {
      # now check if pixel mapping correction is required
      if (corrow)
        {
          skyliaux = mktemp(tmpdir//"ldeditherskyliaux")
          if (outrow == "") # if pixel mapping corrected images are not saved
            {	
              lcpixmap (input = "@"//osfn(skyli),     
            	       output = "ldeditherimsky_", 
            	      outlist = skyliaux,   
            	      verbose = verbose,
	               tmpdir = tmpdir,
            	       stddir = stddir)
            }
         else
	       {
              lcpixmap (input = "@"//osfn(skyli),     
            	       output = outrow, 
            	      outlist = skyliaux,   
            	      verbose = verbose,
	               tmpdir = tmpdir,
            	       stddir = stddir)
	       }		 
         origcpixsky = lcpixmap.original
        }
      else       # no correction is required
        {
          skyliaux = mktemp(tmpdir//"ldeditherskyliaux")
	      sections("@"//osfn(skyli),option="fullname",> skyliaux)
	      origcpixsky = yes
        }

      delete (skyli,yes,ver-)
      skyliaux2 = mktemp (tmpdir//"ldeditherskyli")
      llistdiff (input = "@"//skyliaux,         
              output = skyliaux2,             
               pname = "ldeditherimsky",     
             verbose = verbose,
              tmpdir = tmpdir)
      delete (skyliaux,yes,ver-)

      delskyli = !llistdiff.original || !origcpixsky


      # now check if flatfield correction is required
      if (corfield)
	{
	  if (verbose) 
	    {
	    print ""
	    print "Flatfield correction of sky images..."
	    }

	  if (oneflat)
	    {
	    list1 = fli
	    nsc = fscan(list1,imf)
	    }
	  else 
	    {
	    print ("ERROR: more than 1 flatfield image found")
	    }  
        
	  list1 = skyliaux2
	  While (fscan(list1,fname) != EOF)
	    {
	    if (outfltc == "") 
               imflat = mktemp(tmpdir//"ldeditherimflat")
	    else
               { 
        	 lfilename(fname)
		 imflat = lfilename.path//outfltc//lfilename.root
		 if (verbose) print ("Flatfielding image ",lfilename.root)
	       }

	    # check if flatfield was already performed 
	    corffimage = yes
	    limgaccess(imflat,verbose=no)
	    if (limgaccess.exists) 
	    {
               imgets(imflat,"FLATCOR")
	       if (imgets.value == "1")
		 corffimage = no
	     }
	    if (corffimage) {	 	 
	      imarith ( operand1 = fname,
        		      op = "/",
        		operand2 = imf,
        		  result = imflat,
        		   title = "",
        		 divzero = 0.,
        		 hparams = "",
        		 pixtype = "",
        		calctype = "",
        		 verbose = no,
        		   noact = no)
	      hedit (imflat, "FLATCOR",1,add=yes,update=yes,verify=no)
	    }
	    print (imflat, >>skyli)
	    }

	  if (oneflat == no) imdelete (imf,yes,ver-)
    
        }  # End of if (corfield)
      else 
	{
	skyli = skyliaux2
	if (verbose) 
	  {
	  print ""
	  print "No flatfield correction performed"
	  print ""
	  }
	}
      # --------------------------------------------------------------------
      # End of flatfield correction for sky images
      # --------------------------------------------------------------------

      # --------------------------------------------------------------------- 
      # now check if vertical  gradient correction is required
      
      if (cvgrad1) 
      {
        if (verbose) {
          print ("correcting vertical gradient of sky frames....") 
        }
        vgradskyli = mktemp(tmpdir//"_ldedithervgrdli")
        # We create names in correctli list
        if (outvgrad == "")
          {
            lnamelist ( input = "@"//skyli,    
                      output = vgradskyli,     
                       bname = "_lddthrvdoorr",		
                       pname = "",
		             refname = "@"//skyli,		
		              maxnum = INDEF,
                      extens = "")
          }
        else
          {
            lnamelist ( input = "@"//skyli,    
                       output = vgradskyli,     
                        bname = "",		
                        pname = outvgrad,
		              refname = "",		
	                   maxnum = INDEF,
                       extens = "")
          }

        corvgskyli = mktemp(tmpdir//"_ldthcvgdsklst")
        list1 = skyli
        while (fscan(list1, fname) != EOF)
          {
            ## check if image has been already corrected
            imgets(fname,"VGRADCOR")
########
            if (imgets.value != "1") 
              {
                ofit1d = mktemp(tmpdir//"_ldithskyfit1d")
                ## check if object mask will be used  (TBD)
                licvgrad(input = fname, 
                    output = ofit1d,
                    ctype = lcvgradpars.ctype,
                    quad = lcvgradpars.quadran,
                    keepcounts = lcvgradpars.kpcts,
                    nsamp = lcvgradpars.sample,
                    nxaver = lcvgradpars.nxaver,
                    nyaver = lcvgradpars.nyaver,
                    sfitsec = lcvgradpars.sfitsec,
                    btsfitsec = lcvgradpars.btsfitsec,
                    tpsfitsec = lcvgradpars.tpsfitsec,
                    function = lcvgradpars.function,
                    xorder = lcvgradpars.xorder,
                    yorder = lcvgradpars.yorder,
                    low_reject = lcvgradpars.lrej,
                    high_reject = lcvgradpars.hrej,
                    niterate = lcvgradpars.niter)
              }
            else 
              {
                print("Warning: Image ",fname," already corrected for vertical gradient. Doing nothing")
                imcopy(fname,ofit1d)
              }  

            print (ofit1d, >> corvgskyli)
####### 
          }	
          
          imrename ("@"//osfn(corvgskyli),"@"//vgradskyli,verbose=verbose)
          delete (corvgskyli,yes,ver-, >>&"/dev/null")

      } else {
        if (verbose) {
          print ("Warning: NO vertical gradient correction in user sky frames....") 
        }
        ## in case nothing is done use the previous list
        vgradskyli = skyli
      }

      # now check if interpolation of bad rows and columns is required for sky images
      
    } # end of if ( subsky == "usrsky" ) 

    subli = mktemp (tmpdir//"_ldedithersubli")    
    
    if (skycomb == "single")
      {	
	if (verbose) print "Required sky subtraction mode is single"

	# We create names in subli list
	if (outsbsk == "")
        {
        lnamelist ( input = "@"//inli,    
            	 output = subli,     
                    bname = "ldeditherimsubsky",		
                    pname = "",
			refname = "@"//inli,
			 maxnum = INDEF,
            	 extens = "")
        }
	else
        {
        lnamelist ( input = "@"//inli,    
            	 output = subli,     
                    bname = "",		
                    pname = outsbsk,
			refname = "",		
			 maxnum = INDEF,
            	 extens = "")
        }

	if ( subsky == "combsky" )
        {
          lsubdithsky ( input = "@"//vgradli,
    		    output = "@"//subli,
    		    insky = "",
    	           outsky = iso,
	          outmask = outmask,
    	           tmpdir = tmpdir,
    	          verbose = verbose,
    	         displsub = (dispopt2.dispsubsky1 && dispstep))
	  } # end of if ( subsky == "combsky" )

	if ( subsky == "usrsky" )
        {
          lsubdithsky ( input = "@"//vgradli,
    		       output = "@"//subli,
    		        insky = "@"//skyli,
    	               outsky = iso,
                      outmask = outmask,
    	               tmpdir = tmpdir,
    	              verbose = verbose,
    	             displsub = (dispopt2.dispsubsky1 && dispstep))
	} # end of if ( subsky == "usrsky" )
      } # End of if (skycomb == "single")
    else if (skycomb == "run")
      {
	if (verbose) print "Obtained sky mode is run"
	
	if (outsbsk == "") prefcyc = "ldeditherimsubsky"
	else prefcyc = outsbsk 

	if ( subsky == "combsky" )
        {
        lrunsky ( input = "@"//vgradli,
                 output = prefcyc,
                outlist = subli,
            	  insky = "",
                 outsky = iso,
                outmask = outmask,
    	         tmpdir = tmpdir,
    	        verbose = verbose,
    	        displsub = (dispopt2.dispsubsky1 && dispstep))
        
        } # end of if ( subsky == "combsky" )

	if ( subsky == "usrsky" )
        {
        lrunsky ( input = "@"//vgradli,
                 output = prefcyc,
                outlist = subli,
            	  insky = "@"//skyli,
                 outsky = iso,
                outmask = outmask,
    	         tmpdir = tmpdir,
    	        verbose = verbose,
    	       displsub = (dispopt2.dispsubsky1 && dispstep))

        } # end of if ( subsky == "usrsky" )
	
	}  # End of if (skycomb == "run")
    else if (skycomb == "cycle")
      {
	if (verbose) print "Obtained sky mode is cycles"
	
	if (outsbsk == "") prefcyc = "ldeditherimsubsky"
	else prefcyc = outsbsk 

	if ( subsky == "combsky" )
        {
        lcycsky ( input = "@"//vgradli,
                 output = prefcyc,
                nditpts = nditpts,
                outlist = subli,
           	      insky = "",
                 outsky = iso,
                outmask = outmask,
    	         tmpdir = tmpdir,
    	        verbose = verbose,
    	        displsub = (dispopt2.dispsubsky1 && dispstep))
        
        } # end of if ( subsky == "combsky" )

	if ( subsky == "usrsky" )
        {
        lcycsky ( input = "@"//vgradli,
                 output = prefcyc,
                nditpts = nditpts,
                outlist = subli,
            	  insky = "@"//vgradskyli,
                 outsky = iso,
                outmask = outmask,
    	         tmpdir = tmpdir,
    	        verbose = verbose,
    	        displsub = (dispopt2.dispsubsky1 && dispstep))

        } # end of if ( subsky == "usrsky" )
	
	}  # End of if (skycomb == "cycle")
    
    if (verbose)
      {  
      print "sky treated"
      print ""
      }
    } # end of if ( subsky != "none" )]
    else
    {
      subli = vgradli
      if (verbose) 
	    {
	      print ""
	      print "No sky subtraction is performed"
	      print ""
	    }
     } # end of if else ( subsky == "none" )

  ######################################################################
  #
  #  Variables created: 
  #		- subli (if subsky option no "none"): list with sky substracted images 
  #		- iso (if introduced): sky image result
  #
  #  Variable erased: none variable erased
  #
  #  Variable created + erased: none variable
  #		
  #  Temporary variables used localy and existing yet: none variables
  #			 
  #  
  #  State of files and images:
  #     
  #		- always --> inli contain name of input images
  #		- gtransf --> transform file name
  #		- if subsky=usrsky --> skyli contain name of input sky images 
  #		- prepostli --> contain list of images prepost treated
  #		- if prepost-treated @prepostli --> input images
  #		  else	@prepostli --> if outprps="" = input image names
  #				       esle = images to save
  #		- if (corrow|intprow) corrowli --> contain list of images corrected
  #		  else: corrowli = prepostli
  #		- if (corrow|intprow) @corrowli --> if outrow="" = temporary images
  #				                    esle = images to save
  #		- shiftwcs --> shift between images read on image headers 
  #		- xmin,xmax,ymin,ymax: coordinates of common area of images
  #		- if (subsky != "none") subli --> contain list with sky sub images
  #		  else subli = corrowli
  #		- if (subsky != "none") @subli --> if outsbsk="" = temporary images
  #					       	   else = images to save
  #		- if (iso != "" && subsky != "none") iso --> calculated sky
  #
  ######################################################################
  # --------------------------------------------------------------------
  #  End of substraction of sky
  # --------------------------------------------------------------------

  
  # --------------------------------------------------------------------
  #  Row and lines bad pixel corrections
  # --------------------------------------------------------------------
  
  ######
  #
  #  During this step we correct bad pixel rows due to detector pixel mapping 
  #  problems. This correction are done with lcpixmap task. Black columns or lines
  #  pixels can be interpolated using fixpix (if only interpolated) or inside lcpixmap
  #  (if correction + interpolation)
  #  
  #  A list will be created if this option is choosen. Else the resultant list will
  #  be prepostlist. 
  #  When option choosen the list is like this:
  #
  #		- if corrected images should be saved: list with input names
  #		- else: list with temporary file names 					
  #
  ######
  
  cmask = incmask 
  if (intprow && (cmask != "")) 
    {
    if (cmask == "default")
       {
          list1 = subli
	      nsc = fscan(list1,fname)
          lcorrfile (input = fname,
                   fbpmask = lirisdr.bpmdb,
                   fbcmask = lirisdr.bcmdb,      
                  fgeodist = lirisdr.gdistdb,    
                   ftransf = lirisdr.fcdb, 
                    stddir = stddir,
                   verbose = verbose) 
          
          cmask = osfn(lirisdr.stddir) // lcorrfile.bcmask
       }
         
    #imcopy("@"//osfn(prepostli),"@"//osfn(interpli),verbose=no)
    #if (verbose)
      #{
         print ""
         print "interpolating bad rows and lines, using fixpix..."
      #}
    fixpix( image = "@"//subli,
             mask = cmask,
          linterp = INDEF,
          cinterp = INDEF,
          verbose = no,
           pixels = no)
    
#    if (dispopt2.dispcorrow && dispstep) 
#      {
#         list1 = interpli
#         While(fscan(list1,fname) != EOF)
#           {
#             display(fname,1)
#             imexamine
#           }
#      }
    } # End of if (intprow)      

  # --------------------------------------------------------------------
  # End of interpolation of bad rows & columns  for object images
  # --------------------------------------------------------------------

  
  # --------------------------------------------------------------------
  #  Correction of geometrical distortion
  # -------------------------------------------------------------------- 
  #############
  #
  #  Now we apply correction of the image if option selected and only one
  #  step will be done. If two steps this step is done because individual mask 
  #  images build, and we need original images.
  #  Task used for correction is geotran and it is too applied to mask 
  #
  #############
    
  if (imt!="")
    {
    if (verbose)
      {
      print ""
      print "Distortion correction process"
      print "correcting images ..."
      }
    
    correctli = mktemp(tmpdir//"_ldedithercorrectli")
    # We create names in correctli list
    if (outcorr == "")
      {
      lnamelist ( input = "@"//subli,    
                 output = correctli,     
                  bname = "_lddthrgdoorr",		
                  pname = "",
		refname = "@"//inli,		
	         maxnum = INDEF,
                 extens = "")
      }
    else
      {
      lnamelist ( input = "@"//subli,    
                 output = correctli,     
                  bname = "",		
                  pname = outcorr,
		refname = "",		
                 maxnum = INDEF,
                 extens = "")
      }
      
      
    # We correct images of the pre-post treated list
    
    
    lgeotran (input = "@"//osfn(subli),
    	    output  = "@"//osfn(correctli),
	    intrans = imt, 
	    strechx = bdrx1,
	    strechy = bdry1,
	   boundary = "constant",
	   constant = 0.,
	    verbose = verbose)    

    if (verbose) {print "All images have been corrected of geometric distorsion"}

    ## now transform common mask if used
    if (imk != "") {
     imt_msk = imt
     if (imt_msk == "default")
        {
           list1 = subli
           nsc = fscan (list1,fname)
           lcorrfile (input = fname,
                    fbpmask = lirisdr.bpmdb,
                    fbcmask = lirisdr.bcmdb,      
                   fgeodist = lirisdr.gdistdb,    
                    ftransf = lirisdr.fcdb, 
	             stddir = stddir,
                    verbose = verbose)           
           imt_msk = osfn(lirisdr.stddir) // lcorrfile.geodist
        }
     print ("Now correcting common mask of geometric distortion")
     print ("imk ",imk)
     print ("imt_msk ",imt_msk)
     imkcorrect = mktemp(tmpdir//"_lddthimkgcorr")
     lgeotran (input = imk,
    	     output  = imkcorrect,
         interpolant = "nearest",
             intrans = imt_msk, 
             strechx = bdrx1,
             strechy = bdry1,
            boundary = "constant",
            constant = 1.,
             verbose = verbose)    
    }  
    else {
        imkcorrect = ""
    }  
    
    
    if (verbose)
      {
      print "Geometrical distortion correction applied"
      print ""
      }
    } # end of if (imt!="")
  else 
    {
    if (verbose)
      {
      print ""
      print "INFO: Geometrical distorsion correction not applied"
      print ""
      }
    imkcorrect = imk
    correctli = subli
    }
  
  
  ######################################################################
  #
  #  Variables created: 
  #		- correctli (if correction and no 2 step): list with corrected images 
  #		- imkcorrect (if  (if correction, mask and no 2 stepintroduced): 
  #		     corrected image mask
  #
  #  Variable erased: none variable erased
  #
  #  Variable created + erased: none variable
  #		
  #  Temporary variables used localy and existing yet: none variables
  #			 
  #  
  #  State of files and images:
  #     
  #		- always --> inli contain name of input images
  #		- gtransf --> transform file name
  #		- if subsky=usrsky --> skyli contain name of input sky images 
  #		- prepostli --> contain list of images prepost treated
  #		- if prepost-treated @prepostli --> input images
  #		  else	@prepostli --> if outprps="" = input image names
  #				       esle = images to save
  #		- if (corrow|intprow) corrowli --> contain list of images corrected
  #		  else: corrowli = prepostli
  #		- if (corrow|intprow) @corrowli --> if outrow="" = temporary images
  #				                    esle = images to save
  #		- shiftwcs --> shift between images read on image headers 
  #		- xmin,xmax,ymin,ymax: coordinates of common area of images
  #		- if (subsky != "none") subli --> contain list with sky sub images
  #		  else subli = corrowli
  #		- if (subsky != "none") @subli --> if outsbsk="" = temporary images
  #					       	   else = images to save
  #		- if (iso != "" && subsky != "none") iso --> calculated sky
  #		- if (imt!="") correctli --> contain list with corrected im
  #		  else correctli=subli
  #		- if (imt!="" && imk!="") imkcorrect --> corrected imk
  #		  else imkcorrect=imk
  #		-  if (imt!="") @correctli --> if outcorr="" temp images
  #		  					      else = images to save 
  #
  ######################################################################
    
  # --------------------------------------------------------------------
  #  End of distortion correction
  # -------------------------------------------------------------------- 
   
   
  if (!combimg1) {
    if (verbose) print("Warning: frames will not be combined. ")
    goto tidyup 
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
  
  list1 = correctli
  if (fscan(list1,fname) != EOF)
    {
    imgets(image=fname,param="i_naxis1")
    dimx = int(imgets.value)
    imgets(image=fname,param="i_naxis2")
    dimy = int(imgets.value)
    }
  else
    {
    print "WARNING: image dimension  cannot be determined"
    print " default value is 1024,1024"
    dimx = 1024
    dimy = 1024
    }
  ######################################################################
  #
  #  Variables created: 
  #		- dimx and dimy: image dimentions
  #
  #  Variable erased: none variable erased
  #
  #  Variable created + erased: none variable
  #		
  #  Temporary variables used localy and existing yet: fname
  #			 
  #  
  #  State of files and images:
  #     
  #		- always --> inli contain name of input images
  #		- gtransf --> transform file name
  #		- if subsky=usrsky --> skyli contain name of input sky images 
  #		- prepostli --> contain list of images prepost treated
  #		- if prepost-treated @prepostli --> input images
  #		  else	@prepostli --> if outprps="" = input image names
  #				       esle = images to save
  #		- if (corrow|intprow) corrowli --> contain list of images corrected
  #		  else: corrowli = prepostli
  #		- if (corrow|intprow) @corrowli --> if outrow="" = temporary images
  #				                    esle = images to save
  #		- shiftwcs --> shift between images read on image headers 
  #		- xmin,xmax,ymin,ymax: coordinates of common area of images
  #		- if (subsky != "none") subli --> contain list with sky sub images
  #		  else subli = corrowli
  #		- if (subsky != "none") @subli --> if outsbsk="" = temporary images
  #					       	   else = images to save
  #		- if (iso != "" && subsky != "none") iso --> calculated sky
  #		- if (imt!="") correctli --> contain list with corrected im
  #		  else correctli=subli
  #		- if (imt!="" && imk!="") imkcorrect --> corrected imk
  #		  else imkcorrect=imk
  #		-  if (imt!="") @correctli --> if outcorr="" temp images
  #		  					      else = images to save 
  #		- dimx, dimy always --> image dimentions
  #
  ######################################################################
  # --------------------------------------------------------------------
  #  End of parameters determination
  # --------------------------------------------------------------------

  # --------------------------------------------------------------------
  #  Determination of offset among different images. 
  # --------------------------------------------------------------------
  #############
  #
  #  We determine offset with user interaction if match options manual or pick1 
  #  was choosen. Otherwise it does automatically. 
  #  For display mode we introduce contrdisp. When xmin parameter of ldispstars is
  #  UNDEF no step checking is made (TBD).
  #
  #############
  
  inmatch = match

  #if (adjshift && inmatch == "wcs") adjshwcs = yes 
  # else adjshwcs = no
  adjshwcs = adjshift   

  # check if a file with offsets is introduced
  if (inmatch != "wcs" && inmatch != "pick1" && inmatch != "manual")
    {
     if (!access(inmatch))
       {
	 if (verbose)
	   {
	   print "WARNING: shift file "//inmatch//" not found"
	   print "         match mode used will be wcs"
	   }
	 inmatch = "wcs"
       }
     else
       {if (verbose) print "INFO: Input shift file "//inmatch//" found"}
       #adjshwcs = yes
    }
    
  offsetplus = mktemp("_lddthroffpl")
  foffsetplus = mktemp("_lddthrfoffpl")

  if (starpos != "")
   starpos1 = starpos 
  else 
   starpos1 = mktemp("_lddthstarpos")

  print ("Adjusting shwcs? ",adjshwcs)
  print("correctli ",correctli)
  print("inmatch ",inmatch)
  print("adjshwcs ",adjshwcs)
  print("psf ",psf)
  print (" ")
  ligetoffset("@"//correctli,offsetplus,foffsets=foffsetplus,match=inmatch,psf=psf,
    adjshift=adjshwcs,ostars=starpos1)  
  

  
  
  ######################################################################
  #
  #  Variables created: 
  #		- tf2 (if manual mode): temporary file with manual offset
  #		- tfstar (if manual or pick1): temporary file wit reference stars
  #
  #  Variable erased: none variable erased
  #
  #  Variable created + erased: none variable
  #		
  #  Temporary variables used localy and existing yet: 
  #		- contrdisp: for determine display checking in ldispstars task
  #			 
  #  
  #  State of files and images:
  #     
  #		- always --> inli contain name of input images
  #		- gtransf --> transform file name
  #		- if subsky=usrsky --> skyli contain name of input sky images 
  #		- prepostli --> contain list of images prepost treated
  #		- if prepost-treated @prepostli --> input images
  #		  else	@prepostli --> if outprps="" = input image names
  #				       esle = images to save
  #		- if (corrow|intprow) corrowli --> contain list of images corrected
  #		  else: corrowli = prepostli
  #		- if (corrow|intprow) @corrowli --> if outrow="" = temporary images
  #				                    esle = images to save
  #		- shiftwcs --> shift between images read on image headers 
  #		- xmin,xmax,ymin,ymax: coordinates of common area of images
  #		- if (subsky != "none") subli --> contain list with sky sub images
  #		  else subli = corrowli
  #		- if (subsky != "none") @subli --> if outsbsk="" = temporary images
  #					       	   else = images to save
  #		- if (iso != "" && subsky != "none") iso --> calculated sky
  #		- if (imt!="") correctli --> contain list with corrected im
  #		  else correctli=subli
  #		- if (imt!="" &&  imk!="") imkcorrect --> corrected imk
  #		  else imkcorrect=imk
  #		-  if (imt!="") @correctli --> if outcorr="" temp images
  #		  					      else = images to save 
  #		- dimx, dimy always --> image dimentions
  #		- if (inmatch == "manual" || inmatch == "pick1") 
  #			tfstar --> position reference temporary file
  #		- if (inmatch == "manual") tf2 --> reference star offset
  #
  ######################################################################
  # --------------------------------------------------------------------
  #  End of determination of reference stars. 
  # --------------------------------------------------------------------
   
  
  
  
  ######################################################################
  #
  #  Variables created: 
  #		- shiftwcsadj: shift adjusted
  #
  #  Variable erased: none variable erased
  #
  #  Variable created + erased: 
  #		- shiftaux1: xregister format input shift
  #		- shiftaux2: xregister format result 
  #		
  #  Temporary variables used localy and existing yet: 
  #		- shiftaux1,shiftaux2: adapt format between xregister and ldedither
  #		- x,y: read shiftwcs file and shiftaux2
  #		- imref: first image of the list. Reference image for offset
  #		- fname: read shiftaux2	 
  #  
  #  State of files and images:
  #     
  #		- always --> inli contain name of input images
  #		- gtransf --> transform file name
  #		- if subsky=usrsky --> skyli contain name of input sky images 
  #		- prepostli --> contain list of images prepost treated
  #		- if prepost-treated @prepostli --> input images
  #		  else	@prepostli --> if outprps="" = input image names
  #				       esle = images to save
  #		- if (corrow|intprow) corrowli --> contain list of images corrected
  #		  else: corrowli = prepostli
  #		- if (corrow|intprow) @corrowli --> if outrow="" = temporary images
  #				                    esle = images to save
  #		- shiftwcs --> shift between images read on image headers 
  #		- xmin,xmax,ymin,ymax: coordinates of common area of images
  #		- if (subsky != "none") subli --> contain list with sky sub images
  #		  else subli = corrowli
  #		- if (subsky != "none") @subli --> if outsbsk="" = temporary images
  #					       	   else = images to save
  #		- if (iso != "" && subsky != "none") iso --> calculated sky
  #		- if (imt!="") correctli --> contain list with corrected im
  #		  else correctli=subli
  #		- if (imt!="" && imk!="") imkcorrect --> corrected imk
  #		  else imkcorrect=imk
  #		-  if (imt!="") @correctli --> if outcorr="" temp images
  #		  					      else = images to save 
  #		- dimx, dimy always --> image dimentions
  #		- if (inmatch == "manual" || inmatch == "pick1") 
  #			tfstar --> position reference temporary file
  #		- if (inmatch == "manual") tf2 --> reference star offset
  #		- if (adjshwcs) shiftwcsadj --> offset adjusted
  #		  else shiftwcsadj = shiftwcs
  #
  #
  ######################################################################
  
  # --------------------------------------------------------------------
  #  End of adjustment process
  # --------------------------------------------------------------------
  
  # --------------------------------------------------------------------
  #  Determine average offset of diferents images 
  # --------------------------------------------------------------------
  ############
  #
  #  Now we determine offset between images. When match mode is wcs the offset
  #  is the offset readed in the image header (may be adjusted). Else we use
  #  files created interactivly by user. In this case the task used is imcentroid
  #  this task allow found offset introducing initial shift and some reference star 
  #  for correlate their in the images. In manual match mode initial shift
  #  was been determinated by user. In pick1 match mode header wcs shift is used
  #
  ############
  
  ######################################################################
  # --------------------------------------------------------------------
  #  End of determination of offset 
  # --------------------------------------------------------------------    
  
  # --------------------------------------------------------------------
  #  Addition of BPM (Bad Pixel Mask) parametre header
  # --------------------------------------------------------------------
  ############
  #
  #  Here we add or delete BPM field in image headers.
  #  No variable is created.
  #
  ############
  if (imkcorrect != "")
    {
    if (verbose)
      {
      print ""
      print "adding BPM field header of images of list"
      print "adding mask "//imkcorrect//" to header images"
      }
    hedit(images = "@"//correctli,fields = "BPM",value = imkcorrect,
	   add+,del-,ver-,show-,upd+)
    
    if (verbose)
      {
      print "BPM field header added"
      print ""
      }
    }
  else
    {
    if (verbose)
      {
      print ""
      print "erasing BPM field of header images"
      }
    hedit(images = "@"//correctli,fields = "BPM",
       add-,addonly-,del+,ver-,show-,upd+)
    
    if (verbose) print ""
    }  
  # --------------------------------------------------------------------
  #  End of mask treatment
  # -------------------------------------------------------------------- 
  
  # --------------------------------------------------------------------
  #  Combine images
  # --------------------------------------------------------------------
  ####################
  #
  #  We coadd images with offset calculated before, using imcombine task.
  #  The result is save in ino1. We remember that ino1=ino2 if no second step.
  #  The input images are listed in correctli file
  #
  ####################
    
    
  if (nlow < 1) 
    actnlow = int(0.5+nlow*numberimg)
  else 
    actnlow = nlow

  if (nhigh < 1)
    actnhigh = int(0.5+nhigh*numberimg)
  else 
    actnhigh = nhigh

  if (verbose && (reject == "minmax")) 
    {
    print "INFO: number of rejected pixels is "
    print "	      lower = "//actnlow
    print "	      upper = "//actnhigh
    }
    
### normalize by exposure time
  if (normexp1) 
   {
    list1 =  correctli
    kexptime1 = exptime
    while (fscan (list1,fname) != EOF)
      {
	 imgets(fname,kexptime1)
	 exptime_val = real(imgets.value)
	 imarith(fname,"/",exptime_val,fname)
	 hedit(fname,kexptime1,1,add+,del-,upd+,ver-,>>& "/dev/null")
	 hedit(fname,"HISTORY","Counts levels normalized by exposure time",upd+,ver-,>>& "/dev/null")
      }
   }
   
### now separate name of image and its corresponding offset
   list1 = offsetplus
   icombli = mktemp("_lddthrcombli")
   ishiftli = mktemp("_lddthrshiftli")

#   if (outshift != "")
#    {
#    }
#     offset = outshift
#   else  
   offset = mktemp("_lddthroffs")
   ## aqui da el error
   print("offsetplus ",offsetplus)
   while ( fscan(list1,fname,ixoffset,iyoffset) != EOF) {
      print(fname,>>icombli)
      print(ixoffset,iyoffset,>>offset)
      if (outshift != "")
        print(fname," ",ixoffset,iyoffset,>>outshift)
   }
   
   
          
  if (use_subpix1 && foffsetplus != "") {
    list2 = foffsetplus
    foffset = mktemp("_lddthrfoffs")  
    while (fscan(list2,fname,fxoffset,fyoffset) != EOF) {
          print(fname,>>ishiftli)
	  print(fxoffset,fyoffset,>>foffset)
    }
    
    if (outfshift != "")
      ofs = outfshift 
    else 
      ofs = mktemp("_lofprf")   
    shcorrectli = mktemp("_lshcrtli")  
    lnamelist (input = "@"//icombli,output = shcorrectli,bname = "",pname=ofs, refname="",		
		 maxnum = INDEF,extens = "")
    ## now shift images before combining
       imshift("@"//osfn(icombli),"@"//osfn(shcorrectli),0,0,shifts_file=foffset,
	    interp_type=inttype1)
       print ("estoy en opcion 1 imcombine") 
	   hselect ("@"//osfn(icombli),"$I,TITLE,BPM",yes)
       imcombine (\
  	     input = "@"//osfn(icombli),
	    output = ino2,
	  rejmasks = rejmask,
	  expmasks = expmask,
     ##     plfile = "",  ## not valid in iraf 2.12.2
  	     sigma = "",
	   logfile = logf,
	   combine = "average",
	    reject = reject,
	   project = no,
	   outtype = "real",
	   offsets = offset,
	  masktype = "badvalue",
	 maskvalue = 1.,
  	     blank = 0.,
  	     scale = scale,
  	      zero = zero,
	    weight = weight1,
	   statsec = "",
	   expname = "",
	lthreshold = INDEF,
	hthreshold = INDEF,
 	      nlow = actnlow,
 	     nhigh = actnhigh,
  	     nkeep = 1,
  	     mclip = yes,
	    lsigma = lsig1,
	    hsigma = hsig1,
	   rdnoise = "0.",
  	      gain = "1.",
	    snoise = "0.",
	  sigscale = 0.1,
  	     pclip = pclp1,
  	      grow = 0.)
 	      
       delete(shcorrectli,>>& "dev$null")      
      }
  else { 
       ## voy por aqui  (hay que separar las imagenes de los valores de offset del fichero offsetplus)	
	   hselect ("@"//osfn(icombli),"$I,TITLE,BPM",yes)
       print ("estoy en opcion 2 imcombine") 
       imcombine (\
  	     input = "@"//osfn(icombli),
	    output = ino2,
	  rejmasks = rejmask,
	  expmasks = expmask,
     ##     plfile = "",  ## not valid in iraf 2.12.2
  	     sigma = "",
	   logfile = logf,
	   combine = "average",
	    reject = reject,
	   project = no,
	   outtype = "real",
	   offsets = offset,
	  masktype = "badvalue",
	 maskvalue = 1.,
  	     blank = 0.,
  	     scale = scale,
  	      zero = zero,
	    weight = weight1,
	   statsec = "",
	   expname = "",
	lthreshold = INDEF,
	hthreshold = INDEF,
 	      nlow = actnlow,
 	     nhigh = actnhigh,
  	     nkeep = 1,
  	     mclip = yes,
	    lsigma = lsig1,
	    hsigma = hsig1,
	   rdnoise = "0.",
  	      gain = "1.",
	    snoise = "0.",
	  sigscale = 0.1,
  	     pclip = pclp1,
  	      grow = 0.)
	      
  }

  # We erase BPM field of image header
  hedit(images=ino2,fields="BPM",add-,addonly-,del+,ver-,show-,upd+)

  if (verbose)
    {
    print "images shifted and coadded"
    print ""
    }
  
  ######################################################################
  #
  #  Variables created: 
  #		- ino1: result of first step. (=ino2 if only one step)
  #
  #  Variable erased: none variable erased
  #
  #  Variable created + erased: none variable
  #		
  #  Temporary variables used localy and existing yet: none variable
  #  
  #  State of files and images:
  #     
  #		- always --> inli contain name of input images
  #		- gtransf --> transform file name
  #		- if subsky=usrsky --> skyli contain name of input sky images 
  #		- prepostli --> contain list of images prepost treated
  #		- if prepost-treated @prepostli --> input images
  #		  else	@prepostli --> if outprps="" = input image names
  #				       esle = images to save
  #		- if (corrow|intprow) corrowli --> contain list of images corrected
  #		  else: corrowli = prepostli
  #		- if (corrow|intprow) @corrowli --> if outrow="" = temporary images
  #				                    esle = images to save
  #		- shiftwcs --> shift between images read on image headers 
  #		- xmin,xmax,ymin,ymax: coordinates of common area of images
  #		- if (subsky != "none") subli --> contain list with sky sub images
  #		  else subli = corrowli
  #		- if (subsky != "none") @subli --> if outsbsk="" = temporary images
  #					       	   else = images to save
  #		- if (iso != "" && subsky != "none") iso --> calculated sky
  #		- if (imt!="") correctli --> contain list with corrected im
  #		  else correctli=subli
  #		- if (imt!="" && imk!="") imkcorrect --> corrected imk
  #		  else imkcorrect=imk
  #		-  if (imt!="") @correctli --> if outcorr="" temp images
  #		  					      else = images to save 
  #		- dimx, dimy always --> image dimentions
  #		- if (inmatch == "manual" || inmatch == "pick1") 
  #			tfstar --> position reference temporary file
  #		- if (inmatch == "manual") tf2 --> reference star offset
  #		- if (adjshwcs) shiftwcsadj --> offset adjusted
  #		  else shiftwcsadj = shiftwcs
  #		- if (inmatch != "wcs") offset --> offset temporary file
  #		  else offset=adjshwcs
  #		- always ino1 --> image result 
  #
  #
  ######################################################################
  # --------------------------------------------------------------------
  #  End of combine images
  # --------------------------------------------------------------------
  
    
    
  # --------------------------------------------------------------------
  #  Showing results 
  # --------------------------------------------------------------------
  if (dispopt2.dispres2 && dispstep)
    {
    print ""
    print "presenting results"
    
    print "result image displayed"
    display(ino2,2)
    imexamine
    
    
    print "results presented"
    print ""
    }
  # --------------------------------------------------------------------
  #  End of result presentation 
  # --------------------------------------------------------------------
  

  # --------------------------------------------------------------------
  #  Verify errors in image combination 
  # --------------------------------------------------------------------
  #################
  #
  #  We verify errors:
  #		- Offset error lower than sherror input parameter
  #		- Visual checking of difference between results (intermediate and final)
  #
  #################
  
  # Verify offset error
  if ( inmatch != "wcs" && choffset)
    {
    print ""
    print "Verifyings combination operation errors"
    list1 = shiftwcs
    list2 = offset
    while (fscan (list2,xr,yr) != EOF)
      {
      print("Controling point [",xr,"; ",yr,"]")
      if (fscan (list1,x,y) != EOF)
        {
	diffshift = sqrt ( (x-xr)**2 + (yr-y)**2)
	print ("ecart: ",diffshift)
	if (diffshift > sherror)
	  {
	  print("WARNING: Error in offset calculated in point [",xr,"; ",yr,"] of ",diffshift," pixels")
	  }
	}
      }
    print "Combination errors verified"
    print ""
    }
  
  ######################################################################
  #
  #  Variables created: none variable
  #
  #  Variable erased: none variable
  #
  #  Variable created + erased: 
  #		- imaux: ino1 - ino2
  #		
  #  Temporary variables used localy and existing yet: 
  #		- xr,yr: read offset file
  #		- x,y: read shiftwcs file
  #  
  #  State of files and images:
  #     
  #		- always --> inli contain name of input images
  #		- gtransf --> transform file name
  #		- if subsky=usrsky --> skyli contain name of input sky images 
  #		- prepostli --> contain list of images prepost treated
  #		- if prepost-treated @prepostli --> input images
  #		  else	@prepostli --> if outprps="" = input image names
  #				       esle = images to save
  #		- if (corrow|intprow) corrowli --> contain list of images corrected
  #		  else: corrowli = prepostli
  #		- if (corrow|intprow) @corrowli --> if outrow="" = temporary images
  #				                    esle = images to save
  #		- shiftwcs --> shift between images read on image headers 
  #		- xmin,xmax,ymin,ymax: coordinates of common area of images
  #		- dimx, dimy always --> image dimentions
  #		- if (inmatch == "manual" || inmatch == "pick1") 
  #			tfstar --> position reference temporary file
  #		- if (inmatch == "manual") tf2 --> reference star offset
  #		- if (secondstep) xr,yr --> position of reference image in coadded image
  #		- if (secondstep) imkstar --> general mask image
  #		- if (secondstep) mkstli --> list of individual mask images
  #		- if (secondstep) @mkstli --> if outmkst="" temporary image name
  #					      else image to save
  #		- if (secondstep) subli --> contain list with new sky sub images
  #		  else if (subsky != "none") subli --> contain list with sky sub images
  #		  else subli = corrowli
  #		- if (subsky != "none") @subli --> if outsbsk="" = temporary images
  #					       	   else = images to save
  #		- if (iso != "") iso --> new sky image calculated in 2nd step
  #		  else if (iso != "" && subsky != "none") iso --> calculated sky
  #		- if (imt!="" ) correctli --> contain list with corrected images
  #		  else correctli=subli
  #		- if (imt!="" && imk!="") imkcorrect --> corrected mask image
  #		  else imkcorrect=imk
  #		-  if (imt!="") @correctli --> if outcorr="" temp images
  #		  					      else = images to save
  #		- if (adjshwcs) shiftwcsadj --> offset adjusted (new)
  #		  else shiftwcsadj = shiftwcs 
  #		- if (inmatch != "wcs") offset --> offset temporary file
  #		  else offset=adjshwcs
  #		- always ino2 --> final image result
  #
  ###################################################################### 
  # --------------------------------------------------------------------
  #  Errors in image combination verified
  # --------------------------------------------------------------------


tidyup: 
 
  if (verbose) print("Clean up and quit")  

  # --------------------------------------------------------------------
  #  Empty memory and erase temporary files 
  # --------------------------------------------------------------------
  #################
  #
  #  This step consist in delete temporary files. When finished only images 
  #  that we want to save would be exist
  #
  #################
  delete(inli,yes,ver-)
  ## Comprobar porque se borran los datos originales
  #if (subsky == "usrsky" && delskyli) {imdelete("@"//skyli,yes,ver-, >>& "/dev/null")}
  if (subsky == "usrsky") {delete(skyli,yes,ver-)}
  
  #if (delprepostli) {imdelete("@"//prepostli,yes,ver-, >>& "/dev/null")}
  
  delete(prepostli,yes,ver-, >>& "/dev/null")
  
  if (corrow && outrow == "" && !origcpixprepost) {imdelete("@"//corrowli,yes,ver-, >>& "/dev/null")}
  
  if (corrow ) {delete(corrowli,yes,ver-)}
  
  #if (intprow) 
   # {
   # imdelete("@"//interpli,yes,ver-, >>& "/dev/null")
   # delete(interpli,yes,ver-)
   # }
  
  if (combimg) { 

      if (inmatch == "manual" || inmatch == "pick1") {delete(tfstar,yes,ver-)}
  
      if (inmatch == "manual") {delete(tf2,yes,ver-)}
      print ("at combining ")
	  print ("sho=",sho)
	  print ("shiftwcsadj=",shiftwcsadj)
      if (sho == "")
        {
        delete (shiftwcs,yes,ver-)
        delete (shiftwcsadj,yes,ver-)
        if (inmatch == "manual" || inmatch == "pick1") {delete(offset,yes,ver-)}
        }
      else
        {
        if (inmatch == "wcs" && adjshwcs) rename (shiftwcsadj,sho)
        else delete (shiftwcsadj,yes,ver-)
        #if (inmatch == "manual" || inmatch == "pick1") rename(offset,sho)
        }
      
      delete(ishiftli,ver-,>>& "dev$null")
      if (starpos == "")
         delete(starpos1,ver-,>>& "dev$null")
    
      if (use_subpix1 && outfshift == "") 
         imdel("_lofprf*",>>& "dev$null")  
     
      if (adjshwcs)
         delete(shiftfwcsadj,ver-,>>& "dev$null")   
     
      delete (icombli,ver-,>>& "dev$null") 
      delete (foffsetplus,ver-,>>& "dev$null")  
      delete (foffset,ver-,>>& "dev$null") 
      if (outshift == "") 
         delete (offset,ver-,>>& "dev$null") 
      delete (offsetplus,ver-,>>& "dev$null")   

  }
  
  if (imf != "")  delete (fli,ver-,>>& "dev$null")

  if (subsky != "none" && outsbsk == "") {imdelete("@"//subli,yes,ver-)}
  
  if (subsky != "none") {delete(subli,yes,ver-)}
  
  if (imt != "" && outcorr == "") {imdelete("@"//correctli,yes,ver-)}
  
  if (imt != "") {delete(correctli,yes,ver-)}
  
  # clean temporary images after flatfield if no output required 
  if (corfield && outfltc == "") {imdelete("@"//flatli,yes,ver-)}

  # delete list file for flatfield 
  if (corfield) {delete(flatli,yes,ver-)}
 
  
#  if (imt != "" && imk != "") {imdelete(imkcorrect,yes,ver-)}
  
     
  if (cvgrad1)
     delete (vgradli,ver-,>>& "dev$null")   
  ## delete transformed mask in case of geometric distortion correction 
##JAP-Dec2011  if (imk != "" && imt != "") 
##JAP-Dec2011     imdel(imkcorrect,ver-,>>& "dev$null")
##     imdel(tmpdir//"_lddthimkgcorr*")
   
  ######################################################################
  #
  #  Variables created: none variable
  #
  #  Variable erased: none variable
  #
  #  Variable created + erased: 
  #		- inli (always)
  #		- skyli (if (subsky == usrsky))
  #		- @prepostli (if(delprepostli))
  #		- prepostli (always)
  #		- @corrowli (if ((corrow || intprow) && outrow == ""))
  #		- corrowli (if (corrow || intprow))
  #		- shiftwcs (always)
  #		- tfstar (if (inmatch == "manual" || inmatch == "pick1"))
  #		- tf2 (if (inmatch == "manual"))
  #		- imkstar (if (secondstep))
  #		- @mkstli (if (secondstep && outmkst == ""))
  #		- mkstli (if (secondstep))
  #		- @subli (if (subsky != "none" && outsky == ""))
  #		- subli (if (subsky != "none"))
  #		- @correctli (if (imt != "" && outcorr == ""))
  #		- correctli (if (imt != ""))
  #		- imkcorrect (if (imt != "" && imk != ""))
  #		- shiftwcsadj (if (adjshwcs))
  #		- offset (if (inmatch != "wcs"))
  #
  #		
  #  Temporary variables used localy and existing yet: none variable
  #  
  #  State of files and images:
  #     
  #		- gtransf --> transform file name
  #		- xmin,xmax,ymin,ymax: coordinates of common area of images
  #		- dimx, dimy always --> image dimentions
  #		- if (secondstep) ino1 --> intermediate image result 
  #		- always ino2 --> final image result
  #
  ###################################################################### 
  
  # clear lists
  list1 = ""
  list2 = ""
    

  if (verbose) print "LDEDITHER PROCESS FINISHED"
  
end
