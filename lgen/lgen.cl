#{ LGEN.CL -- LIRIS generic processing tasks

package lgen

task    lframediff	= "lgen$lframediff.cl"
task	ldisplay	= "lgen$ldisplay.cl"
task	limexamine	= "lgen$limexamine.cl"
task    lshiftwcs	= "lgen$lshiftwcs.cl"

task	lcorrow		= "lgen$lcorrow.cl"
task	lcpixmap	= "lgen$lcpixmap.cl"
task	lrctalk		= "lgen$lrctalk.cl"
task 	ltrimim		= "lgen$ltrimim.cl"

# external programs called from IRAF

if (envget("arch") == ".ssun") 
   task 	$corrow     	= ("$" // osfn("lirisdr$bin.ssun/") // "corrow_sun4") 
else if (envget("arch") == ".macintel" || (envget("arch") == ".macosx")) 
   task 	$corrow     	= ("$" // osfn("lirisdr$bin.macintel/") // "corrow_macintel") 
else 
   task 	$corrow     	= ("$" // osfn("lirisdr$bin.redhat/") // "corrow_linux") 

if (envget("arch") == ".ssun")  
   task 	$rctalk     	= ("$" // osfn("lirisdr$bin.ssun/") // "rctalk_ssun") 
else if (envget("arch") == ".macintel" || (envget("arch") == ".macosx")) 
   task 	$rctalk     	= ("$" // osfn("lirisdr$bin.macintel/") // "rctalk_macintel") 
else 
   task 	$rctalk     	= ("$" // osfn("lirisdr$bin.redhat/") // "rctalk_linux") 

hidetask	corrow
hidetask	rctalk

hidetask        lcorrow

clbye()
