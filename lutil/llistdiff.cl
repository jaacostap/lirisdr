# llistdiff - calculates post-pre integration of an image list 
#	       of liris and ingrid instruments
# Author     : Miguel Charcos (mcharcos@ll.iac.es)
# Last Change: 25. Nov. 2003
##############################################################################
procedure llistdiff (input)

string	input		{prompt="Input image list"}
string	output		{prompt="Output image list name"}
string	pname		{"",prompt="Prefix name of output images"}
bool	original	{prompt="Return if almost one image was not been changed"}
bool	verbose		{no,prompt="Verbose ?"}
string	tmpdir		{")_.tmpdir",prompt="temporary directory for file conversion"}


string *list1	{prompt="Ignore this parameter(list1)"}

begin 

  string 	in,out
  string	inli, outli, inname, outname
  string	prefname
  
  out = output
  in  = input

  if (access(out))
    {
    beep
    print("")
    print("ERROR: operation would override output file "//out)
    print("llistdiff aborted")
    print("")
    beep
    bye
    }
    
  inli = mktemp(tmpdir//"llistdiff")
  sections(in,option="fullname",> inli)
  
  prefname = pname
    
    
  original = no
  list1 = inli
  while (fscan(list1, inname) != EOF)
    {
    # check file subtraction and format
    lcheckfile(inname,verbose=no)

    # check if data file needs to be post-pre subtracted
    if ( ! lcheckfile.subtract )
      { 
      if ( lcheckfile.mode_aq == "PRE_POST" )
        {
        # calculate post-pre image
        
	lfilename(inname)
	outname = lfilename.root
        if (verbose) print ("calculating post-pre for image "//lfilename.root//" ...")
	if (prefname != "") outname = prefname//outname
	else outname = mktemp("llistdiffout")//outname
	
	# get title of image
        #imgets (image=inname//"[0]", param="i_title")
        #title = imgets.value
        imarith (operand1=inname//"[2]", \
                 op="-", \
                 operand2=inname//"[1]", \
                 result=outname, \
                 #title="Post-Pre of "//title, \
                 #title="Post-Pre of "//lfilename.reference, \
                 divzero=0., \
                 hparams="EXPTIME", \
                 pixtype="1", \
                 calctype="", \
                 verbose=no, \
                 noact=no)
        }
      else if ( lcheckfile.mode_aq == "DIFF" )
        {
	lfilename(inname)
	outname = lfilename.path//lfilename.root//"[1]"
	print ("outname ",outname)
	if (lfilename.extension != "") outname = outname//"."//lfilename.extension
        original = yes  
	}
      else if ( lcheckfile.mode_aq == "DIFF_PRE" )
        {
	lfilename(inname)
	outname = lfilename.path//lfilename.root//"[1]"
	if (lfilename.extension != "") outname = outname//"."//lfilename.extension
	original = yes  
	}
      } # End of if ( ! lcheckfile.subtract )
    else # if ( lcheckfile.subtract )
      {
      if ( lcheckfile.mode_aq == "DIFF" )
        {
	lfilename(inname)
	if (lcheckfile.nimages ==0) 
	    outname = lfilename.path//lfilename.root
	else     
	    outname = lfilename.path//lfilename.root//"[1]"
	print ("outname ",outname)
	if (lfilename.extension != "") outname = outname//"."//lfilename.extension
        original = yes  
	}
      else 
       {   
        original = yes   
        outname = inname
        if (verbose) print ("image "//lfilename.root//" is substracted")
       }
      } 
  
  print (outname, >> out)
  if (verbose) print (inname//" image checked")
  } # end of while (fscan(list1, inname) != EOF && ... )
  
  delete(inli,yes,ver-)  
  
  list1 = ""
end    
