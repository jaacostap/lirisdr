# lgeotran - make geometric distortion correction 
# Author : Miguel Charcos (mcharcos@ll.iac.es)
# Version: 13. Jan. 2004
# Simplified version: not transforming the mask (J. Acosta) Nov 2004
##############################################################################
procedure lgeotran (input,output,intrans)


string	input 		{prompt="Input images"}
string	output 		{prompt="Output images"}
string	intrans		{"default",prompt="geometric distortion correction file name (default|<filename>"}

# Mask parametres
#string  inmask  	{"",prompt="name of input mask file"}
#string  outmask		{"",prompt="name of output corrected mask"}

# geotran parametre configuration
#pset	geotopt		{prompt="geotran parametre configuration"}
string	interpolant	{"spline3",prompt="The  interpolant used for rebinning the image"}
real	strechx		{1,prompt="Streching factor along x-axis "}
real	strechy		{1,prompt="Streching factor along y-axis "}
string	boundary	{"constant",prompt="Boundary extension (nearest,constant,reflect,wrap)"}
real	constant	{0.,prompt="Constant boundary extension"}

# Directories
string  tmpdir  	{")_.tmpdir",prompt="Temporary directory for file conversion"}
string  stddir  	{")_.stddir",prompt="Parametre directory for transformations"}

bool	verbose		{no,prompt="Verbose?"}

string *list1	{prompt="Ignore this parameter(list1)"}


begin

  string 	inli,outli
  string 	fname
  int 		nsc
  int		dimx,dimy,xmin,xmax,ymin,ymax
  string	imk,imkcorrect
  string 	imt,firstim
  string	gtransf
  real		dbx1,dby1


  # expand input image name.
  inli = mktemp(tmpdir//"lgeotraninli")
  sections(input,option="fullname",> inli)

  dbx1 = strechx
  dby1 = strechy
 
  # expand output image name.
  outli = mktemp(tmpdir//"lgeotranoutli")
  sections(output,option="fullname",> outli)
  # We verify if some output image already exist
  list1 = outli
  While (fscan(list1,fname) !=EOF)
    {
    lfileaccess(fname,verbose=no)
    if (lfileaccess.exist)
      {
      beep
      print("")
      print("ERROR: operation would overwrite output image "//fname)
      print("lgeotran aborted")
      print("")
      beep
      bye
      }
    } # end of While (fscan(list1,fname) !=EOF)  
  
print ("imt ",intrans)
  imt = intrans
  # if default options for transform we search files
  if (imt == "default")
    {
    list1 = inli
    nsc = fscan (list1,fname)
    lcorrfile (input = fname,
             fbpmask = lirisdr.bpmdb,
             fbcmask = lirisdr.bcmdb,      
            fgeodist = lirisdr.gdistdb,    
             ftransf = lirisdr.fcdb, 
	      stddir = stddir,
             verbose = verbose) 
    
#    imt = lcorrfile.geodist
    imt = osfn(lirisdr.stddir) // lcorrfile.geodist
    if (imt == "none" || imt == "unknown")
      {
      beep
      print("")
      print("ERROR: default geometric correction file not found")
      print("lgeotran aborted")
      print("")
      beep
      bye
      }
    else
      {if (verbose) print "INFO: default geometric correction file is "//imt}
    } # end of if (imt == "default")
  else if (imt != "")
    {
    if ( access(imt))
      {if (verbose) print("INFO: geometric correction file found")}
    else
      {
      beep
      print("")
      print("ERROR: geometric correction file not found")
      print("lgeotran aborted")
      print("")
      beep
      bye
      }
    } # end of else if (imt == "")
  else # if (imt == "")
    {
    beep
    print("")
    print("ERROR: no geometric correction file introduced")
    print("lgeotran not executed")
    print("")
    beep
    bye
    }
  
  # We verify that format of database transform file is correct 
  # and we check for transform file
  list1=imt
  nsc = fscan(list1)
  if (fscanf(list1,"begin   %s",gtransf) != EOF)
    {if (verbose) print ("transform file: ",gtransf)}
  else
    {
    beep
    print("")
    print("ERROR: input geometric correction file wrong")
    print("lgeotran aborted")
    print("")
    beep
    bye
    }



  # check if mask will be used
  #if (inmask == "") {imk = ""}
  #else {imk = stddir//inmask}

  
  # We correct images using pset geotran parametres  
  # and input correction files
  # The flux per pixel is conserved
  
  ## determine the limits of the image
  list1 = inli
  nsc = fscan(list1,firstim)
  imgets(firstim,"i_naxis1")
  dimx =  int(imgets.value)
  imgets(firstim,"i_naxis2")
  dimy =  int(imgets.value)
  dbx1 = int(dimx * (1.-strechx)/2.)
  dby1 = int(dimy * (1.-strechy)/2.)
  xmin = dbx1 
  xmax = dimx - dbx1
  ymin = dby1
  ymax = dimy - dby1
  
  geotran(input = "@"//osfn(inli),
	output = "@"//osfn(outli),
       database = imt,
       transfor = gtransf,
	geometr = "geometric",
	    xin = INDEF,
	    yin = INDEF,
	 xshift = INDEF,
	 yshift = INDEF,
	   xout = INDEF,
	   yout = INDEF,
	   xmag = INDEF,
	   ymag = INDEF,
	xrotati = INDEF,
	yrotati = INDEF,
	   xmin = xmin,
	   xmax = xmax,
	   ymin = ymin,
	   ymax = ymax,
	 xscale = 1.,
	 yscale = 1.,
	  ncols = INDEF,
	 nlines = INDEF,
	xsample = 1,
	ysample = 1,
	interpo = interpolant,
	boundar = boundary,
	constan = constant,
	fluxcon = yes,
	nxblock = 1100,
	nyblock = 1100,
	verbose = verbose)

  hedit("@"//osfn(outli),"GDISTCOR",1,add+,ver-,upd+,>>& "/dev/null")
  hedit("@"//osfn(outli),"GDISTDB",imt,add+,ver-,upd+,>>& "/dev/null")
 
  if (verbose) {print "geometric distorsion corrected"}
   

  delete (inli,yes,ver-)
  delete (outli,yes,ver-)

  list1 = ""
end
