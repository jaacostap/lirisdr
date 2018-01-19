procedure lpmksflat (iflatbr, iflatdk, nflat)

string	iflatbr		{prompt="File list of bright flat field images"}
string	iflatdk		{prompt="File list of dark flat field images"}
string	nflat		{"Nflat",prompt="Name of normalize flat"}
string  ftrimsec	{")_.ftrimsec",prompt="File containing trim sections"}
string  flatdk		{"Flatdk",prompt="Name of dark flat"}
string  flatbr 		{"Flatbr",prompt="Name of bright flat"}
string  combine		{"median",prompt="Type of combine operation"}
string	scale		{"median",prompt="Image scaling"}
string	reject		{"ccdclip",enum="none|minmax|ccdclip",prompt="Type of rejection"}
string	gain		{"5.5",prompt="ccdclip: gain (electrons/ADU)"}
string  rdnoise		{"13",prompt="ccdclip: readout noise (electrons)"}
string  dbdir		{")_.stddir",prompt="Database directory"}
bool	corrow		{no,prompt="Correct bad pixel mapping?"}
string  outrow		{"",prompt="prefix of image with pixel mapping corrected"}

bool    verbose 	{yes,prompt="Verbose"}

# Directories
string  tmpdir  {")_.tmpdir",prompt="Temporary directory for file conversion"}

string *list1   {"",prompt="Ignore this parameter"}
string *list2   {"",prompt="Ignore this parameter"}

begin

string	inlibr,inlidk,corrowlibr,corrowlidk,prepostlibr,prepostlidk
string  fllst,fllsttmp,isfltdk,flat1,nflat1
string 	flattmp,nflattmp,ofltdk,ofltdktmp,ofltbr,ofltbrtmp,ofltiflt
string  ftrim1,ofltpc, ofltsec, iflt, trlist, imosec
bool 	origcpixprepost
real	md
int 	isec
  
  # check if the file containing the trim sections exists
  ftrim1 = dbdir//ftrimsec 
  
  # expand input image names.
  inlibr = mktemp(tmpdir//"_lmkfltinbr")
  sections(iflatbr,option="fullname",> inlibr)
  
  isfltdk = iflatdk
  if (isfltdk != "") 
    {
      inlidk = mktemp(tmpdir//"_lmkfltindk")
      sections(isfltdk,option="fullname",> inlidk)
    }

  ##########################################################
  # Correction of pixel mapping problem
  #---------------------------------------------------------
  if (corrow)
    {

    if (verbose)
      {
      print ""
      print "correcting bad rows and lines..."
      } 
      
    corrowlibr = mktemp(tmpdir//"_lmkfltcrowlibr")
    corrowlidk = mktemp(tmpdir//"_lmkfltcrowlibr")
    if (outrow == "")
      {
      lcpixmap (input = "@"//inlibr,     
               output = "lmkfcrow_", 
              outlist = corrowlibr,   
              verbose = verbose,
	       tmpdir = tmpdir)
      if (isfltdk != "")
        { 
          lcpixmap (input = "@"//inlidk,     
                   output = "lmkfcrow_", 
                  outlist = corrowlidk,   
                  verbose = verbose,
	           tmpdir = tmpdir)	
	}              
      }
    else
      {
      lcpixmap (input = "@"//inlibr,     
               output = outrow, 
              outlist = corrowlibr,   
              verbose = verbose,
	       tmpdir = tmpdir)
      if (isfltdk != "")
        { 
          lcpixmap (input = "@"//inlidk,     
                   output = outrow, 
                  outlist = corrowlidk,   
                  verbose = verbose,
	           tmpdir = tmpdir)	
	}              
	       
      }
      
    origcpixprepost = lcpixmap.original

    }    
  else 
    {
    if (verbose)
      {
      print ""
      print "INFO: No need to correct wrong pixel mapping"
      print ""
      }
    corrowlibr = inlibr
    if (isfltdk != "")  corrowlidk = inlidk
    origcpixprepost = yes
    }
  
  #---------------------------------------------------------
  # End of bad row correction
  ##########################################################
    
  # --------------------------------------------------------------------
  #  Verify image format and perfom pre-post treatment if necesary
  #  Image result can be unique format
  # --------------------------------------------------------------------
  # Check if they are already pre read subtracted images containing a wcs
  if (verbose)
    {
    print ""
    print "verification of image format"
    }
  
   prepostlibr = mktemp(tmpdir//"_lmkfppli")
   prepostlidk = mktemp(tmpdir//"_lmkfppli")
  
   llistdiff (input = "@"//corrowlibr,         
              output = prepostlibr,             
               pname = mktemp("lmkf")//"_",     
             verbose = verbose,
              tmpdir = tmpdir)
	      
   if (isfltdk != "") 
      llistdiff (input = "@"//corrowlidk,         
                output = prepostlidk,             
                 pname = mktemp("lmkf")//"_",     
               verbose = verbose,
                tmpdir = tmpdir)	      

 
  if (verbose)
    {
    print "image format verified"
    print ""
    }
  

# create an intermediate flat, not normalized
  flattmp = mktemp(tmpdir//"_flattmp")
  nflat1 = nflat
  if (nflat1 != "") 
    nflattmp = nflat1
  else
    nflattmp = mktemp(tmpdir//"_lmkfltntmp")
  

# combine bright flats
  if (flatbr != "")
    ofltbr = flatbr  
  else 
    ofltbr = mktemp(tmpdir//"_lmkofltbr")

#  
  list1 = prepostlibr
  
  fllst = mktemp(tmpdir//"_fllst")
  
  while (fscan(list1,iflt) != EOF)
    {
        # cut the image into pieces
	print "Slicing images"
        ofltpc= mktemp(tmpdir//"_ofltpc")
        trlist = mktemp("_trlist")
	print ("iflt ",iflt)
	print ("ofltpc ",ofltpc)
	print ("ftrim1 ",ftrim1)
	print ("trlist ",trlist)
	ltrimspol(iflt,ofltpc,ftrim1,outlist=trlist)
	# copy into four different lists corresponding to each piece
	list2 = trlist
	while (fscan(list2,imosec) != EOF)
          {
	     imgets(imosec,"LPOLVECT")
	     isec = int(imgets.value)
             switch (isec) {
	     case 0: 
		print(imosec,>>fllst//"_0")
	     case 90: 
		print(imosec,>>fllst//"_90")
	     case 135: 
		print(imosec,>>fllst//"_135")
	     case 45: 
		print(imosec,>>fllst//"_45")
	     default :
		{
		  print("Error: wrong number of image sections")
		  bye
		}     
             }
          }
    }
    
  print "Combining flat-field images"  

  ## now combine bright flats  piece by piece  
  for (isec=1; isec<=4; isec= isec+1)
    {
       switch (isec) {
       case 1:
          { 
	    ofltsec = "_0"
	  }  
       case 2: 
          { 
	    ofltsec = "_90"
	  }  
       case 3: 
          { 
	    ofltsec = "_135"
	  }  
       case 4: 
          { 
	    ofltsec = "_45"
	  }  
       }
       imcombine ("@"//fllst//ofltsec,ofltbr//ofltsec,headers="",bpmasks="",rejmasks="",
          nrejmasks="",expmasks="",sigmas="",combine=combine,reject=reject,
          project=no,offsets="",masktype="none",scale=scale,zero="none",
	  statsec="")
    }	
    

# combine dark flats
    
  if (isfltdk != "") 
    {
       if (flatdk != "")
          ofltdk = flatdk  
       else 
          ofltdk = mktemp(tmpdir//"_lmkofltbr")

       list1 = prepostlidk
     
       fllst = mktemp(tmpdir//"_fllst")
  
       while (fscan(list1,iflt) != EOF)
	 {
             # cut the image into pieces
             ofltpc= mktemp(tmpdir//"_ofltpc")
	     trlist= mktemp(tmpdir//"_trlist")
	     ltrimspol(iflt,ofltpc,ftrim1,outlist=trlist)
	     # copy into four different lists corresponding to each piece
	     list2 = trlist
	     while (fscan(list2,imosec) != EOF)
               {
	          imgets(imosec,"LPOLVECT")
	          isec = int(imgets.value)
        	  switch (isec) {
		  case 0: 
		     print(imosec,>>fllst//"_0")
		  case 90: 
		     print(imosec,>>fllst//"_90")
		  case 135: 
		     print(imosec,>>fllst//"_135")
		  case 45: 
		     print(imosec,>>fllst//"_45")
		  default :
		     {
		       print("Error: wrong number of image sections")
		       bye
		     }     
        	  }
               }
	 }

       ## now combine dark flats  piece by piece  
       for (isec=1; isec<=4; isec= isec+1)
	 {
	   switch (isec) {
	   case 1:
              { 
		ofltsec = "_0"
	      }  
	   case 2: 
              { 
		ofltsec = "_90"
	      }  
	   case 3: 
              { 
		ofltsec = "_135"
	      }  
	   case 4: 
              { 
		ofltsec = "_45"
	      }  
	   }
	    imcombine ("@"//fllst//ofltsec,ofltdk//ofltsec,headers="",bpmasks="",rejmasks="",
               nrejmasks="",expmasks="",sigmas="",combine=combine,reject=reject,
               project=no,offsets="",masktype="none",scale=scale,zero="none",
	       statsec="")
	       
	    imarith (ofltbr//ofltsec,"-",ofltdk//ofltsec,flattmp//ofltsec)   
         }

    }
   else
    {
       for (isec=1; isec<=4; isec= isec+1) 
         {
	   switch (isec) {
	   case 1:
              { 
		ofltsec = "_0"
	      }  
	   case 2: 
              { 
		ofltsec = "_90"
	      }  
	   case 3: 
              { 
		ofltsec = "_135"
	      }  
	   case 4: 
              { 
		ofltsec = "_45"
	      }  
	   }
           imcopy (ofltbr//ofltsec,flattmp//ofltsec,ver+)
	 } 
    }  
      

   for (isec=1; isec<=4; isec= isec+1)
     {
	switch (isec) {
	case 1:
           { 
	     ofltsec = "_0"
	   }  
	case 2: 
           { 
	     ofltsec = "_90"
	   }  
	case 3: 
           { 
	     ofltsec = "_135"
	   }  
	case 4: 
           { 
	     ofltsec = "_45"
	   }  
	}
	response(flattmp//ofltsec,flattmp//ofltsec,nflattmp//ofltsec)
     }	

   
   ## clean up 
   imdel("_ofltpc*",veri-)
   imdel("_lmkfltntmp*",veri-)
   imdel("_flattmp*",veri-)
   delete("_lmk*",veri-)
   delete("_fllst*",veri-)
   delete("_trlist*",veri-)
   delete("_lmkfpp*",veri-) 
    

end
