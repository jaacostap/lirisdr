# lsmkghostmask - detect ghosts in a flat-field image and create a mask
#               Its main usage is to create ghost mask in MOS spectroscopy
# Author     : J Acosta
#              22. Feb. 2009
#  
##############################################################################
procedure lmosghostmask(input,mask)

file    input           {prompt="Input image, generally an spectroscopic flat"}
file    mask		{prompt="Ghost Mask name (two files generated .pl[FITS]+.dat[ASCII])"}
string	reftype		{"flat",enum="flat|throughslit|mdf",prompt="Type of reference image"}
file	geomtrans	{"default",prompt="Geometric distortion file"}
file    mdf             {prompt="Mask definition file"}
file    resim           {prompt="Output image containing residuals after smoothing"}
int	xmed		{11,prompt="Size of median filter along spectral axis"}
int     xgrow           {1,min=0,prompt="Border around slit edges (along X-axis)"}
int     ygrow           {1,min=0,prompt="Border around slit edges (along Y-axis)"}
int	maskvalue	{3,min=0,prompt="Value defining ghost position in mask"}
real	maxdist		{15.,prompt="Maximum distance for allowed match"}
bool	showreg		{yes,prompt="Show apertures overlaid on image display?"}
bool	verbose		{no,prompt="Verbose?"}

string *list            {prompt="Ignore this parameter (list)"}
string *list2            {prompt="Ignore this parameter (list2)"}

begin
 
  string    input1, fname, mask1, outreg1,imfilt1, inli, resim1, reftp1
  string    geotrans1,gtrans_name,intrans1,otrans1,inline
  int       xmed1,iaper,ord,nref,nslt,ntot,naper_tab,grind,ighfnd,maskval1,nsc,ngfnd
  real	    y1,y2,sllen,slminlen,slwdt,xc,yc,yctab[35],xctab[35],sllentab[35],slwdttab[35]
  real	    symmX[3],symmY[3],xcghost[35],ycghost[35],diffx_md,diffy_md,xbox1,xbox2,ybox1,ybox2
  real	    xcfnd[60],ycfnd[60],maxnorm1,xdist,ydist,rdist
  bool	    verb1,showreg1 
  
  int 	    xgrow1,ygrow1
  
  struct    inline1
  
  string    grlist[3]
  
  string    allapermask_lst,mdf1,styp,slitid,slitidtab[35],styptab[35]
  string    stypfnd[60]
  string    grname, ghostcat, tabpredict, tabmatch
  
  input1 = input
  resim1 = resim
  reftp1 = reftype
  mask1 = mask
  xmed1 = xmed
  mdf1 = mdf
  verb1 = verbose
  showreg1 = showreg
  maskval1 = maskvalue
  xgrow1 = xgrow
  ygrow1 = ygrow
 
  maxnorm1 = maxdist
## define symmetry points
  grlist[1] = "psgrj" ; grlist[2]="psgrh" ; grlist[3]="psgrk"
  symmX[1] = 496.; symmX[2]=455.  ; symmX[3]=447.
  symmY[1] = 501.; symmY[2]=475.5 ; symmY[3]=488.

## look for geometrical distortion file 
   geotrans1 = geomtran
   if ((geotrans1 == "default") && (reftp1 != "throughslit"))
    {
      lcorrfile (input=input1,
             fbpmask = lirisdr.bpmdb,
             fbcmask = lirisdr.bcmdb,      
            fgeodist = lirisdr.gdistdb,    
             ftransf = lirisdr.fcdb, 
             verbose = verbose)	
	     
      geotrans1 = osfn(lirisdr.stddir) // lcorrfile.geodist
      
      if (geotrans1 == "none" || geotrans1 == "unknown")
	{
	  beep
	  print("")
	  print("ERROR: default geometric correction file not found")
	  print("lmosghostmask aborted")
	  print("")
	  beep
	  bye
	}
      else
	{ if (verb1) print "INFO: default geometric correction file is "//geotrans1}
#      } # end of if (geotrans1 == "none" || geotrans1 == "unknown")       	     
    }
    

# check that relevant files exists

  ## several ways to obtain ghost position:
  ## 1- from  a mdf file
  ## 2- from a flat-field image (well constrained y pos)
  ## 3- directly from a through slit image (well constrained y+x pos)
  
  ## determine number of apertures in the mask reading
  ### from mask design file (MDF)
  list = mdf1
  ord = 1
  nref = 0 ; nslt=0
  slminlen = 999
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
                # get the minimum length
                if (slminlen > sllen) 
                   slminlen = sllen 
                print(y1,y2,sllen,slwdt,xc,styp,"  ",slitid,>>allapermask_lst)
           } 
     }      
    }


  ntot = nref + nslt
  if (verb1) 
    print("No. of slits and ref. holes= ",nslt,nref) 
  if (verb1) 
    print("Minimum slit length ",slminlen) 

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
   # in principle this program works only for a single image
  
  inli = mktemp(tmpdir//"_fndmsaperin")
  lcheckfile (input1)
  lfilename (input1)
  if (lcheckfile.nimages != 0) 
  {
     if (lcheckfile.mode_aq != "NORMAL")
	print(lfilename.root//"[1]",>>inli)
     else 
       {
	 print("ERROR: Not  valid input image")
       }
  }   
  else	 
     print(lfilename.root,>>inli)  

  
      
  list = inli 
  while (fscan(list,fname) != EOF)
   {
      ## get grism 
      ## determine symmetry point  
      imgets(fname,"LIRGRNAM")
      grname = imgets.value
      if (grname == 'psgrj')
        grind = 1
      if (grname == 'psgrh') 
        grind = 2
      if (grname == 'psgrk') 
        grind = 3		

      imfilt1 = mktemp("_lsmkghstm")
      if (resim1 == "") 
         resim1 = mktemp("_lsmkghstmr")
      ghostcat = mktemp("_lmsghmskcat")
      ## do median filter along spectral axis to avoid hot pixels, but not too large to 
      ### avoid confusion betweeen distorted slitlets
      median(fname,imfilt1,xmed1,1,verb+)
      imarith(fname,"-",imfilt1,resim1)
      limgaccess(resim1)
      ## find ghost traces using findghost
      print ("!",osfn("lspect$"),"mask_pos/findghost.sh ",limgaccess.real_name," ",ghostcat) \
          | cl
	  
      ## A PARTIR DE ESTA LISTA SE SELECCIONARAN SOLO AQUELLAS APERTURAS PROXIMAS A LAS ESPERADAS	  
      list2 = ghostcat//".mask"
      ighfnd = 0
      while (fscan(list2,styp,xc,yc,slwdt,sllen) != EOF) {
         ighfnd += 1
	 xcfnd[ighfnd] = xc
	 ycfnd[ighfnd] = yc
	 stypfnd[ighfnd] = styp
      }	  
      ngfnd = ighfnd
      
      # compute expected position	
      tabpredict= mktemp("_lmsghttpre")
      for (iaper=1; iaper <= naper_tab; iaper += 1)
        {
	  xcghost[iaper] = 2*symmX[grind] - xctab[iaper]
	  ycghost[iaper] = 2*symmY[grind] - yctab[iaper]
	  print(slitidtab[iaper],"  ",xcghost[iaper],ycghost[iaper],>>tabpredict)	   
	} 
	
      ## match tables to find and average shift
      tabmatch = mktemp("_lmsghttmatch")
      tmatch(tabpredict,ghostcat//".mask",tabmatch,match1="c2 c3",match2="c2 c3",maxnorm=maxnorm1, \
                 incol1="c2,c3",incol2="c2,c3")
      tcalc(tabmatch,"diffx","c2_1-c2_2")
      tcalc(tabmatch,"diffy","c3_1-c3_2")
      tstat(tabmatch,"diffx")
      diffx_md = tstat.median
      tstat(tabmatch,"diffy")
      diffy_md = tstat.median	
      
      ## select only those apertures 
      for (ighfnd=1; ighfnd <= ngfnd; ighfnd += 1)
        {
	   ## find the closest aperture from expected positions	   
           for (iaper=1; iaper <= naper_tab; iaper += 1)
             {
	       xdist = (xcghost[iaper] - diffx_md - xcfnd[ighfnd])
	       ydist = (ycghost[iaper] - diffy_md - ycfnd[ighfnd])
               rdist = sqrt(xdist*xdist+ydist*ydist)
               
	       if (rdist < maxnorm1)
	        {
		   xbox1 = max(1,int(xcfnd[ighfnd] - slwdttab[iaper]/2. - xgrow+0.5))
		   xbox2 = min(1024,int(xcfnd[ighfnd] + slwdttab[iaper]/2. + xgrow+0.5))
		   ybox1 = max(1,int(ycfnd[ighfnd] - sllentab[iaper]/2. - ygrow+0.5))
		   ybox2 = min(1024,int(ycfnd[ighfnd] + sllentab[iaper]/2. + ygrow+0.5))
		   if ((xbox2 > 1) && (ybox2 > 1))
		     {
		       print(xbox1,xbox2,ybox1,ybox2,>> mask1//".dat")
		       printf("image;box(  %.1f , %.1f , %.1f , %.1f ,0) # text={Ghost }\n",\
	        	  (xbox1+xbox2)/2.,(ybox1+ybox2)/2.,slwdttab[iaper],sllentab[iaper], \
			  >> mask1//".reg") 
		     }
		}
	  ## perform geometrical distortion transformation if not using throughslit image
#	  if (reftp1 != "throughslit")
#	     {
#		 intrans1 = mktemp("_lmsghmskitr1")
#		 otrans1 = mktemp("_lmsghmskotr1")
#		 ## obtain name of transformation
#		 print ("geotrans1 ",geotrans1)
#		 list2=geotrans1
#		 gtrans_name = ""
#		 while (fscan(list2,inline1) != EOF) 
#		  {
#		    print ("inline ",inline1)
#		    print ("begin ",strstr("begin",inline1))
#		    if (strstr("begin",inline1) > 0) 
#		    {
#		       nsc = fscanf(inline1,"begin   %s",gtrans_name)
#		      if (verb1) print ("transform file: ",gtrans_name)
#		      break
#		    }  
#		  }
#		 if (gtrans_name == "")   goto err_distfile
#		 # write coordinates to be transformed
#		 print(xcghost,ycghost,>intrans1)
#		 print ("gtrans_name ",gtrans_name)
#		 geoxytran(intrans1,otrans1,database=geotrans1,transforms=gtrans_name, geometry="geometric",	    \
#		   direction="backward",xref=INDEF,yref=INDEF,xmag=INDEF,ymag=INDEF,xrotation=INDEF,yrotation=INDEF, \
#		   xout=INDEF,yout=INDEF,xshift=INDEF,yshift=INDEF,xcol=1,ycol=2)
#		 list2 = otrans1
#		 if (fscan(list2,xcghost,ycghost) == EOF)
#		   {
#		     print ("ERROR: cannot transform coordinates")
#		     bye
#		   }  
#	     }

#          if (showreg1) 
#	     {
#	        if (styptab[iaper] == "SLIT")
#		{
#	          print(int(xcghost+0.5)//" "//int(ycghost+0.5)//"  "//slitidtab[iaper]) | \
#		   tvmark (frame=1,coords="STDIN",mark = "rectangle",\
#          	   lengths = int(slwdttab[iaper])+xgrow//" "//(sllentab[iaper]+2*ygrow)/(slwdttab[iaper]+2*xgrow),\
#          	   color = 205,interactive = no,label+ )
#		}   
#	        if (styptab[iaper] == "REF")
#		{
#	          print(int(xcghost+0.5)//" "//int(ycghost+0.5)//"  "//slitidtab[iaper]) | \
#		   tvmark (frame=1,coords="STDIN",mark = "circle",\
#          	   radii = int(sllentab[iaper]/2.+0.5),color = 205,interactive = no,label+ )
#		}   
#	     }
	     }      
	} 
	
	## now display ghost mask if required
	badpiximage(mask1//".dat",fname,mask1//".pl",goodvalue=0,badvalue=maskval1)
	
	## overlay region files if required
	
      	
   }
      
   ## 
   
   
   bye
   
err_distfile: 
	 print("Format of distortion file is not correct") 
	 bye
	   
end
