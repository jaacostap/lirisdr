# lspnodcomb_cyc - combine spectra taken following sequence ABBA cases but
#        combine spectra by cycles
# Author : Jose Acosta  (jap@ll.iac.es)
# Version: 09. Oct. 2005
#          06 Apr. 2006  (double sky subtraction included)
##############################################################################
procedure lspnodcomb_cyc(input,output,ncyc)
string	input	  {prompt="List of sky subtracted images to be combined"}
string	output	  {prompt="Output image"}
string	outlst	  {prompt="Output lists of combined images"}
int     ncyc      {1,min=1,prompt="Number of AB frames per cycle"}
string  ishift	  {"crosscor",prompt="File containing shifts to be applied (file|wcs|crosscor)"}
string  flatcor	  {"",prompt="flat-field correction"}
string  trspec	  {"",prompt="name of spectral correction file"}
string  database  {"database",prompt="Directory containing spectral correction"}
bool	doublesky {yes,prompt="Perfom double sky subtraction?"}
string  maskim	  {"",prompt="Name of bad pixel mask"}


string *list1	{prompt="Ignore this parameter"}

begin

  string inli, fname, imsubli, imBli,output1,outcyc
  string ishift1,trspec1,flatcor1,database1
  int	 imcont, contcyc, contA, contB, icyc
  bool	 dblsky1
  
  trspec1 = trspec
  flatcor1 = flatcor
  database1 = database
  dblsky1 = doublesky
  ishift1 = ishift
  
# we create imAli and imBli names
 imsubli = mktemp(tmpdir//"_lspectrimsbli")
 
 ## check output name
 if (output != "")
    output1 = output
 else 
    output1 = "spcombcyc"    
 
  # expand input image name.
  inli = mktemp(tmpdir//"_lcycskyinli")
  sections(input,option="fullname",> inli)
  # We verify if some output image already exist
  list1 = inli
  imcont = 0
  contA = 0
  contB = 0
  icyc = 0 

  While (fscan(list1,fname) !=EOF)
    {
       # number of multirun sequence images is calculated 
       # and first image added to corresponding list
       limnumber(fname)
       contcyc = 2*limnumber.imaxnum*ncyc
       if (imcont == contcyc) {
            icyc = icyc + 1
	    ## now call lspnodcomb 
	    print("Using ",contA," images corresponding to pos A")
	    print("Using ",contB," images corresponding to pos B")
	    print("Call lspnodcomb for cyc ",icyc)
	    type(imsubli)
	    outcyc= output1//"_"//icyc
	    print("Output image ",outcyc)
	    lspnodcomb("@"//imsubli,outcyc,ishift=ishift1,trspec=trspec1, \
	       flatcor=flatcor1,database=database1,doublesky=dblsky1)
	    ## reset lists and counter
            imcont = 0 
	    contA = 0
	    contB = 0
	    delete (imsubli,ver-,>& "dev$null")
	  }
	if (limnumber.spect == 1) 
	  {
	  print (fname,>>imsubli)
	  contA = contA + 1
	  }
	else if (limnumber.spect == 2)
	  {
	  print (fname,>>imsubli)
	  contB = contB + 1
	  }
	
	  imcont = imcont+1
	
    } # end of While (nsc != EOF && cont<=contmax)

end
