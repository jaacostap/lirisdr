# ldisplay - display liris images in all formats
# Author     : Miguel Charcos (mcharcos@ll.iac.es)
# Last Change: 20. Jan. 2004
##############################################################################
procedure ldisplay(image,frame)

file 	image 		{prompt="image to be displayed"}
int	frame		{prompt="frame to be written into"}

string	dispmode	{"DIFF",enum="DIFF|PRE|POST",prompt="Display mode (DIFF|PRE|POST)"}
# display parametres
pset	displayopt	{prompt="Display parametre configuration"}

string	tmpdir		{")_.tmpdir",prompt="temporary directory"}


begin

  file		imdisplay
  string	title
  string	dmode
  bool		imdisperase
  
  
  dmode = dispmode
  
  lcheckfile(image)
  
  if (lcheckfile.instrument != "liris")
    {
    beep
    print("")
    print("ERROR: no LIRIS input image")
    print("ldisplay aborted")
    print("")
    beep
    bye
    }
  
  imdisperase = no
  if (lcheckfile.subtract)
    {imdisplay = image}
  else #  if (!lcheckfile.substract)
    { 
    if ( lcheckfile.mode_aq == "PRE_POST" )
      {
      if (dmode == "DIFF")
	{
        # Create new name for substracted image using input reference name
     	lfilename (image)
     	imdisplay = mktemp(tmpdir//"ldisplayimdisp")//"_"//lfilename.reference
 
     	# get title of image
     	imgets (image=image//"[0]", param="i_title")
     	title = imgets.value
     	imarith (operand1=image//"[2]", \
     		 op="-", \
     		 operand2=image//"[1]", \
     		 result=imdisplay, \
     		 title="Post-Pre of "//title, \
     		 divzero=0., \
     		 hparams="EXPTIME", \
     		 pixtype="1", \
     		 calctype="", \
     		 verbose=no, \
     		 noact=no)
 
     	imdisperase = yes
        } # End of if (dmode == "DIFF")
      else if (dmode == "PRE")
	{imdisplay = image//"[1]"} 
      else if (dmode == "POST")
	{imdisplay = image//"[2]"}
      else 
	{
        beep
        print("")
        print("ERROR: no display mode recognised")
        print("ldisplay aborted")
        print("")
        beep
        bye
        }  
      } # end of if ( lcheckfile.mode_aq == "PRE_POST" )
 
    else if ( lcheckfile.mode_aq == "DIFF" )
      {
      if (dmode == "DIFF")
        {imdisplay = image//"[1]"}
      else if (dmode == "PRE")
        {
        beep
        print("")
        print("ERROR: image format does not allow PRE display mode")
        print("ldisplay aborted")
        print("")
        beep
        bye
        }
      else if (dmode == "POST")
        {
        beep
        print("")
        print("ERROR: image format does not allow POST display mode")
        print("ldisplay aborted")
        print("")
        beep
        bye
        }
      else 
	{
        beep
        print("")
        print("ERROR: no display mode recognised")
        print("ldisplay aborted")
        print("")
        beep
        bye
        }  
      } # End of if ( lcheckfile.mode_aq == "DIFF" )
    else if ( lcheckfile.mode_aq == "DIFF_PRE" )
      {
      if (dmode == "DIFF")
        {imdisplay = image//"[1]"}
      else if (dmode == "PRE")
        {imdisplay = image//"[2]"}
      else if (dmode == "POST")
        {
        # Create new name for substracted image using input reference name
        lfilename (image)
        imdisplay = mktemp(tmpdir//"ldisplayimdisp")//"_"//lfilename.reference
 
        # get title of image
        imgets (image=image//"[0]", param="i_title")
        title = imgets.value
        imarith (operand1=image//"[2]", \
        	 op="+", \
        	 operand2=image//"[1]", \
        	 result=imdisplay, \
        	 title="Post-Pre of "//title, \
        	 divzero=0., \
        	 hparams="EXPTIME", \
        	 pixtype="1", \
        	 calctype="", \
        	 verbose=no, \
        	 noact=no)
 
        imdisperase = yes
        } # End of if (dmode == "POST")"
      else 
	{
        beep
        print("")
        print("ERROR: no display mode recognised")
        print("ldisplay aborted")
        print("")
        beep
        bye
        }  
      } # End of if ( lcheckfile.mode_aq == "DIFF_PRE" )
    else
      {
      beep
      print("")
      print("ERROR: image adquisition mode no recognised")
      print("ldisplay aborted")
      print("")
      beep
      bye
      }
    } # end of else [if (lcheckfile.substract)]
  
  if (displayopt.zrange)
    {  
    display (image = imdisplay,
    	     frame = frame,
    	    bpmask = displayopt.bpmask,
    	 bpdisplay = displayopt.bpdisplay,
    	  bpcolors = displayopt.bpcolors,
    	   overlay = displayopt.overlay,
    	   ocolors = displayopt.ocolors,
    	     erase = displayopt.erase,
      border_erase = displayopt.border_erase,
      select_frame = displayopt.select_frame,
    	    repeat = displayopt.repeat,
    	      fill = displayopt.fill,
    	    zscale = displayopt.zscale,
    	  contrast = displayopt.contrast,
    	    zrange = displayopt.zrange,
    	     zmask = displayopt.zmask,
    	   nsample = displayopt.nsample,
    	   xcenter = displayopt.xcenter,
    	   ycenter = displayopt.ycenter,
    	     xsize = displayopt.xsize,
    	     ysize = displayopt.ysize,
    	      xmag = displayopt.xmag,
    	      ymag = displayopt.ymag,
    	     order = displayopt.order,
    	    ztrans = displayopt.ztrans,
    	   lutfile = displayopt.lutfile)
    
    }
  else
    {  
    display (image = imdisplay,
    	     frame = frame,
    	    bpmask = displayopt.bpmask,
    	 bpdisplay = displayopt.bpdisplay,
    	  bpcolors = displayopt.bpcolors,
    	   overlay = displayopt.overlay,
    	   ocolors = displayopt.ocolors,
    	     erase = displayopt.erase,
      border_erase = displayopt.border_erase,
      select_frame = displayopt.select_frame,
    	    repeat = displayopt.repeat,
    	      fill = displayopt.fill,
    	    zscale = displayopt.zscale,
    	  contrast = displayopt.contrast,
    	    zrange = displayopt.zrange,
    	     zmask = displayopt.zmask,
    	   nsample = displayopt.nsample,
    	   xcenter = displayopt.xcenter,
    	   ycenter = displayopt.ycenter,
    	     xsize = displayopt.xsize,
    	     ysize = displayopt.ysize,
    	      xmag = displayopt.xmag,
    	      ymag = displayopt.ymag,
    	     order = displayopt.order,
    		z1 = displayopt.z1,
    		z2 = displayopt.z2,
    	    ztrans = displayopt.ztrans,
    	   lutfile = displayopt.lutfile)
    }
  if (imdisperase)
    {imdelete(imdisplay,no,ver-)}

end
