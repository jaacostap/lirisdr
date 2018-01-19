# limfiles - search for correction and mask files corresponding of the image
# Author : Miguel Charcos (mcharcos@ll.iac.es)
# Version: 22. Sep. 2003
##############################################################################
procedure limfiles (input,inbpmdb)

string	input		{prompt="Input image name"}
string	inbpmdb		{")_.bpmdb",prompt="Input bpm database file name"}
string	inbcmdb		{")_.bcmdb",prompt="Input bcm database file name"}
string	ingdistdb	{")_.gdistdb",prompt="Input gdist database file name"}
string	infcdb		{")_.fcdb",prompt="Input spectral image correction database file name"}
string	stddir		{").stddir",prompt="Parameter directory"}
string	bpm		{"",prompt="Bad pixel mask found in inbpmdb database"}
string	bcm		{"",prompt="Column mask found in inbcmdb database"}
string	gdist		{"",prompt="Geometric dist file found in ingdist database"}
string	fcspatial	{"",prompt="Spatial distortion correction file found in infcspatial database"}
string	fclambda	{"",prompt="Lambda distortion correction file in infclambda database"}
bool	verbose		{no,prompt="verbose?"}

string *list1	{prompt="Ignore this parameter(list1)"}


begin

  string	fbpm,fbcm,fgdist,ffc
  string	date,detector,slit,grism
  int		nsc
  string	fname,fnameb,stdate,enddate,dettype,angles,sl,gr
  real		rotation
  
  fbpm = stddir//inbpmdb
  fbcm = stddir//inbcmdb
  fgdist = stddir//ingdistdb
  ffc = stddir//infcdb
  
  bpm = ""
  bcm = "" 
  gdist = ""
  fcspatial = ""
  fclambda = ""
  
  imgaccess(input,verbose=no)
  if (!imgaccess.exist)
    {
    beep
    print("")
    print("ERROR: input image does not exist")
    print("limfiles aborted")
    print("")
    beep
    bye
    }
  else {if (verbose) {print "INFO: image exists"}}
    
  
  # Looking for image parameters
  imgets(image=input,param="DATE-OBS")
  date = imgets.value
  if (date == "0")
    {
    beep
    print("")
    print("ERROR: input image header does not have date parameter")
    print("limfiles aborted")
    print("")
    beep
    bye
    }
  else 
    {
    date=substr(date, 1, 10)
    if (verbose) {print "INFO: image date is "//date}
    }
  
  
  imgets(image=input,param="CHIPNAME")
  detector = imgets.value
  
  #---------------------------------------------------------------------
  # We search the bad pixel mask corresponding to the image
  #---------------------------------------------------------------------
  if (verbose) 
    {
    print ""
    print "verifying bad pixel mask ..."
    }
  if (!access(fbpm))
    {
    if (verbose) 
      {print "WARNING: Bad pixel mask database file "//inbpmdb//" does not be found"}
    }
  else
    {
    if (verbose) {print "INFO: Bad pixel mask database file "//inbpmdb//" found"}
    list1 = fbpm
    nsc = fscan(list1)
    While (fscan(list1,fname,stdate,enddate) != EOF)
      {
      if (verbose) {print "checking for bad pixel mask "//fname//"..."}
      lhigherdate(date,stdate)
      if (lhigherdate.result == 1 || lhigherdate.result == 0)
        {
	lhigherdate(date,enddate)
	if (lhigherdate.result == 2 || lhigherdate.result == 0)
	  {
	  if (verbose) 
	    {print "bad pixel mask "//fname//" correspond to image "//input}
	  bpm = fname
	  break
	  }
	else
	  {
	  if (verbose) 
	    {print "bad pixel mask "//fname//" checked"}
	  }
	}
      else
        {
	if (verbose) 
	  {print "bad pixel mask "//fname//" checked"}
	}
      }
    }
  if (verbose) 
    {
    print "bad pixel mask verified"
    print ""
    }
  #---------------------------------------------------------------------
  #---------------------------------------------------------------------
  
  #---------------------------------------------------------------------
  # We search the bad column mask corresponding to the image
  #---------------------------------------------------------------------
  if (verbose) 
    {
    print ""
    print "verifying bad column mask ..."
    }
  if (!access(fbcm))
    {
    if (verbose) 
      {print "WARNING: Bad column mask database file "//inbcmdb//" does not be found"}
    }
  else
    {
    if (verbose) {print "INFO: Bad pixel mask database file "//inbcmdb//" found"}
    
    
    list1 = fbcm
    if (fscan(list1,fname)!=EOF)
      {
      if (verbose) {print "INFO: "//fname//" types of CCD"}
      }
    else 
      {
      beep
      print("")
      print("ERROR: bad column mask file format wrong")
      print("limfiles aborted")
      print("")
      beep
      bye
      }
    
    nsc = fscan(list1)
    While (fscan(list1,fname,dettype) != EOF)
      {
      if (verbose) {print "checking for bad column mask "//fname//"..."}
      if (dettype == detector)
        {
	if (verbose) 
	    {print "bad column mask "//fname//" correspond to image "//input}
	  bcm = fname
	  break
	}
      else
        {
	if (verbose) 
	    {print "bad pixel mask "//fname//" checked"}
	}
      }
    }
  if (verbose) 
    {
    print "bad column mask verified"
    print ""
    }
  
  #---------------------------------------------------------------------
  #---------------------------------------------------------------------
  
  #---------------------------------------------------------------------
  # We search distortion correction file corresponding to the image
  #---------------------------------------------------------------------
  if (verbose) 
    {
    print ""
    print "verifying geometric correction file ..."
    }  
  if (!access(fgdist))
    {
    if (verbose) 
      {print "WARNING: Geometric correction distortion database file "//inbcmdb//" does not be found"}
    }
  else
    {
    if (verbose) {print "INFO: Geometric correction distortion database file "//inbcmdb//" found"}
    
    imgets(image=input,param="ROTSKYPA")
    rotation = real(imgets.value)
    
    list1 = fgdist
    nsc = fscan(list1)
    While (fscan(list1,fname,angle) != EOF)
      {
      if (verbose) {print "checking for geometric correction file "//fname//"..."}
      if (rotation == real(angle))
        {
	if (verbose) 
	    {print "bad column mask "//fname//" correspond to image "//input}
	  gdist = fname
	  break
	}
      else
        {
	if (verbose) 
	    {print "bad pixel mask "//fname//" checked"}
	}
      }
    }
  if (verbose) 
    {
    print "geometric correction file verified"
    print ""
    }
  
  #---------------------------------------------------------------------
  #---------------------------------------------------------------------
  
  #---------------------------------------------------------------------
  # We search spectral correction file corresponding to the image
  #---------------------------------------------------------------------
  if (verbose) 
    {
    print ""
    print "verifying spectral image correction file ..."
    }
  if (!access(ffc))
    {
    if (verbose) 
      {print "WARNING: spectral image correction database file "//infcdb//" does not be found"}
    }
  else
    {
    if (verbose) {print "INFO: spectral image correction database file "//infcdb//" found"}
    
    imgets(image=input,param="LIRSLNAM")
    slit = imgets.value
    imgets(image=input,param="LIRGRNAM")
    grism = imgets.value
    
    list1 = ffc
    nsc = fscan(list1)
    While (fscan(list1,fname,fnameb,stdate,enddate,dettype,gr,sl) != EOF)
      {
      if (verbose) {print "checking for files "//fname//" and "//fnameb//" ..."}
      
      if (dettype == detector && \
          gr == grism && \
	  sl == slit)
        {
     	lhigherdate(date,stdate)
     	if (lhigherdate.result == 1 || lhigherdate.result == 0 )
     	  {
     	  lhigherdate(date,enddate)
     	  if (lhigherdate.result == 2 || lhigherdate.result == 0 )
     	    {
     	    if (verbose)
     	      {print "files "//fname//" and "//fnameb//" correspond to image "//input}
     	    fcspatial = fname
	    fclambda = fnameb
     	    break
     	    }
     	  else
     	    {
     	    if (verbose)
     	      {print "files "//fname//" and "//fnameb//" checked"}
     	    }
     	  }
     	else
     	  {
     	  if (verbose)
     	    {print "bad pixel mask "//fname//" checked"}
     	  }
        }
      else 
        {
	if (verbose)
     	  {print "files "//fname//" and "//fnameb//" checked"}
	}
      }
    }
  if (verbose) 
    {
    print "spectral image correction file verified"
    print ""
    }
  #---------------------------------------------------------------------
  #---------------------------------------------------------------------

  # presenting final results
  if (verbose) 
    {
    print ""
    if (bpm != "") {print "bad pixel mask: "//bpm}
    else {print "No bad pixel mask found"}
    if (bcm != "") {print "bad pixel mask: "//bcm}
    else {print "No bad column mask found"}
    if (gdist != "") {print "geometric correction file: "//gdist}
    else {print "No geometric correction file found"}
    if (fcspatial != "") {print "spatial curvature correction file: "//fcspatial}
    else {print "No spatial curvature correction file found"}
    if (fclambda != "") {print "spectral curvature correction file: "//fclambda}
    else {print "No spectral curvature correction file found"}
    print ""
    }


end
