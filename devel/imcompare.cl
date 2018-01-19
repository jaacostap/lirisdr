# imcompare - compare image list with reference image
# Author : Miguel Charcos (mcharcos@ll.iac.es)
# Version: 30. Jul. 2003
##############################################################################
procedure imcompare (input,output)

string 	input	{prompt="List of images for comparing"}
string	output	{prompt=""}
string	imref	{prompt="Reference image for comparation"} 
string	tmpdir	{prompt="Temporary directory for file conversions"}
bool	verbose	{prompt="Verbose?"}
bool	filter	{prompt="Correspond of the same filter"}
bool	date	{prompt="Correspond of the same date"}
bool	object	{prompt="Correspond of the same object"}
bool	position{prompt="Unable at the moment"}
bool	group	{prompt="Correspond of the same observation group (date&filter)"}

string *list1	{prompt="Ignore this parameter (list1)"}

begin

  string	inlist,inref,tmpl
  string	imobj,refobj,imfilt,reffilt,imdat,refdat,imgroup,refgroup,refname,imname
  string 	fname
  int 		nsc
  bool		first
  bool		name
  
  #----------------------------------------------------------------------------
  # Variable verification
  #----------------------------------------------------------------------------
  if (verbose)
    {
    print ""
    print "verification of variables"
    }
    
  inlist = mktemp(tmpdir//"imcompareinl")
  
  # expand input image names.
  tmpl = mktemp(tmpdir//"imcomparetmp")
  sections(input,option="fullname",> tmpl)
  
  # make sure we have some input files ... bail out if we don't
  first = yes
  list1 = tmpl
  while (fscan(list1, fname) != EOF)
    {
    imgaccess(fname, verbose=no)
    if ( imgaccess.exists ) 
      {
      print(fname,>>inlist)
      first = no
      }
    }
  delete(tmpl,yes,verify=no)

  if ( first )
    {
    beep
    print("")
    print("ERROR: no input files found.")
    print("imcompare aborted")
    print("")
    beep
    bye
    }
    
  
  # expand reference image name.
  tmpl = mktemp(tmpdir//"imcompare")
  sections(imref,option="fullname",> tmpl)
  list1 = tmpl
  nsc = fscan(list1, inref)
  delete(tmpl,yes,verify=no)
  
  # check if output image exists
  imgaccess(inref, verbose=no)
  if ( !imgaccess.exists )
    {
    beep
    print("")
    print("ERROR: no reference image found.")
    print("imcompare aborted")
    print("")
    beep
    bye
    }
    
  if (verbose)
    {
    print ("variables verified")
    print ""
    }
  #----------------------------------------------------------------------------
  # End of variable verification
  #----------------------------------------------------------------------------
  
  
  
  #----------------------------------------------------------------------------
  # Comparing images
  #----------------------------------------------------------------------------
  if (verbose)
    {
    print ""
    print "comparing images ..."
    }
    
  filter = yes
  imgets(image=inref,param="LIRF1NAM")
  reffilt = imgets.value
  imgets(image=inref,param="LIRF2NAM")
  reffilt = reffilt//(imgets.value)
  print (reffilt)
  
  date = yes
  imgets(image=inref,param="DATE-OBS")
  refdat = imgets.value
  print (refdat)
  
  object = yes
  imgets(image=inref,param="OBJECT")
  refobj = substr(imgets.value, 1, 2)//substr(imgets.value, 4, 13)
  print (refobj)
  
  name = yes
  nsc=fscan(imref,"%s.fit",refname)
  print (nsc)
  print (refname)
  nsc=nscan()
  print (nsc)

  group = yes
 
  list1 = inlist
  While (fscan(list1,fname) != EOF)
    {
    
    # Check for filter in two images
    imgets(image=inref,param="LIRF1NAM")
    imfilt = imgets.value
    imgets(image=inref,param="LIRF2NAM")
    imfilt = imfilt//(imgets.value)
    if (imfilt != reffilt)
      {
      print (imfilt)
      filter = no
      }
    
    
    # Check for date of observation for two images
    imgets(image=fname,param="DATE-OBS")
    imdat = imgets.value
    if (imdat != refdat)
      {
      print (imdat)
      date = no
      }
      
      
    # Check for type of observation for two images
    imgets(image=fname,param="OBJECT")
    imobj = imgets.value
    if (imobj != refobj)
      {
      print (imobj)
      object = no
      }
    
    # Check for file name of observation for two images
    imgets(image=fname,param="$I")
    #imgets.value|scanf("%s.fit",imname)
    #if (imname != refname)
    #  {
    #  print (imname)
    #  name = no
    #  }
    
    
    if (!(filter && date))
      {
      if (verbose)
        print ("The image ",fname," do not correspond to the ",inref," image group")
      group = no
      }
    else
      {
      if (verbose)
        print ("The image ",fname," correspond to the ",inref," image group")
      }
    }
  
  if (verbose)
    {
    print "Images compared"
    print ""
    }
  #----------------------------------------------------------------------------
  # End of images comparation
  #----------------------------------------------------------------------------
  
  
  #----------------------------------------------------------------------------
  # Determine similitud between images
  #----------------------------------------------------------------------------
  
  
  
  #----------------------------------------------------------------------------
  # End of determination of similitud between images
  #----------------------------------------------------------------------------
  
end
