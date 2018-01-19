# lsubscalesky - subtract sky images to a list of images 
#	    The sky image can be scaled or add a zero offset
# Author : Jose Acosta (jap@ll.iac.es)
# Version: 12. Dic. 2004
# Version: 5 Jan 2007
#     The median value of the sky image is included as a keyword
#          in the header of subtracted image  
##############################################################################
procedure lsubscalesky(input,output,sky)

string 	input		{prompt="Input images to be subtracted"}
string	output		{prompt="Output subtracted images"}
string	sky		{prompt="Sky image to be subtracted"}
string	scale		{"none",enum="none|mean|median",prompt="Scale images"}
string	zero		{"none",enum="none|mean|median",prompt="Offset images"}
bool	verbose		{no,prompt="Verbose?"}
string *list1		{prompt="Ignore this parameter(list1)"}
string *list2		{prompt="Ignore this parameter(list2)"}

begin

  string inli, outli, fname, sky_aux, imsubsky, scale1, fld
  real skymidpt

    ## now check if scale or offset is required
  inli = mktemp(tmpdir//"lsscaskyin")
  sections(input,option="fullname",>inli)  
  outli = mktemp(tmpdir//"lsscaskyout")
  sections(output,option="fullname",>outli)  
  list1 = inli
  list2 = outli
  while (fscan(list1, fname) != EOF)
    {
    if (fscan (list2, imsubsky) == EOF)
      {
        print("ERROR: Input/output lists don't match")
	bye
      }
    lfilename(fname)
    if (verbose) print "substracting sky to "//lfilename.reference//" ..."
      if (scale != "none")
       {
       sky_aux = mktemp (tmpdir//"ldithskyskyaux")
       imarith( operand1 = fname,
                    op = "/",
              operand2 = sky,
                result = sky_aux,
                 title = "",
               divzero = 1.,
               hparams = "",
               pixtype = "",
              calctype = "",
               verbose = no,
                 noact = no) 
		 
       fld=scale  		 
       if (scale == "median")	
         fld="midpt" 
       imstatistics(sky_aux//liskycpars.statsec,
                     fields=fld,
		     format=no) | scan(scale1)
		     
       imdel (sky_aux, yes, verify-, >>&"/dev/null")		     
		     
       if (verbose) print " scale factor = "//scale1

       imarith( operand1 = sky,
                    op = "*",
              operand2 = scale1,
                result = sky_aux,
                 title = "",
               divzero = 1.,
               hparams = "",
               pixtype = "",
              calctype = "",
               verbose = no,
                 noact = no) 

       imstatistics(sky_aux//liskycpars.statsec,fields="midpt",format=no) |
	 scan(skymidpt) 

       imarith( operand1 = fname,
                    op = "-",
              operand2 = sky_aux,
                result = imsubsky,
                 title = "",
               divzero = 1.,
               hparams = "",
               pixtype = "",
              calctype = "",
               verbose = no,
                 noact = no) 

       } 
      else if (zero != "none")
       {
       sky_aux = mktemp (tmpdir//"ldithskyskyaux")
       imstatistics(sky//liskycpars.statsec,fields="midpt",format=no) |
	 scan(skymidpt)	 
       imarith( operand1 = fname,
                    op = "-",
              operand2 = sky,
                result = sky_aux,
                 title = "",
               divzero = 0.,
               hparams = "",
               pixtype = "",
              calctype = "",
               verbose = no,
                 noact = no) 
       fld=zero  		 
       if (zero == "median")	
         fld="midpt" 
       imstatistics(sky_aux//liskycpars.statsec,
                     fields=fld,
		     format=no) | scan(scale1)
		     
       if (verbose) print "           zero offset = "//scale1
      
       imarith(operand1 = sky_aux,
                    op = "-",
              operand2 = scale1,
                result = imsubsky,
                 title = "",
               divzero = 0.,
               hparams = "",
               pixtype = "",
              calctype = "",
               verbose = no,
                 noact = no) 
		 
        skymidpt = skymidpt + real(scale1)
	
	### Add a keyword to header containing median value of sky
	hedit(imsubsky,fields = "SKYMIDPT",value = skymidpt,
	   add+,del-,ver-,show-,upd+)
       }          
      else ## no scale && no zero
       { 
       imarith( operand1 = fname,
                    op = "-",
              operand2 = sky,
                result = imsubsky,
                 title = "",
               divzero = 0.,
               hparams = "",
               pixtype = "",
              calctype = "",
               verbose = no,
                 noact = no)
	### Add a keyword to header containing median value of sky
	imstatistics(sky//liskycpars.statsec,fields="midpt",format=no) |
	 scan(skymidpt)	 
	hedit(imsubsky,fields = "SKYMIDPT",value = skymidpt,
	   add+,del-,ver-,show-,upd+)
	}	  
		  
    if ((scale != "none" || zero != "none")) 
      {imdelete (sky_aux,yes,ver-)}
    
   }
   
  # We delete temporary files. 
   imdel ("ldithskyskyaux*",verify=no, >>&"/dev/null")

   delete(inli,yes,ver-,>>&"/dev/null")
   delete(outli,yes,ver-,>>&"/dev/null")


end
