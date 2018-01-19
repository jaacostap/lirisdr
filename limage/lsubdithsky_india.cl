# lsubdithsky - generate combined sky image from dither images and 
#	    substract it to images
# Author : Miguel Charcos (mcharcos@ll.iac.es)
# Version: 25. Nov. 2003
#        28may04 - Possibility to zero offset when creating sky image (Jacosta)
#        30Oct04 - Include masking of objects when combining the images
##############################################################################
procedure lsubdithsky(input,output)

string	input		{prompt="Name of input dither images"}
string	output		{prompt="Name of output substracted images"}
string	insky		{"",prompt="name of input sky list image"}
string	outsky		{"",prompt="name of output sky image when saved"}

string	outmask  	{"",prompt="Prefix for individual star masks"}

# Combining options
pset	liskycpars	{prompt="Parameter set for sky image combination"}
	

# Directories
string	tmpdir		{")_.tmpdir",prompt="Temporary directory for file conversion"}

#string	scale		{"none",prompt="Scale images (none|mode|median|mean|<keyword>)"}
bool	verbose		{no,prompt="Verbose"}
  
bool	displsub 	{no,prompt="display sky substraction?"}
  
string *list1	{prompt="Ignore this parameter(list1)"}
string *list2	{prompt="Ignore this parameter(list2)"}
  
begin  
  
  string	fname,fname1,imsubsky,sky,sky_aux,sfield,omaskli,onesky 
  string	skyli,inli,outli,scaleli,subli,objmask
  string	logcomb
  bool		savesky,oneinsky,first,displaysub,maskobj
  int		nsc, nfil, nlow, nhigh
  real		scale1,scale2,sg
  
  maskobj = liskycpars.maskobj
  
  # expand input image name.
  inli = mktemp(tmpdir//"ldithskyinli")
  sections(input,option="fullname",> inli)
  wc(inli) | scan(nfil)
  
  displaysub = displsub
  
  # expand output image name.
  outli = mktemp(tmpdir//"ldithskyoutli")
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
      print("lsubdithsky aborted")
      print("")
      beep
      bye
      }
    } # end of While (fscan(list1,fname) !=EOF)

  
  # create an auxiliary list of sky subtracted images
  # We verify if some output image already exist
  list1 = inli
  subli = mktemp(tmpdir//"lsubli")
  While (fscan(list1,fname) !=EOF)
    {
    #lfileaccess(fname,verbose=no)
    #if (lfileaccess.exist)
    #  {
    #    imsubsky = mktemp(tmpdir//"lsubimsubsky")
    #    print (imsubsky,>>subli) 
    #  }
    #else 
    #  { 
    #    print("ERROR: input image does not exists "//fname)
    #	print("lsubdithsky aborted")
    #	print("")
    #	beep
    #	bye
    #  }  
    imsubsky = mktemp(tmpdir//"lsubimsubsky")
    print (imsubsky,>>subli) 
    } # end of While (fscan(list1,fname) !=EOF)
  
  # expand sky images
  if (insky != "") 
    {
    ## a list of input sky images is provided, just the case of extended objects
    skyli = mktemp(tmpdir//"ldithskyskyli")
    sections(insky,option="fullname",> skyli)
    if (verbose) {print "INFO: Sky image list found"}
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
  
  logcomb = mktemp (tmpdir//"ldithskylogcomb")
  scaleli = mktemp (tmpdir//"ldithskyscaleli")
  
  # verify if sky should be saved
  savesky = no
  if (outsky != "")
    {
    if (verbose) {print "INFO: option save sky result"}
    savesky = yes
    lfileaccess(outsky,verbose=no)
    if (lfileaccess.image)
      {
      savesky = no
      if (verbose) 
        {
	print "WARNING: "//outsky//" image already exist"
	print "         sky image will not be saved"
	}
      }
    }
  
  if (savesky) {sky = outsky}
  else {sky = mktemp (tmpdir//"_ldithskysky")}
  
##########################################################################
  # combine sky input images if necessary or combine 
  # input images to create sky image
  if (verbose)
    {
      print ""
      print "creating sky image...."
    }
    if (liskycpars.reject == "minmax")
      {
	if (liskycpars.nlow < 1) {
	  nlow = int(0.5 + nfil * liskycpars.nlow) 
	}
	else {
	  nlow = liskycpars.nlow
	}     
	if (liskycpars.nhigh < 1) {
	  nhigh = int(0.5 + nfil * liskycpars.nhigh) 
	}
	else {
	  nhigh = liskycpars.nhigh
	}
        if (verbose) 
         {
	   print "INFO: Using minmax rejection"
	   print "The number of rejected pixels is "
	   print "	       lower = "//nlow
	   print "	       upper = "//nhigh
	 }
      } else {
        nlow = 0
	nhigh = 0
      }
	     
    
  if ( insky == "" )
    {
    # calculate sky = median of unshifted images  
   
    ## call the routine to compute the sky    
    lmksky( input = "@"//osfn(inli),
           outsky = sky, 
	 masktype = "none",
	  maskval = 0,
	    scale = liskycpars.scale,
	     zero = liskycpars.zero,
	   reject = liskycpars.reject,    
             nlow = nlow, 
	    nhigh = nhigh,
	  statsec = liskycpars.statsec)
      
    } # end of   sky = median of unshifted images ( insky == "" )
  else # if ( insky != "" )
    {
    if (oneinsky)
      {
      list1 = skyli
      nsc = fscan(list1,sky)
      if (verbose) {print ("INFO:The sky image is",sky)}
      savesky = yes
      } # end of if (oneinsky)
    else  # if (!oneinsky) 
      {
      if (verbose) 
	{ 
          print "combining input sky images..." 
        }

      lmksky( input = "@"//osfn(skyli),
             outsky = sky, 
	   masktype = "none",
	    maskval = 0,
	      scale = liskycpars.scale,
	       zero = liskycpars.zero,
	     reject = liskycpars.reject,    
               nlow = nlow, 
	      nhigh = nhigh,
	    statsec = liskycpars.statsec)
	    
       if (maskobj) 
         { 
	   if (verbose) print "creating mask from sky images..." 
	   # subtract sky image to the list of sky images
	   list1 = skyli
	   while (fscan(list1,onesky) != EOF)
	   {
	     sky_aux = mktemp(tmpdir//"lsubdthskysub")
	     print ("subtracting: ",onesky," - ",sky," = ",sky_aux)
	     lsubscalesky(onesky,sky_aux,sky,scale=liskycpars.scale,
               zero=liskycpars.zero) 
	     # create object mask based on the subtracted images
	     if (outmask == "") 
                 objmask = mktemp(tmpdir//"ldithskyslfomsk")
	     else
	       {
	         lfilename(onesky)
		 #objmask = lfilename.path//outmask//lfilename.root//".pl"
		 objmask = outmask//lfilename.root//".pl"
	       }	 
	     print ("creating mask file ",objmask)	 	 
	      lstatis(sky_aux,nsigrej=5.,maxiter=5,addheader=no,
		 lower=INDEF,upper=INDEF,oneparam="all",verbose=no,print=no)
	      sg = (lstatis.median-lstatis.quart1)*1.4	 
	      objmasks(sky_aux,objmask,omtype="numbers",skys=lstatis.median,
	         sigmas=sg,masks="",blkstep=3,blksize=-10,
		 convolve="block 3 3",hsigma=7,hdetect=yes,ldetect=no,
		 neighbors="8",minpix=20,ngrow=2,agrow=2,>>&"/dev/null")	 
              #lstarmask(sky_aux,objmask,nsky=0,nobject=1,addheader="none",
	       #filtsize=0,nsmooth=-5,threshtype="nsigma",nsigthresh=3,
	       #checklimits=no,zmin=-10000,zmax=35000,verbose=verbose)
	     hedit(onesky,"BPM",objmask,add=yes,verify=no,update=yes,show=no)
	     imdel(sky_aux,verify=no, >>&"/dev/null")    
	   }

           imdel (sky//"_one",veri-, >>&"/dev/null")
           imrename (sky,sky//"_one")

	   lmksky(input = "@"//osfn(skyli),
                outsky = sky, 
              masktype = "goodvalue",
               maskval = 0.,
	         scale = liskycpars.scale,
	          zero = liskycpars.zero,
	        reject = liskycpars.reject,    
                  nlow = nlow, 
	         nhigh = nhigh,
	       statsec = liskycpars.statsec)

	   imdel(tmpdir//"ldithskyslfomsk*",verify=no, >>&"/dev/null")       

         }  # end of if maskobj 

      } # end of else [if (oneinsky)]
    } # end of else [if (insky == "")
    
        
  # if insky != "" and maskobj == yes then the stars have to be 
  # masked in the sky frames   
  # Work through list of images and do sky subtraction
#  if (maskobj == no || insky == "") 
#    {
  # now do sky subtraction including scale or offset if selected
  if (verbose) {print "calculating image-sky ...."}
  lsubscalesky("@"//inli,"@"//subli,sky,scale=liskycpars.scale,
     zero=liskycpars.zero)
  
  if(!savesky) 
     imdelete(sky,yes,ver-)
  
  if (!maskobj) 
    {
#      print ("renombrando imagenes sustraidas")
      imrename ("@"//subli,"@"//outli,verbose=verbose)
    }
    
  
############################################################################
  ### if object masking is selected we have to create the mask and 
  ## again perform the combination of images and subtract the resulting sky
  if (maskobj && insky == "")
    {

      list1 = inli 	# list of input images
      list2 = subli    	# list of output sky subtracted images     
      while (fscan(list1, fname) != EOF)
	{
	 nsc = fscan(list2, fname1) 
	 if (outmask == "") 
             objmask = mktemp(tmpdir//"ldthskomsk")
	 else 
	   {
	     lfilename(fname)
	     #objmask = lfilename.path//outmask//lfilename.root//".pl"
	     objmask = outmask//lfilename.root//".pl"
           }
         ## correct the vertical gradient if required
         if (verbose)
	    print ("correcting vertical gradient - intermediate image") 

	 licvgrad(input = fname1, 
	         output = fname1,
		  ctype = lcvgradpars.ctype,
                   quad = lcvgradpars.quadran,
                  nsamp = lcvgradpars.sample,
                  naver = lcvgradpars.naver,
                  order = lcvgradpars.order,
	     low_reject = lcvgradpars.lrej,
            high_reject = lcvgradpars.hrej,
               niterate = lcvgradpars.niter)
	 
	 lstatis(fname1,nsigrej=5.,maxiter=5,addheader=no,
		 lower=INDEF,upper=INDEF,oneparam="all",verbose=no,print=no)
	 sg = (lstatis.median-lstatis.quart1)*1.4	 
	 objmasks(fname1,objmask,omtype="numbers",skys=lstatis.median,
	         sigmas=sg,masks="",blkstep=3,blksize=-10,
		 convolve="block 3 3",hsigma=7,hdetect=yes,ldetect=no,
		 neighbors="8",minpix=20,ngrow=2,agrow=2,>>&"/dev/null")	 

	 hedit(fname,"BPM",objmask,add=yes,verify=no,update=yes,show=no)
	}
      # now compute sky image again, first delete the existing image
      imdel (sky//"_one",veri-, >>&"/dev/null")
      if (savesky) 
         imrename (sky,sky//"_one", >>&"dev$null")

      lmksky( input = "@"//osfn(inli),
	     outsky = sky, 
	   masktype = "goodvalue",
	    maskval = 0,
	      scale = liskycpars.scale,
	       zero = liskycpars.zero,
	     reject = liskycpars.reject,    
               nlow = nlow, 
	      nhigh = nhigh,
	    statsec = liskycpars.statsec)    

      # remove BPM keyword from the original images
      hedit("@"//osfn(inli),"BPM","",add=no,addonly=no,delete=yes,verify=no,update=yes,show=no)

  

############################################################################
      ### now subtract sky image again 
      # Work through list of images and do sky subtraction
      if (verbose) {print "calculating image-sky (2nd iteration)...."}
      imdel("@"//osfn(subli),verify=no, >>&"/dev/null") 
    
      lsubscalesky("@"//osfn(inli),"@"//osfn(subli),sky,scale=liskycpars.scale,
        zero=liskycpars.zero)
	
      if(!savesky) 
        imdelete(sky,yes,ver-)	
      
  }
   
   
  if (maskobj) {
     imrename ("@"//subli,"@"//outli,verbose=verbose) 
     } 
      
     
  # We delete temporary files. Image sky will be erased only 
  # if savesky is not active
  
  delete (inli,yes,ver-)
  delete (outli,yes,ver-)
  if (insky != "") delete (skyli,yes,ver-)
  
  imdel ("lsubimsubsky*",verify=no, >>&"/dev/null")
#  imdel ("ldithskyobjmask*",verify=no, >>&"/dev/null")
  delete (subli,yes,ver-, >>&"/dev/null")
  
  delete(logcomb,yes,ver-, >>&"/dev/null")
    
  delete(scaleli,yes,ver-, >>&"/dev/null")
  
    
  if (verbose)
    {
    print "sky treatment finished"
    print ""
    }
  
  list1 = ""
  list2 = ""
    
end  
