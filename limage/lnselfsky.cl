# lnselfsky - generate combined sky image from dither images and 
#	    substract it to images by cycles
# Author : Jose Acosta (jap@ll.iac.es)
# Version: 12. Nov. 2007
##############################################################################
procedure lnselfsky(input,output,nditpts)

string	input		{prompt="Name of input dither images"}
string	output		{prompt="Prefix name of output substracted images"}
int     nditpts         {prompt="Number of dithern points per cycle"}
string	outlist		{prompt="List name containing sky substracted images"}
string	outsky		{"",prompt="name of output sky images when saved"}
string	outmask  	{"",prompt="Prefix for individual star masks"}


# Combining options
pset	liskycpars	{prompt="Combine parameter configuration"}

# Working Directory
string	tmpdir		{")_.tmpdir",prompt="Temporary directory for file conversion"}

# Verbosity
bool	verbose		{no,prompt="Verbose?"}  
bool	displsub 	{no,prompt="display sky substraction?"}
  
# internal use
string *list1	{prompt="Ignore this parameter(list1)"}
string *list2	{prompt="Ignore this parameter(list2)"}
string *list3	{prompt="Ignore this parameter(list3)"}
  
begin  

  string	ino,isi,isiact,iso,isoact,fname,imsky,imskysb,flist
  string	inli,outli,inskyli,readli,writeli,isili,difli,arunli
  string	inlili,outlili,isilili,diflili,fext
  string        inrunli[300],skyrun1,skyaux1,onesky,objmask
  string	skytmp[15]
  
  string	junk1,junk2,junk3,junk4
  string	path1,path2,path3,path4,pathim
  string	auxref1,auxref2,auxref3
  
  int		nsc,nscmax,i,imcont,skycont,isitype,inrun,igrp
  int		nsky,nhsky1,nhsky2
  bool		found, verb1, corvgrad, maskobj
  real		skyrms = 0.
  
  verb1 = verbose
  corvgrad = liskycpars.corvgrad
  maskobj = liskycpars.maskobj
  
  # number of sky frames to be combined
  nsky = nditpts 
  nhsky1 = (nsky-1)/2 
  nhsky2 = nsky/2

  # expand input image name.
  inli = mktemp(tmpdir//"_lnslskyinli")
  sections(input,option="fullname",> inli)

  # expand output image name.
  ino = output
  outli = mktemp(tmpdir//"_lnslskyoutli")
  files(ino//"//@"//inli,> outli)
  # We verify if some output image already exist
  list1 = outli
  imcont = 0
  While (fscan(list1,fname) !=EOF)
    {
    imcont = imcont + 1
    lfileaccess(fname,verbose=no)
    if (lfileaccess.exist)
      {
      beep
      print("")
      print("ERROR: operation would overwrite output image "//fname)
      print("lcycsky aborted")
      print("")
      beep
      bye
      }
    } # end of While (fscan(list1,fname) !=EOF)
  delete (outli,yes,ver-)
  
  outli = outlist
  if (access(outli))
    {
    beep
    print("")
    print("ERROR: operation would overwrite output file "//outli)
    print("lcycsky aborted")
    print("")
    beep
    bye
    }
  
  iso = outsky
  isoact = ""
  isiact = ""
  
  ########################################################################
  # We create a list containing every list to consider separately
  #  Images will be orderer according to acquisition sequence. 
  #  Expected as a number of runs (indicated in the header) at the same position on the sky, or 
  #  dither point, then move to the next dithern point and get a number
  #  of runs. A cycle finish when the dithern pattern is finished.
  #  Initially the number of dithern points will be an specified parameter,
  #  later should be possible to obtain from the image header. 
  #-----------------------------------------------------------------------
  if (verbose)
    {print "Separating images per cycle ..."}
    
# for each cycle a file list containing the names of files containing the list
# of images split according to the run sequence 

  inlili = mktemp (tmpdir//"_lnslskyinlili")
  outlili = mktemp (tmpdir//"_lnslskyoutlili")
  arunli = mktemp (tmpdir//"_lnslfrunli")
  writeli = mktemp (tmpdir//"_lnslskywriteli")
  
  list1 = inli
  while (fscan(list1,fname) != EOF)
    {
    limnumber (fname, ver-)
    # get the index in the multrun sequence
    nsc = limnumber.imnum
    nscmax = limnumber.imaxnum 
    if (!access(arunli//nsc))
      {
        print (arunli//nsc, >> inlili)
        print (writeli//nsc, >> outlili)
      }
    
		 
    lfilename (fname)
    print (fname, >> arunli//nsc)

    if (verbose) print "adding image "//lfilename.reference//" to run list "//nsc
 
    print (ino//lfilename.reference, >>writeli//nsc)
    print (ino//lfilename.reference, >>outli)
    
      	 
    } # End of While (fscan(list1=difli) != EOF)

    
  ## now read each file list  
  list1 = inlili
  igrp = 1
  while (fscan(list1,flist) != EOF)
    {
       if (verbose) print ("working with group ",igrp)
       list2 = flist
       print ("flist ",flist)
       inrun = 1
       while (fscan(list2,fname) != EOF)
       {
          inrunli[inrun] = fname 
	  inrun += 1
       }

       for (i=1; i<inrun; i=i+1)
       {
          ## assign sky name
	  skyrun1= iso//inrunli[i]
	  if (verbose) print ("Selecting sky frames of image ",inrunli[i])
          
	  ## select sky files 
	  if ((i > nhsky1) && (i < inrun-nhsky2)) 
	    {
	       for (j=1; j <= nhsky1; j=j+1)
	         skytmp[j] = inrunli[i-nhsky1-1+j] 
	       for (j=nhsky1+1; j <= nhsky1+nhsky2; j=j+1)
	         skytmp[j] = inrunli[i+j-nhsky1]
	    }
	  if (i <= nhsky1)
	    {
	       ##if (i > 1) 
	       ##  skytmp[1:i-1] = inrunli[1:i-1]
	       for (j = 1; j <= i -1; j=j+1)
	         skytmp[j] = inrunli[j]
	       for (j = i ; j <= nhsky1+nhsky2; j=j+1)
	         skytmp[j] = inrunli[j+1]	 
	       ##skytmp[i:2*nhsky1] = inrunli[i+1:2*nhsky1+1]
	    }
	  if (i >= inrun-nhsky2)
	    {
               for (j=1; j <= nhsky1 + nhsky2 - (inrun-i-1) ; j=j+1)
	         skytmp[j] = inrunli[inrun-(nhsky1+nhsky2)-2+j]
	    }
	       
	  inskyli = mktemp("_lnskli")     
	  for (j=1; j<=nhsky1+nhsky2; j=j+1)
	    {
	       # check if image has extensions
	       lcheckfile(skytmp[j])
	       if (lcheckfile.nimages > 0) 
        	 fext = "[1]"
	       else
        	 fext = ""
              print(skytmp[j]//fext,>>inskyli)  
            }
	    
	    
          lmksky(  input = "@"//inskyli,
	          outsky = skyrun1,
		masktype = "none",
		   scale = liskycpars.scale,
	            zero = liskycpars.zero,
	          reject = liskycpars.reject,    
                    nlow = liskycpars.nlow, 
	           nhigh = liskycpars.nhigh,
	         statsec = liskycpars.statsec)
	  
	  ## check if maskobj is requested
	  if (maskobj)
	  {
	      if (verb1) print "creating mask from sky images..." 
	      # subtract sky image to the list of sky images
	      list3 = inskyli
	      while (fscan(list3,onesky) != EOF)
	      {
		lcheckfile(onesky)
		if (lcheckfile.nimages > 0) 
        	   fext = "[1]"
		else
        	   fext = ""
		skyaux1 = mktemp(tmpdir//"_lnslfskyaux")
		#print ("subtracting: ",onesky," - ",skyrun1," = ",skyaux1)
		lsubscalesky(onesky,skyaux1,skyrun1,scale=liskycpars.scale,
        	  zero=liskycpars.zero,verbose=verb1) 
		# create object mask based on the subtracted images
                objmask = mktemp(tmpdir//"_lnslfomsk")
		if (verb1) print ("creating mask file ",objmask)	 	 
		 #lstatis(skyaux1,nsigrej=5.,maxiter=5,addheader=no,
		  #  lower=INDEF,upper=INDEF,oneparam="all",verbose=no,print=no)
		 imstatistic(skyaux1,fields="stddev",lower=INDEF,upper=INDEF,binw=0.001,
		   format=no) |  scan(skyrms) 
		 objmasks(skyaux1,objmask//".pl",omtype="numbers",skys=0.,
	            sigmas=skyrms,masks="",blkstep=3,blksize=-10,
		    convolve="block 3 3",hsigma=7,hdetect=yes,ldetect=no,
		    neighbors="8",minpix=20,ngrow=2,agrow=2,>>&"/dev/null")	 
        	 #lstarmask(sky_aux,objmask,nsky=0,nobject=1,addheader="none",
		  #filtsize=0,nsmooth=-5,threshtype="nsigma",nsigthresh=3,
		  #checklimits=no,zmin=-10000,zmax=35000,verbose=verbose)
		hedit(onesky,"BPM",objmask,add=yes,verify=no,update=yes,show=no)
		imdel(skyaux1,verify=no, >>&"/dev/null")    
	      }

              imdel (skyrun1,veri-, >>&"/dev/null")

	      lmksky(input = "@"//osfn(inskyli),
                    outsky = skyrun1, 
        	  masktype = "goodvalue",
        	   maskval = 0.,
	             scale = liskycpars.scale,
	              zero = liskycpars.zero,
	            reject = liskycpars.reject,    
                      nlow = liskycpars.nlow, 
	             nhigh = liskycpars.nhigh,
		   statsec = liskycpars.statsec)

	      imdel(tmpdir//"_lnslfomsk*",verify=no, >>&"/dev/null")       	    	     
	     
	  }  
	  	  
	  delete(inskyli,yes,ver-)
	  # check if image has extensions
	  lcheckfile(inrunli[i])
	  if (lcheckfile.nimages > 0) 
             fext = "[1]"
	  else
             fext = ""
	  if (verb1) print(" subtracting sky frame to  ",inrunli[i]) 
	  imskysb = mktemp("_lnskyimsb")      
	  imarith(inrunli[i]//fext,"-",skyrun1,imskysb)
	  		  
	  imrename(imskysb,ino//inrunli[i])

       }
       
       igrp += 1 
    }


  ############################################################################
  #  Delete temporary files
  #---------------------------------------------------------------------------
  
  delete (inli,yes,ver-)
  
  #delete ("@"//inlili,yes,ver-)
  #delete (inlili,yes,ver-)
  
  delete ("@"//outlili,yes,ver-)
  delete (outlili,yes,ver-)
    
  list1 = ""
  list2 = ""
  list3 = ""

end 
