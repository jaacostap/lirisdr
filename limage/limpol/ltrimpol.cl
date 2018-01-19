# ltrimpol - Trim images into a sequence of files, useful for polarimetry 
#  
# Author : Jose Acosta  (jap@ll.iac.es)
# Version 1: 11. Jan. 2006
##############################################################################
procedure ltrimpol(input,output,ftrimsec)
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
  string	im,rootoutim,outimsec,flstsec,outl, isecnam,im_tmp
  int 		x1,x2,y1,y2,isec, ycenter
  bool		verb1, dry1

   # expand input and output image names.
  rootoutim = output
  im = input
  outl = outlist
  verb1 = verbose
  dry1 = dryrun


  im_tmp = mktemp("_ltrmsec")
  if (!dry1)
    imcopy(im,im_tmp,verb+)
 
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
   
  list1 = flstsec 
  while (fscan(list1,outimsec,isecnam,x1,x2,y1,y2) != EOF)
   {
      limgaccess(outimsec, verbose=no)
      # check if output image exists
      if ( limgaccess.exists && !dry1)
	{
	beep
	print("")
	print("ERROR: operation would override output file "//outimsec)
	print("ltrimim aborted")
	print("")
	beep
	bye
	}
         

      if (!ismask) {
         if (verb1) print ("Section - x1,x2,y1,y2 ",x1,x2,y1,y2)
	 if (!dry1) {
           imcopy (im_tmp//"["//x1//":"//x2//","//y1//":"//y2//"]",outimsec,verb+)      
	   hedit(outimsec,"LPOLVECT",isecnam,veri-,add+,del-,>"dev$null") 
	 }
	 
      } else { 
         if (verb1) print ("Section - x1,x2,y1,y2 ",x1,x2,y1,y2)
 	 if (!dry1) {
           imcopy (im_tmp//"["//x1//":"//x2//","//y1//":"//y2//"]",outimsec//".pl",verb+)
	   hedit(outimsec,"LPOLVECT",isecnam,veri-,add+,del-,>"dev$null") 
	 }
      }
      if (outl != "") print(outimsec,>> outl)
    }
   
## clean up temporary files
 
delete(flstsec,ver-)
imdel(im_tmp,ver-)

end
