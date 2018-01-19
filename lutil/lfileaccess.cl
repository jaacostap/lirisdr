# lfileaccess - checks file type and its access
# Author     : Miguel Charcos (mcharcos@ll.iac.es)
# Last Change: 10. Nov. 2003
##############################################################################
procedure lfileaccess(input)

file	input		{prompt="Input file"}
bool	exist		{prompt="does the file exist ?"}
bool	image		{prompt="does the image exist ?"}
bool	mask		{prompt="does the mask exist ?"}
bool	imglist		{prompt="does the mask exist ?"}
bool	cordist		{prompt="does the geometric distortion correction file exist ?"}
bool 	trspat		{prompt="does the spatial correction file exist"}
bool 	trspec		{prompt="does the spectral correction file exist"}
bool	verbose		{no,prompt="Verbose ?"}

begin

  string	fname,root,ext,path
  string	imtype 	=	"imh",		
				"fits",
				"fit",
				""	# Must use null string to terminate!
  string	masktype =	"pl",
				""	# Must use null string to terminate!
				
  int		contador
  
  				
  # copy input arguments to force definition at the beginning of the script
  fname=input
  
  
  lfilename(fname)
  path=lfilename.path
  root=lfilename.root
  ext=lfilename.extension
  
  
  ######
  #  
  #  We test if extension is somethink known: 
  #
  #    - if extension is imtype we verify that file exist
  #    - if extension is masktype we verify that file exist
  #    - if extension is unknown we verify if file exist
  #    - if extension was not be introduced:
  #
  #		* we verify acces to image with same name and imtype extensions
  #		* we verify acces to image with same name and masktype extension
  #		* we verify acces to file with same name
  #		  and analyse inside the file for file type 
  #
  ######
  
  exist = access(fname)
  
  if (ext != "")
    {
    # we verify if image exists
    # default output values
    image = no
    contador = 1
    while (imtype[contador] != "") 
      {
      if (ext == imtype[contador]) 
        {
	if (verbose)
	  {print "INFO: image "//root//"."//ext//" exists"}
	image = yes
	break
	}
      contador += 1
      } # end of while (imtype[contador] != "") 
    
    if (!image)
      if (verbose) 
        {print "INFO: extension "//ext//" is not image extension"}
    	
    # we verify if mask exists
    # default output values
    mask = no
    contador = 1
    while (masktype[contador] != "") 
      {
      if (ext == masktype[contador]) 
        {
	if (verbose)
	  {print "INFO: mask "//root//"."//ext//" exists"}
	mask = yes
	break
	}
      contador += 1
      } # end of while (masktype[contador] != "")	
  
    if (!mask)  
      if (verbose) 
        {print "INFO: extension "//ext//" is not mask extension"}
    
    if (!mask && !image)
      if (verbose)
        {print "WARNING: file type was not be recognised"}
    else 
      if (verbose)
        {print "INFO: file type found"}
    
    if (!exist)
      if (verbose)
        {print "WARNING: file does not exist"}
    else 	
      if (verbose)
        {print "INFO: file found"} 	
	
    } # end of if (extension != "")
  
  else # if (ext == "" )
    {
    # we verify if image exists
    # default output values
    image = no
    contador = 1
    while (imtype[contador] != "") 
      {
      if (access(fname//"."//imtype[contador])) 
        {
	if (verbose)
	  {print "INFO: image "//root//"."//imtype[contador]//" exists"}
	image = yes
	break
	}
      contador += 1
      } # end of while (imtype[contador] != "") 
    
    if (!image)
      if (verbose) 
        {print "INFO: "//root//" is not an image"}
    	
    # we verify if mask exists
    # default output values
    mask = no
    contador = 1
    while (masktype[contador] != "") 
      {
      if (access(fname//"."//masktype[contador])) 
        {
	if (verbose)
	  {print "INFO: mask "//root//"."//masktype[contador]//" exists"}
	mask = yes
	break
	}
      contador += 1
      } # end of while (masktype[contador] != "")	
  
    if (!mask)  
      if (verbose) 
        {print "INFO: "//root//" is not a mask"}
    
    # if the file exist with original name we look if its type 
    # is image list, geometric correction file, spectral transform file
    # or spatial transform file
    if (exist)
      {
      # de momento considero que son de todos estos tipos solo por existir
      # habria que indagar dentro del fichero
      imglist = yes
      cordist = yes
      trspat  = yes
      trspec  = yes
      } # endo of if (exist)
    else # if (!exist)
      {
      imglist = no
      cordist = no
      trspat  = no
      trspec  = no
      }
    
    if (mask || image) {exist = yes}
      
    } # end of else [if (ext != "" )]
  
  
 

end
