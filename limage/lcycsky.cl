# lcycsky - generate combined sky image from dither images and 
#	    substract it to images by cycles
# Author : Miguel Charcos (mcharcos@ll.iac.es)
# Version: 12. Feb. 2004
##############################################################################
procedure lcycsky(input,output,nditpts)

string	input		{prompt="Name of input dither images"}
string	output		{prompt="Prefix name of output substracted images"}
int     nditpts         {prompt="Number of dithern points per cycle"}
string	outlist		{prompt="List name containing sky substracted images"}
string	insky		{"",prompt="name of input sky list image"}
string	outsky		{"",prompt="name of output sky images when saved"}
string	outmask  	{"",prompt="Prefix for individual star masks"}


# Combining options
pset	liskycpars	{prompt="Combine parameter configuration"}

#pset	skycomb		{prompt="Combine parametre configuration"}

# Working Directory
string	tmpdir		{")_.tmpdir",prompt="Temporary directory for file conversion"}

# Verbosity
bool	verbose		{no,prompt="Verbose"}  
bool	displsub 	{no,prompt="display sky substraction?"}
  
# internal use
string *list1	{prompt="Ignore this parameter(list1)"}
string *list2	{prompt="Ignore this parameter(list2)"}
string *list3	{prompt="Ignore this parameter(list3)"}
string *list4	{prompt="Ignore this parameter(list4)"}
  
begin  

  string	ino,isi,isiact,iso,isoact,fname,imsky,fname1
  string	inli,outli,inskyli,readli,writeli,isili,difli,cycli
  string	inlili,outlili,isilili,diflili,skyli
  
  string	junk1,junk2,junk3,junk4
  string	path1,path2,path3,path4,pathim
  string	auxref1,auxref2,auxref3
  
  int		nsc,nscmax,i,imcont,skycont,isitype,idpt,ndpt,icyc
  bool		found
  
  ndpt = nditpts 

  # expand input image name.
  inli = mktemp(tmpdir//"_lcycskyinli")
  sections(input,option="fullname",> inli)

  # expand output image name.
  ino = output
  outli = mktemp(tmpdir//"lcycskyoutli")
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
  
  isi = insky
  iso = outsky
  isoact = ""
  isiact = ""
  
  ########################################################################
  # We create a list containing every list to be considered separately
  #  Images will be ordered according to acquisition sequence. 
  #  Expected as a number of runs (indicated in the header) at the same position on the sky, or 
  #  dither point, then move to the next dithern point and get a number
  #  of runs. A cycle finish when the dithern pattern is finished.
  #  Initially the number of dithern points will be an specified parameter,
  #  later should be possible to obtain from the image header. 
  #-----------------------------------------------------------------------
  if (verbose)
    {print "Separating images per cycle ..."}
  
#  constli = mktemp(tmpdir//"_lcycskyconstli")
#  checkli = mktemp(tmpdir//"_lcycskycheckli")
#  lconstlist (input = "@"//inli,
#             output = constli,
#             fcheck = checkli,
#             tmpdir = tmpdir,
#            verbose = no)    
  
# for each cycle a file list containing the names of files containing the list
# of images split according to the run sequence 

  inlili = mktemp (tmpdir//"_lcycskyinlili")
  outlili = mktemp (tmpdir//"_lcycskyoutlili")
  cycli = mktemp (tmpdir//"_lcycskyrunli")
  writeli = mktemp (tmpdir//"_lcycskywriteli")
  
  list1 = inli
  icyc = 1
  idpt = 0
  While (fscan(list1,fname) != EOF)
    {
    limnumber (fname, ver-)
    # get the index in the multrun sequence
    nsc = limnumber.imnum
    nscmax = limnumber.imaxnum 
    if (!access(cycli//nsc//"_"//icyc))
      {
        print (cycli//nsc//"_"//icyc, >> inlili)
        print (writeli//nsc//"_"//icyc, >> outlili)
      }
    
    print (fname , >> cycli//nsc//"_"//icyc)
    lfilename (fname)
    if (verbose) print "adding image "//lfilename.reference//" to run list "//nsc//" cycle "//icyc
 
    print (ino//lfilename.reference, >>writeli//nsc//"_"//icyc)
    print (ino//lfilename.reference, >>outli)
    
    if (nsc == nscmax) idpt = idpt + 1
      
    ## when the number of frames reaches the number of dither points
    ## then move to next cycle and reset idpt value
    if (idpt == ndpt) 
      { 
         icyc = icyc + 1
         idpt = 0
      }
      	 
    } # End of While (fscan(list1=difli) != EOF)


  
  ##########################################################################
  # Format treatment
  #--------------------------------------------------------------------------
  #diflili = mktemp (tmpdir//"lcycskydiflili")
  #list1 = inlili
  #While (fscan(list1,pathim,writeli) != EOF)
  #  {
  #  difli = mktemp (tmpdir//"lcycskydifli")
  #  llistdiff (input = pathim//"@"//writeli,         
  #            output = difli,             
  #             pname = "subskyprpst",     
  #           verbose = no,
  #            tmpdir = tmpdir)
  #  print (pathim//" "//difli, >> diflili)
  #  }
  
  
  
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
      if (verbose) print "INFO: A single sky image was provided"
      isitype = 1
      }
    else
      {
      inskyli = mktemp(tmpdir//"lcycskyinskyli")
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
    list1 = inskyli
    isilili = mktemp(tmpdir//"_lcycskyisilili")
    skyli = mktemp(tmpdir//"_lcycskyisili")
    icyc = 1

    while (fscan(list1, imsky) != EOF)
      {
        limnumber (imsky,ver-)
        # get the index in the multrun sequence
	nsc = limnumber.imnum
        nscmax = limnumber.imaxnum 
	if (!access(skyli//nsc//"_"//icyc))
	  {
	    print (skyli//nsc//"_"//icyc, >>isilili)
	  }
        print (imsky , >> skyli//nsc//"_"//icyc)
        lfilename (imsky)
        if (verbose) print "adding sky image "//lfilename.reference//" to run list "//nsc//" cycle "//icyc
 
      } # End of While (fscan(list1=inskyli,imsky) != EOF)

    } # End of if (isitype == 2)
  
  if (isitype == 1 || isitype == 3) isiact = isi
  
  ###########################################################################
  # We substract sky of each list
  #--------------------------------------------------------------------------
  
  if (verbose) print "Sky subtracting process ..."
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
	          outmask = outmask,
                   tmpdir = tmpdir,
                  verbose = verbose,
                 displsub = displsub)
    
    i = i+1
    }


  ############################################################################
  #  Delete temporary files
  #---------------------------------------------------------------------------
  
  delete (inli,yes,ver-,>>& "dev$null")
  
  delete ("@"//inlili,yes,ver-,>>& "dev$null")
  delete (inlili,yes,ver-)
  
  delete ("@"//outlili,yes,ver-,>>& "dev$null")
  delete (outlili,yes,ver-)
  
  list1 = ""
  list2 = ""
  list3 = ""
  list4 = ""

end 
