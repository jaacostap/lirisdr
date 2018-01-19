/* x_liris.x -- translated by f2c (version 19990503).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Common Block Declarations */

struct {
    logical xerflg, xerpad[84];
} xercom_;

#define xercom_1 xercom_

/* Table of constant values */

static integer c__4 = 4;
static integer c__1 = 1;
static integer c__0 = 0;

integer sysruk_(shortint *task, shortint *cmd, integer *rukarf, integer *
	rukint)
{
    /* Initialized data */

    static shortint dict[21] = { 112,115,102,109,101,97,115,117,114,101,0,115,
	    116,97,114,102,111,99,117,115,0 };
    static shortint st0009[29] = { 105,110,118,97,108,105,100,32,115,101,116,
	    32,115,116,97,116,101,109,101,110,116,58,32,39,37,115,39,10,0 };
    static shortint st0010[25] = { 105,110,118,97,108,105,100,32,83,69,84,32,
	    105,110,32,73,82,65,70,32,77,97,105,110,0 };
    static integer dp[3] = { 1,12,0 };
    static integer lmarg = 5;
    static integer maxch = 0;
    static integer ncol = 0;
    static integer rukean = 3;
    static integer ntasks = 0;
    static shortint st0001[9] = { 116,116,121,110,99,111,108,115,0 };
    static shortint st0002[6] = { 99,104,100,105,114,0 };
    static shortint st0003[3] = { 99,100,0 };
    static shortint st0004[6] = { 104,111,109,101,36,0 };
    static shortint st0005[6] = { 72,79,77,69,36,0 };
    static shortint st0006[4] = { 115,101,116,0 };
    static shortint st0007[6] = { 114,101,115,101,116,0 };
    static shortint st0008[2] = { 9,0 };

    /* System generated locals */
    integer ret_val;

    /* Local variables */
    static integer i__, rmarg;
    extern logical streq_(shortint *, shortint *);
    extern integer envgei_(shortint *);
    extern /* Subroutine */ int xfchdr_(shortint *), erract_(integer *), 
	    eprinf_(shortint *);
    extern integer envscn_(shortint *);
    extern /* Subroutine */ int xffluh_(integer *), pargsr_(shortint *), 
	    tpsfme_(void), envlit_(integer *, shortint *, integer *), syspac_(
	    integer *, shortint *), xerpsh_(void), strtbl_(integer *, 
	    shortint *, integer *, integer *, integer *, integer *, integer *,
	     integer *);
    extern logical xerpop_(void);
    extern /* Subroutine */ int tstars_(void), zzepro_(void);

    /* Parameter adjustments */
    --cmd;
    --task;

    /* Function Body */
    if (! (ntasks == 0)) {
	goto L110;
    }
    i__ = 1;
L120:
    if (! (dp[i__ - 1] != 0)) {
	goto L122;
    }
/* L121: */
    ++i__;
    goto L120;
L122:
    ntasks = i__ - 1;
L110:
    if (! (task[1] == 63)) {
	goto L130;
    }
    xerpsh_();
    rmarg = envgei_(st0001);
    if (! xerpop_()) {
	goto L140;
    }
    rmarg = 80;
L140:
    strtbl_(&c__4, dict, dp, &ntasks, &lmarg, &rmarg, &maxch, &ncol);
    ret_val = 0;
    goto L100;
L130:
    if (! (streq_(&task[1], st0002) || streq_(&task[1], st0003))) {
	goto L150;
    }
    xerpsh_();
    if (! (cmd[*rukarf] == 0)) {
	goto L170;
    }
    xerpsh_();
    xfchdr_(st0004);
    if (! xerpop_()) {
	goto L180;
    }
    xfchdr_(st0005);
L180:
    goto L171;
L170:
    xfchdr_(&cmd[*rukarf]);
L171:
/* L162: */
    if (! xerpop_()) {
	goto L160;
    }
    if (! (*rukint == 1)) {
	goto L190;
    }
    erract_(&rukean);
    if (xercom_1.xerflg) {
	goto L100;
    }
    goto L191;
L190:
L191:
L160:
    ret_val = 0;
    goto L100;
L150:
    if (! (streq_(&task[1], st0006) || streq_(&task[1], st0007))) {
	goto L200;
    }
    xerpsh_();
    if (! (cmd[*rukarf] == 0)) {
	goto L220;
    }
    envlit_(&c__4, st0008, &c__1);
    xffluh_(&c__4);
    goto L221;
L220:
    if (! (envscn_(&cmd[1]) <= 0)) {
	goto L230;
    }
    if (! (*rukint == 1)) {
	goto L240;
    }
    eprinf_(st0009);
    pargsr_(&cmd[1]);
    goto L241;
L240:
    goto L91;
L241:
L230:
L221:
/* L212: */
    if (! xerpop_()) {
	goto L210;
    }
    if (! (*rukint == 1)) {
	goto L250;
    }
    erract_(&rukean);
    if (xercom_1.xerflg) {
	goto L100;
    }
    goto L251;
L250:
L91:
    syspac_(&c__0, st0010);
L251:
L210:
    ret_val = 0;
    goto L100;
L200:
/* L151: */
/* L131: */
    if (! streq_(&task[1], &dict[dp[0] - 1])) {
	goto L260;
    }
    tpsfme_();
    ret_val = 0;
    goto L100;
L260:
    if (! streq_(&task[1], &dict[dp[1] - 1])) {
	goto L270;
    }
    tstars_();
    ret_val = 0;
    goto L100;
L270:
    ret_val = -1;
    goto L100;
L100:
    zzepro_();
    return ret_val;
} /* sysruk_ */

