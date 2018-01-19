# leququad - correct vertical gradient in LIRIS images
# Author : Jose Acosta (jap@ll.iac.es)
# Version: 20. Jan. 2009
#        14Nov06 - correction of bug (overwriting the first output image)
##############################################################################
procedure leququad(input,output)

string  input   {prompt="Name of input images"}
string  output  {prompt="Name of output images"}
#real	offset 	{prompt="Value of jump between quadrants"}	
bool	corrow	{no,prompt="Correct bad pixel mapping?"}
string  outrow	{"c",prompt="prefix of image with pixel mapping corrected"}
bool    verbose {yes,prompt="Verbose"}

string *list1   {prompt="Ignore this parameter(list1)"}
string *list2   {prompt="Ignore this parameter(list2)"}
 
begin  

  string   inli,outli,upsec,dwsec,fname1,fname2,imgsec,outrow1
  string   prepostli,corrowli
  real	   upedge,dwedge,offup
  bool	   verb1
  
  outrow1 = outrow
  verb1 = verbose
  
  # expand input image name.
  inli = mktemp(tmpdir//"ldithskyinli")
  sections(input,option="root",> inli)
  
  # expand output image name.
  outli = mktemp(tmpdir//"ldithskyoutli")
  sections(output,option="root",> outli)
  
  ##########################################################
  # Correction of pixel mapping problem
  #---------------------------------------------------------
  if (corrow)
    {

    if (verb1)
      {
      print ""
      print "correcting bad pixel mapping..."
      } 
      
    corrowli = mktemp(tmpdir//"_lqqdli")

    if (outrow == "")
      {
      lcpixmap (input = "@"//inli,     
               output = "lmkfcrow_", 
              outlist = corrowli,   
              verbose = verbose,
	       tmpdir = tmpdir)
      }
    else
      {
      lcpixmap (input = "@"//inli,     
               output = outrow1, 
              outlist = corrowli,   
              verbose = verbose,
	       tmpdir = tmpdir)
	       
      }
      

    }    
  else 
    {
    if (verb1)
      {
      print ""
      print "INFO: No need to correct wrong pixel mapping"
      print ""
      }
    corrowli = inli
    }
  
  #---------------------------------------------------------
  # End of bad row correction
  ##########################################################
  
  # --------------------------------------------------------------------
  #  Verify image format and perfom pre-post treatment if necesary
  #  Image result can be unique format
  # --------------------------------------------------------------------
  # Check if they are already pre read subtracted images containing a wcs
  if (verb1)
    {
    print ""
    print "verification of image format"
    }
  
   prepostli = mktemp(tmpdir//"_lqqdppli")
  
   llistdiff (input = "@"//corrowli,         
              output = prepostli,             
               pname = mktemp("_lqqd")//"_",     
             verbose = verb1,
              tmpdir = tmpdir)
	      
  
  upsec = "[*,514:521]"
  dwsec = "[*,503:510]"

## start loop over input image list
  list1 = prepostli
  list2 = outli
 while (fscan(list1,fname1) !=EOF)
   { 
    if (fscan(list2,fname2) != EOF)
      {   
        imcopy(fname1,fname2)
        imstatistics(fname1//upsec,fields="midpt",format=no) | scan(upedge)
        imstatistics(fname1//dwsec,fields="midpt",format=no) | scan(dwedge)
	offup = upedge - (upedge+dwedge)/2.
	imgsec= mktemp("_lqqd")
        imarith (fname2//"[*,513:1024]","-",offup,imgsec)
	imcopy (imgsec,fname2//"[*,513:1024]")
	imdel(imgsec,ver-,>>&"/dev/null")
	imgsec= mktemp("_lqqd")
        imarith (fname2//"[*,1:512]","+",offup,imgsec)
	imcopy (imgsec,fname2//"[*,1:512]")
	imdel(imgsec,ver-,>>&"/dev/null")
      }
   }   
  
end
