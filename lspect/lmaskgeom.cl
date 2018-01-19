# lmaskgeom - combine spectra taken following sequence ABBA cases
# Author : Jose Acosta  (jap@ll.iac.es)
# Version: 03. Apr. 2008 (initial)
##############################################################################
procedure lmaskgeom(input,name)
string  input           {prompt="List of mask images"}
string  name 		{prompt="List of mask names"}




begin

## se usa print para mandar comandos al sistema operativo
fmsltdir = osfn("lspect$")
shellcommand = fmsltdir
print("fmaskslits)

end
