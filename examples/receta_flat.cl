ls r*.fit > lista1

lcpixmap @lista1 c

llistdiff c//@lista1 output=lista2

#bad pixel mask is common to all grisms and bands
fixpix @lista2 /home/elena/MOS/DATA/ID441/ID441_H/MASTERBAD/bp_20061100.pl linterp=3 cinterp=2

lrctalk c//@lista1 t

llistdiff tc//@lista1 output=lista3

#imstat.binwidth=0.1 not dependent
imcombine @lista3 output="Flat.fits" combine=average reject=none scale=mode

lfindmosaper(input="Flat", mdf="/home/elena/MOS/DATA/ID441/ID441_HKn/len441_fp.txt", outreg="slits.reg", outapdb="")

apsum Flat output="" format="multispec" interac-  find=no recent- resiz- edit- trace- extract+  background="none" weight="none"

######FIRST APPROACH (statistically better)######
lmoscombflat Flat.ms Flatk_comb "/home/elena/MOS/DATA/ID441/ID441_HKn/len441_fp.txt" reject="pclip" combine="median"
#order 150; niterate 0; function spline1 including the absorption
#new version for the ghost things has reject and combine as keyboards
#Jose found that reject=pclip and combine=median are the best options 


lmosmkresp1d Flat.ms Resp.ms Flatk_comb mdf="/home/elena/MOS/DATA/ID441/ID441_HKn/len441_fp.txt" reject="none"

######SECOND APPROACH (apertures treated individually)################
apnormalize Flat output="Response" reference="Flat" interac+  find=no recent- resiz- edit- trace- normali+ fitspec+ background="none" weight="none" function="spline1" order=150 niterate=0

#add points with a in the gaps where the illumination goes down with a and delete the ones that are wrong...

######################################################################

