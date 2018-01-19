# lspctsky - generate combined substracted sky image from spectral images 
# Author : Miguel Charcos (mcharcos@ll.iac.es)
# Version: 25. Nov. 2003
##############################################################################
procedure lspctsky(input)

string	input		{prompt="Name of input spectral image list"}
string	output		{"",prompt="Output substracted image prefix name"}
string  outlist		{"",prompt="Output list file containing substracted images"}
string  oflist		{"",prompt="Output list of original and sky substracted images"}
bool	zerobkg  	{yes,prompt="Set background to zero?"}
string	insky		{"",prompt="name of input sky list image"}
string	outsky		{"",prompt="name of output sky image when saved"}

# Combine parametres
pset	combspsky	{prompt="Combine parametre configuration"}

# Directories
string	tmpdir		{")_.tmpdir",prompt="Temporary directory for file conversion"}

bool	verbose		{no,prompt="Verbose"}
  
  
string *list1	{prompt="Ignore this parameter(list1)"}
string *list2	{prompt="Ignore this parameter(list2)"}
string *list3	{prompt="Ignore this parameter(list3)"}
  

begin   
  
  string	fname,imsubsky,imsubskyb,sky,imA,imB,osky,isky
  string	skyli,inli,outli,ofli,imAli,imBli,ino
  string	logf
  string	imAstdout,imBstdout
  bool		first, oneinsky,delsky
  int		nsc,contA,contB
  int		cont,contmax
  real		md
  
  # expand input image name.
  inli = mktemp(tmpdir//"ldithskyinli")
  sections(input,option="fullname",> inli)
  
  ino = output
  outli = outlist
  ofli = oflist
  
  # Verify if output list already exist
  if (access(outli))
    {
    beep
    print("")
    print("ERROR: operation would overwrite output image list file")
    print("lspctsky aborted")
    print("")
    beep
    bye
    }
      
  # We verify if some output image already exist
  if (ino != "")
    {
    list1 = inli
    While (fscan(list1,fname) !=EOF)
      { 
      lfilename(fname)
      if (lfilename.ext != "")
        {fname = ino//"_"//lfilename.reference//"."//lfilename.ext}	
      else {fname = ino//"_"//lfilename.reference}
      
      lfileaccess(fname,verbose=no)
      if (lfileaccess.exist)
    	{
    	beep
    	print("")
    	print("ERROR: operation would override output image "//fname)
    	print("lspctsky aborted")
    	print("")
    	beep
    	bye
    	}
      } # end of While (fscan(list1,fname) !=EOF)
    }
  
  isky = insky
  # expand input sky images 
  if (isky != "")
    {
    skyli = mktemp(tmpdir//"ldithskyskyli")
    sections(isky,option="fullname",> skyli)
    if (verbose) {print "INFO: Sky image list found ("//isky//")"}
    first = yes
    oneinsky = yes
    list1 = skyli
    While (fscan(list1,fname) != EOF)
      {
      if (first) {first = no}
      else 
        {
	oneinsky = no
	break
	} 
      }
    }
  else 
    {if (verbose) {print "INFO: No input sky image found"}}  
  
  # verify if output sky already exists
  # if it does not exist combined input sky will be saved as
  # outsky
  osky = outsky
  if (isky == "")
    {osky = ""}
  else
    {
    limgaccess(osky,ver-)
    if (limgaccess.exists)
      {
      if (verbose) 
        {
        print "WARNING: "//osky//" already exists"
        print "         sky will not be saved"
        }
      osky = ""
      } # end of if(limgaccess.exists)
    } # end of else [if (isky == "")]
  
  # we verify if sky will be saved (= !delsky)
  # sky will be saved if output sky does not exists and
  # more than one input image are introduced
  if (isky != "") {delsky = ((osky == "") || oneinsky)}

  
  # decide if to show output
  if ( verbose )
    logf = "STDOUT"
  else
    logf = ""
  
  #-------------------------------------------------------------
  # End of verification of input variables
  ##############################################################
  
  ##############################################################
  # Combine input image sky and obtain only one result sky
  # This sky will be substracted if extend input object, i.e
  # when input sky image exists
  #-------------------------------------------------------------
  
  # combine input sky images if they exist and are more than one
  if (isky != "")
    {
    if (oneinsky)
      {
      list1 = skyli
      nsc = fscan(list1,sky)
      } # end of if (oneinsky)
    else
      {
      sky = mktemp(tmpdir//"lspctskysky")
      
      if (verbose) {print "combining input sky images..."}
      imcombine (input = "@"//osfn(skyli),
    		output = sky,
    	       rejmask = "",
    		plfile = "",
    		 sigma = "",
    	       logfile = logf,
    	       combine = "median",
    		reject = combspsky.reject,
    	       project = combspsky.project,
    	       outtype = combspsky.outtype,
    	       offsets = "",
    	      masktype = "none",
    	     maskvalue = 0.,
    		 blank = 1.,
    		 scale = combspsky.scale,
    		  zero = combspsky.zero,
    		weight = combspsky.weight,
    	       statsec = combspsky.statsec,
    	       expname = combspsky.expname,
    	    lthreshold = combspsky.lthreshold,
    	    hthreshold = combspsky.hthreshold,
    		  nlow = combspsky.nlow,
    		 nhigh = combspsky.nhigh,
    		 nkeep = combspsky.nkeep,
    		 mclip = combspsky.mclip,
    		lsigma = combspsky.lsigma,
    		hsigma = combspsky.hsigma,
    	       rdnoise = combspsky.rdnoise,
    		  gain = combspsky.gain,
    		snoise = combspsky.snoise,
    	      sigscale = combspsky.sigscale,
    		 pclip = combspsky.pclip,
    		  grow = combspsky.grow)
      
      } # end of else [if (oneinsky)]
    delete (skyli,yes,ver-)
    } # end of if (isky != "")
  
  #---------------------------------------------------------
  # End of input sky combination
  # sky contain combined sky
  ##########################################################
  
  ##########################################################
  # At this step we substract sky of images
  # If input sky image has been introduced sky will be substracted
  # to each input images. Else substraction will be apply 
  # betwee A and B images
  #---------------------------------------------------------
  
  
  # substract A/B images if no input sky image introduce or
  # substract directly input sky image
  if (verbose)
    {
    print ""
    print "sky treatment"
    }

  if ( isky != "" )
    {
    if (verbose) {print "substracting input sky image..."}
    
    list1 = inli
    While (fscan(list1,fname) != EOF)
      {
      lfilename(fname)
      if (ino != "") imsubsky = ino//"_"//lfilename.reference//"."//lfilename.ext
      else 
        {
	imsubsky = mktemp(tmpdir//"lspctskyimsubsky")
	imsubsky = imsubsky//"_"//lfilename.reference//"."//lfilename.ext
	}
      if (verbose) print "substracting sky to "//fname//" ..."
      imarith (operand1 = fname,
                     op = "-",
               operand2 = sky,
                 result = imsubsky,
                  title = "",
                divzero = 0.,
                hparams = "",
                pixtype = "",
               calctype = "",
                verbose = no,
                  noact = no)
      
      if (outli != "") print (imsubsky, >> outli)
      }
    } # end of if ( isky != "" )
  
  else # if ( isky == "" )
    {
    # calculating A-B
    if (verbose) {print "calculating A-B images ...."}
    
    #######
    #  The process is this one:
    #		- We read an image of the input list
    #		- We read its header and we calculate how many 
    #		  images are in the multirun sequence
    #		- We suppose that list is correctly and we build 
    #		  the rest of the multirun sequence
    #
    #		(in the last two steps images of multirun sequence
    #		 are introduced in imAli and imBli lists)
    #
    #		- When lists of multirun sequence built, first element
    #		  of imAli is substraced to first element of imBli, second
    #		  to second, ... until one list finished or output image list
    #		  finished.
    #  
    #######
      
      
      # we create imAli and imBli names
      imAli = mktemp(tmpdir//"lspectrimAli")
      imBli = mktemp(tmpdir//"lspectrimBli")
      
      list1 = inli
      While (fscan(list1,fname) != EOF)
        {
	
	# number of multirun sequence images is calculated 
	# and first image added to corresponding list
	limnumber(fname)
	contmax = limnumber.imaxnum
	if (limnumber.spect == 1) 
	  {
	  print (fname,>>imAli)
	  contA = 1
	  contB = 0
	  }
	else if (limnumber.spect == 2)
	  {
	  print (fname,>>imBli)
	  contA = 0
	  contB = 1
	  }
	
	# multirun sequence list is completed
	cont = 1
	contmax = 2*contmax - 1
	nsc = 1
	While (nsc != EOF && cont<=contmax)
	  {
	  nsc = fscan(list1,fname)
	  limnumber(fname)
	  if (limnumber.spect == 1) 
	    {
	    print (fname,>>imAli)
	    contA = contA + 1
	    #contB = contB
	    }
	  else if (limnumber.spect == 2)
	    {
	    print (fname,>>imBli)
	    #contA = contA
	    contB = contB + 1
	    }
	  cont = cont+1
	  } # end of While (nsc != EOF && cont<=contmax)
	
	if (contA != contB)
	  {
	  beep
	  print("")
	  print("ERROR: multirun sequence wrong ("//fname//")")
	  print("lspcsky aborted")
	  print("")
	  beep
	  bye
	  }
	} # end of While (fscan(list1=inli,fname) != EOF)
	

      # images of imAli and imBli are substracted
      list1 = imAli
      list2 = imBli
      While (fscan (list1,imA) != EOF && \
	       fscan (list2,imB) != EOF)
	{
        if (ino != "") 
	  {
	  lfilename(imA)
	  imAstdout = lfilename.reference
	  #print("imAstdout "//imAstdout)
	  imsubsky = ino//lfilename.reference
	  lfilename(imB)
	  imBstdout = lfilename.reference
	  #print("imBstdout "//imBstdout)
	  #imsubsky = imsubsky//lfilename.reference//"."//lfilename.ext
	  imsubsky = ino//imAstdout//"_"//imBstdout
	  imsubskyb = ino//imBstdout//"_"//imAstdout
	  }
        else 
	  {
	  imsubsky = mktemp(tmpdir//"lspctskyimsubsky")
	  lfilename(imA)
	  imAstdout = lfilename.reference
	  imsubsky = imsubsky//"_"//lfilename.reference
	  lfilename(imB)
	  imBstdout = lfilename.reference
	  #imsubsky = imsubsky//lfilename.reference//"."//lfilename.ext
	  imsubsky = ino//imAstdout//"_"//imBstdout
	  imsubskyb = imBstdout//"_"//imAstdout
	  #imsubsky = imsubsky//lfilename.reference
	  }
	
	if (verbose) print "substracting "//imBstdout//" to "//imAstdout//" ..."
	imarith (operand1 = imA,
                       op = "-",
                 operand2 = imB,
                   result = imsubsky,
                    title = "",
                  divzero = 0.,
                  hparams = "",
                  pixtype = "",
                 calctype = "",
                  verbose = no,
                    noact = no)
		    
	imarith (operand1 = imB,
                       op = "-",
                 operand2 = imA,
                   result = imsubskyb,
                    title = "",
                  divzero = 0.,
                  hparams = "",
                  pixtype = "",
                 calctype = "",
                  verbose = no,
                    noact = no)
		    
	
	if (zerobkg) 
	  {
	     imstatistics(imsubsky,fields="midpt",format=no) | scan(md)
	     imarith(imsubsky,"-",md,imsubsky)
             imstatistics(imsubskyb,fields="midpt",format=no) | scan(md) 
	     imarith(imsubskyb,"-",md,imsubskyb)
	  }
	
	if (outli != "") print (imsubsky, >>outli)
	if (ofli != "") {
	     print (imsubsky,"  ",imA, >>ofli)
	     print (imsubskyb,"  ",imB, >>ofli)
          }
	} # end of While (fscan (list2 = imAli,imA) != EOF && ...)

      delete (imAli,yes,verif-)
      delete (imBli,yes,verif-)
	
    } # end of else [if ( isky != "" )]
    
  # We delete temporary files
  delete (inli,yes,verif-)
  
  if (isky != "")
    {
    if (delsky) {imdelete(sky,yes,ver-)}
    else {imrename(sky,osky,verbose-)}
    }
    
  if (verbose)  
    {
    print "sky treated"
    print ""
    }

  # clear lists
  list1 = ""
  list2 = ""
  list3 = ""

end
