/*----------------------------------------------------------------------------*/
/*                                                                            */
/*                     Instituto de Astrofisica de Canarias                   */
/*                             Software Department                            */
/*                                                                            */
/*                               Proyecto LIRIS                               */
/*----------------------------------------------------------------------------*/


/*- start of module header information -----------------------------------------

COMPONENT:

   rtdfile.h


HISTORY:

   Version   Author    Description

   1.1       H.Moreno  Original Code


TYPE:

   C include file


PURPOSE:

   It holds function declarations for rtdfile.c module


PORTABILITY:

   ANSI-C


DESCRIPTION:



--- End of module header information -----------------------------------------*/


#if !defined( RTD_FILE_H )
#define RTD_FILE_H


/*- Feature test switches ----------------------------------------------------*/
/*- Headers required by this header ------------------------------------------*/

#include "portable.h"      /* provides implementation-dependent definitions */
#include "global.h"

/*- Exported Macros ----------------------------------------------------------*/





/*- Local typedefs, structures and unions ------------------------------------*/
/*- Exported typedefs, structures and unions ---------------------------------*/
/*- Exported data ------------------------------------------------------------*/
/*- Exported functions  ------------------------------------------------------*/


/*--------------------------------------------------------------------*/
/* Function name : file_is_liris                                      */
/*                                                                    */
/* Passed        : p_file_to_check - pointer to pathname of file to   */
/*                                   test for LIRIS fits compliance.  */
/*                                                                    */
/* Returned      : int = 0  - Yes : file is liris fits format         */
/*                     = -1 - No  : invalid filename                  */
/*                     = -2 - No  : couldn't access file              */
/*                     = -3 - No  : not a Unix REGULAR file           */
/*                     = -4 - No  : file too small                    */
/*                     = -5 - No  : couldn't open file                */
/*                     = -6 - No  : missing 'DETECTOR' header         */
/*                     = -7 - No  : 'DETECTOR' header not 'LIRIS' nor */
/*                                   'INGRID'                         */
/*                     = -8 - No  : missing 'STORMODE' header         */
/*                     = -9 - No  : 'STORMODE' header value not valid */
/*                     = -10 - No : missing  'SATURATE' header        */
/*                     = -11 - No : missing  'MAXBIAS' header         */
/*                     = -12 - No : missing  'LINEARLM' header        */
/*                     = -13 - No : no seeing related keywords        */
/*                     = -14 - No : couldn't close file               */
/*                                                                    */
/* Description   : Check specified file to see whether it is LIRIS    */
/*                 compatible.                                        */
/*                                                                    */
/* "Compatible" means:                                                */
/*                                                                    */
/*    1/ The filename ends in ".fit".                                 */
/*    2/ The file is a Unix REGULAR file.                             */
/*    3/ The file must be above a certain minimum size.               */
/*    4/ The file contains the 'DETECTOR' keyword with the value      */
/*       field set to "LIRIS" or "INGRID.                             */
/*    5/ The file contains the 'STORMODE' keyword with a valid value  */
/*       field set to one of the following values:                    */
/*        DIFF, DIFF_PRE, NORMAL (for PRE_POST), SLOPE, SLOPE_READS   */
/*    6/ The file contains LINEARLM, SATURATE and MAXBIAS headers     */
/*                                                                    */
/*--------------------------------------------------------------------*/
int file_is_liris( const char *p_file_to_check );



/*--------------------------------------------------------------------*/
/* Function name : file_read_liris                                    */
/*                                                                    */
/* Passed        : p_filename    - pathname to FITS file              */
/*                 p_diff_buf    - area for storing diff data         */
/*                 p_pre_buf     - area for storing pre-int data      */
/*                 p_post_buff   - area for storing post-int data     */
/*                 p_slope_buf   - area for storing slope data        */
/*                 p_first_ramp_buf - area for storing first read-up  */
/*                                    the ramp data                   */
/*                 p_last_ramp_buf  - area for storing last read-up   */
/*                                    the ramp.                       */
/*                                                                    */
/* Returned      : int =  0 - Success                                 */
/*                  = -1 - Error : couldn't open file		      */
/*                  = -2 - Error : invalid number of windows	      */
/*                  = -3 - Error : invalid number of hdu's	      */
/*                  = -4 - Error : invalid number of reads	      */
/*                  = -5 - Error : couldn't seek to 1st ext. data     */
/*                  = -6 - Error : couldn't read diff. data	      */
/*                  = -7 - Error : couldn't read pre-int data	      */
/*                  = -8 - Error : couldn't read slope data	      */
/*                  = -9 - Error : couldn't seek to ext. data	      */
/*                  = -10 - Error : couldn't read post-int data       */
/*                  = -11 - Error : couldn't read first ramp data     */
/*                  = -12 - Error : couldn't seak to last ramp data   */
/*                  = -13 - Error : couldn't read last ramp data      */
/*                  = -14 - Error : couldn't close file 	      */
/*                                                                    */
/*                 (Errors -4 to -13 result in possible corruption    */
/*                  of the data previously existing in the supplied   */
/*                  data buffers)                                     */
/*                                                                    */
/* Description   : Read image data from LIRIS FITS file into the      */
/*                 supplied data buffers. Not all data buffers may    */
/*                 be supplied this would depend on the STORMODE.     */  
/*                 Any pixels that are not loaded are flagged         */
/*                 with the special value PIXEL_NOT_LOADED.           */ 
/*                 The relation data buffers content with 'STORMODE'  */
/*                 keyword is as follows.                             */
/*                                                                    */
/*  FOR MNDR observation mode:                                        */
/*      'STORMODE'     p_diff_buf     p_pre_buf     p_post_buf        */
/*      							      */
/*        DIFF         diff data	-----	       -----	      */
/*      DIFF_PRE       diff data     pre-int data      -----	      */
/*      PRE_POST	 -----       pre-int data    post-int data    */
/*                                                                    */
/*  FOR RAMP observation mode:                                        */
/*     'STORMODE'   p_slope_buf   p_first_ramp_buf  p_last_ramp_buf   */
/*                                                                    */
/*       SLOPE       slope data       -----            ------         */
/*     SLOPE_READS   slope data    first read         last_read       */
/*                                                                    */
/*--------------------------------------------------------------------*/

int file_read_liris( const char *p_filename, 
                      Pixel *p_diff_buf ,
                      Pixel *p_pre_buf ,
		      Pixel *p_post_buf,
		      Pixel *p_slope_buf,		      
		      Pixel *p_first_ramp_buf,
		      Pixel *p_last_ramp_buf);


/*--------------------------------------------------------------------*/
/* Function name : file_write_liris                                   */
/*                                                                    */
/* Passed        : p_filename     - pathname to FITS file to create   */
/*                 p_pre_int_buf  - pre-int data to be written        */
/*                 p_post_int_buf - post-int data to be written       */
/*                                                                    */
/* Returned      : int =  0 - Success                                 */
/*                     = -1 - Error : couldn't open file              */
/*                     = -2 - Error : couldn't create primary HDU     */
/*                     = -3 - Error : couldn't create DETECTOR header */
/*                     = -4 - Error : couldn't create pre-int HDU     */
/*                     = -5 - Error : couldn't write pre-int image    */
/*                     = -6 - Error : couldn't create post-int HDU    */
/*                     = -7 - Error : couldn't write post-int image   */
/*                     = -8 - Error : couldn't close file             */
/*                                                                    */
/* Description   : Write supplied image data to new INGRID FITS file  */
/*                                                                    */
/* This routine may be customised for test purposes. It is only       */
/* required by 'rtdtest.c'. Currently (5/12/00) it has been set up    */
/* to write the supplied data twice into two separate windows within  */
/* the file. The window sections are:                                 */
/*                                                                    */
/*    [100:600,200:399] and [300:899,600:799]                         */
/*                                                                    */
/*--------------------------------------------------------------------*/

int file_write_liris( const char  *p_filename, 
                       const Pixel *p_pre_int_buf,
                       const Pixel *p_post_int_buf );

#endif



