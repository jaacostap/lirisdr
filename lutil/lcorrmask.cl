# lcorrmask - when image with values between 0 and 1
#	      values are corrected to build a mask with 0 and 1 
# Author : Miguel Charcos (mcharcos@ll.iac.es)
# Version: 13. Jan. 2004
##############################################################################
procedure lcorrmask (input)

string	input		{prompt="Input image to be transform on mask"}

real	limit		{0.5,min=0.,max=1.,prompt="Limit value of goodvalues"}

begin
  
  string	ini
  
  ini = input
  
  imreplace (input,1.,upper=limit,lower=INDEF,radius=0.)
  imreplace (input,0.,lower=limit,upper=INDEF,radius=0.)

end
