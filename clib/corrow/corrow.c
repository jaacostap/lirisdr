#include <stdio.h>
#include <sys/stat.h>      /* contains stat function        */
#include <string.h>      /* contains stat function        */

#include "global.h"
#include "portable.h"
#include "corrow.h"
#include "lirisfits.h"

#include "fitsio.h"        /* interface to 3rd party CFITSIO library */
                           /* see Makefile for linkage details.      */
      


/* ----------------------------------------------------------------------
**    CORROW: Allow to ...
**    
------------------------------------------------------------------------*/

/*
    
    Functions:
     
     corrow_get_quadrant()        - is used to load portion of buffer in memory subbuffer
                
     corrow_put_quadrant()        - is used to save subbufer in portion of buffer
     
     corrow_load_extensions()     - is used to read extensions of an image

     corrow_save_extensions()     - is used to create an images with extensions

     corrow_copy_extensions()     - is used to create an images near other one
     
     file_is_fit ()		  - check if image format is correct
     
     check_stormode ()		  - check stored image mode and change G_Storemode


    External functions:
                
     file_read_liris()		  - lirisfits.h
     
     file_write_liris()		  - lirisfits.h
     
     
    
	

*/


/*- Local macros -------------------------------------------------------------*/

/* LIRIS_FILE_MIN_SIZE is used by the file_is_liris() function      */
/* to test whether a file is LIRIS compatible. Files smaller than   */
/* the value set here (in bytes) will be rejected.                  */
/*                                                                  */
/* Currently (05/20/03) the value has been chosen such that a file  */
/* must contain at least two FITS HDU's. The minimum HDU size is    */
/* 2880 bytes.                                                      */
/* This constant is also defined in lirisfits.c			    */
#define LIRIS_FILE_MIN_SIZE          (2 * 2880) 


/*- Local typedefs, structures and unions ------------------------------------*/
/* Variables for image allocation */
Pixel		*p_sub_image;
PixelBuffer 	Extension1,Extension2;

/*- External data ------------------------------------------------------------*/
/* Mode is initialise when file_is_liris call */
extern short int G_store_mode;     /* Holds the storage mode of fits file  */
                                   /* defined in lirisfits.c */


/*- Externally visible data ------------------------ */


/*- Local function prototypes ------------------------------------------------*/

/* Auxiliar variables */


/* Function declaration */
static short corrow_get_quadrant( Pixel * src_img, short quadrant, \
                                  short offset, Pixel * sub_img);

static short corrow_put_quadrant( Pixel * src_img, short quadrant,Pixel * sub_img);

		
static short corrow_load_extensions( char *p_obs_file );

static short corrow_save_extensions( char *p_obs_file  );

static int corrow_copy_extensions( char *p_obs_file,  char *p_cp_file);

static int check_stormode( const char *p_key_value) ;

static int file_is_fit( const char *p_file_to_check );

/*- Signal catching functions -----------------------------------------------*/
/*- Main --------------------------------------------------------------------*/
/*- Externally visible functions --------------------------------------------*/
/*--------------------------------------------------------------------*/
/* Function name : main                                          */
/*                                                                    */
/* Passed        :                                                    */
/* Returned      : 						      */
/*								      */
/*	*   0 No errors 					      */
/*	*  -1 sub image allocation memory error 		      */
/*	*  -2 interactive process failed			      */
/*	*  -3 sub image aquisition error			      */
/*	*  -4 centroid search process failed	  		      */
/*                                                                    */
/* Description   : find position of a star.                           */
/*                                                                    */ 
/*--------------------------------------------------------------------*/
main (argc, argv)
int	argc;
char	*argv[];
  {
  char 		*fname = NULL,*res_fname=NULL;
	
  /* Process the command line options. */
  if (argc > 3) 
    {
#if defined( CORROW_DEBUG )      
    printf("Too much arguments \n"); 	
#endif    
    exit(-1);
    }
  else 
    {
    fname = argv[1];
    res_fname = argv[2];
    }
	
#if defined( CORROW_DEBUG )      
  printf("Correcting image %15s ... \n",fname); 	
#endif    
  
  /* We verify that type of the image is FITS */
  if (file_is_fit (fname) != 0)
    {
#if defined( CORROW_DEBUG )      
    printf("Image type wrong \n"); 	
#endif  
    exit(-1);
    }
  else
    {  
#if defined( CORROW_DEBUG )      
    printf("Image is correct format \n"); 	
#endif
    } 
    
  /* Load image in Extension1 and Extension2 variables */ 
  /* Depend of G_store_mode */
  if (corrow_load_extensions(fname) != 0)
    {
#if defined( CORROW_DEBUG )                        
    printf("Error cargando imagen \n");
#endif    
    exit(-1);
    }
  else
    {  
#if defined( CORROW_DEBUG )      
    printf("Image loaded \n"); 	
#endif
    }  
    
  /* allocate space for p_sub_image */
  if ( (p_sub_image = (Pixel *) malloc (512 * 512 * sizeof(Pixel)) ) == NULL )  
    {
#if defined( CORROW_DEBUG )      
    printf("Couldn't not allocate memory for sub image \n"); 	
#endif    
    exit(-1);
    } 
  else
    {  
#if defined( CORROW_DEBUG )      
    printf("Sub image memory allocated \n"); 	
#endif
    }  
  
#if defined( CORROW_DEBUG )      
  printf("Correcting quadrant 1 ... \n");
#endif
  corrow_get_quadrant( Extension1, 1, OFFSET1, p_sub_image);
  corrow_put_quadrant( p_sub_image, 1, Extension1);
  corrow_get_quadrant( Extension2, 1, OFFSET1, p_sub_image);
  corrow_put_quadrant( p_sub_image, 1, Extension2);
  
#if defined( CORROW_DEBUG )      
  printf("Correcting quadrant 2 ... \n");
#endif
  corrow_get_quadrant( Extension1, 2, OFFSET2, p_sub_image);
  corrow_put_quadrant( p_sub_image, 2, Extension1);
  corrow_get_quadrant( Extension2, 2, OFFSET2, p_sub_image);
  corrow_put_quadrant( p_sub_image, 2, Extension2);
  
#if defined( CORROW_DEBUG )      
  printf("Correcting quadrant 3 ... \n");
#endif
  corrow_get_quadrant( Extension1, 3, OFFSET3, p_sub_image);
  corrow_put_quadrant( p_sub_image, 3, Extension1);
  corrow_get_quadrant( Extension2, 3, OFFSET3, p_sub_image);
  corrow_put_quadrant( p_sub_image, 3, Extension2);
  
#if defined( CORROW_DEBUG )      
  printf("Correcting quadrant 4 ... \n");
#endif
  corrow_get_quadrant( Extension1, 4, OFFSET4, p_sub_image);
  corrow_put_quadrant( p_sub_image, 4, Extension1);
  corrow_get_quadrant( Extension2, 4, OFFSET4, p_sub_image);
  corrow_put_quadrant( p_sub_image, 4, Extension2);
  
    
  /* Load image in Extension1 and Extension2 variables */ 
  /* Depend of G_store_mode */
  if (corrow_copy_extensions(fname,res_fname) != 0)
    {
#if defined( CORROW_DEBUG )                        
    printf("Error grabando imagen \n");
#endif    
    exit(-1);
    }
  else
    {  
#if defined( CORROW_DEBUG )      
    printf("Image saved \n"); 	
#endif
    }  
    
  }
  

/*--------------------------------------------------------------------
**   FUNCTION NAME
**    corrow_get_quadrant     : It gets a quadrant of an image.
**
**   INVOCATION
**    short corrow_get_quadrant( Pixel * src_img, 
**                               short quadrant,
**                               short offset,
**                               Pixel * sub_img)
**
**   PARAMETERS IN
**    Pixel * p_src_img : Pointer to source image
**    short quadrant: quadrant to extract
**    short offset: number of pixel to be shifted
**
**   PARAMETERS OUT
**     Pixel * p_sub_img  : Buffer holding the reult image
**
**   FUNCTION RETURN
**	  0  if NO-errors
**	  -1 if failed
**
**   GLOBAL VARIABLES
**
**
**   EXTERNAL VARIABLES
**
**
**   CALLED FUNCTIONS
**
 --------------------------------------------------------------------*/ 
/************************* 
quadrants: 
     _________
    |    |    |
    |  4 |  3 |
    |____|____|
    |    |    |
    |  1 | 2  |
    | ___|____|

**************************/

 
static short corrow_get_quadrant( Pixel * src_img, short quadrant, \
				short offset, Pixel * sub_img)		 
  {
  Pixel * p_sub_img;       /* Point to the current position in the buffer */
  Pixel * p_sub_img_aux;   /* Auxiliar point to the current position in the buffer */
  Pixel * p_ini_img;       /* Point to the initial position in the buffer */
  Pixel * p_sub;           /* Point to the current position in the subbuffer */
  Pixel * p_sub_last_pix;  /* Point to the last position copied in the buffer */
  
  
  short line_size =  512 * sizeof(Pixel);
  short sub_line_size =  (512 - offset) * sizeof(Pixel);
  short offset_size = offset * sizeof(Pixel);
  
  /* verify if correct quadrant and determine limits*/
  switch ( quadrant )
   {
      case 1:
         p_sub = sub_img;
	 p_ini_img = src_img;
	 p_sub_img = p_ini_img + offset;
	 p_sub_last_pix = p_sub_img + 511 * 1024 ;
         break;
	 
      case 2:
         p_sub = sub_img;
	 p_ini_img = src_img + 512;
	 p_sub_img = p_ini_img + offset;
	 p_sub_last_pix = p_sub_img + 511 * 1024 ;
         
         break;	 

      case 3:
         p_sub = sub_img;
	 p_ini_img = src_img + 1024 * 512;
	 p_sub_img = p_ini_img + offset;
	 p_sub_last_pix = p_sub_img + 511 * 1024 ;
         
         break;

      case 4:
         p_sub = sub_img;
	 p_ini_img = src_img + 512 * 1024 + 512;
	 p_sub_img = p_ini_img + offset;
	 p_sub_last_pix = p_sub_img + 511 * 1024  ;
         
         break;
	 
      default:
#if defined( CORROW_DEBUG )         
         printf(" Invalid quadrant\n");
#endif	 
         return(-1);
   }
  
 
  /* We copy all lines except last because we want copy first */
  /*offset pixels in last position */ 
  for ( ; p_sub_img < p_sub_last_pix; p_sub_img += 1024 )
    {
    memcpy ( p_sub, p_sub_img, sub_line_size );
    p_sub += 512 - offset ;
    p_sub_img_aux = p_sub_img + 1024 - offset;
    memcpy ( p_sub, p_sub_img_aux, offset_size );
    p_sub += offset ;
    }
  
  /* Now we copy last line*/
  memcpy ( p_sub, p_sub_img, sub_line_size );
  p_sub += (512 - offset) ;
  memcpy ( p_sub, p_ini_img, offset_size );
  
  
  return 0;
      
  } /* end of corrow_get_quadrant */
  

/*--------------------------------------------------------------------
**   FUNCTION NAME
**    corrow_put_quadrant     : It gets a quadrant of an image.
**
**   INVOCATION
**    short corrow_put_quadrant( Pixel * src_img, short quadrant,Pixel * sub_img)
**
**   PARAMETERS IN
**    Pixel * p_sub_img  : Buffer holding the reult image
**    short quadrant: quadrant to extract
**
**   PARAMETERS OUT
**    Pixel * p_src_img : Pointer to source image
**
**   FUNCTION RETURN
**	  0  if NO-errors
**	  -1 if failed
**
**   GLOBAL VARIABLES
**
**
**   EXTERNAL VARIABLES
**
**
**   CALLED FUNCTIONS
**
 --------------------------------------------------------------------*/ 
/************************* 
quadrants: 
     _________
    |    |    |
    |  4 |  3 |
    |____|____|
    |    |    |
    |  1 | 2  |
    | ___|____|

**************************/

 
static short corrow_put_quadrant( Pixel * sub_img, short quadrant, Pixel * src_img)		 
  {
  Pixel * p_sub_img;       /* Point to the current position in the buffer */
  Pixel * p_sub;           /* Point to the current position in the subbuffer */
  Pixel * p_sub_last_pix;  /* Point to the last position copied in the buffer */
  
  
  short line_size =  512 * sizeof(Pixel);
  
  /* verify if correct quadrant and determine limits*/
  switch ( quadrant )
   {
      case 1:
         p_sub = sub_img;
	 p_sub_img = src_img ;
	 p_sub_last_pix = p_sub_img + 512 * 1024 ;
         break;
	 
      case 2:
         p_sub = sub_img;
	 p_sub_img = src_img + 512 ;
	 p_sub_last_pix = p_sub_img + 512 * 1024 ;
         
         break;	 

      case 3:
         p_sub = sub_img;
	 p_sub_img = src_img + 1024 * 512 ;
	 p_sub_last_pix = p_sub_img + 512 * 1024 ;
         
         break;

      case 4:
         p_sub = sub_img;
	 p_sub_img = src_img + 512 * 1024 + 512 ;
	 p_sub_last_pix = p_sub_img + 512 * 1024  ;
         
         break;
	 
      default:
#if defined( CORROW_DEBUG )         
         printf(" Invalid quadrant\n");
#endif	 
         return(-1);
   }
  
 
  /* We copy all lines except last because we want copy first */
  /*offset pixels in last position */ 
  for ( ; p_sub_img < p_sub_last_pix; p_sub_img += 1024 )
    {
    memcpy ( p_sub_img, p_sub, line_size );
    p_sub += 512 ;
    }
  
  
  return 0;
      
  } /* end of corrow_put_quadrant */


/*--------------------------------------------------------------------*/
/* Function name : corrow_load_extensions                             */
/*                                                                    */
/* Passed        : p_obs_file - name of observation file to be loaded */
/*                                                                    */
/* Returned      : int =  0 - Success                                 */
/*                  = -1 - Error : couldn't open file		      */
/*                  = -2 - Error : invalid number of windows	      */
/*                  = -3 - Error : invalid number of hdu's	      */
/*                  = -4 - Error : NO NRAMPRDS keyword                */
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
/* Uses          : OBS_pre,    - buffers for OBS pre and              */
/*                 OBS_post      post integration data                */
/*                 OBS_diff      diff integration data                */
/*                 OBS_slope   - buffer for OBS slope data            */
/*                 OBS_first_ramp - buffer for OBS first ramp read    */
/*                 OBS_last_ramp  - buffer for OBS last ramp read     */
/*                 OBS_REF_sub - buffer for OBS-REF subtracted total  */
/*                               For MNDR the diff buffers are        */
/*                               substracted. More RAMPS, the slope   */
/*                               buffers are substracted.             */
/*                                                                    */
/* Description   : load observation data file into local pixel        */
/*                 buffers                                            */
/*                                                                    */
/* Note: Errors -4 and -13 result in possible corruption of the data  */
/* previously existing in the internal OBS data buffers.              */
/*                                                                    */
/*--------------------------------------------------------------------*/

static short corrow_load_extensions( char *p_obs_file  )
{
   short result;   
   char  current_filename[ FILESYS_NAME_ALLOC_SIZE ];
   
#if defined( CORROW_DEBUG )               
     printf(" *****FUNC: corrow_load_extensions  \n");
     printf(" ( %s)\n", p_obs_file);
#endif     

   /* Build complete file pathname in current_name array using the */
   /* the global var G_data_dir */ 
   (void) strcpy( current_filename, p_obs_file );
   

   switch (G_store_mode)
   {
     case DIFF:
       if ((result = file_read_liris(current_filename, Extension1,
                                NULL, NULL, NULL, NULL, NULL)) != 0 )    
         {
#if defined( CORROW_DEBUG )                        
         printf ("file_read_liris OBS DIFF error %d\n", result);
#endif
	 
         return result;
         }
       else
         {
#if defined( CORROW_DEBUG )                        
         printf ("file_read_liris DIFF adquisition type \n");
#endif
         }
       break;
           
     case DIFF_PRE:
        if ((result = file_read_liris(current_filename, Extension1,
                                Extension2, NULL, NULL, NULL, NULL)) != 0 )    
          {
#if defined( CORROW_DEBUG )                        	
          printf ("file_read_liris OBS DIFF_PRE error %d\n", result);
#endif
          return result;
          }
        else
          {
#if defined( CORROW_DEBUG )                        
         printf ("file_read_liris DIFF_PRE adquisition type \n");
#endif
          }
        break;     
     
     case PRE_POST: 
        if ((result = file_read_liris(current_filename, NULL,
                                Extension1, Extension2, NULL, NULL, NULL)) != 0 )    
          {
#if defined( CORROW_DEBUG )                        		
          printf ("file_read_liris OBS PRE_POST error %d\n", result);
#endif
          return result;
          }
        else
          {
#if defined( CORROW_DEBUG )                        
          printf ("file_read_liris PRE_POST adquisition type \n");
#endif
          }
        break;        
	  
     default: 
        {
#if defined( CORROW_DEBUG )                        		
        printf ("Store mode does not recognised \n");
#endif   
         return -1;
         }
   }/* end of switch */

   /* If control reaches here return success code */
   return 0;

} /* corrow_load_extensions */


/*--------------------------------------------------------------------*/
/* Function name : corrow_save_extensions                             */
/*                                                                    */
/* Passed        : p_obs_file - name of observation file to be loaded */
/*                                                                    */
/* Returned      : int =  0 - Success                                 */
/*                  = -1 - Error : couldn't open file		      */
/*                  = -2 - Error : invalid number of windows	      */
/*                  = -3 - Error : invalid number of hdu's	      */
/*                  = -4 - Error : NO NRAMPRDS keyword                */
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
/* Uses          : OBS_pre,    - buffers for OBS pre and              */
/*                 OBS_post      post integration data                */
/*                 OBS_diff      diff integration data                */
/*                 OBS_slope   - buffer for OBS slope data            */
/*                 OBS_first_ramp - buffer for OBS first ramp read    */
/*                 OBS_last_ramp  - buffer for OBS last ramp read     */
/*                 OBS_REF_sub - buffer for OBS-REF subtracted total  */
/*                               For MNDR the diff buffers are        */
/*                               substracted. More RAMPS, the slope   */
/*                               buffers are substracted.             */
/*                                                                    */
/* Description   : load observation data file into local pixel        */
/*                 buffers                                            */
/*                                                                    */
/* Note: Errors -4 and -13 result in possible corruption of the data  */
/* previously existing in the internal OBS data buffers.              */
/*                                                                    */
/*--------------------------------------------------------------------*/

static short corrow_save_extensions( char *p_obs_file  )
{
   short result;   
   char  current_filename[ FILESYS_NAME_ALLOC_SIZE ];
   
#if defined( CORROW_DEBUG )               
     printf(" *****FUNC: corrow_save_extensions  \n");
     printf(" ( %lu)\n", p_obs_file);
#endif     

   /* Build complete file pathname in current_name array using the */
   /* the global var G_data_dir */ 
   (void) strcpy( current_filename, p_obs_file );


   switch (G_store_mode)
   {
     case DIFF:
      if ((result = file_write_liris( current_filename, Extension1,
                       Extension1 )) != 0 )    
      {
#if defined( CORROW_DEBUG )                        
         printf ("file_read_liris OBS DIFF error %d\n", result);
#endif
	 
         return result;
      }
      break;
           
     case DIFF_PRE:
       if ((result = file_write_liris( current_filename, Extension1,
                       Extension2 )) != 0 )    
       {
#if defined( CORROW_DEBUG )                        	
         printf ("file_read_liris OBS DIFF_PRE error %d\n", result);
#endif
        return result;
        }
      break;     
     
     case PRE_POST: 
       if ((result = file_write_liris( current_filename, Extension1,
                       Extension2 )) != 0 )    
       {
#if defined( CORROW_DEBUG )                        		
        printf ("file_read_liris OBS PRE_POST error %d\n", result);
#endif
       return result;
       }
       break;        
	  
     default: 
       {
#if defined( CORROW_DEBUG )                        		
       printf ("Store mode does not recognised \n");
#endif   
       return -1;
       }
   }/* end of switch */

   /* If control reaches here return success code */
   return 0;

} /* corrow_save_extensions */
 

/*--------------------------------------------------------------------*/
/* Function name : corrow_copy_extensions                             */
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

#define CFITSIO_FIRST_WR_ELEM    1L   /* First data element has index value 1 */

static int corrow_copy_extensions( char *p_obs_file,  char *p_cp_file)

{
   fitsfile *cfitsio_fptr;                        /* cfitsio file handle   */
   fitsfile *cfitsio_fptr_obs;                    /* cfitsio reference file */
   int       cfitsio_status;                      /* cfitsio return status */

   int       cfitsio_bitpix;                      /* used by fits_create_img to  */
   int       cfitsio_naxis;                       /* create FITS image extension */
   long      cfitsio_naxes[ 2 ];  		  /* HDU's                       */

   int        num_hdu,hdu_type;


  /*--- Set up CFITSIO library ready for use --------------------------------*/
  cfitsio_status = 0;	
   
  cfitsio_bitpix = 8; 

  /*---- Open the specified FITS file using the CFITSIO library -------------*/
  (void) fits_create_file ( &cfitsio_fptr, p_cp_file,  &cfitsio_status );

  if ( cfitsio_status != 0 )
    {
#if defined( CORROW_DEBUG )
    printf("Couldn't create specified FITS file (%s).\n", p_cp_file );
#endif
    return -1;              /*** ERROR: couldn't create FITS file ***/
    }

    /* Header copy of original image */
  /* Open the reference FITS file using the CFITSIO library */
  /* This file will be used to write headers */
  (void) fits_open_file ( &cfitsio_fptr_obs, p_obs_file, 
                            READONLY, &cfitsio_status );

  if ( cfitsio_status != 0 )
    {
#if defined( CORROW_DEBUG )
    printf("Couldn't open reference FITS file (%s).\n", p_obs_file );
#endif
    return -1;              /*** ERROR: couldn't open FITS file ***/
    }

    
  /*---- Create the Primary HDU ---------------------------------------------*/
  cfitsio_naxis  = 0;

  
  /* Reference image header 1 is copied to extension1 */
  fits_copy_header(cfitsio_fptr_obs,cfitsio_fptr, &cfitsio_status);

  if ( cfitsio_status != 0 )
    {
#if defined( CORROW_DEBUG )
    printf("Couldn't copy header (%s) to (%s).\n", p_obs_file,p_cp_file );
#endif
    return -1;              /*** ERROR: couldn't copy header ***/
    }

  
  /*---- Create a new field of header ('CORROW') set to 'QUADR' */
  (void) fits_write_key( cfitsio_fptr, TSTRING, "CORROW", "QUADR", 
                          "LIRIS bad row correction", &cfitsio_status ); 
                            
  if ( cfitsio_status != 0 )
    {
#if defined( CORROW_DEBUG )
    printf("Couldn't create the CORROW header. \n" );
#endif

     /* Close the file - don't look at the result as */
     /* the earlier error condition takes precedence */
     cfitsio_status = 0;   
     (void) fits_close_file ( cfitsio_fptr, &cfitsio_status );

     return -3; 	  /*** ERROR: couldn't create CORROW header ***/ 
     }
  
/*
  (void) fits_create_img( cfitsio_fptr, 
  			  cfitsio_bitpix, 
  			  cfitsio_naxis, 
  			  cfitsio_naxes, 
  			  &cfitsio_status ); 
  			   
  if ( cfitsio_status != 0 )
    {
#if defined( CORROW_DEBUG )
    printf("Couldn't create the Primary HDU.\n" );
#endif
*/
    /* Close the file - don't look at the result as */
    /* the earlier error condition takes precedence */
/*    cfitsio_status = 0;   
    (void) fits_close_file ( cfitsio_fptr, &cfitsio_status );

    return -2;*/           /*** ERROR: couldn't create Primary HDU ***/
    /*}*/


  
  /* We copy image extensions */
  /* Setup */
  cfitsio_naxis  = 2;
  cfitsio_naxes[ 0 ] = 1024;
  cfitsio_naxes[ 1 ] = 1024;
  cfitsio_bitpix = -32; /*sizeof(Pixel);*/
       
     
  /*---- Create an image extension for first extension data set ---------*/
/*  (void) fits_create_img( cfitsio_fptr, 
                          cfitsio_bitpix, 
                          cfitsio_naxis, 
                          cfitsio_naxes, 
                          &cfitsio_status ); 
                            
  if ( cfitsio_status != 0 )
    {
#if defined( CORROW_DEBUG )
     printf("Couldn't create the HDU for first extension data.\n" );
#endif
*/
    /* Close the file - don't look at the result as */
    /* the earlier error condition takes precedence */
/*    cfitsio_status = 0;   
    (void) fits_close_file ( cfitsio_fptr, &cfitsio_status );

    return -4;*/  	 /*** ERROR: couldn't create pre-int HDU ***/ 
    /*}*/

  fits_movabs_hdu (cfitsio_fptr_obs,2,&hdu_type,&cfitsio_status );
  /* Reference image header 1 is copied to extension1 */
  fits_copy_header(cfitsio_fptr_obs,cfitsio_fptr, &cfitsio_status);

  if ( cfitsio_status != 0 )
    {
#if defined( CORROW_DEBUG )
    printf("Couldn't copy header (%s) to (%s).\n", p_obs_file,p_cp_file );
#endif
    return -1;              /*** ERROR: couldn't copy header ***/
    }



  /* Write the first extension image data --------------------------------*/
  (void) fits_write_img( cfitsio_fptr, 
  			 TFLOAT, 
  			 CFITSIO_FIRST_WR_ELEM, 
        		 1024*1024,
  			 (void *) Extension1, 
  			 &cfitsio_status );

  if ( cfitsio_status != 0 )
    {
#if defined( CORROW_DEBUG )
    printf("Couldn't write the first extension data.\n" );
#endif

    /* Close the file - don't look at the result as */
    /* the earlier error condition takes precedence */
    cfitsio_status = 0;   
    (void) fits_close_file ( cfitsio_fptr, &cfitsio_status );
    			     
    return -5;  	 /* ERROR: couldn't write first extension data */
    }


  

  /*---- Create an image extension for second extension data set ---------*/
  /*---- Only if G_store_mode is not DIFF*/

  if (G_store_mode != DIFF)
    {
    /*  (void) fits_create_img( cfitsio_fptr, 
    	     	        	cfitsio_bitpix,
    	     	        	cfitsio_naxis,
    	     	        	cfitsio_naxes,
    	     	        	&cfitsio_status );
                            
    if ( cfitsio_status != 0 )
      {
#if defined( CORROW_DEBUG )
      printf("Couldn't create the HDU for second extension data.\n" );
#endif
*/
      /* Close the file - don't look at the result as */
      /* the earlier error condition takes precedence */
/*     cfitsio_status = 0;   
      (void) fits_close_file ( cfitsio_fptr, &cfitsio_status );

      return -4; */ 	  /*** ERROR: couldn't create pre-int HDU ***/ 
      /*}*/


    fits_movabs_hdu (cfitsio_fptr_obs,2,&hdu_type,&cfitsio_status );
    /* Reference image header 1 is copied to extension1 */
    fits_copy_header(cfitsio_fptr_obs,cfitsio_fptr, &cfitsio_status);

    if ( cfitsio_status != 0 )
      {
#if defined( CORROW_DEBUG )
      printf("Couldn't copy header (%s) to (%s).\n", p_obs_file,p_cp_file );
#endif
      return -1;              /*** ERROR: couldn't copy header ***/
      }

    /*---- Write the second extension image data -------------------------------*/
    (void) fits_write_img( cfitsio_fptr, 
  			 TFLOAT, 
  			 CFITSIO_FIRST_WR_ELEM, 
        		 1024*1024,
  			 (void *) Extension2, 
  			 &cfitsio_status );

    if ( cfitsio_status != 0 )
      {
#if defined( CORROW_DEBUG )
       printf("Couldn't write the second extension data.\n" );
#endif

      /* Close the file - don't look at the result as */
      /* the earlier error condition takes precedence */
      cfitsio_status = 0;   
      (void) fits_close_file ( cfitsio_fptr, &cfitsio_status );
                               
      return -5;           /* ERROR: couldn't write pre-integration data */
      }

    } /* end of if (G_store_mode != DIFF) */


  /*---- Close files -----------------------------------------------------*/
  (void) fits_close_file ( cfitsio_fptr, &cfitsio_status );

  if ( cfitsio_status != 0 )
    {
#if defined( CORROW_DEBUG )
    printf("Couldn't close specified FITS file %s.\n", p_cp_file );
#endif
    return -8;              /*** ERROR: Couldn't close file ***/ 
    }
    
  (void) fits_close_file ( cfitsio_fptr_obs, &cfitsio_status );

  if ( cfitsio_status != 0 )
    {
#if defined( CORROW_DEBUG )
    printf("Couldn't close reference FITS file %s.\n", p_obs_file);
#endif
    return -8;              /*** ERROR: Couldn't close file ***/ 
    }

  /*--- If control reaches here return success code -------------------------*/

  return 0;
                              /*** SUCCESS: File written ok ***/ 

} /* corrow_copy_extensions */



/*--------------------------------------------------------------------*/
/* Function name : file_is_fit                                      */
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
       
int file_is_fit( const char *p_file_to_check )
  {
  struct stat filestat;

  fitsfile   *cfitsio_fptr;
  int	      cfitsio_status;

  char   cfitsio_value_buf[ FLEN_VALUE ];     /* FLEN_VALUE and FLEN_COMMENT */
  char   cfitsio_comment_buf[ FLEN_COMMENT ]; /* are defined in "fitsio.h"   */




  /*-----------------------------------------------------------*/
  /* STEP 2 - Check to see whether file exists  	       */
  /*-----------------------------------------------------------*/

  /* Get the filesystem status associated with the specified file */
  if ( stat( p_file_to_check, &filestat ) != 0 )
    {

#if defined( CORROW_DEBUG )
    printf("File candidate (%s) rejected - couldn't access file statistics.\n",
            p_file_to_check );
#endif
    return -2;   /*** NO: couldn't determine status ***/
    }

#if defined( CORROW_DEBUG )
    printf("access file statistics success.\n");
#endif


  /*-----------------------------------------------------------*/
  /* STEP 4 - Check to see whether the file is greater than    */
  /*	      the minimum required size 		       */
  /*-----------------------------------------------------------*/

  if ( filestat.st_size < LIRIS_FILE_MIN_SIZE )
    {

#if defined( CORROW_DEBUG )
    printf ("File candidate (%s) rejected - filesize too small.\n", 
            p_file_to_check );
#endif

      return -4;   /*** NO: file too small ***/
   }

#if defined( CORROW_DEBUG )
    printf ("filesize correct.\n");
#endif


  /*-----------------------------------------------------------*/
  /* STEP 7 - Check to see whether the file contains a         */
  /*	      'STORMODE' header 			       */
  /*-----------------------------------------------------------*/

  cfitsio_status = 0;
  /* Open the specified FITS file using the CFITSIO library */
  (void) fits_open_file ( &cfitsio_fptr, p_file_to_check, 
  			   READONLY, &cfitsio_status );

  if ( cfitsio_status != 0 )
    {
#if defined( CORROW_DEBUG )
    printf ("File candidate (%s) rejected - couldn't open file.\n",
        p_file_to_check );
#endif
    return -5;   /*** NO: couldn't open file ***/
    }

  /* Get the value of the STORMODE keyword (don't care about the comment) */
  (void) fits_read_key( cfitsio_fptr, TSTRING, "STORMODE", 
  			cfitsio_value_buf, 
  			cfitsio_comment_buf, 
  			&cfitsio_status ); 
  			   
  if ( cfitsio_status != 0 )
    {

#if defined( CORROW_DEBUG )
    printf ("File candidate (%s) rejected - 'STORMODE' keyword not present or undefined.\n",
            p_file_to_check );
#endif

    (void) fits_close_file ( cfitsio_fptr, &cfitsio_status );
    return -8;  /*** NO: 'STORMODE' keyword not found ***/
    }
#if defined( CORROW_DEBUG )
    printf ("'STORMODE' keyword found.\n");
#endif


  /*-----------------------------------------------------------*/
  /* STEP 8 - Check whether STORMODE header set to 'NORMAL',   */
  /*	      'DIFF_PRE', 'DIFF', 'SLOPE', or 'SLOPE_READS'    */  
  /*-----------------------------------------------------------*/

  /* Check whether the STORMODE keyword was set to valid value */
  
  if ( check_stormode ( cfitsio_value_buf ) == -1)
    {
#if defined( CORROW_DEBUG )
    printf ("File candidate (%s) rejected - 'STORMODE' keyword was not set to valid val.\n",
            p_file_to_check );
#endif
    
    (void) fits_close_file ( cfitsio_fptr, &cfitsio_status );
    return -9;   /*** NO: 'STORMODE' keyword not valid ***/   
    }
    
#if defined( CORROW_DEBUG )
    printf ("'STORMODE' keyword valid val.\n");
#endif

  /*-----------------------------------------------------------*/
  /* STEP 10 - Close file				       */
  /*-----------------------------------------------------------*/

  (void) fits_close_file ( cfitsio_fptr, &cfitsio_status );
  if ( cfitsio_status != 0 )
    {

#if defined( CORROW_DEBUG )
    printf ( "File candidate (%s) rejected - couldn't close file.\n", p_file_to_check );
#endif

    return -14;   /*** NO: couldn't close file ***/
    }
   

  /* If control reaches here then the file is deemed to be LIRIS */
  /* compatible. Return success code to caller. */

#if defined( CORROW_DEBUG )
  printf ("File candidate (%s) is compatible.\n", p_file_to_check );
#endif

   return 0;       /*** YES: file is FIT compatible ***/

} /* file_is_fit */





/*--------------------------------------------------------------------*/
/* Function name : check_stormode                                     */
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
static int check_stormode( const char *p_key_value) 
{

#if defined( CORROW_DEBUG )
  printf ("check_stormode value: %s.\n", p_key_value );
#endif

  if ( strcmp( p_key_value, "normal" ) == STRINGS_EQUAL )   
    {
    G_store_mode = PRE_POST;
	
#if defined( CORROW_DEBUG )	
    printf (" stormode is: PRE_POST");
#endif
    return 0;
    }
      
  if ( strcmp( p_key_value, "diff_pre" ) == STRINGS_EQUAL )
    {
    G_store_mode = DIFF_PRE;
	
#if defined( CORROW_DEBUG )		
    printf (" stormode is: DIFF_PRE");
#endif
    return 0;
    } 
   
  if ( strcmp( p_key_value, "diff" ) == STRINGS_EQUAL ) 
    {
    G_store_mode = DIFF;
	
#if defined( CORROW_DEBUG )			
    printf (" stormode is: DIFF");
#endif
    return 0;
    }   
   
  if ( strcmp( p_key_value, "slope" ) == STRINGS_EQUAL ) 
    {
    G_store_mode = SLOPE;
	
#if defined( CORROW_DEBUG )				
    printf (" stormode is: SLOPE");
#endif
    return 0;
    }   
   
  if ( strcmp( p_key_value, "slope_reads" ) == STRINGS_EQUAL ) 
    { 
    G_store_mode = SLOPE_READS;
#if defined( CORROW_DEBUG )					
    printf ("stormode is: SLOPE_READS");
#endif
    return 0;
    }
   
   /* if reach here, it means that an invalid value was set */   	   

#if defined( CORROW_DEBUG )
  printf ("STORMODE keyword set to (%s) is invalid .\n", p_key_value );      
#endif

  return -1;   /*** NO: 'STORMODE' keyword not LIRIS ***/
   
} /* check_stormode */


