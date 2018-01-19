# lmoscombflat - extract and spectra from all slitlets
# Author : Jose Acosta  (jap@ll.iac.es)
# Version: 09. Feb. 2009
#          06 Apr. 2006  (double sky subtraction included)
##############################################################################
procedure lmoscombflat(input,output,mdf)

string input	{"",prompt="Flat-field images (multi-spec format)"}
string output	{"",prompt="Fit to flat-field "}
string mdf	{"",prompt="Mask definition file"} 
string reject	{"none",enum="none|ccdclip|minmax|sigclip|pclip",prompt="Rejection algorithm"}
string combim	{"",prompt="Combined flat-field spectrum"}
string combine  {"median",enum="median|average",prompt="Type of combine operation"}
string expmask	{"",prompt="Exposure mask"}
string sigmask	{"",prompt="Exposure mask"}
bool   incl_ref {no,prompt="Include reference holes?"}

string	*list	{"",prompt="Ignore this parameter (list)"}
string	*list2	{"",prompt="Ignore this parameter (list2)"}

begin

string	input1,mdf1,fname,slitid,styp,apermask_lst,inline,output1,combim1,imtmp
string	offtmp,norm1,combflat,reject1,flist,flist_scale,resptmp,expmsk,sgim1,imap1,comb1
real	xctab[35],xcmin,xcmax,xc,y1,y2,sllen,slwdt,fdumm,midpt
int	xoff[35],ord,iaper,naper_im
int	nslt=0
int	nref=0
bool	incl_ref1

  input1 = input
  mdf1 = mdf
  norm1 = output
  reject1 = reject
  incl_ref1 = incl_ref
  expmsk = expmask
  sgim1 = sigmask
  combim1 = combim
  comb1 = combine
  
  xcmax = 0 
  xcmin = 9999
  
  ## check if output file exists 
  
  ## determine number of apertures in the mask reading
  ### from design mask file
  list = mdf1
  ord = 1
  apermask_lst = mktemp("_lmsmkrsp")
  while (fscan(list,inline) != EOF)
    {
      if (strstr("Typ",inline) != 0)  {
          while (fscan(list,ord,styp,slitid,xc,y1,y2,sllen,slwdt) != EOF)
            {
               if (strstr("SLIT",styp) != 0) 
                 {
                   nslt += 1
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
  list = apermask_lst 
  offtmp = mktemp("_lmsmkrspoff")
  iaper = 0
  while (fscan(list,y1,y2,sllen,xc,styp,slitid) != EOF)
    {
       iaper += 1
       xctab[iaper] = xc
       xoff[iaper]  = int(xcmax - xc+0.5)
       print(int(xcmax-xctab[iaper]+0.5),"  0",>>offtmp)
       print("xc xoff",xc,xoff[iaper])
    }

## usar imcombine con los desplazamientos leidos del fichero de diseño 
## de las mascaras
  
  flist = mktemp("_lmscmbfllst")
  flist_scale = mktemp("_lmscmbfllst_scl")
  imgets(input1,'i_naxis2')
  naper_im = int(imgets.value)
  imtmp = mktemp("_lmscmbflimt")
  imcopy(input1,imtmp)
  ## 
  for (i=1; i<= naper_im; i += 1) 
    {
      ## compute scale 
      imgets(input1,"APNUM"//i)
      print(imgets.value) | scan(fdumm,fdumm,y1,y2)
      imap1 = mktemp("_lmscmbflim")
      imarith(input1//"[*,"//i//"]","/",(y2-y1),imap1)
      imcopy(imap1,imtmp//"[*,"//i//"]")
      print(imap1,>>flist)
      ## obtain statistics using common regions of all spectra
      imstatistics(imap1//"["//int(xctab[i]-xcmin+1)//":"//int(xctab[i]+1024-xcmax)//"]",\ 
        fields="midpt",format=no) | scan(midpt)
      print (1./midpt,>>flist_scale)
    }

  if (combim1 != "") 
     combflat = combim1 
  else 
     combflat = mktemp("_lmscmbfltcmb")
  imcombine(imtmp,combflat,expmasks=expmsk,sigma=sgim1,combine=comb1,reject=reject1,\
     scale="@"//flist_scale,zero="none",offset=offtmp,project=yes)
  
## now build response function based on combined flat-field
  fit1d(combflat,norm1,type="fit",axis=1,interactive=yes,sample="*",naverage=-3,function="spline3",\
      order=15,low_rejec=3.,high_reject=3.,niterate=2)   
   
## clean up
  if (combim1 == "")
     imdel(combflat,ver-,>>"/dev/null")
  imdel("@"//flist,ver-,>>"/dev/null")
  delete(offtmp,ver-,>>"/dev/null")
  delete(flist,ver-,>>"/dev/null")
  delete(flist_scale,ver-,>>"/dev/null")
  delete(apermask_lst,ver-,>>"/dev/null")
  

end
