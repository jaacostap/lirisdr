# lwavecal2d - compute wavelength calibration files
# Author : Jose Acosta  (jap@ll.iac.es)
# Version: 01. May. 2007
#          
##############################################################################
procedure lwavecal2d(input)
string	input		{prompt="Input arc exposures"}
string	inputdk		{prompt="Input dark arc exposures"}
string	outroot		{prompt="Output root name"}
string	section		{"line 400",prompt="Section to apply to two dimensional images"}	
string	coordlist	{"lirisdr$std/argon_ref.dat",prompt="Coordinate list"}
real	match		{30,prompt="Maximum difference for feature matching"}
string  database	{"database",prompt="Database in which to find feature data"}
bool	verbose		{yes,prompt="Verbose?"}

string *list1	{prompt="Ignore this parameter (list1)"}
string *list2	{prompt="Ignore this parameter (list2)"}

begin	
  string 	inli, arcin, slttyp, slttyp1, sltid1, coordlist1, database1
  string	specformat1
  string 	input1, outroot1, sect1
  real		xc, cdelt, crval, crval0, crquad, crpix0
  int		idumm,naxis,naper,iaper,nsc	
  bool		verb1,interact_reid
  
  interact_reid = 
  
  
  # expand input image list
  input1 = input
  outroot1 = outroot
  sect1 = section

  verb1 = verbose
    
  inli = mktemp("_lwvclinput")
  sections(input1,option="fullname", >inli) 
  
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
	
	laddwave(arcin)
	#lcentwave(specformat1,xc)

        if (verb1) {
 	  print ("  ")
	  print ("================================= ")
	  print ("Doing wavelength calib. for arc ",arcin)
	  print ("Grism used was ",laddwave.specformat)
	}

	identify(arcout,section=sect1,coordlist=coordlist1,
	    fwidth=5.,nsum=1,function="legendre",order=4,sample="*",niter=3,low_rej=3,
	    match=-20,high_rej=3.,dbwrite=yes,overwrite=yes,database=database1)

	reidentify(reference=arcout,
	    		image=arcout,interactive=interact_reid,newaps=no,override=no,
			refit=yes,trace=no,addfeature=no,coordlist=coordlist1,match=30,
			nlost=2)
			
	fitcoords(arcout,)		
	  
    } 
    
  
end  
  
  
  	
