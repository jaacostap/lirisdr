	# lsmkghostmask - predicts ghosts position in a flat-field image and create a mask
#               Its main usage is to create ghost mask in MOS spectroscopy
# Author     : J Acosta
#              22. Feb. 2009
#  
##############################################################################
procedure lmosghosttable(mdf,grism,template)

file    mdf             {prompt="Mask definition file"}
string	grism		{"hr_j",enum="hr_j|hr_h|hr_k",prompt="Grism name"}
file	template	{"",prompt="Template image (only needed to create mask)"}
file    mask		{"default",prompt="Ghost Mask name .pl[FITS]"}
int	maskvalue	{3,min=0,prompt="Value defining ghost position in mask"}
file    table		{"default",prompt="Ghost position table .dat[ASCII]"}

bool	verbose		{no,prompt="Verbose?"}

string *list            {prompt="Ignore this parameter (list)"}

begin

  string    inline,mdf1,mask1,table1,allapermask_lst,inbpim,fname
  string    slitid,styp,grkey, tabpredict
  int	    ord,nref,nslt,ntot,naper_tab,iaper,grind,maskval1
  real	    y1,y2,sllen,slwdt,xc,yctab[35],xctab[35],sllentab[35],slwdttab[35]
  string    slitidtab[35],styptab[35]
  real	    symmX[3],symmY[3],xcghost[35],ycghost[35],xbox1,xbox2,ybox1,ybox2
  bool	    verb1

  mdf1 = mdf
  mask1 = mask
  verb1 = verbose
  fname = template
  maskval1 = maskvalue

  ## determine number of apertures in the mask reading
  ### from mask design file (MDF)
  list = mdf1
  ord = 1
  nref = 0 ; nslt=0
  allapermask_lst = mktemp("_lfndmsaaperslt")
  while (fscan(list,inline) != EOF)
    {
      if (strstr("Typ",inline) != 0)  {
          while (fscan(list,ord,styp,slitid,xc,y1,y2,sllen,slwdt) != EOF)
            {
               if (strstr("SLIT",styp) != 0) 
                 {
                   nslt += 1
                 }
                if (strstr("REF",styp) != 0) 
                 {
                   nref += 1
                 }
                print(y1,y2,sllen,slwdt,xc,styp,"  ",slitid,>>allapermask_lst)
           } 
     }      
    }


  ntot = nref + nslt
  if (verb1) 
    print("No. of slits and ref. holes= ",nslt,nref) 

  tsort(allapermask_lst,"c1")
  list = allapermask_lst 
  iaper = 0
  while (fscan(list,y1,y2,sllen,slwdt,xc,styp,slitid) != EOF)
    {
       iaper += 1
       yctab[iaper] = (y1+y2)/2
       xctab[iaper] = xc
       styptab[iaper] = styp
       sllentab[iaper] = sllen
       slwdttab[iaper] = slwdt
       slitidtab[iaper] = slitid 
    }
  
  naper_tab = iaper

## define symmetry points
  symmX[1] = 496.; symmX[2]=455.  ; symmX[3]=447.
  symmY[1] = 501.; symmY[2]=475.5 ; symmY[3]=488.

      
  grind = 0
  grkey = grism
  if (strstr("psgrj",grkey) != 0 || strstr("hrj",grkey) != 0 || strstr("hr_j",grkey) != 0)
    grind = 1
  if (strstr("psgrh",grkey) != 0 || strstr("hrh",grkey) != 0 || strstr("hr_h",grkey) != 0) 
    grind = 2
  if (strstr("psgrk",grkey) != 0 || strstr("hrk",grkey) != 0 || strstr("hr_k",grkey) != 0) 
    grind = 3		




  # compute expected position	
  tabpredict= mktemp("_lmsghttpre")
  inbpim = mktemp("_lmsghttbp")
  print ("## Ghost positions for mask ",mdf, >>tabpredict)
  for (iaper=1; iaper <= naper_tab; iaper += 1)
    {
      xcghost[iaper] = 2*symmX[grind] - xctab[iaper]
      ycghost[iaper] = 2*symmY[grind] - yctab[iaper]
      print(slitidtab[iaper],"  ",xcghost[iaper],ycghost[iaper],sllentab[iaper], >>tabpredict)
      xbox1 = max(1,int(xcghost[iaper]-slwdttab[iaper]/2.+0.5))
      xbox2 = min(1024,int(xcghost[iaper]+slwdttab[iaper]/2.+0.5))
      ybox1 = max(1,int(ycghost[iaper]-sllentab[iaper]/2.+0.5))	   
      ybox2 = min(1024,int(ycghost[iaper]+sllentab[iaper]/2.+0.5))
      print(xbox1,xbox2,ybox1,ybox2)
      print(xbox1,xbox2,ybox1,ybox2,>> inbpim)
    } 
	

   ## now display ghost mask if required
   badpiximage(inbpim,fname,mask1//".pl",goodvalue=0,badvalue=maskval1)



   bye
   
err_distfile: 
	 print("Format of distortion file is not correct") 
	 bye
	   
end
