#{ LUTIL.CL -- LIRIS utilities package

package lutil

# la idea es quitar imgaccess y lmaskaccess para remplazarlo por lfileaccess
task	limnumber	= "lutil$limnumber.cl"
task	limgaccess	= "lutil$limgaccess.cl"

task    lcheckfile	= "lutil$lcheckfile.cl"
task	lcorrfile	= "lutil$lcorrfile.cl"
task	lconstlist	= "lutil$lconstlist.cl"
task	lcorrmask	= "lutil$lcorrmask.cl"
task	lerasetmp	= "lutil$lerasetmp.cl"
task	lfileaccess	= "lutil$lfileaccess.cl"
task	lfilename	= "lutil$lfilename.cl"
task	lhgets		= "lutil$lhgets.cl"
task	lhigherdate	= "lutil$lhigherdate.cl"
task	llistdiff	= "lutil$llistdiff.cl"
task	lmaskaccess	= "lutil$lmaskaccess.cl"
task	lnamelist	= "lutil$lnamelist.cl"
task 	lstatist	= "lutil$lstatist.cl"



hidetask 	lhigherdate,lcorrfile


clbye()
