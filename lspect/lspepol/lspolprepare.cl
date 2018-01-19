# lspolprepare - add informacion to the image header relevant for spectro-polarimetry
# Author : Jose Acosta  (jap@ll.iac.es)
# Version: 01. May. 2007
#          
##############################################################################
procedure lspolprepare(input)
string	input	    {prompt="Input image list"}
bool	slice	    {no,prompt="Slice into polarization stage spectra"} 
string  fslice	    {"",prompt="File containing slice sections"}
string	outslc	    {"",prompt="Prefix for slice sections"}

string	*list1	    {"",prompt="Ignore this parameter (list1)"}

begin

string	mdf1, inline, input1, inli, fname, styp, spsec, apermask_lst,grkey
string  fslice1, outslc1
int	naper, iaper, ord, nref, nslt, naper_mdf
real	xctab[35]
real	y1,y2,sllen,xc,slwdt
string  idtab[35],sttab[35]

## 
  

  input1 = input
  # Open the file containing the raw or the sliced images 
  inli = mktemp(tmpdir//"_lmsprprin")
  sections(input1,option="fullname",>inli)
  if (slice) {
    fslice1 = fslice
    if (!access(fslice1)) 
      {
	print("ERROR: file ",fslice1," does not exist")
	beep; beep; beep
	bye
      }     
    inli = mktemp("_lspwvclinput")
    print("slicing ")	
    lfilename(input1)
    outslc1 = outslc//lfilename.root
    ltrimspol(input1,outslc1,fslice1,outlist=inli,ismask=no)
  } else {
    inli = mktemp("_lspwvclin")
    sections(input1,>inli)
  }  

  list1 = inli
  while(fscan(list1, spsec) != EOF) 
    {
       ## add dispaxis 
       laddwave(spsec,xslitcent=530.)
    }



end
