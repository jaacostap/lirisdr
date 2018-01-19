# lmostransform - Apply spectral transformation to a list of mos frames 
# Author : Jose Acosta  (jap@ll.iac.es)
# Version: 07. Jan. 2011
#          
##############################################################################
procedure lmostransform(input,output,trspec)
string	input		{"",prompt="List of sky subtracted images to be combined"}
string	output		{"t",prompt="Output image prefix"}
string  trspec		{"",prompt="Name of spectral correction file"}
string	ftrimsec	{"",prompt="File containing trimming sections"}
string  database	{"database",prompt="Directory containing spectral correction"}
bool	trimspec	{no,prompt="Trim the spectra?"}
real    dx		{INDEF,prompt="Output X pixel interval"}

string  tmpdir  	{")_.tmpdir",prompt="Temporary directory for file conversion"}

string *list1	{prompt="Ignore this parameter"}
string *list2	{prompt="Ignore this parameter"}
string *list3	{prompt="Ignore this parameter"}

begin
string  inli, specim,trolist,osp,trspli,trimlist
string	trfil, ospecim, specosec, fout, specim_sec, ospecim_sec
string	trspec_sec[30],ext_sec[30],trspec_tmp,nam_imsec,db1
int     nsc, nifil, nspfiles, isec, ii
int 	nim=0
real    dx1


  # Open the file containing the skysubtracted images 
  inli = mktemp(tmpdir//"_lmstrnfmilst")
  sections(input,option="fullname",>inli)
  trolist = mktemp(tmpdir//"_lmstrnfmolst")
  if (output != "") 
     osp = output
  else 
     osp = "t"

  dx1 = dx
  db1 = database
     
  # Expand transformation 
  trspli = mktemp(tmpdir//"_lmstrnfmsplst")
  sections(trspec,option="fullname",>trspli)
  
  list1 = trspli
  isec= 0 
  while (fscan(list1,trspec_tmp) != EOF)
    {
       isec += 1
       trspec_sec[isec] = trspec_tmp
       printf("_%02d\n",isec) | scan(nam_imsec)
       ext_sec[isec] = nam_imsec
    }
  
## now goes through the list of input files
  list1 = inli
  while (fscan(list1,specim) != EOF)
   {
      trimlist = mktemp(tmpdir//"_lmstrnfmtrlst")
      if (trimspec) 
        {
           ltrimspec(specim,specim,ftrimsec,outlist=trimlist)
         	 
	}
	
       lfilename(specim)	
       for (ii = 1; ii <= isec; ii += 1)
          {
	     specim_sec = lfilename.root//ext_sec[ii]
	     ospecim_sec = osp//specim_sec
	     hedit (specim_sec,dispaxis,1,upd+,add+,ver-)
             print("transform ",specim_sec," to ",ospecim_sec," usando ",trspec_sec[ii])	 
             transform(specim_sec,ospecim_sec,trspec_sec[ii],interp="spline3",\
	       dx=dx1,dy=1,flux=yes,database=db1)	     
	  
	  }	
	
   }  ## end of while fscan->specim

       
   
delete (trspli,ver-,>"dev$null")

list1 = ""
list2 = ""

end
