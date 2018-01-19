readcol,'sun_castelli.dat',lamb,flux
ind =WHERE(lamb Gt 4500)
lamb = lamb(ind)
flux = flux(ind)
lstep = lamb(1) - lamb(0)
mkhdr,hdr,flux
sxaddpar,hdr,'CRVAL1',min(lamb)
sxaddpar,hdr,'CRPIX1',1.
sxaddpar,hdr,'CDELT1',lstep
sxaddpar,hdr,'OBJECT','Solar Model Castelli'
sxaddpar,hdr,'HISTORY','Composite solar spectrum '
writefits,'sun_castelli.fits',flux,hdr
