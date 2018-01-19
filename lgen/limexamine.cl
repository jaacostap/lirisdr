# limexamine - display and examine liris image list in all formats
# Author     : Miguel Charcos (mcharcos@ll.iac.es)
# Last Change: 1. Dec. 2003
##############################################################################
procedure limexamine(input,frame)

string 	input 		{prompt="list of image to be examined"}
int	frame		{prompt="frame to be written into"}

# Display option and examine options
pset	displ		{prompt="Display task options"}
pset	exam		{prompt="Examine task options"}

bool	verbose		{no,prompt="Verbose?"}

# Directories
string	tmpdir		{")_.tmpdir",prompt="temporary directory"}

string *list1	{prompt="Ignore this parameter(list1)"}

begin 

  string	inli
  int		frm
  string	fname
  
  frm = frame
  inli = mktemp(tmpdir//"lexamine")
  sections(input,option="fullname",>inli)

  list1 = inli
  While(fscan(list1,fname) != EOF) 
    {
    ldisplay ( image = fname,
               frame = frm,     
              bpmask = displ.bpmask,
           bpdisplay = displ.bpdisplay,
            bpcolors = displ.bpcolors,
             overlay = displ.overlay,
             ocolors = displ.ocolors,
               erase = displ.erase,
        border_erase = displ.border_erase,
        select_frame = displ.select_frame,
              repeat = displ.repeat,
                fill = displ.fill,
              zscale = displ.zscale,
            contrast = displ.contrast,
              zrange = displ.zrange,
               zmask = displ.zmask,
             nsample = displ.nsample,
             xcenter = displ.xcenter,
             ycenter = displ.ycenter,
               xsize = displ.xsize,
               ysize = displ.ysize,
                xmag = displ.xmag,
                ymag = displ.ymag,
               order = displ.order,
              ztrans = displ.ztrans,
             lutfile = displ.lutfile,
             verbose = displ.verbose,
              tmpdir = tmpdir) 

    imexamine ( input = " ",            
                frame = frm,            
        	image = "",
     	      logfile = exam.logfile,
              keeplog = exam.keeplog,
               defkey = exam.defkey,
           autoredraw = exam.autoredraw,
            allframes = exam.allframes,
              nframes = exam.nframes,
               ncstat = exam.ncstat,
               nlstat = exam.nlstat,
             graphcur = exam.graphcur,
             imagecur = exam.imagecur,
                  wcs = exam.wcs,
              xformat = exam.xformat,
              yformat = exam.yformat,
             graphics = exam.graphics,
              display = exam.display,
          use_display = exam.use_display)
    }

  delete(inli,yes,ver-)

end
