# lstarfocus - wrapper for nmisc/starfocus
# Author : Miguel Charcos (mcharcos@ll.iac.es)
# Last Change: 14. Feb. 2004
##############################################################################
procedure lstarfocus (images)

string	images	{prompt="List of focusrun images or first image"}
int    	numimg	{0,prompt="Number of focusrun images"}
string	skyimg	{"",prompt="sky image"}

string	logfile	{"STDOUT",prompt="Logfile"}

# Directories
string	tmpdir	{")_.tmpdir",prompt="Temporary directory for file conversion"}

# starfocus parametres
pset	focopt	{prompt="Configuration starfocus parametres"}

bool	verbose	{"yes",prompt="Verbose"}

string *list1   {prompt="Ignore this parameter(list1)"}

begin

  string	ini,insky
  string	fname,diffile,sky
  string	imgpath,imgext
  file		tmpl,readli,inli,deli,subli,preli
  bool		indifdel
  int		inum,i,inrun

  # copy input arguments to force definition at the beginning of the script
  ini = images
  insky = skyimg
  inum = numimg
  
  # create a unique file for expanding image names given.
  readli = mktemp(tmpdir//"lstarfocusreadli")
  sections(ini,option="fullname",> readli)
  
  if (inum > 0)
    {
    inli = mktemp(tmpdir//"lstarfocusinli")
    list1 = readli
    if (fscan(list1,fname) != EOF)
      {
	lfilename (fname)
	imgpath = lfilename.path
	imgext = lfilename.imgext
	if (imgext != "") imgext = "."//imgext
	
	limnumber (fname,ver-)
	inrun = limnumber.imrun
      for (i=0; i<inum; i=i+1)
	  print(imgpath//"r"//(inrun+i)//imgext, >> inli)
      }
    else
      {
	beep
	print("")
	print("ERROR: input image list empty")
	print("lstarfocus aborted")
	print("")
	beep
	bye
	}
    }
  else {inli = readli}
  
  files ("@"//inli)
  
  # Check if input sky exist
  limgaccess(insky,ver-)
  if (limgaccess.exists == no)
    {
    if (verbose) print "WARNING: sky image does not exist"
    insky = ""
    }
  
  
  # List containing images to be deleted
  deli = mktemp(tmpdir//"lstarfocusdeli")


  #################################################################
  # Check format of sky image and do PRE-POST 
  # "sky" sky image contains prepost treated image
  #----------------------------------------------------------------
  if (insky != "")
    {
    if (verbose) print "Checking sky image format ..."
  
    tmpl = mktemp (tmpdir//"lstarfocustmpl")
    llistdiff (input = insky,
  	      output = tmpl,
  	       pname = mktemp("lstarfocus"),
  	     verbose = no,
  	      tmpdir = tmpdir)
 
    list1 = tmpl
    if (fscan(list1,fname) != EOF)
      {
      sky = fname
      if (listdiff.original == no)
        print(osfn(sky), >> deli)
      }
    else
      {
      if (verbose) print "WARNING: pre treatment substraction of sky wrong"
      sky = ""
      }
    delete (tmpl,yes,ver-)
    } # End of if (insky != "") 
  else 
    {
    if (verbose) print "INFO: no sky treatment"
    sky = ""
    } 


  #################################################################
  # Check format of input images and do PRE-POST 
  # "sky" sky image contains prepost treated image
  #----------------------------------------------------------------
  if (verbose) print "Checking input image format ..."
  
  preli = mktemp (tmpdir//"lstarfocuspreli")
  llistdiff (input = "@"//inli,
            output = preli,
             pname = mktemp("lstarfocus"),
           verbose = no,
            tmpdir = tmpdir)
 
  if (llistdiff.original == no)
    {
    files("@"//preli, >> deli)
    indifdel = yes
    }
  else indifdel = no
  
  #################################################################
  # Sky substracted process
  #----------------------------------------------------------------
  if (sky != "")
    {
    subli = mktemp(tmpdir//"lstarfocussubli")
    list1 = preli
    while (fscan(list1, fname) != EOF)
      {
      diffile = mktemp (tmpdir//"lstarfocusdiffile")
      print (diffile, >> subli)
      print (diffile, >> deli)
      imarith (operand1 = fname,
               op = "-",
               operand2 = sky,
               result = diffile,
               title = "",
               divzero = 0.,
               hparams = "",
               pixtype = "",
               calctype = "",
               verbose = no,
               noact = no)
	       
      } # End of while (fscan(list1=preli, fname) != EOF)
    delete (preli,yes,ver-)
    } # End of if (sky != "")
  else
    {subli = preli}


  #################################################################
  # Call starfocus
  #----------------------------------------------------------------
  
  starfocus(images = "@"//subli,
             focus = focopt.focus,	
             fstep = focopt.fstep,	
        nexposures = focopt.nexposures,	
              step = focopt.step,	
         direction = focopt.direction,	
               gap = focopt.gap,	
            coords = focopt.coords,
           display = focopt.display,	
             frame = focopt.frame,	
             level = focopt.level,	
              size = focopt.size,	
              beta = focopt.beta,	
             scale = focopt.scale,	
            radius = focopt.radius,	
           sbuffer = focopt.sbuffer,	
            swidth = focopt.swidth,	
        saturation = focopt.saturation,	
        ignore_sat = focopt.ignore_sat,	
        iterations = focopt.iterations,	
           xcenter = focopt.xcenter,	
           ycenter = focopt.ycenter,	
           logfile = logfile,	
          imagecur = focopt.imagecur,	
          graphcur = focopt.graphcur)	

  # delete temporary images and files
  
  delete (inli,yes,verify=no)
  delete (subli,yes,verify=no)
  if (sky != "" || indifdel)
    {
    imdelete("@"//deli,yes,verify=no)
    delete (deli,yes,verify=no)
    }

  list1 = ""

end
