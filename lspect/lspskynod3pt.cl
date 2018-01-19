# lspctsky - generate combined substracted sky image from spectral images 
# Author : Miguel Charcos (mcharcos@ll.iac.es)
# Version: 25. Nov. 2003
##############################################################################
procedure lspskynod3pt(input)

string	input		{prompt="Name of input spectral image list"}
string	output		{"",prompt="Output substracted image prefix name"}
string  oflist		{"",prompt="Output list of original and sky substracted images"}
bool	zerobkg  	{no,prompt="Set background to zero?"}

# Combine parametres
#pset	combspsky	{prompt="Combine parametre configuration"}

# Directories
string	tmpdir		{")_.tmpdir",prompt="Temporary directory for file conversion"}

bool	verbose		{no,prompt="Verbose"}
  
  
string *list1	{prompt="Ignore this parameter(list1)"}
string *list2	{prompt="Ignore this parameter(list2)"}
  

begin   
  
  string	inli,inli0, fname,objlist,skylist
  string 	skysub1,skysub2, preobj, prepreobj
  string	ino, outli, ofli, statsec
  string        imobj, imsub1, imsub2, imsubsky
  int		contim
  real		md

  # expand input image name.
  inli0 = mktemp(tmpdir//"_lspsknd3inli")
  sections(input,option="fullname",> inli0)
  
  # check if images contain extensions
  list1 = inli0  
  inli = mktemp(tmpdir//"ldithskyinli")
  while (fscan(list1,fname) != EOF)
    {
      lcheckfile(fname)
      if  (lcheckfile.nimages != 0) 
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
  delete(inli0)
  
  ino = output
  ofli = oflist

    
   #######
   #  The sky subtraction (ABCABC)process is as follows:
   #		   A_skysub[n] = A[n] - (B[n] + C[n-1])/2
   #		   B_skysub[n] = B[n] - (A[n] + C[n])/2 
   #		   C_skysub[n] = C[n] - (B[n] + A[n+1])/2 
   #		   A_skysub[1] = A[1] - B[1]
   #		   C_skysub[N] = C[N] - B[N] 
   #	    Two image lists are generated, one (objlist) containing the 
   #	       spectrum itself , the other (skylist) containing the spectra 
   #	       to be subtracted. 
   #	       - We read an image of the input list, this will go to the 
   #		  list objlist. It will be 
   #	       
   #	       - We suppose that list is correctly and we build 
   #		 the rest of the multirun sequence
   #
   #	       (in the last two steps images of multirun sequence
   #		are introduced in imAli and imBli lists)
   #
   #	       - When lists of multirun sequence built, first element
   #		 of imAli is substraced to first element of imBli, second
   #		 to second, ... until one list finished or output image list
   #		 finished.
   #  
   #######

   # we create objlist and skylist names
      objlist = mktemp(tmpdir//"lspsknd3obj")
      skylist = mktemp(tmpdir//"lspsknd3sky")
      contim = 1
      list1 = inli
      While (fscan(list1,fname) != EOF)
        {
	
	print (fname, >>objlist)
	
	  
	if (contim > 1) 
	  {
	     skysub2 = fname
	  }  
	  
	if (contim > 2) 
	     skysub1 = prepreobj  
	   
	#if (contim > 2 ) 
	#  print ("spc ",fname," ; preobj=",preobj," sub1=",skysub1,"  sub2=",\
	#   skysub2)

	if (contim > 2) 
	    print (skysub1,"  ",skysub2, >>skylist)
	else if (contim == 2) 
	    print (skysub2,"  ",skysub2, >>skylist)    

	if (contim > 1) 
	  prepreobj = preobj
	preobj = fname


	contim = contim + 1
	
	 
	 
        } # end of while fscan(list1,fname) 
  
        print (prepreobj,"  ",prepreobj, >>skylist)
	 

   #######
##   # now perform sky subtraction images of imAli and imBli are substracted
##
      if (ofli != "") {
         if (access(ofli)) 
	   delete(ofli,ver-,>>"dev$null")
      } else {
	 print ("Warning: No output filelist created")  
      }
        
      
      list1 = objlist
      list2 = skylist
      While (fscan (list1,imobj) != EOF && \
	       fscan (list2,imsub1,imsub2) != EOF)
	{
           if (ino != "") 
	     {
	       lfilename(imobj) 
	       imsubsky = ino//lfilename.reference
	     } 
	   else
	     {
	       imsubsky = mktemp(tmpdir//"lspskysbn3")
	     }   
	     
	   if (verbose)
             print (imsubsky," = ",imobj," - (",imsub1," + ",imsub2," )/2 ")
	   
           imcalc( input=imobj//","//imsub1//","//imsub2,
	          output=imsubsky, 
	          equals="im1-(im2+im3)/2.",
		 pixtype="old",
		     verb=verbose)
		     
	if (zerobkg) 
	  {
	     statsec = combspsky.statsec
	     imstatistics(imsubsky//statsec,fields="midpt",format=no) | scan(md)
	     imarith(imsubsky,"-",md,imsubsky)
	  }
		     
	   if (ofli != "") 
	     print (imsubsky, >>ofli)

        }  # end of While (fscan (list1,imobj) != EOF && ...)


  if (verbose)  
    {
    print "sky subtraction finished finished"
    print ""
    }

  # clean up temporary files
#  delete(objlist,ver-)
#  delete(skylist,ver-)
  delete(inli,ver-)


  # clear lists
  list1 = ""
  list2 = ""

end
