##############################################################################
#         
# limstokes - generate combined polarization images from dither sequence 
#              
# 
# Author : Jose Acosta (jap@ll.iac.es)
# Version: 18. Feb. 2007
#         
##############################################################################
procedure limstokes (impol0, impol90, impol45,impol135,Iq,Iu,Q,U)


string  impol0      {"",prompt="Image with polarization vector at 0"}
string  impol90     {"",prompt="Image with polarization vector at 90"}
string  impol45     {"",prompt="Image with polarization vector at 45"}
string  impol135    {"",prompt="Image with polarization vector at 135"}
string  immatch	    {"manual",enum="manual",prompt="Image matching"}
string  imIq         {"",prompt="Output Image with Stokes param. I"}
string  imQ         {"",prompt="Output Image with Stokes param. Q"}
string  imIu         {"",prompt="Output Image with Stokes param. I"}
string  imU         {"",prompt="Output Image with Stokes param. U"}


begin

## select few stars to perform alignment
 ldispstars
## now align the images using limcentroid
 limcentroid 
## now combine the images to obtain the output results
 

end
