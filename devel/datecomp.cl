# datecomp - compare date one and date two
# Author : Miguel Charcos (mcharcos@ll.iac.es)
# Version: 22. Sep. 2003
##############################################################################
procedure datecomp (input1,input2)

string	input1		{prompt="Date one"}
string	input2		{prompt="Date two"}
string	oneisoftwo	{prompt="One is (none|inf|sup|eq|all) compare with two?"}
bool	verbose		{no,prompt="verbose?"}

begin

  int	d11,d12,d13
  int	d21,d22,d23
  
  # We verify if date one and two are "*-*-*"
  # this mean that result is all, i.e. all case can be considered
  if (input1 == "*-*-*" || input2 == "*-*-*")
    {
    if (verbose) {print "INFO: an image is *-*-* type"}
    oneisoftwo = "all"
    bye
    }
  
  if (fscanf(input1,"%d-%d-%d",d11,d12,d13) == EOF)
    {
    if (verbose) {print "WARNING: image 1 has bad format"}
    oneisoftwo = "none"
    bye
    }
  
  if (fscanf(input2,"%d-%d-%d",d21,d22,d23) == EOF)
    {
    if (verbose) {print "WARNING: image 1 has bad format"}
    oneisoftwo = "none"
    bye
    }

  if (d11 == d21) 
    {
    if (d12 == d22)
      {
      if (d13 == d23)
        {
	if (verbose) {print "INFO: date one and two are the same"}
	oneisoftwo = "eq"
     	bye
	}
      else
        {
	if (d13 > d23) 
          {
     	  if (verbose) {print "INFO: date one is bigger than date two"}
     	  oneisoftwo = "sup"
     	  bye
     	  }
        else
     	  {
     	  if (verbose) {print "INFO: date one is smaller than date two"}
     	  oneisoftwo = "inf"
     	  bye
     	  }
	}
      }
    else
      {
      if (d12 > d22) 
        {
     	if (verbose) {print "INFO: date one is bigger than date two"}
     	oneisoftwo = "sup"
     	bye
     	}
      else
     	{
     	if (verbose) {print "INFO: date one is smaller than date two"}
     	oneisoftwo = "inf"
     	bye
     	}
      }
    }
  else 
    {
    if (d11 > d21) 
      {
      if (verbose) {print "INFO: date one is bigger than date two"}
      oneisoftwo = "sup"
      bye
      }
    else
      {
      if (verbose) {print "INFO: date one is smaller than date two"}
      oneisoftwo = "inf"
      bye
      }
    
    }
end
