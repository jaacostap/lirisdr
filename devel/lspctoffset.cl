# lspctoffset - search offset of spectra images 
# Author : Miguel Charcos (mcharcos@ll.iac.es)
# Version: 25. Nov. 2003
##############################################################################
procedure lspctoffset(input,output,offsetf)

string	input		{prompt="Name of input spectral images"}
string  output		{prompt="Name of output choosen spectral image list"}
string	offsetf		{prompt="Name of image offset file"}
bool	predisp		{yes,prompt="Select 1D average spectral"}
bool	postdisp	{yes,prompt="Select spectral correlated signals"}
int	numimages	{prompt="Return the number of images contained in final list"}
bool	verbose		{no,prompt="Verbose"}

# Directories
string	tmpdir		{")_.tmpdir",prompt="Temporary directory for file conversion"}

string *list1	{prompt="Ignore this parameter(list1)"}
string *list2	{prompt="Ignore this parameter(list2)"}
string *list3	{prompt="Ignore this parameter(list3)"}


begin

  string 	ini,ino,outoffset
  string	inli,compli,compliaux,crossli,crossliaux
  string	compoutli,crossoutli
  string	fname,imcross,corref
  int 		ipos,num,nsc
  int		readmax1,readmax2
  string	dispax
  int		b1,b2
  
  ini = input
  ino = output
  outoffset = offsetf
  
  # check if output file already exists
  if (access (ino))
    {
    beep
    print("")
    print("ERROR: operation would overwrite output file list "//ino)
    print("lspctoffset aborted")
    print("")
    beep
    bye
    }
  
  # check if offset file exists
  if (access (outoffset))
    {
    beep
    print("")
    print("ERROR: operation would overwrite output offset file "//outoffset)
    print("lspctoffset aborted")
    print("")
    beep
    bye
    }
  
  if (predisp || postdisp)
    {
    # specplot parametre configuration
    spplotopt.apertures = ""
    spplotopt.bands = "1"
    spplotopt.autolayout = yes
    spplotopt.autoscale = no
    spplotopt.fraction = 0.
    spplotopt.units = ""
    spplotopt.scale = "1."
    spplotopt.offset = "0."
    spplotopt.step = 0.
    spplotopt.ptype = "1"
    spplotopt.labels = "user"
    spplotopt.ulabels = ""
    spplotopt.xlpos = 1.02
    spplotopt.ylpos = 0.
    spplotopt.sysid = yes
    spplotopt.yscale = no
    spplotopt.title = "Spectral extraction"
    spplotopt.xlabel = ""
    spplotopt.ylabel = ""
    spplotopt.xmin = INDEF
    spplotopt.xmax = INDEF
    spplotopt.ymin = INDEF
    spplotopt.ymax = INDEF
    }
  
  
  ######
  #  1D spectre building:
  #
  #	At this step we use blkavg task to compress spectr and if option
  #	choosen 1D spectres are displayed and user can delete some ones
  #	interactively. 
  #
  #						  / if (predisp) --> compli&compoutli 
  #	inli (input list) --> compliaux (blkavg) /
  #						 \ else --> compli = compliaux  & 
  #							    compoutli = inli
  ######
  
  
  inli = mktemp(tmpdir//"lspctoffsetinli")
  sections(ini,option="fullname",>inli)
    
  ##################################################
  # We read dispertion axis using DISPAXIS image header
  # field. Default spectra direction is 2.
  #-------------------------------------------------
  
  list1 = inli
  nsc = fscan(list1,fname)
  imgets(image=fname,param="DISPAXIS")
  dispax = imgets.value
  While (fscan(list1,fname) !=EOF)
    {
    imgets(image=fname,param="DISPAXIS")
    if (dispax != imgets.value)
      {
      beep
      print("")
      print("ERROR: dispertion axis of "//fname//" image does not correspond")
      print("lspctoffset aborted")
      print("")
      beep
      bye
      }
    } # end of While (fscan(list1,fname) !=EOF)  
  
  if (dispax == "1")
    {
    if (verbose) print "INFO: Dispertion axis is "//dispax
    b1 = 1024
    b2 = 1
    }
  else if (dispax == "2")
    {
    if (verbose) print "INFO: Dispertion axis is "//dispax
    b1 = 1
    b2 = 1024
    }
  else 
    {
    if (verbose) 
      {
      print "WARNING: Dispertion axis have not be found"
      print "         default dispertion axis is 2"
      }
    b1 = 1
    b2 = 1024
    }
    
    
  if (verbose) {print "calculating 1D spectre ..."}
  
  ##################################################
  # We compress spectra in ordinate axis direction  
  # compliaux contain initial compressed spectra
  # compli contain selected compress spectra
  #-------------------------------------------------
  compliaux = mktemp(tmpdir//"lspctoffsetcompliaux")
  
  lnamelist (input = "@"//inli,
            output = compliaux,
             bname = "lspctoffsetimcomp",
             pname = "",         
            maxnum = INDEF,
            extens = "",      
            tmpdir = tmpdir) 
    
  blkavg ( input = "@"//inli,        
  	  output = "@"//compliaux,    
  	      b1 = b1,		   
  	      b2 = b2,	  
  	  option = "average")
  
  # preselection spectra  	  
  if (predisp)
    {
    compli = mktemp(tmpdir//"lspctoffsetcompli")
    compoutli = mktemp(tmpdir//"lspctoffsetcompoutli")
    lspecplot(input = "@"//compliaux,
             output = compli,
            indepf1 = inli,
            indepf2 = "",
           outdepf1 = compoutli,
           outdepf2 = "",
           delnosel = no,
             tmpdir = tmpdir,
            verbose = verbose)
    
    num = lspecplot.imnum
    } # end of if (predisp)
  else # if (!predisp)
    {
    compli = compliaux
    compoutli = inli
    num = 0
    list1 = inli
    While (fscan(list1,fname) != EOF){num = num + 1}
    } # end of else [if (predisp)]
      
  # We verify that there are some images in the list because we need 
  # almost one to make correlation    
  if (num == 0)
    {
    beep
    print("")
    print "ERROR: You must choose almost one spectre"
    print("lspctoffset finished")
    print("")
    beep
    bye
    }
  
  
  #######
  # correlation process:
  #
  #	At this step we make correlation of spectres containing in compli choosen
  #	by user (or input by user if predisp option no) 
  #
  #						       / if (postdisp) --> crossli&crossoutli 
  #	compli (input list) --> crossliaux (crosscor) /
  #						      \ else --> crossli = crossliaux  & 
  #							         crossoutli = compli
  #######  
  
  if (verbose) 
    {
    print ""
    print "correlating spectres..."
    }
  
  
  ##################################################
  # We correlate spectra of images with reference image
  # of the list, that is first image of selected image list.
  # crossliaux contain all correlations and crossli contain
  # selected correlations.
  #-------------------------------------------------
  crossliaux = mktemp(tmpdir//"lspctoffsetcrossliaux")
  list1 = compli
  if (fscan(list1,corref) != EOF)
    {if (verbose) print "Reference image loaded"}   
    
  list1 = compli
  while (fscan(list1,fname) != EOF)
    {
    if (verbose)
      {print ("correlating image ",fname," and ",corref,"...")}
    
    imcross = mktemp(tmpdir//"lspctoffsetcross")
    crosscor(input1 = corref,
  	     input2 = fname,
  	     output = imcross,
  	    inreal1 = yes,
  	    inimag1 = no,
  	    inreal2 = yes,
  	    inimag2 = no,
  	    outreal = yes,
  	    outimag = no,
  	coord_shift = no,
  	     center = yes,
  	       chop = yes,
  		pad = yes,
  	   inmemory = yes,
  	    len_blk = 256,
  	    verbose = verbose)
    
    print (imcross, >> crossliaux)
    } # end of while (fscan(list1,fname) != EOF)
 
  # correlated spectra selection
  if (postdisp)
    {
    crossli = mktemp(tmpdir//"lspctoffsetcrossli")
    crossoutli = mktemp(tmpdir//"lspctoffsetcrossoutli")
    lspecplot(input = "@"//osfn(crossliaux),
             output = crossli,
            indepf1 = compoutli,
            indepf2 = "",
           outdepf1 = crossoutli,
           outdepf2 = "",
           delnosel = no,
             tmpdir = tmpdir,
            verbose = verbose)
    
    num = lspecplot.imnum
    } # end of if (postdisp)
  
  else # if (!postdisp)
    {
    crossli = crossliaux
    crossoutli = compoutli
    num = 0
    list1 = compoutli
    While (fscan(list1,fname) != EOF){num = num + 1}
    } # end of else [if (postdisp)]



  ###########
  #  Maximum correlation search
  ########### 
 
  if (verbose)
    {
    print ""
    print ("searching for maximum correlation... ")
    }
  
  list1 = crossli  
  While (fscan(list1,imcross) != EOF)
    { 
    minmax(images = imcross,
  	    force = yes,
  	   update = no,
  	  verbose = verbose)
 
    if (fscanf( minmax.maxpix,"[%d,%d]",readmax1,readmax2) != EOF)
      {
      if (dispax == "1") 
	  {
	  print ("0 ",-readmax2)
	  print ("0 ",-readmax2, >> outoffset)
	  }
      else 
	  {
	  print (-readmax1," 0")
	  print (-readmax1," 0", >> outoffset)
	  }
      }
    else
      {print ("0 0", >> outoffset)}
    }
    
  sections("@"//crossoutli,option="fullname",> ino)
  numimages = num
  
  #########
  # Delete temporary files 
  #########
  
  delete(inli,yes,ver-)
  delete(compoutli,yes,ver-, >>& "/dev/null")
  delete(crossoutli,yes,ver-, >>& "/dev/null")
  
  imdelete ("@"//compliaux,yes,ver-)
  delete (compliaux,yes,ver-)
  if (predisp) delete (compli,yes,ver-)
  
  imdelete ("@"//crossliaux,yes,ver-)
  delete (crossliaux,yes,ver-)
  if (postdisp) delete (crossli,yes,ver-)
  
  if (verbose)
    {
    print "offset calculated"
    print ""
    }

  list1 = ""
  list2 = ""
  list3 = ""
  
end
