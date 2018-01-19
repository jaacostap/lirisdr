# lspecplot - show spectres and return list with selected spectres
# Author : Miguel Charcos (mcharcos@ll.iac.es)
# Version: 15. Dec. 2003
##############################################################################
procedure lspecplot(input,output)

string	input		{prompt="List of spectres to plot"}
string	output		{prompt="List of spectres selected"}

string	indepf1		{"",prompt="File related with input spectres with 1 parametre"}
string	indepf2		{"",prompt="File related with input spectres with 2 parametre"}
string	outdepf1	{"",prompt="Output file related with indepf1"}
string	outdepf2	{"",prompt="Output file related with indepf2"}

bool	delnosel	{no,prompt="Delete no selected spectral images"}

# Work directories
string  tmpdir  	{")_.tmpdir",prompt="Temporary directory for file conversion"}

# plot parametres
pset 	spplotopt	{prompt="Specplot configuration parametres"}

int	imnum		{prompt="Return number of output spectres"}
bool	verbose		{no,prompt="Verbose?"}

string *list1	{prompt="Ignore this parameter(list1)"}
string *list2	{prompt="Ignore this parameter(list2)"}
string *list3	{prompt="Ignore this parameter(list3)"}
string *list4	{prompt="Ignore this parameter(list4)"}


begin

  string	inli,outli
  string	imref,fname,junk
  string	flog,dep1,dep2,outdep1,outdep2
  string	param1,param21,param22
  int		num,nsc,nsc1,nsc2,ipos

  inli = mktemp (tmpdir//"lspecplotinli")
  sections (input,option="fullname",>> inli)

  outli = output
  if (access(outli))
    {
    beep
    print("")
    print("ERROR: operation would overwritte output list file ")
    print("lspecplot aborted")
    print("")
    beep
    bye
    }

  # Related file treatment analyse
  if (indepf1 == "") dep1 = ""
  else dep1 = indepf1
  if (indepf2 == "") dep2 = ""
  else dep2 = indepf2

  if (access(outdepf1))
    {if (verbose) print "WARNING: "//outdepf1//" already exists"}
  if (access(outdepf2))
    {if (verbose) print "WARNING: "//outdepf2//" already exists"}

  if (dep1 != "")
    {
    if (!access(dep1))
      {
      if (verbose)
    	{
    	print "WARNING: "//dep1//" does not exist"
    	print " 	file will not be considered"
    	}
      dep1 = ""
      }
    }
  if (dep2 != "")
    {  
    if (!access(dep2))
      {
      if (verbose)
    	{
    	print "WARNING: "//dep2//" does not exist"
    	print " 	file will not be considered"
    	}
      dep2 = ""
      }
    }
    
  if (dep1 != "") outdep1 = mktemp(tmpdir//"lspecplotdep1")
  if (dep2 != "") outdep2 = mktemp(tmpdir//"lspecplotdep2")
    
  num = 0
    
  flog = mktemp(tmpdir//"lspecplotflog")
  
  print "****** Press d to delete spectre ******"
  print "****** Press q to quit           ******"
    
  specplot (spectra = "@"//inli,
  	  apertures = spplotopt.apertures,
  	      bands = spplotopt.bands,
  	 autolayout = spplotopt.autolayout,
  	  autoscale = spplotopt.autoscale,
  	   fraction = spplotopt.fraction,
  	      units = spplotopt.units,
  	      scale = spplotopt.scale,
  	     offset = spplotopt.offset,
  	       step = spplotopt.step,
  	      ptype = spplotopt.ptype,
  	     labels = spplotopt.labels,
  	    ulabels = spplotopt.ulabels,
  	      xlpos = spplotopt.xlpos,
  	      ylpos = spplotopt.ylpos,
  	      sysid = spplotopt.sysid,
  	     yscale = spplotopt.yscale,
  	      title = spplotopt.title,
  	     xlabel = spplotopt.xlabel,
  	     ylabel = spplotopt.ylabel,
  	       xmin = spplotopt.xmin,
  	       xmax = spplotopt.xmax,
  	       ymin = spplotopt.ymin,
  	       ymax = spplotopt.ymax,
  	    logfile = flog,
  	   graphics = "stdgraph",
  	     cursor = "")	 
    
      
  list1 = flog
  nsc=fscan(list1)
  nsc=fscan(list1)
  nsc=fscan(list1)
  nsc=fscan(list1)
  nsc=fscan(list1)
    
  list2 = inli
  if (dep1 != "") list3=dep1
  if (dep2 != "") list4=dep2
  nsc1 = EOF
  nsc2 = EOF
  While (fscan(list1,junk,imref) != EOF && imref != "Name")
    {
    ipos = stridx("(",imref)
    imref = substr(imref,1,ipos-1)
    ipos = stridx("[",imref)
    imref = substr(imref,1,ipos-1)
    lfilename(imref)
    imref = lfilename.root
    
    While (fscan(list2,fname) != EOF)
      {
      if (dep1 != "") nsc1=fscan(list3,param1)
      if (dep2 != "") nsc2=fscan(list4,param21,param22)
      
      lfilename(fname)
      if (lfilename.root == imref)
        {
        print (fname, >> outli)
        num = num + 1
	if (nsc1 != EOF) print (param1,>>outdep1)
	if (nsc2 != EOF) print (param21//" "//param22,>>outdep2)
        break
        }
      else
        {
	if (delnosel) 
	  {
	  imdelete(fname,yes,ver-)
	  print "WARNING: image "//fname//" deleted"
	  }
	}
      } # end of While (fscan(list2,fname) != EOF)
    
    } # end of While (fscan(list1,junk,fname) != EOF && fname != "Name")
  
  
  if (dep1 != "")
    {
    delete (outdepf1,yes,ver-, >>& "/dev/null")
    rename (outdep1,outdepf1,field="all")
    }
  if (dep2 != "")
    {  
    delete (outdepf2,yes,ver-, >>& "/dev/null")
    rename (outdep2,outdepf2,field="all")
    }
  
  imnum = num
  delete (flog,yes,ver-)
  delete (inli,yes,ver-)

  list1 = ""
  list2 = ""
  list3 = ""
  list4 = ""

end
     
