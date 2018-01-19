# lconstlist - generate image lists of the same observation
# Author : Miguel Charcos (mcharcos@ll.iac.es)
# Version: 30. Jul. 2003
##############################################################################
procedure lconstlist (input,output)

string	input	{prompt="List of images for checking"}
string	output	{prompt="Name for image lists"}
string 	fcheck	{"",prompt="File containing information about lists of images"}
string  tmpdir	{")_.tmpdir",prompt="Temporary directory for file conversion"}
bool	verbose	{no,prompt="Verbose"}

string *list1	{prompt="Ignore this parameter(list1)"}


begin

  string	in, out, chf, tmpl, listfile, sublistfile
  string 	imname,imref,timest
  string	impathref,impath,imroot,imrefroot
  string	aqtype,title
  int 		hours,minuts,seconds
  int 		exptime,inittime,starttime,expreftime,numim,numimref
  int 		contlist,contsublist,contim,nsc,totimsub
  int 		dith,dithmax,serial,serialmax,nummult,nummultmax,spectraux
  bool		checkres,listend,firstaquire



  in = input
  out = output 

  #------------------------------------------------------------------------------
  # Verifying entry data
  #------------------------------------------------------------------------------
  if (verbose) 
    {
    print ""
    print "Verification of entries"
    }
    
  # check if check file exists
  if (fcheck == "")
    {
    if (verbose) {print "INFO: No check of list generation"}
    checkres = no
    }
  else
    {
    checkres = yes
    chf = fcheck
    if ( access(chf))
      {
      beep
      print("")
      print("ERROR: operation would override output check file "//chf)
      print("lconstlist aborted")
      print("")
      beep
      bye
      }
    }
  
  delete(tmpdir//"lconstlisttmp*",yes,verify=no, >>& "/dev/null")
  delete(out//"*",yes,verify=no, >>& "/dev/null")
  
  # check if image directory exists
  tmpl = mktemp (tmpdir//"lconstlisttmp")
  files(in,>tmpl)
  
  list1 = tmpl
  if (fscan(list1,imname) == EOF)
    {
    beep
    print("")
    print("ERROR: no image in the list")
    print("lconstlist aborted")
    print("")
    beep
    bye
    }	
  
  if (verbose)
    {
    print "Entry data verified"
    print ""
    }
    
  #------------------------------------------------------------------------------
  # End of verification of entry data
  #------------------------------------------------------------------------------
  
  
  #------------------------------------------------------------------------------
  # Generate files containing list of images of the same observation
  # of the tmpl list created before
  #------------------------------------------------------------------------------
  if (verbose)
    {
    print ""
    print "generating lists"
    }
    
  contlist = 0
  list1 = tmpl
  While (fscan(list1,imname) != EOF)
    {
    # firstaquire control if we have finished the list right
    # if the list is not complet we consider the last readen image
    # ie. firstaquire = yes and we do not aquire other image
    firstaquire = yes
    While (firstaquire)
      {
      # The image in this step is the reference image of all 
      # the list (list = sublist1 + sublist2 + ...)
      contsublist = 1
      firstaquire = no
      
      # Check type of image: dither, spectr or none
      limnumber(imname, verbose=verbose)
      if (limnumber.sequence)
        {aqtype = limnumber.type}
      else 
        {
	firstaquire=no
	listend=no
	aqtype = "problem header"
	}	
      
      ########
      #  No image type recognised
      ########
      if (aqtype == "none")
        {
        if (verbose) {print ("INFO: image ",imname," do not belong to any list")}
        listend = no
        }
      ########
      #  Problem in reference image header
      ########
      else if (aqtype == "problem header")
        {
	if (verbose) 
	  {print "WARNING: header "//imname//" reference image header wrong"}
	listend = no
	}
      ########
      #  If image type recognised: dither or spectr
      #  
      #  -------------------  ----------------------  ----------------------
      #  -  List with      -  -  sub lists with    -  -  different         -
      #  -  all completed  -  -  all completed	   -  -  exposures         -
      #  -  serial sublist -  -  dith/spectr 	   -  -  no list created   -
      #  -  (1 list with   -  -  (total: 	   -  ----------------------
      #  -  contsublist    -  -  2*nummultmax or   -  
      #  -  sublist)	   -  -  dithmax*nummultmax-  
      #  -------------------  ----------------------  
      #
      #   *** serial1   
      #   *                   *** dith1/spectrA       *** nummult1
      #   *** serial2 ------- *                       *
      #   *                   *** dith2/spectrB ----- *** nummult2
      #   ...                 ..                      ..
      #   *                   *** dithmax             *** nummultmax
      #   *** serialmax
      #
      ########
      if ((limnumber.imnum == 1 && limnumber.snum == 1) \
               && (limnumber.dedither == 1 || limnumber.spectr != 0))
        {
	######
        # if the reference image correspond to the first image
	# we start build list process:
	#      -  read number of images and its type 
	#         considering reference image
	#      -  create list file name but it will not be completed 
	#         until one sublist will be created correctly
	#      -  create sublist name and add reference image
	#      -  aquire control parameters: RUN, exptime and starttime
	#      -  start dither or spectr process (or anyprocess) in which
	#         all sublist and the list of complete serial will be 
	#         created
	#      -  if only one sub list is created it is erased because
	#         sublist1 = list
	#      -  if checkfile we add correspond information
	#
	######
	
	
	#---------------------------------------------
	# read number of images and its type
	#---------------------------------------------
        nummultmax = limnumber.imaxnum
        #serialmax = limnumber.smaxnum
        listend = no
 
	# contlist is the number of list that was created
	# when a list is being created we consider this list in contlist
        contlist = contlist + 1
        listfile = out//"_"//contlist
        if (verbose) {print ("Generating new list file: ",listfile)}
	
	
	#------------------------------------------------------
	# create list and sub list file names and add imref
	#------------------------------------------------------
	# contsublist is the number of the sublist considered in the moment
	# it will be use to know if the actual sublist is the first in
	# in the serial (list will be erased because it does not contain images)
	# or the second (the only sublist will be erased because it wil be equal
	# to the list
	sublistfile = out//"_"//contlist//"sub"//contsublist
	if (verbose) print ("Generating new sub list file: ",sublistfile)
	
	lhgets(image=imname,param="i_title")
	if (lhgets.value != "0")
	  {title = lhgets.value}
	else {title = "no title avalaible"}  
	lfilename(imname)
	imref = imname  
	imrefroot = lfilename.root
      if (lfilename.extension != "")  
	  {imrefroot = imrefroot//"."//lfilename.extension}
	impathref = lfilename.path
        print (imrefroot, >> sublistfile)
	
	if (verbose)
	  {
          print (imrefroot," is reference image of ",listfile," list file")
          print (imrefroot," is reference image of ",sublistfile," sub list file")
	  }
        contim = 1

        if (verbose)
	  {print ("List should be contain ",nummultmax," number of multirun images")}
         
        #---------------------------------
	# save control parameters
	#---------------------------------
        lhgets(image=imname,param="UTSTART")
        if (lhgets.value == "0") {timest=""}
        else {timest = lhgets.value}
 
        if (fscanf(timest,"%d:%d:%d",hours,minuts,seconds) != EOF)
          {
          starttime = int(seconds)+int(minuts)*60+int(hours)*3600
          }
        else
          {
          starttime = 0
          }
	  
	lhgets(image=imname,param="EXPTIME")
        if (lhgets.value == "0") 
	  {
	  if (verbose) {print "WARNING: EXPTIME parameter of "//imname//" empty"}
	  expreftime=0
	  }
        else {expreftime = int(lhgets.value)}
 
        numimref = limnumber.imrun
 
 
	##############################
	#
	#  Start dither or spectr process
	#
	#  Until listend=no we continue list build process. 
	#  listend indicate when true that list build process have
	#  been some problems and the serial construction was interrupted
	#  before finish add every images of the serial
	#
	#  listend=yes when:
	#		  - serial, dither or exposure does not correspond
	#		  - run number image does not correspond
	#		  - we can not read new image in the list
	#
	#  when start time do not correspond only warning message is print
	#
	#  contsublist=1 and conlist=number of actual list build process
	#
	##############################

	#--------------------------------------------------------------------------
        # The group corresponding to the first image is a dedither aquisition type
        #--------------------------------------------------------------------------
	if (aqtype == "dither")
          {
          nummult = 2
          serial = 1
          dithmax = limnumber.maxdith
          dith = 1
	  totimsub = nummultmax * dithmax
	  
          While (!listend)
            {
            While (dith <= dithmax && !listend)
              {
              While (nummult <= nummultmax && !listend)
        	{
        	if (fscan(list1,imname) != EOF)
        	  {
		  #-------------------------------
		  # We acquire image information
		  #-------------------------------
        	  limnumber(imname, verbose=verbose)
		  if (!limnumber.sequence)
		    {
		    if (verbose)
		      {print "WARNING: header "//imname//" reference image header wrong"}
		    listend = yes
		    firstaquire = no
		    }
 
        	  lhgets(image=imname,param="UTSTART")
        	  if (lhgets.value == "0") 
		    {
	            if (verbose) 
		      {print "WARNING: UTSTART parameter of "//imname//" empty"}
		    timest=""
		    }
        	  else {timest = lhgets.value}
 
        	  lhgets(image=imname,param="EXPTIME")
        	  if (lhgets.value == "0") 
		    {
	            if (verbose) 
		      {print "WARNING: EXPTIME parameter of "//imname//" empty"}
		    exptime=0
		    }
        	  else {exptime = int(lhgets.value)}
 
		  numim = limnumber.imrun
 
        	  #---------------------------------
		  # We erase path of image name that will 
		  # be introduced in list
		  #---------------------------------
		  lfilename(imname)
                  imroot = lfilename.root
		  if (lfilename.extension != "")
		    {imroot=imroot//"."//lfilename.extension}
	          impath = lfilename.path
		  if (impath != impathref)
		    {
		    if (verbose)
		      {print "WARNING: Path of images does not correspond"}
		    }
		  
		  
		  #----------------------------------------------------
		  # We compare read and theorical values
        	  # if values are correct we add image in the present list
        	  #----------------------------------------------------
		  if (nummult == limnumber.imnum \
        	      && dith == limnumber.dedither \
        	      && serial == limnumber.snum \
        	      && numim == numimref + contim)
        	    {
        	    if (fscanf(timest,"%d:%d:%d",hours,minuts,seconds) != EOF && starttime != 0)
        	      {
        	      inittime = int(seconds)+int(minuts)*60+int(hours)*3600
 
        	      # if observation times are not correctly we do not increase contim and
        	      # numim != numimref + contim-1 in the next "if" condition
        	      if (inittime <= starttime + contim * (expreftime+60))
        		{
        		if (verbose)
		          {print ("INFO: Time verified for ",imroot," image")}
        		}
        	      }
        	    else
        	      {
        	      inittime = 0
		      if (verbose)
		        {print ("WARNING: Time do not verified for ",imroot," image")}
        	      }
        	    if (verbose) {print ("adding ", imroot,"...")}
		    print (imroot, >> sublistfile)
        	    contim = contim + 1
		    } # end of if (nummult == limnumber.imnum ....)
        	  # if values are not correct we finish actual list build process 
		  # we would have the first image of next list and we continue
		  # in the While (firstaquire)
		  else
        	    {
        	    listend = yes
		    firstaquire = yes
        	    }
        	  } # end of if (fscan(list1,imname) != EOF)
        	# there are not others images i the list
		# we finish actual process (listend=yes)
		# we do not consider image for new list (firstaquire=no)
		else # if (fscan(list1,imname) == EOF)
		  {
		  listend = yes
		  firstaquire = no
		  } # end of else [if (fscan(list1,imname) != EOF)]
        	nummult = nummult + 1
        	} # end of While (nummult <= nummultmax && !listend)
              nummult = 1
              dith = dith + 1
              } # end of While (dith <= dithmax && !listend)
            
	    #--------------------------------------------------------
	    # When finished serial we verify how was finished
	    #--------------------------------------------------------
	    # if we have saved every images of the group (listend = no) 
	    # we do not delete subfile and we add images of subfile to the file
	    if (!listend)
	      {
	      # We add image of sublist to the list
	      files("@"//sublistfile,,>>listfile)
	      # we create new sublist name
	      contsublist = contsublist + 1
	      sublistfile = out//"_"//contlist//"sub"//contsublist
	      } # end of if (!listend)
	    # if the group is not completed we erase this subfile and we do not
	    # add images to the file
	    else  # if (listend)
	      {
	      # we delete the sublist that was not finished
	      delete (sublistfile,yes,verify=no, >>& "/dev/null")
	      if (contsublist == 1)
	        {
		if (verbose)
		  {
		  print ("No sublist completed in ",listfile," list")
		  print ("List ",listfile," deleted")
		  }
		contlist = contlist - 1
		contsublist = 1
		}
	      else if (contsublist == 2)
	        {
		delete(out//"_"//contlist//"sub1",yes,verify=no, >>& "/dev/null")
		contsublist = 1
          	if (checkres)
          	  {
          	  print ("",>>chf)
          	  print ("List ",listfile," no contain sublist. Total images: ",totimsub,>>chf)
	          print ("Path of images: ",impathref,>>chf)
		  print ("Reference image: ",imrefroot," -",title,"-",>>chf)
          	  print ("Aquisition type: ",aqtype,>>chf)
          	  print ("",>>chf)
          	  }
		}
	      else
	        {
		if (verbose)
	          {print ("List ",listfile," have ",contsublist," sublists")}
		}
	      }
	    dith = 1
            serial = serial + 1
            } # end of While (!listend)
          } # end of if (aqtype == "dither")
	
	
	#--------------------------------------------------------------------------
        # The group corresponding to the first image is a spectral aquisition type
        #--------------------------------------------------------------------------  
 	else if (aqtype == "spectr")
 	  {
 	  nummult = 2
 	  serial = 1
	  spectraux = limnumber.spectr
	  
	  totimsub = 2 * nummultmax

	  While (!listend)
 	    {
 	    While (nummult <= nummultmax && !listend)
 	      {
 	      if (fscan(list1,imname) != EOF)
 	        {
		#-------------------------------
		# We acquire image information
		#-------------------------------
	        limnumber(imname, verbose=verbose)
                if (!limnumber.sequence)
		  {
		  if (verbose)
		    {print "WARNING: header "//imname//" reference image header wrong"}
		  listend = yes
		  firstaquire = no
		  }
                lhgets(image=imname,param="UTSTART")
                if (lhgets.value == "0") 
		  {
	          if (verbose) 
		    {print "WARNING: UTSTART parameter of "//imname//" empty"}
		  timest=""
		  }
                else {timest = lhgets.value}
 
                lhgets(image=imname,param="EXPTIME")
                if (lhgets.value == "0") 
		  {
	          if (verbose) 
		    {print "WARNING: EXPTIME parameter of "//imname//" empty"}
		  exptime=0
		  }
                else {exptime = int(lhgets.value)}
 
	    	numim = limnumber.imrun
		
		#---------------------------------
		# We erase path of image name that will 
		# be introduced in list
		#---------------------------------
		lfilename(imname)
            imroot = lfilename.root
		if (lfilename.extension != "")
		  {imroot = imroot//"."//lfilename.extension}
	        impath = lfilename.path
		if (impath != impathref)
		  {
		  if (verbose)
		    {print "WARNING: Path of images does not correspond"}
		  }
		
		#----------------------------------------------------
		# We compare read and theorical values
        	# if values are correct we add image in the present list
        	#----------------------------------------------------
		if (nummult == limnumber.imnum \
            	   && spectraux == limnumber.spectr \
            	   && serial == limnumber.snum \
            	   && numim == numimref + contim)
            	  {
            	  if (fscanf(timest,"%d:%d:%d",hours,minuts,seconds) != EOF && starttime != 0)
            	    {
            	    inittime = int(seconds)+int(minuts)*60+int(hours)*3600
 
            	    # if observation times are not correctly we do not increase contim and
            	    # numim != numimref + contim-1 in the next "if" condition
            	    if (inittime <= starttime + contim * (expreftime+60))
            	      {
            	      if (verbose) {print ("INFO: Time verified for ",imroot," image")}
            	      }
	    	    else
            	      {
            	      inittime = 0
		      if (verbose)
            	        {print ("WARNING: Time do not verified for ",imroot," image")}
            	      }
		    }
	    	    
            	  if (verbose) {print ("adding ", imroot,"...")}
            	  print (imroot, >> sublistfile)
            	  contim = contim + 1
		  }
            	else
            	  {
            	  listend = yes
	    	  firstaquire = yes
            	  }
 	        } # end of if (fscan(list1,imname) != EOF)
              else
	        {
	        listend = yes
	        firstaquire = no
	        }
	      nummult = nummult + 1
 	      } # end of while (nummult <= nummultmax)
	    
	    nummult = 1
	    if (spectraux == 1) {spectraux = 2}
	    else {spectraux = 1}

            While (nummult <= nummultmax && !listend)
 	      {
 	      if (fscan(list1,imname) != EOF)
 	        {
		#-------------------------------
		# We acquire image information
		#-------------------------------
	        limnumber(imname, verbose=verbose)
                if (!limnumber.sequence)
		    {
		    if (verbose)
		      {print "WARNING: header "//imname//" reference image header wrong"}
		    listend = yes
		    firstaquire = no
		    }
                
		lhgets(image=imname,param="UTSTART")
                if (lhgets.value == "0") 
		  {
	          if (verbose) 
		    {print "WARNING: UTSTART parameter of "//imname//" empty"}
		  timest=""
		  }
                else {timest = lhgets.value}
 
                lhgets(image=imname,param="EXPTIME")
                if (lhgets.value == "0") 
		  {
	          if (verbose) 
		    {print "WARNING: EXPTIME parameter of "//imname//" empty"}
		  exptime=0
		  }
                else {exptime = int(lhgets.value)}
 
                lhgets(image=imname,param="RUN")
                if (lhgets.value == "0") 
		  {
	          if (verbose) 
		    {print "WARNING: RUN parameter of "//imname//" empty"}
		  numim=0
		  }
                else {numim = int(lhgets.value)}
	    	
		#---------------------------------
		# We erase path of image name that will 
		# be introduced in list
		#---------------------------------
		lfilename(imname)
            imroot = lfilename.root
		if (lfilename.extension != "")
		  {imroot = imroot//"."//lfilename.extension}
	        impath = lfilename.path
		if (impath != impathref)
		  {
		  if (verbose)
		    {print "WARNING: Path of images does not correspond"}
		  }
		
		#----------------------------------------------------
		# We compare read and theorical values
        	# if values are correct we add image in the present list
        	#----------------------------------------------------
            	if (nummult == limnumber.imnum \
            	   && spectraux == limnumber.spectr \
            	   && serial == limnumber.snum \
            	   && numim == numimref + contim)
            	  {
            	  if (fscanf(timest,"%d:%d:%d",hours,minuts,seconds) != EOF && starttime != 0)
            	    {
            	    inittime = int(seconds)+int(minuts)*60+int(hours)*3600
 
            	    # if observation times are not correctly we do not increase contim and
            	    # numim != numimref + contim-1 in the next "if" condition
            	    if (inittime <= starttime + contim * (expreftime+60))
            	      {
            	      if (verbose) {print ("INFO: Time verified for ",imroot," image")}
            	      }
	    	    else
            	      {
            	      inittime = 0
		      if (verbose)
            	        {print ("WARNING: Time do not verified for ",imroot," image")}
            	      }
		    }
            	  if (verbose) {print ("adding ", imroot,"...")}
            	  print (imroot, >> sublistfile)
            	  contim = contim + 1
	    	  }
            	else
            	  {
            	  listend = yes
	    	  firstaquire = yes
            	  }
 	        } # end of if (fscan(list1,imname) != EOF)
              else
	        {
	        listend = yes
	        firstaquire = no
	        }
	      
	      nummult = nummult + 1
 	      } # end of while (nummult <= nummultmax)
 	    nummult = 1
	    
	    
	    # if we have saved every images of the group (listend = no) 
	    # we do not delete subfile and we add images of subfile to the file
	    if (!listend)
	      {
	      files("@"//sublistfile,,>>listfile)
	      contsublist = contsublist + 1
	      sublistfile = out//"_"//contlist//"sub"//contsublist
	      }
	    # if the group is not completed we erase this subfile and we do not
	    # add images to the file
	    else
	      {
	      delete (sublistfile,yes,verify=no, >>& "/dev/null")
	      if (contsublist == 1)
	 	{
		if (verbose)
		  {
	 	  print ("No sublist completed in ",listfile," list")
	 	  print ("List ",listfile," deleted")
		  }
	 	contlist = contlist - 1
	 	contsublist = 1
	 	}
	      else if (contsublist == 2)
	        {
		delete(out//"_"//contlist//"sub1",yes,verify=no, >>& "/dev/null")
		contsublist = 1
          	if (checkres)
          	  {
          	  print ("",>>chf)
          	  print ("List ",listfile," no contain sublist. Total images: ",totimsub,>>chf)
	          print ("Path of images: ",impathref,>>chf)
		  print ("Reference image: ",imrefroot," -",title,"-",>>chf)
          	  print ("Aquisition type: ",aqtype,>>chf)
          	  print ("",>>chf)
          	  }
		}
	      else
	 	{
	 	if (verbose)
		  {print ("List ",listfile," have ",(contsublist-1)," sublists")}
	 	}
	      }
 	    serial = serial + 1
 	    } # end of while (!listend)
	    
 	  } # end of if (aqtype == "spectr")
        
	else # if the type of aquisition is not "spectr" or dither" 
	  {
	  if (verbose) {print ("WARNING:Problem with ",imrefroot," image aquisition type")}
	  delete (listfile,yes,verify=no, >>& "/dev/null")
	  if (verbose) 
	    {print ("List ",contlist,"asigned to the ",imrefroot," reference image deleted")}
	  contlist = contlist - 1
	  }
	} # end of if ((limnumber.imnum == 1 && limnumber.snum == 1) ...)
      else
        {
	# if the first image does not correspond to a first image
	# we do not start build list process 
        if (verbose) {print ("WARNING: ",imname," image type is not recognised")}
        }
      
      ########################
      #
      #  At this step: 
      #         
      #          -  every correct list was created and wrong list erased
      #          -  every correct sublists was created and wrong sublists erased
      #          -  contsublist = number of sublist completed + 1 
      #          -  contlist = number of list completed correctly
      #          -  listend = yes if process was interrupted because an image
      #             do not verify condition of serial
      #          -  firstaquire = yes if process was interrupted because an
      #		    image do not verify condition of serial but have header 
      #		    parameters (this image will be taken in consideration as 
      #		    reference image of next list
      #
      ########################
      
      #---------------------
      # we write check file 
      #---------------------
      if (checkres)
        {
	if (contsublist == 2)
          {
	  print ("",>>chf)
	  print ("List ",listfile," no contain sublist. Total images: ",totimsub,>>chf)
	  print ("Path of images: ",impathref,>>chf)
	  print ("Reference image: ",imrefroot," -",title,"-",>>chf)
	  print ("Aquisition type: ",aqtype,>>chf)
	  print ("",>>chf)
	  }
	
        else if (contsublist > 2)
	  {
	  print ("",>>chf)
	  print ("List ",listfile," contain ",(contsublist-1)," sublist with ",totimsub," images",>>chf)
	  print ("Path of images: ",impathref,>>chf)
	  print ("Reference image: ",imrefroot," -",title,"-",>>chf)
	  print ("Aquisition type: ",aqtype,>>chf)
	  print ("",>>chf)
	  }
	} #end of if (checkres)
      
      if (!listend && contsublist == 2) 
	{delete (out//"_"//contlist//"sub1",yes,verify=no, >>& "/dev/null")}
	
      } # end while(firstaquire)
    } # end of while (fscan(list1,imname) != EOF)
 
  if (verbose)
    {
    print (contlist,"lists generated")
    print ""
    }
  #------------------------------------------------------------------------------
  # End of files of images list
  #------------------------------------------------------------------------------

  delete(tmpdir//"lconstlisttmp*",yes,verify=no, >>& "/dev/null")
  
  
end
