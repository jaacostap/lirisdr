# llistdiff - calculates post-pre integration of an image list 
#	       of liris and ingrid instruments
# Author     : Miguel Charcos (mcharcos@ll.iac.es)
# Last Change: 25. Nov. 2003
##############################################################################
procedure llistdiff (input,output)

string	input		{prompt="Input image list"}
string	output	{prompt="Output image list name"}

bool	verbose		{"no",prompt="Verbose ?"}

begin 

  string 	ini,ino
  string	inli, outli, inname, outname
  string	prefname
  
  ino = output
  ini  = input

  if (access(ino))
    {
    beep
    print("")
    print("ERROR: operation would override output file "//ino)
    print("lframedif aborted")
    print("")
    beep
    bye
    }
  
  # check file subtraction and format
  lcheckfile(ini,verbose=no)

  # check if data file needs to be post-pre subtracted
  if ( ! lcheckfile.subtract )
    { 
    if ( lcheckfile.mode_aq == "PRE_POST" )
  	{
  	# calculate post-pre image
  	
      # get title of image
  	lhgets (image=inname//"[0]", param="i_title")
  	title = imgets.value
  	imarith (operand1=ini//"[2]", \
  		   op="-", \
  		   operand2=ini//"[1]", \
  		   result=ino, \
  		   title="Post-Pre of "//title, \
  		   divzero=0., \
  		   hparams="EXPTIME", \
  		   pixtype="1", \
  		   calctype="", \
  		   verbose=no, \
  		   noact=no)
  	}
    else if ( lcheckfile.mode_aq == "DIFF" )
  	{
      imcopy (ini//"[1]", ino,ver-)
      }
    else if ( lcheckfile.mode_aq == "DIFF_PRE" )
  	{
	imcopy (ini//"[1]", ino,ver-)
      }
    } # End of if ( ! lcheckfile.subtract )
  
  else # if ( lcheckfile.subtract )
    {   
    if (verbose) print ("image "//ini//" is substracted")
    } 
  
  if (verbose) print (ini//" image checked")
  
end    
