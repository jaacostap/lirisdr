# lrunsky - generate combined sky image from dither images and 
#	    substract it to images by cycles
# Author : Miguel Charcos (mcharcos@ll.iac.es)
# Version: 12. Feb. 2004
##############################################################################
procedure lrunsky(input,output)

string	input		{prompt="Name of input dither images"}
string	output		{prompt="Prefix name of output substracted images"}
string	outlist		{prompt="List name containing sky substracted images"}
string	insky		{"",prompt="name of input sky list image"}
string	outsky		{"",prompt="name of output sky images when saved"}
string	outmask  	{"",prompt="Prefix for individual star masks"}

# Combining options
pset	liskycpars	{prompt="Combine parameter configuration"}

# Working directory
string	tmpdir		{")_.tmpdir",prompt="Temporary directory for file conversion"}

# Verbosity
bool	verbose		{yes,prompt="Verbose"}
bool	displsub 	{no,prompt="display sky substraction?"}
  
# internal use
string *list1	{prompt="Ignore this parameter(list1)"}
string *list2	{prompt="Ignore this parameter(list2)"}
string *list3	{prompt="Ignore this parameter(list3)"}
string *list4	{prompt="Ignore this parameter(list4)"}
  
begin  

  string	ino,isi,isiact,iso,isoact,fname,imsky,fname1
  string	inli,outli,inskyli,readli,writeli,isili,runli,skyli
  string	inlili,outlili,isilili
  
  int		nsc,i,imcont,skycont,isitype
  bool		found

  # expand input image name.
  inli = mktemp(tmpdir//"lrunskyinli")
  sections(input,option="fullname",> inli)
  
  # expand output image name.
  ino = output
  outli = mktemp(tmpdir//"lrunskyoutli")
  files(ino//"//@"//inli,> outli)
  # We verify if some output image already exist
  list1 = outli
  imcont = 0
  While (fscan(list1,fname) !=EOF)
    {
    imcont = imcont + 1
    print ("output file ",fname)
    lfileaccess(fname,verbose=no)
    if (lfileaccess.exist)
      {
      beep
      print("")
      print("ERROR: operation would overwrite output image "//fname)
      print("lrunsky aborted")
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
    print("lrunsky aborted")
    print("")
    beep
    bye
    }
  
  isi = insky
  iso = outsky
  isoact = ""
  isiact = ""
  	    
    
  ########################################################################
  # We create a list containing every list to consider separately
  #-----------------------------------------------------------------------
  if (verbose)
    {print "Checking run lists ..."}
   
  
  inlili = mktemp (tmpdir//"lrunskyinlili")
  outlili = mktemp (tmpdir//"lrunskyoutlili")
  runli = mktemp (tmpdir//"lrunskyrunli")
  writeli = mktemp (tmpdir//"lrunskywriteli")
  
  list1 = inli 
  While (fscan(list1,fname) != EOF)
    {
    limnumber (fname, ver-)
    # get the index in the multrun sequence
    nsc = limnumber.imnum
    if (!access(runli//nsc))
      {
        print (runli//nsc, >> inlili)
        print (writeli//nsc, >> outlili)
      }
    
    print (fname , >> runli//nsc)
    lfilename (fname)
    if (verbose) print "adding image "//lfilename.reference//" to run list "//nsc
    print (ino//lfilename.reference, >>writeli//nsc)
    print (ino//lfilename.reference, >>outli)
 
      
    } # End of While (fscan(list1=inli) != EOF)
  
 
  
  ###########################################################################
  # Check if a separated list of sky images is provided
  #--------------------------------------------------------------------------
  if (isi != "")
    {
    # When input sky image is introduced we considere three posibilities
    #        
    #      - Only one image is introduced (isitype = 1):
    #                   We will substract this image to images of any lists
    #      - One sky per image (isitype = 2):
    #                   We will create sky lists corresponding to image lists
    #      - Any list ist introduced (isitype = 3):
    #                   We combine images and result is used with every list
    
    
    # We check for single sky image
    limgaccess(isi,verb-)
    if (limgaccess.exists)
      {
      if (verbose) print "INFO: single sky image introduced"
      isitype = 1
      }
    else
      {
      inskyli = mktemp(tmpdir//"lrunskyinskyli")
      sections(isi,option="fullname",> inskyli)
      skycont = 0
      list1 = inskyli
      While (fscan(list1) != EOF)
        {skycont = skycont + 1}
      
      # Check if the number of sky images and images are equal
      if (skycont == imcont)
        {
        if (verbose) print "INFO: list of sky image correspond with image list"
        isitype = 2
	}
      else
        {
        if (verbose) print "INFO: any list of sky introduced"
        isitype = 3
        }
      }
    } # End of if (isi != "")
  else # if (isi == "")
    {
    isitype = 0
    if (verbose) print "INFO: No extra sky image was provided"
    }
  
  # When one sky image per image is introduced we create lists corresponding 
  # of image list created
  if (isitype == 2)
    {
    isilili = mktemp(tmpdir//"lrunskyisilili")
    list1 = inskyli
    skyli = mktemp(tmpdir//"lrunskyisili")

    while (fscan(list1, imsky) != EOF)
      {
        limnumber (imsky,ver-)
	nsc = limnumber.imnum
	if (!access(skyli//nsc))
	  {
	    print (skyli//nsc, >>isilili)
	  }
        print (imsky , >> skyli//nsc)
        lfilename (imsky)
        if (verbose) print "adding sky image "//lfilename.reference//" to run list "//nsc
 
      } # End of While (fscan(list1=inskyli,imsky) != EOF)
      
    } # End of if (isitype == 2)
  

  if (isitype == 1 || isitype == 3) isiact = isi
  
  ###########################################################################
  # We substract sky of each list
  #--------------------------------------------------------------------------
  
  if (verbose) print "Sky substracting process ..."
  i = 1
  list1 = inlili
  list2 = outlili
  if (isitype == 2) list3 = isilili
  While (fscan(list1,readli) != EOF && fscan(list2,writeli) != EOF)
    {
      if (verbose) print "Computing list "//i//" ..."

      if (iso != "") isoact = iso//i
      if (isitype == 2) 
	{
	nsc = fscan(list3,isili)
	isiact = "@"//isili
	}
      lsubdithsky ( input = "@"//readli,
                   output = "@"//writeli,
                    insky = isiact,
                   outsky = isoact,
#	          maskobj = liskycpars.maskobj,
	          outmask = outmask,
#	         corvgrad = liskycpars.corvgrad,
                   tmpdir = tmpdir,
                  verbose = verbose,
                 displsub = displsub)

      i = i+1
    }



  ############################################################################
  #  Delete temporary files
  #---------------------------------------------------------------------------
  
  delete (inli,yes,ver-)
  
  delete ("@"//inlili,yes,ver-)
  delete (inlili,yes,ver-)
  
  delete ("@"//outlili,yes,ver-)
  delete (outlili,yes,ver-)
  
  
  list1 = ""
  list2 = ""
  list3 = ""
  list4 = ""

end 
