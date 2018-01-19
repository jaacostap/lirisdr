# lerasetmp - erase temporary files made by liris tasks
# Author : Miguel Charcos (mcharcos@ll.iac.es)
# Version: 24. Nov. 2003
##############################################################################
procedure lerasetmp (input)

string	input		{prompt="Name of temporary-work directory"}

bool	allfield	{yes,prompt="Erase temporary files of all tasks"}
pset 	delopt		{prompt="When allfield false, select task file to erase"}

bool	verbose		{no,prompt="Verbose?"}

begin

  string	ini
  string 	imglist, filelist
  
  bool 		blcheckfile,blconstlist,bldedither,bldithsky,blsubdithsky
  bool		bllistdiff
  bool		bldisplay,bldispstars,blfileaccess,blfilename,blcpixmap
  bool		blframediff,blimfiles,blmarkstar,blmaskaccess,blreduction
  bool		blshiftwcs,blspectr,blstarmask,blstatis,blspctoffset,blspctsky
  bool		blexamine,blnamelist,blimcentroid,blextract,blscale,bltransform
  bool		blspctapall,blspecplot,blspctcombine,blgeotran,blapall,blspecstat
  bool		blfcalib,blcycsky,blquadsky,blrunsky,blcycdither,blstarfocus,bltelluric

  # copy input arguments to force definition at the beginning of the script
  ini =  input
  lfilename(ini)
  ini = lfilename.path
  
  
  if (allfield)
    {
    if (verbose) {print "INFO: Temporary files of all tasks will be erased"}
    
    blapall	  =  yes
    blfcalib	  =  yes
    blconstlist   =  yes
    blcycdither   =  yes
    bldedither    =  yes
    bldisplay	  =  yes
    bldispstars   =  yes
    bldithsky	  =  yes
    blsubdithsky  =  yes
    blexamine	  =  yes
    blextract	  =  yes
    blfileaccess  =  yes
    blfilename    =  yes
    blcpixmap	  =  yes
    blframediff   =  yes
    blgeotran     =  yes
    blimfiles	  =  yes
    blimcentroid  =  yes
    bllistdiff	  =  yes
    blmarkstar    =  yes
    blmaskaccess  =  yes
    blnamelist	  =  yes
    blreduction   =  yes
    blscale       =  yes
    blshiftwcs    =  yes
    blspectr	  =  yes
    blspecplot	  =  yes
    blspecstat	  =  yes
    blspctapall	  =  yes
    blspctcombine =  yes
    blspctsky	  =  yes
    blspctoffset  =  yes
    blstarfocus   =  yes
    blstarmask    =  yes
    blstatis	  =  yes
    blcycsky	  =  yes
    blquadsky	  =  yes
    blrunsky	  =  yes
    bltelluric	  =  yes
    bltransform	  =  yes
    
    } # end of if(allfield)
  else
    {
    blapall       =  dlapall
    blfcalib      =  dlfcalib
    blconstlist   =  dlconstlist
    blcycdither   =  dlcycdither
    bldedither    =  dldedither
    bldisplay	  =  dldisplay
    bldispstars   =  dldispstars
    bldithsky     =  dldithsky
    blsubdithsky  =  dlsubdithsky
    blexamine	  =  dlexamine
    blextract	  =  dlextract
    blfileaccess  =  dlfileaccess
    blfilename    =  dlfilename
    blcpixmap	  =  dlcpixmap
    blframediff   =  dlframediff
    blgeotran     =  dlgeotran
    blimfiles	  =  dlimfiles
    blimcentroid  =  dlimcentroid
    bllistdiff	  =  dllistdiff
    blmarkstar    =  dlmarkstar
    blmaskaccess  =  dlmaskaccess
    blnamelist	  =  dlnamelist
    blreduction   =  dlreduction
    blscale       =  dlscale
    blshiftwcs    =  dlshiftwcs
    blspectr	  =  dlspectr
    blspecplot	  =  dlspecplot
    blspecstat	  =  dlspecstat
    blspctapall	  =  dlspctapall
    blspctcombine =  dlspctcombine
    blspctsky	  =  dlspctsky
    blspctoffset  =  dlspctoffset
    blstarfocus   =  dlstarfocus
    blstarmask    =  dlstarmask
    blstatis	  =  dlstatis
    blcycsky	  =  dlcycsky
    blquadsky	  =  dlquadsky
    blrunsky	  =  dlrunsky
    bltelluric	  =  dltelluric
    bltransform	  =  dltransform
    
    if (verbose)
      {
      if (blapall     ) {print "INFO: lapall temporary files will be erased"}
      if (blfcalib     ) {print "INFO: lfcalib temporary files will be erased"}
      if (blconstlist ) {print "INFO: lconstlist temporary files will be erased"}
      if (blcycdither ) {print "INFO: lcycdither temporary files will be erased"}
      if (bldedither  ) {print "INFO: ldedither temporary files will be erased"}
      if (bldisplay   ) {print "INFO: ldisplay temporary files will be erased"}
      if (bldispstars ) {print "INFO: ldispstars temporary files will be erased"}
      if (bldithsky   ) {print "INFO: ldithsky temporary files will be erased"}
      if (blsubdithsky) {print "INFO: lsubdithsky temporary files will be erased"}
      if (blexamine   ) {print "INFO: lexamine temporary files will be erased"}
      if (blextract   ) {print "INFO: lextract temporary files will be erased"}
      if (blfileaccess) {print "INFO: lfileaccess temporary files will be erased"}
      if (blfilename  ) {print "INFO: lfilename temporary files will be erased"}
      if (blcpixmap   ) {print "INFO: lcpixmap temporary files will be erased"}
      if (blframediff ) {print "INFO: lframediff temporary files will be erased"}
      if (blgeotran   ) {print "INFO: lgeotran temporary files will be erased"}
      if (blimfiles   ) {print "INFO: limfiles temporary files will be erased"}
      if (blimcentroid) {print "INFO: limcentroid temporary files will be erased"}
      if (bllistdiff  ) {print "INFO: llistdiff temporary files will be erased"}
      if (blmarkstar  ) {print "INFO: lmarkstar temporary files will be erased"}
      if (blmaskaccess) {print "INFO: lmaskaccess temporary files will be erased"}
      if (blnamelist  ) {print "INFO: lnamelist temporary files will be erased"}
      if (blreduction ) {print "INFO: lreduction temporary files will be erased"}
      if (blscale     ) {print "INFO: lscale temporary files will be erased"}
      if (blshiftwcs  ) {print "INFO: lshiftwcs temporary files will be erased"}
      if (blspectr    ) {print "INFO: lspectr temporary files will be erased"}
      if (blspecplot  ) {print "INFO: lspecplot temporary files will be erased"}
      if (blspecstat  ) {print "INFO: lspecstat temporary files will be erased"}
      if (blspctapall ) {print "INFO: lspctapall temporary files will be erased"}
      if (blspctcombine){print "INFO: lspctcombine temporary files will be erased"}
      if (blspctsky   ) {print "INFO: lspctsky temporary files will be erased"}
      if (blspctoffset) {print "INFO: lspctoffset temporary files will be erased"}
      if (blstarfocus ) {print "INFO: lstarfocus temporary files will be erased"}
      if (blstarmask  ) {print "INFO: lstarmask temporary files will be erased"}
      if (blstatis    ) {print "INFO: lstatis temporary files will be erased"}
      if (blcycsky    ) {print "INFO: lcycsky temporary files will be erased"}
      if (blrunsky    ) {print "INFO: lrunsky temporary files will be erased"}
      if (blquadsky    ) {print "INFO: lrunsky temporary files will be erased"}
      if (bltelluric     ) {print "INFO: ltelluric temporary files will be erased"}
      if (bltransform ) {print "INFO: ltransform temporary files will be erased"}
      }
    
    } # end of else [if (allfield)]  
    
    
  
  
  
  # firstly temporary images are erased. when finished image erase 
  # other files will be erased
  
  #############
  # First step: erase image files
  #############
  if (verbose) 
    {
    print ""
    print "Deleted image process"
    print "searching temporary files ..."
    }
  # create list starting by correct name when option choose
  imglist = mktemp (ini//"leraseimglist")
  
  if (blapall) 
    {
    files(ini//"lapall*.fits", >> imglist)
    files(ini//"lapall*.imh", >> imglist)
    }
  
  if (blfcalib) 
    {
    files(ini//"lfcalib*.fits", >> imglist)
    files(ini//"lfcalib*.imh", >> imglist)
    }
  
  if (blconstlist) 
    {
    files(ini//"lconstlist*.fits", >> imglist)
    files(ini//"lconstlist*.imh", >> imglist)
    }
  
  if (blcycdither) 
    {
    files(ini//"lcycdither*.fits", >> imglist)
    files(ini//"lcycdither*.imh", >> imglist)
    }
  
  if (bldedither) 
    {
    files(ini//"ldedither*.fits", >> imglist)
    files(ini//"ldedither*.imh", >> imglist)
    }
  
  if (bldisplay) 
    {
    files(ini//"ldisplay*.fits", >> imglist)
    files(ini//"ldisplay*.imh", >> imglist)
    }
  
  if (bldispstars) 
    {
    files(ini//"ldispstars*.fits", >> imglist)
    files(ini//"ldispstars*.imh", >> imglist)
    }
  
  if (bldithsky) 
    {
    files(ini//"ldithsky*.fits", >> imglist)
    files(ini//"ldithsky*.imh", >> imglist)
    }
  
  if (blsubdithsky) 
    {
    files(ini//"lsubdthskysub*.fits", >> imglist)
    files(ini//"lsubdthskysub*.imh", >> imglist)
    }
  
  if (blexamine) 
    {
    files(ini//"lexamine*.fits", >> imglist)
    files(ini//"lexamine*.imh", >> imglist)
    }
  
  if (blextract) 
    {
    files(ini//"lextract*.fits", >> imglist)
    files(ini//"lextract*.imh", >> imglist)
    }
  
  if (blfileaccess) 
    {
    files(ini//"lfileaccess*.fits", >> imglist)
    files(ini//"lfileaccess*.imh", >> imglist)
    }
  
  if (blfilename) 
    {
    files(ini//"lfilename*.fits", >> imglist)
    files(ini//"lfilename*.imh", >> imglist)
    }
  
  if (blcpixmap) 
    {
    files(ini//"lcpixmap*.fits", >> imglist)
    files(ini//"lcpixmap*.imh", >> imglist)
    }
  
  if (blframediff) 
    {
    files(ini//"lframediff*.fits", >> imglist)
    files(ini//"lframediff*.imh", >> imglist)
    }
  
  if (blgeotran) 
    {
    files(ini//"lgeotran*.fits", >> imglist)
    files(ini//"lgeotran*.imh", >> imglist)
    }
  
  if (blimfiles) 
    {
    files(ini//"limfiles*.fits", >> imglist)
    files(ini//"limfiles*.imh", >> imglist)
    }
  
  if (blimcentroid) 
    {
    files(ini//"limcentroid*.fits", >> imglist)
    files(ini//"limcentroid*.imh", >> imglist)
    }
  
  if (bllistdiff) 
    {
    files(ini//"llistdiff*.fits", >> imglist)
    files(ini//"llistdiff*.imh", >> imglist)
    }
  
  if (blmarkstar) 
    {
    files(ini//"lmarkstar*.fits", >> imglist)
    files(ini//"lmarkstar*.imh", >> imglist)
    }
  
  if (blmaskaccess) 
    {
    files(ini//"lmaskaccess*.fits", >> imglist)
    files(ini//"lmaskaccess*.imh", >> imglist)
    }
  
  if (blnamelist) 
    {
    files(ini//"lnamelist*.fits", >> imglist)
    files(ini//"lnamelist*.imh", >> imglist)
    }
  
  if (blreduction) 
    {
    files(ini//"lreduction*.fits", >> imglist)
    files(ini//"lreduction*.imh", >> imglist)
    }
  
  if (blscale) 
    {
    files(ini//"lscale*.fits", >> imglist)
    files(ini//"lscale*.imh", >> imglist)
    }
  
  if (blshiftwcs) 
    {
    files(ini//"lshiftwcs*.fits", >> imglist)
    files(ini//"lshiftwcs*.imh", >> imglist)
    }
  
  if (blspectr) 
    {
    files(ini//"lspectr*.fits", >> imglist)
    files(ini//"lspectr*.imh", >> imglist)
    }
  
  if (blspecplot) 
    {
    files(ini//"lspecplot*.fits", >> imglist)
    files(ini//"lspecplot*.imh", >> imglist)
    }
  
  if (blspecstat) 
    {
    files(ini//"lspecstat*.fits", >> imglist)
    files(ini//"lspecstat*.imh", >> imglist)
    }
  
  if (blspctapall) 
    {
    files(ini//"lspctapall*.fits", >> imglist)
    files(ini//"lspctapall*.imh", >> imglist)
    }
  
  if (blspctcombine) 
    {
    files(ini//"lspctcombine*.fits", >> imglist)
    files(ini//"lspctcombine*.imh", >> imglist)
    }
  
  if (blspctsky) 
    {
    files(ini//"lspctsky*.fits", >> imglist)
    files(ini//"lspctsky*.imh", >> imglist)
    }
  
  if (blspctoffset) 
    {
    files(ini//"lspctoffset*.fits", >> imglist)
    files(ini//"lspctoffset*.imh", >> imglist)
    }
  
  if (blstarfocus) 
    {
    files(ini//"lstarfocus*.fits", >> imglist)
    files(ini//"lstarfocus*.imh", >> imglist)
    }
  
  if (blstarmask) 
    {
    files(ini//"lstarmask*.fits", >> imglist)
    files(ini//"lstarmask*.imh", >> imglist)
    }
  
  if (blstatis) 
    {
    files("lstatis*.fits", >> imglist)
    files("lstatis*.imh", >> imglist)
    }
  
  if (blcycsky) 
    {
    files("lcycsky*.fits", >> imglist)
    files("lcycsky*.imh", >> imglist)
    }
  
  if (blquadsky) 
    {
    files("lquadsky*.fits", >> imglist)
    files("lquadsky*.imh", >> imglist)
    }
  
  if (blrunsky) 
    {
    files("lrunsky*.fits", >> imglist)
    files("lrunsky*.imh", >> imglist)
    }
  
  if (bltelluric) 
    {
    files("ltelluric*.fits", >> imglist)
    files("ltelluric*.imh", >> imglist)
    }
  
  if (bltransform) 
    {
    files("ltransform*.fits", >> imglist)
    files("ltransform*.imh", >> imglist)
    }
  
  if (verbose) {print "deleting images found ..."}
  imdelete("@"//imglist,yes,ver-, >>&"/dev/null")
  if (verbose) {print "temporary images deleted"}
  
  if (verbose) 
    {
    print "Deleting image process finished"
    print ""
    }
    
    
  #############
  # Second step: erase other files
  #############
  
  if (verbose)
    {
    print ""
    print "Delete general files process"
    print "searching temporary files"
    }
    
  # create list starting by correct name when option choose
  filelist = mktemp (ini//"lerasefilelist")
  
  if (blapall) 
    {files(ini//"lapall*", >> filelist)}
  
  if (blfcalib) 
    {files(ini//"lfcalib*", >> filelist)}
  
  if (blconstlist) 
    {files(ini//"lconstlist*", >> filelist)}
  
  if (blcycdither) 
    {files(ini//"lcycdither*", >> filelist)}
  
  if (bldedither) 
    {files(ini//"ldedither*", >> filelist)}
  
  if (bldisplay) 
    {files(ini//"ldisplay*", >> filelist)}
  
  if (bldispstars) 
    {files(ini//"ldispstars*", >> filelist)}
  
  if (bldithsky) 
    {files(ini//"ldithsky*", >> filelist)}
  
  if (blexamine) 
    {files(ini//"lexamine*", >> filelist)}
  
  if (blextract) 
    {files(ini//"lextract*", >> filelist)}
  
  if (blfileaccess) 
    {files(ini//"lfileaccess*", >> filelist)}
  
  if (blfilename) 
    {files(ini//"lfilename*", >> filelist)}
  
  if (blcpixmap) 
    {files(ini//"lcpixmap*", >> filelist)}
  
  if (blframediff) 
    {files(ini//"lframediff*", >> filelist)}
  
  if (blgeotran) 
    {files(ini//"lgeotran*", >> filelist)}
  
  if (blimfiles) 
    {files(ini//"limfiles*", >> filelist)}
  
  if (blimcentroid) 
    {files(ini//"limcentroid*", >> filelist)}
  
  if (bllistdiff) 
    {files(ini//"llistdiff*", >> filelist)}
  
  if (blmarkstar) 
    {files(ini//"lmarkstar*", >> filelist)}
  
  if (blmaskaccess) 
    {files(ini//"lmaskaccess*", >> filelist)}
  
  if (blnamelist) 
    {files(ini//"lnamelist*", >> filelist)}
  
  if (blreduction) 
    {files(ini//"lreduction*", >> filelist)}
  
  if (blscale) 
    {files(ini//"lscale*", >> filelist)}
  
  if (blshiftwcs) 
    {files(ini//"lshiftwcs*", >> filelist)}
  
  if (blspectr) 
    {files(ini//"lspectr*", >> filelist)}
  
  if (blspecplot) 
    {files(ini//"lspecplot*", >> filelist)}
  
  if (blspecstat) 
    {files(ini//"lspecstat*", >> filelist)}
  
  if (blspctapall) 
    {files(ini//"lspctapall*", >> filelist)}
  
  if (blspctcombine) 
    {files(ini//"lspctcombine*", >> filelist)}
  
  if (blspctsky) 
    {files(ini//"lspctsky*", >> filelist)}
  
  if (blspctoffset) 
    {files(ini//"lspctoffset*", >> filelist)}
  
  if (blstarfocus) 
    {files(ini//"lstarfocus*", >> filelist)}
  
  if (blstarmask) 
    {files(ini//"lstarmask*", >> filelist)}
  
  if (blstatis) 
    {files(ini//"lstatis*", >> filelist)}
  
  if (blcycsky) 
    {files(ini//"lcycsky*", >> filelist)}
  
  if (blquadsky) 
    {files(ini//"lquadsky*", >> filelist)}
  
  if (blrunsky) 
    {files(ini//"lrunsky*", >> filelist)}
  
  if (bltelluric) 
    {files(ini//"ltelluric*", >> filelist)}
  
  if (bltransform) 
    {files(ini//"ltransform*", >> filelist)}
    
  
  if (verbose) {print "deleting files found..."}
  delete ("@"//filelist,yes,ver-, >>&"/dev/null")
  if (verbose) {print "temporary files deleted"}
  
  if (verbose) 
    {
    print "Deleting file process finished"
    print ""
    }
  
  # Delete all files created by lerasetmp task
  delete ("leraseimglist*",yes,ver-, >>&"/dev/null")
  delete ("lerasefilelist*",yes,ver-, >>&"/dev/null")
  
  
  
  
end
