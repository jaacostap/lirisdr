# licvgrad - correct vertical gradient in LIRIS images
# Author : Jose Acosta (jap@ll.iac.es)
# Version: 23. Mar. 2005
#        14Nov06 - correction of bug (overwriting the first output image)
##############################################################################
procedure licvgrad(input,output)

string	input		{prompt="Name of input images"}
string	output		{prompt="Name of output images"}
bool	quad		{yes,prompt="Perform correction per quadrant"}
bool	ctype		{"surface",enum="surface|line",prompt"Type of correction fitting"}
string	nsamp		{"*",prompt="Sample points to use in background fit"}
int	naver		{-51,prompt="Number of points in sample averaging"}
int	order	        {2,prompt="Order of fitting function"}
real	low_reject	{0,prompt="Low sigma reject"}
real 	high_reject	{1,prompt="High sigma reject"}
int	niterate	{3,prompt="Number of iterations"}
bool	keepcounts	{no,prompt="Preserve the count number?"}
string  statsec		{"",prompt="Section to compute image median"}

string *list1	{prompt="Ignore this parameter(list1)"}
string *list2	{prompt="Ignore this parameter(list2)"}
  
begin  

  string	inli,outli,fname1,fname2
  string	sec[4],fisect,fosect
  string 	gradsamp
  int		gradnaver,gradnorder
  real		immidpt
  bool		kcnts1
  
  gradsamp = nsamp
  gradnaver = naver
  gradnorder = order
  kcnts1 = keepcounts
  
  
  # expand input image name.
  inli = mktemp(tmpdir//"ldithskyinli")
  sections(input,option="root",> inli)
  
  # expand output image name.
  outli = mktemp(tmpdir//"ldithskyoutli")
  sections(output,option="root",> outli)
##  # We verify if some output image already exist
##  list1 = outli
##  While (fscan(list1,fname1) !=EOF)
##    {
##    lfileaccess(fname1,verbose=no)
##    if (lfileaccess.exist)
##      {
##      beep
##      print("")
##      print("ERROR: operation would overwrite output image "//fname1)
##      print("licvgrad aborted")
##      print("")
##      beep
##      bye
##      }
##    } # end of While (fscan(list1,fname1) !=EOF)


  if (quad) 
    {
       sec[1] = "[1:512,1:512]"
       sec[2] = "[1:512,513:1024]"
       sec[3] = "[513:1024,1:512]"
       sec[4] = "[513:1024,513:1024]"
    }

## start loop over input image list
  list1 = inli
  list2 = outli
 while (fscan(list1,fname1) !=EOF)
   { 
    if (fscan(list2,fname2) != EOF)
      {   
	if (kcnts1) {
	    imstatistics(fname1,fields="midpt",format=no) | scan(immidpt)
	} 
	if (quad) 
	  {

	     if (fname1 != fname2) 
		imarith (fname1,"*",0,fname2,ver-)

	     fisect = mktemp("lcvg")
	     fosect = mktemp("lcvgo")

             lfilename(fname1)

	     for (i=1; i<=4; i+= 1)
	       {
		 imdel(fisect,ver-,>>&"/dev/null")
		 imdel(fosect,ver-,>>&"/dev/null")

		 imcopy(lfilename.root//sec[i],fisect,verb-)

		 fit1d (input = fisect, 
	        	output = fosect,
	        	  type = "difference",
	        	  axis = 1,
		   interactive = no,
	        	sample = gradsamp,
	              naverage = gradnaver, 
	              function = "legendre",
	        	 order = order,
		    low_reject = low_reject,
		   high_reject = high_reject,
	              niterate = niterate,
	        	  grow = 0)  

		 imcopy(fosect,fname2//sec[i],verb-)

	       }
	   }
	 else 
	   {
	     fit1d ( input = fname1, 
		    output = fname2,
		      type = "difference",
		      axis = 1,
	       interactive = no,
		    sample = gradsamp,
		  naverage = gradnaver, 
		  function = "legendre",
		     order = order,
		low_reject = low_reject,
	       high_reject = high_reject,
		  niterate = niterate,
		      grow = 0)

	    }
	 if (kcnts1) {
	    print ("adding ",immidpt)
	    imarith (fname2,"+",immidpt,fname2)
	 }   	  
     }
   }
   
   hedit(fname2,"VGRADCOR",1,update=yes,add=yes,show=no,verify=no)   
   if (kcnts1) 
      hedit(fname2,"VGRADKCT",1,update=yes,add=yes,show=no,verify=no)   
   else 
      hedit(fname2,"VGRADKCT",0,update=yes,add=yes,show=no,verify=no)   
      
   ## clean up
   delete(inli,ver-)
   delete(outli,ver-)
   if (quad) imdel(fisect,ver-)
   imdel("lcvg*",ver-,>>&"/dev/null")
      
end  
