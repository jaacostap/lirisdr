# lmosextall - extract and spectra from all slitlets
# Author : Jose Acosta  (jap@ll.iac.es)
# Version: 09. Feb. 2009
#          06 Apr. 2006  (double sky subtraction included)
##############################################################################
procedure lmosextall(inputa,inputb,references)
string  inputa          {prompt="List of input images at pos A"}
string  inputb          {prompt="List of input images at pos B"}
string	references	{prompt="Reference image"}
string  outa            {prompt="List of output spectra at pos A"}
string  outb            {prompt="List of output spectra at pos B"}
string  apertures	{"",prompt="Apertures to be extracted"}
string	arc		{"",prompt="Arc image - Lamp ON"}
string	outarc		{"",prompt="Output extracted arc spectra"}
string	flat		{"",prompt="Flat image"}
string	outflat		{"fl_",prompt="Prefix added to name of extracted flat spectra"}
string	outflatlst	{"",prompt="List of extracted flat spectra"}
string	mask		{"",prompt="Mask image"}
string	outmask		{"gh_",prompt="Prefix added to name of extracted mask spectra"}
string	outmasklst	{"",prompt="List of extracted mask spectra"}
bool	disp_im		{yes,prompt="Display images before extracting?"}
bool	ext_mos		{yes,prompt="Extract MOS spectra?"}
bool	ext_arc		{yes,prompt="Extract arcs?"}
bool	ext_flat	{no,prompt="Extract flat-field?"}
bool	ext_mask	{no,prompt="Extract mask?"}
string	interactive	{"yes",enum="yes|YES|no|NO",prompt="Recenter apertures interactively?"}
real	lower		{-2.,prompt="Lower aperture limit relative to center"}
real	upper		{2.,prompt="Upper aperture limit relative to center"}
int	nsum		{400,prompt="Number of dispersion lines to sum or median"}
real	cwidth		{5.,prompt="Profile centering width"}
real	cradius		{7.,prompt="Profile centering radius - should be about slitlet size"}
string	weight		{"none",prompt="Extraction weights (none|variance)"}
string	background	{"none",enum="none|average|median|fit|minimum",prompt="Background to subtract (none|average|fit)"}
string	b_samplea	{"5:10",prompt="Background sample region for pos A"}
string	b_sampleb	{"-10:-5",prompt="Background sample region for pos B"}
bool	clean		{no,prompt="Detect and replace bad pixels during extraction?"}
bool	verbose		{no,prompt="Verbose?"}
#string  ftrimsec        {"",prompt="File containing trimming sections (useful for MOS)"}

string *list1	{prompt="Ignore this parameter"}

begin 

  string	inli, refapA_lst, refapB_lst, ref1,subim,arc1,flat1,oarc1,oflat1,oflatlst1
  string	mask1,omask1,omasklst1
  string	weight1,firstposA,aper1,back1,bsamp1a,bsamp1b
  int	  	nsum1,isub
  real		crad1,cwdth1
  bool		clean1,verb1,ext_arc1,ext_flat1,ext_mask1
  bool		intersub1=yes

## first define aperture  limits using reference spectra obtained from flat-field, permits to edit and recenter 
##   apertures, use apall recenter+ edit+ extract+
 
  ref1 = references
  nsum1 = nsum
  crad1= cradius
  cwdth1 = cwidth
  clean1 = clean
  weight1 = weight
  verb1 = verbose
  arc1 = arc
  aper1 = apertures
  back1 = background
  bsamp1a = b_samplea
  bsamp1b = b_sampleb
 
  flat1 = flat
  mask1 = mask
  oarc1 = outarc
  oflat1 = outflat
  omask1 = outmask
  ext_arc1 = ext_arc
  ext_flat1 = ext_flat
  ext_mask1 = ext_mask
  oflatlst1 = outflatlst
  omasklst1 = outmasklst
   
  if (interactive != "yes" && interactive != "YES") 
    intersub1 = no
 
  
  # Open the file containing the skysubtracted images for pos A
  inli = mktemp(tmpdir//"_lspndinli")
  sections(inputa,option="fullname",>inli)
  list1 = inli

  apdefault.lower = lower
  apdefault.upper = upper

  isub = 0
  refapA_lst = mktemp("_lmsaparefa")
  apedit.radius = crad1
  apedit.width  = cwdth1
  while (fscan(list1,subim) != EOF)
   {
      print("Defining and extracting apertures for nod A")
      lfilename(subim,valid-)
      print(lfilename.root,>>refapA_lst) 
      
      ## using the first spectrum to determine the aperture positions, the remaining are 
      ## only recenters 
      if (isub == 0)  
         {
           if (verb1) {
	       printf("Extracting %s based on reference at nod A\n",subim)
	       print("  Use (a+)g to recenter (all-)apertures")
	       print("  Use (a+)s to shift (all-)apertures")
	     }  
	    apresize.ylevel=INDEF 
	    apresize.llimit=lower
	    apresize.ulimit=upper
	    apdefault.b_sample=bsamp1a
	    apsum.background="median"  ## force to have median just to define a background region
	    print ("aper1 ",aper1)
	    print ("voy a definir aperturas usando las referencias ",ref1)
	    apedit(subim,apertures=aper1,references=ref1,find=no,recenter=yes,resize=yes,edit=yes, \
	         nsum=nsum1,radius=crad1,width=cwdth1)
	    firstposA = subim	 
	    ## extract arc if required
	    if (ext_arc1 && (arc1 != ""))
	     {
               if (verb1)  
	           print ("Now extracting arc apertures from pos A")
	       hedit(arc1,"DISPAXIS",1,add+,upd+,ver-)	   
	       apsum (arc1,output=oarc1//"_A.ms",format="multispec",references="last",profiles="",\
                  apertures=aper1,interactive=no,find=no,recenter=no,resize=no,edit=no,trace=no,\
	          fittrace=no,extract=yes,extras=no,review=no,background="none",weights="none",\
		  clean=no)
	     }  
	    	 
	 }   
      else 
         {
           if (verb1) {
	       print("Extracting spectra based on first image at nod A")
	       print("  Use s to shift all apertures using a reference aperture")
	     }  
	   aprecenter(subim,apertures=aper1,references="last",interac=intersub1,resize=no,edit=intersub1,\
	        nsum=nsum1,aprecenter=aper1,npeaks=0.6,shift=yes)
	 }
      
      ## now extract the spectra	 
      apsum (subim,output="",format="multispec",references="",profiles="",apertures=aper1,interactive=no,\
           find=no,recenter=no,resize=no,edit=no,trace=no,fittrace=no,extract=yes,extras=no,review=no,\
	   background=back1,weights=weight1,clean=clean1)

      ## extract flat if required
      if (ext_flat1 && (flat1 != ""))
       {
         if (verb1)  
	     print ("Now extracting flat-field apertures from pos A")
	 apsum (flat1,output=oflat1//subim//".ms",format="multispec",references="last",profiles="",\
            apertures=aper1,interactive=no,find=no,recenter=no,resize=no,edit=no,trace=no,fittrace=no,\
	    extract=yes,extras=no,review=no,background="none",weights="none",clean=no)
	 if (oflatlst1 != "") 
	     print(oflat1//subim//".ms",>> oflatlst1)   
       }  

      ## extract mask if required
      if (ext_mask1 && (mask1 != ""))
       {
         if (verb1)  
	     print ("Now extracting mask apertures from pos A")
	 apsum (mask1,output=omask1//subim//".ms",format="multispec",references="last",profiles="",\
            apertures=aper1,interactive=no,find=no,recenter=no,resize=no,edit=no,trace=no,fittrace=no,\
	    extract=yes,extras=no,review=no,background="none",weights="none",clean=no)
	 if (omasklst1 != "") 
	     print(omask1//subim//".ms",>> omasklst1)   
       }  
	   
      isub += 1	   
   }

   delete(inli,ver-,>>"dev$null")
   

## do the same using B position

  # Open the file containing the skysubtracted images for pos B
  inli = mktemp(tmpdir//"_lspndinli")
  sections(inputb,option="fullname",>inli)
  list1 = inli

  isub = 0
  refapB_lst = mktemp("_lmsaparefb")
  while (fscan(list1,subim) != EOF)
   {
      print("Defining and extracting apertures for nod B")
      lfilename(subim,valid-)
      print(lfilename.root,>>refapB_lst) 
      
      ## using the first spectrum to determine the aperture positions, the remaining are 
      ## only recenters 
      if (isub == 0)  
         {
           if (verb1) {
	       printf("Extracting %s based on reference at nod Bs\n",subim)
	       print("  Use (a+)g to recenter (all-)apertures")
	       print("  Use (a+)s to shift (all-)apertures")
	     } 
	       
	    apdefault.b_sample=bsamp1b
	    apsum.background="median"  ## force to have median just to define a background region
	    aprecenter(subim,apertures=aper1,references=firstposA,interac=yes,resize=no,edit=yes, \
	        nsum=nsum1,aprecenter=aper1,npeaks=0.6,shift=yes)
		
	    ## extract arc if required
	    if (ext_arc1 && (arc1 != ""))
	     {
               if (verb1)  
	           print ("Now extracting arc apertures from pos B")
	       apsum (arc1,output=oarc1//"_B.ms",format="multispec",references="last",profiles="",\
                  apertures=aper1,interactive=no,find=no,recenter=no,resize=no,edit=no,trace=no,\
		  fittrace=no,extract=yes,extras=no,review=no,background="none",weights="none",\
		  clean=no)
	     }  
	 }   
      else 
         {
           if (verb1) {
	       print("Extracting spectra based on first image at nod B")
	       print("  Use s to shift all apertures using a reference aperture")
	     }  
	   aprecenter(subim,apertures=aper1,references="last",interac=intersub1,resize=no,edit=intersub1,
	        nsum=nsum1,aprecenter=aper1,npeaks=0.6,shift=yes)
	 }
      
      ## now extract the spectra	 
      apsum (subim,output="",format="multispec",references="",profiles="",apertures=aper1,interactive=no,\
           find=no,recenter=no,resize=no,edit=no,trace=no,fittrace=no,extract=yes,extras=no,review=no,\
	   background=back1,weights=weight1,clean=clean1)

      ## extract flat if required
      if (ext_flat1 && (flat1 != ""))
       {
         if (verb1)  
	     print ("Now extracting flat-field apertures from pos B")
	 apsum (flat1,output=oflat1//subim//".ms",format="multispec",references="last",profiles="",\
            apertures=aper1,interactive=no,find=no,recenter=no,resize=no,edit=no,trace=no,fittrace=no,\
	    extract=yes,extras=no,review=no,background="none",weights="none",clean=no)
	 if (oflatlst1 != "") 
	     print(oflat1//subim//".ms",>> oflatlst1)   
       }  

      ## extract mask if required
      if (ext_mask1 && (mask1 != ""))
       {
         if (verb1)  
	     print ("Now extracting mask apertures from pos B")
	 apsum (mask1,output=omask1//subim//".ms",format="multispec",references="last",profiles="",\
            apertures=aper1,interactive=no,find=no,recenter=no,resize=no,edit=no,trace=no,fittrace=no,\
	    extract=yes,extras=no,review=no,background=back1,weights="none",clean=no)
	 if (omasklst1 != "") 
	     print(omask1//subim//".ms",>> omasklst1)   
       }  

      isub += 1	   
   }
   
   delete(inli,ver-,>>"dev$null")
   
## clean up 

delete(refapA_lst,ver-,>>"dev$null")
delete(refapB_lst,ver-,>>"dev$null")

end
