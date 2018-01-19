# lrctalk - Perfom correction of cross talk in a list of images
# Author : Jose Acosta (jap@ll.iac.es)
# Version: 3. Sep. 2004
##############################################################################

procedure lrctalk(input,output)

string 	input    	{prompt="List of images to correct"}
string 	output     	{prompt="Prefix of output images "}
string 	outlist     	{"",prompt="List of corrected images "}
bool   	verbose	     	{yes,prompt="Verbose output?"}

# Directories
string  tmpdir  	{")_.tmpdir",prompt="Temporary directory for file conversion"}
string  stddir  	{")_.stddir",prompt="Parametre directory for transformations"}			

bool	original	{prompt="Return if almost one image was not been changed"}

struct 	*imglist	{prompt="Ignore this parameter(imglist)"}


begin

  string  	ini, ino
  string  	img, imo, outtmp, outtmp1,rootimg
  string	outli, intmp
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
  while ((fscan (imglist,img) != EOF)) 
    {
    limgaccess(img,verbo-)
    if (!limgaccess.exists)
      {
	beep
	print("")
	print("ERROR: input image does not exist")
	print("lrctalk aborted")
	print("")
	beep
	bye
      }
    else
      {
        intmp = limgacces.real_name
      }
      
      
    lfilename(intmp)
    rootimg = lfilename.root
    lhgets(intmp,param="LRCTALK")
    if (lhgets.value == "1")
      {
      if (verbose) print "WARNING: Image "//img//" already corrected"
      print (img, >> outli)
      original = yes
      }
    else # if (lhgets.value == "0")
      {
      lcheckfile(img,verbose=no)
      
      if (lcheckfile.format == "UNIC"  || lcheckfile.format == "unknown")
        {
	 if (verbose) 
	   {
	   print "WARNING: Correction for this image format is not implemented"
	   print "         image "//img//" not corrected"
	   }
         print (img, >> outli)
         original = yes
	} 
	else 
        {
         if (verbose) 
           print("Correcting cross talk of image ",img," ..") 
	 #print("img ",intmp)
	 outtmp = tmpdir // ino // lfilename.root // "." // lfilename.extension   
         limgaccess(outtmp,verbo-)
	 if (!limgaccess.exists) 
	   {
             rctalk(intmp,outtmp)
             if (verbose) print (lfilename.root," image corrected")
	     if (outli != "") { print (ino//rootimg, >> outli) }
	     hedit (images = ino//rootimg//"[0]",fields = "LRCTALK",value = "1", \
		add = yes,delete = no,verify = no,show = no,update = yes) 
	   } else {
	     if (verbose) print ("Error: output image exists")
	   } 
	}


      } # end of else [if (lhgets.value == 0)]
    } # end of while (fscan (imglist,img) != EOF) 

 
    
  #######################################
  # Cleaning up
  #--------------------------------------
  delete(ini, yes, ver-, >& "dev$null")	  
      

  imglist = ""
  
end

