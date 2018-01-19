procedure lmkcyclst (input,ncyc,output)

string input 	{prompt="List of images to create lists"}
int ncyc	{prompt="Number of images per cycle"}
string output	{prompt="File containing list of images per cycle"}
string listnam	{prompt="Name of list files"}

string *list1	{prompt="Ignore this parameter(list1)"}

begin

string in, out, tmpl, flist, imname
int	nc, icyc

in = input
out = output

  tmpl = mktemp (tmpdir//"lconstlisttmp")
  files(in,>tmpl)
  
  list1 = tmpl
  nc = 0
  icyc = 1
  flist = listnam//"_1"

   while (fscan(list1,imname) != EOF) 
    {
      print (imname, >> flist)
      if (nc == ncyc) 
        {
	  nc = 0
	  icyc = icyc + 1
	  flist = listnam//"_"//str(icyc)
	} 
      else 
        {
	  nc = nc + 1
	}  
    }



end
