# lcorrfile - search correction or transformation file of input image 
# Author : Miguel Charcos (mcharcos@ll.iac.es)
# Version: 12. Jan. 2004
##############################################################################
procedure lcorrfile(input)

string	input		{prompt="Name of input image"}

# Database file
string  fbpmask  	{")_.bpmdb",prompt="bad pixel mask database file"}
string	fbcmask		{")_.bcmdb",prompt="bad column mask database file"}
string 	fgeodist	{")_.gdistdb",prompt="geometric correction database file"}
string 	ftransf		{")_.fcdb",prompt="spatial and spectral transform database file"}

# Output values
string  bpmask  	{prompt="output bad pixel mask file name (none|unknow|<name>)"}
string	bcmask		{prompt="output bad column mask file name (none|unknow|<name>)"}
string 	geodist		{prompt="output geometric correction file name (none|unknow|<name>)"}
string 	trspat		{prompt="output spatial correction file name (none|unknow|<name>)"}
string 	trspec		{prompt="output spectral correction file name (none|unknow|<name>)"}

# Datadabse directory
string  stddir  	{")_.stddir",prompt="Parametre directory for transformations"}

# interaction with user
bool	verbose		{no,prompt="Verbose"}

string *list1	{prompt="Ignore this parameter(list1)"}



begin

  string	ini
  string	fbpm,fbcm,fgd,ftrf	
  
  string	dateobs,dateyear,datemonth,dateday
  real		exptime,readexptinf,readexptsup
  string	readfile,readfileb,readdateinf,readdatesup
  
  string	orientation,detector,grism,slit
  string	detorientation,readdetector,readgrism,readslit
  
  int		nsc
  int       res_dumm
  bool		found
  
  ini = input

  # check if input image exists
  limgaccess(ini, verbose=no)
  if ( !limgaccess.exists )
    {
    beep
    print("")
    print("ERROR: input image does not exist")
    print("lcorrfile aborted")
    print("")
    beep
    bye
    }
    
  # Check if database files exists
  if (fbpmask == "") fbpm = ""
  else fbpm = stddir//fbpmask
  
  if (fbcmask == "") fbcm = ""
  else fbcm = stddir//fbcmask
  
  if (fgeodist == "") fgd = ""
  else fgd = stddir//fgeodist
  
  if (ftransf == "") ftrf = ""
  else ftrf = stddir//ftransf
   
  if (!access(fbpm))
    {
    if (verbose) print "WARNING: Bad Pixel Maks database file does not exist"
    fbpm = ""
    }
   
  if (!access(fbcm))
    {
    if (verbose) print "WARNING: Bad Column Maks database file does not exist"
    fbcm = ""
    }
   
  if (!access(fgd))
    {
    if (verbose) print "WARNING: Geometric correction database file does not exist"
    fgd = ""
    }
   
  if (!access(ftrf))
    {
    if (verbose) print "WARNING: Transform database files do not exist"
    ftrf = ""
    }

  # Podemos verificar tambien que el formato de los ficheros es correcto

  # Check image type
  bpmask = ""
  bcmask = ""
  geodist = ""
  trspat = ""
  trspec = ""
  
  limnumber(ini)
  if (limnumber.type == "none")
    {
    beep
    print("")
    print("ERROR: image type not recognised")
    print("lcorrfile aborted")
    print("")
    beep
    bye
    }
  else if (limnumber.type == "dither" || limnumber.type == "imaging")
    {
    if (verbose) 
      {
      print "INFO: image type is dither"
      print "      only geometric correction will be search"
      }
    ftrf = ""
    trspat = "none"
    trspec = "none"
    }
  else # if (limnumber.type == "spectr")
    {
    if (verbose) 
      {
        print "INFO: image type is spectre"
        print "      only spectral transformations will be search"
      }
      #fgd = ""
      #geodist = "none"
    }

  
  ###############
  # We read header information of image 
  ###############
  
  # we transform date to julian date
  imgets(image=ini//"[0]", param="DATE-OBS") 
  dateobs = imgets.value
  
  # We look for exposure time when badpixel mask search
  if (fbpm != "")
    {
    lhgets(image=ini, param="EXPTIME")
    exptime = real(lhgets.value)
    }
  
  # We look for orientation of detector if dither type
  if (fgd != "")
    {
    imgets(image=ini//"[0]", param="ROTSKYPA")
    orientation = imgets.value 
    }
  
  # We look for grism and slit if spectral type
  if (ftrf != "")
    {
    imgets(image=ini//"[0]", param="DETECTOR") 
    detector = imgets.value
    imgets(image=ini//"[0]", param="LIRGRNAM") 
    grism = imgets.value
    imgets(image=ini//"[0]", param="LIRSLNAM") 
    slit = imgets.value
    }
  
  
  ###############
  # check for bad pixel mask
  ###############
  if (fbpm != "")
    {
    list1 = fbpm
    nsc = fscan(list1)
    While (fscan(list1,readfile,readdateinf,readdatesup,readexptinf,readexptsup) != EOF)
      {
      found = yes
      lhigherdate (readdateinf,dateobs)
      if (lhigherdate.result != 2 && lhigherdate.result != 0)
        {found = no}
      lhigherdate (readdatesup,dateobs)
      if (lhigherdate.result != 1 && lhigherdate.result != 0)
        {found = no}

	if (exptime > readexptsup)
        {found = no}
      
	if (exptime <= readexptinf)
        {found = no}
		 
      if (found)
        {
	  if (verbose) print "INFO: bad pixel mask file found is "//readfile
	  bpmask = readfile
	  break
	  }
      }
    if (!found) 
      {
      if (verbose) print "WARNING: No bad pixel mask file found"
      bpmask = "unknown"
      }
    }
  
  
  ###############
  # check for bad column mask
  ###############
  if (fbcm != "")
    {
    list1 = fbcm
    nsc = fscan(list1)
    While (fscan(list1,readfile,readdateinf,readdatesup) != EOF)
      {
      found = yes
      lhigherdate (readdateinf,dateobs)
      if (lhigherdate.result != 2 && lhigherdate.result != 0)
        {found = no}
      lhigherdate (readdatesup,dateobs)
      if (lhigherdate.result != 1 && lhigherdate.result != 0)
        {found = no}
      
      if (found)
        {
	if (verbose) print "INFO: bad column mask file found is "//readfile
	bcmask = readfile
	break
	}
      }
    if (!found) 
      {
      if (verbose) print "WARNING: No bad column mask file found"
      bcmask = "unknown"
      }
    }
  
  
  ###############
  # check for geometric distortion correction file
  ###############  
  if (fgd != "")
    {
    list1 = fgd
    nsc = fscan(list1)
    While (fscan(list1,readfile,readdateinf,readdatesup,detorientation) != EOF)
      {
      found = yes
      lhigherdate (readdateinf,dateobs)
	  res_dumm = lhigherdate.result
      if (lhigherdate.result != 2 && lhigherdate.result != 0)
        {found = no}
      lhigherdate (readdatesup,dateobs)
	  res_dumm = lhigherdate.result
      if (lhigherdate.result != 1 && lhigherdate.result != 0)
        {found = no}
            
      if (found)
        {
	      if (verbose) print "INFO: geometric correction file found is "//readfile
	      geodist = readfile
	      break
	    }
      }
    if (!found) 
      {
      if (verbose) print "WARNING: No geometric correction file found"
      geodist = "unknown"
      }
    }
  #bye
  ###############
  # check for spectral and spatial transform files
  ###############
  if (ftrf != "")
    {
    list1 = ftrf
    nsc = fscan(list1)
    While (fscan(list1,readfile,readfileb,readdateinf,\
           readdatesup,readdetector,readgrism,readslit) != EOF)
      {
      found = yes
      lhigherdate (readdateinf,dateobs)
      if (lhigherdate.result != 2 && lhigherdate.result != 0)
        {found = no}
      lhigherdate (readdatesup,dateobs)
      if (lhigherdate.result != 1 && lhigherdate.result != 0)
        {found = no}
      
      if (readdetector != detector) {found = no}
      if (readgrism != grism) {found = no}
      if (readslit != slit) {found = no}
      
      if (found)
        {
	if (verbose) print "INFO: transform files found are "//readfile//" and "//readfileb
	trspat = readfile
	trspec = readfileb
	break
	}
      }
    if (!found) 
      {
      if (verbose) print "WARNING: No transform file found"
      trspat = "unknown"
      trspec = "unknown"
      }
    }
  
  
  list1 = ""

end
