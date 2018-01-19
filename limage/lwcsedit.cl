# lwcsedit - add keywords to header 
# 
procedure lwcsedit (input)

string  input   {"",prompt="Name of file list of dither images"}
string  instrument {"liris",enum="liris|ingrid",prompt="Instrument"}
real	wxoff	{0.,prompt="X offset of the WCS origin (in pixels)"}
real	wyoff	{0.,prompt="Y offset of the WCS origin (in pixels)"}
string *list1 	{prompt="Ignore this parameter"}

begin

real 	skyrot,wxrot,wyrot,pixscl,wxref1,wyref1,wxoff1,wyoff1
string 	ini,ilist,instr,prepostli

instr = instrument

if (instr == "liris") {
  pixscl = 0.25
}

if (instr == "ingrid") {
  pixscl = 0.242
}

wxoff1 = wxoff
wyoff1 = wyoff

ilist = mktemp("_lwcsdtlst")
sections(input,option="fullname",> ilist)

prepostli = mktemp(tmpdir//"_lwcsli")
  
llistdiff (input = "@"//ilist,         
              output = prepostli,             
               pname = "",     
             verbose = no,
              tmpdir = tmpdir)
	      
list1 = prepostli


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
    
    imgets(ini,"i_naxis1")
    wyref1 = real(imgets.value)/2. - wyoff
    
    print("x,y ",wxref1,wyref1)
    
    
    awcspars.wraunit="hours"
    awcspars.wdecuni="degrees"

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

       
  }
  

delete("_lwcsdtlst*",ver-,>>& "/dev/null") 

end 
