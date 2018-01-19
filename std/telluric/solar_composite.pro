bb= readfits('bb_g2v_nir.fits',hdrbb)
nele = N_ELEMENTS(bb)
lambbb = fxpar(hdrbb,'CRVAL1') + FINDGEN(nele) * fxpar(hdrbb,'CDELT1')

lstep = 0.2
lmin = 8500.
lmax = 25010.
nfine = ROUND((lmax-lmin)/lstep)
lfine = FINDGEN(nfine)*lstep + lmin
bbfine = INTERPOL(bb,lambbb,lfine) 

pathi = "../../../solar/"
soli = readfits(pathi+'solar_comp_I_norm.fits',hdri)
nele = N_ELEMENTS(soli)
lambi = fxpar(hdri,'CRVAL1') + FINDGEN(nele) * fxpar(hdri,'CDELT1')

solz = readfits('solrb_sz_1aa_norm.fits',hdrz)
nele = N_ELEMENTS(solz)
lambz = fxpar(hdrz,'CRVAL1') + FINDGEN(nele) * fxpar(hdrz,'CDELT1')

solj = readfits('solrb_j_1aa_norm.fits',hdrj)
nele = N_ELEMENTS(solj)
lambj = fxpar(hdrj,'CRVAL1') + FINDGEN(nele) * fxpar(hdrj,'CDELT1')

solh = readfits('solrb_h_1aa.fits',hdrh)
nele = N_ELEMENTS(solh)
lambh = fxpar(hdrh,'CRVAL1') + FINDGEN(nele) * fxpar(hdrh,'CDELT1')

solk = readfits('solrb_k_1aa.fits',hdrk)
nele = N_ELEMENTS(solk)
lambk = fxpar(hdrk,'CRVAL1') + FINDGEN(nele) * fxpar(hdrk,'CDELT1')

fullsp = bbfine

indi = WHERE(lfine LE MAX(lambi) and lfine GE MIN(lambi))
fullsp(indi) = INTERPOL(soli,lambi,lfine(indi))*bbfine(indi) 

indz = WHERE(lfine LE MAX(lambz) and lfine GE MIN(lambz))
fullsp(indz) = INTERPOL(solz,lambz,lfine(indz))*bbfine(indz)

indj = WHERE(lfine LE MAX(lambj) and lfine GE MIN(lambj))
fullsp(indj) = INTERPOL(solj,lambj,lfine(indj))*bbfine(indj)

indh = WHERE(lfine LE MAX(lambh) and lfine GE MIN(lambh))
fullsp(indh) = INTERPOL(solh,lambh,lfine(indh))*bbfine(indh)

indk = WHERE(lfine LE MAX(lambk) and lfine GE MIN(lambk))
fullsp(indk) = INTERPOL(solk,lambk,lfine(indk))*bbfine(indk)

mkhdr,hdr,fullsp
sxaddpar,hdr,'CRVAL1',min(lfine)
sxaddpar,hdr,'CRPIX1',1.
sxaddpar,hdr,'CDELT1',lstep
sxaddpar,hdr,'OBJECT','Solar Composite'
sxaddpar,hdr,'HISTORY','Composite solar spectrum '
sxaddpar,hdr,'HISTORY','Combined spectra: solrb_[sz|j|h|k]_1aa'
writefits,'solar_comp.fits',fullsp,hdr
