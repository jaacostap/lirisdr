# lmksupflat - generate combined image from dither
#             could make two ldedither iteration using star mask in the second
# 		step
#  	      The non-linear pixel mask can be derived
# Author : Jose Acosta (jap@ll.iac.es)
# Version: 25. Jan. 2005
##############################################################################
procedure lmksupflat (isflat, nsflat)

string	isflat		{prompt="List of  images to construct superflat"}
string  outfltc         {"f",prompt="Prefix of flat-field corrected images"}
string	nsflat		{"Nsupflat",prompt="Name of normalize superflat"}
string  sflat 		{"Supflat",prompt="Name of combined flat"}
string  combine		{"median",prompt="Type of combine operation"}
string	scale		{"median",prompt="Image scaling"}
string	reject		{"ccdclip",enum="none|minmax|ccdclip",prompt="Type of rejection"}
string  gain		{"5.5",prompt="ccdclip: gain (electrons/ADU)"}
string  rdnoise		{"13",prompt="ccdclip: readout noise (electrons)"}
bool	corrow		{no,prompt="Correct bad pixel mapping?"}
string  outrow		{"",prompt="prefix of image with pixel mapping corrected"}
bool	corvgrad	{yes,prompt="Correct vertical gradient?"}

bool    verbose {yes,prompt="Verbose"}

# Directories
string  tmpdir  {")_.tmpdir",prompt="Temporary directory for file conversion"}
string  *list1  {prompt="Ignore this parameter(list1)"}

begin

string	inlibr,corrowlibr,corrowlidk,prepostlibr, nsflat1
string 	nflattmp, flattmp, fname, inframli, outframli, outfltc1
bool 	origcpixprepost,cvgrad1
real	md
int	nsc, nscmax
  
  outfltc1 = outfltc
  cvgrad1 = corvgrad
  
  # expand input image names.
  inlibr = mktemp(tmpdir//"_lmksfltinbr")
  sections(isflat,option="fullname",> inlibr)
   
  if (sflat == "") 
    flattmp = mktemp("_lmksflflt")
  else 
    flattmp = sflat  

  nsflat1 = nsflat  
  if (nsflat1 == "")
    {
       print "Error: please provide a name for output image")
       bye
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
      lcpixmap (input = "@"//inlibr,     
               output = "lmkfcrow_", 
              outlist = corrowlibr,   
              verbose = verbose,
	       tmpdir = tmpdir)
      }
    else
      {
      lcpixmap (input = "@"//inlibr,     
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
    corrowlibr = inlibr
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
	      
	       
  if (verbose)
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
      limnumber (fname, ver-)
      # get the index in the multrun sequence
      nsc = limnumber.imnum
      if (limnumber.imaxnum > nscmax) 
         nscmax = limnumber.imaxnum 

      lfilename (fname)
      print (fname, >> inframli//nsc)
      print (tmpdir//outfltc1//lfilename.root, >> outframli//nsc)

      if (verbose) print "adding image "//lfilename.reference//" to run list "//nsc

    } # End of While (fscan(list1=difli) != EOF)


## combine image to create superflat    
for (i=1;i<=nscmax; i=i+1)
  { 
     imcombine ("@"//inframli//i,flattmp//"_"//i,headers="",bpmasks="",rejmasks="",
       nrejmasks="",expmasks="",sigmas="",combine=combine,reject=reject,
       project=no,offsets="",masktype="none",scale=scale,zero="none",statsec="")
      
            
     ## en este momento convendria hacer una deteccion de objetos brillantes y 
     ## enmascararlos. Luego se deberia crear una nueva imagen de flat-field usando la mascara.
     
     # create an intermediate flat, not normalized 
     nflattmp = mktemp(tmpdir//"lmkfltntmp")
     imcopy (flattmp//"_"//i,nflattmp//"_"//i,ver-) 
      
     imstatistics(nflattmp//"_"//i,fields="midpt",format=no) | scan(md)
     imarith(nflattmp//"_"//i,"/",md,nsflat1//"_"//i)
     imdel(nflattmp//"_"//i,ver-)
   
     ## now divide by the flat
     imarith("@"//inframli//i,"/",nsflat1//"_"//i,"@"//outframli//i,verbo-)

     ## clean up
     delete(inframli//i,ver-,>>"dev$null")
     delete(outframli//i,ver-,>>"dev$null")

   }
   
   

   
   
   ## clean up   
   
   delete(prepostlibr,ver-,>>"dev$null")

end
