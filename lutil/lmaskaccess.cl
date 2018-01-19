# lmaskaccess - checks if a mask exists and is correctly
# Author     : Miguel Charcos Llorens (mcharcos@ll.iac.es)
# Last Change: 30. Jul. 2003
##############################################################################
procedure lmaskaccess(input)

file	input		{prompt="Input image"}
bool	exists		{prompt="does the file exists ?"}
bool	verbose		{prompt="Verbose ?"}

begin

  string	imgname,ext
  int		p,pos

  # copy input arguments to force definition at the beginning of the script
  imgname=input

  # default output values
  exists = no

  # find last "." in image name
  p = stridx( ".",imgname )
  pos = p
  while ( p != 0 && pos != strlen(imgname) )
    {
    p = stridx( ".",substr(imgname,pos+1,strlen(imgname)))
    pos = pos+p
    }

  # check if output image exists already
  # If an extension was part of the file name check if it is one of the
  # image formats. If not, try all common extensions.
  ext = ""
  if ( pos > 0 )
    {
    ext = substr(imgname,pos+1,strlen(imgname))
    if ( ext != "pl" )
      {
      ext = ""
      }
    }

  # (I should really check for fxf in imextn to find strange extensions ... )
  if ( ext == "" )
    {
    if ( access(imgname//".pl") )
      {
      exists = yes
      }
    }
  else
    {
    if ( access(imgname) ) { exists = yes }
    }

  # print verbose infromation about our findings if it was asked for
  if ( verbose )
    {
    if ( exists ) { print "image "//imgname//" exists" }
    else          { print "image "//imgname//" does not exist" }
    }

end
