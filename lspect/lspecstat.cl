# lspecstat - show spectra statistics and return list with selected spectras
# Author : Miguel Charcos (mcharcos@ll.iac.es)
# Version: 30. Jan. 2004
##############################################################################
procedure lspecstat(input,output)

string	input		{prompt="List of spectres to plot"}
string	output		{prompt="List of spectres selected"}

string	indepf1		{"",prompt="File related with input spectres with 1 parametre"}
string	indepf2		{"",prompt="File related with input spectres with 2 parametre"}
string	outdepf1	{"",prompt="Output file related with indepf1"}
string	outdepf2	{"",prompt="Output file related with indepf2"}

bool	delnosel	{no,prompt="Delete no selected spectral images"}

# Work directories
string  tmpdir  	{")_.tmpdir",prompt="Temporary directory for file conversion"}

# plot parametres
pset 	statplot	{prompt="Plot configuration parametres"}

string	statinterv	{"[*]",prompt="Statistic interval"}
int	imnum		{prompt="Return number of output spectres"}
bool	verbose		{no,prompt="Verbose?"}

string *list1	{prompt="Ignore this parameter(list1)"}
string *list2	{prompt="Ignore this parameter(list2)"}
string *list3	{prompt="Ignore this parameter(list3)"}
string *list4	{prompt="Ignore this parameter(list4)"}


begin

  string	inli,outli,redli,inputli
  string	imref,fname,junk
  string	dep1,dep2,outdep1,outdep2
  string	param1,param21,param22
  int		num,nsc,nsc1,nsc2,ipos
  
  string	logli,logliaux
  string	log_number,log_selected,log_name
  string	log_average,log_median,log_sigma
  string	ref_average,ref_median,ref_sigma
  real		ratio_average,ratio_median,ratio_sigma
  
  string	interv
  int		xmin,xmax
  char		option_name
  int		option_value,cont_value


   
  # Check interval of image  
  interv = statinterv
  if (interv != "[*]")
    {
    nsc1 = stridx(interv,"[")
    nsc2 = stridx(interv,"]")
    nsc  = stridx(interv,":")
    
    if (nsc == 0 || nsc1 == 0 || nsc2 == 0) 
      {
      if (verbose)
        {
	print "WARNING: Statistic interval "//interv//" wrong"
	print "         All interval is choosen"
	}
      interv = "[*]"
      }
    else
      {if (verbose) print "INFO: statistci interval "//interv}
    }

  inputli = mktemp (tmpdir//"lspecstatinputli")
  inli = mktemp (tmpdir//"lspecstatinli")
  #sections (input//interv,option="fullname",>> inli)
  sections (input,>> inputli)
  list1 = inputli
  While (fscan(list1,fname) != EOF)
    {print (fname//interv,>> inli)}

  outli = output
  if (access(outli))
    {
    beep
    print("")
    print("ERROR: operation would overwritte output list file ")
    print("lspecstat aborted")
    print("")
    beep
    bye
    }

  # Related file treatment analyse
  if (indepf1 == "") dep1 = ""
  else dep1 = indepf1
  if (indepf2 == "") dep2 = ""
  else dep2 = indepf2

  if (access(outdepf1))
    {if (verbose) print "WARNING: "//outdepf1//" already exists"}
  if (access(outdepf2))
    {if (verbose) print "WARNING: "//outdepf2//" already exists"}

  if (dep1 != "")
    {
    if (!access(dep1))
      {
      if (verbose)
    	{
    	print "WARNING: "//dep1//" does not exist"
    	print " 	file will not be considered"
    	}
      dep1 = ""
      }
    }
  if (dep2 != "")
    {  
    if (!access(dep2))
      {
      if (verbose)
    	{
    	print "WARNING: "//dep2//" does not exist"
    	print " 	file will not be considered"
    	}
      dep2 = ""
      }
    }
    
  if (dep1 != "") outdep1 = mktemp(tmpdir//"lspecstatdep1")
  if (dep2 != "") outdep2 = mktemp(tmpdir//"lspecstatdep2")
 
    
  num = 0
  
  #----------------------------------
  # Variable verification finished
  ###################################
  
  ####################################
  # Spectra selection
  #-----------------------------------  
  
  # We create log file containing statistics
  logli = mktemp (tmpdir//"lspecstatlogli")
  print ("Number selected   name    average   median   sigma")
  print ("Number selected   name    average   median   sigma", >> logli)
  cont_value = 0
  list1 = inli
  While (fscan(list1,fname) != EOF)
    {
    lstatist( image = fname,
            nsigrej = 5.,
            maxiter = 10,
              print = no,
            verbose = no,
          addheader = no,
              lower = INDEF,
              upper = INDEF,
           oneparam = "all")   
    
    cont_value = cont_value + 1
    print( cont_value," ",
           "yes "," ",
           fname," ",
	   int(1000*lstatist.mean)/1000.," ",
	   int(1000*lstatist.median)/1000.," ",
	   int(1000*lstatist.variance)/1000.)
    print( cont_value," ",
           "yes "," ",
           fname," ",
	   int(1000*lstatist.mean)/1000.," ",
	   int(1000*lstatist.median)/1000.," ",
	   int(1000*lstatist.variance)/1000.," ",
	   >>logli)
	   
    } # end of While (fscan(list1=inli,fname) != EOF)
  
  print ""
  print ""  
  print "****** SPECTRA SELECTION	     *********** "
  print "****** PRESS: 		 	     *********** "
  print "******       q to quit              *********** "
  print "******       s print statistic      *********** "
  print "******       r print ref statistic  *********** "
  print "******       p to plot spectra      *********** "
  print "******       d to delete spectra    *********** "
  print "******       a to add spectra       *********** "
  print "******       i to change interval   *********** "
    
  
  # inli --> redli 
  option_value = 0
  option_name = "n"
  While(scanf("%c",option_name) != EOF)
    {
     
    # act according to key pressed
    switch ( option_name )
      {
      ###
      # quit (ie. return to calling script)
      ###
      case 'q':
        {
        # break out of loop
	if (verbose) print "Selection process finished"
	break
        }# End of case q
	
      ###
      # plot the selected image
      ###
      case 'p':
        {
	print "Select image to be ploted: "
	scanf("%d",option_value)
	list1 = logli
	list2 = inputli
	for (cont_value=1;  cont_value <= option_value ;  cont_value += 1)
	  {
	  nsc = fscan(list1)
	  nsc = fscan(list2,fname)
	  } # End of for (cont_value=1;  ...)
	if (fscan(list1,log_number,log_selected,log_name) != EOF)
	  {
	  if (log_selected != "yes")
	    {print "Image is not selected"}
	  else  
	    {
	    print "Image "//fname//" is plot"
	    implot(fname)
	    }
	  } # End of if (fscan(list1=logli,log_number,...) != EOF)
	} # End of case p
	
      ###
      # print statistic of images
      ###
      case 's':
        {
        list1 = logli
        While(fscan(list1,log_number,
      			  log_selected,
		  	  log_name,
			  log_average,
			  log_median,
			  log_sigma) != EOF)
          {print (log_number," ",
		  log_selected," ",
		  log_name," ",
		  log_average," ",
		  log_median," ",
		  log_sigma)}
        print ""
	} # End of case s
	
      ###
      # print statistic of images
      ###
      case 'r':
        {
	print "Select reference image: "
	scanf("%d",option_value)
	list1 = logli
	for (cont_value=1;  cont_value <= option_value ;  cont_value += 1)
	  {
	  nsc = fscan(list1)
	  } # End of for (cont_value=1;  ...)
	if (fscan(list1,log_number,
      			  log_selected,
		  	  log_name,
			  ref_average,
			  ref_median,
			  ref_sigma) == EOF)
	  {
	  ref_average = 1
	  ref_median = 1
	  ref_sigma = 1
	  }
	  
	list1 = logli
        if (fscan(list1,log_number,
      			  log_selected,
		  	  log_name,
			  log_average,
			  log_median,
			  log_sigma) != EOF)
          {
	  print (log_number," ",
		  log_selected," ",
		  log_name," ",
		  log_average," ",
		  log_median," ",
		  log_sigma)
	  
	  } # End of if (fscan(list1,log_number, ...)
	While(fscan(list1,log_number,
      			  log_selected,
		  	  log_name,
			  log_average,
			  log_median,
			  log_sigma) != EOF)
          {
	  ratio_average = real(int(1000*real(log_average)/real(ref_average)))/1000.
	  ratio_median = real(int(1000*real(log_median)/real(ref_median)))/1000.
	  ratio_sigma = real(int(1000*real(log_sigma)/real(ref_sigma)))/1000.
	  print (log_number," ",
		  log_selected," ",
		  log_name," ",
		  ratio_average," ",
		  ratio_median," ",
		  ratio_sigma)
	  }
        print ""
	} # End of case s
	
      ###
      # delete image of the list 
      ###
      case 'd':
        {
	print "Select image to be deleted: "
	scanf("%d",option_value)
	logliaux = mktemp(tmpdir//"lspecstatlogliaux")
	list1 = logli
	# We read all information before spectra selected in logfile
	for (cont_value=1;  cont_value <= option_value ;  cont_value += 1)
	  {
	  if (fscan(list1,log_number,
      			log_selected,
			log_name,
			log_average,
			log_median,
			log_sigma) != EOF)
	    {
	    print (log_number," ",
      			log_selected," ",
			log_name," ",
			log_average," ",
			log_median," ",
			log_sigma," ",>>logliaux)
		
	    } # End of if (fscan(list1,log_number,...)
	  } # End of for (cont_value=1;  ...)
	  
	  # We read choosen spectra  
	  if (fscan(list1,log_number,
      			log_selected,
			log_name,
			log_average,
			log_median,
			log_sigma) != EOF)
	    {
	    if (log_selected == "no")
	      {print "spectra already erased"}
	    print (log_number," ",
      		   "no"," ",
		   log_name," ",
		   log_average," ",
		   log_median," ",
		   log_sigma," ",>>logliaux)
	      
	    } # End of if (fscan(list1,log_number,...)
	
	# We read all information after spectra selected in logfile
	While (fscan(list1,log_number,
      			log_selected,
			log_name,
			log_average,
			log_median,
			log_sigma) != EOF)
	  {
	  print (log_number," ",
      	              log_selected," ",
	              log_name," ",
	              log_average," ",
	              log_median," ",
	              log_sigma," ",>>logliaux)
	
	  } # End of if (fscan(list1,log_number,...)
	delete(logli,yes,ver-)  
	rename(logliaux,logli)
	} # End of case d
	
      ###
      # add image to the list 
      ###
      case 'a':
        {
	print "Select image to be added: "
	scanf("%d",option_value)
	logliaux = mktemp(tmpdir//"lspecstatlogliaux")
	list1 = logli
	# We read all information before spectra selected in logfile
	for (cont_value=1;  cont_value <= option_value ;  cont_value += 1)
	  {
	  if (fscan(list1,log_number,
      			log_selected,
			log_name,
			log_average,
			log_median,
			log_sigma) != EOF)
	    {
	    print (log_number," ",
      			log_selected," ",
			log_name," ",
			log_average," ",
			log_median," ",
			log_sigma," ",>>logliaux)
		
	    } # End of if (fscan(list1,log_number,...)
	  } # End of for (cont_value=1;  ...)
	  
	# We read choosen spectra  
	if (fscan(list1,log_number,
      	              log_selected,
	              log_name,
	              log_average,
	              log_median,
	              log_sigma) != EOF)
	  {
	  if (log_selected == "yes")
	    {print "spectra already choosen"}
	   
	  print (log_number," ",
      	  	 "yes"," ",
	  	 log_name," ",
	  	 log_average," ",
	  	 log_median," ",
	  	 log_sigma," ",>>logliaux)
	    
	  } # End of if (fscan(list1,log_number,...)
	
	# We read all information after spectra selected in logfile
	While (fscan(list1,log_number,
      			log_selected,
			log_name,
			log_average,
			log_median,
			log_sigma) != EOF)
	  {
	  print (log_number," ",
      	              log_selected," ",
	              log_name," ",
	              log_average," ",
	              log_median," ",
	              log_sigma," ",>>logliaux)
	
	  } # End of if (fscan(list1,log_number,...)
	delete(logli,yes,ver-)  
	rename(logliaux,logli)
	} # End of case a
	
      ###
      # change statistic interval 
      ###
      case 'i':
        {
	print("Introduce minimum value: ")
	scanf("%d",xmin)
	print("Introduce maximum value: ")
	scanf("%d",xmax)
	interv = "["//xmin//":"//xmax//"]"
	
	delete(inli,yes,ver-)
	list1 = inputli
        While (fscan(list1,fname) != EOF)
           {print (fname//interv,>> inli)}
	
        # We create a new log file containing statistics
	logliaux = mktemp (tmpdir//"lspecstatlogliaux")
        print ("Number selected   name    average   median   sigma")
        print ("Number selected   name    average   median   sigma", >> logliaux)
        cont_value = 0
        list1 = inli
	list2 = logli
	nsc = fscan(list2)
        While (fscan(list1,fname) != EOF \
	      && fscan(list2,log_number, \
      			log_selected,    \
			log_name,        \
			log_average,     \
			log_median,      \
			log_sigma) != EOF)
          {
          lstatist( image = fname,
        	  nsigrej = 5.,
        	  maxiter = 10,
        	    print = no,
        	  verbose = no,
        	addheader = no,
        	    lower = INDEF,
        	    upper = INDEF,
        	 oneparam = "all")
 
          cont_value = cont_value + 1
          print( cont_value," ",
        	 log_selected," ",
        	 fname," ",
        	 int(1000*lstatist.mean)/1000.," ",
        	 int(1000*lstatist.median)/1000.," ",
        	 int(1000*lstatist.variance)/1000.)
          print( cont_value," ",
        	 log_selected," ",
        	 fname," ",
        	 int(1000*lstatist.mean)/1000.," ",
        	 int(1000*lstatist.median)/1000.," ",
        	 int(1000*lstatist.variance)/1000.," ",
        	 >>logliaux)
 
          } # end of While (fscan(list1=inli,fname) != EOF && ..)
	delete(logli,yes,ver-)
	rename(logliaux,logli)
	} # End of case i
	
      ###
      # change statistic interval 
      ###
      case '?':
        {
        print "****** PRESS: 		 	     *********** "
        print "******       q to quit              *********** "
        print "******       s print statistic      *********** "
        print "******       r print ref statistic  *********** "
        print "******       p to plot spectra      *********** "
        print "******       d to delete spectra    *********** "
        print "******       a to add spectra       *********** "
        print "******       i to change interval   *********** "
	} # End of case ?
	
	
      }	# End of switch ( option_name )
    print "select option action: "
    } # end of While(scanf("%c",option_name) != EOF)
  
  # We read log file with selected spectra
  redli = mktemp(tmpdir//"lspecstatredli")
  list1 = logli
  list2 = inputli
  nsc = fscan(list1)
  While (fscan(list1,cont_value,junk) != EOF)
    {
    if (junk == "yes") 
      {
      if (fscan(list2,fname) != EOF)
        {
        print(fname, >> redli)
        num = num + 1
	}
      }
    } # end of While (fscan(list1=logli,junk,fname) != EOF)
  delete(logli,yes,ver-)  
    
  # We treate associated files
  if (dep1 != "" || dep2 != "")
    {    
    if (dep1 != "") list3=dep1
    if (dep2 != "") list4=dep2
    nsc1 = EOF
    nsc2 = EOF
    
    list1 = redli
    list2 = inputli
    While (fscan(list1,imref) != EOF)
      {
      lfilename(imref)
      imref = lfilename.root
 
      While (fscan(list2,fname) != EOF)
    	{
    	if (dep1 != "") nsc1=fscan(list3,param1)
    	if (dep2 != "") nsc2=fscan(list4,param21,param22)
 
    	lfilename(fname)
    	if (lfilename.root == imref)
    	  {
    	  print (fname, >> outli)
    	  if (nsc1 != EOF) print (param1,>>outdep1)
    	  if (nsc2 != EOF) print (param21//" "//param22,>>outdep2)
    	  break
    	  }
    	else
    	  {
    	  if (delnosel)
    	    {
    	    imdelete(fname,yes,ver-)
    	    print "WARNING: image "//fname//" deleted"
    	    }
    	  }
    	} # end of While (fscan(list2,fname) != EOF)
 
      } # end of While (fscan(list1,fname))
    delete (redli,yes,ver-, >>&"/dev/null")
    } # end of if (dep1 != "" || dep2 != "")
  else
    {rename(redli,outli, >>&"/dev/null")}
  
  if (dep1 != "")
    {
    delete (outdepf1,yes,ver-, >>& "/dev/null")
    rename (outdep1,outdepf1,field="all", >>&"/dev/null")
    }
  if (dep2 != "")
    {  
    delete (outdepf2,yes,ver-, >>& "/dev/null")
    rename (outdep2,outdepf2,field="all", >>&"/dev/null")
    }
  
  imnum = num
  
  delete (inli,yes,ver-, >>&"/dev/null")
  delete (inputli,yes,ver-, >>&"/dev/null")

  list1 = ""
  list2 = ""
  list3 = ""
  list4 = ""

end
     
