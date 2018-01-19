# lreduction - make lists of the same group and reduct images of lists
# 
# Author : Miguel Charcos (mcharcos@ll.iac.es)
# Version: 12. Oct. 2003
##############################################################################
procedure lreduction (input, outdith,outspectr)

string	input		{prompt="Name of file list of images"}
string	outdith		{prompt="Prefix name of output dither results"}
string	outspectr	{prompt="Prefix name of output spectre results"}
string	inmode		{"listf",prompt="Mode of input list (listf|checkf)"}

# Correction parameter files
pset 	dithopt	{prompt="Dither reduction parametres"}
pset	specopt	{prompt="Spectral reduction parametres"}

bool	verbose	{"no",prompt="Verbose"}

# Directories
string	tmpdir	{")_.tmpdir",prompt="Temporary directory for file conversion"}
string	stddir	{")_.stddir",prompt="Parametre directory"}


string *list1	{prompt="Ignore this parameter(list1)"}
string *list2	{prompt="Ignore this parameter(list2)"}
string *list3	{prompt="Ignore this parameter(list3)"}


begin

  string	checkli,imli
  string	lname,fname1,fname2
  string	type1,type2,type3,imname1,imname2,imname3,path1,path2,path3,path4
  string	imname,inodith,inospectr,ini
  string	saux
  string	trspat,trspec
  int		nsc
  bool		spctanalysis,dithanalysis,intspec
  
  
  
  ini = input
  inodith = outdith
  inospectr = outspectr
  checkli = mktemp(tmpdir//"lreductioncheckli")
  lname = mktemp(tmpdir//"lreductionlname")
  
  if (inodith == "") {dithanalysis = no}
  else {dithanalysis = yes}
  
  if (inospectr == "") {spctanalysis = no}
  else {spctanalysis = yes}
  
  if (specopt.match != "wcs") {intspec=yes}
  else {intspec=no}
  
  if (inmode == "listf")
    {
    if (verbose)
      {
      print ""
      print "listf mode"
      print "Making lists of image groups ..."
      }
    
    lconstlist (input = ini,  
               output = lname,
               fcheck = checkli,
               tmpdir = tmpdir,
              verbose = verbose)
    
    if (verbose)
      {
      print "Lists finished"
      print ""
      }
    }
  else if (inmode == "checkf")
    {
    checkli = ini
    if (verbose)
      {
      print ""
      print "checkf mode"
      print "Lists of image groups considered: "//checkli
      print ""
      }
    }
  else 
    {
    beep
    print("")
    print("ERROR: input file wrong")
    print("lreduction aborted")
    print("")
    beep
    bye
    }  
  
  
  if (verbose)
    {
    print ""
    print "Reducing lists ..."
    }
  
  list1 = checkli
  nsc = fscan (list1)
  While (fscan(list1,fname1,fname2) != EOF)
    {
    if (fname1 == "List")
      {
      nsc = fscan (list1,path1,path2,path3,path4)
      print "marca "//path1//" "//path2//" "//path3
      if (path1//" "//path2//" "//path3 == "Path of images:")
        {
	if (verbose) 
	  {
	  print ""
	  print "Image list: "//fname2
	  print "Path of images: "//path4
	  }
	}
      else {path4="./"}
      
      nsc = fscan (list1,imname1,imname2,imname3)
      print "marca "//imname1//" "//imname2
      if (imname1//" "//imname2 == "Reference image:")
        {
	if (verbose) 
	  {
	  print ""
	  print "Image list: "//fname2
	  print "Reference image: "//imname3
	  }
	imname3=path4//imname3
	print "marca "//imname3
	imgets(image=imname3,param="RUN")
	imname = imgets.value
	print "marca1"
	} # end of if (imname1//" "//imname2 == "Reference image:")
      else # if (imname1//" "//imname2 != "Reference image:")
        {
	imname = mktemp("default")
	print "marca2"
	if (verbose) 
	  {
	  print "Warning: No name of reference image found"
	  print imname//" default name considered"
	  }
	print "marca3"
	} # end of else [if (imname1//" "//imname2 == "Reference image:")]
      
      nsc = fscan (list1,type1,type2,type3)
      if (type1//" "//type2 == "Aquisition type:")
        {
	if (type3 == "dither" && dithanalysis)
	  {
	  imname = inodith//imname
	  limgaccess(imname,verbose=no)
	  if (!limgaccess.exist)
	    {
	    if (verbose) {print "dither reduction ..."}
	    ldedither2 (input = "@"//osfn(fname2),        
                       output = imname,
                	match = dithopt.match,
                       subsky = dithopt.subsky,
                	insky = dithopt.insky,
                      inimkst = "",
                       outrow = "",
                      outprps = "",
                      outsbsk = "",
                      outcorr = "",
                      outmkst = "",
                       outsky = "",
                       inmask = dithopt.inmask,
                      intrans = dithopt.intrans,
                       corrow = dithopt.corrow,
                      intprow = dithopt.intprow,
                       stmask = dithopt.stmask,
                     adjshift = dithopt.adjshift,
                	scale = dithopt.scale,
                      verbose = verbose,
                       tmpdir = tmpdir,
                       stddir = stddir,
                     dispstep = no,
                     choffset = no,
                       bigbox = dithopt.bigbox,
                      sherror = dithopt.sherror)
	  
	    imli = imname//"_list"
	    copy(fname2,imli)
	    }
	  else
	    {
	    if (verbose) {print "image "//imname//" already exists"}
	    }
	  } # end of if (type3 == "dither" && dithanalysis)
	else if (type3 == "spectr" && spctanalysis)
	  {
	  imname = inospectr//imname
	  limgaccess(imname,verbose=no)
	  if (!limgaccess.exist)
	    {
	    if (verbose) {print "spectre reduction ..."}
	    imgets(image=imname3,param="LIRGRNAM")
	    saux = imgets.value
	    if (saux == "LR_ZJ")
	      {
	      trspat = "ZJspt_030201"
              trspec = "ZJl0p75_030201"
	      }
	    else if (saux == "LR_HK")
	      {
	      trspat = "HKspt_030201"
              trspec = "HKl0p75_030201"
	      }
	    else
	      {
	      trspat = ""
              trspec = ""
	      }
	      lspectr (input = "@"//osfn(fname2),        
                  output = imname,         
                   match = specopt.match,        
                  subsky = specopt.subsky,      
                   insky = specopt.insky,             
                  inmask = specopt.inmask,
        	  trspat = specopt.trspat,  	   
        	  trspec = specopt.trspec,  	   
        	  tmpdir = tmpdir,    
        	  stddir = stddir,	 
        	   scale = specopt.scale,	   
        	  ressky = specopt.ressky,	   
                 combine = specopt.combspc,            
                 verbose = verbose,            
             interactive = intspec)
          
	    imli = imname//"_list"
	    copy(fname2,imli)
	    }
	  else
	    {
	    if (verbose) {print "image "//imname//" already exist"}
	    }
	  } # end of if (type3 == "spectr")
	else 
	  {
	  if (verbose)
	    {print "WARNING: type no recognized"}
	  imname = "_undet"//imname
	  imli = imname//"_list"
	  if (!access(imli)) {copy(fname2,imli)}
	  }  
	} #end of if (type1//" "//type2 == "Aquisition type:")
      else # if (type1//" "//type2 != "Aquisition type:")
        {
	if (verbose) 
	  {print"WARNING: No adquisition type found for "//fname2//" list"}
	} # end of else [if (type1//" "//type2 == "Aquisition type:")]
      } # end of if (fname1 == "List")
    nsc = fscan (list1)
    nsc = fscan (list1)
    } # end of While (fscan(list1,fname1,fname2) != EOF)
  
  if (verbose)
    {
    print "Reduction finished"
    print ""
    }
end
