Todos los ficheros cuyo nombre contengan yymmdd corresponden a ano/mes/dia de 
  comienzo de su validez 

==========================================================================
Mascaras pixeles malos: 
 Contiene pixeles muertos + pixeles calientes 
 se genera una por ciclado y depende del tiempo de exposicion (pixeles calientes)
 Nombre: lbpmt[exptime]_yymmdd.pl  
 Tipo: binario
 
===========================================================================
Mascaras columnas/filas malas: 
 Contiene columnas o filas de pixeles sin senal
 corresponde a un detector
 La utilidad de esta mascara es su uso para interpolar estos pixeles
 Nombre: lbcm_yymmdd.pl 
 Tipo: binario

==========================================================================
Ficheros de correccion de distorsion geometrica de imagenes
  Contiene los datos para la correccion geometrica debida a la optica
  Depende de la orienacion del detector
  Nombre: lgdist_yymmdd 
  Tipo: ASCII
  
==========================================================================
Ficheros de correccion de curvatura espacial de los espectros
  Contiene los datos para su correccion 
  Depende de la orienacion del detector, del ciclado (ruedas) y del grisma
  Se calibrara cada cierto tiempo
  Nombre: fc[grisma]spt_yymmdd (ejemplo: fcZJspt_020101) 
  Tipo: ASCII
  
==========================================================================
Ficheros de calibracion en longitud de onda
  Contiene los datos para su calibracion 
  Depende de la orienacion del detector, de la rendija, del ciclado (ruedas) y del grisma
  Se calibrara cada cierto tiempo
  Nombre: fc[grisma]l[rendija]_yymmdd (ejemplo: fcZJl0p75_020101) 
  Tipo: ASCII  
  
  
