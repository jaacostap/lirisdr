readcol,"Ar600_air.txt",lambda_air,dd,format="F,A"
nele=N_ELEMENTS(lambda_air)
lambda_vac = lambda_air
for i=0,nele-1 do begin & $
  l = lambda_air(i) & $
  airtovac,l & $
  lambda_vac(i) = l & $ 
endfor  

