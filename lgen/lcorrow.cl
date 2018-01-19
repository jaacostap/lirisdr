# lcorrow - correction of bad rows  
# Author : Miguel Charcos (mcharcos@ll.iac.es)
# Version: 06. Feb. 2004
##############################################################################
procedure lcorrow (input,output)

string	input		{prompt="Name of input image"}
string	output		{prompt="Name of output image"}


begin

  string	intmp,outtmp
  string	inext,outext
  
  outtmp = output
  intmp = input
  
  limgaccess(intmp,verbose+)
  if (!limgaccess.exists)
    {
    beep
    print("")
    print("ERROR: input image does not exist")
    print("lcorrow aborted")
    print("")
    beep
    bye
    }
  else
    {intmp = limgacces.real_name}
    
  lfilename(intmp)
  inext = lfilename.ext
  
  lfilename(outtmp) 
  if (lfilename.ext == "") outtmp=outtmp//"."//inext
  
  limgaccess(outtmp,verbose+)
  if (limgaccess.real_name == outtmp)
    {
    beep
    print("")
    print("ERROR: output image already exists")
    print("lcorrow aborted")
    print("")
    beep
    bye
    }
  
  intmp = osfn(intmp)
  outtmp = osfn(outtmp)  
  corrow(intmp,outtmp) 
   
end
