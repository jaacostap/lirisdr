ls r*.fit > lista1

lcpixmap

llistdiff c//@lista1 output=lista2

fixpix @lista2 /home/elena/MOS/DATA/ID441/ID441_H/MASTERBAD/bp_20061100.pl linterp=3 cinterp=2

lrctalk c//@lista1 t

lspskynod (input="tc//@lista1", output="s", outlsta="list_a", outlstb="list_b", zerobkg=yes)
#Warning, I had to set zerobkg no yes in this band, because otherwise lmosextall would find weird peaks

apextract.database="database" 
#I  copy the /apFlat into the local /database

lmosextall @list_a @list_b Flat  arc="../LAMP/cr1064165[1]" outarc="lenID441_arc" flat="../FLAT/Flat" outflat="flat_" outflatlst="flat_id441.lst" ext_mos=yes ext_arc=yes ext_flat=yes ext_mask=no lower=-2 upper=2 nsum=400 cradius=17. cwidth=5. verb+
#nsum number of columns that uses to define the continuum peak in the spatial direction
#edit the centres of the apertures for the first A frame and the first B frame
#change upper and lower by hand in the graphic display
#recenter globally a --> g --> a
#recenter one by one a --> c --->a
# This is the old version, the new one uses the A aperture positions and recenters them monolithically on the first B frame
#The new one, has to have a larger cwidth=20, 34, because that is the size to find the new peaks.
###For Standard##### Erase on the display all the apertures that are not needed, beside the standard star
#Forget about last sentence!! use all the apertures even if you are using only one for the standard, it is the only way it works!!!

ls  stcr*.ms.fits > id441_allms.lst 
	   


lmosmkresp1d flat_//@id441_allms.lst  res_//@id441_allms.lst  "../FLAT/Flatk_comb" mdf="/home/elena/MOS/DATA/ID441/ID441_HKn/len441_fp.txt" reject="none"

imarith @id441_allms.lst / res_//@id441_allms.lst f//@id441_allms.lst 

implot  stcr1064430_tcr1064431.ms
#graphic display o = oplot
#graphic display :l 12 indicates the aperture to plot
#graphic display :i name of the second file to overplot



lmsprepare lenID441_arc_A.ms.fits mdf="/home/elena/MOS/DATA/ID441/ID441_HKn/len441_fp.txt"
lmsprepare lenID441_arc_B.ms.fits mdf="/home/elena/MOS/DATA/ID441/ID441_HKn/len441_fp.txt"

lwavecal1d lenID441_arc_A.ms lenID441_arc_B.ms outroot="" specfor="mr_k" coordli="lirisdr$std/argon_ref.dat" match=30. database="database" verb+
#identify order 4!!!!!!!!!!!!!!!!!!!!!
#One may want to use arc_on-arc_off
#Would be nice if it would subtract continuum
#list with brightest lines works better (future: primary lines, secondary lines)
#It is better not to use l, better to mark a few with m and then identify other good ones with m too and confirm
#typing c while being close to a point gives the wavelength info of that point.
# Shift-c gives the value of the cursor
#We included the line at 23139.5 in the argon_ref.dat file and lines 16127.1 and 16184.4
#Maybe it is better to lower the maximum difference for feature matching  



hedit f//@list_a//.ms refspec1 lenID441_arc_A.ms add+ upd+ ver-
dispcor f//@list_a//.ms wf//@list_a//.ms linea+ table="" flux=yes ignoreaps=no samedisp=no global=no

hedit f//@list_b//.ms refspec1 lenID441_arc_B.ms add+ upd+ ver-
dispcor f//@list_b//.ms wf//@list_b//.ms linea+ table="" flux=yes ignoreaps=no samedisp=no global=no

scombine wf//@id441_allms.lst  id441_hk_sc_swgt.ms  group="apertures" combine="average" reject="none" zero="none" scale="median" weight="median" sample="21000:22000"

scombine wf//@list_a//.ms id441_hk_A_sc_swgt.ms  group="apertures" combine="average" reject="none" zero="none" scale="median" weight="median" sample="17000:17500"

scombine wf//@list_b//.ms id441_hk_B_sc_swgt.ms  group="apertures" combine="average" reject="none" zero="none" scale="median" weight="median" sample="17000:17500"
