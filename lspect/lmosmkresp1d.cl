# lmosmkresp1d - extract and spectra from all slitlets
# Author : Jose Acosta  (jap@ll.iac.es)
# Version: 09. Feb. 2009
#          06 Apr. 2006  (double sky subtraction included)
##############################################################################
procedure lmosmkresp1d(input,output,combflat,mdf)

string input	  {"",prompt="Flat-field images (Multi-spec format)"}
string output	  {"",prompt="Response function images "}
string combflat   {"",prompt="Combined flat-field"}
string mdf	  {"",prompt="Mask definition file"} 
string reject	  {"none",enum="none|ccdclip",prompt="Rejection algorithm"}
bool   incl_ref   {no,prompt="Include reference holes?"}
bool   ctelluric  {no,prompt="Set to 1 the telluric absorption bands?"}

string	*list1	{"",prompt="Ignore this parameter (list1)"}
string	*list2	{"",prompt="Ignore this parameter (list2)"}

begin

string	input1,mdf1,fname,slitid,styp,apermask_lst,inline,outline,output1,combflat1
string	offtmp,norm1,reject1,flist,resptmp,expmsk
real	xctab[35],xcmin,xcmax,xc,y1,y2,sllen,slwdt,fdumm
int	xoff[35],ord,iaper,naper_im
int	nslt=0
int	nref=0
int	naper_mdf=0
bool	incl_ref1
  
  input1 = input
  mdf1 = mdf
  output1 = output
  combflat1 = combflat
  incl_ref1 = incl_ref

  xcmax = 0 
  xcmin = 9999

  
  ## determine number of apertures in the mask reading
  ### from design mask file
  list1 = mdf1
  ord = 1
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
		   if (xc > xcmax) 
		       xcmax = xc
		   if (xc < xcmin)
		       xcmin = xc      
                 }
                if (strstr("REF",styp) != 0) 
                 {
                   nref += 1
		   if (incl_ref1) {
		      naper_mdf += 1
                      print(y1,y2,sllen,xc,styp,"  ",slitid,>>apermask_lst)
		      if (xc > xcmax) 
			  xcmax = xc
		      if (xc < xcmin)
			  xcmin = xc  
		   }        
                 }
           } 
     }      
    }
  
  ## order apertures
  tsort(apermask_lst,"c1")
  list1 = apermask_lst 
  offtmp = mktemp("_lmsmkrspoff")
  iaper = 0
  while (fscan(list1,y1,y2,sllen,xc,styp,slitid) != EOF)
    {
       iaper += 1
       xctab[iaper] = xc
       xoff[iaper]  = int(xcmax - xc+0.5)
       print(int(xcmax-xctab[iaper]+0.5),"  0",>>offtmp)
       print("xc xoff: ",xc,xoff[iaper])
    }


  # Open the file containing the skysubtracted images 
  inli = mktemp(tmpdir//"lsmsmkrsp1din")
  outli = mktemp(tmpdir//"lsmsmkrsp1dout")
  sections(input1,option="fullname",>inli)
  sections(output1,option="fullname",>outli)


## now create response for each aperture using measurement of 
  resptmp = mktemp("_lmsrsptmp")
  iaper = 0
  list1 = inli
  list2 = outli
  while (fscan(list1,inline) != EOF)
   {
      if (fscan(list2,outline) != EOF)
        { 
           imcopy(inline,outline,ver-)
	   imgets(inline,'i_naxis2')
	   naper_im = int(imgets.value)
	   ## check if numbers of image and mdf apertures match
           if (naper_im != naper_mdf) 
	      goto cont
	   for (iaper=1; iaper<= naper_im; iaper += 1) 
             {
	        norm1 = mktemp("_lmsmkrspd1dnrm1")
        	imgets(inline,"APNUM"//iaper)
        	print(imgets.value) | scan(fdumm,fdumm,y1,y2)
		imarith(combflat1//"["//1+xoff[iaper]//":"//1024+xoff[iaper]//"]",\
		   "*",(y2-y1),norm1)
        	imarith(inline//"[*,"//iaper//"]", "/", norm1, resptmp)
		imcopy(resptmp,outline//"[*,"//iaper//"]") 
		imdel(resptmp,ver-,>>"/dev/null")
	     } 
	} 
      cont:	
	      
   }


end
