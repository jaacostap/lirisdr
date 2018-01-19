# lfindmosaper - determine slit boundaries over a flatfield or lamp spectrum
#               Its main usage is to define slitlets in MOS spectroscopy
# Author     : J Acosta
#              15. Jan. 2009
#  
##############################################################################
procedure lcheckmask(mdf,slitpos,outcheck)

file    input           {prompt="Input image"}
file	mdf		{prompt="Mask definition file"}
file	slitpos		{prompt="Slitlet position file"}
file    outcheck          {prompt="Output file containing differences among slitlet limits (ASCII)"}
string	use_offset	{"both",enum="bottom|top|both",prompt="Offset is determined from?"}
bool	showreg		{yes,prompt="Show apertures overlaid on image display?"}
bool    verbose         {no,prompt="Verbose ?"}
string *list            {prompt="Ignore this parameter (list)"}
string *list2           {prompt="Ignore this parameter (list2)"}

begin

  string        input1, mdf1, slitpos1, inli, outcheck1,dbnewap, fsecap
  string	styp,slitid,inline
  string	grnam,apermask_lst,allapermask_lst,allslitpos_lst,aperstr
  string	tmpjn,tmpjn1,dumm
  int		ord,ns,nsc,offreg1
  int		nslt=0
  int		nref=0
  int 		find_nslt=0
  int		find_nref=0
  int		ntot,ntot_fnd,apernum,iaper,ntabaper,dispax,ifnd,ifnd_min,tt
  real		xc,y1,y2,sllen,slwdt,slminlen,yc,xx1,xx2,yy1,yy2,xdist,ydist,dist,mindist
  real		ytop,ybottom,yoffsetbot,yoffsettop,yoffset,xoffset,fdumm1,yoffset2
  bool		isdataline,verb1,showreg1
  real		ytab1[35],ytab2[35],sllentab[35],xctab[35]
  real		ycfnd[35],slwdtfnd[35],sllenfnd[35],xcfnd[35]
  string	styptab[35],slitidtab[35]
  string	stypfnd[35]
  
  
  ## este programa deberia leer la imagen y llamar al programa que corre sextractor.
  
  input1 = input
  mdf1 = mdf
  slitpos1 = slitpos
  outcheck1 = outcheck

  delete(outcheck1,veri-,>> "/dev/null")

  showreg1 = showreg
  verb1 = verbose
  
  slminlen = 3
  
  if (use_offset == "bottom") 
    offreg1 = 0
  else if (use_offset == "top") 
    offreg1 = 1
  else
    offreg1 = 2    
    
  
  slminlen = 1100
  
  
  ## determine number of apertures in the mask reading
  ### from design mask file
  list2 = mdf1
  isdataline = no
  ord = 1
  apermask_lst = mktemp("_lchkaprmsk")
  allapermask_lst = mktemp("_lchkaaprmsk")
  while (fscan(list2,inline) != EOF)
    {
      if (strstr("Typ",inline) != 0)  {
          while (fscan(list2,ord,styp,slitid,xc,y1,y2,sllen,slwdt) != EOF)
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
                print(y1,y2,sllen,xc,styp,"  ",slitid,>>allapermask_lst)
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
  while (fscan(list,y1,y2,sllen,xc,styp,slitid) != EOF)
    {
       iaper += 1
       ytab1[iaper] = y1
       ytab2[iaper] = y2 
       xctab[iaper] = xc
       styptab[iaper] = styp
       sllentab[iaper] = sllen
       slitidtab[iaper] = slitid 
    }
  ntabaper = iaper
  
  ## now read measured slitpos 
  allslitpos_lst = mktemp("_lchksltps")
  list2 = slitpos1
  ybottom = 1200
  ytop = 1
  iaper = 0
  while (fscanf(list2,"%s %f %f %f %f",styp,xc,yc,slwdt,sllen) != EOF)
    {
      if (stridx("#",styp) != 1)  {
          #print("inline ",inline)
          #print(inline) | scanf("%s %f %f %f %f",styp,xc,yc,slwdt,sllen)
          #if (fscan(inline,styp,xc,yc,slwdt,sllen) == 5 )
           # {
	       iaper += 1 
               if (strstr("SLIT",styp) != 0) 
                 {
                   find_nslt += 1
                 }
                if (strstr("REF",styp) != 0) 
                 {
                   find_nref += 1
                 }
                # get the top and bottom position
		
		y2 = yc + sllen/2.
                if (ytop < yc)
		   ytop = y2
		y1 = yc - sllen/2
		if (ybottom > y1)
		   ybottom = y1
		   
		ycfnd[iaper] = yc 
                xcfnd[iaper] = xc
                sllenfnd[iaper] = sllen
                slwdtfnd[iaper] = slwdt
		stypfnd[iaper] = styp
           #} 
     }      
    }

  # check number of slits and ref positions
  if (find_nslt != nslt) {
     beep; beep
     printf ("Warning: Number of expected and found slitlets not matching [%d/%d]\n",find_nslt,nslt)
  } 

  if (find_nref != nref) {
     beep; beep
     printf ("Warning: Number of expected and found ref. holes not matching [%d/%d]",find_nref,nref)
  } 

  if (verb1) 
    print("ytop=",ytop," - ybottom=",ybottom)

   # in principle this program works only for a single image
  
  inli = mktemp(tmpdir//"_fndmsaperin")
  #lcheckfile (input1)
  #lfilename (input1)
  #if (lcheckfile.nimages != 0) 
  #{
  #   if (lcheckfile.mode_aq != "NORMAL")
  #	print(lfilename.root//"[1]",>>inli)
  #   else 
  #     {
  #	 print("ERROR: input format not valid")
  #     }
  #}   
  #else	 
  #   print(lfilename.root,>>inli)  
     
  #if (showreg1)
  #    display(input1,1)
    
  
    ## first determine average offset between measured and expected positions
    yoffsetb = ybottom - ytab1[1]
    yoffsett = ytop - ytab2[ntabaper]
    switch (offreg1) {
       case 0: 
         yoffset = yoffsett
       case 1:
         yoffset = yoffsetb
       case 2: 
         yoffset = (yoffsetb+yoffsett)/2.
    }
    if (verb1) print(" offset [b,t], offset ",yoffsetb,yoffsett,yoffset)
  
  # re-sort position of negative maxima 
  #tsort(tmpneg,"c3",asc+)
  
  ntot_fnd = find_nslt + find_nref
 
  #list = allslitpos_lst
  apernum = 0
  iaper = 1
  while (iaper<= ntabaper)
  {

       ## adjust table position with mask offset
       yy1 = ytab1[iaper] + yoffset
       yy2 = ytab2[iaper] + yoffset
       
       
       
       ## match the closest found aperture
       ## 
       mindist = 9999
       for (ifnd=1; ifnd <= ntot_fnd; ifnd +=1 )
        {
          xdist = xcfnd[ifnd] - xctab[iaper]
          ydist = ycfnd[ifnd] - (yy1+yy2)/2.
	  
       
          dist = sqrt(xdist*xdist+ydist*ydist)
	  if (mindist > dist) {
	       ifnd_min = ifnd
	       mindist = dist
	    }
	}
	 
       xdist = xcfnd[ifnd_min] - xctab[iaper]
       ydist = ycfnd[ifnd_min] - (yy1+yy2)/2.
       dist = sqrt(xdist*xdist+ydist*ydist)	  

       if (dist < 10) 
        {
	  ## find offset along vertical axis
	  ybottom = ycfnd[ifnd_min] - sllenfnd[ifnd_min]/2.
	  ytop = ycfnd[ifnd_min] + sllenfnd[ifnd_min]/2
	  yoffsetbot = ybottom-yy1
	  yoffsettop = ytop-yy2
          printf("%15s %6.1f %6.1f %6.1f %6.1f %.2f %.2f %.2f\n", \
	      slitidtab[iaper],xctab[iaper],xcfnd[ifnd_min],(yy2+yy1)/2,ycfnd[ifnd_min], \
	      xdist,yoffsetbot,yoffsettop, >>outcheck1)
	  ## if image presents overlay the measured position
	}
       else 
        {
          printf ("Object Pos %s not found\n",slitidtab[iaper]) 

	}
        
	iaper += 1
  }
 
    
  ## clean up
  delete (allapermask_lst,veri-,>> "/dev/null")
  delete (inli,veri-,>> "/dev/null")
 

end
