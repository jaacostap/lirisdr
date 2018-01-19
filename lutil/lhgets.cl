# lhgets - get the value of an image header parameter as a string
#          of LIRIS images in all formats
# Author : Miguel Charcos (mcharcos@ll.iac.es)
# Version: 12. Feb. 2002
##############################################################################
procedure lhgets (image)

string	image 	{prompt= "image name"}
string	param 	{prompt= "image parameter to be returned"}
string	value 	{prompt= "output value of image parameter"}

begin

  string	ini
  
  ini = image

  lcheckfile(ini,verbose-)
  
  if (lcheckfile.format == "ImpB")
    {
    imgets(ini,param=param)
    value = imgets.value
    }
  else if (lcheckfile.format == "UNIC")
    {
    imgets(ini,param=param, >& "dev$null")
    value = imgets.value
    }
  else if (lcheckfile.format == "UDAS")
    {
    imgets(ini//"[0]",param=param, >& "dev$null")
    value = imgets.value
    }
  else
    {
    print "WARNING: image format not recognised"
    value = 0
    }    

end
