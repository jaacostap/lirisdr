# liflatcor - correct by flat field a list of images
#             could make two ldedither iteration using star mask in the second
# 		step
#  	      The non-linear pixel mask can be derived
# Author : Jose Acosta (jap@ll.iac.es)
# Version: 25. Jan. 2005
##############################################################################
procedure liflatcor (input,outfltc,flat)

string	input		{prompt="List of  images to be corrected"}
string  outfltc         {"f",prompt="Prefix of flat-field corrected images"}
string	flat		{"",prompt="Name of flatfield correction"}
bool	corrow		{no,prompt="Correct bad pixel mapping?"}
string  outrow		{"c",prompt="prefix of image with pixel mapping corrected"}

bool    verbose {yes,prompt="Verbose"}

# Directories
string  tmpdir  {")_.tmpdir",prompt="Temporary directory for file conversion"}
string  *list1  {prompt="Ignore this parameter(list1)"}

begin

string	input1,inim,corrowlibr,prepostlibr, flat1
string 	fname, inframli, outframli, outfltc1
bool 	origcpixprepost, verb1
real	md
int	nsc, nscmax
  
  input1 = input
  outfltc1 = outfltc
  flat1 = flat
  verb1 = verbose
  
  # expand input image names.
  inim = mktemp(tmpdir//"_lifltcorr")
  sections(input1,option="fullname",> inim)
   
  # check that flatfield exists
  limgaccess(flat1, verbose=no)
  if ( !limgaccess.exists )
    {
      beep
      print("")
      print("ERROR: flat field  image cannot be found "//flat1)
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
    if (outrow == "")
      {
      lcpixmap (input = "@"//inim,     
               output = "lmkfcrow_", 
              outlist = corrowlibr,   
              verbose = verbose,
	       tmpdir = tmpdir)
      }
    else
      {
      lcpixmap (input = "@"//inim,     
               output = outrow, 
              outlist = corrowlibr,   
              verbose = verbose,
	       tmpdir = tmpdir)	       
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
    corrowlibr = inim
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
  
   prepostlibr = mktemp(tmpdir//"_lmksfppli")
  
   llistdiff (input = "@"//corrowlibr,         
              output = prepostlibr,             
               pname = mktemp("lmkf")//"_",     
             verbose = verbose,
              tmpdir = tmpdir)
	      
	       
  if (verb1)
    {
    print "image format verified"
    print ""
    }
  
    
## split the list of images according to the run sequence
  inframli = mktemp (tmpdir//"_lmkspflinfrli")
  outframli = mktemp (tmpdir//"_lmkspfloutfrli")
  list1 = prepostlibr
  nscmax = 0
  while (fscan(list1,fname) != EOF)
    {

      lfilename (fname)
      print (fname, >> inframli)
      print (tmpdir//outfltc1//lfilename.root, >> outframli)
      if (verb1) print "adding image "//lfilename.reference

    } # End of While (fscan(list1=difli) != EOF)


## combine image to create superflat    
   
   ## now divide by the flat
   imarith("@"//inframli,"/",flat1,"@"//outframli,verbose=verb1)
   hedit ("@"//outframli, "FLATCOR",1,add=yes,update=yes,verify=no)
   hedit ("@"//outframli, "FLATIMG",flat1,add=yes,update=yes,verify=no)


   ## clean up
   delete(inim,ver-,>>"dev$null")
   delete(inframli,ver-,>>"dev$null")
   delete(outframli,ver-,>>"dev$null")
   
   delete(prepostlibr,ver-,>>"dev$null")

end
