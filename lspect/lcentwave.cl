# laddwave - add approximate wavelength calibration 
# Author : Jose Acosta  (jap@ll.iac.es)
# Version: 19. Feb. 2009
#          
##############################################################################
procedure lcentwave(grism,slitxc)
string	grism	{"",enum="lr_zj|lr_hk|mr_k|hr_j|hr_h|hr_k",prompt="List of comparison lamp spectra"}
real	slitxc	{512.,prompt="Position of slit center along x-axis"}
real	cdelt 	{0.,prompt="Dispersion (AA/pix) [output]"}
real	crval	{0.,prompt="Value at reference pixel [output]"}
real	crpix	{512.,prompt="Reference pixel "}    


begin	
  string	grkey
  real		slitxc1, crval0,crpix0,crpix1
  real		xoff=0.
  
  grkey = grism
  
  slitxc1 = slitxc
  crpix1 = crpix
  
  
  
	if (strstr("lr_zj",grkey) != 0) 
          {
 	     ## slit center at xc=530, feature 11490.7 @ 438.8
             xoff = 530. - slitxc1
	     cdelt = 6.06
	     crval0 = 11490.7
	     crpix0 = 438.8 - xoff
	  }
	if (strstr("lr_hk",grkey) != 0)
	  {
	     ## slit center at xc=518.7, feature 17919.61 @ 398.45
             xoff = 518.7 - slitxc1
	     cdelt = 9.71
	     crval0 = 17919.6 
	     crpix0 = 398.45 - xoff
	  }      
	if (strstr("mr_k",grkey) != 0)
	  {
             xoff = 512. - slitxc1
	     cdelt = 4.6
	     crval0 = 21738. 
	     crpix0 = 530 - xoff
  	  }
	        
	if (strstr("hr_j",grkey) != 0)
	  {
 	     ## slit center at xc=530, feature 12705.76 @ 570.54
             xoff = 532. - slitxc1
	     cdelt = 1.81
	     crval0 = 12705.76 
	     crpix0 = 561.53 - xoff
  	  }

	if (strstr("hr_k",grkey) != 0)
	  {
             xoff = 530 - slitxc1
	     cdelt = 3.55
	     crval0 = 22350. 
	     crpix0 = 512 - xoff
  	  }
	  
	if (strstr("hr_h",grkey) != 0)
	  {
 	     ## slit center at xc=530, feature 16524.42 @ 530.36
             xoff = 530. - slitxc1 
	     cdelt = 2.57
	     crval0 = 16524. 
	     crpix0 = 530.36 - xoff
  	  }

	 crval = crval0 + cdelt * (crpix1-crpix0) 
	 
	 
	 crpix = crpix1
 
      
end  
  
