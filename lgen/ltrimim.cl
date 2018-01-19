# ltrimspec - Trim spectra into a sequence of files, useful for MOS 
#  
# Author : Jose Acosta  (jap@ll.iac.es)
# Version 1: 11. Jan. 2006
##############################################################################
procedure ltrimim(input,output,ftrimsec)
string  input           {"",prompt="Image to be trimmed"}
string  output          {"",prompt="Output root image name"}
string  onamext		{"",prompt="File containing names for sections"}
string  outlist         {"",prompt="Output image listfile"}
string  ftrimsec        {"",prompt="File containing trimming sections"}
bool	ismask		{no,prompt="is a mask? If yes append an extension pl"}
string  tmpdir          {")_.tmpdir",prompt="Temporary directory for file conversion"}

string *list1   {prompt="Ignore this parameter"}
string *list2   {prompt="Ignore this parameter"}

begin
  string	im,rootoutim,outimsec,flstsec,outl
  int 		x1,x2,y1,y2,isec,isecnam
  bool		defext = yes
  

   # expand input and output image names.
  rootoutim = output
  im = input
  outl = outlist

  # Open the file containing the image sections
  list1 = ftrimsec
  flstsec = mktemp(tmpdir//"ltrmm")
  isec = 1
  list2 = onamext
  if (onamext != "") defext = no 
  while (fscan(list1,x1,x2,y1,y2) != EOF)
   {
      if (defext) 
         {
            printf("%s_%02d %d %d %d %d\n",rootoutim,isec,x1,x2,y1,y2, >> flstsec)
	 }
      else 	 
         {
	    if (fscan(list2,isecnam) != EOF) {
	        printf("%s_%s %d %d %d %d\n",rootoutim,isecnam,x1,x2,y1,y2, >> flstsec)
	      }
	    else 
	      {
	        print("Error: number of name for sections does not match sections")
		bye
	      }  
         }
      isec = isec + 1 
   }
   
  list1 = flstsec 
  while (fscan(list1,outimsec,x1,x2,y1,y2) != EOF)
   {
      limgaccess(outimsec//"*", verbose=no)
      # check if output image exists
      if ( limgaccess.exists )
	{
	beep
	print("")
	print("ERROR: operation would override output file "//fname)
	print("ltrimim aborted")
	print("")
	beep
	bye
	}
	
      if (!ismask)
         imcopy (im//"["//x1//":"//x2//","//y1//":"//y2//"]",outimsec,verb-)      
      else 
         imcopy (im//"["//x1//":"//x2//","//y1//":"//y2//"]",outimsec//".pl",verb-)

      if (outl != "") print(outimsec,>> outl)
    }
   
## clean up temporary files
 
delete(flstsec,ver-)

end
