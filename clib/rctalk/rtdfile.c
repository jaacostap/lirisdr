/*----------------------------------------------------------------------------*/
/*                                                                            */
/*                     Isaac Newton Group of Telescopes                       */
/*                    Roque de los Muchachos Observatory                      */
/*                               La Palma                                     */
/*                                                                            */
/*                          Copyright PPARC 2000                              */
/*----------------------------------------------------------------------------*/

/*- start of module header information -----------------------------------------

COMPONENT:
   $Id: rtdfile.c$

HISTORY:
  $Log: $ 
  
   Version  Date    Author    Description

   1.1      030318 H Moreno   Addapted for LIRIS from INGRID code			      
            031105 H Moreno   Initialize  to DEFAULT_VALS all buffers
	    031111 H Moreno   Fix bug mapping images index

TYPE:

   C source file


PURPOSE:

   FILE module for Real Time Display

   This module provides routines to:
   
      a/  check target files for LIRIS compatibility.
      b/  to build pre, post and/or diff data sets.
      c/  to build slope, first ramp and last ramp data sets.


   This module has been designed:
   
   1/  To correctly process files compliant with the document
       INS-DAS-26 "Observation files produced by ULTRADAS" 
       Issue 2.2.

       See also document INS-DAS-26: URD for ULTRADAS


   2/  To reject any files incompatible with the format
       described in the above document.  In particular
       LIRIS Standalone files will be rejected.
       

PORTABILITY:

   POSIX-1 (can't be ANSI-C as it makes use of various calls
            associated with the operating system file system)

   This module requires that the CFITSIO library is available
   at BUILD time.

   Version 2.0.32 of CFITSIO definitely WON'T work with this module
   as it doesn't contain all the functions used in this module.

   Version 2.0.36 of CFITSIO definitely WILL work. 
   Version 2.420 of CFITSIO at iac. 

  
DESCRIPTION:

   This file provides support for reading, writing and verifying
   ULTRADAS-style LIRIS FITS data files.

   It does so by means of a 3rd party library (CFITSIO) provided by
   the NOAO.


   1.  Module Interface
       ----------------

        |
        | file_is_liris()
        | file_read_liris()
        | file_write_liris()
        |
     ________________________ 
    |                         |
    |    RTD FILE MODULE      |
    |                         |
    |_________________________|


      file_is_liris()    - checks user specified file for LIRIS
                            compatibility.

      file_read_liris()  - parses the file to extract or build the pre,  
                           post and diff data sets.                   

      file_write_liris() - is used by the RTD test program to write
                           an LIRIS-compatible test file.
      


   2.  Compatibility Test         
       ------------------
  
   The current rules for the LIRIS compatibility test are as follows:

      a/ the file must be a Unix REGULAR file.
      b/ the filename must terminate in ".fit".
      c/ the file must be above a certain mimimum size.
      d/ the file must contain the DETECTOR header set to 'LIRIS'or 'INGRID'.


   3.  Expected File Format         
       --------------------

   Unlike the previous release, this module now provides
   support for reading LIRIS ULTRADAS FITS files generated 
   using the following observational modes:

       MNDR with storage modes DIFF, DIFF_PRE, PRE_POST
       Read-up-Ramp with stroage modes SLOPE, SLOPE_READS

   All these modes are supported for files generated both 
   with and without windowing.
                                                 
   The expected LIRIS file format is as follows:                  
                                                                     
      <FITS_File> = <Primary_Header>  +  <Primary_data>  +     
                    <ImgExt1_Header>  +  <ImgExt1_Data>  +     
                    <ImgExt1_Header>  +  <ImgExt1_Data>  +     
                       ..........     +    ..........    +
                    <ImgExtN_Header>  +  <ImgExtN_Data>  +     

   Where
   -----
                                                                     
   <Primary_Header> is the header unit in the primary HDU.
                    This unit is expected to contain the
                    'DETECTOR' keyword which must be set to 
                    'LIRIS'.
                     
   <Primary_Data>   is the data unit in the primary HDU.
                    For LIRIS UTRADAS FITS files this unit 
                    will be empty.

   <ImgExtN_Header> is the header unit in the Nth FITS image 
                    extension HDU.
           
   <ImgExtN_Data>   is the data unit in the Nth FITS image
                    extension HDU. 
                    

   The contents of the individual image extension data units 
   depends on  the observational modes and their associated 
   storages modes . The mapping for LIRIS is as follows:
   

   Observe  Store   Windowing Disabled    Windows Enabled
   Mode     Mode    Ext   Contents        Ext         Contents  
                                             				  
						  
   MNDR    DIFF_PRE  1 diff of avg	 1 to W	   difference of the average 			  
       		       of N post-int               of the N post-int reads
		       reads minus avg             data minus the avg of the N 
		       of N pre-int reads          pre-int reads data for 
                                                   windows 1 to W
						   
                     2 avg of N	         W+1 to 2W avg of N pret-int reads
                       pre-int reads  	           for windows 1 to W							   

						   
   MNDR    DIFF	     1 diff of avg	 1 to W	   difference of the average 			  
       		       of N post-int               of the N post-int reads
		       reads minus avg             minus the avg of the N 
		       of N pre-int reads          pre-int reads for windows
                                                   1 to W					   

                                   
   MNDR    PRE_POST  1 avg of N          1 to W    avg of N pre-int reads    
                       pre-int reads               for windows 1 to W         
                                                                     
                     2  avg of N	 W+1 to 2W avg of N post-int reads
                        post-int reads  	   for windows 1 to W	
			 

                	       
   Read-up SLOPE_READS 1  slope    	1 to W     slopes for windows 1 to W
   -Ramp        	
                       2  read 1  	W+1 to 2W  read 1 for windows 1 to W 
		           
                       3  read 2  	2W+1 to 3W read 2 for windows 1 to W 
                	       
                       4  read 3        3W+1 to 4W read 3 for windows 1 to W
                	       
                       N  read N-1  	(N-1)*W+1  read N-1 for windows 1 to W 
                                         to NW 
                       N+1 read N  	(N)*W+1    read N for windows 1 to W 
                                         to (N+1)W 
					 
   Read-up  SLOPE      1 slope 	         1 to W	   slopes for windows 1 to W 			  
   -Ramp 	     
					 					     
                                  

   Regardless of observational mode the file_read_lafiris() function in
   this module always processes the specified fits file to return three 
   data buffers of size 1024 x 1024 pixels. Thre is an exception for the 
   SLOPE_READS mode where an extra data set is created for the slope. 

   The data buffers contains processed the following data   

   Windowing Disabled
   ------------------
   
   For MNDR and Coavg with STOREMODE DIFF:
   
      The first data buffer contains the diff data which comes from the
      dataset in the FIRST image extension. 
      
      The second data buffer contains Zeroes   
      
      The third data buffer contains Zeroes
      
   For MNDR and Coavg with STOREMODE DIFF_PRE:

      The first data buffer contains the diff data which comes from the
      dataset in the FIRST image extension.
      
      The second data buffer contains pre-int data which comes from the
      SECOND image extension.
      
      The third data buffer contains post_int data which comes from adding
      the contents of the FIRST data buffer with the contents of the SECOND
      data buffer.
      
      
   For MNDR and Coavg with STOREMODE PRE_POST:
   
      The first data buffer contains diff data which comes from subtracting
      the contents of the THIRD data buffer minus the contents of the 
      SECOND data buffer.   

      The second data buffer contains pre-int data which comes from the
      dataset in the FIRST image extension.
      
      The third data buffer contains post-int data which comes from the
      SECOND image extension.
            

   For Read-up-Ramp with STOREMODE SLOPE:

      The first data buffer contains the slope data which comes from the
      dataset in the FIRST image extension.
      
      The second data buffer contains zeroes.
      
      The third data buffer contains zeroes.
      
      
   For Read-up-Ramp with STOREMODE SLOPE_READS: 
      

      A first data buffer will contain the slope data which comes from the  
      FIRST image extension.
            
      The second data buffer contains the first read which comes from 
      the SECOND image extension.
      
      The third data buffer contains the last read which comes from the N+1
      image extension.
      
      The fourth data buffer contains the diff data which comes from 
      substracting the last read - the first read (the data set in the N+1
      extension minus the data set in the 2nd image extension)
      
      
       
   Windowing Enabled
   -----------------
   
   When windowing is enabled the number of image extensions present in the 
   final FITS file is multiplied by the number of windows present. 
   
   The data in each image extension needs to be located correctly within 
   the returned 1024 x 1024  data buffers. Currently (2/8/00) this is 
   achieved by looking at the WINSECx headers which must be present 
   in the primary HDU.
   
   For MNDR and Coavg with STOREMODE DIFF:
   
      The first data buffer contains the diff data which comes from the
      datasets in the FIRST W image extensions. 
      
      The second data buffer contains Zeroes   
      
      The third data buffer contains Zeroes 
      
   For MNDR and Coavg with STOREMODE DIFF_PRE:

      The first data buffer contains the diff data which comes from the
      datasets in the FIRST W image extensions. 
      
      The second data buffer contains pre-int data which comes from the
      SECOND W image extensions. 
      
      The third data buffer contains post_int data which comes from adding
      the contents of the FIRST data buffer with the contents of the 
      SECOND data buffer.     

   For MNDR and Coavg with STOREMODE PRE_POST:
   
      The first data buffer contains diff data which comes from subtracting
      the contents of the THIRD data buffer minus the contents of the 
      SECOND data buffer.   

      The second data buffer contains pre-int data which comes from the
      dataset in the FIRST W image extensions. 
      
      The third data buffer contains post-int data which comes from the
      datasets in the SECOND W image extensions.          

   For Read-up-Ramp with STOREMODE SLOPE:

      The first data buffer contains the slope data which comes from the
      datasets in the FIRST W image extensions. 
      
      The second data buffer contains zeroes.
      
      The third data buffer contains zeroes.
      
      
  For Read-up-Ramp with STOREMODE SLOPE_READS: 
      
      A first data buffer will contain the slope data which comes from the  
      datasets in the FIRST W image extensions.
     
      The second data buffer contains the first read which comes from 
      the datasets in the SECOND W image extensions.
      
      The third data buffer contains the last read which comes from 
      the datasets in the N+1 W image extensions.      
      
      The fouth data buffer contains the diff data which comes from 
      substracting the third data buffer minus the second data buffer      

   4.  Software Environment         
       --------------------

   The software environment in which this module operates is illustrated
   below:


          |
          | file_xxxx_() - see Module Interface above
          |
       ______________________
      |                      |
      |   RTD FILE module    |   <<<<<<<<<  This module !
      |                      |
      |______________________|
          |         
          | fits_open_file()           
          | fits_close_file()           
          | fits_report_error()           
          | fits_movabs_hdu()          
          | fits_read_img()          
          | fits_create_file()   (*)
          | fits_write_key()     (*)
          | fits_create_img()    (*)
          | 
       ___|_____________________ 
      |                         |
      |     CFITSIO Library     |
      |                         |
      |_________________________|

   (*) only required for writing test files.


   The CFITSIO library is a 3rd party library provided by NOAO
   that wraps up the potentially fiddly details of parsing
   FITS style files into a set of routines more usable by software 
   developers. 


   Note
   ----  
          
   With ULTRADAS, file sizes vary so it is necessary to read the 
   'DETECTOR' header to determine LIRIS compatibility. With
   STANDALONE the size of the file was fixed and considered sufficiently
   unique to ensure LIRIS validity.

   Additionally, ULTRADAS files store their data in separate FITS
   extensions (see above) which need to be parsed.
          
          

--- End of module header information -----------------------------------------*/

/*- Feature test switches ----------------------------------------------------*/

/* Code Developers: enable the following definition to */
/* turn on debugging messages from this module.        */

#undef RTD_FILE_DEBUG


/*- System headers -----------------------------------------------------------*/

#include <stdio.h>         /* required for printf() func    */        
#include <sys/stat.h>      /* contains stat function        */
#include <string.h>        /* required for strlen function  */


/*- Local headers ------------------------------------------------------------*/

#include "global.h"
#include "rtdseeing.h"     /* for fun get_seeing_keywords()          */
#include "fitsio.h"        /* interface to 3rd party CFITSIO library */
                           /* see Makefile for linkage details.      */


/*- Local macros -------------------------------------------------------------*/

/*------------------------------------------------------------------*/
/* The following constants define various parameters associated     */
/* with the LIRIS FITS file format.                                 */
/*------------------------------------------------------------------*/

/* LIRIS_FILE_MIN_SIZE is used by the file_is_liris() function      */
/* to test whether a file is LIRIS compatible. Files smaller than   */
/* the value set here (in bytes) will be rejected.                  */
/*                                                                  */
/* Currently (05/20/03) the value has been chosen such that a file  */
/* must contain at least two FITS HDU's. The minimum HDU size is    */
/* 2880 bytes.                                                      */

#define LIRIS_FILE_MIN_SIZE          (2 * 2880) 


/* LIRIS_FILE_MAX_WINDOWS defines the maximum number of windows   */
/* allowed in an liris file. If the number present exceeds the    */
/* number set here liris_read_file() will fail.                   */

#define LIRIS_FILE_MAX_WINDOWS       5


/* LIRIS_FILE_NAXIS determines the number of data axes present */
/* each FITS image extension.                                  */
#define LIRIS_FILE_NAXIS             2


/* LIRIS_FILE_MAX_IMAGE_SIZE defines the maximum number of pixels  */
/* expected in any one FITS image extension. This is used in       */
/* allocating storage space for pixel data read from the file.     */
/* Normally, this would not be greater than the LIRIS array size,  */
/* but if some ridiculously large window was set up by the user    */
/* it could be greater.                                            */

/* Currently (07/08/00) arbitrarily set to double the size of the  */ 
/* pixel buffer.                                                   */

#define LIRIS_FILE_MAX_IMAGE_SIZE    (PIXEL_BUF_SIZE * 2)



/* The following definitions specify the type of image data to be   */ 
/* read from the LIRIS FITS file. Only one of the following         */
/* definitions should be enabled.                                   */

/* Currently (07/08/00) set to expect 32-bit Real */

#define LIRIS_FILE_IMG_DATA_IS_REAL32
#undef  LIRIS_FILE_IMG_DATA_IS_UINT16


/*- Local typedefs, structures and unions ------------------------------------*/

#if defined ( LIRIS_FILE_IMG_DATA_IS_REAL32 )

/* The following definition determines the storage type used to  */
/* hold data read from FITS file image extensions. If the file   */
/* contains 32-bit reals this is mapped onto the Float32 data    */
/* type (see portable.h) for implementation-specific definition. */

typedef Float32  FITSPixel;


/* CFITSIO_IMG_DATA_TYPE defines the type of image data to be    */ 
/* read from the LIRIS FITS file. In the case of 32-bit reals    */
/* this maps onto the CFITSIO definition TFLOAT.                 */

#define CFITSIO_IMG_DATA_TYPE         TFLOAT


/* CFITSIO_BITPIX is also used by the CFITSIO library in */
/* interfacing to LIRIS FITS data files. In the case of */
/* 32-bit reals this maps onto the CFITSIO definition    */
/* FLOAT_IMG.                                            */

#define CFITSIO_BITPIX                FLOAT_IMG

#endif


#if defined ( LIRIS_FILE_IMG_DATA_IS_UINT16 ) 

/* The following definition determines the storage type used to  */
/* hold data read from FITS file image extensions. If the file   */
/* contains 16-bit unsigned integers this is mapped onto the     */
/* Word16 type (see portable.h) for implementation-specific      */
/* definition.                                                   */

typedef Word16   FITSPixel;


/* CFITSIO_IMG_DATA_TYPE defines the type of image data to be     */ 
/* read from the LIRIS FITS file. If the file contains 16-bit    */
/* unsigned integers this maps onto the CFITSIO definition TUINT. */

#define CFITSIO_IMG_DATA_TYPE         TUINT


/* CFITSIO_BITPIX is also used by the CFITSIO library in */
/* interfacing to LIRIS FITS data files. If the file    */
/* contains 16-bit unsigned integers this maps onto the  */
/* CFITSIO definition SHORT_IMG.                         */

#define CFITSIO_BITPIX                SHORT_IMG

#endif


/* The following typedef is used to describe how an array of   */
/* data read from a FITS image extension fits into the overall */
/* composite image. eg (1, 20, 1, 20) would describe an array  */
/* of data of 200 pixels located at the extreme lower left     */
/* corner of the composite image.                              */
/* NO ENTIENDO COMO RESULTA EN 200 pixels */
typedef struct {
   int x1, x2;    /* pixel range in X  going from 1.. upwards */
   int y1, y2;    /* pixel range in Y, going from 1.. upwards */
} RegionDescriptor;


/* The following typedef is used to hold pixel data read from */
/* a FITS image extension. The buffer size needs to be big    */
/* enough to hold the maximum number of pixels likely to be   */
/* encountered in any LIRIS FITS file image extension.       */                     

typedef FITSPixel FITSPixelData[ LIRIS_FILE_MAX_IMAGE_SIZE ];


/* The following typedef provides a data structure for holding */
/* important information read from FITS image extension. The   */                
/* information in this data structure allows the data to be    */
/* stitched back into the overall composite image.             */

typedef struct {
  RegionDescriptor region_descriptor;
  FITSPixelData    fits_pixel_data; 
} ImgExtData;
       

/*- External imported data --------------------------------------------------*/
/*- comentado mcharcos 
extern  short int G_seeing_display;  fin comentado mcharcos */ /* Comunication with seeing display   */
extern  short int G_camera;           /* Defined in rtd.c */

/*- Local data ---------------------------------------------------------------*/
/*- Local function prototypes ------------------------------------------------*/

static int  check_lirsmode( const char *p_key_value);
static int  validate_nunfits_extensions( int num_extensions,int num_windows);
static void initialize_data_buffers(Pixel *p_diff_buf, Pixel *p_pre_buf ,
		                   Pixel *p_post_buf, Pixel *p_slope_buf,		      
		        Pixel *p_first_ramp_buf, Pixel *p_last_ramp_buf);	

static int  load_image( fitsfile *cfitsio_fptr, int num_ext, 
                        Pixel *p_image_buf );

static int  load_image_extension( fitsfile *cfitsio_fptr, 
                                  ImgExtData *p_img_ext_data );

static void map_image_extension_data( const ImgExtData *p_img_ext_data, 
                                      Pixel *p_image_buf );

#if defined( RTD_FILE_DEBUG )

  static void log_cfitsio_errmsg( void );
#endif


/*- Signal catching functions ------------------------------------------------*/
/*- Main ---------------------------------------------------------------------*/
/*- Externally visible data --------------------------------------------------*/

 short int G_store_mode = 0;      /* Current fits file Storage mode   */ 
 short int G_windows  = 0;        /* Number of user selected windows  */ 
 float G_pix_linear_limit  = 0.0; /* Holds pixel 2% linearity limit   */
 float G_pix_saturat_limit = 0.0; /* Holds pixel saturation limit     */
 float G_pix_offset = 0.0;        /* Holds pixel offset  (maxbias)    */ 
 
 
/*- Externally visible functions ---------------------------------------------*/

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

#define STRINGS_EQUAL           0    
       
int file_is_liris( const char *p_file_to_check )
{
   struct stat filestat;
   int         filename_length;

   fitsfile   *cfitsio_fptr;
   int         cfitsio_status;

   char   cfitsio_value_buf[ FLEN_VALUE ];     /* FLEN_VALUE and FLEN_COMMENT */
   char   cfitsio_comment_buf[ FLEN_COMMENT ]; /* are defined in "fitsio.h"   */


   /*-----------------------------------------------------------*/
   /* STEP 1 - Check to see whether the filename ends in ".fit" */
   /*-----------------------------------------------------------*/

   filename_length = strlen( p_file_to_check );

   /* Must be at least 5 characters - if not return failure */ 
   if ( filename_length < 5 )
   {

#if defined( RTD_FILE_DEBUG )
      msg( DEBUG,
       "LIRIS file candidate (%s) rejected - filename too short.\n",
        p_file_to_check );
#endif

      return -1;   /*** NO: invalid filename ***/
   }

   /* Check last four chars are ".fit" */
   if ( strcmp( &p_file_to_check[ filename_length - 4 ], ".fit" )
                 != STRINGS_EQUAL )
   {

#if defined( RTD_FILE_DEBUG )
      msg( DEBUG,
     "LIRIS file candidate (%s) rejected - filename doesn't end in '.fit'.\n",
      p_file_to_check );
#endif

      return -1;   /*** NO: invalid filename ***/
   }


   /*-----------------------------------------------------------*/
   /* STEP 2 - Check to see whether file exists                 */
   /*-----------------------------------------------------------*/

   /* Get the filesystem status associated with the specified file */
   if ( stat( p_file_to_check, &filestat ) != 0 )
   {

#if defined( RTD_FILE_DEBUG )
      msg( DEBUG, 
     "LIRIS file candidate (%s) rejected - couldn't access file statistics.\n",
      p_file_to_check );
#endif

      return -2;   /*** NO: couldn't determine status ***/
   }


   /*-----------------------------------------------------------*/
   /* STEP 3 - Check to see whether a Unix 'REGULAR' file       */
   /*-----------------------------------------------------------*/

   /* Use supplied macro to test for Unix file REGULAR ity */
   if ( ! S_ISREG( filestat.st_mode ) )
   {

#if defined( RTD_FILE_DEBUG )
      msg( DEBUG, 
     "LIRIS file candidate (%s) rejected - not a Unix REGULAR file.\n", 
     p_file_to_check );
#endif

      return -3;   /*** NO: not Unix REGULAR file ***/
   }


   /*-----------------------------------------------------------*/
   /* STEP 4 - Check to see whether the file is greater than    */
   /*          the minimum required size                        */
   /*-----------------------------------------------------------*/

   if ( filestat.st_size < LIRIS_FILE_MIN_SIZE )
   {

#if defined( RTD_FILE_DEBUG )
      msg( DEBUG,
            "LIRIS file candidate (%s) rejected - filesize too small.\n", 
            p_file_to_check );
#endif

      return -4;   /*** NO: file too small ***/
   }


   /*-----------------------------------------------------------*/
   /* STEP 5 - Check to see whether the file contains a         */
   /*          'DETECTOR' header                                */
   /*-----------------------------------------------------------*/

   /* Set up the CFITSIO library ready for use */
   cfitsio_status = 0;   
   (void) fits_clear_errmsg();


   /* Open the specified FITS file using the CFITSIO library */
   (void) fits_open_file ( &cfitsio_fptr, p_file_to_check, 
                            READONLY, &cfitsio_status );

   if ( cfitsio_status != 0 )
   {

#if defined( RTD_FILE_DEBUG )
      msg( DEBUG, 
       "LIRIS file candidate (%s) rejected - couldn't open file.\n",
        p_file_to_check );
      log_cfitsio_errmsg();
#endif

      return -5;   /*** NO: couldn't open file ***/
   }
   

   /* Get the value of the DETECTOR keyword (don't care about the comment) */
   (void) fits_read_key( cfitsio_fptr, TSTRING, "DETECTOR", 
                         cfitsio_value_buf, 
                         cfitsio_comment_buf, 
                         &cfitsio_status ); 
                            
   if ( cfitsio_status != 0 )
   {

#if defined( RTD_FILE_DEBUG )
      msg( DEBUG, 
 "LIRIS file candidate (%s) rejected - 'DETECTOR' keyword not present or undefined.\n", p_file_to_check );
      log_cfitsio_errmsg();
#endif

      (void) fits_close_file ( cfitsio_fptr, &cfitsio_status );

      return -6;  /*** NO: 'DETECTOR' keyword not found ***/
   }


   /*-----------------------------------------------------------*/
   /* STEP 6 - Check whether DETECTOR header set to 'LIRIS' or  */
   /*           'INGRID'                                        */
   /*-----------------------------------------------------------*/

   /* Check whether the DETECTOR keyword was set to LIRIS */
   if ( strcmp( cfitsio_value_buf, "LIRIS" ) != STRINGS_EQUAL )
   {
   
      /* Check whether the DETECTOR keyword was set to INGRID */
      if ( strcmp( cfitsio_value_buf, "INGRID" ) != STRINGS_EQUAL )
      {   

#if defined( RTD_FILE_DEBUG )
      msg( DEBUG, 
      "File candidate (%s) rejected - 'DETECTOR' keyword was not set to 'LIRIS' or 'INGRID'.\n",
       p_file_to_check );
#endif

      (void) fits_close_file ( cfitsio_fptr, &cfitsio_status );

      return -7;   /*** NO: 'DETECTOR' keyword not LIRIS ***/
      
      }  
   }
   
   

   /*-----------------------------------------------------------*/
   /* STEP 7 - Check to see whether the file contains a         */
   /*          'STORMODE' header                                */
   /*-----------------------------------------------------------*/

   /* Get the value of the STORMODE keyword (don't care about the comment) */
   (void) fits_read_key( cfitsio_fptr, TSTRING, "STORMODE", 
                         cfitsio_value_buf, 
                         cfitsio_comment_buf, 
                         &cfitsio_status ); 
                            
   if ( cfitsio_status != 0 )
   {

#if defined( RTD_FILE_DEBUG )
      msg( DEBUG,
       "LIRIS file candidate (%s) rejected - 'STORMODE' keyword not present or undefined.\n",
        p_file_to_check );
      log_cfitsio_errmsg();
#endif

      (void) fits_close_file ( cfitsio_fptr, &cfitsio_status );

      return -8;  /*** NO: 'STORMODE' keyword not found ***/
   }


   /*-----------------------------------------------------------*/
   /* STEP 8 - Check whether STORMODE header set to 'NORMAL',   */
   /*          'DIFF_PRE', 'DIFF', 'SLOPE', or 'SLOPE_READS'    */  
   /*-----------------------------------------------------------*/

   /* Check whether the STORMODE keyword was set to valid value */
   
   if ( check_lirsmode ( cfitsio_value_buf ) == -1)
   {
#if defined( RTD_FILE_DEBUG )
      msg( DEBUG, 
   "LIRIS file candidate (%s) rejected - 'STORMODE' keyword was not set to valid val.\n",
    p_file_to_check );
      
#endif

      (void) fits_close_file ( cfitsio_fptr, &cfitsio_status );

      return -9;   /*** NO: 'STORMODE' keyword not valid ***/   
   }

   /*-----------------------------------------------------------*/
   /* STEP 9 - Check whether , SATURATE, MAXBIAS and LINEARLM   */
   /*           headers are defined                             */
   /* NOTE: For INGRID LINEARLM may not  present (TBC)          */
   /*-----------------------------------------------------------*/

   /* Get the value of the SATURATE keyword (don't care about the comment) */
   (void) fits_read_key( cfitsio_fptr, TFLOAT, "SATURATE",  
                         &G_pix_saturat_limit, 
                         cfitsio_comment_buf, 
                         &cfitsio_status ); 			 
                            
   if ( cfitsio_status != 0 )
   {

#if defined( RTD_FILE_DEBUG )
      msg( DEBUG, 
 "LIRIS file candidate (%s) rejected - 'SATURATE' keyword not present or undefined.\n", p_file_to_check );
      log_cfitsio_errmsg();
#endif

      (void) fits_close_file ( cfitsio_fptr, &cfitsio_status );

  
      return -10;   /*** NO: 'SATURATE' keyword not found ***/
      
   }
    
   /* Get the value of the MAXBIAS keyword (don't care about the comment) */   
   (void) fits_read_key( cfitsio_fptr, TFLOAT, "MAXBIAS",  
                         &G_pix_offset, 
                         cfitsio_comment_buf, 
                         &cfitsio_status ); 
			 			 
                            
   if ( cfitsio_status != 0 )
   {

#if defined( RTD_FILE_DEBUG )
      msg( DEBUG, 
 "LIRIS file candidate (%s) rejected - 'MAXBIAS' keyword not present or undefined.\n", p_file_to_check );
      log_cfitsio_errmsg();
#endif

      (void) fits_close_file ( cfitsio_fptr, &cfitsio_status );
      
     return -11;  /*** NO: 'MAXBIAS' keyword not found ***/
      
       
   }

   /* Get the value of the LINEARLM keyword (don't care about the comment) */
   /* NOTE: INGRID does not have this keyword as MAY26,2003                */
   (void) fits_read_key( cfitsio_fptr, TFLOAT, "LINEARLM",  
                         &G_pix_linear_limit, 
                         cfitsio_comment_buf, 
                         &cfitsio_status ); 			 
                            
   if ( cfitsio_status != 0 )
   {
    #if defined( RTD_FILE_DEBUG )
      msg( DEBUG, 
 "LIRIS file candidate (%s) rejected - 'LINEARLM' keyword not present or undefined.\n", p_file_to_check );
      log_cfitsio_errmsg();
#endif

      (void) fits_close_file ( cfitsio_fptr, &cfitsio_status );

      return -12;  /*** NO: 'LINEARLM' keyword not found ***/
   }
   
   /* Get keywords related to seiing & background calculations */
   /* This is only done if seeing communications is activated  */
   /* off == 0, on == 1                                        */
      
   /*  comentado por mcharcos    
   if ( G_seeing_display == COMMUNICATION_ON) 
   {
      if ( get_seeing_keywords ( cfitsio_fptr ) == -1)
      {
   #if defined( RTD_FILE_DEBUG )
	 msg( DEBUG, 
      "LIRIS file candidate (%s) rejected - seeing related keywords missing.\n",
           p_file_to_check );

   #endif

	 (void) fits_close_file ( cfitsio_fptr, &cfitsio_status );

	 return -13;     fin comentado por mcharcos   */ 
 /*  comentado por mcharcos    
      }

   }   
   fin comentado por mcharcos   */ 

   /*-----------------------------------------------------------*/
   /* STEP 10 - Close file                                      */
   /*-----------------------------------------------------------*/

   (void) fits_close_file ( cfitsio_fptr, &cfitsio_status );
   if ( cfitsio_status != 0 )
   {

#if defined( RTD_FILE_DEBUG )
      msg( DEBUG, "LIRIS file candidate (%s) rejected - couldn't close file.\n", p_file_to_check );
      log_cfitsio_errmsg();
#endif

      return -14;   /*** NO: couldn't close file ***/
   }
   

   /* If control reaches here then the file is deemed to be LIRIS */
   /* compatible. Return success code to caller. */

#if defined( RTD_FILE_DEBUG )
      msg( DEBUG, 
      "LIRIS file candidate (%s) is LIRIS compatible.\n", p_file_to_check );
#endif

   return 0;       /*** YES: file is LIRIS compatible ***/

} /* file_is_liris */





/*--------------------------------------------------------------------*/
/* Function name : check_lirsmode                                     */
/*                                                                    */
/* Passed        : p_key_value    - value found on STORMODE keyword   */
/*                                                                    */
/* Returned      : int =  0 - Success                                 */
/*                     = -1 - Error : invalid keyword val             */
/*                                                                    */
/* Description   : Checks if the STORMODE keyword has one of the      */
/*                 following valid values:                            */  
/*                 'NORMAL'(PRE_POST),'DIFF_PRE', 'DIFF',             */
/*                 'SLOPE', or 'SLOPE_READS'                          */
/*                                                                    */
/*--------------------------------------------------------------------*/
static int check_lirsmode( const char *p_key_value) 
{

#if defined( RTD_FILE_DEBUG )
      msg( DEBUG, 
      "check_lirsmode value: %s.\n", p_key_value );
#endif

   if ( strcmp( p_key_value, "normal" ) == STRINGS_EQUAL )   
   {
   	G_store_mode = PRE_POST;
	
#if defined( RTD_FILE_DEBUG )	
	msg(DEBUG, " lirismode is: PRE_POST");
#endif
	
	return 0;
   }
      
   if ( strcmp( p_key_value, "diff_pre" ) == STRINGS_EQUAL )
   {
   	G_store_mode = DIFF_PRE;
	
#if defined( RTD_FILE_DEBUG )		
	msg(DEBUG, " lirismode is: DIFF_PRE");
#endif
	
	return 0;
   } 
   
   if ( strcmp( p_key_value, "diff" ) == STRINGS_EQUAL ) 
   {
   	G_store_mode = DIFF;
	
#if defined( RTD_FILE_DEBUG )			
	msg(DEBUG, " lirismode is: DIFF");
#endif
	
	return 0;
   }   
   
 
   if ( strcmp( p_key_value, "slope" ) == STRINGS_EQUAL ) 
   {
   	G_store_mode = SLOPE;
	
#if defined( RTD_FILE_DEBUG )				
	msg(DEBUG, " lirismode is: SLOPE");
#endif
	
	return 0;
   }   
   
   if ( strcmp( p_key_value, "slope_reads" ) == STRINGS_EQUAL ) 
   { 
   	G_store_mode = SLOPE_READS;
#if defined( RTD_FILE_DEBUG )					
	msg(DEBUG, "lirismode is: SLOPE_READS");
#endif
	
	return 0;
   }
   
   /* if reach here, it means that an invalid value was set */   	   

#if defined( RTD_FILE_DEBUG )
      msg( DEBUG, 
   "LIRIS LIRSMODE keyword set to (%s) is invalid .\n", p_key_value );      
#endif

    return -1;   /*** NO: 'STORMODE' keyword not LIRIS ***/
   
} /* check_lirsmode */




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
/*                  = -4 - Error : No number of reads keyword         */
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

/* Definitions for fits_read_img() routine used locally in this function */

#define CFITSIO_SKIP_NULCHK     0   /* Set to zero to disable null checking */
#define CFITSIO_FIRST_RD_ELEM   1L  /* First data element has index value 1 */

int file_read_liris( const char *p_filename, 
                      Pixel *p_diff_buf ,
                      Pixel *p_pre_buf ,
		      Pixel *p_post_buf,
		      Pixel *p_slope_buf,		      
		      Pixel *p_first_ramp_buf,
		      Pixel *p_last_ramp_buf)
{

   char   cfitsio_comment_buf[ FLEN_COMMENT ];  /* FLEN_COMMENT is defined */
                                                /* in "fitsio.h" */
                                 
   fitsfile *cfitsio_fptr;     /* cfitsio file handle    */

   int    cfitsio_status;      /* cfitsio return status  */
   int    cfitsio_hdutype;     /* Dummy call parameter - */
                               /*return value not used   */



   int    num_windows;         /* Holds number of windows in FITS file  */
   int    num_hdus;            /* Holds number of FITS HDU's 	        */
   int    num_fits_extensions; /* Holds number of FITS image extensions */
   int    num_reads_for_ramp;  /* Holds number of reads in FITS file    */
                               /* this is only used for readup the ramp */

   int  first_group_start_hdu; /* Set to point to first image extension HDU */
                               /* containing pre-integration target data or */
			       /* diff data                                 */

   int  second_group_start_hdu; /* Set to point to second image extension */
                                /* HDU containing pre-integration target  */
		                /* data or post-integration data          */
				
   int last_read_up_ext_start_hdu;				


#if defined( RTD_FILE_DEBUG )					   

   float  cfitsio_version;     /* Dummy call parameter - */
#endif
                               /*return value not used   */

#if defined( RTD_FILE_DEBUG )					   

   msg (DEBUG, " **********FUNC: file_read_liris******\n");
   msg (DEBUG, " (%s, %lu, %lu, %lu, %lu, %lu, %lu)\n",
                       p_filename, 
                       p_diff_buf ,
                       p_pre_buf ,
		       p_post_buf,
		       p_slope_buf,			
		       p_first_ramp_buf,
		       p_last_ramp_buf);
#endif
		       
   /*-----------------------------------------------------------*/
   /* STEP 1 - Set up the CFITSIO library ready for use         */
   /*-----------------------------------------------------------*/
   
   /* Clear error status */
   cfitsio_status = 0;   
   (void) fits_clear_errmsg();


   /* Print library version */
   #if defined( RTD_FILE_DEBUG )
      (void) fits_get_version( &cfitsio_version );
      msg( DEBUG, "Using CFITSIO library version %f.\n", cfitsio_version );
   #endif


   /* If there was a problem terminate processing with error */
   if ( cfitsio_status != 0 )
   {

     #if defined( RTD_FILE_DEBUG )
          msg( DEBUG, 
         "CFITSIO Couldn't open specified FITS file %s.\n", p_filename );
           log_cfitsio_errmsg();
     #endif

     return -1;              /*** ERROR: Couldn't open file ***/ 
   }


   /*-----------------------------------------------------------*/
   /* STEP 2 - Open the specified FITS file                     */
   /*-----------------------------------------------------------*/

   /* Open the specified FITS file using the CFITSIO library */
   (void) fits_open_file ( &cfitsio_fptr, p_filename, READONLY, 
                           &cfitsio_status );
			   
#if defined( RTD_FILE_DEBUG )					   
      msg(DEBUG, "cfitsio_fptr= %lu\n", cfitsio_fptr);                
#endif

   /* If there was a problem terminate processing with error */
   if ( cfitsio_status != 0 )
   {
     #if defined( RTD_FILE_DEBUG )
       msg( DEBUG, 
	"CFITSIO Couldn't open specified FITS file %s.\n", p_filename );
       log_cfitsio_errmsg();
     #endif
       return -1;              /*** ERROR: Couldn't open file ***/ 
   }


   /*-----------------------------------------------------------*/
   /* STEP 3 - Determine and validate the number of windows     */
   /*-----------------------------------------------------------*/

   /* Attempt to determine the number of windows by reading the */
   /* NWINDOWS header                                           */
   (void) fits_read_key( cfitsio_fptr, TINT, "NWINDOWS", 
                         &num_windows, 
                         cfitsio_comment_buf, 
                         &cfitsio_status ); 
                            
   if ( cfitsio_status != 0 )
   {
     
     #if defined( RTD_FILE_DEBUG )
      msg( DEBUG, 
  "'NWINDOWS' keyword not present or undefined - will assume file is non-windowed.\n" );
      log_cfitsio_errmsg();
     #endif

      /* If the 'NWINDOWS' keyword is not present then assume no windows */
      /* were explicitly set up by the user.                             */
      num_windows = 0;

      /* Reset error status to enable further CFITSIO processing later on */
      cfitsio_status = 0;   

   }

 
   /* Check the specified number of windows against configured limits */
   if ( ( num_windows < 0 ) || ( num_windows > LIRIS_FILE_MAX_WINDOWS ) )
   {

#if defined( RTD_FILE_DEBUG )
      msg( DEBUG, "'NWINDOWS' has invalid value (%d) - should be between 0 and %d.\n",
           num_windows, LIRIS_FILE_MAX_WINDOWS );
#endif

      /* Close the file - don't look at the result as */
      /* the earlier error condition takes precedence */
      (void) fits_close_file ( cfitsio_fptr, &cfitsio_status );

      return -2;              /*** ERROR: Invalid number of windows ***/ 
   }
   /* set global window indicator to number of windows selected by user */
   G_windows= num_windows;
   
   /* If no windows were explicitly set up by the user (NWINDOWS undefined, */
   /* or zero) then for all further processing in this routine this may be  */
   /* considered as being a single window.                                  */  
   
   
   if ( num_windows == 0 )
   {
      
      num_windows = 1;
   }


   /*-----------------------------------------------------------*/
   /* STEP 4 - Determine the number of FITS image extensions    */
   /*-----------------------------------------------------------*/

   /* Attempt to determine the total number of HDU's present in */
   /* the file.                                                 */
   
   (void) fits_get_num_hdus( cfitsio_fptr, &num_hdus, &cfitsio_status ); 
                            
   if ( cfitsio_status != 0 )
   {
   #if defined( RTD_FILE_DEBUG )
      msg( DEBUG, 
      "CFITSIO couldn't determine the number of FITS image extensions.\n" );
      log_cfitsio_errmsg();
   #endif

      /* Close the file - don't look at the result as */
      /* the earlier error condition takes precedence */
      cfitsio_status = 0;   
      (void) fits_close_file ( cfitsio_fptr, &cfitsio_status );

      return -3;              /*** ERROR: Couldn't determine ***/
                              /*** number of FITS extensions ***/ 
   }
 

   /* There is one FITS image extension for all HDU's excluding */
   /* the primary HDU. */
   
   num_fits_extensions = num_hdus - 1;

   
   /*-----------------------------------------------------------*/
   /* STEP 5 - Validate the number of FITS image extensions     */
   /*-----------------------------------------------------------*/   
   if( validate_nunfits_extensions(num_fits_extensions, num_windows) != 0)
   {
       #if defined( RTD_FILE_DEBUG )
	 msg( DEBUG, "Invalid number of FITS image extensions (%d).\n",
	   num_fits_extensions );
       #endif

       /* Close the file - don't look at the result as */
       /* the earlier error condition takes precedence */
       cfitsio_status = 0;   
       (void) fits_close_file ( cfitsio_fptr, &cfitsio_status );

       return -3;	/*** ERROR: Invalid number of HDU's ***/ 
   }    


   /*-----------------------------------------------------------*/
   /* STEP 6 - Get the number of readup the ramp reads          */
   /*-----------------------------------------------------------*/
   
   /* Attempt to determine the number of reads by looking into  */
   /* the NRAMPRDS header */
   if (G_store_mode == SLOPE_READS)
   {
   
     (void) fits_read_key( cfitsio_fptr, TINT, "NRAMPRDS", 
                         &num_reads_for_ramp, 
                         cfitsio_comment_buf, 
                         &cfitsio_status );    

                            
     if ( cfitsio_status != 0 )
     {
       #if defined( RTD_FILE_DEBUG )
	msg( DEBUG, 
"CFITSIO couldn't determine the total number of readouts for the ramp.\n" );
	log_cfitsio_errmsg();
     #endif

	/* Close the file - don't look at the result as */
	/* the earlier error condition takes precedence */
	cfitsio_status = 0;   
	(void) fits_close_file ( cfitsio_fptr, &cfitsio_status );

	return -4;           /*** ERROR: Couldn't determine ***/
                             /*** number of reads for readup the ramp ***/ 
      }   

   }
       
   /*-------------------------------------------------------------*/
   /* STEP 6 - Seek to first image extension HDU containing      */
   /*          pre-integration, diff or slope target data         */
   /*-------------------------------------------------------------*/
   
   /* This first group of data set always begins at the second  */
   /* HDU (the first HDU is the primary).                       */

   first_group_start_hdu = 2;
   cfitsio_status =0; /* clean up cfitsio status */   

   /* Attempt to seek to the first HDU containing the diff, pre-int */
   /* or slope data depending on the storage-mode                   */
   
#if defined( RTD_FILE_DEBUG )					      
   msg(DEBUG, "llamo a fits_movabs_hdu (cfitsio_fptr= %lu,", cfitsio_fptr);                
   msg(DEBUG, "first_group_start_hdu= %d) \n", first_group_start_hdu);                
#endif
   (void) fits_movabs_hdu( cfitsio_fptr, 
                           first_group_start_hdu, 
                           &cfitsio_hdutype, &cfitsio_status );

   /* If there was a problem terminate processing with error */
   if ( cfitsio_status != 0 )
   {

#if defined( RTD_FILE_DEBUG )
      msg( DEBUG, 
      "CFITSIO couldn't find first HDU (%d).\n", first_group_start_hdu );
      log_cfitsio_errmsg();
#endif

      /* Close the file - don't look at the result as */
      /* the earlier error condition takes precedence */
      cfitsio_status = 0;   
      (void) fits_close_file ( cfitsio_fptr, &cfitsio_status );

      return -5;              /*** ERROR: Couldn't find data */
   }


   /*-----------------------------------------------------------*/
   /* STEP 7 - Initialise image buffers                         */
   /*-----------------------------------------------------------*/
   /* Ok, if execution has reached here there's a good chance   */
   /* that the file can be loaded ok.                           */ 
 

   (void) initialize_data_buffers(p_diff_buf, p_pre_buf, p_post_buf,
                           p_slope_buf,	p_first_ramp_buf, 
			   p_last_ramp_buf);
#if defined( RTD_FILE_DEBUG )					      
   msg(DEBUG, " p_diff_buf=%lu p_pre_buf=%lu p_post_buf=%lu\n",
                  p_diff_buf, p_pre_buf, p_post_buf);
		  
    msg(DEBUG, " p_slope_buf=%lu  p_first_ramp_buf=%lu  p_last_ramp_buf=%lu\n",
    		 p_slope_buf,	p_first_ramp_buf, p_last_ramp_buf); 			   
#endif
			    
   /*-----------------------------------------------------------*/
   /* STEP 8 - Read the first group data on the appropiate      */
   /*          storage buffers acoording to the storage mode.   */
   /*-----------------------------------------------------------*/
    
   switch (G_store_mode)
   {
     case DIFF:
     case DIFF_PRE:
	 /* Attempt to build image from diff ITS image extension */
	 if ( load_image( cfitsio_fptr, num_windows, p_diff_buf ) != 0 )
	 {

           #if defined( RTD_FILE_DEBUG )
	       msg( DEBUG, "Failed to read diff data.\n" );
           #endif

	    /* Close the file - don't look at the result as */
	    /* the earlier error condition takes precedence */
	    cfitsio_status = 0;   
	    (void) fits_close_file ( cfitsio_fptr, &cfitsio_status );

	    return -6;      /*** ERROR: Couldn't read diff data */
	 }
       break;        
           
     case PRE_POST:
     
	 /* Attempt to build image from pre-int FITS image extension */
	 if ( load_image( cfitsio_fptr, num_windows, p_pre_buf ) != 0 )
	 {

           #if defined( RTD_FILE_DEBUG )
	       msg( DEBUG, "Failed to read pre-int data.\n" );
           #endif

	    /* Close the file - don't look at the result as */
	    /* the earlier error condition takes precedence */
	    cfitsio_status = 0;   
	    (void) fits_close_file ( cfitsio_fptr, &cfitsio_status );

	    return -7;       /*** ERROR: Couldn't read pre-int data */
	 }
       break;      
     
     case SLOPE:
     case SLOPE_READS:
	 /* Attempt to build image from slope FITS image extension */
	 if ( load_image( cfitsio_fptr, num_windows, p_slope_buf ) != 0 )
	 {

           #if defined( RTD_FILE_DEBUG )
	       msg( DEBUG, "Failed to read slope data.\n" );
           #endif

	    /* Close the file - don't look at the result as */
	    /* the earlier error condition takes precedence */
	    cfitsio_status = 0;   
	    (void) fits_close_file ( cfitsio_fptr, &cfitsio_status );

	    return -8;       /*** ERROR: Couldn't read slope data */
	 }
       break;           
     
   }  /* end of switch */  
   
   /*------------------------------------------------------------*/
   /* STEP 9 - Seek to the first image extension HDU containing  */
   /*          pre-int, post-int or the first readup of the ramp */
   /*------------------------------------------------------------*/
  
   /* For the MNDR storage modes the second group of data always */
   /* begins one "window set" back from the LAST HDU             */
   switch (G_store_mode )
   {
     case DIFF:
          second_group_start_hdu = 0;    
          break;
     case DIFF_PRE:
     case PRE_POST:                                                         
          second_group_start_hdu = num_hdus - num_windows + 1;
          break;
       
     case SLOPE:
          second_group_start_hdu = 0;         
          break;
     case SLOPE_READS:
          second_group_start_hdu = num_hdus - (num_reads_for_ramp * num_windows) + 1;
          break;
	  
    }

   /* Attempt to seek to the second HDU containing data */
   /* Only for DIFF_PRE, PRE_POST and SLOPE_READS modes, those */
   /* where second_group_start_hdu is not 0 */
   /*clear fits staus */
   cfitsio_status = 0;
   if ( second_group_start_hdu != 0)
   {
   
#if defined( RTD_FILE_DEBUG )					         
      msg(DEBUG, "llamo segunda vez a fits_movabs_hdu\n");
      msg(DEBUG, "cfitsio_fptr= %lu\n, second_group_start_hdu %d\n",
                     cfitsio_fptr, second_group_start_hdu); 
#endif		     
                     
      (void) fits_movabs_hdu( cfitsio_fptr, 
                           second_group_start_hdu, 
                           &cfitsio_hdutype, &cfitsio_status );
			   
#if defined( RTD_FILE_DEBUG )					         

      msg(DEBUG, "cfitsio_status= %d\n", cfitsio_status);                
#endif		     

      /* If there was a problem terminate processing with error */
      if ( cfitsio_status != 0 )
      {

#if defined( RTD_FILE_DEBUG )
         msg( DEBUG, "CFITSIO couldn't find second HDU containing data (%d).\n",
              second_group_start_hdu );
         log_cfitsio_errmsg();
#endif

         /* Close the file - don't look at the result as */
         /* the earlier error condition takes precedence */
         cfitsio_status = 0;   
         (void) fits_close_file ( cfitsio_fptr, &cfitsio_status );

         return -9;        /*** ERROR: Couldn't find second group data ***/
       }
   }
   
   /*-----------------------------------------------------------*/
   /* STEP 10 - Read data on the appropiate storage buffers     */
   /*          depending on the storage mode.                   */
   /*-----------------------------------------------------------*/
   switch (G_store_mode )
   {
     case DIFF:
#if defined( RTD_FILE_DEBUG)     
          msg(DEBUG," NO MORE DATA _ THIS IS A DIFF FILE\n ");
#endif
          break;  /* no data available. It holds only one extension */
	  
     case DIFF_PRE:

	  /* Attempt to build image from pre-int FITS image extensions */
	  if ( load_image( cfitsio_fptr, num_windows, p_pre_buf ) != 0 )
	  {

            #if defined( RTD_FILE_DEBUG )
	        msg( DEBUG, "Failed to read pre-integration data.\n" );
            #endif

	     /* Close the file - don't look at the result as */
	     /* the earlier error condition takes precedence */
	     cfitsio_status = 0;   
	     (void) fits_close_file ( cfitsio_fptr, &cfitsio_status );

	     return -7;       /*** ERROR: Couldn't read pre-int data */
	  }
	  
          break;

     case PRE_POST:

	  /* Attempt to build image from post-int FITS image extensions */
	  if ( load_image( cfitsio_fptr, num_windows, p_post_buf ) != 0 )
	  {

            #if defined( RTD_FILE_DEBUG )
	        msg( DEBUG, "Failed to read post-integration data.\n" );
            #endif

	     /* Close the file - don't look at the result as */
	     /* the earlier error condition takes precedence */
	     cfitsio_status = 0;   
	     (void) fits_close_file ( cfitsio_fptr, &cfitsio_status );

	     return -10;    /*** ERROR: Couldn't read post-int data */
	  }
	  
          break;
       
     case SLOPE:
          break;  /* no data available. It holds only one extension */ 
	      
     case SLOPE_READS:
     
	  /* Attempt to build image from first read of the ramp FITS  */
	  /* image extensions */
	  if ( load_image( cfitsio_fptr, num_windows, p_first_ramp_buf ) != 0 )
	  {

            #if defined( RTD_FILE_DEBUG )
	        msg( DEBUG, "Failed to read first read of the ramp data.\n" );
            #endif

	     /* Close the file - don't look at the result as */
	     /* the earlier error condition takes precedence */
	     cfitsio_status = 0;   
	     (void) fits_close_file ( cfitsio_fptr, &cfitsio_status );

	     return -11; /*** ERROR: Couldn't read first read of ramp data */
	  }
	  
	  /*----------------------------------------------------*/
	  /* Seek to the first image extension HDU containing   */
	  /* the last read-up the ramp data                     */
	  /*----------------------------------------------------*/
                                                	  
	  last_read_up_ext_start_hdu = num_hdus - num_windows + 1;


	  /* Attempt to seek to the HDU containing the last read */
	  /* of the ramp data */
	  (void) fits_movabs_hdu( cfitsio_fptr, 
                        	  last_read_up_ext_start_hdu, 
                        	  &cfitsio_hdutype, &cfitsio_status );


	  /* If there was a problem terminate processing with error */
	  if ( cfitsio_status != 0 )
	  {

            #if defined( RTD_FILE_DEBUG )
	      msg( DEBUG, 
	      "CFITSIO couldn't find HDU containing last read of the ramp data (%d).\n",
        	        last_read_up_ext_start_hdu );
	      log_cfitsio_errmsg();
            #endif
	     
	     /* Close the file - don't look at the result as */
	     /* the earlier error condition takes precedence */
	     cfitsio_status = 0;   
	     (void) fits_close_file ( cfitsio_fptr, &cfitsio_status );

	     return -12;     /*** ERROR: Couldn't find last read - data ***/
	  }	  
	  
	  /* Attempt to build image from last read of the RAMP FITS */
	  /* image extensions */
	  if ( load_image( cfitsio_fptr, num_windows, p_last_ramp_buf ) != 0 )
	  {

            #if defined( RTD_FILE_DEBUG )
	        msg( DEBUG, "Failed to read last read ramp data.\n" );
            #endif

	     /* Close the file - don't look at the result as */
	     /* the earlier error condition takes precedence */
	     cfitsio_status = 0;   
	     (void) fits_close_file ( cfitsio_fptr, &cfitsio_status );

	     return -13;   /*** ERROR: Couldn't read last read of ramp data */
	  }
	  
       break;	  

   }  /* close switch */
   
   /*-----------------------------------------------------------*/
   /* STEP 11 - Close the file                                  */
   /*-----------------------------------------------------------*/
  
   /* Close the file */
   cfitsio_status = 0;   
   
   (void) fits_close_file ( cfitsio_fptr, &cfitsio_status );
#if defined( RTD_FILE_DEBUG)     
   msg(DEBUG, "file cerrado terminar file_read_liris\n");
#endif

   /* If there was a problem terminate processing with error */
   if ( cfitsio_status != 0 )
   {

#if defined( RTD_FILE_DEBUG )
      msg( DEBUG, "CFITSIO couldn't close specified FITS file %s.\n",
                  p_filename );
      log_cfitsio_errmsg();
#endif
      return -14;              /*** ERROR: Couldn't close file ***/
   }

   /*-----------------------------------------------------------*/
   /* STEP 12 - Exit with success                               */
   /*-----------------------------------------------------------*/
   
   return 0;                  /*** SUCCESS: File read ok ***/

} /* file_read_liris */

/*--------------------------------------------------------------------*/
/* Function name : validate_nunfits_extensions                        */
/*                                                                    */
/* Passed        : num_extensions  -   number of fits extensions      */
/*                 num_windows     -   number of windows              */
/*                                                                    */
/* Returned      : int =  0 - Success                                 */
/*                     = -1 - Error : invalid number of extensions    */
/*                USES: G_store_mode                                  */
/*                                                                    */
/* Description   : Checks if the number of FITS extensions is valid   */
/*                 for the type of file ( depends on the storemode    */  
/*                                                                    */
/*--------------------------------------------------------------------*/
static int validate_nunfits_extensions( int num_fits_extensions,
            int  num_windows) 
{

#if defined( RTD_FILE_DEBUG)     

      msg( DEBUG, "*******FUNC: validate_nunfits_extensions()\n");
      msg( DEBUG, " (%d, %d)\n", num_fits_extensions,num_windows); 
#endif

   /* Validate the number of FITS image extensions.     */
   /* For MNDR there should be :                        */
   /*  DIFF = 1W, DIFF_PRE and PRE_POST = 2W            */
   /* where W is the number of windows.                 */   
   /*                                                   */
   /* For Readup the RAMP there should be :             */
   /*   SLOPE = 1W, SLOPE_READS = 3W, 4W, 5W,...NW      */
   /* where W is the number of windows and N the number */
   /* of reads. For this mode make no sense for N < 2.  */
   /* Thus valid values for num_fits_extensions start   */
   /* with 3W                                           */

  
   switch (G_store_mode)      
   {
     case DIFF:
     case SLOPE:     
	 if ( ( num_fits_extensions < 1 * num_windows ) ||
               ( ( num_fits_extensions % num_windows ) != 0 ) ) 
	 {
       #if defined( RTD_FILE_DEBUG )
	   msg( DEBUG,
	    "Invalid number of FITS image extensions for DIFF/SLOPE (%d).\n",
	    num_fits_extensions );
       #endif

	     return -1;       /*** ERROR: Invalid number of HDU's ***/ 
	 } 
	 break;    
     
     case DIFF_PRE:
     case PRE_POST:        
	 if ( ( num_fits_extensions < 2 * num_windows ) ||
               ( ( num_fits_extensions % num_windows ) != 0 ) ) 
	 {
       #if defined( RTD_FILE_DEBUG )
	   msg( DEBUG,
     "Invalid number of FITS image extensions for DIFF_PRE/PRE_POST (%d).\n",
	      num_fits_extensions );
       #endif
	     return -1;       /*** ERROR: Invalid number of HDU's ***/ 
	 } 
	 break;       
               
     case SLOPE_READS:
	 if ( ( num_fits_extensions < 3 * num_windows ) ||
               ( ( num_fits_extensions % num_windows ) != 0 ) ) 
	 {

       #if defined( RTD_FILE_DEBUG )
	   msg( DEBUG,
	   "Invalid number of FITS image extensions for SLOPE_READS (%d).\n",
           num_fits_extensions );
       #endif
	    return -1;       /*** ERROR: Invalid number of HDU's ***/ 
	 } 
	 break;           
   } /* end of switch */
   
   /* if reahed here, num-extension is valid, retun  SUCCESS */
   
   return 0; 
}   /* validate_nunfits_extensions */


/*--------------------------------------------------------------------*/
/* Function name : initialize_data_buffers                            */
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
/* Returned      : none                                               */
/*                                                                    */
/* Description   : Depending on the store-mode , it inicializes the   */
/*                 supplied data buffersto their special value        */
/*                 PIXEL_NOT_LOADED.                                  */  
/*                 Only pixels that are mapped by active RTDATSEC     */
/*                 descriptors will have their values flipped back.   */
/*                                                                    */
/*--------------------------------------------------------------------*/   
static void initialize_data_buffers(Pixel *p_diff_buf, Pixel *p_pre_buf,
		      Pixel *p_post_buf, Pixel *p_slope_buf,		      
		      Pixel *p_first_ramp_buf, Pixel *p_last_ramp_buf) 		      
{		      
   long int  i;
   
#if defined( RTD_FILE_DEBUG)     
   msg (DEBUG, " ****FUNC: initialize_data_buffers \n");
   msg (DEBUG, " (%lu,%lu,%lu,%lu,%lu,%lu)\n",
        p_diff_buf, p_pre_buf,p_post_buf, p_slope_buf,		      
        p_first_ramp_buf, p_last_ramp_buf ); 
#endif 

 switch (G_store_mode)
   {
      case  DIFF:
	  
          for ( i = 0; i < PIXEL_BUF_SIZE; i++ )
	     *p_diff_buf++   = PIXEL_NOT_LOADED;
#if defined( RTD_FILE_DEBUG)     	      
  msg (DEBUG, "DIFF Bufer initialized to NOT_LOADED \n"); 
#endif 
 
	 break;
	
      case DIFF_PRE:
      
      
	  for ( i = 0; i < PIXEL_BUF_SIZE; i++ )
	  {      
	     *p_diff_buf++   = PIXEL_NOT_LOADED;
	     *p_pre_buf++    = PIXEL_NOT_LOADED;
	  }
#if defined( RTD_FILE_DEBUG)     	      	  
	  msg (DEBUG, "Despues de poner NOTLOADED p_diff_buf= %lu  p_pre_buf= %lu\n",
	   p_diff_buf, p_pre_buf );    
#endif	   
	
	  
	  break;
       
      case  PRE_POST: 
      	             
	  for ( i = 0; i < PIXEL_BUF_SIZE; i++ )
	  {      
	     *p_pre_buf++    = PIXEL_NOT_LOADED;
	     *p_post_buf++   = PIXEL_NOT_LOADED;	  
	  }
#if defined( RTD_FILE_DEBUG)     	      	  	   
	 msg (DEBUG, "PRE and POST Bufer initialized to NOT_LOADED \n"); 	
#endif
	 
	  break;
              
      case SLOPE:
            
          for ( i = 0; i < PIXEL_BUF_SIZE; i++ )
	    *p_slope_buf++   = PIXEL_NOT_LOADED;
	    
	    
	  break;
	  
      case SLOPE_READS:
      
          for ( i = 0; i < PIXEL_BUF_SIZE; i++ )
          {
	     *p_slope_buf++      = PIXEL_NOT_LOADED;
             *p_first_ramp_buf++ = PIXEL_NOT_LOADED;
             *p_last_ramp_buf++  = PIXEL_NOT_LOADED;
	  } 

	  break;      
    }
    	        
} /* initialize_data_buffers */

				        
/*--------------------------------------------------------------------*/
/* Function name : file_write_liris                                   */
/*                                                                    */
/* Passed        : p_filename     - pathname to FITS file to create   */
/*                 p_pre_int_buf  - pre-int data to be written        */
/*                 p_diff_buf - post-int data to be written           */
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
/* Description   : Write supplied image data to new LIRIS FITS file   */
/*                                                                    */
/* This routine may be customised for test purposes. It is only       */
/* required by 'rtdtest.c'. Currently (5/12/00) it has been set up    */
/* to write the supplied data twice into two separate windows within  */
/* the file. The window sections are:                                 */
/*                                                                    */
/*    [100:600,200:399] and [300:899,600:799]                         */
/*                                                                    */
/*--------------------------------------------------------------------*/

/* Definition for fits_write_img() routine used locally in this function */

#define CFITSIO_FIRST_WR_ELEM    1L   /* First data element has index value 1 */

int file_write_liris( const char  *p_filename, 
                       const Pixel *p_pre_int_buf,
                       const Pixel *p_diff_buf )

{
   fitsfile *cfitsio_fptr;                        /* cfitsio file handle   */
   int       cfitsio_status;                      /* cfitsio return status */

   int       cfitsio_bitpix;                      /* used by fits_create_img to  */
   int       cfitsio_naxis;                       /* create FITS image extension */
   long      cfitsio_naxes[ LIRIS_FILE_NAXIS ];  /* HDU's                       */

   int        num_windows;


   /*--- Set up CFITSIO library ready for use --------------------------------*/
   cfitsio_status = 0;   
   (void) fits_clear_errmsg();


   /*---- Open the specified FITS file using the CFITSIO library -------------*/
   (void) fits_create_file ( &cfitsio_fptr, p_filename,  &cfitsio_status );

   if ( cfitsio_status != 0 )
   {

#if defined( RTD_FILE_DEBUG )
      msg( DEBUG, "Couldn't create specified FITS file (%s).\n", p_filename );
      log_cfitsio_errmsg();
#endif

      return -1;              /*** ERROR: couldn't create FITS file ***/
   }


   /*---- Create the Primary HDU ---------------------------------------------*/

   /* modificado por mcharcos el 19/01/04*/
   cfitsio_bitpix = 32;
   /*cfitsio_bitpix = 8;/*       /* Primary HDU has no associated data array */
   /*fin de la modificacion del 19/01/04 de mcharcos*/
   cfitsio_naxis  = 0;

   (void) fits_create_img( cfitsio_fptr, 
                           cfitsio_bitpix, 
                           cfitsio_naxis, 
                           cfitsio_naxes, 
                           &cfitsio_status ); 
                            
   if ( cfitsio_status != 0 )
   {

#if defined( RTD_FILE_DEBUG )
      msg ( DEBUG, "Couldn't create the Primary HDU.\n" );
      log_cfitsio_errmsg();
#endif

      /* Close the file - don't look at the result as */
      /* the earlier error condition takes precedence */
      cfitsio_status = 0;   
      (void) fits_close_file ( cfitsio_fptr, &cfitsio_status );

      return -2;           /*** ERROR: couldn't create Primary HDU ***/
   }


   /*---- Create a new DETECTOR header set to 'LIRIS' -----------------------*/
   (void) fits_write_key( cfitsio_fptr, TSTRING, "DETECTOR", "LIRIS", 
                          "LIRIS Test File", &cfitsio_status ); 
                            
   if ( cfitsio_status != 0 )
   {

#if defined( RTD_FILE_DEBUG )
      msg ( DEBUG, "Couldn't create the DETECTOR header. \n" );
      log_cfitsio_errmsg();
#endif

      /* Close the file - don't look at the result as */
      /* the earlier error condition takes precedence */
      cfitsio_status = 0;   
      (void) fits_close_file ( cfitsio_fptr, &cfitsio_status );

      return -3;           /*** ERROR: couldn't create DETECTOR header ***/ 
   }


   /*---- Create a new NWINDOWS header set to 2 ------------------------------*/
   
   num_windows = 2;

   (void) fits_write_key( cfitsio_fptr, TINT, "NWINDOWS", &num_windows, 
                          "", &cfitsio_status ); 
                            
   if ( cfitsio_status != 0 )
   {

#if defined( RTD_FILE_DEBUG )
      msg ( DEBUG, "Couldn't create the NWINDOWS header. \n" );
      log_cfitsio_errmsg();
#endif

      /* Close the file - don't look at the result as */
      /* the earlier error condition takes precedence */
      cfitsio_status = 0;   
      (void) fits_close_file ( cfitsio_fptr, &cfitsio_status );

      return -3;           /*** ERROR: couldn't create NWINDOWS header ***/ 
   }


   /*---- WINDOW 1 -----------------------------------------------------------*/
   /*---- Create an image extension for the pre-integration data set ---------*/
   cfitsio_bitpix = CFITSIO_BITPIX;
   cfitsio_naxis  = 2;
   /* modificado por mcharcos */
   /*cfitsio_naxes[ 0 ] = 600;*/
   /*cfitsio_naxes[ 1 ] = 200;*/
   cfitsio_naxes[ 0 ] = 1024;
   cfitsio_naxes[ 1 ] = 1024;
   /* fin de la modificacion por mcharcos */

   (void) fits_create_img( cfitsio_fptr, 
                           cfitsio_bitpix, 
                           cfitsio_naxis, 
                           cfitsio_naxes, 
                           &cfitsio_status ); 
                            
   if ( cfitsio_status != 0 )
   {

#if defined( RTD_FILE_DEBUG )
      msg ( DEBUG, "Couldn't create the HDU for pre-integration data.\n" );
      log_cfitsio_errmsg();
#endif

      /* Close the file - don't look at the result as */
      /* the earlier error condition takes precedence */
      cfitsio_status = 0;   
      (void) fits_close_file ( cfitsio_fptr, &cfitsio_status );

      return -4;           /*** ERROR: couldn't create pre-int HDU ***/ 
   }


   /*---- WINDOW 1 -----------------------------------------------------------*/
   /*---- Create a new RTDATSEC header set to '[100:699,200:399]'--------------*/
   (void) fits_write_key( cfitsio_fptr, TSTRING, "RTDATSEC", "[100:699,200:399]", 
                          "LIRIS Test File", &cfitsio_status ); 
                            
   if ( cfitsio_status != 0 )
   {

#if defined( RTD_FILE_DEBUG )
      msg ( DEBUG, "Couldn't create the RTDATSEC header. \n" );
      log_cfitsio_errmsg();
#endif

      /* Close the file - don't look at the result as */
      /* the earlier error condition takes precedence */
      cfitsio_status = 0;   
      (void) fits_close_file ( cfitsio_fptr, &cfitsio_status );

      return -3;           /*** ERROR: couldn't create RTDATSEC header ***/ 
   }


   /*---- WINDOW 1 -----------------------------------------------------------*/
   /*---- Write the pre-integration image data --------------------------------*/
   (void) fits_write_img( cfitsio_fptr, 
                          CFITSIO_IMG_DATA_TYPE, 
                          CFITSIO_FIRST_WR_ELEM, 
                          /*modificado por mcharcos el 19/01/04*/
			  /*600*200,*/  
			  1024*1024,
			  /*fin de la modificacion del 19/01/04 de mcharcos*/
                          (void *) p_pre_int_buf, 
                          &cfitsio_status );

   if ( cfitsio_status != 0 )
   {

#if defined( RTD_FILE_DEBUG )
      msg( DEBUG, "Couldn't write the pre-integration data.\n" );
      log_cfitsio_errmsg();
#endif

      /* Close the file - don't look at the result as */
      /* the earlier error condition takes precedence */
      cfitsio_status = 0;   
      (void) fits_close_file ( cfitsio_fptr, &cfitsio_status );
                               
      return -5;           /* ERROR: couldn't write pre-integration data */
   }


   /*---- WINDOW 2 -----------------------------------------------------------*/
   /*---- Create an image extension for the pre-integration data set ---------*/
   cfitsio_bitpix = CFITSIO_BITPIX;
   cfitsio_naxis  = 2;
   /* modificado por mcharcos */
   /*cfitsio_naxes[ 0 ] = 600;*/
   /*cfitsio_naxes[ 1 ] = 200;*/
   cfitsio_naxes[ 0 ] = 1024;
   cfitsio_naxes[ 1 ] = 1024;
   /* fin de la modificacion por mcharcos */

   (void) fits_create_img( cfitsio_fptr, 
                           cfitsio_bitpix, 
                           cfitsio_naxis, 
                           cfitsio_naxes, 
                           &cfitsio_status ); 
                            
   if ( cfitsio_status != 0 )
   {

#if defined( RTD_FILE_DEBUG )
      msg ( DEBUG, "Couldn't create the HDU for pre-integration data.\n" );
      log_cfitsio_errmsg();
#endif

      /* Close the file - don't look at the result as */
      /* the earlier error condition takes precedence */
      cfitsio_status = 0;   
      (void) fits_close_file ( cfitsio_fptr, &cfitsio_status );

      return -4;           /*** ERROR: couldn't create pre-int HDU ***/ 
   }


   /*---- WINDOW 2 -----------------------------------------------------------*/
   /*---- Create a new RTDATSEC header set to '[300:899,600:799]'--------------*/
   (void) fits_write_key( cfitsio_fptr, TSTRING, "RTDATSEC", "[300:899,600:799]", 
                          "LIRIS Test File", &cfitsio_status ); 
                            
   if ( cfitsio_status != 0 )
   {

#if defined( RTD_FILE_DEBUG )
      msg ( DEBUG, "Couldn't create the RTDATSEC header. \n" );
      log_cfitsio_errmsg();
#endif

      /* Close the file - don't look at the result as */
      /* the earlier error condition takes precedence */
      cfitsio_status = 0;   
      (void) fits_close_file ( cfitsio_fptr, &cfitsio_status );

      return -3;           /*** ERROR: couldn't create RTDATSEC header ***/ 
   }


   /*---- WINDOW 2 -----------------------------------------------------------*/
   /*---- Write the pre-integration image data -------------------------------*/
   (void) fits_write_img( cfitsio_fptr, 
                          CFITSIO_IMG_DATA_TYPE, 
                          CFITSIO_FIRST_WR_ELEM, 
                          /*modificado por mcharcos el 19/01/04*/
			  /*600*200,*/  
			  1024*1024,
			  /*fin de la modificacion del 19/01/04 de mcharcos*/
                          (void *) p_pre_int_buf, 
                          &cfitsio_status );

   if ( cfitsio_status != 0 )
   {

#if defined( RTD_FILE_DEBUG )
      msg( DEBUG, "Couldn't write the pre-integration data.\n" );
      log_cfitsio_errmsg();
#endif

      /* Close the file - don't look at the result as */
      /* the earlier error condition takes precedence */
      cfitsio_status = 0;   
      (void) fits_close_file ( cfitsio_fptr, &cfitsio_status );
                               
      return -5;           /* ERROR: couldn't write pre-integration data */
   }


   /*---- WINDOW 1 -----------------------------------------------------------*/
   /*---- Create an image extension for the post-integration data set --------*/
   cfitsio_bitpix = CFITSIO_BITPIX;
   cfitsio_naxis  = 2;
   /* modificado por mcharcos */
   /*cfitsio_naxes[ 0 ] = 600;*/
   /*cfitsio_naxes[ 1 ] = 200;*/
   cfitsio_naxes[ 0 ] = 1024;
   cfitsio_naxes[ 1 ] = 1024;
   /* fin de la modificacion por mcharcos */

   (void) fits_create_img( cfitsio_fptr, 
                           cfitsio_bitpix, 
                           cfitsio_naxis, 
                           cfitsio_naxes, 
                           &cfitsio_status ); 

   if ( cfitsio_status != 0 )
   {

#if defined( RTD_FILE_DEBUG )
      msg ( DEBUG, "Couldn't create the HDU for post-integration data.\n" );
      log_cfitsio_errmsg();
#endif

      /* Close the file - don't look at the result as */
      /* the earlier error condition takes precedence */
      cfitsio_status = 0;   
      (void) fits_close_file ( cfitsio_fptr, &cfitsio_status );

      return -6;           /*** ERROR: couldn't create pre-int HDU ***/  
   }


   /*---- WINDOW 1 -----------------------------------------------------------*/
   /*---- Create a new RTDATSEC header set to '[100:699,200:399]'--------------*/
   (void) fits_write_key( cfitsio_fptr, TSTRING, "RTDATSEC", "[100:699,200:399]", 
                          "LIRIS Test File", &cfitsio_status ); 
                            
   if ( cfitsio_status != 0 )
   {

#if defined( RTD_FILE_DEBUG )
      msg ( DEBUG, "Couldn't create the RTDATSEC header. \n" );
      log_cfitsio_errmsg();
#endif

      /* Close the file - don't look at the result as */
      /* the earlier error condition takes precedence */
      cfitsio_status = 0;   
      (void) fits_close_file ( cfitsio_fptr, &cfitsio_status );

      return -3;           /*** ERROR: couldn't create RTDATSEC header ***/ 
   }


   /*---- WINDOW 1 -----------------------------------------------------------*/
   /*---- Write the post-integration image data ------------------------------*/
   (void)  fits_write_img( cfitsio_fptr, 
                           CFITSIO_IMG_DATA_TYPE, 
                           CFITSIO_FIRST_WR_ELEM, 
                           /*modificado por mcharcos el 19/01/04*/
			   /*600*200,*/  
			   1024*1024,
			   /*fin de la modificacion del 19/01/04 de mcharcos*/
                           (void *) p_diff_buf, 
                           &cfitsio_status );

   if ( cfitsio_status != 0 )
   {

#if defined( RTD_FILE_DEBUG )
      msg( DEBUG, "Couldn't write the post-integration data.\n" );
      log_cfitsio_errmsg();
#endif

      /* Close the file - don't look at the result as */
      /* the earlier error condition takes precedence */
      cfitsio_status = 0;   
      (void) fits_close_file ( cfitsio_fptr, &cfitsio_status );
                               
      return -7;              /* ERROR: couldn't write post-integration data */
   }


   /*---- WINDOW 2 -----------------------------------------------------------*/
   /*---- Create an image extension for the post-integration data set --------*/

   cfitsio_bitpix = CFITSIO_BITPIX;
   cfitsio_naxis  = 2;
   /* modificado por mcharcos */
   /*cfitsio_naxes[ 0 ] = 600;*/
   /*cfitsio_naxes[ 1 ] = 200;*/
   cfitsio_naxes[ 0 ] = 1024;
   cfitsio_naxes[ 1 ] = 1024;
   /* fin de la modificacion por mcharcos */

   (void) fits_create_img( cfitsio_fptr, 
                           cfitsio_bitpix, 
                           cfitsio_naxis, 
                           cfitsio_naxes, 
                           &cfitsio_status ); 

   if ( cfitsio_status != 0 )
   {

#if defined( RTD_FILE_DEBUG )
      msg ( DEBUG, "Couldn't create the HDU for post-integration data.\n" );
      log_cfitsio_errmsg();
#endif

      /* Close the file - don't look at the result as */
      /* the earlier error condition takes precedence */
      cfitsio_status = 0;   
      (void) fits_close_file ( cfitsio_fptr, &cfitsio_status );

      return -6;           /*** ERROR: couldn't create pre-int HDU ***/  
   }


   /*---- WINDOW 2 -----------------------------------------------------------*/
   /*---- Create a new RTDATSEC header set to '[300:899,600:799]'--------------*/
   (void) fits_write_key( cfitsio_fptr, TSTRING, "RTDATSEC", "[300:899,600:799]", 
                          "LIRIS Test File", &cfitsio_status ); 
                            
   if ( cfitsio_status != 0 )
   {

#if defined( RTD_FILE_DEBUG )
      msg ( DEBUG, "Couldn't create the RTDATSEC header. \n" );
      log_cfitsio_errmsg();
#endif

      /* Close the file - don't look at the result as */
      /* the earlier error condition takes precedence */
      cfitsio_status = 0;   
      (void) fits_close_file ( cfitsio_fptr, &cfitsio_status );

      return -3;           /*** ERROR: couldn't create RTDATSEC header ***/ 
   }


   /*---- WINDOW 2 -----------------------------------------------------------*/
   /*---- Write the post-integration image data ------------------------------*/
   (void)  fits_write_img( cfitsio_fptr, 
                           CFITSIO_IMG_DATA_TYPE, 
                           CFITSIO_FIRST_WR_ELEM, 
                           /*modificado por mcharcos el 19/01/04*/
			   /*600*200,*/  
			   1024*1024,
			   /*fin de la modificacion del 19/01/04 de mcharcos*/
                           (void *) p_diff_buf, 
                           &cfitsio_status );

   if ( cfitsio_status != 0 )
   {

#if defined( RTD_FILE_DEBUG )
      msg( DEBUG, "Couldn't write the post-integration data.\n" );
      log_cfitsio_errmsg();
#endif

      /* Close the file - don't look at the result as */
      /* the earlier error condition takes precedence */
      cfitsio_status = 0;   
      (void) fits_close_file ( cfitsio_fptr, &cfitsio_status );
                               
      return -7;              /* ERROR: couldn't write pre-integration data */
   }


   /*---- Close the file -----------------------------------------------------*/
   (void) fits_close_file ( cfitsio_fptr, &cfitsio_status );

   if ( cfitsio_status != 0 )
   {

#if defined( RTD_FILE_DEBUG )
      msg( DEBUG, "Couldn't close specified FITS file %s.\n", p_filename );
      log_cfitsio_errmsg();
#endif

      return -8;              /*** ERROR: Couldn't close file ***/ 
   }


   /*--- If control reaches here return success code -------------------------*/

   return 0;
                              /*** SUCCESS: File written ok ***/ 

} /* file_write_liris */


/*- Local functions ----------------------------------------------------------*/

/*--------------------------------------------------------------------*/
/* Function name : load_image                                         */
/*                                                                    */
/* Passed        : cfitsio_ptr - CFITSIO file handle                  */
/*                                                                    */
/*                 num_ext     - number of FITS image extensions      */
/*                               to be read (1...N)                   */
/*                                                                    */
/*                 p_image_buf - pointer to buffer for building       */
/*                               reconstructed 2D image               */
/*                                                                    */
/* Returned      : int =  0 - Success                                 */
/*                     = -1 - Failure                                 */
/*                                                                    */
/* Description   : Reconstruct 2D image from FITS image extension     */
/*                 data.                                              */
/*                                                                    */
/* Notes:                                                             */
/*                                                                    */
/*   [1]  The cfitsio_cptr must be associated with a file which has   */
/*        already be opened by CFITSIO.                               */
/*                                                                    */
/*   [2]  The image data is read starting at the current CFITSIO HDU. */
/*        Additional HDU's are read for each FITS image extension.    */
/*                                                                    */
/*   [3]  If a call to this routine fails the data in p_image_buf     */
/*        may be corrupted.                                           */
/*                                                                    */
/*   [4]  No attempt is made to close the file on failure. That is    */
/*        left to the calling routine.                                */
/*                                                                    */
/*--------------------------------------------------------------------*/

static int load_image( fitsfile *cfitsio_fptr, int num_ext,
            Pixel *p_image_buf )
{

   /* The following defines a buffer for holding data read from the */
   /* FITS image extension. It is declared as static for reasons of */
   /* efficiency.                                                   */

   static ImgExtData img_ext_data;


   int  cfitsio_hdutype; /* Dummy call parameter - return value not used */
   int  cfitsio_status;  /* cfitsio return status */
   int  ext_index;       /* image extension iterator */


   /* Clear error status */
   cfitsio_status = 0;
   
#if defined( RTD_FILE_DEBUG )
     
   msg ( DEBUG, "**** FUNC : load_image\n");
   msg ( DEBUG, "(%lu, %d, %lu) \n", cfitsio_fptr, num_ext, p_image_buf);
#endif


   /* Load requested number of image extensions */
   for ( ext_index = 1; ext_index <= num_ext; ext_index++ )
   {
      /* Attempt to load an image extension. If there was a problem */
      /* terminate processing with error.                           */
      if ( load_image_extension( cfitsio_fptr, &img_ext_data ) != 0 )
      {

#if defined( RTD_FILE_DEBUG )
         msg( DEBUG, "Failed to load FITS image extension.\n" );
#endif

         return -1;           /*** ERROR: failed to read file data ***/
      }


      /* Map the image etxension data to the appropriate place */
      /* in the image buffer.                                  */
      map_image_extension_data( &img_ext_data, p_image_buf );


      /* If more windows to read then seek to the next image extension HDU */
      if ( ext_index < num_ext )
      {
         (void) fits_movrel_hdu( cfitsio_fptr, 1, 
                                 &cfitsio_hdutype, &cfitsio_status );
   
         /* If there was a problem terminate processing with error */
         if ( cfitsio_status != 0 )
         {
   
#if defined( RTD_FILE_DEBUG )
            msg( DEBUG, "CFITSIO couldn't move forward to next HDU\n" );
            log_cfitsio_errmsg();
#endif
   
            return -1;        /*** ERROR: failed to move to next HDU */
         }
      }

   } /* for */


   /* If control passes here the data was read ok */

   return 0;                 /*** SUCCESS: file read ok ***/

} /* load_image */


/*--------------------------------------------------------------------*/
/* Function name : load_image_extension                               */
/*                                                                    */
/* Passed        : cfitsio_ptr - CFITSIO file handle                  */
/*                                                                    */
/*               : p_img_ext_data - pointer to buffer for storing     */
/*                                  FITS image extension data         */
/*                                                                    */
/* Returned      : int =  0 - Success                                 */
/*                     = -1 - Failure                                 */
/*                                                                    */
/* Description   : Load FITS image extension data from FITS file      */
/*                                                                    */
/* Notes:                                                             */
/*                                                                    */
/*   [1]  The cfitsio_cptr must be associated with a file which has   */
/*        already be opened by CFITSIO.                               */
/*                                                                    */
/*   [2]  The image data is read from the current CFITSIO HDU.        */
/*                                                                    */
/*   [3]  The data is loaded into the ImgExtData data structure       */
/*        pointed to by p_img_ext_data.                               */
/*                                                                    */
/*   [4]  No attempt is made to close the file on failure. That is    */
/*        left to the calling routine.                                */
/*                                                                    */
/*--------------------------------------------------------------------*/

/* Definition for fits_get_img_param() routine used locally in this function */

#define LIRIS_FILE_MAX_NAXIS    2

static int load_image_extension( fitsfile *cfitsio_fptr, 
                                     ImgExtData *p_img_ext_data )
{

   char cfitsio_value_buf[ FLEN_VALUE ];     /* FLEN_VALUE and FLEN_COMMENT */
   char cfitsio_comment_buf[ FLEN_COMMENT ]; /* are defined in "fitsio.h"   */

   int  cfitsio_anynul;   /* Dummy call parameter - return value not used */

   int  cfitsio_status;                      /* cfitsio return status */

   long  cfitsio_num_pixels; /* variable defining number of pixels to be read */
                            /* from the image extension. This is initialised */

   int  cfitsio_bitpix;                    /* used by fits_create_img to  */
   int  cfitsio_naxis;                     /* create FITS image extension */
   long cfitsio_naxes[ LIRIS_FILE_NAXIS ]; /* HDU's			  */

   int  x1, y1;                        /* Holds image descriptor values	*/
   int  x2, y2;                        /* extracted from 'RTDATSEC' header */

   int  num_converted;         


#if defined( RTD_FILE_DEBUG )

   msg( DEBUG, " ****** FUNC: load_image_extension\n");
   msg( DEBUG, "(%lu, %lu)\n", cfitsio_fptr, p_img_ext_data);
#endif   
   /* Clear the CFITSIO error status */
   cfitsio_status = 0;
   
      
#if defined( RTD_FILE_DEBUG )

   msg( DEBUG, " LLAMADA A fits_get_img_param\n");
   msg( DEBUG, "(%lu, 2, %lu, %lu %lu, %lu))\n",
      cfitsio_fptr, &cfitsio_bitpix, &cfitsio_naxis, cfitsio_naxes,
                              &cfitsio_status ); 
#endif			      
			      
   /* Read the keywords that define the type and size of the image */
   (void) fits_get_img_param( cfitsio_fptr, 
                              LIRIS_FILE_MAX_NAXIS,
                              &cfitsio_bitpix,
                              &cfitsio_naxis, cfitsio_naxes,
                              &cfitsio_status ); 

   if ( cfitsio_status != 0 )
   {
    
#if defined( RTD_FILE_DEBUG )
      msg( DEBUG, "CFITSIO couldn't read 'BITPIX', 'NAXIS', 'NAXIS1', 'NAXIS2' in FITS image extension.\n" );
      log_cfitsio_errmsg();
#endif

      return -1;          /*** ERROR: Couldn't read image descriptors ***/
   }


   /* Validate the image descriptor 'BITPIX' and 'NAXIS' keywords */
   if ( ( cfitsio_bitpix != CFITSIO_BITPIX ) || 
        ( cfitsio_naxis  != LIRIS_FILE_NAXIS ) )
   {

#if defined( RTD_FILE_DEBUG )
      msg( DEBUG, "Invalid 'BITPIX' or 'NAXIS' in FITS image extension.\n" );
#endif

      return -1;          /*** ERROR: Illegal image descriptors ***/

   }


   /* Determine the extent of the data (by means of the RTDATSEC keyword) */
   (void) fits_read_key( cfitsio_fptr, TSTRING, "RTDATSEC", 
                         cfitsio_value_buf, 
                         cfitsio_comment_buf, 
                         &cfitsio_status ); 
   if ( cfitsio_status != 0 )
   {
    
#if defined( RTD_FILE_DEBUG )
      msg( DEBUG, "'The RTDATSEC' keyword was not present in FITS image extension.\n" );
      log_cfitsio_errmsg();
#endif

      return -1;          /*** ERROR: 'RTDATSEC' keyword not found ***/
   }


   /* Parse the 'RTDATSEC' value string to determine the descriptor */
   /* values (x1, x2, y1, y2) describing the data in the image.    */
   num_converted = sscanf( cfitsio_value_buf, "[%d:%d,%d:%d]", &x1, &x2, &y1, &y2 );
   if ( num_converted != 4 )
   {
#if defined( RTD_FILE_DEBUG )
      msg( DEBUG, "Couldn't parse 'RTDATSEC' value string in FITS image extension.\n" );
#endif

      return -1;          /*** ERROR: Couldn't parse 'RTDATSEC' value string ***/
   }


   /* Check the image descriptor information read previously */
   /* is consistent with the 'RTDATSEC' descriptor.           */
   if ( ( cfitsio_naxes[ 0 ] != ( x2 - x1 + 1 ) ) ||
        ( cfitsio_naxes[ 1 ] != ( y2 - y1 + 1 ) ) )
   {

#if defined( RTD_FILE_DEBUG )
      msg( DEBUG, "'RTDATSEC' was inconsistent with 'NAXIS', 'NAXIS1', 'NAXIS2' in FITS image extension.\n" );
#endif

      return -1;          /*** ERROR: 'RTDATSEC' / image data inconsistent ***/

   }
 
    /* Check the data buffers is big enough to hold the data in the extension */ 
    cfitsio_num_pixels = cfitsio_naxes[ 0 ] * cfitsio_naxes[ 1 ];

   if ( cfitsio_num_pixels > LIRIS_FILE_MAX_IMAGE_SIZE )
   {
#if defined( RTD_FILE_DEBUG )
      msg( DEBUG, "Number of pixels in FITS image extension exceeded buffer size.\n" );
#endif
   }

#if defined( RTD_FILE_DEBUG )
  msg( DEBUG, "LLAMADA fits_read_img \n" );
  msg( DEBUG, "(%lu, TFLOAT, 1, %lu, 0, %lu, %lu , %lu)\n",
   cfitsio_fptr , cfitsio_num_pixels, p_img_ext_data->fits_pixel_data,
   &cfitsio_anynul, &cfitsio_status);
#endif   
	  
   /* Read the image data within the current HDU */
   (void)  fits_read_img( cfitsio_fptr, 
                          CFITSIO_IMG_DATA_TYPE, 
                          (long) CFITSIO_FIRST_RD_ELEM, 
                          cfitsio_num_pixels, 
                          CFITSIO_SKIP_NULCHK, 
                          (void *) p_img_ext_data->fits_pixel_data, 
                          &cfitsio_anynul, &cfitsio_status );


   /* If there was a problem terminate processing with error */
   if ( cfitsio_status != 0 )
   {

#if defined( RTD_FILE_DEBUG )
      msg( DEBUG, "Failed to read pixel data from FITS image extension.\n" );
      log_cfitsio_errmsg();
#endif

      return -2;          /*** ERROR: failed to read image data ***/
   }
   

   /* Map the image data onto the relevant portion of the  */
   /* image buffer.                                        */
   p_img_ext_data->region_descriptor.x1 = x1;
   p_img_ext_data->region_descriptor.x2 = x2;
   p_img_ext_data->region_descriptor.y1 = y1;
   p_img_ext_data->region_descriptor.y2 = y2;


   /* If control passes here the data was read ok */
   return 0;              /*** SUCCESS: file image extension loaded ok ***/


} /* load_image_extension */


/*--------------------------------------------------------------------*/
/* Function name : map_image_extension_data                           */
/*                                                                    */
/* Passed        : p_img_ext_data - pointer to buffer containing      */
/*                                  FITS image extension data         */
/*                                                                    */
/*                 p_image_buf    - pointer to buffer for storing     */
/*                                  translated data                   */
/*                                                                    */
/* Returned      : None                                               */
/*                                                                    */
/* Description   : Reconstructs (part of) the full image using the    */
/*                 data read from the supplied FITS image extension.  */
/*                                                                    */
/* The data structure pointed to by p_img_ext_data is of type         */
/* "ImgExtData". This contains two sub-structures used as follows.    */
/*                                                                    */
/* The "fits_pixel_data" structure contains the raw FITS pixel data   */
/* read from the file.                                                */
/*                                                                    */
/* The "region_descriptor" structure provides four values of the      */
/* form "[x1, x2, y1, y2]". These govern the translation as           */
/* follows:                                                           */
/*                                                                    */
/*    (x1, y1) specifies where the FIRST pixel in "fits_pixel_data"   */
/*             is located in terms of its 2D coordinates in the image */
/*             buffer p_image_buf.                                    */
/*                                                                    */
/*    (x2, y2) specifies where the LAST pixel in "fits_pixel_data"    */
/*             located in terms of its 2D coordinates in the image    */
/*             buffer p_image_buf.                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/

static void map_image_extension_data( const ImgExtData *p_img_ext_data, 
                                      Pixel *p_image_buf )
{

   int x_idx, y_idx;               /* Iterators for addressing  */
                                   /* fits pixel data buffer as */
                                   /* 2D array                  */
                                  
   int x1, y1;                     /* Coords of first and last  */
   int x2, y2;                     /* pixels in fits buffer in  */
                                   /* terms of image coords     */ 

   FITSPixel *p_fits_pixel_buf;    /* pointer to fits pixel data */

#if defined( RTD_FILE_DEBUG )
   msg( DEBUG, " ******FUNC: map_image_extension_data\n");
   msg (DEBUG, " (%lu, %lu)\n", p_img_ext_data, p_image_buf);
#endif
   
   /* Extract image descriptors from supplied data structure */
   /* We substract one in order to work with C like indexex  */
   /* (stating at zero and not at one )                      */
   
   x1 = p_img_ext_data->region_descriptor.x1 -1;
   x2 = p_img_ext_data->region_descriptor.x2 -1;
   y1 = p_img_ext_data->region_descriptor.y1 -1 ;
   y2 = p_img_ext_data->region_descriptor.y2 -1;
   
#if defined( RTD_FILE_DEBUG )   
   msg (DEBUG, " (x1= %d, x2= %d) (y1=%d y2=%d) \n", x1,x2,y1,y2);
#endif


   /* Set up pointer to start of FITS pixel data */
   p_fits_pixel_buf = (FITSPixel *) p_img_ext_data->fits_pixel_data;
   
   /* Iterate through all pixels in the fits pixel data buffer */
   for ( y_idx = y1; y_idx <= y2; y_idx++ )
   {
      for ( x_idx = x1; x_idx <= x2; x_idx++ )
      {
          /* If the image coord is within the bounds of the 2D image */
          /* held in p_fits_buf then copy it across                  */
          if ( ( x_idx >= 0 ) && ( x_idx <= XDETPIX ) &&
               ( y_idx >= 0 ) && ( y_idx <= YDETPIX ) )
          {
#ifdef ORIG
             p_image_buf[ (y_idx - y1) * YDETPIX + 
                          (x_idx - x1) ] = *p_fits_pixel_buf;
#endif
             p_image_buf[ (y_idx * YDETPIX) + x_idx ] = *p_fits_pixel_buf;
	     	     	   
#if defined( RTD_FILE_DEBUG )   	     
	    msg(DEBUG, "coord[%d, %d]= %f\t", x_idx, y_idx,
	              p_image_buf[ (y_idx * YDETPIX) + x_idx ]  );
#endif
          }

          p_fits_pixel_buf++;
      }
   }

} /* map_image_extension_data */

#if defined( RTD_FILE_DEBUG )

/*--------------------------------------------------------------------*/
/* Function name : log_cfitsio_errmsg                                 */
/*                                                                    */
/* Passed        : None                                               */
/* Returned      : None                                               */
/*                                                                    */
/* Description   : Dump CFITSIO error stack                           */
/*                                                                    */
/*--------------------------------------------------------------------*/

static void log_cfitsio_errmsg( void )
{
   char cfitsio_errmsg[ FLEN_ERRMSG ];
   

   msg( DEBUG, "The CFITSIO error stack was as follows...\n" );

   while ( fits_read_errmsg( cfitsio_errmsg ) != 0 )
   {
      msg( DEBUG, "%s\n", cfitsio_errmsg );
   }

   msg( DEBUG, "CFITSIO error stack - now empty.\n" );


} /* log_cfitsio_errmsg */

#endif
