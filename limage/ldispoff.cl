# ldispoff - Display dithered images to obtain offset interactively
# Author : Jose Acosta (jap@ll.iac.es)
# Version: 22. Jun. 2011
# Modified by J. Acosta Jun 2011 to avoid presenting all images
# in manual mode. Only one the first exposure after changing of dithern point
# will be marked.
##############################################################################
procedure ldispoff (input, outstars)

string 	input		{prompt="List of input images"}
string	outstars	{prompt="File of position stars in the reference image"}
string 	outshift	{"",prompt="Shift file  result of reference star"}
string 	sky	     	{"",prompt="Sky image for visualisation"}
string	shiftf		{"",prompt="File containing image shifts"}
bool	skpnear		{yes,prompt="Skip contiguous near frames (yes) or show all frames (no)?"}
real	xmin		{INDEF,prompt="Xmin of the common area"}
real	ymin		{INDEF,prompt="Ymin of the common area"}
real	xmax		{INDEF,prompt="Xmax of the common area"}
real	ymax		{INDEF,prompt="Ymax of the common area"}
bool	zscale		{no,prompt="display range of greylevels near median?"}
bool	zrange 	        {no,prompt="display full image intensity range?"}
int     z1              {prompt="minimum greylevel to be displayed"}
int     z2              {prompt="maximum greylevel to be displayed"}
string  ztrans          {"linear",prompt="greylevel transformation (linear|log|none|user)"}

string	tmpdir		{")_.tmpdir",prompt="Temporary directory"}
int 	checkbox	{0,prompt="Box where would be point in other images"}
bool   	verbose	     	{yes,prompt="Verbose output?"}
			
string *list1	{prompt="Ignore this parameter(list1)"}
string *list2	{prompt="Ignore this parameter(list2)"}
string *list3	{prompt="Ignore this parameter(list3)"}

begin
  
  
  string	ini,isi,shiftaux
  string	fname,dispimg
  string 	tfstar,tf2,tmpl
  string	key
  real		x,y,xr,yr,xs,ys,xs0,ys0,xslast,yslast,xsofflast,ysofflast,xref,yref
  real		toloff,xstar,ystar,xminbox,xmaxbox,yminbox,ymaxbox
  int		dimx,dimy, xoffmax, yoffmax,ptsz		
  int		nst,nsc,nframesir,istar
  bool		subsky,searchshift,first,multi,delshiftaux,skipframe
  bool	        markcbox=no
  # --------------------------------------------------------------------
  # Verifications
  # --------------------------------------------------------------------
  if (verbose)
    {
    print ""
    print "verification of variables"
    }
    
  ini = mktemp("_ldspffini")
  sections(input,>>ini)
      
  if ( access(shiftf) ) 
    {
     delshiftaux = no
     shiftaux=shiftf
    }
  else 
  ## in case that no initial shift file is specified set to 0,0
    {
     delshiftaux = yes
     shiftaux = mktemp(tmpdir//"_ldspffsshiftaux")
     if (verbose) {print"INFO: no input shift file introduced"}
     list1 = ini
     while (fscan(list1, fname) != EOF)
      {print("0 0",>>shiftaux)}
    }
  
  # check if input sky image exists
  if (sky != "")
    {
     limgaccess(sky, verbose=no)
     if ( limgaccess.exists )
       {
        subsky = yes
        isi = sky
        if (verbose) {print "INFO: "//sky//"image sky found"}
       }
     else 
       {
        subsky = no
        if (verbose) {print "WARNING: "//sky//" image sky did not be found"}
       }  
    }
  else
    {
     subsky = no
     if (verbose) {print "INFO: No image sky introduced"}
    }
  
  # determine if a common region is specified, in such case 
  #  the offsets will be checked against the size of the common box
  if (xmin != INDEF && ymin != INDEF && xmax != INDEF && ymax != INDEF)
    {
    if (verbose) 
      {print("INFO: Comon area is ["//xmin//":"//xmax//","//ymin//":"//ymax//"]"
	}
    markcbox = yes
    xoffmax = xmax - xmin + 1
    yoffmax = ymax - ymin + 1
    }
  else 
    {
    markcbox = no 
    if (verbose) {print "INFO: No visualisation of the comon area"}
    }
  
  if (outshift == "")
    {
    if (verbose) {print "INFO: No shift image calculated"}
    searchshift = no
    }
  else if (access(outshift))
    {
    beep
    print("")
    print("ERROR: operation would override output outshift file "//outshift)
    print("ldispoff aborted")
    print("")
    beep
    bye
    }
  else
    {
    if (verbose) {print "INFO: Shift image calculation using reference star"}
    searchshift = yes
    tf2 = outshift
    }
  
  if (access(outstars))
    {
    beep
    print("")
    print("ERROR: operation would override output outstars file "//outstars)
    print("ldispoff aborted")
    print("")
    beep
    bye
    }
  else {tfstar = outstars}
  
  if (verbose)
    {
    print ("variables verified")
    print ""
    }
  # --------------------------------------------------------------------
  # End of verifications
  # --------------------------------------------------------------------

  # --------------------------------------------------------------------
  #  Finding reference stars interactively with the user
  # --------------------------------------------------------------------
  
  # Work through list of substracted pre read images 
  toloff = 4.
  first = yes
  list1 = ini
  list2 = shiftaux
  while (fscan(list1, fname) != EOF)
   { 
    #check if we should subtract a user defined sky image
    if (subsky)
     {
      dispimg =  mktemp (tmpdir//"_ldspffdispimg")
      print ("subtracting input sky image "//isi//" from display image "//fname//" ...")
      imarith (operand1 = fname,
        	 op = "-",
        	 operand2 = isi,
        	 result = dispimg,
        	 title = "",
        	 divzero = 0.,
        	 hparams = "",
        	 pixtype = "",
        	 calctype = "",
        	 verbose = verbose,
        	 noact = no)
     }
    else ## (!subsky)
     {
      dispimg=fname
     }
    
    imgets(image=fname,param="i_naxis1")
    dimx = int(imgets.value)
    imgets(image=fname,param="i_naxis2")
    dimy = int(imgets.value)

    
    # Number of reference stars
    nst = 0
    skipframe = no
      
    if ( !first )
      {
	nsc=fscan(list2,xs,ys)

        xs = xs - xs0
        ys = ys - ys0 


        ## display image only if the difference with previous position is larger than
        ## a certain value
        if (abs(xs-xslast) > toloff || abs(ys-yslast) > toloff) {

        # the image has to be displayed
        display(dispimg,1,zscale=zscale,zrange=zrange,z1=z1,z2=z2,ztrans=ztrans)
        
        if ( markcbox )
          {
	    xminbox = xmin - xs
	    xmaxbox = xmax - xs
	    yminbox = ymin - ys
	    ymaxbox = ymax - ys

	    if (xminbox <=0) {xminbox = 1}
	    if (yminbox <=0) {yminbox = 1}
	    if (xmaxbox >dimx) {xmaxbox = dimx}
	    if (ymaxbox >dimy) {ymaxbox = dimy}

            x = xminbox + (xmaxbox - xminbox) / 2.
            y = yminbox + (ymaxbox - yminbox) / 2.
            print(int(x)//" "//int(y)) | tvmark (frame=1,\
                  coords="STDIN",\
                  mark = "rectangle",\
                  lengths = int(xmaxbox - xminbox)//" "//(ymaxbox-yminbox)/(xmaxbox-xminbox),\
                  color = 205,\
                  interactive = no )
          }
	x = xref - xs - xsofflast
	y = yref - ys - ysofflast
	print(int(x)//" "//int(y)) | tvmark (frame=1,\
             coords="STDIN",\
             mark = "rectangle",\
             lengths = checkbox//" "//1,\
             color = 205,\
             interactive = no )
        print(int(xref)//" "//int(yref)) | tvmark (frame=1,\
             coords="STDIN",\
             mark = "cross",\
             color = 205,\
             interactive = no )

	list3 = tfstar
        istar = 0
	While (fscan(list3,xstar,ystar) != EOF)
	   {
	      x = xstar - xs - xsofflast
	      y = ystar - ys - ysofflast
	      if (istar > 0) 
               {
                 print(int(x)//" "//int(y)) | tvmark (frame=1,\
                    coords="STDIN",\
                    mark = "circle",\
                    radii = checkbox/2,\
                    color = 205,\
                    interactive = no )
               }
	   }

 	key = ""
        print ""
        print " *** please mark main reference star with 'm' or discard frame with 'd'"
	#print "                       'I' to abort"
	while ( !skipframe )
           {
	      lmarkstar(input=dispimg, verbose=yes)
              key = lmarkstar.key
              xr = lmarkstar.x
              yr = lmarkstar.y
              switch (key)
              {
                 case 'm':
                   {
 	              xsofflast = xref-xr-xs
	              ysofflast = yref-yr-ys
                      xslast = xref - xr
                      yslast = yref - yr
	              if (searchshift)
                        printf("%s %d  %d\n",dispimg, (xref-xr+0.5),(yref-yr+0.5), >> tf2)
                      break
                   }
                case 'd': 
                   {
                      printf("Discarding frame ",dispimg)
                      skipframe = yes
                   }
                case 'I': 
                   {
                      print("Aborting ")
                      bye
                   }                  
                 default: 
                   beep
              }
           }
      }else {	
          if (searchshift)
             printf("%s %d  %d\n",dispimg, xslast,yslast, >> tf2)
        }

      }         
    else
      {
       ### case first 
       # the image has to be displayed
       display(dispimg,1,zscale=zscale,zrange=zrange,z1=z1,z2=z2,ztrans=ztrans)

       nsc=fscan(list2,xs0,ys0)
       if ( markcbox )
         {
           x = xmin + (xmax - xmin) / 2.
           y = ymin + (ymax - ymin) / 2.
           print(int(x)//" "//int(y)) | tvmark (frame=1,\
          	coords="STDIN",\
          	mark = "rectangle",\
          	lengths = xoffmax//" "//(yoffmax*1./xoffmax),\
          	color = 205,\
          	interactive = no )
         }
	  
       # print usage information  
       print ""
       print " *** You are marking stars in the reference image"
       print " *** The first marked star should be in all images"
       print " *** Press: "
       print "           'm': to mark a star "
       print "           'd': to discard this frame "
       print "           'q': to quit and go to next frame if present"
	
       key = ""
       nst = 0
       while ( !skipframe )
        {
          lmarkstar(input=dispimg, verbose=yes)
          key = lmarkstar.key
          switch (key)
          {
           case 'm': 
            {           
             xr = lmarkstar.x
             yr = lmarkstar.y
	     xsofflast = 0.
	     ysofflast = 0.
	     print(xr," ",yr,>>tfstar)
	     nst += 1
             if (nst == 1) 
              {
               ptsz = 5
               xref = xr
               yref = yr
               xslast = 0.
               yslast = 0.
              }
             else 
              {
               ptsz = 3
              }   
	     print(int(xr+0.5)//" "//int(yr+0.5)) | tvmark (frame=1,\
                coords="STDIN",\
                mark = "cross",\
                color = 205,\
                pointsize=ptsz,
                interactive = no )
	    }
           case 'd':
            {
             skipframe = yes
            }
           case 'q':
            {
	     if (searchshift) 
               print(dispimg,"   0   0",>>tf2)
             first = no
             break
            }   
           default:
             beep
          }
	}
      ### end case first
      } 


   }  

  list1 = ""
  list2 = ""
  list3 = ""
  
end
