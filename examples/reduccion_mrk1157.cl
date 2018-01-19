
hedit ../bias/*.fits[1] CCDSEC [25:1049,1:2051] up+ ver-
hedit ../bias/*.fits[1] DATASEC [25:1049,1:2051] up+ ver-
hedit ../bias/*.fits[1] BIASSEC [1:24,1:2051] up+ ver-
hedit ../bias/*.fits[1] TRIMSEC [275:1049,1:2051] up+ ver-

hedit ../bias/*.fits[2] CCDSEC [25:1049,1:2051] up+ ver-
hedit ../bias/*.fits[2] DATASEC [25:1049,1:2051] up+ ver-
hedit ../bias/*.fits[2] BIASSEC [1:25,1:2051] up+ ver-
hedit ../bias/*.fits[2] TRIMSEC [25:1049,1:2051] up+ ver-

zerocombine ../bias/*.fits[1] output="bias1" reject = "minmax" ccdtype=""
zerocombine ../bias/*.fits[2] output="bias2" reject = "minmax" ccdtype=""

hedit ../dark/*.fits[1] CCDSEC [25:1049,1:2051] up+ ver-
hedit ../dark/*.fits[1] DATASEC [25:1049,1:2051] up+ ver-
hedit ../dark/*.fits[1] BIASSEC [1:24,1:2051] up+ ver-
hedit ../dark/*.fits[1] TRIMSEC [275:1049,1:2051] up+ ver-

hedit ../dark/*.fits[2] CCDSEC [25:1049,1:2051] up+ ver-
hedit ../dark/*.fits[2] DATASEC [25:1049,1:2051] up+ ver-
hedit ../dark/*.fits[2] BIASSEC [1:24,1:2051] up+ ver-
hedit ../dark/*.fits[2] TRIMSEC [25:1049,1:2051] up+ ver-

darkcombine ../dark/*.fits[1] output="dark1" reject = "minmax" ccdtype="" process=no
darkcombine ../dark/*.fits[2] output="dark2" reject = "minmax" ccdtype="" process=no

hedit ../flat/*.fits[1] CCDSEC [25:1049,1:2051] up+ ver-
hedit ../flat/*.fits[1] DATASEC [25:1049,1:2051] up+ ver-
hedit ../flat/*.fits[1] BIASSEC [1:24,1:2051] up+ ver-
hedit ../flat/*.fits[1] TRIMSEC [275:1049,1:2051] up+ ver-

hedit ../flat/*.fits[2] CCDSEC [25:1049,1:2051] up+ ver-
hedit ../flat/*.fits[2] DATASEC [25:1049,1:2051] up+ ver-
hedit ../flat/*.fits[2] BIASSEC [1:24,1:2051] up+ ver-
hedit ../flat/*.fits[2] TRIMSEC [25:1049,1:2051] up+ ver-

hedit ../object/*.fits[1] CCDSEC [25:1049,1:2051] up+ ver-
hedit ../object/*.fits[1] DATASEC [25:1049,1:2051] up+ ver-
hedit ../object/*.fits[1] BIASSEC [1:24,1:2051] up+ ver-
hedit ../object/*.fits[1] TRIMSEC [275:1049,1:2051] up+ ver-

hedit ../object/*.fits[2] CCDSEC [25:1049,1:2051] up+ ver-
hedit ../object/*.fits[2] DATASEC [25:1049,1:2051] up+ ver-
hedit ../object/*.fits[2] BIASSEC [1:24,1:2051] up+ ver-
hedit ../object/*.fits[2] TRIMSEC [25:1049,1:2051] up+ ver-

ccdproc ../object/*.fits[1] output=@lista1  zerocor=yes over+ darkcor=yes trim=yes zero="bias1" dark="dark1" biassec=[1:24,1:2051] trimsec=[275:1049,1:2051]
ccdproc ../object/*.fits[2] output=@lista2  zerocor=yes over+ darkcor=yes trim=yes zero="bias2" dark="dark2" biassec=[1:24,1:2051] trimsec=[25:1025,1:2051]

ccdproc ../flat/*.fits[1] output=@lista_f1  zerocor=yes over+ darkcor=no trim=yes zero="bias1"  biassec=[1:24,1:2051] trimsec=[275:1049,1:2051]
ccdproc ../flat/*.fits[2] output=@lista_f2  zerocor=yes over+ darkcor=no trim=yes zero="bias2"  biassec=[1:24,1:2051] trimsec=[25:1025,1:2051]

flatcombine bd11501d1,bd11502d1,bd11503d1   output=flat1z1 combine="average" reject = "avsigclip" ccdtype=""
flatcombine bd11501d2,bd11502d2,bd11503d2   output=flat2z1 combine="average" reject = "avsigclip" ccdtype=""
flatcombine bd11504d1,bd11505d1,bd11506d1   output=flat1z2 combine="average" reject = "avsigclip" ccdtype=""
flatcombine bd11504d2,bd11505d2,bd11506d2   output=flat2z2 combine="average" reject = "avsigclip" ccdtype=""
flatcombine bd11507d1,bd11508d1,bd11509d1   output=flat1z3 combine="average" reject = "avsigclip" ccdtype=""
flatcombine bd11507d2,bd11508d2,bd11509d2   output=flat2z3 combine="average" reject = "avsigclip" ccdtype=""
flatcombine bd11510d1,bd11511d1,bd11512d1   output=flat1z4 combine="average" reject = "avsigclip" ccdtype=""
flatcombine bd11510d2,bd11511d2,bd11512d2   output=flat2z4 combine="average" reject = "avsigclip" ccdtype=""
flatcombine bd11513d1,bd11514d1,bd11515d1   output=flat1z5 combine="average" reject = "avsigclip" ccdtype=""
flatcombine bd11513d2,bd11514d2,bd11515d2   output=flat2z5 combine="average" reject = "avsigclip" ccdtype=""

ccdproc bd11481d1   output=fbd11481d1 flatcor=yes flat=flat1z1
ccdproc bd11482d1   output=fbd11482d1 flatcor=yes flat=flat1z2
ccdproc bd11483d1   output=fbd11483d1 flatcor=yes flat=flat1z3
ccdproc bd11484d1   output=fbd11484d1 flatcor=yes flat=flat1z4
ccdproc bd11485d1   output=fbd11485d1 flatcor=yes flat=flat1z5
ccdproc bd11481d2   output=fbd11481d2 flatcor=yes flat=flat2z1
ccdproc bd11482d2   output=fbd11482d2 flatcor=yes flat=flat2z2
ccdproc bd11483d2   output=fbd11483d2 flatcor=yes flat=flat2z3
ccdproc bd11484d2   output=fbd11484d2 flatcor=yes flat=flat2z4
ccdproc bd11485d2   output=fbd11485d2 flatcor=yes flat=flat2z5

daofind fbd11483d1 
ccxymatch fbd11483d1.coo.1  mrk1157_usnob fbd11483d1.allmatch refpoin="fbd11483d1_ref" lngcolu=2 latcolu=3 xcolumn=1 ycolumn=2 lngunits="hours" latunits="degrees" matching="tolerance"
ccmap fbd11483d1.allmatch fbd11483d1.db images=fbd11483d1 xxorder=3 xyorder=3 xcolumn=3 ycolumn=4 lngcolu=1 latcolu=2 yxorder=3 yyorder=3 xxterms=full yxterms=full
ccsetwcs fbd11483d1 fbd11483d1.db fbd11483d1 lngunits="hours" latunits="degrees"

daofind fbd11485d1 
ccxymatch fbd11485d1.coo.1  mrk1157_usnob fbd11485d1.allmatch refpoin="fbd11485d1_ref" lngcolu=2 latcolu=3 xcolumn=1 ycolumn=2 lngunits="hours" latunits="degrees" matching="tolerance"
ccmap fbd11485d1.allmatch fbd11485d1.db images=fbd11485d1 xxorder=3 xyorder=3 xxterms=full yxterms=full xcolumn=3 ycolumn=4 lngcolu=1 latcolu=2 yxorder=3 yyorder=3 
ccsetwcs fbd11485d1 fbd11485d1.db fbd11485d1 lngunits="hours" latunits="degrees"

daofind fbd11482d1 
ccxymatch fbd11482d1.coo.1  mrk1157_usnob fbd11482d1.allmatch refpoin="fbd11482d1_ref" lngcolu=2 latcolu=3 xcolumn=1 ycolumn=2 lngunits="hours" latunits="degrees" matching="tolerance"
ccmap fbd11482d1.allmatch fbd11482d1.db images=fbd11482d1 xxorder=2 xyorder=3 xcolumn=3 ycolumn=4 lngcolu=1 latcolu=2 yxorder=3 yyorder=3 xxterms=full yxterms=full
ccsetwcs fbd11482d1 fbd11482d1.db fbd11482d1 lngunits="hours" latunits="degrees"

daofind fbd11481d1 
ccxymatch fbd11481d1.coo.1  mrk1157_usnob fbd11481d1.allmatch refpoin="fbd11481d1_ref" lngcolu=2 latcolu=3 xcolumn=1 ycolumn=2 lngunits="hours" latunits="degrees" matching="tolerance"
ccmap fbd11481d1.allmatch fbd11481d1.db images=fbd11481d1 xxorder=3 xyorder=3 xcolumn=3 ycolumn=4 lngcolu=1 latcolu=2 yxorder=3 yyorder=3 xxterms=full yxterms=full
ccsetwcs fbd11481d1 fbd11481d1.db fbd11481d1 lngunits="hours" latunits="degrees"

daofind fbd11484d1 
ccxymatch fbd11484d1.coo.1  mrk1157_usnob fbd11484d1.allmatch refpoin="fbd11484d1_ref" lngcolu=2 latcolu=3 xcolumn=1 ycolumn=2 lngunits="hours" latunits="degrees" matching="tolerance"
ccmap fbd11484d1.allmatch fbd11484d1.db images=fbd11484d1 xxorder=3 xyorder=3 xcolumn=3 ycolumn=4 lngcolu=1 latcolu=2 yxorder=3 yyorder=3 xxterms=full yxterms=full
ccsetwcs fbd11484d1 fbd11484d1.db fbd11484d1 lngunits="hours" latunits="degrees"


