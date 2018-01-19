# lspnodcomb - combine spectra taken following sequence ABBA cases
# Author : Jose Acosta  (jap@ll.iac.es)
# Version: 09. Oct. 2005
#          06 Apr. 2006  (double sky subtraction included)
##############################################################################
procedure lspnodcomb(input,output)
string	input		{prompt="List of sky subtracted images to be combined"}
string	output		{prompt="Output image"}
string  ftrimsec	{"",prompt="File containing trimming sections (useful for MOS)"}
string  ishift		{"crosscor",prompt="File containing shifts to be applied (file|wcs|crosscor)"}
int	iref		{1,prompt="Trim section or slitlet to be used for alignment (MOS)"}
string  shift		{"",prompt="File containing applied integer shifts (output)"}
string  spshift	        {"",prompt="File containing applied subpixel shifts (output)"}
string  trspec		{"",prompt="name of spectral correction file"}
string  otpref		{"t",prompt="Prefix to be added after spectral correction"}
string  dspref		{"d",prompt="Prefix to be added after double sky subtraction"}
string  ofpref		{"o",prompt="Prefix to be added after image shift"}
string  database	{"database",prompt="Directory containing spectral correction"}
string  flatcor		{"",prompt="flat-field correction"}
string  ffpref		{"f",prompt="Prefix of flat-field corrected images"}
bool	doublesky	{yes,prompt="Perfom double sky subtraction?"}
#bool    flattrim	{yes,prompt="Trim flat-field image"}
string  maskim		{"",prompt="Name of bad pixel mask"}
bool    use_subpixel	{yes,prompt="Use subpixel scale when combining"}
string  inter_typ	{"drizzle[0.4]",prompt="Interpolant type (nearest,linear,sinc,drizzle,poly3,poly5,spline3"}

pset  lspndcombpars {prompt="Additional configuration parameters (combination, double sky subtraction, registering)"}
string  tmpdir  	{")_.tmpdir",prompt="Temporary directory for file conversion"}
string  stddir  	{")_.stddir",prompt="Parametre directory for transformations"}

bool	verbose	{yes,prompt="Verbose"}

string *list1	{prompt="Ignore this parameter"}
string *list2	{prompt="Ignore this parameter"}
string *list3	{prompt="Ignore this parameter"}

begin
  string	outsp,flstoutsp,comblist,trlist,trfolist,dsfolist,ofsolist
  string	trspectmp,trspectrim,inttype1,flatcor1,fltcortmp,fltcortrim
  string	inli,subim,fsubim,imorig,foshift,fofracshift,imo,imosec,otr
  int		i,isec,nim,dspx,faxis, round
  string 	ffp,ffolist,masktype,bpmask, ods, ofs
  bool		lambcal,dsky, use_subpix1, verb1 
  
  inttype1 = inter_typ
  
  verb1 = verbose

  # expand input and output image names.
 
  bpmask = maskim
  if (bpmask == "") 
    masktype= "none"
  else 
    masktype = "goodvalue" 
 
  outsp = output

  dspx = lspect.dispaxis 
  
  use_subpix1 = use_subpixel
  flatcor1 = flatcor
  
  if (flatcor1 != "")
    ffp = ffpref
  else 
    ffp = ""
   
  # check if lambda calibration should be applied
  if (trspec != "") 
     {
       otr = otpref
       lambcal = yes
     }
  else 
     {
       otr = ""  
       lambcal = no
     }

  if (ofpref != "") 
      ofs = ofpref
  else 
      ofs = mktemp("_ofprf")
         
  # check if double sky subtraction should be applied
  if (doublesky == yes) 
     {
       ods = dspref
       dsky = yes
     }
  else 
     {
       ods = ""  
       dsky = no
     }
    
 # check if output image exists
  limgaccess(outsp//"*", verbose=no)
  if ( limgaccess.exists )
    {
    beep
    print("")
    print("ERROR: operation would override output file "//fname)
    print("lspnodcomb aborted")
    print("")
    beep
    bye
    }

  
  # Open the file containing the skysubtracted images 
  inli = mktemp(tmpdir//"lspndinli")
  sections(input,option="fullname",>inli)
  list1 = inli
  fsubim = mktemp(tmpdir//"_lspndfsubi")
  ffolist = mktemp(tmpdir//"_lspndffolst")
  trfolist = mktemp(tmpdir//"_lspndtrolst")
  dsfolist = mktemp(tmpdir//"_lspnddsolst")
  ofsolist = mktemp(tmpdir//"_lspndofslst")
  
  
  while (fscan(list1,subim) != EOF)
   {
      print(subim,>> fsubim)
      lfilename(subim,valid-)
      print(lfilename.path//ffp//lfilename.root,>>ffolist) 
      print(lfilename.path//otr//ffp//lfilename.root,>>trfolist) 
      print(lfilename.path//ods//otr//ffp//lfilename.root,>>dsfolist) 
      print(lfilename.path//ofs//ods//otr//ffp//lfilename.root,>>ofsolist) 
   }
   
   
  # check if flat-field correction is needed
  if (flatcor1 != "" && ftrimsec == "")
    {
      imarith("@"//fsubim,"/",flatcor1,"@"//ffolist,divzero=1)
    }
     

  comblist = mktemp(tmpdir//"_lspndolst")
  list1 = fsubim
   
  ## now check if images should be trimmed
  if (ftrimsec == "") 
    {   ### LONGSLIT CASE 
      	
      if (trspec != "")
        {
          ltransform("@"//ffolist,"@"//trfolist,"",trspec,database=database,
          verbose=yes)  
        }

      ## the second sky subtraction should be done here
      if (dsky)
        {
          print("applying second sky subtraction")
          if (dspx == 1) 
            faxis = 2
          else 
           faxis = 1  

          fit1d("@"//trfolist, "@"//dsfolist,
            "difference",axis=faxis,interac=lspndcombpars.dskyinter,
            sample=lspndcombpars.dskysamp,
            naverage=lspndcombpars.dskynaver,function=lspndcombpars.dskyfunction,
            order=lspndcombpars.dskyorder,low_reject=lspndcombpars.dskylreject,
            high_reject=lspndcombpars.dskyhreject,niterate=lspndcombpars.dskyniter)
        } 
	   

      # Now compute the shift 

      if (ishift == "wcs" || ishift == "crosscor")
        {
          if (shift == "") 
            { 
               foshift = mktemp(tmpdir//"_lspndoshf")
            } else 
            {
               foshift = shift
            }

	  if (spshift == "") 
	   { 
               fofracshift = mktemp(tmpdir//"_lspndoshff")
	   } else 
	   { 
	       fofracshift = spshift 
	   }
          
  	  if (ishift != "wcs")
	    {
	      if (use_subpix1) round=2 
		else round=0 		
              lspgetoff("@"//dsfolist,fofracshift,foshift,dispaxis=dspx,xcrsample=lspndcombpars.xcrsample,round=round)
	    }    
	  else 
            lshiftwcs("@"//trfolist,foshift,refer="90",xyshift="yonly",
	       surfcom=no,accuracy=0) 
	}
      else 
	foshift = ishift       

      if (bpmask != "") 
	 {
	       hedit("@"//dsfolist,"BPM",bpmask,add=yes,verif=no,update=yes)
	       masktype = "goodvalue"
	  } 

      if (use_subpix1 && (ishift == "wcs" || ishift == "crosscor")) {
        ## now shift images before combining
	  ##inttype1 = "drizzle[0.5]"
	  imshift("@"//dsfolist,"@"//ofsolist,0,0,shifts_file=fofracshift,
	    interp_type=inttype1)
		
	  imcombine(input = "@"//ofsolist,
	     output = outsp,
	    headers = "",             
	    bpmasks = "" ,            
	   rejmasks = "" ,            
	  nrejmasks = "" ,            
	   expmasks = "" ,            
	     sigmas = "" ,            
	    logfile = "STDOUT",       
	    combine = lspndcombpars.combine,         
	     reject = lspndcombpars.reject,         
	    project = no   ,          
	    outtype = "real",         
	  outlimits = ""   ,          
	    offsets = foshift,         
	   masktype = masktype,         
	  maskvalue = lspndcombpars.maskval,           
	      blank = 0.  ,           
	      scale = lspndcombpars.scale,         
               zero = lspndcombpars.zero,        
	     weight = lspndcombpars.weight,         
	    statsec = lspndcombpars.statsec,
	     lsigma = lspndcombpars.lsigma,
	     hsigma = lspndcombpars.hsigma,
              pclip = lspndcombpars.pclip,
               nlow = lspndcombpars.nlow,
	      nhigh = lspndcombpars.nhigh,
	      nkeep = lspndcombpars.nkeep) 
	      
      }	else {
      
	  imcombine(input = "@"//dsfolist,
	     output = outsp,
	    headers = "",             
	    bpmasks = "" ,            
	   rejmasks = "" ,            
	  nrejmasks = "" ,            
	   expmasks = "" ,            
	     sigmas = "" ,            
	    logfile = "STDOUT",       
	    combine = lspndcombpars.combine,         
	     reject = lspndcombpars.reject,         
	    project = no   ,          
	    outtype = "real",         
	  outlimits = ""   ,          
	    offsets = foshift,         
	   masktype = masktype,         
	  maskvalue = lspndcombpars.maskval,           
	      blank = 0.  ,           
	      scale = lspndcombpars.scale,         
               zero = lspndcombpars.zero,        
	     weight = lspndcombpars.weight,         
	    statsec = lspndcombpars.statsec,
	     lsigma = lspndcombpars.lsigma,
	     hsigma = lspndcombpars.hsigma,
              pclip = lspndcombpars.pclip,
               nlow = lspndcombpars.nlow,
	      nhigh = lspndcombpars.nhigh,
	      nkeep = lspndcombpars.nkeep) 
      }	  
    }	              
  else   ### MULTIOBJECT CASE  
    {
      ## if the spectra have to be trimmed before combination 
      ## the input list should be open
      flstoutsp = mktemp(tmpdir//"_lspndosp")
      nim = 1
      while (fscan(list1,imorig) != EOF)
        {
	  trlist = mktemp(tmpdir//"_lspndtrlst")
          ltrimspec(ffp//imorig,ffp//imorig,ftrimsec,outlist=trlist)
	  list2 = trlist
	  isec = 1 
	  while (fscan(list2,imosec) != EOF)
	   {
	     print(imosec,>>comblist//"_"//isec)
             ## construct the list for lambda calibration
	     lfilename(imosec,valid-)
	     print(lfilename.path//ffp//lfilename.root,>>ffolist//"_"//isec)
	     print(lfilename.path//otr//ffp//lfilename.root,>>trfolist//"_"//isec)
	     print(lfilename.path//ods//otr//ffp//lfilename.root,>>dsfolist//"_"//isec)
	     print(lfilename.path//ofs//ods//otr//ffp//lfilename.root,>>ofsolist//"_"//isec)
	     if (nim == 1)
	        printf("%s_%02d\n",outsp,isec, >> flstoutsp)
	     isec += 1
	   }	
	   nim += 1  
	}
	
	
      ## now combine spectra separately
      
      
      ## first determine the offset using a reference aperture
         # Now compute the shift 
    
      if (ishift == "wcs" || ishift == "crosscor")
	{
	  if (shift == "") 
	   { 
               foshift = mktemp(tmpdir//"_lspndoshf")
	   } else 
	   {
               foshift = shift
	   }

	  if (spshift == "") 
	   { 
               fofracshift = mktemp(tmpdir//"_lspndoshff")
	   } else 
	   { 
	       fofracshift = spshift 
	   }

	  if (ishift != "wcs")
	    {		
	       if (use_subpix1) round=2 
		 else round=0 		
               lspgetoff("@"//comblist//"_"//iref,fofracshift,foshift,dispaxis=dspx,round=round) 
	    }   
	  else 
            lshiftwcs("@"//fsubim,foshift,refer="90",xyshift="yonly",
	       surfcom=no,accuracy=0) 
	}
       else 
	foshift = ishift 
      
      
      list1 = flstoutsp  
      ## prepare the list of flatfield corrections 
      if (flatcor1 != "")  
          {
	    fltcortmp = mktemp(tmpdir//"_lspndfltcor")
	    sections(flatcor1,>fltcortmp)
            list3 = fltcortmp
	  } 
      
      ## prepare the list of lambda calibration 
      if (lambcal)  
          {
	    trspectmp = mktemp(tmpdir//"lspndtrspt")
	    sections(trspec,>trspectmp)
            list2 = trspectmp
	  } 

      ### NOW TREAT DIFFERENT SECTIONS SEPARATELY	     
      for (i=1 ; i < isec; i += 1)
        {
          if (fscan(list1,outsp) == EOF)
            {
	       beep
	       print("")
	       print("ERROR: Output spectra do not match number of sections")
	       print("lspnodcomb aborted\n")
	       beep
	       bye	      
	    }
	    
	  print ("seccion ",i," file ",outsp)  
	  
	  
	  if (flatcor != "") 
              {
                if (fscan(list3,fltcortrim) != EOF)
		 { 
		    if (verb1)
		      print("applying flatcorrection calibration ",fltcortrim)
		    imarith("@"//comblist//"_"//i,"/",fltcortrim,
		      "@"//ffolist//"_"//i,divzero=1)
		 }
              }

	  
	  if (lambcal) 
	  {
	    if (fscan(list2,trspectrim) != EOF)
	      {
	         ## select spectral calibration for the trimsection
		 print("applying wavelength calibration ",trspectrim)
		 hedit("@"//comblist//"_"//i,"DISPAXIS",dspx,add+,upd+,ver-,
		    show-)
		 if (dspx == 1)
		  { 
	           transform("@"//comblist//"_"//i,"@"//trfolist//"_"//i,
	             trspectrim,database=database,dy=1,dx=INDEF)
		  }    
		 else {  
	           transform("@"//comblist//"_"//i,"@"//trfolist//"_"//i,
	             trspectrim,database=database,dx=1,dy=INDEF)
		  }  
		   
	      } 
	    else 
	      {
		 beep
		 print("")
		 print("ERROR: Wavelength calibrations do not match sections")
		 print("lspnodcomb aborted\n")
		 beep
		 bye	      
	      }    
	  }
	  
	  
	  ## the second sky subtraction should be done here
	  if (dsky)
	  {
	     print("applying second sky subtraction")
	     if (dspx == 1) 
	       faxis = 2
	     else 
	       faxis = 1  
	       
	     fit1d("@"//trfolist//"_"//i, "@"//dsfolist//"_"//i,
	       "difference",axis=faxis,interac=lspndcombpars.dskyinter,
	       sample=lspndcombpars.dskysamp,
	       naverage=lspndcombpars.dskynaver,function="legendre",
	       order=lspndcombpars.dskyorder,low_reject=lspndcombpars.dskylreject,
	       high_reject=lspndcombpars.dskyhreject,niterate=lspndcombpars.dskyniter)
	  } 
	   
	 if (use_subpix1) {
           ## now shift images before combining
	     ##inttype1 = "drizzle[0.5]"
	     imshift("@"//dsfolist//"_"//i,"@"//ofsolist//"_"//i,0,0,
	       shifts_file=fofracshift,interp_type=inttype1)

	     imcombine(input = "@"//ofsolist//"_"//i,
		output = outsp,
	       headers = "",             
	       bpmasks = "" ,            
	      rejmasks = "" ,            
	     nrejmasks = "" ,            
	      expmasks = "" ,            
		sigmas = "" ,            
	       logfile = "STDOUT",       
	       combine = lspndcombpars.combine,         
		reject = lspndcombpars.reject,         
	       project = no   ,          
	       outtype = "real",         
	     outlimits = ""   ,          
	       offsets = foshift,         
	      masktype = masktype,         
	     maskvalue = lspndcombpars.maskval,           
		 blank = 0.  ,           
		 scale = lspndcombpars.scale,         
        	  zero = lspndcombpars.zero,        
		weight = lspndcombpars.weight,         
	       statsec = lspndcombpars.statsec,
		lsigma = lspndcombpars.lsigma,
		hsigma = lspndcombpars.hsigma,
        	 pclip = lspndcombpars.pclip,
        	  nlow = lspndcombpars.nlow,
		 nhigh = lspndcombpars.nhigh,
		 nkeep = lspndcombpars.nkeep) 

	 } else {
	   
	     imcombine(input ="@"//dsfolist//"_"//i,
	              output = outsp,
	             headers = "",             
	             bpmasks = "" ,            
                    rejmasks = "" ,            
                   nrejmasks = "" ,            
                    expmasks = "" ,            
	              sigmas = "" ,            
		     logfile = "STDOUT",       
		     combine = lspndcombpars.combine,         
		      reject = lspndcombpars.reject,         
		     project = no   ,          
		     outtype = "real",         
		   outlimits = ""   ,          
		     offsets = foshift,         
		    masktype = masktype,         
		   maskvalue = lspndcombpars.maskval,           
		       blank = 0.  ,           
		       scale = lspndcombpars.scale,         
        		zero = lspndcombpars.zero,        
		      weight = lspndcombpars.weight,         
		     statsec = "",
		      lsigma = lspndcombpars.lsigma,
		      hsigma = lspndcombpars.hsigma,
        		nlow = lspndcombpars.nlow,
		       nhigh = lspndcombpars.nhigh,
		       nkeep = lspndcombpars.nkeep) 
	 }	       
	
        }  ### CLOSE FOR - TREAT DIFFERENT SECTIONS
	
    }   ### CLOSE ELSE - MULTIOBJECT CASE   

## clean up temporary files
delete(fsubim,ver-)
#delete(fimorig,ver-)
delete(ffolist,ver-)
delete(trfolist,ver-)
delete(dsfolist,ver-)
delete(ofsolist,ver-)
delete(tmpdir//"lspndtrolst*",ver-)
delete(tmpdir//"lspndinli*",ver-)

if (shift == "" && ishift == "") 
  delete(foshift,ver-)
  
if (spshift == "") 
  delete(fofracshift,ver-)
 
  
if ( ftrimsec !=  "") 
  {
    delete ("_lspndolst*",ver-)
    delete (flstoutsp,ver-)
    delete ("_lspndtrlst*",ver-)
    imdel ("lspndimo*",ver-)
  }

end
