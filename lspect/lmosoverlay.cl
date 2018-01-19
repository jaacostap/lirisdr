# lmosoverlay - determine slit boundaries over a flatfield or lamp spectrum
#               Its main usage is to define slitlets in MOS spectroscopy
# Author     : J Acosta
#              13. Nov. 2008
#  
##############################################################################
procedure lmsoverlay(pos)

file  pos         {prompt="File containing slitlet limits (ASCII)"}
int   frame       {1,prompt="Default frame number for display"}

string *list1     {prompt="Ignore this parameter (list1)"}

begin

int	apernum
real    xc,x1,x2,yc,y1,y2
string  slitid,styp

apernum = 0
list1 = pos

while (fscan(list1,styp,slitid,xc,x1,x2,y1,y2) != EOF) 
  {
     apernum += 1
     yc = (y1+y2)/2.
     xc = (x1+x2)/2.
     print(int(xc)//" "//int(yc)//" Ap-"//apernum//"/"//slitid) | \
	tvmark (frame=1,coords="STDIN",mark = "rectangle",\
        lengths = int(x2 - x1)//" "//(y2-y1)/(x2-x1),\
        color = 205,interactive = no,label+ )

  }
  
  
list1 = ''

end
