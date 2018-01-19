# lcpixmap - to correct the bad pixel map
# Author : Miguel Charcos (mcharcos@ll.iac.es)
# Version: 16. Dec. 2003
##  outlist is optional argument. J. Acosta- September 2005
##############################################################################

procedure lcpixmap(input,output,outlist)

string 	input    	{prompt="List of images to correct"}
string 	output     	{prompt="Prefix of output images "}
string 	outlist     	{prompt="List of corrected images "}
bool   	verbose	     	{yes,prompt="Verbose output?"}

# Directories
string  tmpdir  	{")_.tmpdir",prompt="Temporary directory for file conversion"}

bool	original	{prompt="Positive if none of the images is corrected"}

struct 	*imglist	{prompt="Ignore this parameter(imglist)"}


begin

  string  	ini, ino
  string  	img, outtmp, outtmp1,rootimg
  string	outli
  int		nsc


  #######################################
  # Verify parametres
  #--------------------------------------
  
  #  Make name for temporary files
  	  
  ini = mktemp(tmpdir//"lcpixmapini")
  ino = output
  outli = outlist
  
  # Expand input and output image list
  files(input,>ini)

  # Check if output images exist
  
  # Check if output image list file exists


  #######################################
  # Correction process
  #--------------------------------------
  original = no
  imglist = ini
  while (fscan (imglist,img) != EOF) 
    {
    lfilename(img)
    rootimg = lfilename.root
    lhgets(img,param="PIXMAPCR")
    if (lhgets.value == "1")
      {
      if (verbose) print "WARNING: Image "//img//" already corrected"
      if (outli != "") {
        print (img, >> outli) }
      original = yes
      }
    else # if (lhgets.value == "0")
      {
      if (verbose) 
         print("Correcting image ",img," ..") 
  
      lcheckfile(img,verbose=no)
      
      if (lcheckfile.format == "ImpB")
        {
        # We change columns 1 and 2 in 513 and 514. 
        # The list res_list contains new image names
	
        outtmp1 = mktemp(tmpdir//"lcpixmapouttmp1")//".fit" 
        imcopy(img,outtmp1,ver+)
        imcopy(img//"[1:2,514:1024]",outtmp1//"[513:514,513:1023]",ver-)
        imcopy(img//"[1:2,2:512]",outtmp1//"[513:514,1:511]",ver-)
        imcopy(img//"[513:514,*]",outtmp1//"[1:2,*]",ver-)
	imrename(outtmp1,ino//rootimg,ver-)
        if (outli != "") 
	  { print (ino//rootimg, >> outli) }
	hedit (images = ino//rootimg,fields = "PIXMAPCR",value = "1", \
	       add = yes,delete = no,verify = no,show = no,update = yes) 
	}
      else if (	lcheckfile.format == "UDAS")
        {
        lcorrow(img,ino//rootimg)
        if (outli != "") 
	  { print (ino//rootimg, >> outli) }
	hedit (images = ino//rootimg//"[0]",fields = "PIXMAPCR",value = "1", \
	       add = yes,delete = no,verify = no,show = no,update = yes) 
	}
      else if (	lcheckfile.format == "UNIC")
        {
	if (verbose) 
	  {
	  print "WARNING: file format treatment not implemented"
	  print "         image "//img//" not corrected"
	  }
        if (outli != "") 
	  { print (img, >> outli) }
        original = yes
	}
      else # if ( lcheckfile.format == "unknown")
        {
        # imcopy(img,outtmp1,ver+)
	if (verbose) 
	  {
	  print "WARNING: image format unknown"
	  print "         image "//img//" not corrected"
	  }
        if (outli != "") 
	  { print (img, >> outli) }
        original = yes
	}

      } # end of else [if (lhgets.value == 0)]
    } # end of while (fscan (imglist,img) != EOF) 

 
  if (verbose) print("images corrected")
    
  #######################################
  # Cleaning up
  #--------------------------------------
  delete(ini, yes, ver-, >& "dev$null")	  
      

  imglist = ""
  
end

