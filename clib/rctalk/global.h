/*----------------------------------------------------------------------------*/
/*                                                                            */
/*                     Instituto de Astrofisica de Canarias                   */
/*                             Software Department                            */
/*                                                                            */
/*                               Proyecto LIRIS                               */
/*----------------------------------------------------------------------------*/

/*- start of module header information -----------------------------------------


COMPONENT:

   global.h


HISTORY:

   Version  Date     Author      Description

   1.1               J Acosta    Original code.


TYPE:

   C include file


PURPOSE:

   RTD-wide facility for constant definitions


PORTABILITY:

   ANSI-C


DESCRIPTION:

   This file contains definitions used by most RTD modules


--- End of module header information -----------------------------------------*/

#if !defined(GLOBAL_H )
#define GLOBAL_H

/*- Feature test switches ----------------------------------------------------*/
/*- Headers required by this header ------------------------------------------*/

#include "portable.h"      /* provides implementation-dependent definitions */


/* define valid LIRIS store modes */
enum  {DIFF =1, DIFF_PRE, PRE_POST, SLOPE, SLOPE_READS};

#define XDETPIX 1024
#define YDETPIX 1024
#define DETECTOR_NUM_PIXELS      ( XDETPIX * YDETPIX ) 
#define PIXEL_BUF_SIZE           ( DETECTOR_NUM_PIXELS )

#define CDL_XDETPIX  1024
#define CDL_YDETPIX  1024
#define SCALEPIX     0.25
#define DATAMAX      20000
#define GAIN         3.6


/* FITS keywords */
#define KEYWD_NAXIS3   "NAXIS3"
#define KEYWD_RDMOD    "READMODE"
#define KEYWD_FILTER1  "LIRF1POS"
#define KEYWD_FILTER2  "LIRF2POS"
#define KEYWD_EXPTIME  "EXPTIME"
#define KEYWD_AIRMASS  "AIRMASS"
#define KEYWD_MJD      "MJD-OBS"
#define KEYWD_RUN      "RUN"

/* seeing calculations constants */                    
#define RMIN          2.0
#define GAUSS_SUMG    0
#define GAUSS_SUMGSQ  1
#define GAUSS_PIXELS  2
#define GAUSS_DENOM   3
#define GAUSS_SGOP    4
#define GAUSS_NELE    5
#define MAXNBUF       40       /* Maximum size of buffer    */
#define OBJMINSEP     3.0      /* minimum separation for detected objects 
				  in unitsof FWHM_PSF/2 */
#define NSIGMA        2.0      /* limit of convolution kernel  */
#define THRESHOLD     20.0     /* Detection threshold above background noise */				
#define ROUNDLOW      0.0      /* Minimum ellipticity of detected objects    */				
#define ROUNDHIGH     0.3      /* Maximum ellipticity of detected objects    */				
#define SHARPLOW      0.5      /* Minimum sharpness of detected objects      */				
#define SHARPHIGH     0.9      /* Maximum sharpness of detected objects      */				
#define NPIXMIN	      5	       /* Minimum area occupied by detected objects  */				 


#define FWHM          2.3      /* sigma of gaussian in x       */
#define THETA         0.0      /* position angle of Gaussian   */
#define RATIO 	      1.0      /* ratio of half-width in y to x 
                                            (1. for round PSF) */
#define FWHM_TO_SIGMA 0.42467  /* conversion factor */
#define ARRAY_ZONE     0.8     /*  fraction of array to be used */ 

#define XDETPIX_CONV (XDETPIX * ARRAY_ZONE)
#define YDETPIX_CONV (YDETPIX * ARRAY_ZONE)




/*------------------------------------------------------------------*/
/* Enable one of the following definitions to determine the         */
/* processing of data in the RTD. Both these definitions should     */
/* work ok. The code should be optimised for speed.                 */
/*------------------------------------------------------------------*/

/* Currently (06/08/00) floats have been selected */

#define  PIXELS_ARE_FLOATS
#undef   PIXELS_ARE_UNSIGNED_INTEGERS


/*- Local typedefs, structures and unions ------------------------------------*/
/*- Exported typedefs, structures and unions ---------------------------------*/

/*------------------------------------------------------------------*/
/* The following provides an application-wide definition for the    */
/* Pixel type.                                                      */
/*------------------------------------------------------------------*/

#if defined ( PIXELS_ARE_UNSIGNED_INTEGERS ) 
typedef Word16   Pixel;
#endif


#if defined ( PIXELS_ARE_FLOATS )
typedef Float32  Pixel;
#endif


/* Regardless of what windows are defined, file_read_ingrid() always returns */
/* a buffer of size XDETPIX by YDETPIX. The      */
/* following value is used to flag entries within the buffer which do not    */
/* map onto any active areas of the detector. They may then be excluded from */
/* the autoscale function. The value chosen must be outside the normal data  */
/* range.                                                                    */                                     

#if defined ( PIXELS_ARE_UNSIGNED_INTEGERS ) 
#define PIXEL_NOT_LOADED  54321
#endif


#if defined ( PIXELS_ARE_FLOATS )
#define PIXEL_NOT_LOADED  -999999.0
#endif

typedef Pixel   PixelBuffer[ PIXEL_BUF_SIZE ];


#endif

#define DETECTOR_LIRIS          1
#define DETECTOR_INGRID         2
#define COMMUNICATION_ON        1
#define COMMUNICATION_OFF       0


/*------------------------------------------------------------------*/
/* Enable one of the following definitions to determine the         */
/* processing seeing calculations. The seeing code needs to be      */
/* reviewed. During the feb2003 commisioning did not work and MUST  */
/* be carefully walkthroug it for the new data format               */
/*------------------------------------------------------------------*/
/* Currently (MAY29, 2003) seeing calculations are not performed */
#undef SEEING_CODE_ACTIVE
#define SEEING_CODE_NOT_ACTIVE

/* anadido por mcharcos */
/* Use of CENT library for centre star determitation*/
#define CENT_CODE_ACTIVE
#undef CENT_CODE_NOT_ACTIVE
/* fin de anadido por mcharcos */

/*  time elapsed since last calculation of seeing and background values */
#define  SEEING_SHEDULE_UPDATE  60  /* secs */
