# lpwcsedit - add keywords to header 
# 
procedure lpwcsedit (input)

string  input   {"",prompt="Name of file list of dither images"}
string  instrument {"liris",enum="liris|ingrid",prompt="Instrument"}
real	wxoff	{0.,prompt="X offset of the WCS origin (in pixels)"}
real	wyoff	{0.,prompt="Y offset of the WCS origin (in pixels)"}
string *list1 	{prompt="Ignore this parameter (list1)"}
string *list2 	{prompt="Ignore this parameter (list2)"}
string *list3 	{prompt="Ignore this parameter (list3)"}
string *list4 	{prompt="Ignore this parameter (list4)"}

begin

real 	skyrot,wxrot,wyrot,pixscl,wxref1,wyref1,wxoff1,wyoff1
string 	ini,ilist,instr
string  ilist0, ilist90, ilist45, ilist135
string  ini1, ini2, ini3, ini4
int	nsc

instr = instrument

if (instr == "liris") {
  pixscl = 0.25
}

if (instr == "ingrid") {
  print,"WARNING: This routine may not work for INGRID data")
  pixscl = 0.242
}

wxoff1 = wxoff
wyoff1 = wyoff


## The coordinates are read from the 90 degree section, the same 
## coordinates are applied to the remaining three sections
ilist = mktemp("_lwcsdtlst")
ilist0 = mktemp("_lwcsdtlst0")
ilist90 = mktemp("_lwcsdtlst90")
ilist45 = mktemp("_lwcsdtlst45")
ilist135 = mktemp("_lwcsdtlst135")

sections(input,option="root",> ilist)
sections(input//"_0",option="fullname",> ilist0)
sections(input//"_90",option="fullname",> ilist90)
sections(input//"_45",option="fullname",> ilist45)
sections(input//"_135",option="fullname",> ilist135)

print("list0 ")
type (ilist0)
type (ilist90)
type (ilist45)
print("list135 ")
type (ilist135)

list1 = ilist90
list2 = ilist0
list3 = ilist45
list4 = ilist135

while (fscan(list1,ini) != EOF)
  {
    imgets(ini,"ROTSKYPA")
    skyrot = real(imgets.value)
    wxrot = 180 - skyrot
    wyrot = 0. - skyrot
    
    #print("wxrot ",wxrot)
    #print("wyrot ",wyrot)
    imgets(ini,"i_naxis1")    
    
    wxref1 = real(imgets.value)/2. - wxoff
    
    imgets(ini,"i_naxis2")
    wyref1 = real(imgets.value)/2. - wyoff
    
    #print("x,y ",wxref1,wyref1)

    ahedit(ini,"",wcsedit=yes,hupdate=yes,wcs="none",wraref="RA",wdecref="DEC",
       wsystem="EQUINOX",wxref=wxref1,wyref=wyref1,wxmag=pixscl,wymag=pixscl,
       wxrot=wxrot,wyrot=wyrot,hdredit=no)
       
    hedit(ini,"PV1_1",0.0,delete=yes,add-,addon-,verify=no,>>& "/dev/null")
    hedit(ini,"PV1_2",0.0,delete=yes,add-,addon-,verify=no,>>& "/dev/null")
    hedit(ini,"PV2_1",0.0,delete=yes,add-,addon-,verify=no,>>& "/dev/null")
    hedit(ini,"PV2_2",0.0,delete=yes,add-,addon-,verify=no,>>& "/dev/null")
    
    hedit(ini,"PROJP1",0.0,delete=yes,add-,addon-,verify=no,>>& "/dev/null")
    hedit(ini,"PROJP2",0.0,delete=yes,add-,addon-,verify=no,>>& "/dev/null")
    hedit(ini,"PROJP3",0.0,delete=yes,add-,addon-,verify=no,>>& "/dev/null")

    nsc = fscan(list2,ini2)
    print("nsc ",nsc)
    ahedit(ini2,"",wcsedit=yes,hupdate=yes,wcs="none",wraref="RA",wdecref="DEC",
       wsystem="EQUINOX",wxref=wxref1,wyref=wyref1,wxmag=pixscl,wymag=pixscl,
       wxrot=wxrot,wyrot=wyrot,hdredit=no)
       
    hedit(ini2,"PV1_1",0.0,delete=yes,add-,addon-,verify=no,>>& "/dev/null")
    hedit(ini2,"PV1_2",0.0,delete=yes,add-,addon-,verify=no,>>& "/dev/null")
    hedit(ini2,"PV2_1",0.0,delete=yes,add-,addon-,verify=no,>>& "/dev/null")
    hedit(ini2,"PV2_2",0.0,delete=yes,add-,addon-,verify=no,>>& "/dev/null")
    
    hedit(ini2,"PROJP1",0.0,delete=yes,add-,addon-,verify=no,>>& "/dev/null")
    hedit(ini2,"PROJP2",0.0,delete=yes,add-,addon-,verify=no,>>& "/dev/null")
    hedit(ini2,"PROJP3",0.0,delete=yes,add-,addon-,verify=no,>>& "/dev/null")

    nsc = fscan(list3,ini3)
    print("nsc ",nsc)
    ahedit(ini3,"",wcsedit=yes,hupdate=yes,wcs="none",wraref="RA",wdecref="DEC",
       wsystem="EQUINOX",wxref=wxref1,wyref=wyref1,wxmag=pixscl,wymag=pixscl,
       wxrot=wxrot,wyrot=wyrot,hdredit=no)
       
    hedit(ini3,"PV1_1",0.0,delete=yes,add-,addon-,verify=no,>>& "/dev/null")
    hedit(ini3,"PV1_2",0.0,delete=yes,add-,addon-,verify=no,>>& "/dev/null")
    hedit(ini3,"PV2_1",0.0,delete=yes,add-,addon-,verify=no,>>& "/dev/null")
    hedit(ini3,"PV2_2",0.0,delete=yes,add-,addon-,verify=no,>>& "/dev/null")
    
    hedit(ini3,"PROJP1",0.0,delete=yes,add-,addon-,verify=no,>>& "/dev/null")
    hedit(ini3,"PROJP2",0.0,delete=yes,add-,addon-,verify=no,>>& "/dev/null")
    hedit(ini3,"PROJP3",0.0,delete=yes,add-,addon-,verify=no,>>& "/dev/null")

    nsc = fscan(list4,ini4)
    print("nsc ",nsc)
    ahedit(ini4,"",wcsedit=yes,hupdate=yes,wcs="none",wraref="RA",wdecref="DEC",
       wsystem="EQUINOX",wxref=wxref1,wyref=wyref1,wxmag=pixscl,wymag=pixscl,
       wxrot=wxrot,wyrot=wyrot,hdredit=no)
       
    hedit(ini4,"PV1_1",0.0,delete=yes,add-,addon-,verify=no,>>& "/dev/null")
    hedit(ini4,"PV1_2",0.0,delete=yes,add-,addon-,verify=no,>>& "/dev/null")
    hedit(ini4,"PV2_1",0.0,delete=yes,add-,addon-,verify=no,>>& "/dev/null")
    hedit(ini4,"PV2_2",0.0,delete=yes,add-,addon-,verify=no,>>& "/dev/null")
    
    hedit(ini4,"PROJP1",0.0,delete=yes,add-,addon-,verify=no,>>& "/dev/null")
    hedit(ini4,"PROJP2",0.0,delete=yes,add-,addon-,verify=no,>>& "/dev/null")
    hedit(ini4,"PROJP3",0.0,delete=yes,add-,addon-,verify=no,>>& "/dev/null")
    
       
  }
  

delete("_lwcsdtlst*",ver-,>>& "/dev/null") 

end 
