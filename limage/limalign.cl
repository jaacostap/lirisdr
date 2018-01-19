## a file with the initial guess for coordinates is passed 
## the program imcentroid is used to compute the accurate shift for
## each image

## The stars are found using starfind
procedure limalign (input, incoords, ocoords)

string input	   {"",prompt="List of input images"}
string incoords	   {"",prompt="File containing aproximate coordinates"}
string ocoords	   {"",prompt="File containing computed integer offsets"}
string ofshift     {"",prompt="File containing computed fractional offsets"}
bool   addinam     {no,prompt="Add image name to offset files?"}
string output 	   {"",prompt="List of successfully registered images"}
string istars      {"",prompt="List of stars used to register images (input)"}
string ostars	   {"",prompt="List of stars used to register images (output)"}
real psf	   {4,prompt="Value of the PSF - FWHM (pixels)"}
real threshold	   {5.,prompt="Threshold in sigma for object detections"}
pset lstarfindpars {prompt="Parameter set for star finding algorithm"}
int cboxsize	   {15,prompt="Size of the centering box"}
string statsec	   {"",prompt="Image section to compute statistics"}
string	tmpdir	   {")_.tmpdir",prompt="Temporary directory for file conversion"}

string *list1	{prompt="Ignore this parameter(list1)"}
string *list2	{prompt="Ignore this parameter(list2)"}
string *list3	{prompt="Ignore this parameter(list3)"}

begin 

string imref,refcoo,inim,inli,outli
string ilist,tmpshifts,coorfile,censhift,ocrds,ofcrds,ext1
string dumm
real hpsf,athreshold,md,qua1,qua3
real xsh,ysh,xxsh,xxsh_int,xxsh_frac,yysh,yysh_int,yysh_frac,exxsh,eyysh
real xoff,yoff
real xcur,ycur
int npmin,boxsz,fsigma,nimag,ifs,nsc
bool  addinam1 

hpsf = psf
#boxsz = int(psf*1.5+0.5)
if (cboxsize == INDEF)
  boxsz = hpsf*4.
else 
  boxsz = cboxsize
  
addinam1 = addinam

coorfile = incoords

ocrds = ocoords
ofcrds = ofshift

inli = mktemp(tmpdir//"_limlgninm")
sections(input,option="fullname",>inli)

if (output != "") 
  outli = output
else 
  outli = mktemp(tmpdir//"_limlgnoutim")  

## The reference image is taken as the first image in the list
list1 = inli
ifs = fscan(list1,imref)
ext1 = ""
lcheckfile(imref)
if (lcheckfile.nimages > 0)
   ext1 = "[1]"

## first compute statistics to determine detection threshold
lstatist(imref//ext1//statsec,maxiter=3,addheader=no,lower=INDEF,upper=INDEF,oneparam="all",verbose=no,print=no)
qua1 = lstatist.quart1
qua3 = lstatist.quart3
fsigma = threshold
athreshold = fsigma*(qua3 - qua1)/1.36
npmin = int(3.14*hpsf*hpsf+0.5)
#if (verb) print ("athreshold ",athreshold," - npmin ",npmin)
 

if (!access(istars)) 
  {
    print ("Automatic search of objects to perform image alignment")
 
    ## search reference stars

    if (ostars != "")
       refcoo = ostars
    else 
       refcoo = mktemp(tmpdir//"_limlgn")

    starfind(image = imref//ext1,             
            output = refcoo,      
           hwhmpsf = hpsf,              
         threshold = athreshold,           
           datamin = qua1,         
           datamax = 20000,          
           fradius = lstarfindpars.fradius,            
            sepmin = lstarfindpars.sepmin,            
           npixmin = npmin,             
             maglo = INDEF,          
             maghi = INDEF,          
           roundlo = lstarfindpars.roundlo,             
           roundhi = lstarfindpars.roundhi,            
           sharplo = lstarfindpars.sharplo,            
           sharphi = lstarfindpars.sharphi,             
               wcs = "physical",             
          wxformat = "",             
          wyformat = "",             
          boundary = "reflect",      
          constant = 0.,             
           nxblock = 256,          
           nyblock = 256,            
           verbose = no)    

  } else {
     refcoo = istars
  }

list1 = inli
list2 = coorfile
nimag = 1
while (fscan(list1,inim) != EOF) 
  {
    if (fscan(list2,xsh,ysh) == EOF)
      { 
	  print ("ERROR: missing initial shifts") 
	  bye
      }
	
    if (nimag > 1)  
      {
	 ilist = mktemp(tmpdir//"_limlgnilst")
	 tmpshift = mktemp(tmpdir//"_limlgntshft")
	 censhift = mktemp(tmpdir//"_limlgncshft")
         ext1 = ""
         lcheckfile(inim)
         if (lcheckfile.nimages > 0)
            ext1 = "[1]"
	 print(imref//ext1,>ilist)
	 print(inim//ext1,>>ilist)
	 xcur = xsh + xoff 
	 ycur = ysh + yoff
	 print(0,0,> tmpshift)
	 print(xcur,ycur,>> tmpshift)
	 imcentroid("@"//ilist,imref//ext1,refcoo,shifts=tmpshift,boxsize=boxsz,
	    background=athreshold,maxshift=INDEF,verb-,>censhift)
         #limcentroid("@"//ilist,refcoo,inshift=tmpshift,outshift=censhift,boxsize=boxsz,
	 #   background=athreshold,verb+)
	 list3 = censhift   
	 while (fscan(list3,dumm) != EOF)
	   {
	     if (dumm == "#Shifts") 
	       {
	         ## the first one contains the reference image, 0, 0
                 ifs= fscanf(list3,"%s %f (%f) %f (%f)",dumm,xxsh,exxsh,yysh,eyysh)
	         ifs= fscanf(list3,"%s %f (%f) %f (%f)",dumm,xxsh,exxsh,yysh,eyysh)
		 nsc = nscan()
		 if (nsc > 0) { 
		   xoff = xxsh - xsh
		   yoff = yysh - ysh
		   xxsh_int = nint(xxsh) 
		   yysh_int = nint(yysh) 
		   xxsh_frac = nint((xxsh-xxsh_int)*100.)/100.
		   yysh_frac = nint((yysh-yysh_int)*100.)/100.
		   if (!addinam1) 
	             print(xxsh_int," ",yysh_int,>>ocrds)
		   else  
	             print(inim,"   ",xxsh_int," ",yysh_int,>>ocrds)
		   if (ofcrds != "") 
		    {
		      if (!addinam1) 
		       print(xxsh_frac," ",yysh_frac, >>ofcrds) 
		      else 
		       print(inim,"   ",xxsh_frac," ",yysh_frac, >>ofcrds)		        		     		   
                    }
		   print(inim,>>outli)
	           print("xsh,ysh=",xxsh," ",yysh)
	         } else 
	           print("Warning: Shift cannot be determined for image ",inim)
	       } 
	   } 
	 delete(ilist,veri-)
	 delete(tmpshift,ver-)
      }
    else 
      {
         print(inim,>outli)
         if (!addinam1) {
	   print(0," ",0,>ocrds)
	   if (ofcrds != "")
	      print(0," ",0,>ofcrds)
	 } else {
	   print(inim,"   ",0," ",0,>ocrds)
	   if (ofcrds != "")
	      print(inim,"   ",0," ",0,>ofcrds)
         }	    
	 xoff = 0.
	 yoff = 0.
      }  
    nimag = nimag + 1  
  }
  
  
## clean up
delete(inli,ver-) 
delete("_limlgn*",ver-)
bye

end  
