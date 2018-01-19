# lhigherdate - search which of input date is higher 
# Author : Miguel Charcos (mcharcos@ll.iac.es)
# Version: 12. Jan. 2004
##############################################################################
procedure lhigherdate(date1,date2)

string	date1	{prompt="first input date (YYYY-MM-DD)"}
string	date2	{prompt="second input date (YYYY-MM-DD)"}
int	result	{prompt="Output result (-1:undefined|0:equal|1:date1|2:date2)"}

begin

  int		dateyear1,datemonth1,dateday1
  int		dateyear2,datemonth2,dateday2
  real		datejul1,datejul2

  # We check if date is "*-*-*"
  # This mind that date is actual date
  if (date1 == "*-*-*")
    {
    if (date2 == "*-*-*") 
      {
      result = 0
      bye
      }
    else
      {
      result = 1
      bye
      }
    }
  else
    {
    if (date2 == "*-*-*") 
      {
      result = 2
      bye
      }
    # else no date are "*-*-*" type and we continue checking  
    }
  
  # We transform dates to julian date easier to be compared
  # if dates do not have wright format result is -1
  if (fscanf(date1,"%d-%d-%d",dateyear1,datemonth1,dateday1) != EOF)
    {
    asttimes (files = "",
    	     header = no,
    	observatory = "lapalma",
    	       year = dateyear1,
    	      month = datemonth1,
    		day = dateday1,
    	       time = 0, >>&"/dev/null")

    datejul1= asttimes.jd
    }
  else 
    {
    result = -1
    beep
    print("")
    print("ERROR: date no recognised")
    print("lhigherdate aborted")
    print("")
    beep
    bye
    }
  
  if (fscanf(date2,"%d-%d-%d",dateyear2,datemonth2,dateday2) != EOF)
    {
    asttimes (files = "",
    	     header = no,
    	observatory = "lapalma",
    	       year = dateyear2,
    	      month = datemonth2,
    		day = dateday2,
    	       time = 0, >>&"/dev/null")

    datejul2= asttimes.jd
    }
  else 
    {
    result = -1
    beep
    print("")
    print("ERROR: date no recognised")
    print("lhigherdate aborted")
    print("")
    beep
    bye
    }
    
    
  # We compare dates
  if (date1 == date2) {result = 0}
  else if (date1 > date2) {result = 1}
  else if (date2 > date1) {result = 2}
    
end
