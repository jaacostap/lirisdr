#  lspgetoff - determine offset from peak of the spectra
procedure lspgetoff(input,ofshift,ofintshift)
string 	input        {"",prompt="Name of spectra "}
string  ofshift	     {"",prompt="File containing offsets "}
string  ofintshift   {"",prompt="File containing integer offsets "}
int  	dispaxis     {1,prompt="Dispersion axis"}
string 	xcrsample	{"*",prompt="Range of pixels along slit used for cross correlation"}
int	round	     {0,prompt="Number of decimal digits"}
bool	verbose	     {no,prompt="Print operations?"}

string *list1 	{prompt="Ignore this parameter"}
string *list2 	{prompt="Ignore this parameter"}

begin
  real		md, xmax, rjunk, x1, x2,soff,xcent,soff_frac
  real		fpmax=0.
  string	inli,im,improj,imtrim,fproj,iproj,iprojref,cross, pfitprof
  string	foffset, fintoffset	
  int		dpaxis, ifirst, digi1
  string	oftprf,sreg,sreg1,sreg2,tmplog,word,xcrsample1
  string	junk
  bool		verb1
  
  dpaxis= dispaxis
  verb1 = verbose
  digi1 = round
  xcrsample1 = xcrsample
  
  
# expand input image name.
  inli = mktemp("_sffcmb")
  sections(input,option="fullname",> inli)
  
  if (xcrsample1 == "") {xcrsample1 = "*"} 

## first project the spectra onto one dimension and at the same time 
##   suppress the negative values
  list1 = inli
  fproj = mktemp("_fproj")
  while(fscan(list1,im) != EOF) 
    {
       improj = mktemp("_improj")
	   ## trim along the slit to avoid border effects
	   imtrim = mktem("_imtrm")
	   imcopy (im//"[*,"//xcrsample1//"]",imtrim)
       improject(imtrim,improj,dpaxis,average=yes)
       imstatistics(improj,fields="midpt",binwidth=0.01,format=no) | scan(md)
       imarith(improj,"-",md,improj)
       imreplace(improj,0.,upper=0.)
       print(improj,>>fproj)
    }


## taper and cross-correlate 
#tapering is needed for the boundaries

# crosscor    imglist = fproj
   list1 = fproj
   ifirst = 1 
   #foffset = mktemp("_foffset")
   foffset = ofshift
   fintoffset = ofintshift
   while(fscan(list1,iproj) != EOF)
     {
	wcsreset(iproj,"world")      
        # use first file as reference, otherwise perform correlation
        if (ifirst > 1)
	   {
               taper(iproj,"",width="10 %",subtract="none", function="cosbell",
	         verbose-, >& "dev$null")
	       cross = mktemp("_cross")
	       crosscor(iproj,iprojref,cross,inreal1=yes,inimag1=no,\
	          inreal2=yes,inimag2=no,outreal=yes,outimag=no,\
		  coord_shift=no,center=yes,chop=no,pad=yes,verb-)
	       # find the peak
	       minmax(cross,update-,verb-)
	       imgets(cross,"CRPIX1")
	       xcent = real(imgets.value)
	       printf ("%s\n", minmax.maxpix) | scanf ("[%f]", rjunk)
	       xmax = rjunk *1.	- xcent       
	       # use of fitprofs to get maximum 
	       x1 = xmax-8
	       x2 = xmax+8
	       printf("%.2f\n",x1) | scan(sreg1)
	       printf("%.2f\n",x2) | scan(sreg2)
	       sreg = sreg1//"  "//sreg2  
	       printf("x1=%.2f   x2=%.2f\n",x1,x2)  
	       pfitprof = mktemp("_pftprf")
	       print(xmax, >pfitprof)
	       oftprf = mktemp("_oftprf")
	       if (verb1) print("looking maximum within region: ",sreg)
	       ### refine peak to obtain sub-pixel value
	       soff = xmax
	       #print("ajustando ",cross)
	       ## poner valores de la region en funcion del desplazamiento
               tmplog = mktemp ("tmplog")
	       fitprofs(cross,dispaxis=1,nsum=1,region=sreg,pos=pfitprof,
	         profile="gaussian",gfwhm=9.,fitbackground=no,output="",
		 logfile=tmplog,verb+,>& "dev$null") 
	       list2 = tmplog
	       word = ""
	       while (fscan (list2, junk,word) != EOF) {
	          if (strstr("center",word) >0)
		       if (fscan(list2,rjunk) == EOF) {
		          print("ERROR - Fit not successful")
		       } else {
		          #print("Valor ajustado ",rjunk)
 		          soff = nint(10**digi1*(rjunk-xmax)) / 10.**digi1
		       }
	       }	
	       print("0 ",soff,>>foffset)	
	       print("0 ",int(xmax),>>fintoffset)	
	       if (verb1) {
	          print ("Fractional offset for  ",cross," is ",soff) 
	       	  print ("Integer offset for ",cross," is ",xmax)
	       }  
		  
	   }
	else
	   {
               taper(iproj,"",width="10 %",subtract="none", function="cosbell",
	         verbose-, >& "dev$null")
	       iprojref = iproj
	       print("0 0",>foffset) 	
	       print("0 0",>fintoffset) 	
	   }   
	   
	ifirst += 1  
     
     }
   
# now clean the temporary files

imdel("_improj*",ver-,>& "dev$null")
imdel("_cross*",ver-,>& "dev$null")
delete("_pftprf*",ver-,>& "dev$null")
delete("_oftprf*",ver-,>& "dev$null")
delete("_sffcmb*",ver-,>& "dev$null")
delete("_fproj*",ver-,>& "dev$null")
delete("_imtrm*",ver-,>& "dev$null")
delete("_foffset*",ver-,>& "dev$null")
delete("tmplog*",ver-
   
list1 = ""

     
end
