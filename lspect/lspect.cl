print ("    ##################################################################")
print ("                   LSPECT - LIRIS spectra processing")
print ("                       last update: Jul 2013")
print ("    ##################################################################")
print (" ")
print (" ")

if (!defpac("lutil")) {
   lutil
}

package lspect

task lspepol 		= "lspect$lspepol/lspepol.cl"

task 	lspectall 	= "lspect$lspectall.cl"	
task 	lspecplot 	= "lspect$lspecplot.cl"	
task 	lspecstat 	= "lspect$lspecstat.cl"	
task 	lspctapall 	= "lspect$lspctapall.cl"	
task 	lspctcombine 	= "lspect$lspctcombine.cl"
task 	lspskynod 	= "lspect$lspskynod.cl"
task 	lspskynod3pt 	= "lspect$lspskynod3pt.cl"
task 	lspnodcomb 	= "lspect$lspnodcomb.cl"
task 	ltransform 	= "lspect$ltransform.cl"
task 	lspgetoff	= "lspect$lspgetoff.cl"
task	laddwave	= "lspect$laddwave.cl"
task	ltrimspec	= "lspect$ltrimspec.cl"
task	lmarkslitbd	= "lspect$lmarkslitbd.cl"
task	lgetmostrace	= "lspect$lgetmostrace.cl"
task	lfindmosaper	= "lspect$lfindmosaper.cl"
task	lcheckmask	= "lspect$lcheckmask.cl"
task	lcentwave	= "lspect$lcentwave.cl"
task	lwavecal1d	= "lspect$lwavecal1d.cl"
task    l2dwavecal      = "lspect$l2dwavecal.cl"
task	lmkspflat	= "lspect$lmkspflat.cl"

## for MOS data reduction
task    lmsprepare	= "lspect$lmsprepare.cl"
task	lmoswavecal	= "lspect$lmoswavecal.cl"
task	lmosextall	= "lspect$lmosextall.cl"
task    lmoscombflat	= "lspect$lmoscombflat.cl"
task	lmosmkresp1d	= "lspect$lmosmkresp1d.cl"
task	lmosghosttable	= "lspect$lmosghosttable.cl"
task	lmosghostmask	= "lspect$lmosghostmask.cl"
task	lmosoverlay	= "lspect$lmosoverlay.cl"
task    lmostransform   = "lspect$lmostransform.cl"

task   lspndcombpars = "lspect$lspndcombpars.par"

clbye()
