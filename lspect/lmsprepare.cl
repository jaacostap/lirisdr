# lmsprepare - add informacion 
# Author : Jose Acosta  (jap@ll.iac.es)
# Version: 01. May. 2007
#          
##############################################################################
procedure lmsprepare(input,mdf)
string	input	    {prompt="Input arc exposure"}
string  mdf	    {"",prompt="Mask definition file"} 

string	*list1	    {"",prompt="Ignore this parameter (list1)"}

begin

string	mdf1, inline, input1, inli, fname, styp, slitid, apermask_lst,grkey
int	naper, iaper, ord, nref, nslt, naper_mdf
real	xctab[35]
real	y1,y2,sllen,xc,slwdt
string  idtab[35],sttab[35]

## 
  mdf1 = mdf
  nslt = 0
  nref = 0
  naper_mdf = 0

  ## determine number of apertures in the mask reading
  ### from design mask file
  list1 = mdf1
  apermask_lst = mktemp("_lmsmkrsp")
  while (fscan(list1,inline) != EOF)
    {
      if (strstr("Typ",inline) != 0)  {
          while (fscan(list1,ord,styp,slitid,xc,y1,y2,sllen,slwdt) != EOF)
            {
               if (strstr("SLIT",styp) != 0) 
                 {
                   nslt += 1
		   naper_mdf += 1
        	   print(y1,y2,sllen,xc,styp,"  ",slitid,>>apermask_lst)
                 }
                if (strstr("REF",styp) != 0) 
                 {
                   nref += 1
		   naper_mdf += 1
                   print(y1,y2,sllen,xc,styp,"  ",slitid,>>apermask_lst)
                 }
           } 
     }      
    }
  
  ## order apertures
  tsort(apermask_lst,"c1")
  list1 = apermask_lst 
  iaper = 0
  while (fscan(list1,y1,y2,sllen,xc,styp,slitid) != EOF)
    {
       iaper += 1
       xctab[iaper] = xc
       idtab[iaper] = slitid
       sttab[iaper] = styp
    }

  input1 = input
  # Open the file containing the skysubtracted images 
  inli = mktemp(tmpdir//"_lmsprprin")
  sections(input1,option="fullname",>inli)

  list1 = inli
  while(fscan(list1, inline) != EOF) 
    {
       ## add dispaxis 
       hedit(inline,'DISPAXIS',1,add+,upd+,ver-)
       imgets(inline,'i_naxis2')
       naper = int(imgets.value)
       for (iaper=1; iaper <= naper; iaper+= 1)
         {
	   hedit(inline,'MDXC'//iaper,xctab[iaper],add+,upd+,ver-)
	   hedit(inline,'MDID'//iaper,idtab[iaper],add+,upd+,ver-)
	   hedit(inline,'MDSTYP'//iaper,sttab[iaper],add+,upd+,ver-)
	   imgets(inline,'LIRGRNAM')
	   grkey = imgets.value
           ## based on xc and grism used add approximate wavelength calib
	   #lcentwave(grkey,xctab[iaper])
	 }
    }



end
