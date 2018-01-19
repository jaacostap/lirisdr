print ("    ##################################################################")
print ("                     LIMPOL - LIRIS polarization image processing")
print ("                       last update: Feb 2014")
print ("    ##################################################################")
print (" ")

package limpol

task lpdedither 	= "limpol$lpdedither.cl"
task lpmkflat 		= "limpol$lpmkflat.cl"
task lpedge		= "limpol$lpedge.cl"
task ltrimpol		= "limpol$ltrimpol.cl"
task lpwcsedit 		= "limpol$lpwcsedit.cl"

# pset parameter files
task lpgeodistpars      = "limpol$lpgeodistpars.par"

clbye()
