# lspoltrim - Trim images into a sequence of files, useful for polarimetry 
#  
# Author : Jose Acosta  (jap@ll.iac.es)
# Version 1: 11. Jan. 2006
##############################################################################
procedure lspoltrim(input,output,ftrimsec)
string  input           {"",prompt="Image to be trimmed"}
string  output          {"",prompt="Output root image name"}
string  outlist         {"",prompt="Output image listfile"}
string  ftrimsec        {"",prompt="File containing trimming sections"}
bool	ismask		{no,prompt="is a mask? If yes append an extension pl"}
bool	dryrun		{no,prompt="Perform a trial run without slicing images?"}
string  tmpdir          {")_.tmpdir",prompt="Temporary directory for file conversion"}
bool	verbose		{no,prompt="Verbose ?"}

string *list1   {prompt="Ignore this parameter(ltrimpol.list1)"}

begin
  string	im,rootoutim,outimsec,flstsec,outl, isecnam,outimlst,ext0tmp
  int 		x1,x2,y1,y2,isec, ycenter, nexten
  bool		verb1, dry1

   # expand input and output image names.
  rootoutim = output
  im = input
  outl = outlist
  verb1 = verbose
  dry1 = dryrun

  # Open the file containing the image sections
  list1 = ftrimsec
  flstsec = mktemp(tmpdir//"_ltrmm")
  isec = 1
  if (verb1) print ("Trimming image ", im)
  while (fscan(list1,x1,x2,y1,y2) != EOF)
   {
      ## determine extension as function of position on the detector
      ycenter = (y2+y1)/2
      if (abs(ycenter - 128) < 128) 
         isecnam = "45"
      if (abs(ycenter - 384) < 128) 
         isecnam = "135"
      if (abs(ycenter - 640) < 128) 
         isecnam = "90"
      if (abs(ycenter - 896) < 128) 
         isecnam = "0"
	 
      printf("%s_%s %s %d %d %d %d\n",rootoutim,isecnam,isecnam,x1,x2,y1,y2, >> flstsec)

      isec = isec + 1 
   }
  
  isec = 1  
  list1 = flstsec 
  outimlst = mktemp("_ltrmsplout")

  # determine number of extensions
  lcheckfile(im)  
  nexten = lcheckfile.nimages
  
  ext0tmp = mktemp("_ltrmsplext0")
  #print (ext0tmp, >>outimlst)
  if (nexten >0)  ## assuming original format, ext0 contains header
    imcopy(im//"[0]",ext0tmp)
  else 
    imheader(im,l+,>>ext0tmp)  
    fxdummy(rootoutim//".fits",hdr_file=ext0tmp)
  
  while (fscan(list1,outimsec,isecnam,x1,x2,y1,y2) != EOF)
   {
      limgaccess(outimsec, verbose=no)
      # check if output image exists
      if ( limgaccess.exists && !dry1)
	{
	beep
	print("")
	print("ERROR: operation would override output file "//outimsec)
	print("ltrimspol aborted")
	print("")
	beep
	bye
	}
	
      if (!ismask) {
         if (verb1) print ("Copying Section - x1,x2,y1,y2 ",x1,x2,y1,y2)
	 if (!dry1) {
           imcopy (im//"["//x1//":"//x2//","//y1//":"//y2//"]",outimsec,verb+)   
	   hedit(outimsec,"LPOLVECT",isecnam,veri-,add+,del-,>"dev$null") 
	 }
	 
      } else { 
         if (verb1) print ("Copying Section - x1,x2,y1,y2 ",x1,x2,y1,y2)
 	 if (!dry1) {
           imcopy (im//"["//x1//":"//x2//","//y1//":"//y2//"]",outimsec//".pl",verb+)
	   hedit(outimsec,"LPOLVECT",isecnam,veri-,add+,del-,>"dev$null") 
	 }
      }
      if (outl != "") print(outimsec,>> outl)
      print (outimsec,>>outimlst)
    }

    fxcopy("@"//outimlst,rootoutim//".fits")
   
## clean up temporary files
 
delete(flstsec,ver-)

end
