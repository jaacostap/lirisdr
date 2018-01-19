procedure ligetoffset(input,ioffsets)

string	input	 {prompt="Name of file list of dither images"}
string  ioffsets {prompt="Name of output file containing integer shifts"}
string  foffsets {prompt="Name of output file containing fractional shifts"}
string	match	 {"wcs",prompt="Method used to match images (wcs|manual|pick1|<filename>)"}
string  ostars	 {"",prompt="List of stars used to register images"}
string	tmpdir	 {")_.tmpdir",prompt="Temporary directory for file conversion"}
bool	adjshift {yes,prompt="Adjust the calculated shift from image headers"}
bool	verbose	 {yes,prompt="Verbose"}
# imcentroid parameters
int	bigbox	  {17,prompt="Size of the coarse centering box"}
real    sherror	  {5.,prompt="Maximum error in pixels on offset"}
real 	psf       {4.,prompt="Value of the PSF - FWHM (pixels) to find reference stars"}
real    threshold {5.,prompt="Threshold in sigma for object detections"}
string  statsec	  {"",prompt="Image section to compute sky statistics"}

string *list1	{"",prompt="Ignore this parameter (list1)"}
string *list2	{"",prompt="Ignore this parameter (list2)"}

begin
  
  
  string  shiftwcs,shiftwcs1,shiftwcsadj,shiftfwcsadj,refshiftwcs,fname,inli,inli1
  string  tf2, tfstar, inmatch,outi,inishift,inishift1,istars
  string  fdummy
  real	  xmax,xmin,ymax,ymin,ixshftmp,iyshftmp
  int 	  opcode, nsc=0

  
  # expand input image name.
  inli = mktemp(tmpdir//"_lgtffstin")
  sections(input,option="root",> inli)
  
  inmatch = match

  istars = ""
  
  
  # --------------------------------------------------------------------
  #  Determine of general offset between inages
  #  Determine global shift using image headers
  # --------------------------------------------------------------------
  #######
  #
  #  At this step we read image headers to determine shift between images
  #  We use lshiftwcs task to determine this shift. Shift will be used in all cases
  #  for determine offset between images
  #  
  #######
  if (verbose)
    {
    print ""
    print("calculating reference shift...")
    }
  shiftwcs = mktemp (tmpdir//"_lgtffstwcs")
  
  refshiftwcs = "0"
  list1 = inli
  if (fscan (list1,fname) != EOF)
    {
      lcheckfile(fname,ver-)
      refshiftwcs = "0"
      if (lcheckfile.instrument == "LIRIS") {
	if (lcheckfile.format == "ImpB") refshiftwcs = "0"
	else if (lcheckfile.format == "UDAS") refshiftwcs = "90"
	else if (lcheckfile.format == "UNIC") refshiftwcs = "90"
	else refshiftwcs = "0"
      } else if (lcheckfile.instrument == "INGRID") 
	refshiftwcs = "90"  
    }
  
  lshiftwcs(input = "@"//inli,
     	   output = shiftwcs,
     	   format = "",
	 accuracy = 0,
	  xyshift = "both",
         addimnam = yes,
	    refer = refshiftwcs,
	  verbose = verbose,
     	   tmpdir = tmpdir)
  
  if (verbose) 
    {
    print "reference shift calculated"
    print ""
    }
   ######################################################################
  #
  #  Variables created: 
  #		- shiftwcs 
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
  #		- shiftwcs --> shift between images read on image headers 
  #
  ######################################################################
  # --------------------------------------------------------------------
  #  End of determination of offset
  # --------------------------------------------------------------------
  
  
  # --------------------------------------------------------------------
  #  Checking common area of image list
  # --------------------------------------------------------------------
  #######
  #
  #  Here we verify that images have common area. If no common area we stop
  #  ldedither task
  #  
  #######
   ### WARNING:  Sometimes the coordinates from the TCS are not available
   ### this may cause to stop the reduction. The solution now is to fix 
   ### image headers. In future a workaround solution is needed.

  if (verbose)
    {
    print ""
    print("checking common area...")
    }
  
  xmin = lshiftwcs.xmin
  xmax = lshiftwcs.xmax
  ymin = lshiftwcs.ymin
  ymax = lshiftwcs.ymax
  
  # print information about common area and check that there is some
  if (verbose)
    {
    print ( "[xmin:xmax] = ["//xmin//":"//xmax//"]")
    print ( "[ymin:ymax] = ["//ymin//":"//ymax//"]")
    }
    
  if ( !lshiftwcs.surfcom )
    {
    beep
    print("")
    print("ERROR: no common area among input files.")
    print('*****  Please verify header images and re-run ldedither')
    print("ligetoffset aborted")
    print("")
    beep
    bye
    }
  
  if (verbose)
    {
    print "common area checked"
    print ""
    }
   ######################################################################
  #
  #  Variables created: 
  #		- xmin,xmax,ymin,ymax: contain coordinates of common area 
  #
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
  #
  #
  ######################################################################
  # --------------------------------------------------------------------
  #  End of check of common area of image list
  # --------------------------------------------------------------------

######################################################################
  # --------------------------------------------------------------------
  #  Determination of reference stars. Interaction with user (if only one step)
  # --------------------------------------------------------------------
  #############
  #
  #  We determine offset with user interaction if manual or pick1 match option
  #  was choosen.
  #  For display mode we introduce contrdisp. When xmin parameter of ldispstars is
  #  UNDEF no step checking is made.
  #
  #############
 
  opcode = 4 
  
  if (inmatch == "manual")
    opcode=1
  if (inmatch == "pick1")
    opcode=2
  if (inmatch == "wcs")
    opcode=3
#  if (inmatch != "manual" && inmatch != "pick1" && inmatch != "wcs")
#    opcode=4

       
  switch (opcode) {
    ## case 1 - Manual image offset determination, loop over all images.
    ##    Using the first image, a set of reference stars is determined, 
    ##    with the rest of images, mark the reference star (first marked in previous step)
    case 1: {
      shiftwcs1 = mktemp("_lgtffstwcs1")
      list1 = shiftwcs
      while (fscan(list1,fname,ixshftmp,iyshftmp) != EOF)
        print(nint(ixshftmp),"  ",nint(iyshftmp),>> shiftwcs1)        
      tf2 = mktemp(tmpdir//"_lgtffsttf2")
      tfstar = mktemp(tmpdir//"_lgtffsttfst")
      #ldispstars (input = "@"//inli,
      ldispoff (input = "@"//inli,
             outstars = tfstar,
             outshift = tf2,
        	  #sky = "",
               shiftf = shiftwcs1,
        	 xmin = xmin,
        	 ymin = ymin,
        	 xmax = xmax,
        	 ymax = ymax,
               tmpdir = tmpdir,
             checkbox = bigbox,
              verbose = yes)
      inishift = tf2
      istars = tfstar
    }  # end of  ( inmatch == "manual")
    
    ## case 2 - Pick1, a set of reference stars are selected from the first image.
    case 2: {
      tf2 = mktemp(tmpdir//"_lgtffsttf2")
      tfstar = mktemp(tmpdir//"_lgtffsttfst")
      #ldispstars (input = "@"//inli,
      ldispoff (input = "@"//inli, 
             outstars = tfstar,
             outshift = "",
        	 #sky = "",
               shiftf = "",
        	 xmin = xmin,
        	 ymin = ymin,
        	 xmax = xmax,
        	 ymax = ymax,
               tmpdir = tmpdir,
             checkbox = bigbox,
              verbose = yes)
      istars = tfstar
    }  # end of  ( inmatch == "pick1")
    
    ## case 3 - Using the WCS offset file
    case 3: {
      if (verbose)
	{
	  print ""
	  print "Using WCS offset file ..."
	}
      ## inishift contains the name of the image, but shiftwcs no
      inishift= shiftwcs
      		
    } # end of  case 3 

    ## case 4 - A file containing the offsets is expected.
    ## 
    case 4: {
      if (verbose)
	{
	  print ""
	  print "checking input offset file ..."
	}
      if (!access(inmatch))
        {
	   print ("ERROR: offset file ",inmatch," not found")
	} 
      else 
        {
	   print ("offset file ",inmatch,"  found")
           # ignore the file name present in the input file, instead use file from input list1
           list1 = inli
           list2 = inmatch
           inishift= mktemp(tmpdir//"_lgtffstishft1")
           while (fscan(list1,fname) != EOF) 
             {
               nsc=fscan(list2,fdummy,ixshftmp,iyshftmp)
               # extract integer offsets
               print(fname,"    ",nint(ixshftmp),"  ",nint(iyshftmp),>> inishift)
             }
           
	} 
      		
    } # end of  case 4 
  } ## end switch opcode

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
   
  # --------------------------------------------------------------------
  #  Adjust offset file 
  # --------------------------------------------------------------------
  ###########
  #
  #  At this step we adjust offset making a cross-correlation between images
  #  Task used is xregister. Common area between images is used to reduce 
  #  time calculation in xregister task
  #
  ############ 
  
  
  if (adjshift)
    {
    if (verbose)
      {
      print ""
      print "Adjusting offsets using objects in the field ..."
      }
      
    shiftwcsadj = mktemp(tmpdir//"_lgtffshiftadj")    # integer offsets   
    shiftfwcsadj = mktemp(tmpdir//"_lgtffshiftfadj")   # fractional offsets
    ## obtain images and offsets from the file inishift
    list2 = inishift
    inli1 = mktemp(tmpdir//"_lgtffstin1")
    inishift1 = mktemp(tmpdir//"_lgtffstishft1") 
    while (fscan(list2,fname,ixshftmp,iyshftmp) != EOF)
       {
          print(fname,>>inli1)
          print(nint(ixshftmp),"  ",nint(iyshftmp),>>inishift1)    
       }
    limalign("@"//inli1,inishift1,ioffsets,ofshift=foffsets,psf=psf,addinam=yes,
       statsec=statsec,istars=istars,ostars=ostars)
    wc(ioffsets) | scan(nsc)   
    if (nsc <= 1) 
      {
         print("ERROR: Images cannot be properly registered")
	 beep ; beep
	 bye
      }      
    }
  else 
    {
    if (verbose) 
      {
      print ""
      print "INFO: no offset adjustment"
      print ""
      }
    list1 = inli 
    
    list2 = inishift 
    delete (ioffsets)
    while (fscan(list2,fname,ixshftmp,iyshftmp) != EOF) 
     {
          # extract integer offsets
          print(fname,"    ",nint(ixshftmp),"  ",nint(iyshftmp),>> ioffsets)
     }
    }
  
  
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
  

  delete (inli,ver-,>& "dev$null") 
  if (adjshift) {
    delete (inli1,ver-,>& "dev$null")
    delete (inishift1,ver-,>& "dev$null")
    delete (shiftwcsadj,ver-,>& "dev$null")
    delete (shiftfwcsadj,ver-,>& "dev$null")
  } 
  delete (inishift,ver-,>& "dev$null")
  delete (shiftwcs,ver-,>& "dev$null")
  if (opcode == 1) 
    delete (shiftwcs1,ver-,>& "dev$null")

  list1 = ""
  list2 = ""

bye
  
end
