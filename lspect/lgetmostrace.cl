# lgetmostrace - determine slit boundaries over a flatfield or lamp spectrum
#               Its main usage is to define slitlets in MOS spectroscopy
# Author     : J Acosta
#              13. Nov. 2008
#  
##############################################################################
procedure lgetmostrace(input)

file    input           {prompt="Input image"}
file    output          {prompt="Output file containing the limits"}
file	mdf		{prompt="Mask definition file"}
real    x               {prompt="X position (return)"}
real    y               {prompt="Y position (return)"}
string  key             {prompt="key (return)"}
bool    verbose         {prompt="Verbose ?"}
string *list            {prompt="Ignore this parameter (list)"}
string *list2           {prompt="Ignore this parameter (list2)"}

begin

  string        input1, fout, mdf1, fname, inli
  string	styp,slitid,inline,imgmed,gradpos,gradneg,tmppos,tmpneg
  int		ord,ns
  int		nslt=0
  int		nref=0
  int		ntot
  real		xc,y1,y2,sllen,slwdt,slminlen
  bool		isdataline
  
  mdf1 = mdf

  slminlen = 1100
  
  ## determine number of aperture in the mask from design mask file
  ### from design mask file
  list2 = mdf1
  isdataline = no
  ord = 1
  while (fscan(list2,inline) != EOF)
    {
      print("He leido ",inline)
     if (strstr("Typ",inline) != 0)  {
	  while (fscan(list2,ord,styp,slitid,xc,y1,y2,sllen,slwdt) != EOF)
	    {
	       if (strstr("SLIT",styp) != 0) 
		 {
		   nslt += 1
		   # get the minimum length
		   if (slminlen > sllen) 
		      slminlen = sllen 
		   print("Slit: xc, y1, y2, sllen ",xc,y1,y2,sllen)
		 }
		if (strstr("REF",styp) != 0) 
		 {
		   nref += 1
		   # get the minimum length
		   if (slminlen > sllen) 
		      slminlen = sllen 
		   print("Hole: xc, y1, y2, sllen ",xc,y1,y2,sllen)
		 }
	   } 
     }      
    }

  ntot = nref + nslt
  print("nslt ",nslt) 
  print("minsllen ",slminlen) 
  
   # expand input and output image names.
  input1 = mktemp(tmpdir//"_lgtmstrc0")
  sections(input,>input1)
  
  inli = mktemp(tmpdir//"_lgtmstrcin")
  list = input1
  while(fscan(list,fname) != EOF)
  {
     lcheckfile(fname)
     if (lcheckfile.nimages != 0) 
	{
	 if (lcheckfile.mode_aq != "NORMAL")
           print(fname//"[1]",>>inli)
	 else 
	   {
	     print("ERROR: input format not valid")
	   }
	}   
     else	   
	print(fname,>>inli)  
  }
     
  ## do median filter along spectral axis to avoid hot pixels

  list = inli 
  while (fscan(list,fname) != EOF)
   {
    print("fname ",fname)
 
    imgmed = mktemp(tmpdir//"_lgtmstrmd") 
    median(fname,imgmed,xwin=21,ywin=1)
   
    ## check that dispaxis is correctly written in the header
    hedit(imgmed,"DISPAXIS",dispax,add+,upd+,ver-,>>"/dev/null")
      
    ## obtain gradient images
    gradpos = mktemp("_lgtmstrgdpos")
    gradneg = mktemp("_lgtmstrgdneg")
    gradient (imgmed,gradpos,90)
    gradient (imgmed,gradneg,270)
    tmppos = mktemp("_lgtmstrcpos")
    tmpneg = mktemp("_lgtmstrcneg")

    ## obtain aperture limits
    apfind.nfind= nslt + nref
    apfind.minsep = slminlen
    ## find lower edges
    aptrace (gradpos,intera+,edit+,recent+,resize-,find+,trace+,function="legendre",order=4)
    match ("center", "database/ap"//gradpos, stop-, > tmppos)
    ## find upper edges
    aptrace (gradneg,intera+,edit+,recent+,resize-,find+,trace+,function="legendre",order=4)
    match ("center", "database/ap"//gradneg, stop-, > tmpneg)
  
    ## separate slit and reference holes
    ## determine grism used 
    #imgets(imgname,"")
    ## write file with image sections
    
    
  
  }
end
