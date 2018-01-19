# imnumber - determine the number of the image in the observation serial
# Author : Miguel Charcos (mcharcos@ll.iac.es)
# Version: 11. Aug. 2003
##############################################################################
procedure limnumber (input)

string 	input	{prompt="Image"}
string	type	{prompt="Type of aquisition (none|dither|spectr)"}
int	imrun	{prompt="Image run number"}
int	dedither{prompt="Number of dither"}
int	maxdith	{prompt="Total number of dither"}
int	spectr	{prompt="Number of spectrum position (0=no spectrum|1=A|2=B)"}
int 	imnum	{prompt="Number of the image in multirun sequence"}
int 	imaxnum	{prompt="Total number of image in multirun sequence"}
int	snum	{prompt="Number of exposure"}
int	smaxnum	{prompt="Total number of exposures"}
bool	sequence{prompt="Sequence recognised"}
bool	verbose	{"yes",prompt="Verbose"}

begin

  string		ini
  string		obj,otnam,auxrun0,lirgrnam
  int 		cont,nsc,cdmax
  int			ipos1,ipos2,ilen
 
  ini = input
   
  sequence = yes
  
  lcheckfile(ini,verbose=no)
  
  smaxnum = 0
  
  ######################################################################
  # Firstly we check for multirun numbers and cycles number
  #---------------------------------------------------------------------
  
  imnum = 0
  imaxnum = 0
  
  snum = 0
  smaxnum = 0
  
  imrun	= 0
  
  if (lcheckfile.instrument == "LIRIS")
  {       ### case for LIRIS
  
  if (lcheckfile.format == "ImpB")
    {
    imgets(image=ini,param="LIRIM")
    imnum = int(imgets.value)
    imgets(image=ini,param="LIRNM")
    imaxnum = int(imgets.value)
  
    imgets(image=ini,param="LIROTSEQ")
    snum = int(imgets.value)
    imgets(image=ini,param="LIROTCYC")
    smaxnum = int(imgets.value)
    
    imgets(image=ini,param="RUN")
    imrun = int(imgets.value)

    imgets(image=ini,param="OBJECT")
    obj = imgets.value
  
    imgets(image=ini,param="LIROTNAM")
    otnam = imgets.value
    
    # We consider spectrum data
    if (otnam == "OBS_SPEC_NOD")
      {
      dedither = 0
      type = "spectr"
      if (substr(obj, 1, 1) == "A") {spectr = 1}
      else if (substr(obj, 1, 1) == "B") {spectr=2}
      else
   	  {
   	  spectr = 0
   	  if (verbose) {print "WARNING: Bad spectrum aquisition format"}
   	  type = "none"
   	  sequence = no
   	  }
      }
    # We consider dedither data
    else if (fscanf(otnam,"OBS_IMG_DITHER%d",nsc) != EOF)
      {
      spectr = 0
      if (substr(obj, 1, 1) == "D")
   	{
   	cdmax = int(substr(obj, 5, 5))
   	if (cdmax == nsc)
   	  {
   	  dedither = int(substr(obj, 3, 3))
   	  maxdith = nsc
   	  type = "dither"
   	  }
   	else
   	  {
   	  dedither = 0
   	  maxdith = 0
   	  if (verbose) {print "WARNING: Bad dither aquisition format"}
   	  type = "none"
   	  sequence = no
   	  }
   	}
      else
   	{
   	if (verbose) {print "WARNING: Bad dither aquisition format"}
   	dedither = 0
   	maxdith = 0
   	type = "none"
   	sequence = no
   	}
      } # end of if (fscanf(otnam,"OBS_IMG_DITHER%d",nsc) != EOF)
 
 
    # we consider no spectrum and no dedither data
    else
      {
      if (verbose) {print "WARNING: No format type recognise"}
      type = "none"
      spectr = 0
      dedither = 0
      maxdith = 0
      sequence = no
      }
    
    }
  else if (lcheckfile.format == "UNIC" || lcheckfile.format == "UDAS")
    {
    #if (lcheckfile.format == "UNIC")
    #  imgets(image=ini,param="RUNSET")
    #else # if (lcheckfile.format == "UDAS")
    #  imgets(image=ini//"[0]",param="RUNSET")
    lhgets(image=ini,param="RUNSET")
    
    auxrun0 = lhgets.value
    ilen = strlen(auxrun0)
    
    ipos1 = stridx(":",auxrun0)
    imnum = int(substr(auxrun0,1,ipos1-1))
    auxrun0 = substr(auxrun0,ipos1+1,ilen)
    
    ipos1 = stridx(":",auxrun0)
    imaxnum = int(substr(auxrun0,1,ipos1-1))
    imrun = int(substr(auxrun0,ipos1+1,ilen))
    lhgets (image=ini,param="OBJECT")
    obj = lhgets.value
    if (obj == "0")
      {
	lhgets (image=ini,param="i_title")
      obj = lhgets.value
	}
    lhgets (image=ini,param="LIRGRNAM")
    lirgrnam = lhgets.value
    
    
    # We consider imaging data
    if (lirgrnam == "clear")
      {
      spectr = 0
      type = "imaging"
      if (substr(obj, 1, 1) == "D" || substr(obj, 1, 1) == "N") 
        {
	  maxdith = int(substr(obj, 4, 4))
	  dedither = int(substr(obj, 2, 2))

	  if (substr(obj, 5, 5) == "-")
            {
	    snum =  int(substr(obj, 6, 6)) 
            #smaxnum = int(substr(obj, 8, 8))
	    }
	  else 
            {
            lhgets(image=ini,param="LIROTSEQ")
            snum = int(lhgets.value)
	    if (snum == 0) snum =  1 

	    lhgets(image=ini,param="LIROTCYC")
            #smaxnum = int(lhgets.value)
	    }
        }
      }
    # We consider spectrum data
    else if (lirgrnam != "clear") 
      {
        dedither = 0
        type = "spectr"
        if (substr(obj, 1, 1) == "A") 
           spectr = 1
	if (substr(obj, 1, 1) == "B")
	   spectr = 2
      }
    # we consider no spectrum and no dedither data
    else
      {
      if (verbose) {print "WARNING: No format type recognised"}
      type = "none"
      spectr = 0
      dedither = 0
      maxdith = 0
      sequence = no
      }
    }
  else # if (lcheckfile.format == "unknown")
    {
    if (verbose) 
      {
      print "WARNING: format not recognised"
      print "         multirun and cycle number will not be determined"
      }
    imnum = 0 	  
    imaxnum = 0
    snum = 0     
    #smaxnum = 0
    if (verbose) {print "         No image type determined"}
    type = "none"
    spectr = 0
    dedither = 0
    maxdith = 0
    sequence = no
    }
  
  }  ## end of LIRIS case
  
  
  if (lcheckfile.instrument == "INGRID")
  {       ### case for INGRID
    imgets(image=ini,param="INGIM")
    imnum = int(imgets.value)
    imgets(image=ini,param="INGNM")
    imaxnum = int(imgets.value)
    
    imgets(image=ini,param="RUN")
    imrun = int(imgets.value)

    imgets(image=ini,param="OBJECT")
    obj = imgets.value
    type = "dither"
   
  }
    
  if (imnum == 0 || imaxnum == 0)
    {sequence = no}
  
  if (imrun == 0)
    {sequence = no}
  
  if (snum == 0)
    {sequence = no}

end



