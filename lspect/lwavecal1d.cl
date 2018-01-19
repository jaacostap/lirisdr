# lwavecal1d - compute wavelength calibration files
# Author : Jose Acosta  (jap@ll.iac.es)
# Version: 01. May. 2007
#          
##############################################################################
procedure lwavecal1d(inputA,inputB)
string	inputA		{prompt="Input arc exposure for pos A"}
string	inputB		{prompt="Input arc exposure for pos B"}
string	outroot		{prompt="Output root name for slitlets"}
string	coordlist	{"lirisdr$std/argon_ref.dat",prompt="Coordinate list"}
real	match		{30,prompt="Maximum difference for feature matching"}
string  database	{"database",prompt="Database in which to find feature data"}
string	specformat	{"lr_zj",enum="lr_zj|lr_hk|mr_k|psgrj|psgrh|psgrk",prompt="Grism used"}
bool	verbose		{yes,prompt="Verbose?"}

string *list1	{prompt="Ignore this parameter (list1)"}
string *list2	{prompt="Ignore this parameter (list2)"}

begin	
  string 	inli, inliB, arcin, arcinB, slttyp, slttyp1, sltid1, coordlist1, database1
  string	specformat1
  string 	input1, outroot1
  real		xc, cdelt, crval, crval0, crquad, crpix0
  int		idumm,naxis,naper,iaper,nsc	
  bool		verb1,interact_reid
  
  interact_reid = 
  
  
  # expand input image list
  input1 = inputA
  outroot1 = outroot

  verb1 = verbose
    
  inli = mktemp("_lmswvclinput")
  sections(input1,option="fullname", >inli) 
  
  input1 = inputB	
  inliB = mktemp("_lmswvclinputB")
  sections(input1,option="fullname", >inliB) 
    
  coordlist1 = coordlist
  specformat1 = specformat
  database1 = database


  ## start loop over slitlets
  
  list1 = inli
  list2 = inliB
  
  while (fscan(list1, arcin) != EOF) 
    {
       imgets(arcin,'i_naxis') 
       naxis = int(imgets.value)
       if (naxis > 1) 
          { 
            imgets(arcin,'i_naxis2')
            naper = int(imgets.value) 
	  }
       else 
            naper = 1	    
       ## start loop over apertures (images are expected to be in ms format)
       for (iaper=1; iaper <= naper; iaper += 1)
        {  
        ## read slit position from image header or from mdf file
        imgets(arcin,'APID'//iaper)
	sltid1 = imgets.value
	imgets(arcin,'MDXC'//iaper)
	if (imgets.value != "0")
	  xc = real(imgets.value)
	else {
	  print("WARNING: Slit center not found in header. Assuming center value")
	  xc = 530.
	}  
	
	lcentwave(specformat1,xc)

        crval0 = lcentwave.crval
	cdelt = lcentwave.cdelt
	crpix0 = lcentwave.crpix
        crquad= 0.
        # call autoidentify based on the 
        aidpars.crpix = lcentwave.crpix
	aidpars.crquad = crquad
	aidpars.reflist = "lirisdr$std/argon_ref.dat"
	aidpars.cddir = "sign"
	aidpars.aidord=3
        aidpars.ntarget = 20
	aidpars.nbins= 6
        
        if (verb1) {
 	  print ("  ")
	  print ("================================= ")
	  print ("Doing wavelength calib. for slit id ",sltid1," using aperture ",iaper)
	  print ("Slit center at col  ",xc)
	  print ("Ref. lambda is ",crval0," at Ref pixel ",crpix0)
	}
	autoidentify(arcin//'[*,'//iaper//']',crval0,cdelt,coordlist=coordlist1,section="",
	    fwidth=5.,nsum=1,function="legendre",order=4,sample="*",niter=3,low_rej=3,
	    match=-20,high_rej=3.,dbwrite=yes,overwrite=yes,database=database1,threshold=500)

        }	    

        if (fscan(list2, arcinB) != EOF)
	  {
	    reidentify(reference=arcin,
	    		image=arcinB,interactive=interact_reid,newaps=no,override=no,
			refit=yes,trace=no,addfeature=no,coordlist=coordlist1,match=30,
			nlost=2)
	  
	  }
    } 
    
  
end  
  
  
  	
