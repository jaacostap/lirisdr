print ("    ##################################################################")
print ("                     LSPEPOL - LIRIS spectro-polarization processing")
print ("                       last update: August 2007")
print ("    ##################################################################")
print (" ")

package lspepol

task lpmksflat           = "lspepol$lpmksflat.cl"
task ltrimspol		 = "lspepol$ltrimspol.cl"
task lspolwavecal	 = "lspepol$lspolwavecal.cl"
task lspolprepare	 = "lspepol$lspolprepare.cl"

clbye()
