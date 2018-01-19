# lnamelist - generate a list with names 
# Author : Miguel Charcos (mcharcos@ll.iac.es)
# Version: 14. Jan. 2004
##############################################################################
procedure lnamelist (input,output)

string	input		{prompt="Name of list containing main names"}
string	output	{prompt="Name of output file"}
string  	bname		{"",prompt="Basic name for creating random name list"}
string	pname		{"p",prompt="Prefix name used if do not bname"}
string	refname	{"",prompt="List of reference image names"}
int		maxnum	{INDEF,prompt="Maximum number of images in output list"}
string	extens	{"",prompt="Extension for image names"}
string  tmpdir		{")_.tmpdir",prompt="Temporary directory for file conversion"}

string *list1	{prompt="Ignore this parameter(list1)"}
string *list2	{prompt="Ignore this parameter(list2)"}

begin

  string	out,inlist,reflist,tmpl
  string 	fname,newname,extension,imref,imroot
  int 		cont,contmax

  out = output
  extension = extens
  
  inlist = mktemp(tmpdir//"lnamelistinlist")
  sections(input,option="fullname",>inlist)
  
  if (access(out))
    {
    beep
    print("")
    print("ERROR: operation would overwrite output file "//out)
    print("lnamelist aborted")
    print("")
    beep
    bye
    }
  
  tmpl = refname
  if (tmpl != "")
    {
    reflist = mktemp(tmpdir//"lnamelistreflist")
    sections(tmpl,option="fullname",>reflist)
    } # end of if (tmpl != "")
  else
    {
    reflist = ""
    } # end of else [if (tmpl != "")]
  
  cont = 0
  if (maxnum == INDEF) {contmax=1}
  else {contmax=maxnum}
  
  if (bname == "")
    {
    list1 = inlist
    if (reflist != "") list2 = reflist
    While (fscan(list1,fname) != EOF && cont<contmax)
      {
      if (reflist != "")
        {
	  if (fscan (list2,imref) != EOF)
	    {
	    lfilename(imref)
	    if (lfilename.reference == "")
	      {imref = "_"//lfilename.root}
	    else {imref = "_"//lfilename.reference}
	    }
	  else {imref = ""}
	  }
      else {imref = ""}
      
      lfilename(fname)
      if (lfilename.reference == "")
        {imroot = imref}
      else
        {imroot	= lfilename.reference}
	
      if (extension == "") 
        {
	  if (lfilename.ext == "")
	    {newname = pname//imroot}
	  else 
	    {newname = pname//imroot//"."//lfilename.ext}
	  }
      else {newname = pname//imroot//"."//extension}
        print(newname, >> out)
      
	if (maxnum != INDEF) {cont = cont + 1}
      }
    }
  else
    {
    list1 = inlist
    if (reflist != "") list2 = reflist
    While (fscan(list1,fname) != EOF && cont<contmax)
      {
      newname = mktemp(bname)
      
      if (reflist != "")
        {
	if (fscan (list2,imref) != EOF)
	  {
	  lfilename(imref)
	  if (lfilename.reference == "")
	    {imref = "_"//lfilename.root}
	  else {imref = "_"//lfilename.reference}
	  }
	else 
	  {imref = ""}
	}
      else {imref = ""}
      
      lfilename(fname)
      
      if (extension == "")
        {
	if (lfilename.ext != "")
	  {newname = newname//imref//"."//lfilename.ext}	
	else {newname = newname//imref}
	}
      else {newname = newname//imref//"."//extension}
      print(newname, >> out)
      if (maxnum != INDEF) {cont = cont + 1}
      }
    }
  
  delete (inlist,yes,ver-)
  delete (reflist,yes,ver-)
    
  list1 = ""
  list2 = ""
    
end 
