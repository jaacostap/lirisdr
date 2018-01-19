print (" ")
print ("    ##################################################################")
print ("            TELLIR - LIRIS spectra telluric absortion correction")
print ("                    last update: 20. May 2004")
print ("    ##################################################################")
print (" ")
print (" ")

lutil

package tellir

task 	ltelluric	= "tellir$ltelluric.cl"	
task 	lfcalib	 	= "tellir$lfcalib.cl"	

clbye()
