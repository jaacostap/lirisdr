
#if (!(deftask("objmasks"))) {
#    nproto
#}

package limage

if (limage.motd)
 type limage$limage.motd
 
set limpol  = "limage$limpol/"
task	limpol.pkg		= "limpol$limpol.cl"

task    lcycdither	= "limage$lcycdither.cl"
task	lcycsky		= "limage$lcycsky.cl"
task    ldedither	= "limage$ldedither.cl"
task	ldispstars	= "limage$ldispstars.cl"
task    ldispoff        = "limage$ldispoff.cl"
task    lgeotran	= "limage$lgeotran.cl"
task    limalign	= "limage$limalign.cl"
task	lmarkstar	= "limage$lmarkstar.cl"
task    limcentroid	= "limage$limcentroid.cl"
task	lrunsky		= "limage$lrunsky.cl"
task	lstarfocus	= "limage$lstarfocus.cl"
task	lmksky		= "limage$lmksky.cl"
task	lsubdithsky	= "limage$lsubdithsky.cl"
task	lsubscalesky	= "limage$lsubscalesky.cl"
task    licvgrad	= "limage$licvgrad.cl"
task	lmkflat		= "limage$lmkflat.cl"
task	liflatcor	= "limage$liflatcor.cl"
task	lmksupflat	= "limage$lmksupflat.cl"
task 	lwcsedit	= "limage$lwcsedit.cl"
task	lnselfsky	= "limage$lnselfsky.cl"
task	leququad	= "limage$leququad.cl"
task    ligetoffset     = "limage$ligetoffset.cl"

# pset parameter files
task    liskycpars	= "limage$liskycpars.par"
task 	lcvgradpars	= "limage$lcvgradpars.par" 
task    lstarfindpars	= "limage$lstarfindpars.par"

## sex utilities
task	$sexphotom      = ("$" // osfn("limage$sexutils/") // "sexphotom.sh")

clbye()
