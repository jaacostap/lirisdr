# licvgrad - correct vertical gradient in LIRIS images
# Author : Jose Acosta (jap@ll.iac.es)
# Version: 23. Mar. 2005
#        14Nov06 - correction of bug (overwriting the first output image)
##############################################################################
procedure licvgrad(input,output)

string	input		{"",prompt="Name of input images"}
string	output		{"",prompt="Name of output images"}
string  objmask		{"",prompt="Name of input object masks"}
bool	quad		{yes,prompt="Perform correction per quadrant"}
string	ctype		{"surface",enum="surface|halfsurface|line",prompt="Type of correction fitting"}
string	nsamp		{"*",prompt="Sample points to use in background fit"}
int	nxaver		    {51,prompt="Number of points in sample averaging along x-axis"}
int	nyaver	        {5,prompt="Number of points in sample averaging along y-axis"}
string sfitsec     {"",prompt="File name for sections list to be used in the surface fitting for complete detector[surface]"}
string btsfitsec   {"",prompt="File name for sections list to be used in the surface fitting for bottom-half detector[halfsurface]"}
string tpsfitsec   {"",prompt="File name for sections list to be used in the surface fitting for top-half detector[halfsurface]"}
#string lwrows       {"5-512",prompt="Rows to be used in the surface fitting for lower-half detector[halfsurface]"}
#string uprows       {"1-507",prompt="Rows to be used in the surface fitting for upper-half detector[halfsurface]"}
#string rows       {"10-1015",prompt="Rows to be used in the surface fitting for whole detector[surface]"}
#string columns       {"10-1015",prompt="Columns to be used in the surface fitting "}
string function	{"legendre",enum="legendre|chebyshev|spline3|spline1",prompt="Functional form of surface to be fit"}
int	xorder	        {2,prompt="Order of fitting function"}
int	yorder	        {4,prompt="Order of fitting function"}
real	low_reject	{0,prompt="Low sigma reject"}
real 	high_reject	{1,prompt="High sigma reject"}
int	niterate	{3,prompt="Number of iterations"}
bool	keepcounts	{no,prompt="Preserve the count number?"}
string  statsec		{"",prompt="Section to compute image median"}

string *list1	{"",prompt="Ignore this parameter(list1)"}
string *list2	{"",prompt="Ignore this parameter(list2)"}
string *list3	{"",prompt="Ignore this parameter(list3)"}
 
begin  

  string	inli,outli,maskli,infit,fname1,fname2,fname3
  string	sec[4],fisect,fosect,fitdw,fitup,resdw,resup
  string 	gradsamp
  string	imsurf_regtp,imsurf_regbt,imsurf_sectbt,imsurf_secttp
  int		gradnxaver,gradnyaver,gradxorder,gradyorder,opcode,opcode1,naxis1,naxis2
  real		immidpt
  bool		kcnts1,use_mask=no
  
  gradsamp = nsamp
  gradxorder = xorder
  gradyorder = yorder
  kcnts1 = keepcounts
  
  
  # expand input image name.
  inli = mktemp(tmpdir//"_lcvgrdinli")
  sections(input,option="root",> inli)
  
  # expand output image name.
  outli = mktemp(tmpdir//"_lcvgrdoutli")
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

  if (ctype == "halfsurface") {
    opcode = 1
    gradnxaver = abs(nxaver)
    gradnyaver = abs(nyaver)
    ## setting top half
	imsurf_regtp="sections"
    imsurf_secttp=mktemp("_msrfstup")
	if (tpsfitsec != "")
	  imsurf_secttp=tpsfitsec
	else 
	  imsurf_regtp="all"
    ## setting bottom half
	imsurf_regbt="sections"
    imsurf_sectbt=mktemp("_msrfstdw")
	if (btsfitsec != "")
	  imsurf_sectbt=btsfitsec
	else 
	  imsurf_regbt="all"
  } else if (ctype == "surface") {
    opcode = 2
    gradnxaver = abs(nxaver)     
    gradnyaver = abs(nyaver)     
  } else {
    gradnxaver = nxaver
    gradnyaver = nyaver
    if (!quad)
      opcode = 3
    else 
      opcode = 4   
  } 

# determine image section where to work  
  ## opcode fitting mode
  ##  1     halfsurface
  ##  2     surface
  ##  3     line by line
  ##  4     line by line per quadrant
  switch (opcode) {
    case 1:  
      {
	    sec[1] = "[1:1024,1:512]"
	    sec[2] = "[1:1024,513:1024]"
      }		  
    case 4:  
      {
	    sec[1] = "[1:512,1:512]"
	    sec[2] = "[1:512,513:1024]"
	    sec[3] = "[513:1024,1:512]"
	    sec[4] = "[513:1024,513:1024]"
      }		  
    default:	     
  }

		  
## check if bad pixel mask will be used
if (objmask != "")
  {
    use_mask = yes
    maskli = mktemp(tmpdir//"_lcvgrdmaskli")
    sections(objmask,option="root", > maskli)
    list3 = maskli
  }

## start loop over input image list
  list1 = inli
  list2 = outli
 while (fscan(list1,fname1) !=EOF)
   { 
    if (fscan(list2,fname2) != EOF)
      {   
	if (kcnts1) {
	    imstatistics(fname1,fields="midpt",format=no,binwidth=0.01) | scan(immidpt)
	}
	opcode1 = opcode 
	if (use_mask)
	  {
	    if (fscan(list3,fname3) == EOF)
	       goto nomask
	    infit = mktemp("_lcvgrdif")  
	    imcopy(fname1,infit,verb-)   
	    fixpix(infit,fname3,linterp="INDEF",cinterp="INDEF",verb-)
	  } else {
	    infit = fname1
	  }  
        ## check image dimensions for consistency of correction fitting
	imgets(fname1,"i_naxis1")
	naxis1 = int(imget.value)
	imget(fname1,"i_naxis2")
	naxis2 = int(imget.value)	 
	if (naxis1 != 1024 || naxis2 != 1024) { 
	  if (opcode == 1)
	    { 
	      opcode1 = 2
	      print ("WARNING: Image not complete. Force correction fitting to a single surface instead of double")
	    }     
	  if (opcode == 4) {
	      opcode1 = 3
	      print ("WARNING: Image not complete. Force to correction to line by line fitting")
	  }  
	}  

	switch (opcode1) {
	   case 1:   ## surface fitting - one surface for each half-detector
	     {
		  ## bottom half
           print ("  Doing surface fitting separately to each detector half ")
           fitdw = mktemp("_lcvgrdfdw")
           resdw = mktemp("_lcvgrdrdw")
           imsurfit ( input = infit//sec[1],
              output = fitdw,
              xorder = gradxorder,
              yorder = gradyorder,
              type_output = "fit",
              function = function,
              cross_terms = no,
              xmedian = gradnxaver,
              ymedian = gradnyaver,
              median_perce = 50.,
              lower = low_reject,upper = high_reject,ngrow = 1,niter = niterate,
			  regions = imsurf_regbt,
			  sections = imsurf_sectbt,
              div_min = INDEF)     
		   imarith (fname1//sec[1],"-",fitdw,resdw)        
		        
		  ## top half
		  fitup = mktemp("_lcvgrdfp")
		  resup = mktemp("_lcvgrdfp")
          imsurfit ( input = infit//sec[2],
                    output = fitup,
                    xorder = gradxorder,
                    yorder = gradyorder,
               type_output = "fit",
              function = function,
              cross_terms = no,
              xmedian = gradnxaver,
              ymedian = gradnyaver,
              median_perce = 50.,
              lower = low_reject,upper = high_reject,ngrow = 1,niter = niterate,
			  regions = imsurf_regtp,
			  sections = imsurf_secttp,
              div_min = INDEF)
          imarith (fname1//sec[2],"-",fitup,resup)        
		  imcopy (fname1,fname2,ver-)
		  imcopy (resdw,fname2//sec[1],ver-)    
		  imcopy (resup,fname2//sec[2],ver-) 
		  imdel(resdw,ver-,>>&"/dev/null")
		  imdel(resup,ver-,>>&"/dev/null") 
          if (use_mask)
	          {
                  imdel(fitdw,ver-,>>&"/dev/null")   
                  imdel(fitup,ver-,>>&"/dev/null")   
              }

	     }  ## end of case 1

	   case 2:   ## surface fitting - one surface for whole surface
	     {
		   ## single surface
           fitdw = mktemp("_lcvgrdfdw")
           imsurfit ( input = infit,
                     output = fitdw,
                     xorder = gradxorder,
                     yorder = gradyorder,
                type_output = "fit",
                   function = function,
                cross_terms = no,
                    xmedian = gradnxaver,
                    ymedian = gradnyaver,
               median_perce = 50.,
                      lower = low_reject,upper = high_reject,ngrow = 1,niter = niterate,
                    regions = "rows",
                       rows = rows,columns = columns,
                    div_min = INDEF)     

           imarith (fname1,"-",fitdw,fname2)        

           if (use_mask)
              {
                imdel(fitdw,ver-,>>&"/dev/null")   
              }

	     }  ## end of case 2

	   case 3:   ## row per row fitting, no quadrant
	     {
		  fit1d ( input = fname1, 
			     output = fname2,
			       type = "difference",
			       axis = 1,
		    interactive = no,
			     sample = gradsamp,
		       naverage = gradnxaver, 
		       function = "legendre",
			      order = gradxorder,
		     low_reject = low_reject,
		    high_reject = high_reject,
		       niterate = niterate,
			   grow = 0)

	     }  ## end of case 3

	   case 4:   ## row per row fitting by quadrant
	     {
	     if (fname1 != fname2) 
		   imarith (fname1,"*",0,fname2,ver-)
	     fisect = mktemp("_lcvg")
	     fosect = mktemp("_lcvgo")
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
	             naverage = gradnxaver, 
	             function = "legendre",
	        	    order = order,
		       low_reject = low_reject,
		      high_reject = high_reject,
	             niterate = niterate,
	        	     grow = 0)  
		     imcopy(fosect,fname2//sec[i],verb-)
	       }

	     }  ## end of case 4
	     
	}   ## end of switch
	
	
	 if (kcnts1) {
	    print ("adding ",immidpt)
	    imarith (fname2,"+",immidpt,fname2)
	 }
	 
	 hedit(fname2,"VGRADCOR",1,update=yes,add=yes,show=no,verify=no)   
	 hedit(fname2,"VGRDCTYP",ctype,update=yes,add=yes,show=no,verify=no)   
	 hedit(fname2,"VGRDQUAD",quad,update=yes,add=yes,show=no,verify=no)   
	 hedit(fname2,"VGRDNSMP",nsamp,update=yes,add=yes,show=no,verify=no)
	 hedit(fname2,"VGRDNXAV",nxaver,update=yes,add=yes,show=no,verify=no)
	 hedit(fname2,"VGRDNYAV",nyaver,update=yes,add=yes,show=no,verify=no)
	 hedit(fname2,"VGRDFUNC",function,update=yes,add=yes,show=no,verify=no)
	 hedit(fname2,"VGRDXORD",gradxorder,update=yes,add=yes,show=no,verify=no)
	 hedit(fname2,"VGRDYORD",gradyorder,update=yes,add=yes,show=no,verify=no)
	 hedit(fname2,"VGRDLREJ",low_reject,update=yes,add=yes,show=no,verify=no)
	 hedit(fname2,"VGRDHREJ",high_reject,update=yes,add=yes,show=no,verify=no)
	 hedit(fname2,"VGRDNITE",niterate,update=yes,add=yes,show=no,verify=no)
	 if (kcnts1) 
	    hedit(fname2,"VGRADKCT",1,update=yes,add=yes,show=no,verify=no)   
	 else 
	    hedit(fname2,"VGRADKCT",0,update=yes,add=yes,show=no,verify=no)   
	 	    	  
     }
   }

   goto cleanup

nomask: 
   print("Error: mask not found")
   bye


cleanup:   
      
   ## clean up
   delete(inli,ver-)
   delete(outli,ver-)
   if (opcode == 4) imdel(fisect,ver-,>>&"/dev/null")
   imdel("_lcvg*",ver-,>>&"/dev/null")
   
      
end  
