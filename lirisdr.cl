#{ LIRIS_QL.CL -- Script to set up tasks in the LIRIS_QL package

cl < "lirisdr$lib/zzsetenv.def"

reset use_new_imt = no #; flpr 0

#add any packages that need to be loaded here
nproto
astutil
imred
ccdred
plot

astcat

twodspec
longslit
apextract
onedspec
#generic

artdata


## imcalc, improject, need stsdas 

if (deftask("stsdas")) {
   if ( !defpac("stsdas")) {
     stsdas motd-
     ;
   }
}
;

fourier


nproto

#comment out the next line if you do not want to use "istarfocus" and
#"ibpmgenerate" and don't have the external package nmisc installed.
#nmisc
task psfmeasure = "lirisbin$x_liris.e"
#task psfmeasure = "nmisc$src/x_nmisc.e"
task starfocus = "lirisbin$x_liris.e"
#task starfocus = "nmisc$bin.ssun/x_nmisc.e"
#task starfocus = "nmisc$src/x_nmisc.e"

#comment out the next two lines if you do not want to use "ifindron" and
#don't have the external package tables installed.
tables
ttools
fourier

immatch

#make sure we work with fits files
reset	imextn	= "fxf:fits,fit,fts"
reset	imtype	= "fits"

package lirisdr, bin = lirisbin$


  
## print welcome banner   
print (" ")
print("##################################################################")
print("#                                                                #")
print("#	   LIRISDR -  Package for LIRIS data reduction           #")
print("#                                                                #")
print("#                  Version ",lirisdr.version,"                   #")
print("#                                                                #")
print("##################################################################")


if (lirisdr.motd) 
 type lirisdr$lirisdr.motd
;

# Generic processing tasks
task 	lgen.pkg	= "lgen$lgen.cl"

# imaging tasks
task    limage.pkg    = "limage$limage.cl"

# Spectroscopy tasks	
task    lspect.pkg     = "lspect$lspect.cl"


# Spectra calibration tasks
set 	tellir 	        = "lirisdr$tellir/"
task    tellir.pkg      = "tellir$tellir.cl"


# Util tasks
task    lutil.pkg       = "lutil$lutil.cl"



# pset parameter files
task 	dispstep 	= "lirisdr$par/dispstep.par"
task 	lapopt 		= "lirisdr$par/lapopt.par"
task 	lapplot 	= "lirisdr$par/lapplot.par"
#task 	apallcomb 	= "lirisdr$par/apallcomb.par"
task 	apcomb	 	= "lirisdr$par/apcomb.par"
task 	apstatplot	= "lirisdr$par/apstatplot.par"
task 	bodyopt		= "lirisdr$par/bodyopt.par"
task 	combapall	= "lirisdr$par/combapall.par"
task 	combopt		= "lirisdr$par/combopt.par"
task 	combspsky	= "lirisdr$par/combspsky.par"
task 	combspct	= "lirisdr$par/combspct.par"
task 	dispopt 	= "lirisdr$par/dispopt.par"
task 	dispopt2 	= "lirisdr$par/dispopt2.par"
task 	displayopt 	= "lirisdr$par/displayopt.par"
task	dithopt		= "lirisdr$par/dithopt.par"
task	focopt		= "lirisdr$par/focopt.par"
task	geotopt		= "lirisdr$par/geotopt.par"
task	specopt		= "lirisdr$par/specopt.par"
task	spplotopt	= "lirisdr$par/spplotopt.par"
task	statplot	= "lirisdr$par/statplot.par"
task	skycomb		= "lirisdr$par/skycomb.par"
task	skyopt		= "lirisdr$par/skyopt.par"
task	skycpars	= "lirisdr$par/skycpars.par"
task	delopt		= "lirisdr$par/delopt.par"
task	displ		= "lirisdr$par/displ.par"
task	exam		= "lirisdr$par/exam.par"
task	teluropt	= "lirisdr$par/teluropt.par"


hidetask	dispstep
#hidetask	apallcomb
hidetask	lapopt
hidetask	lapplot
hidetask	apcomb
hidetask	apstatplot
hidetask	bodyopt
hidetask	combapall
hidetask	combopt
hidetask	combspsky
hidetask	combspct
hidetask	dispopt
hidetask	dispopt2
hidetask	displayopt
hidetask	dithopt
hidetask	focopt
hidetask	geotopt
hidetask	specopt
hidetask	spplotopt
hidetask	statplot
hidetask	skycomb
hidetask	skyopt
hidetask	delopt
hidetask	displ
hidetask	exam
hidetask	teluropt

# external programs called from IRAF


# load some packages by default
cl < lirisdr$load.cl

clbye()
