# ltrimspec - Trim spectra into a sequence of files, useful for MOS 
#  
# Author : Jose Acosta  (jap@ll.iac.es)
# Version 1: 11. Jan. 2006
##############################################################################
procedure ltrimspec(input,output,ftrimsec)
string  input           {"",prompt="Image to be trimmed"}
string  output          {"",prompt="Output root image name"}
string  ftrimsec        {"",prompt="File containing trimming sections"}
string  onamext		{"",prompt="File containing names for sections"}
string  outlist         {"",prompt="Output image listfile"}
bool	ismask		{no,prompt="is a mask? If yes append an extension pl"}
string  tmpdir          {")_.tmpdir",prompt="Temporary directory for file conversion"}

string *list1   {prompt="Ignore this parameter"}
string *list2   {prompt="Ignore this parameter"}
string *list3   {prompt="Ignore this parameter"}
string *list4   {prompt="Ignore this parameter"}

begin
  string	input1,inli,outli,fname,im,fout,outimsec,flstsec,outl,styp,slitid,onamext1
  int 		xc, x1,x2,y1,y2,isec,isecnam
  bool		defext = yes
  


  outl = outlist
  
   # expand input and output image names.
  onamext1 = onamext
  input1 = mktemp(tmpdir//"_trmspecin0")
  sections(input,>input1)
  
  inli = mktemp(tmpdir//"_trmspecin")
  list1 = input1
  while(fscan(list1,fname) != EOF)
  {
     print(fname)
     lcheckfile(fname)
     if (lcheckfile.nimages != 0) 
	{
	 if (lcheckfile.mode_aq != "NORMAL")
           print(fname//"[1]",>>inli)
	 else 
	   {
	     print("ERROR: input format not valid")
	   }
	}   
     else	   
	print(fname,>>inli)  
  }
     
  outli = mktemp(tmpdir//"_trmspecout")   
  sections(output,>outli)
    
  if (onamext != "") 
    defext = no 
  else 
    defext = yes  
  
   
  ## now run over list of input images
  list1 = inli
  list2 = outli

  
  while (fscan(list1,im) != EOF) { 
  
      if (fscan(list2,fout) == EOF)
          break 
   
      # Open the file containing the image sections
      list3 = ftrimsec
      flstsec = mktemp(tmpdir//"_ltrms")
      isec = 1
      
      if (!defext) 
        list4 = onamext1
       
      while (fscan(list3,styp, slitid, xc, x1,x2,y1,y2) != EOF)
       {
	  if (defext) 
             {
        	printf("%s_%02d\n",fout,isec) | scan(outimsec)
	     }
	  else 	 
             {
		if (fscan(list4,isecnam) != EOF) {
	            printf("%s_%s\n",fout,isecnam) | scan(outimsec)
		  }
		else 
		  {
	            print("Error: number of name for sections does not match sections")
		    bye
		  }  
             }
	  
	  limgaccess(outimsec, verbose=no)
	  # check if output image exists
	  if ( limgaccess.exists )
	    {
	    beep
	    print("")
	    print("ERROR: operation would override output file "//outimsec)
	    print("ltrimspec aborted")
	    print("")
	    beep
	    bye
	    }
	     
	  if (!ismask)
            {
               imcopy (im//"["//x1//":"//x2//","//y1//":"//y2//"]",outimsec,verb-)  
	       hedit(outimsec,"SLITID",slitid,add+,ver-,>>& "/dev/null") 
	       hedit(outimsec,"SLITXC",xc,add+,ver-,>>& "/dev/null")
	    }    
	  else 
              imcopy (im//"["//x1//":"//x2//","//y1//":"//y2//"]",outimsec//".pl",verb-)

	  if (outl != "") print(outimsec,>> outl)

	  isec = isec + 1 
       }

    
    }

   
## clean up temporary files
 
delete(flstsec,ver-)
delete(inli,ver-)
delete(input1,ver-)
delete(outli,ver-)

end
