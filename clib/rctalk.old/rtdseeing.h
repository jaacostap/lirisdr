/*----------------------------------------------------------------------------*/
/*                                                                            */
/*                     Instituto de Astrofisica de Canarias                   */
/*                             Software Department                            */
/*                                                                            */
/*                               Proyecto LIRIS                               */
/*----------------------------------------------------------------------------*/


/*- start of module header information -----------------------------------------

COMPONENT:

   rtdseeing.h


HISTORY:

   Version   Author    Description

   1.1       J.Acosta  Original Code


TYPE:

   C include file


PURPOSE:

   It holds function declarations for rtdseeing.c module


PORTABILITY:

   ANSI-C


DESCRIPTION:



--- End of module header information -----------------------------------------*/

#if !defined( RTD_SEEING_H )
#define RTD_SEEING_H

#include "fitsio.h" 

#ifdef RTDSEEING_C
#  define extern 

  static short seeing_im_temp_alloc();
  static void  seeing_im_temp_dealloc();
  static short apgk_alloc_kernel();
  static void  apgk_egparams();    
  static void  apgk_dealloc_kernel();
  static short apgk_kernel();
  static short apgk_convolve(Pixel *);  
  static short ap_find(Pixel *, float, long *, float *);
  static short ap_detect (Pixel *, float);
  static void  ap_moments (Pixel *, Pixel *, Pixel *, short);
  static short ap_test (float);
  static short ap_alloc_linefind (short);
  static void  ap_dealloc_linefind ();
  static short apfd_alloc_obj ();
  static void  apfd_dealloc_obj ();  
  static short seeing_init_mem();
      
#else 
#   define extern extern
#endif
extern short seeing_open();
extern void  seeing_dealloc_mem();
extern short seeing_stfd_starfind(Pixel *, long *);
extern short seeing_get_sub_image(Pixel *, short, short, Pixel *, short, short,
                           short, short );
extern int get_seeing_keywords( fitsfile *cfitsio_fptr) ;			   
                           
#  undef extern  



#endif

