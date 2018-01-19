# lshiftwcs - generate file with shift between images of a file
# Author : Miguel Charcos (mcharcos@ll.iac.es)
# Version: 1. Jul. 2003
##############################################################################
procedure lshiftwcs(input,output)

string	input	{prompt="List of input images"}
string	output	{prompt="Name of output file containing shifts"}
string	format	{prompt="Formats of input images (disable)"}
string  refer	{"90",enum="0|90|180|270",prompt="Angle between CCD and wcs axes"}
bool	verbose	{no,prompt="Verbose"}
bool 	surfcom	{no,prompt="Common area among imput files?"}
bool    chkcom  {no,prompt="Check if there is common area?"} 
bool	addimnam {no,prompt="Add image name to file containing shifts"}
int 	accuracy{2,prompt="Number of decimal digits"}
string 	xyshift {"both",enum="both|xonly|yonly",prompt="Compute offsets along both axes"}
int 	xmin	{1,prompt="Minimal absice of common area"}
int 	ymin	{1,prompt="Minimal ordinate of common area"}
int	xmax	{1024,prompt="Maximal absice of common area"}
int 	ymax	{1024,prompt="Maximal ordinate of common area"}
string	tmpdir	{")_.tmpdir",prompt="Temporary directory for file conversion"}
#bool	view	{prompt="View comun area of images"}

string *list1	{prompt="Ignore this parameter(list1)"}

begin
  string	ini,ino
  string	fname,fname1,xyoff
  file		tmpl,tf1 
  real		imscale
  real		x,y,xr,yr,ref_ra,ref_dec,tel_ra,tel_dec
  real		xoff,yoff,xoff_ref,yoff_ref
  real		pa,du,dv,du_ref,dv_ref,dra,ddec,accu,rdiv
  real		xs,ys,xd,yd
  int		x1,x2,y1,y2
  bool		first,addim1


  xyoff = substr(xyshift, 1, 1)
  surfcom = yes
  # scale in arcsec/pixel
  imscale = lirisdr.scale
  
  addim1 = addimnam
  
  # Control if we test the first image
  first = yes
  ini = input
  
  # Create list file
  tf1 = output
  delete(tf1,yes,verify=no, >>& "/dev/null")
  
  # expand input image names.
  tmpl = mktemp("tmp$_lsiftwcstmpl")
  sections(ini,option="fullname",> tmpl)
  list1 = tmpl

  type (tmpl)  

  While ( fscan(list1,fname1) != EOF )
    {
    lcheckfile(fname1)
    if (lcheckfile.nimages == 0) 
      fname = fname1
    else 
      fname = fname1//"[1]"
      
    # find position telescope was pointing at
    #imgets (image=fname, param="CAT-RA")
    imgets (image=fname, param="RA")
    tel_ra = real(imgets.value)
    #imgets (image=fname, param="CAT-DEC")
    imgets (image=fname, param="DEC")
    tel_dec = real(imgets.value)
    imgets (image=fname, param="XAPNOM")
    xoff = -real(imgets.value)
    imgets (image=fname, param="YAPNOM")
    yoff = -real(imgets.value)
    imgets (image=fname, param="XAPOFF")
    xoff = xoff  - real(imgets.value)
    imgets (image=fname, param="YAPOFF")
    yoff = yoff  - real(imgets.value)
    
        
    # conversion factor degrees to radian: PI/180 = 0.017453293
    # conversion factor degrees to hours: 1/15
    tel_ra = 15.* tel_ra

    if ( first )
      {
      xmin = 1
      imgets (image=fname, param="i_naxis1")
      xmax = int(imgets.value)
      ymin = 1
      imgets (image=fname, param="i_naxis2")
      ymax = int(imgets.value)
      
      imgets (image=fname, param="ROTSKYPA")
      pa = real(imgets.value)*3.14/180
      
      # store position telescope was pointing at as reference
      ref_ra = tel_ra
      ref_dec = tel_dec
      xoff_ref = xoff
      yoff_ref = yoff
      
      if (verbose)
        print ("RA de referencia: ",ref_ra,"DEC de referencia: ",ref_dec)
      
      # set smart track error budget to zero
      xd = 0
      yd = 0
      if (addim1)
	   print(fname1," 0. 0.", >> tf1)
      else
      	   print("0. 0.", >> tf1)
      first = no
      }
    else #if (!first)
      {
      if (verbose)
        {
           print ("Coordinates for frame ",fname)
           print ("RA: ",tel_ra,"DEC: ",tel_dec)
        }
	
      # Determine shift
      dra  = (tel_ra - ref_ra)*cos(ref_dec*3.14/180)
      ddec = (tel_dec - ref_dec)
      du   = sin(pa)*ddec - cos(pa)*dra 
      dv   = -cos(pa)*ddec - sin(pa)*dra
      
      # This position correspond for u=-y and v=-x)
      if (refer == "0" || refer == "180")
        {
        x = - dv*3600/imscale - (yoff-yoff_ref)*3600/imscale
        y = - du*3600/imscale - (xoff-xoff_ref)*3600/imscale
        }
       else if (refer == "90" || refer == "270")
        {
        x = du*3600/imscale + (xoff-xoff_ref)*3600/imscale
        y = - dv*3600/imscale - (yoff-yoff_ref)*3600/imscale
        }
	
      # check limits
      if ( x >= 0 && x > xmin ) xmin = x
      if ( x < 0  && 1024+x < xmax ) xmax = 1024+x
      if ( y >= 0 && y > ymin ) ymin = y
      if ( y < 0  && 1024+y < ymax ) ymax = 1024+y
      #print ("After check x ",x,"; xmin ",xmin,"; xmax ",xmax)
	
      # test if the images have a common surface
      if ( xmin >= xmax || ymin >= ymax )
        {
        xmin = 0.
        ymin = 0.
        xmax = 0.
        ymax = 0.
        surfcom = no
	if (chkcom)
	   break
        }
      
      # round to three decimal places
      accu = accuracy
      rdiv = 10.**accu
      xs = real (nint (x * rdiv)) / rdiv
      ys = real (nint (y * rdiv)) / rdiv
 
      if (verbose)
        print("Auto       : x="//xs//" y="//ys)
      
      switch ( xyoff )
        {
        case 'b':
          {
	    if (addim1)
	       print(fname1," ",xs//" "//ys, >> tf1)
	    else    
	       print(xs//" "//ys, >> tf1)
	  }
	case 'x':
          {
	    if (addim1)
	       print(fname1," ",xs//" "//0, >> tf1)            
	    else    
               print(xs//" "//0, >> tf1)
	       	  }
	case 'y':
          {
	    if (addim1)
	       print(fname1," ",0//" "//ys, >> tf1)            
	    else    
               print(0//" "//ys, >> tf1)
	  }
	}  
	
      } # end of else of if (first) 
    } # end while ( fscan(list1,fname) != EOF )
   
  
       
  delete(tmpl,yes,verify=no)
  
  list1 = ""
    
end
