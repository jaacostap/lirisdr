/* stfgraph.x -- translated by f2c (version 19990503).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Common Block Declarations */

struct {
    doublereal memd[1];
} mem_;

#define mem_1 mem_

struct {
    logical xerflg, xerpad[84];
} xercom_;

#define xercom_1 xercom_

/* Table of constant values */

static integer c__1023 = 1023;
static integer c__2 = 2;
static integer c__5 = 5;
static integer c__6 = 6;
static real c_b57 = 1.6e38f;
static integer c__0 = 0;
static integer c__33 = 33;
static integer c__3 = 3;
static integer c__1 = 1;
static real c_b232 = .15f;
static real c_b233 = .95f;
static real c_b234 = .1f;
static real c_b235 = .88f;
static integer c__9 = 9;
static real c_b251 = .54f;
static integer c__10 = 10;
static real c_b261 = .44f;
static integer c__102 = 102;
static integer c__114 = 114;
static integer c__4 = 4;
static integer c__101 = 101;
static integer c__109 = 109;
static integer c__116 = 116;
static integer c__7 = 7;
static real c_b363 = .47f;
static integer c__8 = 8;
static integer c__11 = 11;
static real c_b376 = .63f;
static integer c__15 = 15;
static real c_b388 = 2.f;
static real c_b389 = 0.f;
static real c_b393 = .5f;
static real c_b394 = .93f;
static real c_b720 = .99f;
static real c_b722 = .96f;
static integer c__255 = 255;
static integer c__16 = 16;
static real c_b857 = 3.f;
static integer c__14 = 14;
static integer c__309 = 309;
static real c_b891 = 4.f;
static real c_b896 = 1.f;
static real c_b916 = -.1f;
static real c_b919 = .05f;
static integer c__301 = 301;
static real c_b1026 = .98f;
static integer c__111 = 111;
static integer c__112 = 112;
static integer c__211 = 211;
static integer c__212 = 212;
static integer c__209 = 209;
static integer c__17 = 17;
static real c_b1221 = .9f;
static integer c__110 = 110;
static integer c__210 = 210;
static integer c__12 = 12;
static integer c__512 = 512;
static integer c__310 = 310;

/* Subroutine */ int stfgrh_(integer *sf)
{
    /* Initialized data */

    static shortint st0003[8] = { 79,112,116,105,111,110,115,0 };
    static shortint st0093[5] = { 70,87,72,77,0 };
    static shortint st0094[8] = { 104,61,99,44,118,61,116,0 };
    static shortint st0095[8] = { 104,61,99,44,118,61,116,0 };
    static shortint st0096[8] = { 104,61,99,44,118,61,116,0 };
    static shortint st0097[9] = { 103,114,97,112,104,99,117,114,0 };
    static real fa[8] = { 0.f,1.f,1.f,0.f,0.f,0.f,1.f,1.f };
    static shortint st0004[25] = { 108,105,114,105,115,95,113,108,36,115,114,
	    99,47,115,116,102,104,101,108,112,46,107,101,121,0 };
    static shortint st0005[8] = { 79,112,116,105,111,110,115,0 };
    static shortint st0006[2] = { 7,0 };
    static shortint st0007[47] = { 68,101,108,101,116,101,32,105,109,97,103,
	    101,44,32,115,116,97,114,44,32,102,111,99,117,115,44,32,111,114,
	    32,112,111,105,110,116,63,32,40,105,124,115,124,102,124,112,41,0 }
	    ;
    static shortint st0008[9] = { 103,114,97,112,104,99,117,114,0 };
    static shortint st0009[4] = { 37,115,10,0 };
    static shortint st0010[35] = { 66,101,115,116,32,102,111,99,117,115,32,
	    101,115,116,105,109,97,116,101,115,32,102,111,114,32,101,97,99,
	    104,32,115,116,97,114,0 };
    static shortint st0011[29] = { 83,116,97,114,58,32,120,61,37,46,50,102,44,
	    32,121,61,37,46,50,102,44,32,109,61,37,46,50,102,0 };
    static shortint st0012[1] = { 0 };
    static shortint st0013[1] = { 0 };
    static shortint st0014[1] = { 0 };
    static shortint st0015[6] = { 70,111,99,117,115,0 };
    static shortint st0016[12] = { 69,108,108,105,112,116,105,99,105,116,121,
	    0 };
    static shortint st0017[29] = { 83,116,97,114,58,32,120,61,37,46,50,102,44,
	    32,121,61,37,46,50,102,44,32,109,61,37,46,50,102,0 };
    static shortint st0018[1] = { 0 };
    static shortint st0019[1] = { 0 };
    static shortint st0020[10] = { 77,97,103,110,105,116,117,100,101,0 };
    static shortint st0021[12] = { 69,108,108,105,112,116,105,99,105,116,121,
	    0 };
    static shortint st0022[29] = { 83,116,97,114,58,32,120,61,37,46,50,102,44,
	    32,121,61,37,46,50,102,44,32,109,61,37,46,50,102,0 };
    static shortint st0023[1] = { 0 };
    static shortint st0024[1] = { 0 };
    static shortint st0025[13] = { 70,105,101,108,100,32,114,97,100,105,117,
	    115,0 };
    static shortint st0026[12] = { 69,108,108,105,112,116,105,99,105,116,121,
	    0 };
    static shortint st0027[1] = { 0 };
    static shortint st0028[1] = { 0 };
    static shortint st0029[14] = { 69,110,99,108,111,115,101,100,32,102,108,
	    117,120,0 };
    static shortint st0030[1] = { 0 };
    static shortint st0031[7] = { 82,97,100,105,117,115,0 };
    static shortint st0032[8] = { 80,114,111,102,105,108,101,0 };
    static shortint st0033[1] = { 0 };
    static shortint st0034[14] = { 69,110,99,108,111,115,101,100,32,102,108,
	    117,120,0 };
    static shortint st0035[5] = { 70,87,72,77,0 };
    static shortint st0036[8] = { 104,61,99,44,118,61,116,0 };
    static shortint st0037[7] = { 82,97,100,105,117,115,0 };
    static shortint st0038[14] = { 69,110,99,108,111,115,101,100,32,102,108,
	    117,120,0 };
    static shortint st0039[1] = { 0 };
    static shortint st0040[1] = { 0 };
    static shortint st0041[10] = { 77,97,103,110,105,116,117,100,101,0 };
    static shortint st0042[12] = { 69,108,108,105,112,116,105,99,105,116,121,
	    0 };
    static shortint st0043[14] = { 69,110,99,108,111,115,101,100,32,102,108,
	    117,120,0 };
    static shortint st0044[5] = { 70,87,72,77,0 };
    static shortint st0045[7] = { 82,97,100,105,117,115,0 };
    static shortint st0046[8] = { 80,114,111,102,105,108,101,0 };
    static shortint st0047[1] = { 0 };
    static shortint st0048[1] = { 0 };
    static shortint st0049[13] = { 70,105,101,108,100,32,114,97,100,105,117,
	    115,0 };
    static shortint st0050[12] = { 69,108,108,105,112,116,105,99,105,116,121,
	    0 };
    static shortint st0051[1] = { 0 };
    static shortint st0052[1] = { 0 };
    static shortint st0053[14] = { 69,110,99,108,111,115,101,100,32,102,108,
	    117,120,0 };
    static shortint st0054[1] = { 0 };
    static shortint st0055[7] = { 82,97,100,105,117,115,0 };
    static shortint st0056[8] = { 80,114,111,102,105,108,101,0 };
    static shortint st0057[1] = { 0 };
    static shortint st0058[14] = { 69,110,99,108,111,115,101,100,32,102,108,
	    117,120,0 };
    static shortint st0059[5] = { 70,87,72,77,0 };
    static shortint st0060[8] = { 104,61,99,44,118,61,116,0 };
    static shortint st0061[1] = { 0 };
    static shortint st0062[1] = { 0 };
    static shortint st0063[1] = { 0 };
    static shortint st0064[6] = { 70,111,99,117,115,0 };
    static shortint st0065[12] = { 69,108,108,105,112,116,105,99,105,116,121,
	    0 };
    static shortint st0066[29] = { 83,116,97,114,58,32,120,61,37,46,50,102,44,
	    32,121,61,37,46,50,102,44,32,109,61,37,46,50,102,0 };
    static shortint st0067[7] = { 82,97,100,105,117,115,0 };
    static shortint st0068[14] = { 69,110,99,108,111,115,101,100,32,102,108,
	    117,120,0 };
    static shortint st0069[29] = { 83,116,97,114,58,32,120,61,37,46,50,102,44,
	    32,121,61,37,46,50,102,44,32,109,61,37,46,50,102,0 };
    static shortint st0070[14] = { 69,110,99,108,111,115,101,100,32,102,108,
	    117,120,0 };
    static shortint st0071[5] = { 70,87,72,77,0 };
    static shortint st0072[29] = { 83,116,97,114,58,32,120,61,37,46,50,102,44,
	    32,121,61,37,46,50,102,44,32,109,61,37,46,50,102,0 };
    static shortint st0001[9] = { 115,116,100,103,114,97,112,104,0 };
    static shortint st0073[7] = { 82,97,100,105,117,115,0 };
    static shortint st0074[8] = { 112,114,111,102,105,108,101,0 };
    static shortint st0075[1] = { 0 };
    static shortint st0076[1] = { 0 };
    static shortint st0077[14] = { 69,110,99,108,111,115,101,100,32,102,108,
	    117,120,0 };
    static shortint st0078[1] = { 0 };
    static shortint st0079[7] = { 82,97,100,105,117,115,0 };
    static shortint st0080[8] = { 80,114,111,102,105,108,101,0 };
    static shortint st0081[1] = { 0 };
    static shortint st0082[14] = { 69,110,99,108,111,115,101,100,32,102,108,
	    117,120,0 };
    static shortint st0002[25] = { 108,105,114,105,115,95,113,108,36,115,114,
	    99,47,112,115,102,104,101,108,112,46,107,101,121,0 };
    static shortint st0083[5] = { 70,87,72,77,0 };
    static shortint st0084[8] = { 104,61,99,44,118,61,116,0 };
    static shortint st0085[1] = { 0 };
    static shortint st0086[1] = { 0 };
    static shortint st0087[14] = { 69,110,99,108,111,115,101,100,32,102,108,
	    117,120,0 };
    static shortint st0088[1] = { 0 };
    static shortint st0089[7] = { 82,97,100,105,117,115,0 };
    static shortint st0090[8] = { 80,114,111,102,105,108,101,0 };
    static shortint st0091[1] = { 0 };
    static shortint st0092[14] = { 69,110,99,108,111,115,101,100,32,102,108,
	    117,120,0 };

    /* System generated locals */
    integer i__1, i__2, i__3, i__4;
    real r__1, r__2;

    /* Builtin functions */
    double sqrt(doublereal);
    integer i_nint(real *);
    double r_lg10(real *);

    /* Local variables */
    static integer i__, j;
    static real x, y, r2;
    static integer gp, ix, iy, sp, nx, ny;
    static real wx, wy;
    static integer cmd, sfd, sff, key, sfs, wcs;
#define memb ((logical *)&mem_1)
#define memc ((shortint *)&mem_1)
#define memi ((integer *)&mem_1)
#define meml ((integer *)&mem_1)
    static integer sw0001, sw0002, sw0003, sw0004, sw0005;
#define memr ((real *)&mem_1)
#define mems ((shortint *)&mem_1)
    static integer sw0006, sw0007, sw0008, sw0009;
#define memx ((complex *)&mem_1)
    static integer sw0010, pkey, sw0011, sw0012, skey, sw0013, sw0014, sw0015,
	     sw0016, sw0017, sw0018, sw0019;
    static real r2min;
    extern integer gopen_(shortint *, integer *, integer *);
    static integer title;
    extern /* Subroutine */ int smark_(integer *), gseti_(integer *, integer *
	    , integer *), stfg11_(integer *, integer *, integer *, shortint *)
	    , stfg12_(integer *, integer *, integer *, shortint *), sysid_(
	    shortint *, integer *), pargr_(real *), stfg2_(integer *, integer 
	    *, shortint *), stfg3_(integer *, integer *, shortint *), stfg1_(
	    integer *, integer *, integer *, integer *, shortint *, shortint *
	    , shortint *), gfill_(integer *, real *, real *, integer *, 
	    integer *), stfg9_(integer *, integer *, shortint *), stfg10_(
	    integer *, integer *, shortint *), stfg4_(integer *, integer *, 
	    shortint *), stfg5_(integer *, integer *, shortint *), stfg6_(
	    integer *, integer *, shortint *, shortint *, shortint *), stfg7_(
	    integer *, integer *, shortint *, shortint *, shortint *), stfg8_(
	    integer *, integer *, shortint *, shortint *, shortint *), gsetr_(
	    integer *, integer *, real *), gline_(integer *, real *, real *, 
	    real *, real *), gtext_(integer *, real *, real *, shortint *, 
	    shortint *), sfree_(integer *), gpagee_(integer *, shortint *, 
	    shortint *), gclear_(integer *), gclose_(integer *), salloc_(
	    integer *, integer *, integer *);
    static integer nearet;
    extern integer clgcur_(shortint *, real *, real *, integer *, integer *, 
	    shortint *, integer *);
    extern /* Subroutine */ int gctran_(integer *, real *, real *, real *, 
	    real *, integer *, integer *);
    static integer redraw;
    extern /* Subroutine */ int stfcon_(integer *, shortint *, integer *), 
	    stffis_(integer *), stftie_(integer *, integer *, integer *, 
	    integer *, shortint *, integer *), pargsr_(shortint *), sprinf_(
	    shortint *, integer *, shortint *);
    static integer curret;
    extern /* Subroutine */ int gsview_(integer *, real *, real *, real *, 
	    real *), xprinf_(shortint *), stfnom_(integer *, integer *, real *
	    , real *), xerpsh_(void), stffws_(integer *, integer *);
    static integer sysidr;
    extern logical xerpop_(void);
    extern /* Subroutine */ int stfwis_(integer *, integer *), zzepro_(void);

    smark_(&sp);
    salloc_(&sysidr, &c__1023, &c__2);
    salloc_(&title, &c__1023, &c__2);
    salloc_(&cmd, &c__1023, &c__2);
    sysid_(&memc[sysidr - 1], &c__1023);
    memi[*sf + 18] = gopen_(st0001, &c__5, &c__6);
    gp = memi[*sf + 18];
    wcs = 0;
    if (! (memi[*sf + 32] > 1)) {
	goto L110;
    }
    key = 102;
    goto L111;
L110:
    if (! (memi[*sf + 29] > 1)) {
	goto L120;
    }
    key = 97;
    goto L121;
L120:
    key = 122;
L121:
L111:
    pkey = 0;
    skey = 1;
    curret = memi[*sf + 38];
L130:
    sw0001 = key;
    goto L140;
L150:
    goto L132;
L160:
    if (! (memi[*sf - 1] == 2)) {
	goto L170;
    }
    gpagee_(&gp, st0002, st0003);
    goto L171;
L170:
    gpagee_(&gp, st0004, st0005);
L171:
    goto L131;
L180:
    xerpsh_();
    stfcon_(sf, &memc[cmd - 1], &redraw);
    if (! xerpop_()) {
	goto L190;
    }
    redraw = 0;
L190:
    if (! (redraw == 0)) {
	goto L200;
    }
    goto L131;
L200:
    goto L141;
L210:
    if (! (memi[*sf + 29] > 1 && memi[*sf + 32] > 1)) {
	goto L220;
    }
    goto L221;
L220:
    if (! (memi[*sf + 29] > 1)) {
	goto L230;
    }
    if (! (key == 98)) {
	goto L240;
    }
    key = 97;
L240:
    if (! (key == 102)) {
	goto L250;
    }
    key = 109;
L250:
    goto L231;
L230:
    if (! (memi[*sf + 32] > 1)) {
	goto L260;
    }
    if (! (key == 97 || key == 98 || key == 109 || key == 116)) {
	goto L270;
    }
    key = 102;
L270:
    goto L261;
L260:
    key = 122;
L261:
L231:
L221:
    sw0002 = key;
    goto L280;
L290:
    goto L281;
L300:
    if (! (key == pkey)) {
	goto L310;
    }
    goto L131;
L310:
    goto L281;
L280:
    if (sw0002 == 101) {
	goto L290;
    }
    if (sw0002 == 103) {
	goto L290;
    }
    if (sw0002 == 112) {
	goto L290;
    }
    goto L300;
L281:
    goto L141;
L320:
    if (! (pkey != 97 && pkey != 98)) {
	goto L330;
    }
    goto L131;
L330:
    skey = (skey + 1) % 2;
    goto L141;
L340:
    j = 0;
    i__1 = memi[*sf + 27];
    for (i__ = 1; i__ <= i__1; ++i__) {
	sfd = memi[memi[*sf + 28] + i__ - 2];
	if (! (memi[sfd + 88] != 0)) {
	    goto L360;
	}
	memi[sfd + 88] = 0;
	++j;
L360:
/* L350: */
	;
    }
/* L351: */
    if (! (j == 0)) {
	goto L370;
    }
    goto L131;
L370:
    stffis_(sf);
    goto L141;
L380:
    goto L141;
L390:
    xprinf_(st0006);
    goto L131;
L140:
    if (sw0001 == 32) {
	goto L380;
    }
    if (sw0001 == 58) {
	goto L180;
    }
    if (sw0001 == 63) {
	goto L160;
    }
    if (sw0001 == 97) {
	goto L210;
    }
    if (sw0001 == 98) {
	goto L210;
    }
    if (sw0001 == 100) {
	goto L380;
    }
    if (sw0001 == 101) {
	goto L210;
    }
    if (sw0001 == 102) {
	goto L210;
    }
    if (sw0001 == 103) {
	goto L210;
    }
    if (sw0001 == 105) {
	goto L380;
    }
    if (sw0001 == 109) {
	goto L210;
    }
    if (sw0001 == 110) {
	goto L380;
    }
    if (sw0001 == 111) {
	goto L380;
    }
    if (sw0001 == 112) {
	goto L210;
    }
    if (sw0001 == 113) {
	goto L150;
    }
    if (sw0001 == 114) {
	goto L380;
    }
    if (sw0001 == 115) {
	goto L320;
    }
    if (sw0001 == 116) {
	goto L210;
    }
    if (sw0001 == 117) {
	goto L340;
    }
    if (sw0001 == 120) {
	goto L380;
    }
    if (sw0001 == 122) {
	goto L210;
    }
    goto L390;
L141:
    sw0003 = key;
    goto L400;
L410:
    pkey = pkey;
    nearet = curret;
    goto L401;
L420:
    if (! (wcs != 7 || pkey == 112)) {
	goto L430;
    }
    goto L131;
L430:
    pkey = pkey;
    nearet = curret;
    if (! (key == 110)) {
	goto L440;
    }
    stfnom_(sf, &nearet, &wx, &c_b57);
    goto L441;
L440:
    stfnom_(sf, &nearet, &wx, &wy);
L441:
    stfwis_(sf, &nearet);
    stffws_(sf, &nearet);
    stffis_(sf);
    goto L401;
L450:
    sw0004 = pkey;
    goto L460;
L470:
    sff = memi[curret + 91];
    i__ = 1;
L480:
    if (! (memi[memi[*sf + 34] + i__ - 2] != sff)) {
	goto L482;
    }
/* L481: */
    ++i__;
    goto L480;
L482:
    j = memi[*sf + 33];
    i__ = i__ % j + 1;
L490:
    if (! (memi[memi[memi[*sf + 34] + i__ - 2] + 1] == 0)) {
	goto L492;
    }
/* L491: */
    i__ = i__ % j + 1;
    goto L490;
L492:
    if (! (memi[memi[*sf + 34] + i__ - 2] == sff)) {
	goto L500;
    }
    goto L131;
L500:
    sff = memi[memi[*sf + 34] + i__ - 2];
    i__1 = memi[sff + 3];
    for (i__ = 1; i__ <= i__1; ++i__) {
	nearet = memi[sff + i__ + 3];
	if (! (memi[nearet + 88] == 0)) {
	    goto L520;
	}
	goto L511;
L520:
/* L510: */
	;
    }
L511:
    goto L461;
L530:
    sw0005 = wcs;
    goto L540;
L550:
    i__ = 1;
L560:
    if (! (memi[memi[*sf + 28] + i__ - 2] != curret)) {
	goto L562;
    }
/* L561: */
    ++i__;
    goto L560;
L562:
    j = memi[*sf + 27];
    i__ = i__ % j + 1;
L570:
    if (! (memi[memi[memi[*sf + 28] + i__ - 2] + 88] != 0)) {
	goto L572;
    }
/* L571: */
    i__ = i__ % j + 1;
    goto L570;
L572:
    nearet = memi[memi[*sf + 28] + i__ - 2];
    goto L541;
L580:
    sfs = memi[curret + 90];
    i__ = 1;
L590:
    if (! (memi[sfs + i__ + 5] != curret)) {
	goto L592;
    }
/* L591: */
    ++i__;
    goto L590;
L592:
    j = memi[sfs + 5];
    i__ = i__ % j + 1;
L600:
    if (! (memi[memi[sfs + i__ + 5] + 88] != 0)) {
	goto L602;
    }
/* L601: */
    i__ = i__ % j + 1;
    goto L600;
L602:
    nearet = memi[sfs + i__ + 5];
    if (! (nearet == curret)) {
	goto L610;
    }
    goto L131;
L610:
    goto L541;
L620:
    sff = memi[curret + 91];
    i__ = 1;
L630:
    if (! (memi[sff + i__ + 3] != curret)) {
	goto L632;
    }
/* L631: */
    ++i__;
    goto L630;
L632:
    j = memi[sff + 3];
    i__ = i__ % j + 1;
L640:
    if (! (memi[memi[sff + i__ + 3] + 88] != 0)) {
	goto L642;
    }
/* L641: */
    i__ = i__ % j + 1;
    goto L640;
L642:
    nearet = memi[sff + i__ + 3];
    if (! (nearet == curret)) {
	goto L650;
    }
    goto L131;
L650:
    goto L541;
L540:
    sw0005 += -6;
    if (sw0005 < 1 || sw0005 > 5) {
	goto L541;
    }
    switch (sw0005) {
	case 1:  goto L550;
	case 2:  goto L550;
	case 3:  goto L580;
	case 4:  goto L620;
	case 5:  goto L550;
    }
L541:
    goto L461;
L660:
    goto L131;
L460:
    if (sw0004 == 97) {
	goto L470;
    }
    if (sw0004 == 101) {
	goto L530;
    }
    if (sw0004 == 103) {
	goto L530;
    }
    if (sw0004 == 109) {
	goto L470;
    }
    if (sw0004 == 112) {
	goto L530;
    }
    if (sw0004 == 116) {
	goto L470;
    }
    if (sw0004 == 122) {
	goto L530;
    }
    goto L660;
L461:
    goto L401;
L670:
    sw0006 = pkey;
    goto L680;
L690:
    r2min = 9.9e36f;
    gctran_(&gp, &wx, &wy, &wx, &wy, &wcs, &c__0);
    sff = memi[curret + 91];
    i__1 = memi[sff + 3];
    for (i__ = 1; i__ <= i__1; ++i__) {
	sfd = memi[sff + i__ + 3];
	if (! (memi[sfd + 88] != 0)) {
	    goto L710;
	}
	goto L700;
L710:
	sw0007 = wcs;
	goto L720;
L730:
	x = memr[sfd + 48];
	y = memr[sfd + 49];
	goto L721;
L740:
	x = memr[sfd + 48];
	y = memr[sfd + 51];
	goto L721;
L750:
	x = memr[sfd + 51];
	y = memr[sfd + 49];
	goto L721;
L760:
	x = memr[sfd + 48];
	y = memr[sfd + 53];
	goto L721;
L770:
	x = memr[sfd + 53];
	y = memr[sfd + 49];
	goto L721;
L720:
	if (sw0007 < 1 || sw0007 > 5) {
	    goto L721;
	}
	switch (sw0007) {
	    case 1:  goto L730;
	    case 2:  goto L740;
	    case 3:  goto L750;
	    case 4:  goto L760;
	    case 5:  goto L770;
	}
L721:
	gctran_(&gp, &x, &y, &x, &y, &wcs, &c__0);
/* Computing 2nd power */
	r__1 = x - wx;
/* Computing 2nd power */
	r__2 = y - wy;
	r2 = r__1 * r__1 + r__2 * r__2;
	if (! (r2 < r2min)) {
	    goto L780;
	}
	r2min = r2;
	nearet = sfd;
L780:
L700:
	;
    }
/* L701: */
    goto L681;
L790:
    r2min = 9.9e36f;
    gctran_(&gp, &wx, &wy, &wx, &wy, &wcs, &c__0);
    i__1 = memi[*sf + 30];
    for (i__ = 1; i__ <= i__1; ++i__) {
	sfs = memi[memi[*sf + 31] + i__ - 2];
	if (! (memi[sfs + 3] == 0)) {
	    goto L810;
	}
	goto L800;
L810:
	sw0008 = wcs;
	goto L820;
L830:
	x = memr[memi[sfs + 6] + 48];
	y = memr[memi[sfs + 6] + 49];
	goto L821;
L840:
	x = memr[memi[sfs + 6] + 48];
	y = memr[sfs + 1];
	goto L821;
L850:
	x = memr[sfs + 1];
	y = memr[memi[sfs + 6] + 49];
	goto L821;
L860:
	x = memr[memi[sfs + 6] + 48];
	y = memr[sfs];
	goto L821;
L870:
	x = memr[sfs];
	y = memr[memi[sfs + 6] + 49];
	goto L821;
L820:
	if (sw0008 < 1 || sw0008 > 5) {
	    goto L821;
	}
	switch (sw0008) {
	    case 1:  goto L830;
	    case 2:  goto L840;
	    case 3:  goto L850;
	    case 4:  goto L860;
	    case 5:  goto L870;
	}
L821:
	gctran_(&gp, &x, &y, &x, &y, &wcs, &c__0);
/* Computing 2nd power */
	r__1 = x - wx;
/* Computing 2nd power */
	r__2 = y - wy;
	r2 = r__1 * r__1 + r__2 * r__2;
	if (! (r2 < r2min)) {
	    goto L880;
	}
	r2min = r2;
	nearet = sfs;
L880:
L800:
	;
    }
/* L801: */
    sfs = nearet;
    r2min = 9.9e36f;
    i__1 = memi[sfs + 5];
    for (i__ = 1; i__ <= i__1; ++i__) {
	sfd = memi[sfs + i__ + 5];
	if (! (memi[sfd + 88] != 0)) {
	    goto L900;
	}
	goto L890;
L900:
	r2 = memr[sfd + 51];
	if (! (r2 < r2min)) {
	    goto L910;
	}
	r2min = r2;
	nearet = sfd;
L910:
L890:
	;
    }
/* L891: */
    goto L681;
L920:
    sw0009 = wcs;
    goto L930;
L940:
    sfs = memi[curret + 90];
    i__ = memi[sfs + 3];
    if (! (i__ < 4)) {
	goto L950;
    }
    nx = i__;
    ny = 1;
    goto L951;
L950:
    r__1 = sqrt((real) i__);
    nx = i_nint(&r__1);
    if (! ((i__ - 1) % (nx + 1) >= (i__ - 1) % nx)) {
	goto L960;
    }
    ++nx;
L960:
    ny = (i__ - 1) / nx + 1;
L951:
/* Computing MAX */
/* Computing MIN */
    i__3 = nx, i__4 = i_nint(&wx);
    i__1 = 1, i__2 = min(i__3,i__4);
    ix = max(i__1,i__2);
/* Computing MAX */
/* Computing MIN */
    i__3 = ny, i__4 = i_nint(&wy);
    i__1 = 1, i__2 = min(i__3,i__4);
    iy = max(i__1,i__2);
    j = 0;
    i__1 = memi[sfs + 5];
    for (i__ = 1; i__ <= i__1; ++i__) {
	sfd = memi[sfs + i__ + 5];
	if (! (memi[sfd + 88] != 0)) {
	    goto L980;
	}
	goto L970;
L980:
	if (! (ix == j % nx + 1 && iy == j / nx + 1)) {
	    goto L990;
	}
	nearet = sfd;
	goto L971;
L990:
	++j;
L970:
	;
    }
L971:
    goto L931;
L1000:
    sff = memi[curret + 91];
    i__ = memi[sff + 1];
    if (! (i__ < 4)) {
	goto L1010;
    }
    nx = i__;
    ny = 1;
    goto L1011;
L1010:
    r__1 = sqrt((real) i__);
    nx = i_nint(&r__1);
    if (! ((i__ - 1) % (nx + 1) >= (i__ - 1) % nx)) {
	goto L1020;
    }
    ++nx;
L1020:
    ny = (i__ - 1) / nx + 1;
L1011:
/* Computing MAX */
/* Computing MIN */
    i__3 = nx, i__4 = i_nint(&wx);
    i__1 = 1, i__2 = min(i__3,i__4);
    ix = max(i__1,i__2);
/* Computing MAX */
/* Computing MIN */
    i__3 = ny, i__4 = i_nint(&wy);
    i__1 = 1, i__2 = min(i__3,i__4);
    iy = max(i__1,i__2);
    j = 0;
    i__1 = memi[sff + 3];
    for (i__ = 1; i__ <= i__1; ++i__) {
	sfd = memi[sff + i__ + 3];
	if (! (memi[sfd + 88] != 0)) {
	    goto L1040;
	}
	goto L1030;
L1040:
	if (! (ix == j % nx + 1 && iy == j / nx + 1)) {
	    goto L1050;
	}
	nearet = sfd;
	goto L1031;
L1050:
	++j;
L1030:
	;
    }
L1031:
    goto L931;
L930:
    if (sw0009 == 9) {
	goto L940;
    }
    if (sw0009 == 10) {
	goto L1000;
    }
L931:
    if (! (key == pkey && nearet == curret)) {
	goto L1060;
    }
    goto L131;
L1060:
    goto L681;
L1070:
    sw0010 = wcs;
    goto L1080;
L1090:
    r2min = 9.9e36f;
    gctran_(&gp, &wx, &wy, &wx, &wy, &wcs, &c__0);
    i__1 = memi[*sf + 27];
    for (i__ = 1; i__ <= i__1; ++i__) {
	sfd = memi[memi[*sf + 28] + i__ - 2];
	if (! (memi[sfd + 88] != 0)) {
	    goto L1110;
	}
	goto L1100;
L1110:
	sw0011 = wcs;
	goto L1120;
L1130:
	x = memr[sfd + 50];
	y = memr[sfd + 51];
	goto L1121;
L1140:
	x = memr[sfd + 50];
	y = memr[sfd + 53];
	goto L1121;
L1120:
	if (sw0011 == 1) {
	    goto L1130;
	}
	if (sw0011 == 2) {
	    goto L1140;
	}
L1121:
	gctran_(&gp, &x, &y, &x, &y, &wcs, &c__0);
/* Computing 2nd power */
	r__1 = x - wx;
/* Computing 2nd power */
	r__2 = y - wy;
	r2 = r__1 * r__1 + r__2 * r__2;
	if (! (r2 < r2min)) {
	    goto L1150;
	}
	r2min = r2;
	nearet = sfd;
L1150:
L1100:
	;
    }
/* L1101: */
    goto L1081;
L1160:
    r2min = 9.9e36f;
    gctran_(&gp, &wx, &wy, &wx, &wy, &wcs, &c__0);
    sff = memi[curret + 91];
    i__1 = memi[sff + 3];
    for (i__ = 1; i__ <= i__1; ++i__) {
	sfd = memi[sff + i__ + 3];
	if (! (memi[sfd + 88] != 0)) {
	    goto L1180;
	}
	goto L1170;
L1180:
	sw0012 = wcs;
	goto L1190;
L1200:
	r__1 = memr[memi[sfd + 90] + 2] / memr[*sf + 21];
	x = r_lg10(&r__1) * -2.5f;
	y = memr[sfd + 51];
	goto L1191;
L1210:
	r__1 = memr[memi[sfd + 90] + 2] / memr[*sf + 21];
	x = r_lg10(&r__1) * -2.5f;
	y = memr[sfd + 53];
	goto L1191;
L1220:
/* Computing 2nd power */
	r__1 = memr[sfd + 48] - memr[*sf + 16];
/* Computing 2nd power */
	r__2 = memr[sfd + 49] - memr[*sf + 17];
	x = sqrt(r__1 * r__1 + r__2 * r__2);
	y = memr[sfd + 51];
	goto L1191;
L1230:
/* Computing 2nd power */
	r__1 = memr[sfd + 48] - memr[*sf + 16];
/* Computing 2nd power */
	r__2 = memr[sfd + 49] - memr[*sf + 17];
	x = sqrt(r__1 * r__1 + r__2 * r__2);
	y = memr[sfd + 53];
	goto L1191;
L1190:
	sw0012 += -2;
	if (sw0012 < 1 || sw0012 > 4) {
	    goto L1191;
	}
	switch (sw0012) {
	    case 1:  goto L1200;
	    case 2:  goto L1210;
	    case 3:  goto L1220;
	    case 4:  goto L1230;
	}
L1191:
	gctran_(&gp, &x, &y, &x, &y, &wcs, &c__0);
/* Computing 2nd power */
	r__1 = x - wx;
/* Computing 2nd power */
	r__2 = y - wy;
	r2 = r__1 * r__1 + r__2 * r__2;
	if (! (r2 < r2min)) {
	    goto L1240;
	}
	r2min = r2;
	nearet = sfd;
L1240:
L1170:
	;
    }
/* L1171: */
    goto L1081;
L1250:
    nearet = curret;
    goto L1081;
L1080:
    if (sw0010 < 1 || sw0010 > 6) {
	goto L1250;
    }
    switch (sw0010) {
	case 1:  goto L1090;
	case 2:  goto L1090;
	case 3:  goto L1160;
	case 4:  goto L1160;
	case 5:  goto L1160;
	case 6:  goto L1160;
    }
L1081:
    goto L681;
L680:
    if (sw0006 == 97) {
	goto L690;
    }
    if (sw0006 == 98) {
	goto L790;
    }
    if (sw0006 == 101) {
	goto L920;
    }
    if (sw0006 == 103) {
	goto L920;
    }
    if (sw0006 == 112) {
	goto L920;
    }
    goto L1070;
L681:
    sw0013 = key;
    goto L1260;
L1270:
    if (! (memi[*sf + 29] > 1)) {
	goto L1280;
    }
    sfs = memi[nearet + 90];
    i__1 = memi[sfs + 5];
    for (i__ = 1; i__ <= i__1; ++i__) {
	memi[memi[sfs + i__ + 5] + 88] = 1;
/* L1290: */
    }
/* L1291: */
    goto L1281;
L1280:
    memi[nearet + 88] = 1;
L1281:
    stffis_(sf);
    goto L1261;
L1300:
L1310:
    sw0014 = key;
    goto L1320;
L1330:
    sff = memi[nearet + 91];
    i__1 = memi[sff + 3];
    for (i__ = 1; i__ <= i__1; ++i__) {
	memi[memi[sff + i__ + 3] + 88] = 1;
/* L1340: */
    }
/* L1341: */
    goto L1321;
L1350:
    sfd = memi[nearet + 92];
    i__1 = memi[sfd + 40];
    for (i__ = 1; i__ <= i__1; ++i__) {
	memi[memi[sfd + i__ + 40] + 88] = 1;
/* L1360: */
    }
/* L1361: */
    goto L1321;
L1370:
    memi[nearet + 88] = 1;
    goto L1321;
L1380:
    sfs = memi[nearet + 90];
    i__1 = memi[sfs + 5];
    for (i__ = 1; i__ <= i__1; ++i__) {
	memi[memi[sfs + i__ + 5] + 88] = 1;
/* L1390: */
    }
/* L1391: */
    goto L1321;
L1400:
    xprinf_(st0007);
    goto L1311;
L1320:
    if (sw0014 == 102) {
	goto L1330;
    }
    if (sw0014 == 105) {
	goto L1350;
    }
    if (sw0014 == 112) {
	goto L1370;
    }
    if (sw0014 == 115) {
	goto L1380;
    }
    goto L1400;
L1321:
    stffis_(sf);
    goto L1312;
L1311:
    if (! (clgcur_(st0008, &wx, &wy, &wcs, &key, &memc[cmd - 1], &c__1023) == 
	    -2)) {
	goto L1310;
    }
L1312:
    goto L1261;
L1410:
    sw0015 = pkey;
    goto L1420;
L1430:
    sfs = memi[nearet + 90];
    stftie_(sf, &c__0, &sfs, &c__0, &memc[title - 1], &c__1023);
    goto L1421;
L1440:
    stftie_(sf, &nearet, &c__0, &c__0, &memc[title - 1], &c__1023);
    goto L1421;
L1420:
    if (sw0015 == 98) {
	goto L1430;
    }
    goto L1440;
L1421:
    xprinf_(st0009);
    pargsr_(&memc[title - 1]);
    goto L131;
L1450:
    pkey = key;
    goto L1261;
L1260:
    if (sw0013 == 100) {
	goto L1270;
    }
    if (sw0013 == 105) {
	goto L1410;
    }
    if (sw0013 == 120) {
	goto L1300;
    }
    goto L1450;
L1261:
    goto L401;
L400:
    if (sw0003 == 32) {
	goto L450;
    }
    if (sw0003 == 58) {
	goto L410;
    }
    if (sw0003 == 110) {
	goto L420;
    }
    if (sw0003 == 111) {
	goto L420;
    }
    if (sw0003 == 114) {
	goto L410;
    }
    if (sw0003 == 115) {
	goto L410;
    }
    if (sw0003 == 117) {
	goto L410;
    }
    goto L670;
L401:
    if (! (memi[nearet + 88] == 0)) {
	goto L1460;
    }
    curret = nearet;
    goto L1461;
L1460:
    curret = memi[*sf + 38];
L1461:
    gclear_(&gp);
    gseti_(&gp, &c__33, &c__0);
    if (! (memi[*sf + 29] > 1 && memi[*sf + 32] > 1)) {
	goto L1470;
    }
    sw0016 = pkey;
    goto L1480;
L1490:
    sff = memi[curret + 91];
    stftie_(sf, &c__0, &c__0, &sff, &memc[title - 1], &c__1023);
    gseti_(&gp, &c__3, &c__1);
    gsview_(&gp, &c_b232, &c_b233, &c_b234, &c_b235);
    stfg11_(sf, &curret, &skey, &memc[title - 1]);
    goto L1481;
L1500:
    sprinf_(&memc[title - 1], &c__1023, st0010);
    gseti_(&gp, &c__3, &c__1);
    gsview_(&gp, &c_b232, &c_b233, &c_b234, &c_b235);
    stfg12_(sf, &curret, &skey, &memc[title - 1]);
    goto L1481;
L1510:
    sfs = memi[curret + 90];
    sprinf_(&memc[title - 1], &c__1023, st0011);
    pargr_(&memr[curret + 48]);
    pargr_(&memr[curret + 49]);
    r__2 = memr[sfs + 2] / memr[*sf + 21];
    r__1 = r_lg10(&r__2) * -2.5f;
    pargr_(&r__1);
    gseti_(&gp, &c__3, &c__9);
    gsview_(&gp, &c_b232, &c_b233, &c_b251, &c_b235);
    stfg2_(sf, &curret, &memc[title - 1]);
    sff = memi[curret + 91];
    stftie_(sf, &c__0, &c__0, &sff, &memc[title - 1], &c__1023);
    gseti_(&gp, &c__3, &c__10);
    gsview_(&gp, &c_b232, &c_b233, &c_b234, &c_b261);
    stfg3_(sf, &curret, &memc[title - 1]);
    goto L1481;
L1520:
    gseti_(&gp, &c__3, &c__1);
    gsview_(&gp, &c_b232, &c_b233, &c_b251, &c_b235);
    stfg1_(sf, &curret, &c__102, &c__114, st0012, st0013, &memc[*sf * 2]);
    gseti_(&gp, &c__3, &c__2);
    gsview_(&gp, &c_b232, &c_b233, &c_b234, &c_b261);
    gfill_(&gp, fa, &fa[4], &c__4, &c__2);
    stfg1_(sf, &curret, &c__102, &c__101, st0014, st0015, st0016);
    goto L1481;
L1530:
    sfs = memi[curret + 90];
    sprinf_(&memc[title - 1], &c__1023, st0017);
    pargr_(&memr[curret + 48]);
    pargr_(&memr[curret + 49]);
    r__2 = memr[sfs + 2] / memr[*sf + 21];
    r__1 = r_lg10(&r__2) * -2.5f;
    pargr_(&r__1);
    gseti_(&gp, &c__3, &c__9);
    gsview_(&gp, &c_b232, &c_b233, &c_b251, &c_b235);
    stfg9_(sf, &curret, &memc[title - 1]);
    sff = memi[curret + 91];
    stftie_(sf, &c__0, &c__0, &sff, &memc[title - 1], &c__1023);
    gseti_(&gp, &c__3, &c__10);
    gsview_(&gp, &c_b232, &c_b233, &c_b234, &c_b261);
    stfg10_(sf, &curret, &memc[title - 1]);
    goto L1481;
L1540:
    sff = memi[curret + 91];
    stftie_(sf, &c__0, &c__0, &sff, &memc[title - 1], &c__1023);
    gseti_(&gp, &c__3, &c__3);
    gsview_(&gp, &c_b232, &c_b233, &c_b251, &c_b235);
    stfg1_(sf, &curret, &c__109, &c__114, &memc[title - 1], st0018, &memc[*sf 
	    * 2]);
    gseti_(&gp, &c__3, &c__4);
    gsview_(&gp, &c_b232, &c_b233, &c_b234, &c_b261);
    gfill_(&gp, fa, &fa[4], &c__4, &c__2);
    stfg1_(sf, &curret, &c__109, &c__101, st0019, st0020, st0021);
    goto L1481;
L1550:
    sfs = memi[curret + 90];
    sprinf_(&memc[title - 1], &c__1023, st0022);
    pargr_(&memr[curret + 48]);
    pargr_(&memr[curret + 49]);
    r__2 = memr[sfs + 2] / memr[*sf + 21];
    r__1 = r_lg10(&r__2) * -2.5f;
    pargr_(&r__1);
    gseti_(&gp, &c__3, &c__9);
    gsview_(&gp, &c_b232, &c_b233, &c_b251, &c_b235);
    stfg4_(sf, &curret, &memc[title - 1]);
    sff = memi[curret + 91];
    stftie_(sf, &c__0, &c__0, &sff, &memc[title - 1], &c__1023);
    gseti_(&gp, &c__3, &c__10);
    gsview_(&gp, &c_b232, &c_b233, &c_b234, &c_b261);
    stfg5_(sf, &curret, &memc[title - 1]);
    goto L1481;
L1560:
    sff = memi[curret + 91];
    stftie_(sf, &c__0, &c__0, &sff, &memc[title - 1], &c__1023);
    gseti_(&gp, &c__3, &c__5);
    gsview_(&gp, &c_b232, &c_b233, &c_b251, &c_b235);
    stfg1_(sf, &curret, &c__116, &c__114, &memc[title - 1], st0023, &memc[*sf 
	    * 2]);
    gseti_(&gp, &c__3, &c__6);
    gsview_(&gp, &c_b232, &c_b233, &c_b234, &c_b261);
    gfill_(&gp, fa, &fa[4], &c__4, &c__2);
    stfg1_(sf, &curret, &c__116, &c__101, st0024, st0025, st0026);
    goto L1481;
L1570:
    gseti_(&gp, &c__3, &c__7);
    gsview_(&gp, &c_b232, &c_b363, &c_b251, &c_b235);
    stfg6_(sf, &curret, st0027, st0028, st0029);
    gseti_(&gp, &c__3, &c__8);
    gsview_(&gp, &c_b232, &c_b363, &c_b234, &c_b261);
    gfill_(&gp, fa, &fa[4], &c__4, &c__2);
    stfg7_(sf, &curret, st0030, st0031, st0032);
    gseti_(&gp, &c__3, &c__11);
    gsview_(&gp, &c_b376, &c_b233, &c_b251, &c_b235);
    gfill_(&gp, fa, &fa[4], &c__4, &c__2);
    stfg8_(sf, &curret, st0033, st0034, st0035);
    stftie_(sf, &curret, &c__0, &c__0, &memc[title - 1], &c__1023);
    gseti_(&gp, &c__3, &c__0);
    gsetr_(&gp, &c__15, &c_b388);
    gline_(&gp, &c_b389, &c_b389, &c_b389, &c_b389);
    gtext_(&gp, &c_b393, &c_b394, &memc[title - 1], st0036);
    goto L1481;
L1480:
    if (sw0016 == 97) {
	goto L1490;
    }
    if (sw0016 == 98) {
	goto L1500;
    }
    if (sw0016 == 101) {
	goto L1510;
    }
    if (sw0016 == 102) {
	goto L1520;
    }
    if (sw0016 == 103) {
	goto L1530;
    }
    if (sw0016 == 109) {
	goto L1540;
    }
    if (sw0016 == 112) {
	goto L1550;
    }
    if (sw0016 == 116) {
	goto L1560;
    }
    if (sw0016 == 122) {
	goto L1570;
    }
L1481:
    goto L1471;
L1470:
    if (! (memi[*sf + 29] > 1)) {
	goto L1580;
    }
    sw0017 = pkey;
    goto L1590;
L1600:
    sff = memi[curret + 91];
    stftie_(sf, &c__0, &c__0, &sff, &memc[title - 1], &c__1023);
    gseti_(&gp, &c__3, &c__1);
    gsview_(&gp, &c_b232, &c_b233, &c_b234, &c_b235);
    stfg11_(sf, &curret, &skey, &memc[title - 1]);
    goto L1591;
L1610:
    sff = memi[curret + 91];
    stftie_(sf, &c__0, &c__0, &sff, &memc[title - 1], &c__1023);
    gseti_(&gp, &c__3, &c__10);
    gsview_(&gp, &c_b232, &c_b233, &c_b251, &c_b235);
    stfg3_(sf, &curret, &memc[title - 1]);
    stftie_(sf, &curret, &c__0, &c__0, &memc[title - 1], &c__1023);
    gseti_(&gp, &c__3, &c__7);
    gsview_(&gp, &c_b232, &c_b233, &c_b234, &c_b261);
    gfill_(&gp, fa, &fa[4], &c__4, &c__2);
    stfg6_(sf, &curret, &memc[title - 1], st0037, st0038);
    goto L1591;
L1620:
    sff = memi[curret + 91];
    stftie_(sf, &c__0, &c__0, &sff, &memc[title - 1], &c__1023);
    gseti_(&gp, &c__3, &c__3);
    gsview_(&gp, &c_b232, &c_b233, &c_b251, &c_b235);
    stfg1_(sf, &curret, &c__109, &c__114, &memc[title - 1], st0039, &memc[*sf 
	    * 2]);
    gseti_(&gp, &c__3, &c__4);
    gsview_(&gp, &c_b232, &c_b233, &c_b234, &c_b261);
    gfill_(&gp, fa, &fa[4], &c__4, &c__2);
    stfg1_(sf, &curret, &c__109, &c__101, st0040, st0041, st0042);
    goto L1591;
L1630:
    sff = memi[curret + 91];
    stftie_(sf, &c__0, &c__0, &sff, &memc[title - 1], &c__1023);
    gseti_(&gp, &c__3, &c__10);
    gsview_(&gp, &c_b232, &c_b233, &c_b251, &c_b235);
    stfg10_(sf, &curret, &memc[title - 1]);
    stftie_(sf, &curret, &c__0, &c__0, &memc[title - 1], &c__1023);
    gseti_(&gp, &c__3, &c__11);
    gsview_(&gp, &c_b232, &c_b233, &c_b234, &c_b261);
    gfill_(&gp, fa, &fa[4], &c__4, &c__2);
    stfg8_(sf, &curret, &memc[title - 1], st0043, st0044);
    goto L1591;
L1640:
    sff = memi[curret + 91];
    stftie_(sf, &c__0, &c__0, &sff, &memc[title - 1], &c__1023);
    gseti_(&gp, &c__3, &c__10);
    gsview_(&gp, &c_b232, &c_b233, &c_b251, &c_b235);
    stfg5_(sf, &curret, &memc[title - 1]);
    stftie_(sf, &curret, &c__0, &c__0, &memc[title - 1], &c__1023);
    gseti_(&gp, &c__3, &c__7);
    gsview_(&gp, &c_b232, &c_b233, &c_b234, &c_b261);
    gfill_(&gp, fa, &fa[4], &c__4, &c__2);
    stfg7_(sf, &curret, &memc[title - 1], st0045, st0046);
    goto L1591;
L1650:
    sff = memi[curret + 91];
    stftie_(sf, &c__0, &c__0, &sff, &memc[title - 1], &c__1023);
    gseti_(&gp, &c__3, &c__5);
    gsview_(&gp, &c_b232, &c_b233, &c_b251, &c_b235);
    stfg1_(sf, &curret, &c__116, &c__114, &memc[title - 1], st0047, &memc[*sf 
	    * 2]);
    gseti_(&gp, &c__3, &c__6);
    gsview_(&gp, &c_b232, &c_b233, &c_b234, &c_b261);
    gfill_(&gp, fa, &fa[4], &c__4, &c__2);
    stfg1_(sf, &curret, &c__116, &c__101, st0048, st0049, st0050);
    goto L1591;
L1660:
    gseti_(&gp, &c__3, &c__7);
    gsview_(&gp, &c_b232, &c_b363, &c_b251, &c_b235);
    stfg6_(sf, &curret, st0051, st0052, st0053);
    gseti_(&gp, &c__3, &c__8);
    gsview_(&gp, &c_b232, &c_b363, &c_b234, &c_b261);
    gfill_(&gp, fa, &fa[4], &c__4, &c__2);
    stfg7_(sf, &curret, st0054, st0055, st0056);
    gseti_(&gp, &c__3, &c__11);
    gsview_(&gp, &c_b376, &c_b233, &c_b251, &c_b235);
    gfill_(&gp, fa, &fa[4], &c__4, &c__2);
    stfg8_(sf, &curret, st0057, st0058, st0059);
    stftie_(sf, &curret, &c__0, &c__0, &memc[title - 1], &c__1023);
    gseti_(&gp, &c__3, &c__0);
    gsetr_(&gp, &c__15, &c_b388);
    gline_(&gp, &c_b389, &c_b389, &c_b389, &c_b389);
    gtext_(&gp, &c_b393, &c_b394, &memc[title - 1], st0060);
    goto L1591;
L1590:
    if (sw0017 == 97) {
	goto L1600;
    }
    if (sw0017 == 98) {
	goto L1600;
    }
    if (sw0017 == 101) {
	goto L1610;
    }
    if (sw0017 == 102) {
	goto L1620;
    }
    if (sw0017 == 103) {
	goto L1630;
    }
    if (sw0017 == 109) {
	goto L1620;
    }
    if (sw0017 == 112) {
	goto L1640;
    }
    if (sw0017 == 116) {
	goto L1650;
    }
    if (sw0017 == 122) {
	goto L1660;
    }
L1591:
    goto L1581;
L1580:
    if (! (memi[*sf + 32] > 1)) {
	goto L1670;
    }
    sw0018 = pkey;
    goto L1680;
L1690:
    gseti_(&gp, &c__3, &c__1);
    gsview_(&gp, &c_b232, &c_b233, &c_b251, &c_b235);
    stfg1_(sf, &curret, &c__102, &c__114, st0061, st0062, &memc[*sf * 2]);
    gseti_(&gp, &c__3, &c__2);
    gsview_(&gp, &c_b232, &c_b233, &c_b234, &c_b261);
    gfill_(&gp, fa, &fa[4], &c__4, &c__2);
    stfg1_(sf, &curret, &c__102, &c__101, st0063, st0064, st0065);
    goto L1681;
L1700:
    sfs = memi[curret + 90];
    sprinf_(&memc[title - 1], &c__1023, st0066);
    pargr_(&memr[curret + 48]);
    pargr_(&memr[curret + 49]);
    r__2 = memr[sfs + 2] / memr[*sf + 21];
    r__1 = r_lg10(&r__2) * -2.5f;
    pargr_(&r__1);
    gseti_(&gp, &c__3, &c__9);
    gsview_(&gp, &c_b232, &c_b233, &c_b251, &c_b235);
    stfg2_(sf, &curret, &memc[title - 1]);
    stftie_(sf, &curret, &c__0, &c__0, &memc[title - 1], &c__1023);
    gseti_(&gp, &c__3, &c__7);
    gsview_(&gp, &c_b232, &c_b233, &c_b234, &c_b261);
    gfill_(&gp, fa, &fa[4], &c__4, &c__2);
    stfg6_(sf, &curret, &memc[title - 1], st0067, st0068);
    goto L1681;
L1710:
    sfs = memi[curret + 90];
    sprinf_(&memc[title - 1], &c__1023, st0069);
    pargr_(&memr[curret + 48]);
    pargr_(&memr[curret + 49]);
    r__2 = memr[sfs + 2] / memr[*sf + 21];
    r__1 = r_lg10(&r__2) * -2.5f;
    pargr_(&r__1);
    gseti_(&gp, &c__3, &c__9);
    gsview_(&gp, &c_b232, &c_b233, &c_b251, &c_b235);
    stfg9_(sf, &curret, &memc[title - 1]);
    stftie_(sf, &curret, &c__0, &c__0, &memc[title - 1], &c__1023);
    gseti_(&gp, &c__3, &c__11);
    gsview_(&gp, &c_b232, &c_b233, &c_b234, &c_b261);
    gfill_(&gp, fa, &fa[4], &c__4, &c__2);
    stfg8_(sf, &curret, &memc[title - 1], st0070, st0071);
    goto L1681;
L1720:
    sfs = memi[curret + 90];
    sprinf_(&memc[title - 1], &c__1023, st0072);
    pargr_(&memr[curret + 48]);
    pargr_(&memr[curret + 49]);
    r__2 = memr[sfs + 2] / memr[*sf + 21];
    r__1 = r_lg10(&r__2) * -2.5f;
    pargr_(&r__1);
    gseti_(&gp, &c__3, &c__9);
    gsview_(&gp, &c_b232, &c_b233, &c_b251, &c_b235);
    stfg4_(sf, &curret, &memc[title - 1]);
    stftie_(sf, &curret, &c__0, &c__0, &memc[title - 1], &c__1023);
    gseti_(&gp, &c__3, &c__7);
    gsview_(&gp, &c_b232, &c_b233, &c_b234, &c_b261);
    gfill_(&gp, fa, &fa[4], &c__4, &c__2);
    stfg7_(sf, &curret, &memc[title - 1], st0073, st0074);
    goto L1681;
L1730:
    gseti_(&gp, &c__3, &c__7);
    gsview_(&gp, &c_b232, &c_b363, &c_b251, &c_b235);
    stfg6_(sf, &curret, st0075, st0076, st0077);
    gseti_(&gp, &c__3, &c__8);
    gsview_(&gp, &c_b232, &c_b363, &c_b234, &c_b261);
    gfill_(&gp, fa, &fa[4], &c__4, &c__2);
    stfg7_(sf, &curret, st0078, st0079, st0080);
    gseti_(&gp, &c__3, &c__11);
    gsview_(&gp, &c_b376, &c_b233, &c_b251, &c_b235);
    gfill_(&gp, fa, &fa[4], &c__4, &c__2);
    stfg8_(sf, &curret, st0081, st0082, st0083);
    stftie_(sf, &curret, &c__0, &c__0, &memc[title - 1], &c__1023);
    gseti_(&gp, &c__3, &c__0);
    gsetr_(&gp, &c__15, &c_b388);
    gline_(&gp, &c_b389, &c_b389, &c_b389, &c_b389);
    gtext_(&gp, &c_b393, &c_b394, &memc[title - 1], st0084);
    goto L1681;
L1680:
    if (sw0018 == 97) {
	goto L1690;
    }
    if (sw0018 == 98) {
	goto L1690;
    }
    if (sw0018 == 101) {
	goto L1700;
    }
    if (sw0018 == 102) {
	goto L1690;
    }
    if (sw0018 == 103) {
	goto L1710;
    }
    if (sw0018 == 109) {
	goto L1690;
    }
    if (sw0018 == 112) {
	goto L1720;
    }
    if (sw0018 == 116) {
	goto L1690;
    }
    if (sw0018 == 122) {
	goto L1730;
    }
L1681:
    goto L1671;
L1670:
    sw0019 = pkey;
    goto L1740;
L1750:
    gseti_(&gp, &c__3, &c__7);
    gsview_(&gp, &c_b232, &c_b363, &c_b251, &c_b235);
    stfg6_(sf, &curret, st0085, st0086, st0087);
    gseti_(&gp, &c__3, &c__8);
    gsview_(&gp, &c_b232, &c_b363, &c_b234, &c_b261);
    gfill_(&gp, fa, &fa[4], &c__4, &c__2);
    stfg7_(sf, &curret, st0088, st0089, st0090);
    gseti_(&gp, &c__3, &c__11);
    gsview_(&gp, &c_b376, &c_b233, &c_b251, &c_b235);
    gfill_(&gp, fa, &fa[4], &c__4, &c__2);
    stfg8_(sf, &curret, st0091, st0092, st0093);
    stftie_(sf, &curret, &c__0, &c__0, &memc[title - 1], &c__1023);
    gseti_(&gp, &c__3, &c__0);
    gsetr_(&gp, &c__15, &c_b388);
    gline_(&gp, &c_b389, &c_b389, &c_b389, &c_b389);
    gtext_(&gp, &c_b393, &c_b394, &memc[title - 1], st0094);
    goto L1741;
L1740:
    if (sw0019 == 97) {
	goto L1750;
    }
    if (sw0019 == 98) {
	goto L1750;
    }
    if (sw0019 == 101) {
	goto L1750;
    }
    if (sw0019 == 102) {
	goto L1750;
    }
    if (sw0019 == 109) {
	goto L1750;
    }
    if (sw0019 == 112) {
	goto L1750;
    }
    if (sw0019 == 116) {
	goto L1750;
    }
    if (sw0019 == 122) {
	goto L1750;
    }
L1741:
L1671:
L1581:
L1471:
    stftie_(sf, &c__0, &c__0, &c__0, &memc[title - 1], &c__1023);
    gseti_(&gp, &c__3, &c__0);
    gsetr_(&gp, &c__15, &c_b388);
    gline_(&gp, &c_b389, &c_b389, &c_b389, &c_b389);
    gtext_(&gp, &c_b393, &c_b720, &memc[sysidr - 1], st0095);
    gtext_(&gp, &c_b393, &c_b722, &memc[title - 1], st0096);
    if (! (memi[*sf + 27] == 1)) {
	goto L1760;
    }
    goto L132;
L1760:
L131:
    if (! (clgcur_(st0097, &wx, &wy, &wcs, &key, &memc[cmd - 1], &c__1023) == 
	    -2)) {
	goto L130;
    }
L132:
    gclose_(&gp);
    sfree_(&sp);
/* L100: */
    zzepro_();
    return 0;
} /* stfgrh_ */

#undef memx
#undef mems
#undef memr
#undef meml
#undef memi
#undef memc
#undef memb


/* Subroutine */ int stfcon_(integer *sf, shortint *cmd, integer *redraw)
{
    /* Initialized data */

    static shortint st0001[64] = { 124,115,104,111,119,124,108,101,118,101,
	    108,124,115,105,122,101,124,115,99,97,108,101,124,114,97,100,105,
	    117,115,124,120,99,101,110,116,101,114,124,121,99,101,110,116,101,
	    114,9,9,9,124,111,118,101,114,112,108,111,116,124,98,101,116,97,
	    124,0 };
    static shortint st0002[9] = { 116,109,112,36,105,114,97,102,0 };
    static shortint st0003[10] = { 115,116,97,114,102,111,99,117,115,0 };
    static shortint st0004[10] = { 108,101,118,101,108,32,37,103,10,0 };
    static shortint st0005[26] = { 124,82,97,100,105,117,115,124,70,87,72,77,
	    124,71,70,87,72,77,124,77,70,87,72,77,124,0 };
    static shortint st0006[19] = { 73,110,118,97,108,105,100,32,115,105,122,
	    101,32,116,121,112,101,10,0 };
    static shortint st0007[9] = { 115,105,122,101,32,37,115,10,0 };
    static shortint st0008[10] = { 115,99,97,108,101,32,37,103,10,0 };
    static shortint st0009[11] = { 114,97,100,105,117,115,32,37,103,10,0 };
    static shortint st0010[12] = { 120,99,101,110,116,101,114,32,37,103,10,0 }
	    ;
    static shortint st0011[12] = { 121,99,101,110,116,101,114,32,37,103,10,0 }
	    ;
    static shortint st0012[13] = { 111,118,101,114,112,108,111,116,32,37,98,
	    10,0 };
    static shortint st0013[9] = { 98,101,116,97,32,37,103,10,0 };
    static shortint st0014[35] = { 85,110,114,101,99,111,103,110,105,122,101,
	    100,32,111,114,32,97,109,98,105,103,117,111,117,115,32,99,111,109,
	    109,97,110,100,7,0 };

    /* System generated locals */
    integer i__1;
    real r__1, r__2;

    /* Local variables */
    static integer i__, j, sp, sfd, str;
#define memb ((logical *)&mem_1)
#define memc ((shortint *)&mem_1)
    static integer ncmd;
    static logical bval;
#define memi ((integer *)&mem_1)
#define meml ((integer *)&mem_1)
    static integer sw0001, sw0002;
    extern integer btoi_(logical *);
    static integer sw0003, sw0004;
#define memr ((real *)&mem_1)
#define mems ((shortint *)&mem_1)
    static real rval;
#define memx ((complex *)&mem_1)
    extern /* Subroutine */ int gargb_(logical *);
    extern integer nscan_(void);
    extern /* Subroutine */ int gargr_(real *), pargi_(integer *), sfree_(
	    integer *), sscan_(shortint *), pargr_(real *), smark_(integer *);
    extern real stfr2i_(real *);
    extern /* Subroutine */ int gpagee_(integer *, shortint *, shortint *), 
	    xfdele_(shortint *), gargwd_(shortint *, integer *), salloc_(
	    integer *, integer *, integer *), xfcloe_(integer *), erract_(
	    integer *), eprinf_(shortint *);
    extern integer strdic_(shortint *, shortint *, integer *, shortint *);
    extern /* Subroutine */ int stflog_(integer *, integer *);
    extern integer xfopen_(shortint *, integer *, integer *);
    extern /* Subroutine */ int stffis_(integer *), pargsr_(shortint *), 
	    stfras_(integer *, integer *, real *, real *), xprinf_(shortint *)
	    , stfnom_(integer *, integer *, real *, real *), xmktep_(shortint 
	    *, shortint *, integer *), xerpsh_(void), stffws_(integer *, 
	    integer *);
    extern logical xerpop_(void);
    extern /* Subroutine */ int stfwis_(integer *, integer *), zzepro_(void), 
	    xstrcy_(shortint *, shortint *, integer *);

    /* Parameter adjustments */
    --cmd;

    /* Function Body */
    smark_(&sp);
    salloc_(&str, &c__255, &c__2);
    sscan_(&cmd[1]);
    gargwd_(&memc[str - 1], &c__255);
    ncmd = strdic_(&memc[str - 1], &memc[str - 1], &c__255, st0001);
    sw0001 = ncmd;
    goto L110;
L120:
    gargwd_(&memc[str - 1], &c__255);
    xerpsh_();
    if (! (nscan_() == 1)) {
	goto L140;
    }
    xmktep_(st0002, &memc[str - 1], &c__255);
    i__ = xfopen_(&memc[str - 1], &c__4, &c__11);
    if (xercom_1.xerflg) {
	goto L132;
    }
    stflog_(sf, &i__);
    if (xercom_1.xerflg) {
	goto L132;
    }
    xfcloe_(&i__);
    gpagee_(&memi[*sf + 18], &memc[str - 1], st0003);
    xfdele_(&memc[str - 1]);
    if (xercom_1.xerflg) {
	goto L132;
    }
    goto L141;
L140:
    i__ = xfopen_(&memc[str - 1], &c__4, &c__11);
    if (xercom_1.xerflg) {
	goto L132;
    }
    stflog_(sf, &i__);
    if (xercom_1.xerflg) {
	goto L132;
    }
    xfcloe_(&i__);
L141:
L132:
    if (! xerpop_()) {
	goto L130;
    }
    erract_(&c__3);
    if (xercom_1.xerflg) {
	goto L100;
    }
L130:
    *redraw = 0;
    goto L111;
L150:
    gargr_(&rval);
    if (! (nscan_() == 2)) {
	goto L160;
    }
    if (! (rval > 1.f)) {
	goto L170;
    }
    rval /= 100.f;
L170:
/* Computing MAX */
    r__1 = .05f, r__2 = min(.95f,rval);
    memr[*sf + 7] = max(r__1,r__2);
    i__1 = memi[*sf + 27];
    for (i__ = 1; i__ <= i__1; ++i__) {
	sfd = memi[memi[*sf + 28] + i__ - 2];
	stfras_(sf, &sfd, &memr[*sf + 7], &memr[sfd + 55]);
	if (xercom_1.xerflg) {
	    goto L100;
	}
/* L180: */
    }
/* L181: */
    if (! (memi[*sf + 4] == 1)) {
	goto L190;
    }
    stffis_(sf);
    if (xercom_1.xerflg) {
	goto L100;
    }
L190:
    *redraw = 1;
    goto L161;
L160:
    xprinf_(st0004);
    pargr_(&memr[*sf + 7]);
    *redraw = 0;
L161:
    goto L111;
L200:
    gargwd_(&memc[str - 1], &c__255);
    if (! (nscan_() == 2)) {
	goto L210;
    }
    ncmd = strdic_(&memc[str - 1], &memc[str - 1], &c__255, st0005);
    if (! (ncmd == 0)) {
	goto L220;
    }
    eprinf_(st0006);
    *redraw = 0;
    goto L221;
L220:
    xstrcy_(&memc[str - 1], &memc[*sf * 2], &c__7);
    memi[*sf + 4] = ncmd;
    i__1 = memi[*sf + 27];
    for (i__ = 1; i__ <= i__1; ++i__) {
	sfd = memi[memi[*sf + 28] + i__ - 2];
	sw0002 = memi[*sf + 4];
	goto L240;
L250:
	memr[sfd + 51] = memr[sfd + 55];
	goto L241;
L260:
	memr[sfd + 51] = memr[sfd + 56];
	goto L241;
L270:
	memr[sfd + 51] = memr[sfd + 57];
	goto L241;
L280:
	memr[sfd + 51] = memr[sfd + 58];
	goto L241;
L240:
	if (sw0002 < 1 || sw0002 > 4) {
	    goto L241;
	}
	switch (sw0002) {
	    case 1:  goto L250;
	    case 2:  goto L260;
	    case 3:  goto L270;
	    case 4:  goto L280;
	}
L241:
	stffws_(sf, &sfd);
/* L230: */
    }
/* L231: */
    stffis_(sf);
    if (xercom_1.xerflg) {
	goto L100;
    }
    *redraw = 1;
L221:
    goto L211;
L210:
    xprinf_(st0007);
    pargsr_(&memc[*sf * 2]);
    *redraw = 0;
L211:
    goto L111;
L290:
    gargr_(&rval);
    if (! (nscan_() == 2)) {
	goto L300;
    }
    rval /= memr[*sf + 6];
    memr[*sf + 6] *= rval;
    i__1 = memi[*sf + 27];
    for (i__ = 1; i__ <= i__1; ++i__) {
	sfd = memi[memi[*sf + 28] + i__ - 2];
	sw0003 = memi[*sf + 4];
	goto L320;
L330:
	memr[sfd + 55] *= rval;
	memr[sfd + 51] = memr[sfd + 55];
	goto L321;
L340:
	memr[sfd + 56] *= rval;
	memr[sfd + 51] = memr[sfd + 56];
	goto L321;
L350:
	memr[sfd + 85] *= rval;
	memr[sfd + 57] *= rval;
	memr[sfd + 51] = memr[sfd + 57];
	goto L321;
L360:
	memr[sfd + 86] *= rval;
	memr[sfd + 58] *= rval;
	memr[sfd + 51] = memr[sfd + 58];
	goto L321;
L320:
	if (sw0003 < 1 || sw0003 > 4) {
	    goto L321;
	}
	switch (sw0003) {
	    case 1:  goto L330;
	    case 2:  goto L340;
	    case 3:  goto L350;
	    case 4:  goto L360;
	}
L321:
	for (j = 1; j <= 19; ++j) {
	    memr[sfd + j + 62] *= rval;
/* L370: */
	}
/* L371: */
/* L310: */
    }
/* L311: */
    i__1 = memi[*sf + 30];
    for (i__ = 1; i__ <= i__1; ++i__) {
	sfd = memi[memi[*sf + 31] + i__ - 2];
	memr[sfd + 1] *= rval;
/* L380: */
    }
/* L381: */
    i__1 = memi[*sf + 33];
    for (i__ = 1; i__ <= i__1; ++i__) {
	sfd = memi[memi[*sf + 34] + i__ - 2];
	memr[sfd] *= rval;
/* L390: */
    }
/* L391: */
    memr[*sf + 20] *= rval;
    *redraw = 1;
    goto L301;
L300:
    xprinf_(st0008);
    pargr_(&memr[*sf + 6]);
    *redraw = 0;
L301:
    goto L111;
L400:
    gargr_(&rval);
    if (! (nscan_() == 2)) {
	goto L410;
    }
    j = stfr2i_(&rval) + 1;
    memr[*sf + 8] = rval;
    i__1 = memi[*sf + 27];
    for (i__ = 1; i__ <= i__1; ++i__) {
	sfd = memi[memi[*sf + 28] + i__ - 2];
	if (! (j > memi[sfd + 42])) {
	    goto L430;
	}
	goto L420;
L430:
	memi[sfd + 41] = j;
	memr[*sf + 40] = memr[*sf + 8];
	stfnom_(sf, &sfd, &c_b57, &c_b57);
	if (xercom_1.xerflg) {
	    goto L100;
	}
	stfwis_(sf, &sfd);
	stffws_(sf, &sfd);
L420:
	;
    }
/* L421: */
    stffis_(sf);
    if (xercom_1.xerflg) {
	goto L100;
    }
    *redraw = 1;
    goto L411;
L410:
    xprinf_(st0009);
    pargr_(&memr[*sf + 8]);
    *redraw = 0;
L411:
    goto L111;
L440:
    gargr_(&rval);
    if (! (nscan_() == 2)) {
	goto L450;
    }
    if (! (rval == 1.6e38f)) {
	goto L460;
    }
    memr[*sf + 16] = (memi[*sf + 14] + 1) / 2.f;
    goto L461;
L460:
    memr[*sf + 16] = rval;
L461:
    *redraw = 0;
    goto L451;
L450:
    xprinf_(st0010);
    pargr_(&memr[*sf + 16]);
    *redraw = 0;
L451:
    goto L111;
L470:
    gargr_(&rval);
    if (! (nscan_() == 2)) {
	goto L480;
    }
    if (! (rval == 1.6e38f)) {
	goto L490;
    }
    memr[*sf + 17] = (memi[*sf + 15] + 1) / 2.f;
    goto L491;
L490:
    memr[*sf + 17] = rval;
L491:
    *redraw = 0;
    goto L481;
L480:
    xprinf_(st0011);
    pargr_(&memr[*sf + 17]);
    *redraw = 0;
L481:
    goto L111;
L500:
    gargb_(&bval);
    if (! (nscan_() == 2)) {
	goto L510;
    }
    memi[*sf + 13] = btoi_(&bval);
    *redraw = 1;
    goto L511;
L510:
    xprinf_(st0012);
    pargi_(&memi[*sf + 13]);
    *redraw = 0;
L511:
    goto L111;
L520:
    gargr_(&rval);
    if (! (nscan_() == 2)) {
	goto L530;
    }
    memr[*sf + 5] = rval;
    i__1 = memi[*sf + 27];
    for (i__ = 1; i__ <= i__1; ++i__) {
	sfd = memi[memi[*sf + 28] + i__ - 2];
	stfwis_(sf, &sfd);
	sw0004 = memi[*sf + 4];
	goto L550;
L560:
	memr[sfd + 51] = memr[sfd + 55];
	goto L551;
L570:
	memr[sfd + 51] = memr[sfd + 56];
	goto L551;
L580:
	memr[sfd + 51] = memr[sfd + 57];
	goto L551;
L590:
	memr[sfd + 51] = memr[sfd + 58];
	goto L551;
L550:
	if (sw0004 < 1 || sw0004 > 4) {
	    goto L551;
	}
	switch (sw0004) {
	    case 1:  goto L560;
	    case 2:  goto L570;
	    case 3:  goto L580;
	    case 4:  goto L590;
	}
L551:
	stffws_(sf, &sfd);
/* L540: */
    }
/* L541: */
    stffis_(sf);
    if (xercom_1.xerflg) {
	goto L100;
    }
    *redraw = 1;
    goto L531;
L530:
    xprinf_(st0013);
    pargr_(&memr[*sf + 5]);
    *redraw = 0;
L531:
    goto L111;
L600:
    xprinf_(st0014);
    *redraw = 0;
    goto L111;
L110:
    if (sw0001 < 1 || sw0001 > 9) {
	goto L600;
    }
    switch (sw0001) {
	case 1:  goto L120;
	case 2:  goto L150;
	case 3:  goto L200;
	case 4:  goto L290;
	case 5:  goto L400;
	case 6:  goto L440;
	case 7:  goto L470;
	case 8:  goto L500;
	case 9:  goto L520;
    }
L111:
    sfree_(&sp);
L100:
    zzepro_();
    return 0;
} /* stfcon_ */

#undef memx
#undef mems
#undef memr
#undef meml
#undef memi
#undef memc
#undef memb


/* Subroutine */ int stfg1_(integer *sf, integer *curret, integer *xkey, 
	integer *ykey, shortint *title, shortint *xlabel, shortint *ylabel)
{
    /* System generated locals */
    integer i__1, i__2;
    real r__1, r__2;

    /* Builtin functions */
    double r_lg10(real *), sqrt(doublereal);

    /* Local variables */
    static integer i__, j;
    static real x, y, x1, x2, y1, y2;
    static logical hl;
    static integer gp;
    static real dx, dy;
    static integer sfd, sff;
#define memb ((logical *)&mem_1)
#define memc ((shortint *)&mem_1)
#define memi ((integer *)&mem_1)
#define meml ((integer *)&mem_1)
    static integer sw0001, sw0002, sw0003, sw0004, sw0005;
#define memr ((real *)&mem_1)
#define mems ((shortint *)&mem_1)
#define memx ((complex *)&mem_1)
    extern /* Subroutine */ int gline_(integer *, real *, real *, real *, 
	    real *), gmark_(integer *, real *, real *, integer *, real *, 
	    real *), gseti_(integer *, integer *, integer *), glabax_(integer 
	    *, shortint *, shortint *, shortint *), gswind_(integer *, real *,
	     real *, real *, real *), zzepro_(void);

    /* Parameter adjustments */
    --ylabel;
    --xlabel;
    --title;

    /* Function Body */
    x1 = 9.9e36f;
    x2 = -9.9e36f;
    sw0001 = *ykey;
    goto L110;
L120:
    y1 = memr[*sf + 20];
    y2 = memr[*sf + 20] * 1.5f;
    goto L111;
L130:
    y1 = 0.f;
    y2 = 1.f;
    goto L111;
L110:
    if (sw0001 == 101) {
	goto L130;
    }
    if (sw0001 == 114) {
	goto L120;
    }
L111:
    i__1 = memi[*sf + 33];
    for (j = 1; j <= i__1; ++j) {
	sff = memi[memi[*sf + 34] + j - 2];
	if (! (*xkey != 102 && sff != memi[*curret + 91])) {
	    goto L150;
	}
	goto L140;
L150:
	i__2 = memi[sff + 3];
	for (i__ = 1; i__ <= i__2; ++i__) {
	    sfd = memi[sff + i__ + 3];
	    if (! (memi[sfd + 88] == 0)) {
		goto L170;
	    }
	    sw0002 = *xkey;
	    goto L180;
L190:
	    x = memr[sfd + 50];
	    goto L181;
L200:
	    r__1 = memr[memi[sfd + 90] + 2] / memr[*sf + 21];
	    x = r_lg10(&r__1) * -2.5f;
	    goto L181;
L210:
/* Computing 2nd power */
	    r__1 = memr[sfd + 48] - memr[*sf + 16];
/* Computing 2nd power */
	    r__2 = memr[sfd + 49] - memr[*sf + 17];
	    x = sqrt(r__1 * r__1 + r__2 * r__2);
	    goto L181;
L180:
	    if (sw0002 == 102) {
		goto L190;
	    }
	    if (sw0002 == 109) {
		goto L200;
	    }
	    if (sw0002 == 116) {
		goto L210;
	    }
L181:
	    sw0003 = *ykey;
	    goto L220;
L230:
	    y = memr[sfd + 51];
	    goto L221;
L240:
	    y = memr[sfd + 53];
	    goto L221;
L220:
	    if (sw0003 == 101) {
		goto L240;
	    }
	    if (sw0003 == 114) {
		goto L230;
	    }
L221:
	    x1 = min(x1,x);
	    x2 = max(x2,x);
	    y1 = min(y1,y);
	    y2 = max(y2,y);
L170:
/* L160: */
	    ;
	}
/* L161: */
L140:
	;
    }
/* L141: */
    dx = x2 - x1;
    dy = y2 - y1;
    x1 -= dx * .05f;
    x2 += dx * .05f;
    y1 -= dy * .05f;
    y2 += dy * .05f;
    gp = memi[*sf + 18];
    gswind_(&gp, &x1, &x2, &y1, &y2);
    glabax_(&gp, &title[1], &xlabel[1], &ylabel[1]);
    i__1 = memi[*sf + 33];
    for (j = 1; j <= i__1; ++j) {
	sff = memi[memi[*sf + 34] + j - 2];
	if (! (*xkey != 102 && sff != memi[*curret + 91])) {
	    goto L260;
	}
	goto L250;
L260:
	i__2 = memi[sff + 3];
	for (i__ = 1; i__ <= i__2; ++i__) {
	    sfd = memi[sff + i__ + 3];
	    if (! (memi[sfd + 88] == 0)) {
		goto L280;
	    }
	    hl = FALSE_;
	    sw0004 = *xkey;
	    goto L290;
L300:
	    x = memr[sfd + 50];
	    goto L291;
L310:
	    r__1 = memr[memi[sfd + 90] + 2] / memr[*sf + 21];
	    x = r_lg10(&r__1) * -2.5f;
	    goto L291;
L320:
/* Computing 2nd power */
	    r__1 = memr[sfd + 48] - memr[*sf + 16];
/* Computing 2nd power */
	    r__2 = memr[sfd + 49] - memr[*sf + 17];
	    x = sqrt(r__1 * r__1 + r__2 * r__2);
	    goto L291;
L290:
	    if (sw0004 == 102) {
		goto L300;
	    }
	    if (sw0004 == 109) {
		goto L310;
	    }
	    if (sw0004 == 116) {
		goto L320;
	    }
L291:
	    sw0005 = *ykey;
	    goto L330;
L340:
	    y = memr[sfd + 51];
	    goto L331;
L350:
	    y = memr[sfd + 53];
	    goto L331;
L330:
	    if (sw0005 == 101) {
		goto L350;
	    }
	    if (sw0005 == 114) {
		goto L340;
	    }
L331:
	    if (! hl) {
		goto L360;
	    }
	    gseti_(&gp, &c__16, &c__2);
	    if (! (sfd == *curret)) {
		goto L370;
	    }
	    gmark_(&gp, &x, &y, &c__2, &c_b857, &c_b857);
L370:
	    gmark_(&gp, &x, &y, &c__4, &c_b857, &c_b857);
	    gseti_(&gp, &c__16, &c__1);
	    goto L361;
L360:
	    gmark_(&gp, &x, &y, &c__8, &c_b388, &c_b388);
L361:
L280:
/* L270: */
	    ;
	}
/* L271: */
L250:
	;
    }
/* L251: */
    gseti_(&gp, &c__14, &c__2);
    if (! (*xkey == 102)) {
	goto L380;
    }
    gline_(&gp, &memr[*sf + 19], &y1, &memr[*sf + 19], &y2);
L380:
    if (! (*ykey == 114)) {
	goto L390;
    }
    gline_(&gp, &x1, &memr[*sf + 20], &x2, &memr[*sf + 20]);
L390:
    gseti_(&gp, &c__14, &c__1);
/* L100: */
    zzepro_();
    return 0;
} /* stfg1_ */

#undef memx
#undef mems
#undef memr
#undef meml
#undef memi
#undef memc
#undef memb


/* Subroutine */ int stfg2_(integer *sf, integer *curret, shortint *title)
{
    /* Initialized data */

    static shortint st0001[1] = { 0 };
    static shortint st0002[1] = { 0 };
    static shortint st0003[1] = { 0 };
    static shortint st0004[5] = { 37,46,51,103,0 };
    static shortint st0005[8] = { 104,61,114,59,118,61,98,0 };
    static shortint st0006[5] = { 37,46,52,103,0 };
    static shortint st0007[8] = { 104,61,108,59,118,61,98,0 };
    static shortint st0008[1] = { 0 };
    static shortint st0009[1] = { 0 };

    /* System generated locals */
    integer i__1;
    real r__1, r__2, r__3, r__4;

    /* Builtin functions */
    double sqrt(doublereal);
    integer i_nint(real *);

    /* Local variables */
    static integer i__, j;
    static real r__, z__, r1, r2, x1, x2, y1, y2, z1, fa[10], dr;
    static integer gp, np, ix, iy, sp, nx, ny;
    static real vx, vy;
    static integer np1, sfd, asi, sfs;
    static real dvx, dvy;
    static integer str;
#define memb ((logical *)&mem_1)
#define memc ((shortint *)&mem_1)
#define memi ((integer *)&mem_1)
#define meml ((integer *)&mem_1)
#define memr ((real *)&mem_1)
#define mems ((shortint *)&mem_1)
#define memx ((complex *)&mem_1)
    extern /* Subroutine */ int gfill_(integer *, real *, real *, integer *, 
	    integer *), gline_(integer *, real *, real *, real *, real *), 
	    sfree_(integer *), gseti_(integer *, integer *, integer *), 
	    pargr_(real *), smark_(integer *), gsetr_(integer *, integer *, 
	    real *), gtext_(integer *, real *, real *, shortint *, shortint *)
	    ;
    extern real stfi2r_(real *), stfr2i_(real *);
    extern /* Subroutine */ int glabax_(integer *, shortint *, shortint *, 
	    shortint *), gadraw_(integer *, real *, real *), salloc_(integer *
	    , integer *, integer *), gpline_(integer *, real *, real *, 
	    integer *), gamove_(integer *, real *, real *);
    extern real asievl_(integer *, real *);
    extern /* Subroutine */ int ggview_(integer *, real *, real *, real *, 
	    real *), gswind_(integer *, real *, real *, real *, real *), 
	    sprinf_(shortint *, integer *, shortint *), gsview_(integer *, 
	    real *, real *, real *, real *), zzepro_(void);

    /* Parameter adjustments */
    --title;

    /* Function Body */
    smark_(&sp);
    salloc_(&str, &c__1023, &c__2);
    gp = memi[*sf + 18];
    sfs = memi[*curret + 90];
    np = memi[*curret + 41];
    i__ = memi[sfs + 3];
    if (! (i__ < 4)) {
	goto L110;
    }
    nx = i__;
    ny = 1;
    goto L111;
L110:
    r__1 = sqrt((real) i__);
    nx = i_nint(&r__1);
    if (! ((i__ - 1) % (nx + 1) >= (i__ - 1) % nx)) {
	goto L120;
    }
    ++nx;
L120:
    ny = (i__ - 1) / nx + 1;
L111:
    ggview_(&gp, &vx, &dvx, &vy, &dvy);
    dvx = (dvx - vx) / nx;
    dvy = (dvy - vy) / ny;
    x1 = -.05f;
    x2 = 1.05f;
    y1 = -.15f;
    y2 = 1.05f;
    gswind_(&gp, &x1, &x2, &y1, &y2);
    fa[0] = x1;
    fa[5] = y1;
    fa[1] = x2;
    fa[6] = y1;
    fa[2] = x2;
    fa[7] = y2;
    fa[3] = x1;
    fa[8] = y2;
    fa[4] = x1;
    fa[9] = y1;
    j = 0;
    i__1 = memi[sfs + 5];
    for (i__ = 1; i__ <= i__1; ++i__) {
	sfd = memi[sfs + i__ + 5];
	if (! (memi[sfd + 88] != 0)) {
	    goto L140;
	}
	goto L130;
L140:
	np1 = memi[sfd + 41];
	ix = j % nx + 1;
	iy = j / nx + 1;
	++j;
	r__1 = vx + dvx * (ix - 1);
	r__2 = vx + dvx * ix;
	r__3 = vy + dvy * (ny - iy);
	r__4 = vy + (ny - iy + 1) * dvy;
	gsview_(&gp, &r__1, &r__2, &r__3, &r__4);
	gfill_(&gp, fa, &fa[5], &c__4, &c__2);
	gseti_(&gp, &c__309, &c__0);
	glabax_(&gp, st0001, st0002, st0003);
	if (! (sfd == *curret)) {
	    goto L150;
	}
	r__1 = vx + dvx * (ix - 1) + .005f;
	r__2 = vx + dvx * ix - .005f;
	r__3 = vy + dvy * (ny - iy) + .005f;
	r__4 = vy + (ny - iy + 1) * dvy - .005f;
	gsview_(&gp, &r__1, &r__2, &r__3, &r__4);
	gsetr_(&gp, &c__15, &c_b891);
	gseti_(&gp, &c__16, &c__2);
	gpline_(&gp, fa, &fa[5], &c__5);
	gsetr_(&gp, &c__15, &c_b896);
	gseti_(&gp, &c__16, &c__1);
	r__1 = vx + dvx * (ix - 1);
	r__2 = vx + dvx * ix;
	r__3 = vy + dvy * (ny - iy);
	r__4 = vy + (ny - iy + 1) * dvy;
	gsview_(&gp, &r__1, &r__2, &r__3, &r__4);
L150:
	asi = memi[sfd + 59];
	r__1 = (real) np;
	r2 = stfi2r_(&r__1);
	gamove_(&gp, &c_b389, &c_b389);
	z__ = 1.f;
L160:
	if (! (z__ <= (real) np1)) {
	    goto L162;
	}
	r__1 = stfi2r_(&z__) / r2;
	r__2 = asievl_(&asi, &z__);
	gadraw_(&gp, &r__1, &r__2);
/* L161: */
	z__ += .1f;
	goto L160;
L162:
	if (! (memi[*sf + 13] == 1 && sfd != memi[*sf + 38])) {
	    goto L170;
	}
	gseti_(&gp, &c__16, &c__2);
	np1 = memi[memi[*sf + 38] + 41];
	asi = memi[memi[*sf + 38] + 59];
	r1 = stfi2r_(&c_b896);
	r__1 = (real) np;
	r2 = stfi2r_(&r__1);
	dr = (r2 - r1) * .05f;
	r__ = r1;
L180:
	if (! (r__ <= r2)) {
	    goto L182;
	}
	z__ = stfr2i_(&r__);
	r__1 = r__ + dr * .7f;
	z1 = stfr2i_(&r__1);
	if (! (z__ > 1.f && z1 <= (real) np1)) {
	    goto L190;
	}
	r__1 = r__ / r2;
	r__2 = asievl_(&asi, &z__);
	r__3 = (r__ + dr * .7f) / r2;
	r__4 = asievl_(&asi, &z1);
	gline_(&gp, &r__1, &r__2, &r__3, &r__4);
L190:
/* L181: */
	r__ += dr;
	goto L180;
L182:
	gseti_(&gp, &c__16, &c__1);
L170:
	sprinf_(&memc[str - 1], &c__1023, st0004);
	pargr_(&memr[sfd + 51]);
	gtext_(&gp, &c_b233, &c_b916, &memc[str - 1], st0005);
	if (! (nx < 5 && ny < 5)) {
	    goto L200;
	}
	sprinf_(&memc[str - 1], &c__1023, st0006);
	pargr_(&memr[sfd + 50]);
	gtext_(&gp, &c_b919, &c_b916, &memc[str - 1], st0007);
L200:
L130:
	;
    }
/* L131: */
    r__1 = vx + nx * dvx;
    r__2 = vy + ny * dvy;
    gsview_(&gp, &vx, &r__1, &vy, &r__2);
    r__1 = nx + .5f;
    r__2 = ny + .5f;
    gswind_(&gp, &c_b393, &r__1, &r__2, &c_b393);
    gamove_(&gp, &c_b896, &c_b896);
    gseti_(&gp, &c__301, &c__0);
    glabax_(&gp, &title[1], st0008, st0009);
    gseti_(&gp, &c__301, &c__3);
    sfree_(&sp);
/* L100: */
    zzepro_();
    return 0;
} /* stfg2_ */

#undef memx
#undef mems
#undef memr
#undef meml
#undef memi
#undef memc
#undef memb


/* Subroutine */ int stfg3_(integer *sf, integer *curret, shortint *title)
{
    /* Initialized data */

    static shortint st0001[1] = { 0 };
    static shortint st0002[1] = { 0 };
    static shortint st0003[1] = { 0 };
    static shortint st0004[5] = { 37,46,51,103,0 };
    static shortint st0005[8] = { 104,61,114,59,118,61,98,0 };
    static shortint st0006[6] = { 37,100,32,37,100,0 };
    static shortint st0007[8] = { 104,61,108,59,118,61,98,0 };
    static shortint st0008[1] = { 0 };
    static shortint st0009[1] = { 0 };

    /* System generated locals */
    integer i__1;
    real r__1, r__2, r__3, r__4;

    /* Builtin functions */
    double sqrt(doublereal);
    integer i_nint(real *);

    /* Local variables */
    static integer i__, j;
    static real r__, z__, r1, r2, x1, x2, y1, y2, z1, fa[10], dr;
    static integer gp, np, ix, iy, sp, nx, ny;
    static real vx, vy;
    static integer np1, sfd, asi, sff;
    static real dvx, dvy;
    static integer str;
#define memb ((logical *)&mem_1)
#define memc ((shortint *)&mem_1)
#define memi ((integer *)&mem_1)
#define meml ((integer *)&mem_1)
#define memr ((real *)&mem_1)
#define mems ((shortint *)&mem_1)
#define memx ((complex *)&mem_1)
    extern /* Subroutine */ int gfill_(integer *, real *, real *, integer *, 
	    integer *), gline_(integer *, real *, real *, real *, real *), 
	    sfree_(integer *), gseti_(integer *, integer *, integer *), 
	    pargr_(real *), smark_(integer *), gsetr_(integer *, integer *, 
	    real *), gtext_(integer *, real *, real *, shortint *, shortint *)
	    ;
    extern real stfi2r_(real *), stfr2i_(real *);
    extern /* Subroutine */ int glabax_(integer *, shortint *, shortint *, 
	    shortint *), gadraw_(integer *, real *, real *), salloc_(integer *
	    , integer *, integer *), gpline_(integer *, real *, real *, 
	    integer *), gamove_(integer *, real *, real *);
    extern real asievl_(integer *, real *);
    extern /* Subroutine */ int ggview_(integer *, real *, real *, real *, 
	    real *), gswind_(integer *, real *, real *, real *, real *), 
	    sprinf_(shortint *, integer *, shortint *), gsview_(integer *, 
	    real *, real *, real *, real *), zzepro_(void);

    /* Parameter adjustments */
    --title;

    /* Function Body */
    smark_(&sp);
    salloc_(&str, &c__1023, &c__2);
    gp = memi[*sf + 18];
    sff = memi[*curret + 91];
    np = memi[*curret + 41];
    i__ = memi[sff + 1];
    if (! (i__ < 4)) {
	goto L110;
    }
    nx = i__;
    ny = 1;
    goto L111;
L110:
    r__1 = sqrt((real) i__);
    nx = i_nint(&r__1);
    if (! ((i__ - 1) % (nx + 1) >= (i__ - 1) % nx)) {
	goto L120;
    }
    ++nx;
L120:
    ny = (i__ - 1) / nx + 1;
L111:
    ggview_(&gp, &vx, &dvx, &vy, &dvy);
    dvx = (dvx - vx) / nx;
    dvy = (dvy - vy) / ny;
    x1 = -.05f;
    x2 = 1.05f;
    y1 = -.2f;
    y2 = 1.05f;
    gswind_(&gp, &x1, &x2, &y1, &y2);
    fa[0] = x1;
    fa[5] = y1;
    fa[1] = x2;
    fa[6] = y1;
    fa[2] = x2;
    fa[7] = y2;
    fa[3] = x1;
    fa[8] = y2;
    fa[4] = x1;
    fa[9] = y1;
    j = 0;
    i__1 = memi[sff + 3];
    for (i__ = 1; i__ <= i__1; ++i__) {
	sfd = memi[sff + i__ + 3];
	if (! (memi[sfd + 88] != 0)) {
	    goto L140;
	}
	goto L130;
L140:
	np1 = memi[sfd + 41];
	ix = j % nx + 1;
	iy = j / nx + 1;
	++j;
	r__1 = vx + dvx * (ix - 1);
	r__2 = vx + dvx * ix;
	r__3 = vy + dvy * (ny - iy);
	r__4 = vy + (ny - iy + 1) * dvy;
	gsview_(&gp, &r__1, &r__2, &r__3, &r__4);
	gfill_(&gp, fa, &fa[5], &c__4, &c__2);
	gseti_(&gp, &c__309, &c__0);
	glabax_(&gp, st0001, st0002, st0003);
	if (! (sfd == *curret)) {
	    goto L150;
	}
	r__1 = vx + dvx * (ix - 1) + .005f;
	r__2 = vx + dvx * ix - .005f;
	r__3 = vy + dvy * (ny - iy) + .005f;
	r__4 = vy + (ny - iy + 1) * dvy - .005f;
	gsview_(&gp, &r__1, &r__2, &r__3, &r__4);
	gsetr_(&gp, &c__15, &c_b891);
	gseti_(&gp, &c__16, &c__2);
	gpline_(&gp, fa, &fa[5], &c__5);
	gsetr_(&gp, &c__15, &c_b896);
	gseti_(&gp, &c__16, &c__1);
	r__1 = vx + dvx * (ix - 1);
	r__2 = vx + dvx * ix;
	r__3 = vy + dvy * (ny - iy);
	r__4 = vy + (ny - iy + 1) * dvy;
	gsview_(&gp, &r__1, &r__2, &r__3, &r__4);
L150:
	asi = memi[sfd + 59];
	r__1 = (real) np;
	r2 = stfi2r_(&r__1);
	gamove_(&gp, &c_b389, &c_b389);
	z__ = 1.f;
L160:
	if (! (z__ <= (real) np1)) {
	    goto L162;
	}
	r__1 = stfi2r_(&z__) / r2;
	r__2 = asievl_(&asi, &z__);
	gadraw_(&gp, &r__1, &r__2);
/* L161: */
	z__ += .1f;
	goto L160;
L162:
	if (! (memi[*sf + 13] == 1 && sfd != memi[*sf + 38])) {
	    goto L170;
	}
	gseti_(&gp, &c__16, &c__2);
	np1 = memi[memi[*sf + 38] + 41];
	asi = memi[memi[*sf + 38] + 59];
	r1 = stfi2r_(&c_b896);
	r__1 = (real) np;
	r2 = stfi2r_(&r__1);
	dr = (r2 - r1) * .05f;
	r__ = r1;
L180:
	if (! (r__ <= r2)) {
	    goto L182;
	}
	z__ = stfr2i_(&r__);
	r__1 = r__ + dr * .7f;
	z1 = stfr2i_(&r__1);
	if (! (z__ > 1.f && z1 <= (real) np1)) {
	    goto L190;
	}
	r__1 = r__ / r2;
	r__2 = asievl_(&asi, &z__);
	r__3 = (r__ + dr * .7f) / r2;
	r__4 = asievl_(&asi, &z1);
	gline_(&gp, &r__1, &r__2, &r__3, &r__4);
L190:
/* L181: */
	r__ += dr;
	goto L180;
L182:
	gseti_(&gp, &c__16, &c__1);
L170:
	sprinf_(&memc[str - 1], &c__1023, st0004);
	pargr_(&memr[sfd + 51]);
	gtext_(&gp, &c_b233, &c_b916, &memc[str - 1], st0005);
	if (! (nx < 5 && ny < 5)) {
	    goto L200;
	}
	sprinf_(&memc[str - 1], &c__1023, st0006);
	pargr_(&memr[sfd + 48]);
	pargr_(&memr[sfd + 49]);
	gtext_(&gp, &c_b919, &c_b916, &memc[str - 1], st0007);
L200:
L130:
	;
    }
/* L131: */
    r__1 = vx + nx * dvx;
    r__2 = vy + ny * dvy;
    gsview_(&gp, &vx, &r__1, &vy, &r__2);
    r__1 = nx + .5f;
    r__2 = ny + .5f;
    gswind_(&gp, &c_b393, &r__1, &r__2, &c_b393);
    gamove_(&gp, &c_b896, &c_b896);
    gseti_(&gp, &c__301, &c__0);
    glabax_(&gp, &title[1], st0008, st0009);
    gseti_(&gp, &c__301, &c__3);
    sfree_(&sp);
/* L100: */
    zzepro_();
    return 0;
} /* stfg3_ */

#undef memx
#undef mems
#undef memr
#undef meml
#undef memi
#undef memc
#undef memb


/* Subroutine */ int stfg4_(integer *sf, integer *curret, shortint *title)
{
    /* Initialized data */

    static shortint st0001[1] = { 0 };
    static shortint st0002[1] = { 0 };
    static shortint st0003[1] = { 0 };
    static shortint st0004[5] = { 37,46,51,103,0 };
    static shortint st0005[8] = { 104,61,114,59,118,61,116,0 };
    static shortint st0006[5] = { 37,46,52,103,0 };
    static shortint st0007[8] = { 104,61,108,59,118,61,116,0 };
    static shortint st0008[1] = { 0 };
    static shortint st0009[1] = { 0 };

    /* System generated locals */
    integer i__1;
    real r__1, r__2, r__3, r__4;

    /* Builtin functions */
    double sqrt(doublereal);
    integer i_nint(real *);

    /* Local variables */
    static integer i__, j;
    static real r__, z__, r1, r2, x1, x2, y1, y2, z1, fa[10], dr;
    static integer gp, np, ix, iy, sp, nx, ny;
    static real vx, vy;
    static integer np1, sfd, asi, sfs;
    static real dvx, dvy;
    static integer str;
#define memb ((logical *)&mem_1)
#define memc ((shortint *)&mem_1)
#define memi ((integer *)&mem_1)
#define meml ((integer *)&mem_1)
#define memr ((real *)&mem_1)
#define mems ((shortint *)&mem_1)
#define memx ((complex *)&mem_1)
    static real rmax;
    extern /* Subroutine */ int gfill_(integer *, real *, real *, integer *, 
	    integer *), gline_(integer *, real *, real *, real *, real *), 
	    sfree_(integer *), gseti_(integer *, integer *, integer *), 
	    pargr_(real *), smark_(integer *), gsetr_(integer *, integer *, 
	    real *), gtext_(integer *, real *, real *, shortint *, shortint *)
	    ;
    extern real stfi2r_(real *), stfr2i_(real *);
    extern /* Subroutine */ int glabax_(integer *, shortint *, shortint *, 
	    shortint *), gadraw_(integer *, real *, real *), salloc_(integer *
	    , integer *, integer *), gpline_(integer *, real *, real *, 
	    integer *), gamove_(integer *, real *, real *);
    extern real asievl_(integer *, real *);
    extern /* Subroutine */ int ggview_(integer *, real *, real *, real *, 
	    real *), gswind_(integer *, real *, real *, real *, real *), 
	    sprinf_(shortint *, integer *, shortint *), gsview_(integer *, 
	    real *, real *, real *, real *), zzepro_(void);

    /* Parameter adjustments */
    --title;

    /* Function Body */
    smark_(&sp);
    salloc_(&str, &c__1023, &c__2);
    gp = memi[*sf + 18];
    sfs = memi[*curret + 90];
    np = memi[*curret + 41];
    i__ = memi[sfs + 3];
    if (! (i__ < 4)) {
	goto L110;
    }
    nx = i__;
    ny = 1;
    goto L111;
L110:
    r__1 = sqrt((real) i__);
    nx = i_nint(&r__1);
    if (! ((i__ - 1) % (nx + 1) >= (i__ - 1) % nx)) {
	goto L120;
    }
    ++nx;
L120:
    ny = (i__ - 1) / nx + 1;
L111:
    ggview_(&gp, &vx, &dvx, &vy, &dvy);
    dvx = (dvx - vx) / nx;
    dvy = (dvy - vy) / ny;
    x1 = -.05f;
    x2 = 1.05f;
    z__ = memr[*sf + 25] - memr[*sf + 24];
    y1 = memr[*sf + 24] - z__ * .05f;
    y2 = memr[*sf + 25] + z__ * .15f;
    fa[0] = x1;
    fa[5] = y1;
    fa[1] = x2;
    fa[6] = y1;
    fa[2] = x2;
    fa[7] = y2;
    fa[3] = x1;
    fa[8] = y2;
    fa[4] = x1;
    fa[9] = y1;
    j = 0;
    i__1 = memi[sfs + 5];
    for (i__ = 1; i__ <= i__1; ++i__) {
	sfd = memi[sfs + i__ + 5];
	if (! (memi[sfd + 88] != 0)) {
	    goto L140;
	}
	goto L130;
L140:
	np1 = memi[sfd + 41];
	ix = j % nx + 1;
	iy = j / nx + 1;
	++j;
	r__1 = vx + dvx * (ix - 1);
	r__2 = vx + dvx * ix;
	r__3 = vy + dvy * (ny - iy);
	r__4 = vy + (ny - iy + 1) * dvy;
	gsview_(&gp, &r__1, &r__2, &r__3, &r__4);
	gswind_(&gp, &x1, &x2, &y1, &y2);
	gfill_(&gp, fa, &fa[5], &c__4, &c__2);
	gseti_(&gp, &c__309, &c__0);
	glabax_(&gp, st0001, st0002, st0003);
	if (! (sfd == *curret)) {
	    goto L150;
	}
	r__1 = vx + dvx * (ix - 1) + .005f;
	r__2 = vx + dvx * ix - .005f;
	r__3 = vy + dvy * (ny - iy) + .005f;
	r__4 = vy + (ny - iy + 1) * dvy - .005f;
	gsview_(&gp, &r__1, &r__2, &r__3, &r__4);
	gsetr_(&gp, &c__15, &c_b891);
	gseti_(&gp, &c__16, &c__2);
	gpline_(&gp, fa, &fa[5], &c__5);
	gsetr_(&gp, &c__15, &c_b896);
	gseti_(&gp, &c__16, &c__1);
	r__1 = vx + dvx * (ix - 1);
	r__2 = vx + dvx * ix;
	r__3 = vy + dvy * (ny - iy);
	r__4 = vy + (ny - iy + 1) * dvy;
	gsview_(&gp, &r__1, &r__2, &r__3, &r__4);
L150:
	asi = memi[sfd + 60];
	r__1 = (real) np;
	rmax = stfi2r_(&r__1);
	z__ = memr[*sf + 22];
	r__1 = stfi2r_(&z__) / rmax;
	r__2 = asievl_(&asi, &z__);
	gamove_(&gp, &r__1, &r__2);
L160:
	if (! (z__ <= memr[*sf + 23])) {
	    goto L162;
	}
	r__1 = stfi2r_(&z__) / rmax;
	r__2 = asievl_(&asi, &z__);
	gadraw_(&gp, &r__1, &r__2);
/* L161: */
	z__ += .1f;
	goto L160;
L162:
	if (! (memi[*sf + 13] == 1 && sfd != memi[*sf + 38])) {
	    goto L170;
	}
	gseti_(&gp, &c__16, &c__2);
	np1 = memi[memi[*sf + 38] + 41];
	asi = memi[memi[*sf + 38] + 60];
	r__1 = (real) np;
	rmax = stfi2r_(&r__1);
	r1 = stfi2r_(&memr[*sf + 22]);
	r2 = stfi2r_(&memr[*sf + 23]);
	dr = (rmax - stfi2r_(&c_b896)) * .05f;
	r__ = r1;
L180:
	if (! (r__ <= r2)) {
	    goto L182;
	}
	z__ = stfr2i_(&r__);
	r__1 = r__ + dr * .7f;
	z1 = stfr2i_(&r__1);
	if (! (z__ > 1.f && z1 <= (real) np1)) {
	    goto L190;
	}
	r__1 = r__ / rmax;
	r__2 = asievl_(&asi, &z__);
	r__3 = (r__ + dr * .7f) / rmax;
	r__4 = asievl_(&asi, &z1);
	gline_(&gp, &r__1, &r__2, &r__3, &r__4);
L190:
/* L181: */
	r__ += dr;
	goto L180;
L182:
	gseti_(&gp, &c__16, &c__1);
L170:
	gswind_(&gp, &c_b389, &c_b896, &c_b389, &c_b896);
	sprinf_(&memc[str - 1], &c__1023, st0004);
	pargr_(&memr[sfd + 51]);
	gtext_(&gp, &c_b233, &c_b1026, &memc[str - 1], st0005);
	if (! (nx < 5 && ny < 5)) {
	    goto L200;
	}
	sprinf_(&memc[str - 1], &c__1023, st0006);
	pargr_(&memr[sfd + 50]);
	gtext_(&gp, &c_b919, &c_b1026, &memc[str - 1], st0007);
L200:
L130:
	;
    }
/* L131: */
    r__1 = vx + nx * dvx;
    r__2 = vy + ny * dvy;
    gsview_(&gp, &vx, &r__1, &vy, &r__2);
    r__1 = nx + .5f;
    r__2 = ny + .5f;
    gswind_(&gp, &c_b393, &r__1, &r__2, &c_b393);
    gamove_(&gp, &c_b896, &c_b896);
    gseti_(&gp, &c__301, &c__0);
    glabax_(&gp, &title[1], st0008, st0009);
    gseti_(&gp, &c__301, &c__3);
    sfree_(&sp);
/* L100: */
    zzepro_();
    return 0;
} /* stfg4_ */

#undef memx
#undef mems
#undef memr
#undef meml
#undef memi
#undef memc
#undef memb


/* Subroutine */ int stfg5_(integer *sf, integer *curret, shortint *title)
{
    /* Initialized data */

    static shortint st0001[1] = { 0 };
    static shortint st0002[1] = { 0 };
    static shortint st0003[1] = { 0 };
    static shortint st0004[5] = { 37,46,51,103,0 };
    static shortint st0005[8] = { 104,61,114,59,118,61,116,0 };
    static shortint st0006[6] = { 37,100,32,37,100,0 };
    static shortint st0007[8] = { 104,61,108,59,118,61,116,0 };
    static shortint st0008[1] = { 0 };
    static shortint st0009[1] = { 0 };

    /* System generated locals */
    integer i__1;
    real r__1, r__2, r__3, r__4;

    /* Builtin functions */
    double sqrt(doublereal);
    integer i_nint(real *);

    /* Local variables */
    static integer i__, j;
    static real r__, z__, r1, r2, x1, x2, y1, y2, z1, fa[10], dr;
    static integer gp, np, ix, iy, sp, nx, ny;
    static real vx, vy;
    static integer np1, sfd, asi, sff;
    static real dvx, dvy;
    static integer str;
#define memb ((logical *)&mem_1)
#define memc ((shortint *)&mem_1)
#define memi ((integer *)&mem_1)
#define meml ((integer *)&mem_1)
#define memr ((real *)&mem_1)
#define mems ((shortint *)&mem_1)
#define memx ((complex *)&mem_1)
    static real rmax;
    extern /* Subroutine */ int gfill_(integer *, real *, real *, integer *, 
	    integer *), gline_(integer *, real *, real *, real *, real *), 
	    sfree_(integer *), gseti_(integer *, integer *, integer *), 
	    pargr_(real *), smark_(integer *), gsetr_(integer *, integer *, 
	    real *), gtext_(integer *, real *, real *, shortint *, shortint *)
	    ;
    extern real stfi2r_(real *), stfr2i_(real *);
    extern /* Subroutine */ int glabax_(integer *, shortint *, shortint *, 
	    shortint *), gadraw_(integer *, real *, real *), salloc_(integer *
	    , integer *, integer *), gpline_(integer *, real *, real *, 
	    integer *), gamove_(integer *, real *, real *);
    extern real asievl_(integer *, real *);
    extern /* Subroutine */ int ggview_(integer *, real *, real *, real *, 
	    real *), gswind_(integer *, real *, real *, real *, real *), 
	    sprinf_(shortint *, integer *, shortint *), gsview_(integer *, 
	    real *, real *, real *, real *), zzepro_(void);

    /* Parameter adjustments */
    --title;

    /* Function Body */
    smark_(&sp);
    salloc_(&str, &c__1023, &c__2);
    gp = memi[*sf + 18];
    sff = memi[*curret + 91];
    np = memi[*curret + 41];
    i__ = memi[sff + 1];
    if (! (i__ < 4)) {
	goto L110;
    }
    nx = i__;
    ny = 1;
    goto L111;
L110:
    r__1 = sqrt((real) i__);
    nx = i_nint(&r__1);
    if (! ((i__ - 1) % (nx + 1) >= (i__ - 1) % nx)) {
	goto L120;
    }
    ++nx;
L120:
    ny = (i__ - 1) / nx + 1;
L111:
    ggview_(&gp, &vx, &dvx, &vy, &dvy);
    dvx = (dvx - vx) / nx;
    dvy = (dvy - vy) / ny;
    x1 = -.05f;
    x2 = 1.05f;
    z__ = memr[*sf + 25] - memr[*sf + 24];
    y1 = memr[*sf + 24] - z__ * .05f;
    y2 = memr[*sf + 25] + z__ * .15f;
    fa[0] = x1;
    fa[5] = y1;
    fa[1] = x2;
    fa[6] = y1;
    fa[2] = x2;
    fa[7] = y2;
    fa[3] = x1;
    fa[8] = y2;
    fa[4] = x1;
    fa[9] = y1;
    j = 0;
    i__1 = memi[sff + 3];
    for (i__ = 1; i__ <= i__1; ++i__) {
	sfd = memi[sff + i__ + 3];
	if (! (memi[sfd + 88] != 0)) {
	    goto L140;
	}
	goto L130;
L140:
	np1 = memi[sfd + 41];
	ix = j % nx + 1;
	iy = j / nx + 1;
	++j;
	r__1 = vx + dvx * (ix - 1);
	r__2 = vx + dvx * ix;
	r__3 = vy + dvy * (ny - iy);
	r__4 = vy + (ny - iy + 1) * dvy;
	gsview_(&gp, &r__1, &r__2, &r__3, &r__4);
	gswind_(&gp, &x1, &x2, &y1, &y2);
	gfill_(&gp, fa, &fa[5], &c__4, &c__2);
	gseti_(&gp, &c__309, &c__0);
	glabax_(&gp, st0001, st0002, st0003);
	if (! (sfd == *curret)) {
	    goto L150;
	}
	r__1 = vx + dvx * (ix - 1) + .005f;
	r__2 = vx + dvx * ix - .005f;
	r__3 = vy + dvy * (ny - iy) + .005f;
	r__4 = vy + (ny - iy + 1) * dvy - .005f;
	gsview_(&gp, &r__1, &r__2, &r__3, &r__4);
	gsetr_(&gp, &c__15, &c_b891);
	gseti_(&gp, &c__16, &c__2);
	gpline_(&gp, fa, &fa[5], &c__5);
	gsetr_(&gp, &c__15, &c_b896);
	gseti_(&gp, &c__16, &c__1);
	r__1 = vx + dvx * (ix - 1);
	r__2 = vx + dvx * ix;
	r__3 = vy + dvy * (ny - iy);
	r__4 = vy + (ny - iy + 1) * dvy;
	gsview_(&gp, &r__1, &r__2, &r__3, &r__4);
L150:
	asi = memi[sfd + 60];
	r__1 = (real) np;
	rmax = stfi2r_(&r__1);
	z__ = memr[*sf + 22];
	r__1 = stfi2r_(&z__) / rmax;
	r__2 = asievl_(&asi, &z__);
	gamove_(&gp, &r__1, &r__2);
L160:
	if (! (z__ <= memr[*sf + 23])) {
	    goto L162;
	}
	r__1 = stfi2r_(&z__) / rmax;
	r__2 = asievl_(&asi, &z__);
	gadraw_(&gp, &r__1, &r__2);
/* L161: */
	z__ += .1f;
	goto L160;
L162:
	if (! (memi[*sf + 13] == 1 && sfd != memi[*sf + 38])) {
	    goto L170;
	}
	gseti_(&gp, &c__16, &c__2);
	np1 = memi[memi[*sf + 38] + 41];
	asi = memi[memi[*sf + 38] + 60];
	r__1 = (real) np;
	rmax = stfi2r_(&r__1);
	r1 = stfi2r_(&memr[*sf + 22]);
	r2 = stfi2r_(&memr[*sf + 23]);
	dr = (rmax - stfi2r_(&c_b896)) * .05f;
	r__ = r1;
L180:
	if (! (r__ <= r2)) {
	    goto L182;
	}
	z__ = stfr2i_(&r__);
	r__1 = r__ + dr * .7f;
	z1 = stfr2i_(&r__1);
	if (! (z__ > 1.f && z1 <= (real) np1)) {
	    goto L190;
	}
	r__1 = r__ / rmax;
	r__2 = asievl_(&asi, &z__);
	r__3 = (r__ + dr * .7f) / rmax;
	r__4 = asievl_(&asi, &z1);
	gline_(&gp, &r__1, &r__2, &r__3, &r__4);
L190:
/* L181: */
	r__ += dr;
	goto L180;
L182:
	gseti_(&gp, &c__16, &c__1);
L170:
	gswind_(&gp, &c_b389, &c_b896, &c_b389, &c_b896);
	sprinf_(&memc[str - 1], &c__1023, st0004);
	pargr_(&memr[sfd + 51]);
	gtext_(&gp, &c_b233, &c_b1026, &memc[str - 1], st0005);
	if (! (nx < 5 && ny < 5)) {
	    goto L200;
	}
	sprinf_(&memc[str - 1], &c__1023, st0006);
	pargr_(&memr[sfd + 48]);
	pargr_(&memr[sfd + 49]);
	gtext_(&gp, &c_b919, &c_b1026, &memc[str - 1], st0007);
L200:
L130:
	;
    }
/* L131: */
    r__1 = vx + nx * dvx;
    r__2 = vy + ny * dvy;
    gsview_(&gp, &vx, &r__1, &vy, &r__2);
    r__1 = nx + .5f;
    r__2 = ny + .5f;
    gswind_(&gp, &c_b393, &r__1, &r__2, &c_b393);
    gamove_(&gp, &c_b896, &c_b896);
    gseti_(&gp, &c__301, &c__0);
    glabax_(&gp, &title[1], st0008, st0009);
    gseti_(&gp, &c__301, &c__3);
    sfree_(&sp);
/* L100: */
    zzepro_();
    return 0;
} /* stfg5_ */

#undef memx
#undef mems
#undef memr
#undef meml
#undef memi
#undef memc
#undef memb


/* Subroutine */ int stfg6_(integer *sf, integer *curret, shortint *title, 
	shortint *xlabel, shortint *ylabel)
{
    /* System generated locals */
    real r__1, r__2, r__3, r__4;

    /* Local variables */
    static real r__, z__, r1, r2, x1, x2, y1, y2, z1, dr;
    static integer gp, np, np1, asi;
#define memb ((logical *)&mem_1)
#define memc ((shortint *)&mem_1)
#define memi ((integer *)&mem_1)
#define meml ((integer *)&mem_1)
    static integer sw0001;
#define memr ((real *)&mem_1)
#define mems ((shortint *)&mem_1)
#define memx ((complex *)&mem_1)
    static real flux, scale;
    extern /* Subroutine */ int gline_(integer *, real *, real *, real *, 
	    real *), gmark_(integer *, real *, real *, integer *, real *, 
	    real *);
    static real level;
    extern /* Subroutine */ int gseti_(integer *, integer *, integer *);
    extern real stfi2r_(real *), stfr2i_(real *);
    extern /* Subroutine */ int glabax_(integer *, shortint *, shortint *, 
	    shortint *), gadraw_(integer *, real *, real *), gamove_(integer *
	    , real *, real *);
    extern real asievl_(integer *, real *);
    static real profie, radius;
    extern /* Subroutine */ int gswind_(integer *, real *, real *, real *, 
	    real *), stfmol_(integer *, integer *, real *, real *, real *), 
	    zzepro_(void);

    /* Parameter adjustments */
    --ylabel;
    --xlabel;
    --title;

    /* Function Body */
    gp = memi[*sf + 18];
    level = memr[*sf + 7];
    scale = memr[*sf + 6];
    np = memi[*curret + 41];
    asi = memi[*curret + 59];
    x1 = scale * -.5f;
    r__1 = (real) np;
    x2 = (stfi2r_(&r__1) + .5f) * scale;
    y1 = -.05f;
    y2 = 1.05f;
    gswind_(&gp, &x1, &x2, &y1, &y2);
    gseti_(&gp, &c__309, &c__1);
    gseti_(&gp, &c__111, &c__6);
    gseti_(&gp, &c__112, &c__4);
    gseti_(&gp, &c__211, &c__6);
    gseti_(&gp, &c__212, &c__4);
    glabax_(&gp, &title[1], &xlabel[1], &ylabel[1]);
    if (! (memi[*curret + 88] == 0)) {
	goto L110;
    }
    gseti_(&gp, &c__16, &c__1);
    z__ = 1.f;
L120:
    if (! (z__ <= (real) np)) {
	goto L122;
    }
    r__1 = stfi2r_(&z__) * scale;
    r__2 = asievl_(&asi, &z__);
    gmark_(&gp, &r__1, &r__2, &c__4, &c_b388, &c_b388);
/* L121: */
    z__ += 1;
    goto L120;
L122:
    gamove_(&gp, &c_b389, &c_b389);
    z__ = 1.f;
L130:
    if (! (z__ <= (real) np)) {
	goto L132;
    }
    r__1 = stfi2r_(&z__) * scale;
    r__2 = asievl_(&asi, &z__);
    gadraw_(&gp, &r__1, &r__2);
/* L131: */
    z__ += .1f;
    goto L130;
L132:
    sw0001 = memi[*sf + 4];
    goto L140;
L150:
    radius = memr[*curret + 51];
    gseti_(&gp, &c__14, &c__2);
    gline_(&gp, &x1, &level, &radius, &level);
    gline_(&gp, &radius, &level, &radius, &y1);
    gseti_(&gp, &c__14, &c__1);
    goto L141;
L160:
    radius = memr[*curret + 51] / 2.f;
    gseti_(&gp, &c__14, &c__2);
    gline_(&gp, &radius, &y1, &radius, &y2);
    gseti_(&gp, &c__14, &c__1);
    goto L141;
L140:
    if (sw0001 == 1) {
	goto L150;
    }
    goto L160;
L141:
    gseti_(&gp, &c__16, &c__2);
    stfmol_(sf, curret, &c_b389, &profie, &flux);
    gamove_(&gp, &c_b389, &flux);
    z__ = 1.f;
L170:
    if (! (z__ <= (real) np)) {
	goto L172;
    }
    r__ = stfi2r_(&z__) * scale;
    stfmol_(sf, curret, &r__, &profie, &flux);
    gadraw_(&gp, &r__, &flux);
/* L171: */
    z__ += .1f;
    goto L170;
L172:
    gseti_(&gp, &c__16, &c__1);
    if (! (memi[*sf + 13] == 1 && *curret != memi[*sf + 38])) {
	goto L180;
    }
    gseti_(&gp, &c__16, &c__2);
    np1 = memi[memi[*sf + 38] + 41];
    asi = memi[memi[*sf + 38] + 59];
    r1 = stfi2r_(&c_b896);
    r__1 = (real) np;
    r2 = stfi2r_(&r__1);
    dr = (r2 - r1) * .05f;
    r__ = r1;
L190:
    if (! (r__ <= r2)) {
	goto L192;
    }
    z__ = stfr2i_(&r__);
    r__1 = r__ + dr * .7f;
    z1 = stfr2i_(&r__1);
    if (! (z__ > 1.f && z1 <= (real) np1)) {
	goto L200;
    }
    r__1 = r__ * scale;
    r__2 = asievl_(&asi, &z__);
    r__3 = (r__ + dr * .7f) * scale;
    r__4 = asievl_(&asi, &z1);
    gline_(&gp, &r__1, &r__2, &r__3, &r__4);
L200:
/* L191: */
    r__ += dr;
    goto L190;
L192:
    gseti_(&gp, &c__16, &c__1);
L180:
L110:
/* L100: */
    zzepro_();
    return 0;
} /* stfg6_ */

#undef memx
#undef mems
#undef memr
#undef meml
#undef memi
#undef memc
#undef memb


/* Subroutine */ int stfg7_(integer *sf, integer *curret, shortint *title, 
	shortint *xlabel, shortint *ylabel)
{
    /* System generated locals */
    real r__1, r__2, r__3, r__4;

    /* Local variables */
    static real r__, z__, r1, r2, x1, x2, y1, y2, z1, dr;
    static integer gp, np, np1, asi;
#define memb ((logical *)&mem_1)
#define memc ((shortint *)&mem_1)
#define memi ((integer *)&mem_1)
#define meml ((integer *)&mem_1)
    static integer sw0001;
#define memr ((real *)&mem_1)
#define mems ((shortint *)&mem_1)
#define memx ((complex *)&mem_1)
    static real flux, scale;
    extern /* Subroutine */ int gline_(integer *, real *, real *, real *, 
	    real *), gmark_(integer *, real *, real *, integer *, real *, 
	    real *);
    static real level;
    extern /* Subroutine */ int gseti_(integer *, integer *, integer *);
    extern real stfi2r_(real *), stfr2i_(real *);
    extern /* Subroutine */ int glabax_(integer *, shortint *, shortint *, 
	    shortint *), gadraw_(integer *, real *, real *), gamove_(integer *
	    , real *, real *);
    extern real asievl_(integer *, real *);
    static real profie, radius;
    extern /* Subroutine */ int gswind_(integer *, real *, real *, real *, 
	    real *), stfmol_(integer *, integer *, real *, real *, real *), 
	    zzepro_(void);

    /* Parameter adjustments */
    --ylabel;
    --xlabel;
    --title;

    /* Function Body */
    gp = memi[*sf + 18];
    level = memr[*sf + 7];
    scale = memr[*sf + 6];
    np = memi[*curret + 41];
    asi = memi[*curret + 60];
    x1 = scale * -.5f;
    r__1 = (real) np;
    x2 = (stfi2r_(&r__1) + .5f) * scale;
    z__ = memr[*curret + 62] - memr[*curret + 61];
    y1 = memr[*curret + 61] - z__ * .05f;
    y2 = memr[*curret + 62] + z__ * .05f;
    gswind_(&gp, &x1, &x2, &y1, &y2);
    gseti_(&gp, &c__109, &c__1);
    gseti_(&gp, &c__209, &c__0);
    gseti_(&gp, &c__111, &c__6);
    gseti_(&gp, &c__112, &c__4);
    gseti_(&gp, &c__211, &c__6);
    gseti_(&gp, &c__212, &c__4);
    glabax_(&gp, &title[1], &xlabel[1], &ylabel[1]);
    gseti_(&gp, &c__16, &c__1);
    z__ = memr[*sf + 22];
L110:
    if (! (z__ <= memr[*sf + 23])) {
	goto L112;
    }
    r__1 = stfi2r_(&z__) * scale;
    r__2 = asievl_(&asi, &z__);
    gmark_(&gp, &r__1, &r__2, &c__4, &c_b388, &c_b388);
/* L111: */
    z__ += 1;
    goto L110;
L112:
    z__ = memr[*sf + 22];
    r__1 = stfi2r_(&z__) * scale;
    r__2 = asievl_(&asi, &z__);
    gamove_(&gp, &r__1, &r__2);
L120:
    if (! (z__ <= memr[*sf + 23])) {
	goto L122;
    }
    r__1 = stfi2r_(&z__) * scale;
    r__2 = asievl_(&asi, &z__);
    gadraw_(&gp, &r__1, &r__2);
/* L121: */
    z__ += .1f;
    goto L120;
L122:
    sw0001 = memi[*sf + 4];
    goto L130;
L140:
    radius = memr[*curret + 51];
    goto L131;
L150:
    radius = memr[*curret + 51] / 2.f;
    goto L131;
L130:
    if (sw0001 == 1) {
	goto L140;
    }
    goto L150;
L131:
    gseti_(&gp, &c__14, &c__2);
    gline_(&gp, &radius, &y1, &radius, &y2);
    gseti_(&gp, &c__14, &c__1);
    gseti_(&gp, &c__16, &c__2);
    z__ = memr[*sf + 22];
    r__ = stfi2r_(&z__) * scale;
    stfmol_(sf, curret, &r__, &profie, &flux);
    gamove_(&gp, &r__, &profie);
L160:
    if (! (z__ <= (real) np)) {
	goto L162;
    }
    r__ = stfi2r_(&z__) * scale;
    stfmol_(sf, curret, &r__, &profie, &flux);
    gadraw_(&gp, &r__, &profie);
/* L161: */
    z__ += .1f;
    goto L160;
L162:
    gseti_(&gp, &c__16, &c__1);
    if (! (memi[*sf + 13] == 1 && *curret != memi[*sf + 38])) {
	goto L170;
    }
    gseti_(&gp, &c__16, &c__2);
    np1 = memi[memi[*sf + 38] + 41];
    asi = memi[memi[*sf + 38] + 60];
    r1 = stfi2r_(&memr[*sf + 22]);
    r2 = stfi2r_(&memr[*sf + 23]);
    dr = (r2 - r1) * .05f;
    r__ = r1;
L180:
    if (! (r__ <= r2)) {
	goto L182;
    }
    z__ = stfr2i_(&r__);
    r__1 = r__ + dr * .7f;
    z1 = stfr2i_(&r__1);
    if (! (z__ > 1.f && z1 <= (real) np1)) {
	goto L190;
    }
    r__1 = r__ * scale;
    r__2 = asievl_(&asi, &z__);
    r__3 = (r__ + dr * .7f) * scale;
    r__4 = asievl_(&asi, &z1);
    gline_(&gp, &r__1, &r__2, &r__3, &r__4);
L190:
/* L181: */
    r__ += dr;
    goto L180;
L182:
    gseti_(&gp, &c__16, &c__1);
L170:
/* L100: */
    zzepro_();
    return 0;
} /* stfg7_ */

#undef memx
#undef mems
#undef memr
#undef meml
#undef memi
#undef memc
#undef memb


/* Subroutine */ int stfg8_(integer *sf, integer *curret, shortint *title, 
	shortint *xlabel, shortint *ylabel)
{
    /* System generated locals */
    real r__1, r__2;

    /* Local variables */
    static real y1, y2;
    static integer gp;
#define memb ((logical *)&mem_1)
#define memc ((shortint *)&mem_1)
#define memi ((integer *)&mem_1)
#define meml ((integer *)&mem_1)
    static integer sw0001;
#define memr ((real *)&mem_1)
#define mems ((shortint *)&mem_1)
    static real fwhm;
#define memx ((complex *)&mem_1)
    extern /* Subroutine */ int gline_(integer *, real *, real *, real *, 
	    real *), alimr_(real *, integer *, real *, real *);
    static real level;
    extern /* Subroutine */ int gseti_(integer *, integer *, integer *), 
	    glabax_(integer *, shortint *, shortint *, shortint *), gvline_(
	    integer *, real *, integer *, real *, real *), gvmark_(integer *, 
	    real *, integer *, real *, real *, integer *, real *, real *), 
	    gswind_(integer *, real *, real *, real *, real *), zzepro_(void);

    /* Parameter adjustments */
    --ylabel;
    --xlabel;
    --title;

    /* Function Body */
    level = memr[*sf + 7];
    if (! (memi[*sf + 4] == 1)) {
	goto L110;
    }
    fwhm = memr[*curret + 58];
    goto L111;
L110:
    fwhm = memr[*curret + 51];
L111:
    alimr_(&memr[*curret + 64], &c__17, &y1, &y2);
    y2 -= y1;
    y1 -= y2 * .05f;
    y2 = y1 + y2 * 1.1f;
/* Computing MIN */
    r__1 = y1, r__2 = fwhm * .9f;
    y1 = min(r__1,r__2);
/* Computing MAX */
    r__1 = y2, r__2 = fwhm * 1.1f;
    y2 = max(r__1,r__2);
    gp = memi[*sf + 18];
    gseti_(&gp, &c__309, &c__1);
    gseti_(&gp, &c__111, &c__6);
    gseti_(&gp, &c__112, &c__4);
    gseti_(&gp, &c__211, &c__6);
    gseti_(&gp, &c__212, &c__4);
    gswind_(&gp, &c_b389, &c_b896, &y1, &y2);
    glabax_(&gp, &title[1], &xlabel[1], &ylabel[1]);
    gvline_(&gp, &memr[*curret + 64], &c__17, &c_b234, &c_b1221);
    gvmark_(&gp, &memr[*curret + 64], &c__17, &c_b234, &c_b1221, &c__4, &
	    c_b388, &c_b388);
    sw0001 = memi[*sf + 4];
    goto L120;
L130:
    gseti_(&gp, &c__14, &c__2);
    gline_(&gp, &c_b389, &fwhm, &level, &fwhm);
    gline_(&gp, &level, &y1, &level, &fwhm);
    gseti_(&gp, &c__14, &c__1);
    goto L121;
L140:
    gseti_(&gp, &c__14, &c__2);
    gline_(&gp, &c_b389, &fwhm, &c_b896, &fwhm);
    gseti_(&gp, &c__14, &c__1);
    goto L121;
L120:
    if (sw0001 == 1) {
	goto L130;
    }
    goto L140;
L121:
/* L100: */
    zzepro_();
    return 0;
} /* stfg8_ */

#undef memx
#undef mems
#undef memr
#undef meml
#undef memi
#undef memc
#undef memb


/* Subroutine */ int stfg9_(integer *sf, integer *curret, shortint *title)
{
    /* Initialized data */

    static shortint st0001[1] = { 0 };
    static shortint st0002[1] = { 0 };
    static shortint st0003[1] = { 0 };
    static shortint st0004[5] = { 37,46,51,103,0 };
    static shortint st0005[8] = { 104,61,114,59,118,61,116,0 };
    static shortint st0006[5] = { 37,46,52,103,0 };
    static shortint st0007[8] = { 104,61,108,59,118,61,116,0 };
    static shortint st0008[1] = { 0 };
    static shortint st0009[1] = { 0 };

    /* System generated locals */
    integer i__1;
    real r__1, r__2, r__3, r__4;

    /* Builtin functions */
    double sqrt(doublereal);
    integer i_nint(real *);

    /* Local variables */
    static integer i__, j;
    static real x1, x2, y1, y2, fa[10];
    static integer gp, ix, iy, sp, nx, ny;
    static real vx, vy;
    static integer sfd, sfs;
    static real dvx, dvy;
    static integer str;
#define memb ((logical *)&mem_1)
#define memc ((shortint *)&mem_1)
#define memi ((integer *)&mem_1)
#define meml ((integer *)&mem_1)
#define memr ((real *)&mem_1)
#define mems ((shortint *)&mem_1)
    static real fwhm;
#define memx ((complex *)&mem_1)
    extern /* Subroutine */ int gfill_(integer *, real *, real *, integer *, 
	    integer *), alimr_(real *, integer *, real *, real *), sfree_(
	    integer *);
    static real level;
    extern /* Subroutine */ int gseti_(integer *, integer *, integer *), 
	    pargr_(real *), smark_(integer *), gsetr_(integer *, integer *, 
	    real *), gtext_(integer *, real *, real *, shortint *, shortint *)
	    , glabax_(integer *, shortint *, shortint *, shortint *), salloc_(
	    integer *, integer *, integer *), gpline_(integer *, real *, real 
	    *, integer *), gamove_(integer *, real *, real *), gvline_(
	    integer *, real *, integer *, real *, real *), ggview_(integer *, 
	    real *, real *, real *, real *), gswind_(integer *, real *, real *
	    , real *, real *), sprinf_(shortint *, integer *, shortint *), 
	    gsview_(integer *, real *, real *, real *, real *), zzepro_(void);

    /* Parameter adjustments */
    --title;

    /* Function Body */
    smark_(&sp);
    salloc_(&str, &c__1023, &c__2);
    gp = memi[*sf + 18];
    sfs = memi[*curret + 90];
    level = memr[*sf + 7];
    if (! (memi[*sf + 4] == 1)) {
	goto L110;
    }
    fwhm = memr[*curret + 58];
    goto L111;
L110:
    fwhm = memr[*curret + 51];
L111:
    i__ = memi[sfs + 3];
    if (! (i__ < 4)) {
	goto L120;
    }
    nx = i__;
    ny = 1;
    goto L121;
L120:
    r__1 = sqrt((real) i__);
    nx = i_nint(&r__1);
    if (! ((i__ - 1) % (nx + 1) >= (i__ - 1) % nx)) {
	goto L130;
    }
    ++nx;
L130:
    ny = (i__ - 1) / nx + 1;
L121:
    ggview_(&gp, &vx, &dvx, &vy, &dvy);
    dvx = (dvx - vx) / nx;
    dvy = (dvy - vy) / ny;
    y1 = fwhm * .9f;
    y2 = fwhm * 1.1f;
    i__1 = memi[sfs + 5];
    for (i__ = 1; i__ <= i__1; ++i__) {
	sfd = memi[sfs + i__ + 5];
	if (! (memi[sfd + 88] != 0)) {
	    goto L150;
	}
	goto L140;
L150:
	alimr_(&memr[sfd + 64], &c__17, &x1, &x2);
	x2 -= x1;
	x1 -= x2 * .05f;
	x2 = x1 + x2 * 1.1f;
	y1 = min(x1,y1);
	y2 = max(x2,y2);
L140:
	;
    }
/* L141: */
    x2 = y2 - y1;
/* Computing MIN */
    r__1 = y1, r__2 = fwhm - x2 * .2f;
    y1 = min(r__1,r__2);
/* Computing MAX */
    r__1 = y2, r__2 = fwhm + x2 * .2f;
    y2 = max(r__1,r__2);
    x1 = 0.f;
    x2 = 1.f;
    gswind_(&gp, &x1, &x2, &y1, &y2);
    fa[0] = x1;
    fa[5] = y1;
    fa[1] = x2;
    fa[6] = y1;
    fa[2] = x2;
    fa[7] = y2;
    fa[3] = x1;
    fa[8] = y2;
    fa[4] = x1;
    fa[9] = y1;
    j = 0;
    i__1 = memi[sfs + 5];
    for (i__ = 1; i__ <= i__1; ++i__) {
	sfd = memi[sfs + i__ + 5];
	if (! (memi[sfd + 88] != 0)) {
	    goto L170;
	}
	goto L160;
L170:
	ix = j % nx + 1;
	iy = j / nx + 1;
	++j;
	r__1 = vx + dvx * (ix - 1);
	r__2 = vx + dvx * ix;
	r__3 = vy + dvy * (ny - iy);
	r__4 = vy + (ny - iy + 1) * dvy;
	gsview_(&gp, &r__1, &r__2, &r__3, &r__4);
	gfill_(&gp, fa, &fa[5], &c__4, &c__2);
	gseti_(&gp, &c__309, &c__0);
	glabax_(&gp, st0001, st0002, st0003);
	if (! (sfd == *curret)) {
	    goto L180;
	}
	r__1 = vx + dvx * (ix - 1) + .005f;
	r__2 = vx + dvx * ix - .005f;
	r__3 = vy + dvy * (ny - iy) + .005f;
	r__4 = vy + (ny - iy + 1) * dvy - .005f;
	gsview_(&gp, &r__1, &r__2, &r__3, &r__4);
	gsetr_(&gp, &c__15, &c_b891);
	gseti_(&gp, &c__16, &c__2);
	gpline_(&gp, fa, &fa[5], &c__5);
	gsetr_(&gp, &c__15, &c_b896);
	gseti_(&gp, &c__16, &c__1);
	r__1 = vx + dvx * (ix - 1);
	r__2 = vx + dvx * ix;
	r__3 = vy + dvy * (ny - iy);
	r__4 = vy + (ny - iy + 1) * dvy;
	gsview_(&gp, &r__1, &r__2, &r__3, &r__4);
L180:
	gvline_(&gp, &memr[sfd + 64], &c__17, &c_b234, &c_b1221);
	sprinf_(&memc[str - 1], &c__1023, st0004);
	pargr_(&memr[sfd + 51]);
	r__1 = y2 * .95f + y1 * .05f;
	gtext_(&gp, &c_b233, &r__1, &memc[str - 1], st0005);
	if (! (nx < 5 && ny < 5)) {
	    goto L190;
	}
	sprinf_(&memc[str - 1], &c__1023, st0006);
	pargr_(&memr[sfd + 50]);
	r__1 = y2 * .95f + y1 * .05f;
	gtext_(&gp, &c_b919, &r__1, &memc[str - 1], st0007);
L190:
L160:
	;
    }
/* L161: */
    r__1 = vx + nx * dvx;
    r__2 = vy + ny * dvy;
    gsview_(&gp, &vx, &r__1, &vy, &r__2);
    r__1 = nx + .5f;
    r__2 = ny + .5f;
    gswind_(&gp, &c_b393, &r__1, &r__2, &c_b393);
    gamove_(&gp, &c_b896, &c_b896);
    gseti_(&gp, &c__301, &c__0);
    glabax_(&gp, &title[1], st0008, st0009);
    gseti_(&gp, &c__301, &c__3);
    sfree_(&sp);
/* L100: */
    zzepro_();
    return 0;
} /* stfg9_ */

#undef memx
#undef mems
#undef memr
#undef meml
#undef memi
#undef memc
#undef memb


/* Subroutine */ int stfg10_(integer *sf, integer *curret, shortint *title)
{
    /* Initialized data */

    static shortint st0001[1] = { 0 };
    static shortint st0002[1] = { 0 };
    static shortint st0003[1] = { 0 };
    static shortint st0004[5] = { 37,46,51,103,0 };
    static shortint st0005[8] = { 104,61,114,59,118,61,116,0 };
    static shortint st0006[6] = { 37,100,32,37,100,0 };
    static shortint st0007[8] = { 104,61,108,59,118,61,116,0 };
    static shortint st0008[1] = { 0 };
    static shortint st0009[1] = { 0 };

    /* System generated locals */
    integer i__1;
    real r__1, r__2, r__3, r__4;

    /* Builtin functions */
    double sqrt(doublereal);
    integer i_nint(real *);

    /* Local variables */
    static integer i__, j;
    static real x1, x2, y1, y2, fa[10];
    static integer gp, ix, iy, sp, nx, ny;
    static real vx, vy;
    static integer sfd, sff;
    static real dvx, dvy;
    static integer str;
#define memb ((logical *)&mem_1)
#define memc ((shortint *)&mem_1)
#define memi ((integer *)&mem_1)
#define meml ((integer *)&mem_1)
#define memr ((real *)&mem_1)
#define mems ((shortint *)&mem_1)
    static real fwhm;
#define memx ((complex *)&mem_1)
    extern /* Subroutine */ int gfill_(integer *, real *, real *, integer *, 
	    integer *), alimr_(real *, integer *, real *, real *), sfree_(
	    integer *);
    static real level;
    extern /* Subroutine */ int gseti_(integer *, integer *, integer *), 
	    pargr_(real *), smark_(integer *), gsetr_(integer *, integer *, 
	    real *), gtext_(integer *, real *, real *, shortint *, shortint *)
	    , glabax_(integer *, shortint *, shortint *, shortint *), salloc_(
	    integer *, integer *, integer *), gpline_(integer *, real *, real 
	    *, integer *), gamove_(integer *, real *, real *), gvline_(
	    integer *, real *, integer *, real *, real *), ggview_(integer *, 
	    real *, real *, real *, real *), gswind_(integer *, real *, real *
	    , real *, real *), sprinf_(shortint *, integer *, shortint *), 
	    gsview_(integer *, real *, real *, real *, real *), zzepro_(void);

    /* Parameter adjustments */
    --title;

    /* Function Body */
    smark_(&sp);
    salloc_(&str, &c__1023, &c__2);
    gp = memi[*sf + 18];
    sff = memi[*curret + 91];
    level = memr[*sf + 7];
    if (! (memi[*sf + 4] == 1)) {
	goto L110;
    }
    fwhm = memr[*curret + 58];
    goto L111;
L110:
    fwhm = memr[*curret + 51];
L111:
    i__ = memi[sff + 1];
    if (! (i__ < 4)) {
	goto L120;
    }
    nx = i__;
    ny = 1;
    goto L121;
L120:
    r__1 = sqrt((real) i__);
    nx = i_nint(&r__1);
    if (! ((i__ - 1) % (nx + 1) >= (i__ - 1) % nx)) {
	goto L130;
    }
    ++nx;
L130:
    ny = (i__ - 1) / nx + 1;
L121:
    ggview_(&gp, &vx, &dvx, &vy, &dvy);
    dvx = (dvx - vx) / nx;
    dvy = (dvy - vy) / ny;
    y1 = fwhm * .9f;
    y2 = fwhm * 1.1f;
    i__1 = memi[sff + 3];
    for (i__ = 1; i__ <= i__1; ++i__) {
	sfd = memi[sff + i__ + 3];
	if (! (memi[sfd + 88] != 0)) {
	    goto L150;
	}
	goto L140;
L150:
	alimr_(&memr[sfd + 64], &c__17, &x1, &x2);
	x2 -= x1;
	x1 -= x2 * .05f;
	x2 = x1 + x2 * 1.1f;
	y1 = min(x1,y1);
	y2 = max(x2,y2);
L140:
	;
    }
/* L141: */
    x2 = y2 - y1;
/* Computing MIN */
    r__1 = y1, r__2 = fwhm - x2 * .2f;
    y1 = min(r__1,r__2);
/* Computing MAX */
    r__1 = y2, r__2 = fwhm + x2 * .2f;
    y2 = max(r__1,r__2);
    x1 = 0.f;
    x2 = 1.f;
    gswind_(&gp, &x1, &x2, &y1, &y2);
    fa[0] = x1;
    fa[5] = y1;
    fa[1] = x2;
    fa[6] = y1;
    fa[2] = x2;
    fa[7] = y2;
    fa[3] = x1;
    fa[8] = y2;
    fa[4] = x1;
    fa[9] = y1;
    j = 0;
    i__1 = memi[sff + 3];
    for (i__ = 1; i__ <= i__1; ++i__) {
	sfd = memi[sff + i__ + 3];
	if (! (memi[sfd + 88] != 0)) {
	    goto L170;
	}
	goto L160;
L170:
	ix = j % nx + 1;
	iy = j / nx + 1;
	++j;
	r__1 = vx + dvx * (ix - 1);
	r__2 = vx + dvx * ix;
	r__3 = vy + dvy * (ny - iy);
	r__4 = vy + (ny - iy + 1) * dvy;
	gsview_(&gp, &r__1, &r__2, &r__3, &r__4);
	gfill_(&gp, fa, &fa[5], &c__4, &c__2);
	gseti_(&gp, &c__309, &c__0);
	glabax_(&gp, st0001, st0002, st0003);
	if (! (sfd == *curret)) {
	    goto L180;
	}
	r__1 = vx + dvx * (ix - 1) + .005f;
	r__2 = vx + dvx * ix - .005f;
	r__3 = vy + dvy * (ny - iy) + .005f;
	r__4 = vy + (ny - iy + 1) * dvy - .005f;
	gsview_(&gp, &r__1, &r__2, &r__3, &r__4);
	gsetr_(&gp, &c__15, &c_b891);
	gseti_(&gp, &c__16, &c__2);
	gpline_(&gp, fa, &fa[5], &c__5);
	gsetr_(&gp, &c__15, &c_b896);
	gseti_(&gp, &c__16, &c__1);
	r__1 = vx + dvx * (ix - 1);
	r__2 = vx + dvx * ix;
	r__3 = vy + dvy * (ny - iy);
	r__4 = vy + (ny - iy + 1) * dvy;
	gsview_(&gp, &r__1, &r__2, &r__3, &r__4);
L180:
	gvline_(&gp, &memr[sfd + 64], &c__17, &c_b234, &c_b1221);
	sprinf_(&memc[str - 1], &c__1023, st0004);
	pargr_(&memr[sfd + 51]);
	r__1 = y2 * .95f + y1 * .05f;
	gtext_(&gp, &c_b233, &r__1, &memc[str - 1], st0005);
	if (! (nx < 5 && ny < 5)) {
	    goto L190;
	}
	sprinf_(&memc[str - 1], &c__1023, st0006);
	pargr_(&memr[sfd + 48]);
	pargr_(&memr[sfd + 49]);
	r__1 = y2 * .95f + y1 * .05f;
	gtext_(&gp, &c_b919, &r__1, &memc[str - 1], st0007);
L190:
L160:
	;
    }
/* L161: */
    r__1 = vx + nx * dvx;
    r__2 = vy + ny * dvy;
    gsview_(&gp, &vx, &r__1, &vy, &r__2);
    r__1 = nx + .5f;
    r__2 = ny + .5f;
    gswind_(&gp, &c_b393, &r__1, &r__2, &c_b393);
    gamove_(&gp, &c_b896, &c_b896);
    gseti_(&gp, &c__301, &c__0);
    glabax_(&gp, &title[1], st0008, st0009);
    gseti_(&gp, &c__301, &c__3);
    sfree_(&sp);
/* L100: */
    zzepro_();
    return 0;
} /* stfg10_ */

#undef memx
#undef mems
#undef memr
#undef meml
#undef memi
#undef memc
#undef memb


/* Subroutine */ int stfg11_(integer *sf, integer *curret, integer *key, 
	shortint *title)
{
    /* Initialized data */

    static shortint st0001[1] = { 0 };
    static shortint st0002[7] = { 67,111,108,117,109,110,0 };
    static shortint st0003[1] = { 0 };
    static shortint st0004[1] = { 0 };
    static shortint st0005[5] = { 76,105,110,101,0 };
    static shortint st0006[1] = { 0 };
    static shortint st0007[1] = { 0 };
    static shortint st0008[6] = { 69,108,108,105,112,0 };
    static shortint st0009[1] = { 0 };
    static shortint st0010[6] = { 69,108,108,105,112,0 };
    static shortint st0011[1] = { 0 };
    static shortint st0012[1] = { 0 };
    static shortint st0013[1] = { 0 };
    static shortint st0014[1] = { 0 };
    static shortint st0015[1] = { 0 };
    static shortint st0016[1] = { 0 };
    static real fa[8] = { 0.f,1.f,1.f,0.f,0.f,0.f,1.f,1.f };

    /* System generated locals */
    integer i__1;
    real r__1, r__2;

    /* Builtin functions */
    double sqrt(doublereal);

    /* Local variables */
    static integer i__;
    static real x, y, z__, x1, x2, y1, y2;
    static integer gp;
    static real vx[6]	/* was [3][2] */, vy[6]	/* was [3][2] */;
    static integer sfd, sff;
    static real dvx, dvy;
#define memb ((logical *)&mem_1)
#define memc ((shortint *)&mem_1)
#define memi ((integer *)&mem_1)
    static real emin;
#define meml ((integer *)&mem_1)
    static real emax;
#define memr ((real *)&mem_1)
#define mems ((shortint *)&mem_1)
    static real rmin;
#define memx ((complex *)&mem_1)
    static real rmax;
    extern /* Subroutine */ int gfill_(integer *, real *, real *, integer *, 
	    integer *), gline_(integer *, real *, real *, real *, real *), 
	    gmark_(integer *, real *, real *, integer *, real *, real *), 
	    gseti_(integer *, integer *, integer *);
    static real rbest;
    extern /* Subroutine */ int glabax_(integer *, shortint *, shortint *, 
	    shortint *), ggview_(integer *, real *, real *, real *, real *), 
	    gswind_(integer *, real *, real *, real *, real *), gsview_(
	    integer *, real *, real *, real *, real *), zzepro_(void);

    /* Parameter adjustments */
    --title;

    /* Function Body */
    gp = memi[(0 + (0 + (*sf + 19 - 1 << 2))) / 4];
    sff = memi[*curret + 91];
    x1 = 1.f;
    y1 = 1.f;
    x2 = (real) memi[*sf + 14];
    y2 = (real) memi[*sf + 15];
    rbest = memr[memi[*sf + 38] + 51];
    rmin = memr[*sf + 20];
    rmax = memr[*sf + 20] * 1.5f;
    emin = 0.f;
    emax = 1.f;
    i__1 = memi[sff + 3];
    for (i__ = 1; i__ <= i__1; ++i__) {
	sfd = memi[sff + i__ + 3];
	if (! (memi[sfd + 88] != 0)) {
	    goto L120;
	}
	goto L110;
L120:
/* Computing MIN */
	r__1 = rmin, r__2 = memr[sfd + 51];
	rmin = min(r__1,r__2);
/* Computing MAX */
	r__1 = rmax, r__2 = memr[sfd + 51];
	rmax = max(r__1,r__2);
/* Computing MIN */
	r__1 = emin, r__2 = memr[sfd + 53];
	emin = min(r__1,r__2);
/* Computing MAX */
	r__1 = emax, r__2 = memr[sfd + 53];
	emax = max(r__1,r__2);
L110:
	;
    }
/* L111: */
    z__ = rmax - rmin;
    rmin -= z__ * .1f;
    rmax += z__ * .1f;
    ggview_(&gp, vx, &vx[5], vy, &vy[5]);
    dvx = vx[5] - vx[0];
    dvy = vy[5] - vy[0];
    vx[0] += dvx * 0.f;
    vx[3] = vx[0] + dvx * .2f;
    vx[1] = vx[0] + dvx * .25f;
    vx[4] = vx[0] + dvx * .75f;
    vx[2] = vx[0] + dvx * .8f;
    vx[5] = vx[0] + dvx * 1.f;
    vy[0] += dvy * 0.f;
    vy[3] = vy[0] + dvy * .2f;
    vy[1] = vy[0] + dvy * .25f;
    vy[4] = vy[0] + dvy * .75f;
    vy[2] = vy[0] + dvy * .8f;
    vy[5] = vy[0] + dvy * 1.f;
    gseti_(&gp, &c__3, &c__2);
    gseti_(&gp, &c__301, &c__3);
    gseti_(&gp, &c__110, &c__1);
    gseti_(&gp, &c__210, &c__1);
    gseti_(&gp, &c__111, &c__6);
    gseti_(&gp, &c__112, &c__4);
    gseti_(&gp, &c__211, &c__4);
    gseti_(&gp, &c__212, &c__0);
    gsview_(&gp, &vx[1], &vx[4], vy, &vy[3]);
    gswind_(&gp, &c_b389, &c_b896, &c_b389, &c_b896);
    gfill_(&gp, fa, &fa[4], &c__4, &c__2);
    gswind_(&gp, &x1, &x2, &rmin, &rmax);
    glabax_(&gp, st0001, st0002, st0003);
    i__1 = memi[sff + 3];
    for (i__ = 1; i__ <= i__1; ++i__) {
	sfd = memi[sff + i__ + 3];
	if (! (memi[sfd + 88] != 0)) {
	    goto L140;
	}
	goto L130;
L140:
	x = memr[sfd + 48];
	y = memr[sfd + 51];
	if (! (*key == 1)) {
	    goto L150;
	}
	z__ = sqrt(memr[memi[sfd + 90] + 2] / memr[*sf + 21]);
/* Computing MAX */
	r__1 = .005f, r__2 = z__ * .03f;
	z__ = max(r__1,r__2);
	gmark_(&gp, &x, &y, &c__12, &z__, &z__);
L150:
	if (! (memr[sfd + 51] < memr[*sf + 20])) {
	    goto L160;
	}
	gseti_(&gp, &c__16, &c__2);
	goto L161;
L160:
	gseti_(&gp, &c__16, &c__3);
L161:
/* Computing MIN */
	r__1 = 2.f, r__2 = memr[sfd + 51] / rbest;
	z__ = min(r__1,r__2);
	z__ = ((z__ - 1) * 5 + 1) * .01f;
	gmark_(&gp, &x, &y, &c__512, &z__, &z__);
	gseti_(&gp, &c__16, &c__1);
L130:
	;
    }
/* L131: */
    gseti_(&gp, &c__14, &c__2);
    gline_(&gp, &x1, &memr[*sf + 20], &x2, &memr[*sf + 20]);
    gseti_(&gp, &c__14, &c__1);
    gseti_(&gp, &c__3, &c__3);
    gseti_(&gp, &c__110, &c__1);
    gseti_(&gp, &c__210, &c__1);
    gseti_(&gp, &c__111, &c__4);
    gseti_(&gp, &c__112, &c__0);
    gseti_(&gp, &c__211, &c__6);
    gseti_(&gp, &c__212, &c__4);
    gsview_(&gp, vx, &vx[3], &vy[1], &vy[4]);
    gswind_(&gp, &c_b389, &c_b896, &c_b389, &c_b896);
    gfill_(&gp, fa, &fa[4], &c__4, &c__2);
    gswind_(&gp, &rmin, &rmax, &y1, &y2);
    glabax_(&gp, st0004, &memc[*sf * 2], st0005);
    i__1 = memi[sff + 3];
    for (i__ = 1; i__ <= i__1; ++i__) {
	sfd = memi[sff + i__ + 3];
	if (! (memi[sfd + 88] != 0)) {
	    goto L180;
	}
	goto L170;
L180:
	x = memr[sfd + 51];
	y = memr[sfd + 49];
	if (! (*key == 1)) {
	    goto L190;
	}
	z__ = sqrt(memr[memi[sfd + 90] + 2] / memr[*sf + 21]);
/* Computing MAX */
	r__1 = .005f, r__2 = z__ * .03f;
	z__ = max(r__1,r__2);
	gmark_(&gp, &x, &y, &c__12, &z__, &z__);
L190:
	if (! (memr[sfd + 51] < memr[*sf + 20])) {
	    goto L200;
	}
	gseti_(&gp, &c__16, &c__2);
	goto L201;
L200:
	gseti_(&gp, &c__16, &c__3);
L201:
/* Computing MIN */
	r__1 = 2.f, r__2 = memr[sfd + 51] / rbest;
	z__ = min(r__1,r__2);
	z__ = ((z__ - 1) * 5 + 1) * .01f;
	gmark_(&gp, &x, &y, &c__512, &z__, &z__);
	gseti_(&gp, &c__16, &c__1);
L170:
	;
    }
/* L171: */
    gseti_(&gp, &c__14, &c__2);
    gline_(&gp, &memr[*sf + 20], &y1, &memr[*sf + 20], &y2);
    gseti_(&gp, &c__14, &c__1);
    gseti_(&gp, &c__3, &c__4);
    gseti_(&gp, &c__301, &c__3);
    gseti_(&gp, &c__110, &c__0);
    gseti_(&gp, &c__210, &c__1);
    gseti_(&gp, &c__111, &c__6);
    gseti_(&gp, &c__112, &c__4);
    gseti_(&gp, &c__211, &c__4);
    gseti_(&gp, &c__212, &c__0);
    gsview_(&gp, &vx[1], &vx[4], &vy[2], &vy[5]);
    gswind_(&gp, &c_b389, &c_b896, &c_b389, &c_b896);
    gfill_(&gp, fa, &fa[4], &c__4, &c__2);
    gswind_(&gp, &x1, &x2, &emin, &emax);
    glabax_(&gp, st0006, st0007, st0008);
    i__1 = memi[sff + 3];
    for (i__ = 1; i__ <= i__1; ++i__) {
	sfd = memi[sff + i__ + 3];
	if (! (memi[sfd + 88] != 0)) {
	    goto L220;
	}
	goto L210;
L220:
	x = memr[sfd + 48];
	y = memr[sfd + 53];
	if (! (*key == 1)) {
	    goto L230;
	}
	z__ = sqrt(memr[memi[sfd + 90] + 2] / memr[*sf + 21]);
/* Computing MAX */
	r__1 = .005f, r__2 = z__ * .03f;
	z__ = max(r__1,r__2);
	gmark_(&gp, &x, &y, &c__12, &z__, &z__);
L230:
	if (! (memr[sfd + 51] < memr[*sf + 20])) {
	    goto L240;
	}
	gseti_(&gp, &c__16, &c__2);
	goto L241;
L240:
	gseti_(&gp, &c__16, &c__3);
L241:
/* Computing MIN */
	r__1 = 2.f, r__2 = memr[sfd + 51] / rbest;
	z__ = min(r__1,r__2);
	z__ = ((z__ - 1) * 5 + 1) * .01f;
	gmark_(&gp, &x, &y, &c__512, &z__, &z__);
	gseti_(&gp, &c__16, &c__1);
L210:
	;
    }
/* L211: */
    gseti_(&gp, &c__3, &c__5);
    gseti_(&gp, &c__110, &c__1);
    gseti_(&gp, &c__210, &c__0);
    gseti_(&gp, &c__111, &c__4);
    gseti_(&gp, &c__112, &c__0);
    gseti_(&gp, &c__211, &c__6);
    gseti_(&gp, &c__212, &c__4);
    gsview_(&gp, &vx[2], &vx[5], &vy[1], &vy[4]);
    gswind_(&gp, &c_b389, &c_b896, &c_b389, &c_b896);
    gfill_(&gp, fa, &fa[4], &c__4, &c__2);
    gswind_(&gp, &emin, &emax, &y1, &y2);
    glabax_(&gp, st0009, st0010, st0011);
    i__1 = memi[sff + 3];
    for (i__ = 1; i__ <= i__1; ++i__) {
	sfd = memi[sff + i__ + 3];
	if (! (memi[sfd + 88] != 0)) {
	    goto L260;
	}
	goto L250;
L260:
	x = memr[sfd + 53];
	y = memr[sfd + 49];
	if (! (*key == 1)) {
	    goto L270;
	}
	z__ = sqrt(memr[memi[sfd + 90] + 2] / memr[*sf + 21]);
/* Computing MAX */
	r__1 = .005f, r__2 = z__ * .03f;
	z__ = max(r__1,r__2);
	gmark_(&gp, &x, &y, &c__12, &z__, &z__);
L270:
	if (! (memr[sfd + 51] < memr[*sf + 20])) {
	    goto L280;
	}
	gseti_(&gp, &c__16, &c__2);
	goto L281;
L280:
	gseti_(&gp, &c__16, &c__3);
L281:
/* Computing MIN */
	r__1 = 2.f, r__2 = memr[sfd + 51] / rbest;
	z__ = min(r__1,r__2);
	z__ = ((z__ - 1) * 5 + 1) * .01f;
	gmark_(&gp, &x, &y, &c__512, &z__, &z__);
	gseti_(&gp, &c__16, &c__1);
L250:
	;
    }
/* L251: */
    gseti_(&gp, &c__3, &c__1);
    gseti_(&gp, &c__301, &c__0);
    gsview_(&gp, vx, &vx[5], vy, &vy[5]);
    glabax_(&gp, &title[1], st0012, st0013);
    gseti_(&gp, &c__301, &c__3);
    gseti_(&gp, &c__310, &c__0);
    gseti_(&gp, &c__111, &c__6);
    gseti_(&gp, &c__112, &c__4);
    gseti_(&gp, &c__211, &c__6);
    gseti_(&gp, &c__212, &c__4);
    gsview_(&gp, &vx[1], &vx[4], &vy[1], &vy[4]);
    gswind_(&gp, &c_b389, &c_b896, &c_b389, &c_b896);
    gfill_(&gp, fa, &fa[4], &c__4, &c__2);
    gswind_(&gp, &x1, &x2, &y1, &y2);
    glabax_(&gp, st0014, st0015, st0016);
    i__1 = memi[sff + 3];
    for (i__ = 1; i__ <= i__1; ++i__) {
	sfd = memi[sff + i__ + 3];
	if (! (memi[sfd + 88] != 0)) {
	    goto L300;
	}
	goto L290;
L300:
	x = memr[sfd + 48];
	y = memr[sfd + 49];
	if (! (*key == 1)) {
	    goto L310;
	}
	z__ = sqrt(memr[memi[sfd + 90] + 2] / memr[*sf + 21]);
/* Computing MAX */
	r__1 = .005f, r__2 = z__ * .03f;
	z__ = max(r__1,r__2);
	gmark_(&gp, &x, &y, &c__12, &z__, &z__);
L310:
	if (! (memr[sfd + 51] < memr[*sf + 20])) {
	    goto L320;
	}
	gseti_(&gp, &c__16, &c__2);
	goto L321;
L320:
	gseti_(&gp, &c__16, &c__3);
L321:
/* Computing MIN */
	r__1 = 2.f, r__2 = memr[sfd + 51] / rbest;
	z__ = min(r__1,r__2);
	z__ = ((z__ - 1) * 5 + 1) * .01f;
	gmark_(&gp, &x, &y, &c__512, &z__, &z__);
	gseti_(&gp, &c__16, &c__1);
L290:
	;
    }
/* L291: */
/* L100: */
    zzepro_();
    return 0;
} /* stfg11_ */

#undef memx
#undef mems
#undef memr
#undef meml
#undef memi
#undef memc
#undef memb


/* Subroutine */ int stfg12_(integer *sf, integer *curret, integer *key, 
	shortint *title)
{
    /* Initialized data */

    static shortint st0001[1] = { 0 };
    static shortint st0002[7] = { 67,111,108,117,109,110,0 };
    static shortint st0003[1] = { 0 };
    static shortint st0004[1] = { 0 };
    static shortint st0005[5] = { 76,105,110,101,0 };
    static shortint st0006[1] = { 0 };
    static shortint st0007[1] = { 0 };
    static shortint st0008[6] = { 70,111,99,117,115,0 };
    static shortint st0009[1] = { 0 };
    static shortint st0010[6] = { 70,111,99,117,115,0 };
    static shortint st0011[1] = { 0 };
    static shortint st0012[1] = { 0 };
    static shortint st0013[1] = { 0 };
    static shortint st0014[1] = { 0 };
    static shortint st0015[1] = { 0 };
    static shortint st0016[1] = { 0 };
    static real fa[8] = { 0.f,1.f,1.f,0.f,0.f,0.f,1.f,1.f };

    /* System generated locals */
    integer i__1;
    real r__1, r__2;

    /* Builtin functions */
    double sqrt(doublereal);

    /* Local variables */
    static integer i__;
    static real x, y, z__, x1, x2, y1, y2;
    static integer gp;
    static real vx[6]	/* was [3][2] */, vy[6]	/* was [3][2] */;
    static integer sfd, sfs;
    static real dvx, dvy;
#define memb ((logical *)&mem_1)
#define memc ((shortint *)&mem_1)
#define memi ((integer *)&mem_1)
    static real fmin;
#define meml ((integer *)&mem_1)
    static real fmax;
#define memr ((real *)&mem_1)
#define mems ((shortint *)&mem_1)
    static real rmin;
#define memx ((complex *)&mem_1)
    static real rmax;
    extern /* Subroutine */ int gfill_(integer *, real *, real *, integer *, 
	    integer *), gline_(integer *, real *, real *, real *, real *), 
	    gmark_(integer *, real *, real *, integer *, real *, real *), 
	    gseti_(integer *, integer *, integer *);
    static real rbest;
    extern /* Subroutine */ int glabax_(integer *, shortint *, shortint *, 
	    shortint *), ggview_(integer *, real *, real *, real *, real *), 
	    gswind_(integer *, real *, real *, real *, real *), gsview_(
	    integer *, real *, real *, real *, real *), zzepro_(void);

    /* Parameter adjustments */
    --title;

    /* Function Body */
    gp = memi[(0 + (0 + (*sf + 19 - 1 << 2))) / 4];
    x1 = 1.f;
    y1 = 1.f;
    x2 = (real) memi[*sf + 14];
    y2 = (real) memi[*sf + 15];
    rbest = memr[memi[*sf + 38] + 51];
    fmin = 9.9e36f;
    fmax = -9.9e36f;
    rmin = memr[*sf + 20];
    rmax = memr[*sf + 20] * 1.5f;
    i__1 = memi[*sf + 30];
    for (i__ = 1; i__ <= i__1; ++i__) {
	sfs = memi[memi[*sf + 31] + i__ - 2];
	if (! (memi[sfs + 3] == 0)) {
	    goto L120;
	}
	goto L110;
L120:
/* Computing MIN */
	r__1 = fmin, r__2 = memr[sfs];
	fmin = min(r__1,r__2);
/* Computing MAX */
	r__1 = fmax, r__2 = memr[sfs];
	fmax = max(r__1,r__2);
/* Computing MIN */
	r__1 = rmin, r__2 = memr[sfs + 1];
	rmin = min(r__1,r__2);
/* Computing MAX */
	r__1 = rmax, r__2 = memr[sfs + 1];
	rmax = max(r__1,r__2);
L110:
	;
    }
/* L111: */
    z__ = fmax - fmin;
    fmin -= z__ * .1f;
    fmax += z__ * .1f;
    z__ = rmax - rmin;
    rmin -= z__ * .1f;
    rmax += z__ * .1f;
    ggview_(&gp, vx, &vx[5], vy, &vy[5]);
    dvx = vx[5] - vx[0];
    dvy = vy[5] - vy[0];
    vx[0] += dvx * 0.f;
    vx[3] = vx[0] + dvx * .2f;
    vx[1] = vx[0] + dvx * .25f;
    if (! (memi[*sf + 32] > 1)) {
	goto L130;
    }
    vx[4] = vx[0] + dvx * .75f;
    vx[2] = vx[0] + dvx * .8f;
    vx[5] = vx[0] + dvx * 1.f;
    goto L131;
L130:
    vx[4] = vx[0] + dvx * 1.f;
    vx[2] = vx[0] + dvx * 1.f;
    vx[5] = vx[0] + dvx * 1.f;
L131:
    vy[0] += dvy * 0.f;
    vy[3] = vy[0] + dvy * .2f;
    vy[1] = vy[0] + dvy * .25f;
    if (! (memi[*sf + 32] > 1)) {
	goto L140;
    }
    vy[4] = vy[0] + dvy * .75f;
    vy[2] = vy[0] + dvy * .8f;
    vy[5] = vy[0] + dvy * 1.f;
    goto L141;
L140:
    vy[4] = vy[0] + dvy * 1.f;
    vy[2] = vy[0] + dvy * 1.f;
    vy[5] = vy[0] + dvy * 1.f;
L141:
    dvx = vx[1] - vx[4];
    dvy = vy[0] - vy[3];
    if (! (abs(dvx) > .01f && abs(dvy) > .01f)) {
	goto L150;
    }
    gseti_(&gp, &c__3, &c__2);
    gseti_(&gp, &c__301, &c__3);
    gseti_(&gp, &c__110, &c__1);
    gseti_(&gp, &c__210, &c__1);
    gseti_(&gp, &c__111, &c__6);
    gseti_(&gp, &c__112, &c__4);
    gseti_(&gp, &c__211, &c__4);
    gseti_(&gp, &c__212, &c__0);
    gsview_(&gp, &vx[1], &vx[4], vy, &vy[3]);
    gswind_(&gp, &c_b389, &c_b896, &c_b389, &c_b896);
    gfill_(&gp, fa, &fa[4], &c__4, &c__2);
    gswind_(&gp, &x1, &x2, &rmin, &rmax);
    glabax_(&gp, st0001, st0002, st0003);
    i__1 = memi[*sf + 30];
    for (i__ = 1; i__ <= i__1; ++i__) {
	sfs = memi[memi[*sf + 31] + i__ - 2];
	if (! (memi[sfs + 3] == 0)) {
	    goto L170;
	}
	goto L160;
L170:
	x = memr[memi[sfs + 6] + 48];
	y = memr[sfs + 1];
	if (! (*key == 1)) {
	    goto L180;
	}
	z__ = sqrt(memr[sfs + 2] / memr[*sf + 21]);
/* Computing MAX */
	r__1 = .005f, r__2 = z__ * .03f;
	z__ = max(r__1,r__2);
	gmark_(&gp, &x, &y, &c__12, &z__, &z__);
L180:
	if (! (memr[sfs] < memr[*sf + 19])) {
	    goto L190;
	}
	gseti_(&gp, &c__16, &c__2);
	goto L191;
L190:
	gseti_(&gp, &c__16, &c__3);
L191:
/* Computing MIN */
	r__1 = 2.f, r__2 = memr[sfs + 1] / rbest;
	z__ = min(r__1,r__2);
	z__ = ((z__ - 1) * 5 + 1) * .01f;
	gmark_(&gp, &x, &y, &c__512, &z__, &z__);
	gseti_(&gp, &c__16, &c__1);
L160:
	;
    }
/* L161: */
    gseti_(&gp, &c__14, &c__2);
    gline_(&gp, &x1, &memr[*sf + 20], &x2, &memr[*sf + 20]);
    gseti_(&gp, &c__14, &c__1);
L150:
    dvx = vx[0] - vx[3];
    dvy = vy[1] - vy[4];
    if (! (abs(dvx) > .01f && abs(dvy) > .01f)) {
	goto L200;
    }
    gseti_(&gp, &c__3, &c__3);
    gseti_(&gp, &c__110, &c__1);
    gseti_(&gp, &c__210, &c__1);
    gseti_(&gp, &c__111, &c__4);
    gseti_(&gp, &c__112, &c__0);
    gseti_(&gp, &c__211, &c__6);
    gseti_(&gp, &c__212, &c__4);
    gsview_(&gp, vx, &vx[3], &vy[1], &vy[4]);
    gswind_(&gp, &c_b389, &c_b896, &c_b389, &c_b896);
    gfill_(&gp, fa, &fa[4], &c__4, &c__2);
    gswind_(&gp, &rmin, &rmax, &y1, &y2);
    glabax_(&gp, st0004, &memc[*sf * 2], st0005);
    i__1 = memi[*sf + 30];
    for (i__ = 1; i__ <= i__1; ++i__) {
	sfs = memi[memi[*sf + 31] + i__ - 2];
	if (! (memi[sfs + 3] == 0)) {
	    goto L220;
	}
	goto L210;
L220:
	x = memr[sfs + 1];
	y = memr[memi[sfs + 6] + 49];
	if (! (*key == 1)) {
	    goto L230;
	}
	z__ = sqrt(memr[sfs + 2] / memr[*sf + 21]);
/* Computing MAX */
	r__1 = .005f, r__2 = z__ * .03f;
	z__ = max(r__1,r__2);
	gmark_(&gp, &x, &y, &c__12, &z__, &z__);
L230:
	if (! (memr[sfs] < memr[*sf + 19])) {
	    goto L240;
	}
	gseti_(&gp, &c__16, &c__2);
	goto L241;
L240:
	gseti_(&gp, &c__16, &c__3);
L241:
/* Computing MIN */
	r__1 = 2.f, r__2 = memr[sfs + 1] / rbest;
	z__ = min(r__1,r__2);
	z__ = ((z__ - 1) * 5 + 1) * .01f;
	gmark_(&gp, &x, &y, &c__512, &z__, &z__);
	gseti_(&gp, &c__16, &c__1);
L210:
	;
    }
/* L211: */
    gseti_(&gp, &c__14, &c__2);
    gline_(&gp, &memr[*sf + 20], &y1, &memr[*sf + 20], &y2);
    gseti_(&gp, &c__14, &c__1);
L200:
    dvx = vx[1] - vx[4];
    dvy = vy[2] - vy[5];
    if (! (abs(dvx) > .01f && abs(dvy) > .01f)) {
	goto L250;
    }
    gseti_(&gp, &c__3, &c__4);
    gseti_(&gp, &c__110, &c__0);
    gseti_(&gp, &c__210, &c__1);
    gseti_(&gp, &c__111, &c__6);
    gseti_(&gp, &c__112, &c__4);
    gseti_(&gp, &c__211, &c__4);
    gseti_(&gp, &c__212, &c__0);
    gsview_(&gp, &vx[1], &vx[4], &vy[2], &vy[5]);
    gswind_(&gp, &c_b389, &c_b896, &c_b389, &c_b896);
    gfill_(&gp, fa, &fa[4], &c__4, &c__2);
    gswind_(&gp, &x1, &x2, &fmin, &fmax);
    glabax_(&gp, st0006, st0007, st0008);
    i__1 = memi[*sf + 30];
    for (i__ = 1; i__ <= i__1; ++i__) {
	sfs = memi[memi[*sf + 31] + i__ - 2];
	if (! (memi[sfs + 3] == 0)) {
	    goto L270;
	}
	goto L260;
L270:
	x = memr[memi[sfs + 6] + 48];
	y = memr[sfs];
	if (! (*key == 1)) {
	    goto L280;
	}
	z__ = sqrt(memr[sfs + 2] / memr[*sf + 21]);
/* Computing MAX */
	r__1 = .005f, r__2 = z__ * .03f;
	z__ = max(r__1,r__2);
	gmark_(&gp, &x, &y, &c__12, &z__, &z__);
L280:
	if (! (memr[sfs] < memr[*sf + 19])) {
	    goto L290;
	}
	gseti_(&gp, &c__16, &c__2);
	goto L291;
L290:
	gseti_(&gp, &c__16, &c__3);
L291:
/* Computing MIN */
	r__1 = 2.f, r__2 = memr[sfs + 1] / rbest;
	z__ = min(r__1,r__2);
	z__ = ((z__ - 1) * 5 + 1) * .01f;
	gmark_(&gp, &x, &y, &c__512, &z__, &z__);
	gseti_(&gp, &c__16, &c__1);
L260:
	;
    }
/* L261: */
    gseti_(&gp, &c__14, &c__2);
    gline_(&gp, &x1, &memr[*sf + 19], &x2, &memr[*sf + 19]);
    gseti_(&gp, &c__14, &c__1);
L250:
    dvx = vx[2] - vx[5];
    dvy = vy[1] - vy[4];
    if (! (abs(dvx) > .01f && abs(dvy) > .01f)) {
	goto L300;
    }
    gseti_(&gp, &c__3, &c__5);
    gseti_(&gp, &c__110, &c__1);
    gseti_(&gp, &c__210, &c__0);
    gseti_(&gp, &c__111, &c__4);
    gseti_(&gp, &c__112, &c__0);
    gseti_(&gp, &c__211, &c__6);
    gseti_(&gp, &c__212, &c__4);
    gsview_(&gp, &vx[2], &vx[5], &vy[1], &vy[4]);
    gswind_(&gp, &c_b389, &c_b896, &c_b389, &c_b896);
    gfill_(&gp, fa, &fa[4], &c__4, &c__2);
    gswind_(&gp, &fmin, &fmax, &y1, &y2);
    glabax_(&gp, st0009, st0010, st0011);
    i__1 = memi[*sf + 30];
    for (i__ = 1; i__ <= i__1; ++i__) {
	sfs = memi[memi[*sf + 31] + i__ - 2];
	if (! (memi[sfs + 3] == 0)) {
	    goto L320;
	}
	goto L310;
L320:
	x = memr[sfs];
	y = memr[memi[sfs + 6] + 49];
	if (! (*key == 1)) {
	    goto L330;
	}
	z__ = sqrt(memr[sfs + 2] / memr[*sf + 21]);
/* Computing MAX */
	r__1 = .005f, r__2 = z__ * .03f;
	z__ = max(r__1,r__2);
	gmark_(&gp, &x, &y, &c__12, &z__, &z__);
L330:
	if (! (memr[sfs] < memr[*sf + 19])) {
	    goto L340;
	}
	gseti_(&gp, &c__16, &c__2);
	goto L341;
L340:
	gseti_(&gp, &c__16, &c__3);
L341:
/* Computing MIN */
	r__1 = 2.f, r__2 = memr[sfs + 1] / rbest;
	z__ = min(r__1,r__2);
	z__ = ((z__ - 1) * 5 + 1) * .01f;
	gmark_(&gp, &x, &y, &c__512, &z__, &z__);
	gseti_(&gp, &c__16, &c__1);
L310:
	;
    }
/* L311: */
    gseti_(&gp, &c__14, &c__2);
    gline_(&gp, &memr[*sf + 19], &y1, &memr[*sf + 19], &y2);
    gseti_(&gp, &c__14, &c__1);
L300:
    gseti_(&gp, &c__3, &c__1);
    gseti_(&gp, &c__301, &c__0);
    gsview_(&gp, vx, &vx[5], vy, &vy[5]);
    glabax_(&gp, &title[1], st0012, st0013);
    dvx = vx[1] - vx[4];
    dvy = vy[1] - vy[4];
    if (! (abs(dvx) > .01f && abs(dvy) > .01f)) {
	goto L350;
    }
    gseti_(&gp, &c__301, &c__3);
    gseti_(&gp, &c__310, &c__0);
    gseti_(&gp, &c__111, &c__6);
    gseti_(&gp, &c__112, &c__4);
    gseti_(&gp, &c__211, &c__6);
    gseti_(&gp, &c__212, &c__4);
    gsview_(&gp, &vx[1], &vx[4], &vy[1], &vy[4]);
    gswind_(&gp, &c_b389, &c_b896, &c_b389, &c_b896);
    gfill_(&gp, fa, &fa[4], &c__4, &c__2);
    gswind_(&gp, &x1, &x2, &y1, &y2);
    glabax_(&gp, st0014, st0015, st0016);
    i__1 = memi[*sf + 30];
    for (i__ = 1; i__ <= i__1; ++i__) {
	sfs = memi[memi[*sf + 31] + i__ - 2];
	if (! (memi[sfs + 3] == 0)) {
	    goto L370;
	}
	goto L360;
L370:
	sfd = memi[sfs + 6];
	x = memr[sfd + 48];
	y = memr[sfd + 49];
	if (! (*key == 1)) {
	    goto L380;
	}
	z__ = sqrt(memr[sfs + 2] / memr[*sf + 21]);
/* Computing MAX */
	r__1 = .005f, r__2 = z__ * .03f;
	z__ = max(r__1,r__2);
	gmark_(&gp, &x, &y, &c__12, &z__, &z__);
L380:
	if (! (memr[sfs] < memr[*sf + 19])) {
	    goto L390;
	}
	gseti_(&gp, &c__16, &c__2);
	goto L391;
L390:
	gseti_(&gp, &c__16, &c__3);
L391:
/* Computing MIN */
	r__1 = 2.f, r__2 = memr[sfs + 1] / rbest;
	z__ = min(r__1,r__2);
	z__ = ((z__ - 1) * 5 + 1) * .01f;
	gmark_(&gp, &x, &y, &c__512, &z__, &z__);
	gseti_(&gp, &c__16, &c__1);
L360:
	;
    }
/* L361: */
L350:
/* L100: */
    zzepro_();
    return 0;
} /* stfg12_ */

#undef memx
#undef mems
#undef memr
#undef meml
#undef memi
#undef memc
#undef memb


