# laddwave - add approximate wavelength calibration 
# Author : Jose Acosta  (jap@ll.iac.es)
# Version: 01. May. 2007
#          
##############################################################################
procedure laddwave(input)
string	input		{prompt="List of comparison lamp spectra"}
real 	xslitcent	{INDEF,prompt="Position of the slit center"}
string	specformat	{"",prompt="Grism used"}

string *list1	{prompt="Ignore this parameter"}


begin	
  string 	inli, im
  string	grkey, grnam
  real		cdelt, crval, xoff
  real		xslitcent1
  int		crpix
  
  # expand input image list
  inli = mktemp("_lmswvclinput")	
  sections(input,option="fullname", >inli)
  
  ## start loop over slitlets
  
  xslitcent1 = xslitcent
  
  list1 = inli
  
  if (xslitcent != INDEF) 
    xslitcent1 = xslitcent
  else 
    xslitcent1 = 530.  

  while (fscan(list1, im) != EOF) 
    {

        imgets(im,"CRPIX1")
        xoff = int(imgets.value)
	imgets(im,"lirgrnam")
	grnam = imgets.value

        if ((strstr("lr_zj",grnam) != 0) || (strstr("lrzj8",grnam) != 0))
	   grkey = "lr_zj"
        if ((strstr("lr_hk",grnam) != 0) || (strstr("lrhk",grnam) != 0))
	   grkey = "lr_hk"
	if (strstr("mr_k",grnam) != 0)
           grkey = "mr_k"
	if (strstr("psgrj",grnam) != 0 || strstr("hrj",grnam) != 0 || strstr("hr_j",grnam) != 0)
           grkey = "hr_j"
	if (strstr("psgrh",grnam) != 0 || strstr("hrh",grnam) != 0 || strstr("hr_h",grnam) != 0)
           grkey = "hr_h"
	if (strstr("psgrk",grnam) != 0 || strstr("hrk",grnam) != 0 || strstr("hr_k",grnam) != 0)
           grkey = "hr_k"

	lcentwave(grkey,xslitcent1)

        cdelt = lcentwave.cdelt
	crval = lcentwave.crval
	crpix = lcentwave.crpix + xoff
		  
        hedit(im,"DISPAXIS",1,add+,upd+,ver-,> "dev$null")
        hedit(im,"CRVAL1",crval,add+,upd+,ver-,> "dev$null")
	hedit(im,"CD1_1",cdelt,add-,upd+,ver-,> "dev$null")
	hedit(im,"CDELT1",cdelt,add+,upd+,ver-,> "dev$null")
	hedit(im,"CRPIX1",crpix,add+,upd+,ver-,> "dev$null")

    } 

specformat = grkey
    
delete(inli,>> "dev$null")  
  
end  
  
  
 
