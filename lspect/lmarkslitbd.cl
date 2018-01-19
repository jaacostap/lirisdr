# lmarkslitdb - mark slit boundaries over a flatfield or lamp spectrum
#               Its main usage is to define slitlets in MOS spectroscopy
# Author     : J Acosta
#              10. Jul. 2004
#  
##############################################################################
procedure lmarkslitdb(input)

file	input		{prompt="Input image"}
file	output		{prompt="Output file containing the limits"}
real	x		{prompt="X position (return)"}
real	y		{prompt="Y position (return)"}
string	key		{prompt="key (return)"}
bool	verbose		{prompt="Verbose ?"}
string *list		{prompt="Ignore this parameter(list)"}


begin

  string	imgname, fout
  string	bound
  struct	cmd
  int		wcs,ix1,iy1,ix2,iy2
  int		naxis1,naxis2

  # copy input arguments to force definition at the beginning of the script
  imgname = input
  fout = output

  # default output values
  x = 0
  y = 0
  key = ""

  # find size of the image
  imgets (image=imgname, param="i_naxis1")
  naxis1 = int(imgets.value)
  imgets (image=imgname, param="i_naxis2")
  naxis2 = int(imgets.value)


  # read the image cursor until "b" or "q" is returned
  while ( fscan(imcur, x, y, wcs, cmd) != EOF )
    {
    # find the key pressed
    key = substr(cmd, 1, 1)

    # act according to key pressed
    switch ( key )
      {
      ###
      # the boundaries has been marked 
      ###
      case 'b':
        {
        ix1 = int(x + 0.5)
        iy1 = int(y + 0.5)
        print("please press b again to mark second position")
        while ( fscan(imcur, x, y, wcs, cmd) != EOF )
          {
          # find the key pressed
          key = substr(cmd, 1, 1)
          if ( key == "b" ) break
          }
        ix2 = int(x + 0.5)
        iy2 = int(y + 0.5)
        bound= "1 "//naxis1//"   "//iy1//" "//iy2
	print(bound,>>fout)
	}
	
      ###
      # plot the column at the selected position
      ###
      case 'c':
        {
        pcol(image=imgname,
             col=int(x+0.5),
             wcs="logical",
             wx1=0.,
             wx2=0.,
             wy1=0.,
             wy2=0.,
             pointmode=no,
             marker="box",
             szmarker=0.005,
             logx=no,
             logy=no,
             xlabel="wcslabel",
             ylabel="",
             title="imtitle",
             xformat="wcsformat",
             vx1=0.,
             vx2=0.,
             vy1=0.,
             vy2=0.,
             majrx=5,
             minrx=5,
             majry=5,
             minry=5,
             round=no,
             fill=yes,
             append=no)
        }

      ###
      # quit (ie. return to calling script)
      ###
      case 'q':
        {
        # break out of loop
        break
        }
	
      ###
      # plot the vector between the selected positions
      ###
      case 'v':
        {
        ix1 = int(x + 0.5)
        iy1 = int(y + 0.5)
        if ( verbose ) print("please press v again to mark second position")
        while ( fscan(imcur, x, y, wcs, cmd) != EOF )
          {
          # find the key pressed
          key = substr(cmd, 1, 1)
          if ( key == "v" ) break
          }
        ix2 = int(x + 0.5)
        iy2 = int(y + 0.5)

        pvector(image=imgname,
                x1=ix1,
                y1=iy1,
                x2=ix2,
                y2=iy2,
                width=1,
                theta=INDEF,
                length=INDEF,
                boundary="constant",
                constant=0.,
                vec_output="",
                out_type="text",
                wx1=0.,
                wx2=0.,
                wy1=0.,
                wy2=0.,
                pointmode=no,
                marker="box",
                szmarker=0.005,
                logx=no,
                logy=no,
                xlabel="",
                ylabel="",
                title="imtitle",
                vx1=0.,
                vx2=0.,
                vy1=0.,
                vy2=0.,
                majrx=5,
                minrx=5,
                majry=5,
                minry=5,
                round=no,
                fill=yes,
                append=no)
        }
      ###
      case '?':
        {
        print("            CURSOR KEY COMMAND SUMMARY")
        print(" ")
        print("? Help             b Mark boundaries   c Column plot      ")
        print("q Quit             v Vector plot      ")
        }

      }
    }



end

