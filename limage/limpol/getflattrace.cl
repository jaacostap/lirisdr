# en primer lugar desplazamos el espectro en la direccion espacial dos pixeles
## desplazamos por la mitad del ancho de las rendijas
imshift center centerup xshift=0 yshift=20
imshift center centerupoff xshift=0 yshift=21 interp_type=nearest


## luego le restamos la imagen desplazada a la original
imarith centerup - centerupoff rawtrace
#imcalc "center,centerup" "rawtrace" "abs(im1-im2)" 


## luego pasamos un filtro de mediana a la imagen restada con xbox=5 ybox=1
## para reducir el ruido en las zonas donde se encuentra la rendija
median rawtrace smtrace xwind=5 ywind=1

