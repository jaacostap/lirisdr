# ltransform - make spatial and spectral correction 
# Author : Miguel Charcos (mcharcos@ll.iac.es)
# Version: 13. Jan. 2004
##############################################################################
procedure ltransform (input,output,trspat,trspec)


string	input 		{prompt="Input images"}
string	output 		{prompt="Output images"}
string 	trspat		{"default",prompt="name of spatial correction file (<filename>|default)"}
string 	trspec		{"default",prompt="name of spectral correction file (<filename>|default)"}

# Mask parametres
string  inmask  	{"",prompt="name of input mask file"}
string  outmask		{"",prompt="name of output corrected mask"}

# Directories
string  database  	{"database",prompt="Directory containing spectral correction"}
string  tmpdir  	{")_.tmpdir",prompt="Temporary directory for file conversion"}
string  stddir  	{")_.stddir",prompt="Parametre directory for transformations"}

bool	verbose		{no,prompt="Verbose?"}

#Dimention of the image
int	x1 		{INDEF,prompt="Output starting x coordinate"}
int	x2 		{INDEF,prompt="Output ending x coordinate"}
int	nx		{INDEF,prompt="Number of output x pixels"}
int	y1	 	{INDEF,prompt="Output starting y coordinate"}
int	y2	 	{INDEF,prompt="Output ending y coordinate"}
int	ny	  	{INDEF,prompt="Number of output y pixels"}

string	interptype	{"spline3",prompt="Interpolation type (nearest|linear|poly3|poly5|spline3)"}

string *list1	{prompt="Ignore this parameter(list1)"}


begin

  string 	inli,outli
  string 	fname
  int 		nsc
  int		dx,dy
  string	imk,imkcorrect
  string 	imtspatial,imtlambda,imt,dbdir
  string 	imtspatialaux,imtlambdaaux
  int		dispax


  ####################################################
  # Check input parametres
  #---------------------------------------------------
  
  # expand input image name.
  inli = mktemp(tmpdir//"ltransforminli")
  sections(input,option="fullname",> inli)

  # expand output image name.
  outli = mktemp(tmpdir//"ltransformoutli")
  sections(output,option="fullname",> outli)
  # We verify if some output image already exist
  list1 = outli
  While (fscan(list1,fname) !=EOF)
    {
    lfileaccess(fname,verbose=no)
    if (lfileaccess.exist)
      {
      beep
      print("")
      print("ERROR: operation would overwrite output image "//fname)
      print("ltransform aborted")
      print("")
      beep
      bye
      }
    } # end of While (fscan(list1,fname) !=EOF)  
  
  imtspatial = trspat
  imtlambda = trspec
  dbdir = database//"/"
  
  
  print("dbdir ",database)
  
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
      else
        {
	nsc = strlen(imtspatial)
	imtspatial = substr(imtspatial,3,nsc)
	}
      } # end of if (imtspatial == "default")
    if (imtlambda == "default")
      {
      dbdir = lirisdr.stddir
      imtlambda = lcorrfile.trspec
      if (imtlambda == "none" || imtlambda == "unknown")
        {
	if (verbose) print "WARNING: default spectral transform file not found"
	imtlambda = ""
	}
      else
        {
	nsc = strlen(imtlambda)
	imtlambda = substr(imtlambda,3,nsc)
	}
      } # end of if (imtlambda == "default")
    
    } # end of if (imtspatial == "default" || imtlambda == "default")
  
  # check if correction will be applied
  if (imtspatial != "") {imtspatialaux = dbdir//"fc"//imtspatial}
  else {imtspatialaux = ""}
  if (imtlambda != "") {imtlambdaaux = dbdir//"fc"//imtlambda}
  else {imtlambdaaux = ""}
  
  # check if geometric correction files exist
  if ( access(imtspatialaux))
    {
    if (verbose) print("INFO: spatial transform file found is ",imtspatialaux)
    imt = imtspatial
    if ( access(imtlambdaaux))
      {
      if (verbose) print("INFO: spectral transform file found is ",imtlambdaaux)
      imt = imt//","//imtlambda
      }
    else
      {
      if (verbose) print("INFO: spectral transform file not found")
      }
    }
  else 
    {
    if ( access(imtlambdaaux))
      {
      if (verbose) print("INFO: spectral transform file found is ",imtlambdaaux)
      imt = imtlambda
      }
    else 
      {
      beep
      print("")
      print("ERROR: spectral transform file not found ",imtlambdaaux)
      print("ltransform aborted")
      print("")
      beep
      bye
      }
    }
  
  



  # check if mask will be used
  if (inmask == "") {imk = ""}
  else {imk = stddir//inmask}

    
  # check if mask file exist
  lmaskaccess(imk, verbose=no)
  if ( lmaskaccess.exists)
    {if (verbose) print("INFO: input mask image found")}
  else if (imk == "")
    {if (verbose) print("INFO: no input mask image")}
  else #if (imk != "")
    {
    if (verbose)
      {
      print("WARNING: input mask image not found")
      print("         mask will not be considered")
      }
    }

  # check if output mask exist if input mask introduced correctly
  if (imk != "")
    {
    if (outmask == "") {imkcorrect = ""}
    else {imkcorrect = stddir//outmask}
    
    # check if output mask file exists
    if (outmask != "")
      {
      lmaskaccess(imkcorrect, verbose=no)
      if ( lmaskaccess.exists)
        {
        if (verbose) 
          {
	  print("WARNING: output mask image already exist")
	  print("         corrected mask will not be calculated")
	  }
        imk = ""
	imkcorrect = ""
	}
      }
    }
  else {imkcorrect = ""}  
  
  #------------------------------------------------
  # End of checking of input variables
  #################################################
  
  #################################################
  # We read dispertion axis
  #------------------------------------------------
  
  dispax = lspect.dispaxis

  hedit ("@"//osfn(inli),"DISPAXIS",dispax,addonl+,add-,updat+,verify-)

  list1 = inli
  nsc = fscan(list1,fname)
  imgets(image=fname,param="DISPAXIS")
  dispax = int(imgets.value)
  While (fscan(list1,fname) !=EOF)
    {
    imgets(image=fname,param="DISPAXIS")
    if (dispax != int(imgets.value))
      {
      beep
      print("")
      print("ERROR: dispertion axis of "//fname//" image does not correspond")
      print("ltransform aborted")
      print("")
      beep
      bye
      }
    } # end of While (fscan(list1,fname) !=EOF)  
  
  if (dispax == 1)
    {
    if (verbose) print "INFO: Dispertion axis is "//dispax
    dx = INDEF
    dy = 1
    }
  else if (dispax == 2)
    {
    if (verbose) print "INFO: Dispertion axis is "//dispax
    dx = 1
    dy = INDEF
    }
  else 
    {
    if (verbose) print "WARNING: Dispertion axis incorrect"
    dx = INDEF
    dy = INDEF
    }
  
  ###############################################################
  # We correct images using interptype interpolation variable  
  # and input correction files
  # The flux per pixel is conserved
  #--------------------------------------------------------------
  if (verbose) print "correcting images ..."
    
   
  transform (input = "@"//osfn(inli),         
  	    output = "@"//osfn(outli),
  	  fitnames = imt,
  	   databas = dbdir,
  	   interpt = interptype,
  		x1 = x1,
  		x2 = x2,
  		dx = dx,
  		nx = nx,
  	      xlog = no,
  		y1 = y1,
  		y2 = y2,
  		dy = dy,
  		ny = ny,
  	      ylog = no,
  	      flux = yes,
          logfiles = "")
   
  if (imk != "")
    {
    lfilename(imkcorrect)
    imkcorrect = lfilename.path//lfilename.root//".pl"
    if (verbose) print "correcting mask ..."
    transform (input = imk,
              output = imkcorrect,
            fitnames = imt,
             databas = stddir,
             interpt = interptype,
        	  x1 = x1,
        	  x2 = x2,
        	  dx = dx,
        	  nx = nx,
        	xlog = no,
        	  y1 = y1,
        	  y2 = y2,
        	  dy = dy,
        	  ny = ny,
        	ylog = no,
        	flux = yes,
            logfiles = "")
	    
    # We correct mask to obtain only values 0 and 1
    lcorrmask(imkcorrect,limit=0.5)
    }


  delete (inli,yes,ver-)
  delete (outli,yes,ver-)

  list1 = ""
end
