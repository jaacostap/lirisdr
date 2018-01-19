# lcheckfile - check the instrument used for adquisition and
#		checks if image is post-pre subtracted, UltraDAS or Imp. B
# Author     : Miguel Charcos (mcharcos@ll.iac.es)
# Last Change: 18. Jul. 2003
##############################################################################
procedure lcheckfile(input)

string	input		{prompt="Input image"}
bool	subtract	{prompt="post-pre check result"}
string	format		{prompt="format result (unknown|ImpB|UDAS|UNIC)"}
string	mode_aq		{prompt="store mode (unknown|PRE_POST|DIFF|DIFF_PRE|SLOPE|SLOPE_READS)"}
string 	instrument	{prompt="output type of instrument (unknown|LIRIS|INGRID)"}
int	nimages		{prompt="number of extensions in file"}
int	nwindows	{prompt="number of windows in file"}
bool	verbose		{no,prompt="Verbose ?"}

begin

  string	imgname,imgname1,shct,siqlpp,dateobs,imext
  int		naxis,spos
  int		dateday,datemonth,dateyear
  real		datejul,datejullim
  
  # copy input arguments to force definition at the beginning of the script
  imgname=input

  # default output values
  subtract = no
  format = "unknown"
  mode_aq = "unknown"
  instrument = "unknown"
  nimages = 0
  nwindows = 0

  # strip any section information [...] from the filename
  spos = stridx("[",imgname)
  if ( spos > 1 )
    {
    imgname = substr(imgname,1,spos-1)
    }

  # ----------------------------------------------------------------------
  # Find necessary information to destinguish DAS cases
  # ----------------------------------------------------------------------
  # find number of extensions in file
  limgaccess(imgname,verbose=no)
  imgname1 = limgaccess.real_name
  imextensions(input = imgname1,
               output = "none",
               index = "1-",
               extname = "",
               extver = "" )
  nimages = imextensions.nimages
  # I should use HCTVERSI= 'IMPB ISP V1.14    '  or ' LIRIS ISP V1.3' 
  if (nimages > 0 ) 
    imext = "[0]"
  else 
    imext = ""   
  hselect(images=imgname//imext, fields="HCTVERSI", expr="yes") | scanf("%s",shct)
  # ----------------------------------------------------------------------
  # End find necessary information to destinguish DAS cases
  # ----------------------------------------------------------------------

  

  # ----------------------------------------------------------------------
  # Find type of instrument
  # ----------------------------------------------------------------------
  imgets(image=imgname//imext, param="INSTRUME")
  if (imgets.value == "INGRID" )
    {
    instrument = "INGRID"
    }
  else if ( imgets.value == "LIRIS")
    {
    instrument = "LIRIS"
    } 
  else {}
  # ----------------------------------------------------------------------
  # End find type of instrument
  # ----------------------------------------------------------------------


  # ----------------------------------------------------------------------
  # Find format aquisition in the case of ingrid instrument
  # ----------------------------------------------------------------------
  if (instrument == "INGRID")
    {
    # only ImpB images should be 3D ...
    imgets(image=imgname//"[0]", param="i_naxis")
    naxis = int(imgets.value)

    # clear cut case, this is an ImpB image
    if ( substr(shct, 2, 5) == "IMPB" && nimages <= 0 )
      {
      format = "ImpB"
      }
 
    # clear cut case, this is an UDAS image
    if ( substr(shct, 2, 5) != "IMPB" && nimages > 0 )
      {
      format = "UDAS"
      }
 
    # problem case. Could be ImpB with missing header but very likely is
    # processed UDAS, now without extensions.
    if ( substr(shct, 2, 5) != "IMPB" && nimages <= 0 )
      {
      # There is one more check we can do. If the dimension of the data is 3,
      # then it should be an ImpB image. If it is 2, then it is likely UDAS ...
      if ( naxis == 3 )
   	{
   	format = "ImpB"
   	}
      else
   	{
   	format = "UNIC"
   	}
      }
    # problem case. ImpB should not have any extension !
    if ( substr(shct, 2, 5) == "IMPB" && nimages > 0 )
      {
      format = "ImpB"
      }

    # check if image is already post-pre subtracted
    #	For implementation B images this is the case if the image has two axis.
    #	For IR-UltraDAS this is the case if there are no extensions present.

    # for ImpB, check number of axis to see if the image was post-pre subtracted
    if ( format == "ImpB" )
      {
      if (naxis == 2)
   	{
   	subtract = yes
   	}
      }
    # for UltraDAS, check if either the image header IQL-PP is set to T
    # (this is done by iframediff) or if the number of image extensions
    # is 0.
    if ( format == "UDAS" )
      {
      hselect(images=imgname//"[0]", fields="IQL-PP", expr="yes") | scanf("%s",siqlpp)
      if ( imgets.value == "T" )
   	{
   	subtract = yes
   	}
      # UltraDAS also allows windowing. Read the number of windows from
      # the header.
      imgets(image=imgname//"[0]", param="NWINDOWS")
      nwindows = int(imgets.value)
      }
    }
  else if (instrument == "LIRIS")
    {
    # We verify if the observation date is before (Impb) or after (UDAS)
    # July 2003. We use Julian date because it is easier to compare dates
    
    asttimes (files = "",
             header = no,
        observatory = "lapalma",
               year = 2003,
              month = 07,
                day = 01,
               time = 0, >>&"/dev/null") 

    datejullim = asttimes.jd
    
    # We read header information of image and we transform date
    imgets(image=imgname//"[0]", param="DATE-OBS") 
    dateobs = imgets.value
    
    if (fscanf(dateobs,"%d-%d-%d",dateyear,datemonth,dateday) != EOF)
      {
      asttimes (files = "",
               header = no,
          observatory = "lapalma",
        	 year = dateyear,
        	month = datemonth,
        	  day = dateday,
        	 time = 0, >>&"/dev/null")

      datejul= asttimes.jd
      }
    else {datejul = datejullim}
    if ( nimages <= 0 )
      {
      subtract = yes
      if (datejul < datejullim) format = "ImpB"
      else format = "UNIC"
      }
    else 
      {
      subtract = no
      if (datejul >= datejullim) format = "UDAS"
      else format = "unknown"
      }
    }
  # ----------------------------------------------------------------------
  # End format aquisition type search
  # ----------------------------------------------------------------------
  
  # ----------------------------------------------------------------------
  # Find mode image
  # ----------------------------------------------------------------------
  if (instrument == "INGRID")
    {
    mode_aq = "PRE_POST"
    }
  else if (instrument == "LIRIS")
    {
    imgets(image=imgname//"[0]", param="STORMODE", >>&"/dev/null")
    if (imgets.value == "diff_pre")
      {mode_aq = "DIFF_PRE"}
    if (imgets.value == "normal")
      {mode_aq = "PRE_POST"}
    else if (imgets.value == "diff")
      {mode_aq = "DIFF"}
    }
  
  # ----------------------------------------------------------------------
  # End of find mode image
  # ----------------------------------------------------------------------
  
  if ( format == "UNIC" )  
    {
    subtract = yes 
    }



  if ( verbose )
    {
    if ( subtract )
      print (imgname//" is a post-pre subtracted image")
    else
      print (imgname//" has not been post-pre subtracted")

    print (imgname//" have acquired wiht a "//instrument//" instrument type")
    print (imgname//" is an "//format//" image")
    print (imgname//" is save as "//mode_aq//" mode")
    print (imgname//" has "//nimages//" extensions")
    print (imgname//" has "//nwindows//" windows")
    }

end
