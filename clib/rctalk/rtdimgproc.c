/*----------------------------------------------------------------------------*/
/*                                                                            */
/*                     Instituto de Astrofisica de Canarias                   */
/*                             Software Department                            */
/*                                                                            */
/*                               Proyecto LIRIS                               */
/*----------------------------------------------------------------------------*/

/*- start of module header information -----------------------------------------

COMPONENT:

   rtdimgproc.c


HISTORY:

   Version  Date    Author    Description

   1.1     0109    J. Acosta  Original code
   1.2     011029  H. Moreno  Added Module header and sorting routine
                              re-write imgproc_sampleimg function 
			      to optimize code

TYPE:

   C source file


PURPOSE:

   Provides functions for image sampling and sorting.
 

PORTABILITY:

   ANSI-C Standard C


DESCRIPTION:

  This module contains fuctions to to compress or sample a float image
  and the sort algorithm based on the numerical recipies code.

--- End of module header information ----------------------------------------*/

/*- Feature test switches ---------------------------------------------------*/


/*- System headers ----------------------------------------------------------*/

#include <stddef.h>
#include <stdio.h>         /* required for printf ()         */
#include <stdlib.h>
#include <strings.h>  

/*- Local headers -----------------------------------------------------------*/
#define RTD_IMGPROC_C
 #include "global.h"         
#undef RTD_IMGPROC_C

/*- Local macros ------------------------------------------------------------*/

/* Code Developers: enable the following definition to turn on */
/* debugging for this module  #undef                           */
#undef RTD_IMGPROC_DEBUG

#define max(a,b) ((a) > (b) ? (a) : (b))
#undef min
#define min(a,b) ((a) < (b) ? (a) : (b)) 
#undef mod
#define mod(a,b) ((a) % (b))


/*- Local typedefs, structures and unions -----------------------------------*/

/* the following defines are required by the imgproc_nrsort function */
#define SWAP(a,b) temp=(a);(a)=(b);(b)=temp;
#define M 7            /* size of subarrays sorted by straight insertion */
#define NSTACK 50      /* to require auxiliary storage */

/*- External data -----------------------------------------------------------*/
/*- Global data -------------------------------------------------------------*/
/*- Local function prototypes -----------------------------------------------*/
long int imgproc_sampleimg(const float *, float **, int, int, int, int );
short int imgproc_nrsort( unsigned long n, float arr[]);

/*- Externally visible functions ---------------------------------------------*/

/*---------------------------------------------------------------------*/
/* Function name : imgproc_statistics                                  */
/*                                                                     */
/* Passed        : p_pix_buf - pointer to pixel data to get statistics */
/*                 median  - to return the calculated meddiam value    */
/*                 sigma_L - To retur the calulated sigma_left value   */
/*                 sigma_R - to return the calculated sigma_right value*/
/*                                                                     */
/*                                                                     */
/* Returned      : -1 if error found in sort or sampleimage functions  */
/*                 0  if OK                                            */
/*                                                                     */
/* Description   : perform image statistics. Get median, sigma         */
/*                                                                     */
/*---------------------------------------------------------------------*/

short int imgproc_statistics( const Pixel *p_pix_buf, float *median, 
                               float *sigma_L, float *sigma_R)
{

   Pixel *sample = NULL, *left = NULL;   
   long int center_pixel, quart1_pixel, quart3_pixel; 
   long int nsample, nsampLines, npix_sample;
   
#if defined( RTD_SHOW_DEBUG )         
   msg(DEBUG, " FUNC: imgproc_statistics \n");
   msg(DEBUG, " (%lu)\n", p_pix_buf);
#endif   
     
/************************************************************************/
/* STILL_TO_DO EL siguiente codigo esta temporal. en el definitivo      */
/* lo quitaremos  Lo hacemos para evitar re- compilar             */

 /*  char *env_var_value;
   char   dummy_ch;
 */  

   
 /*  if ((env_var_value =  getenv("RTD_NSAMPLE")) != NULL) 
   { 
        if ( sscanf( env_var_value, "%ld%c", &nsample, &dummy_ch ) != 1 )
        {
           msg( ERROR, "Invalid value for environmetal var RTD_NSAMPLE ('%s')",
	        env_var_value );
           exit( EXIT_FAILURE );
	}      
   }


   if ((env_var_value =  getenv("RTD_NSAMPLE_LINE")) != NULL) 
   { 
     if ( sscanf( env_var_value, "%ld%c", &nsampLines, &dummy_ch ) != 1 )
     {
        msg( ERROR, "Invalid value for environmetal var RTD_NSAMPLE_LINE ('%s')",
	        env_var_value );
        exit( EXIT_FAILURE );
     }      
   }
*/   
   
/************************************************************************/
   
   nsample = 65535;  /* 65535, 256 Esto da lugar a hacer un grid de 256 *256 */    
   nsampLines = 256; /* tomados cada 4 cols y filas */        
   
   
  /* msg( DEBUG, " nsample = %ld nsampLines= %ld \n", nsample, nsampLines); 
   */
   
   /* get the current values of nsample and nsampleLines */
   npix_sample = imgproc_sampleimg(p_pix_buf,  &sample, XDETPIX,
                               YDETPIX, nsample, nsampLines); 
   			       
   if ( npix_sample <= 0 )
   {
      msg (INFO, " Could't sample the imput image ");
      return -1;
   }
      
#if defined( RTD_SHOW_DEBUG )   
   msg( DEBUG, "npix_sample %ld \n", npix_sample );	 
   msg (DEBUG, " ANTES de imgproc_nrsort()-sample[%ld] = %f \n " , npix_sample -1,
                          sample[ npix_sample -1] )
#endif   
   			      
  /* Sort the sample, compute the  median pixel value.  */       			      ;
   if (  imgproc_nrsort ( (unsigned long) npix_sample, sample) != 0)
   {
      msg(INFO, " sort algorithm error \n");   
      return -1;
   }   
   

   /* The median value is the average of the two central values if  
    * there are an even number of pixels in the sample.       
    */
   center_pixel = max (1, (npix_sample + 1) / 2);
   left = &(sample[center_pixel - 1]);
   if (mod (npix_sample, 2) == 1 || center_pixel >= npix_sample)
       *median = (float) *left;
   else
       *median = (*left + *(left+1)) / 2;
       
   quart1_pixel = max (1, (npix_sample + 1) / 4);
   quart3_pixel = max (1, (int) (((float) npix_sample + 1.0) * 3.0 / 4.0)); 
   
   *sigma_L =   (*median - *(&(sample[quart1_pixel-1]))) * 2.0 /1.36 ;
   *sigma_R =   (*(&(sample[quart3_pixel-1])) - *median) * 2.0 /1.36 ;
     
   free(sample);
   return 0;
   
} /* imgproc_statistics */




/*---------------------------------------------------------------------*/
/* Function name : imgproc_sampleimg                                   */
/*                                                                     */
/* Passed        :                                                     */
/*    float *im,                   image to be sampled                 */
/*    float **sample,              output vector containing the sample */
/*    int nx,                                                          */
/*    int ny,                      image dimensions                    */
/*    int optimal_size,            desired number of pixels in sample  */
/*    int len_stdline              optimal number of pixels per line   */
/*                                                                     */
/* Returned      : int =  Number of pixels in sample image             */
/*                     = -1 - failure                                  */
/*                                                                     */
/* Description   : Sample a large image and returnes the sampled image */
/*                 and the number of pixels in the new image           */
/*                                                                     */
/*---------------------------------------------------------------------*/
long int imgproc_sampleimg (
    const float *im,	/* image to be sampled          */
    float **sample,	/* output vector containing the sample	*/
    int nx,
    int ny,		/* image dimensions			*/
    int optimal_size,	/* desired number of pixels in sample	*/
    int len_stdline)	/* optimal number of pixels per line	*/
{
    unsigned short int j, ip;
    int col_step, line_step, maxpix, start_line;
    int opt_npix_per_line, npix_per_line, npix = 0;
    int opt_nlines_in_sample, min_nlines_in_sample, max_nlines_in_sample;
    int line_increment;
    int size_of_line;
    float *op ,  *row , *fpix;
    float * ptr_last_pixel;

#if defined( RTD_IMGPROC_DEBUG )
     msg(DEBUG, " FUNC: imgproc_sampleimg  \n");
#endif  

    size_of_line = nx * sizeof(float);
  
    /*----------------------------------------------------------*/
    /* Compute the number of pixels each line will contribute   */
    /* to the sample,and the subsampling step size for a line.  */
    /* The sampling grid must span the whole line on a uniform  */
    /* grid.                                                    */
    /*----------------------------------------------------------*/
    
    opt_npix_per_line = max (1, min (nx, len_stdline));
    col_step = max (2, (nx + opt_npix_per_line-1) / opt_npix_per_line);
    npix_per_line = max (1, (nx + col_step -1) / col_step);
    
#if defined( RTD_IMGPROC_DEBUG )	
    msg(DEBUG, "[sampleImage] opt_npix/line=%d col_step=%d n/line=%d\n",
		opt_npix_per_line, col_step, npix_per_line);   
#endif 	   

    /*--------------------------------------------------------*/
    /* Compute the number of lines to sample and the spacing  */
    /* between lines. We must ensure that the image is        */
    /* adequately sampled despite its size, hence there is a  */
    /* lower limit on the number of lines in the sample.      */
    /* We also want to minimize the number of lines accessed  */
    /* when accessing a large image, because each disk seek   */
    /* and read is expensive. The number of lines extracted   */
    /* will be roughly the sample size divided by len_stdline,*/
    /* possibly more if the lines are very short.             */
    /*--------------------------------------------------------*/
    
    min_nlines_in_sample = max (1, optimal_size / len_stdline);
    opt_nlines_in_sample = max(min_nlines_in_sample, 
    	     min(ny, (optimal_size + npix_per_line -1) / npix_per_line));
    line_step = max (2, ny / (opt_nlines_in_sample));
    max_nlines_in_sample = (ny + line_step-1) / line_step;

#if defined( RTD_IMGPROC_DEBUG )    
     msg (DEBUG, "[sampleImage] nl_in_samp=%d/%d opt_nl/samp=%d lstep=%d\n",
		min_nlines_in_sample, opt_nlines_in_sample, line_step,
		max_nlines_in_sample);   
#endif
 	   
    /*--------------------------------------------------------*/   
    /* Allocate space for the output vector.                  */
    /*--------------------------------------------------------*/
     maxpix = npix_per_line * max_nlines_in_sample;
     *sample = (float *) malloc (maxpix * sizeof (float));
     
     row = (float *) malloc (size_of_line);
 
                             			      

     /* Extract the vector. */
     op = *sample;
     start_line = ((line_step +1) /2 ) - 1;
     line_increment = line_step * nx;
     ptr_last_pixel = (float *) im + nx * ny; 
      
#if defined( RTD_IMGPROC_DEBUG )        
    msg (DEBUG, " max_pix =%d start_line=%d  line_increment=%d\n", 
                maxpix, start_line,  line_increment);		 
    msg (DEBUG, " ptr_last_pixel=%ld  \n", ptr_last_pixel);    
    msg (DEBUG, " fpix=%ld  \n", (float *)im + start_line * nx);
#endif 	   
    
     
     for (fpix = (float *)im + start_line * nx;
            fpix < ptr_last_pixel && npix < maxpix; fpix += line_increment)
     {
      /* Load a row of float values from the image */
       memcpy (row, fpix,  size_of_line);

      /*-----------------------------------------------------------*/       
      /* subsample an image line, extract the first pixel and every*/ 
      /* "step" th pixel thereafter for a total of npix pixels.    */
      /*-----------------------------------------------------------*/       
       
       if (col_step <= 1)
	    bcopy(op, row, npix_per_line);
       else
       { 
         ip = 0;
	 for (j=0; j < npix_per_line; j++)
	 {
	    op[j] = row[ip];
	   	    
	    ip += col_step;
	 }
       }	   
       op += npix_per_line;
       npix += npix_per_line;
   
     }

     free ((float *)row);
     return (npix);
}

/*--------------------------------------------------------------------*/
/* Function name : imgproc_nrsort                                     */
/*                                                                    */
/* Passed        : n - number of elements in the buffer to be sorted  */
/*                                                                    */
/*                 arr - buffer holding the data to be sorted         */
/*                       on output it hods the re-arranged data       */
/*                                                                    */
/* Returned      : int =  0 - Success                                 */
/*                     = -1 - Error : couldn't allocate auxiliary mem */
/*                     = -2 - Error : Auxiliary memory too small      */
/*                                                                    */
/* Description   : Quicksort algorithm adapted from the numerical     */
/*                 recipies software.                                 */
/*                 Sorts an array arr[] of n elements into ascending  */
/*                 order. arr is replaced on output by its sorted     */
/*                 re-arrangement                                     */
/*                 Some modifications have been made to the original  */
/*                 as to code: the array index ( from 0 to n-1) and   */
/*                 the unsigned vars were transformed to signed       */
/*--------------------------------------------------------------------*/

short int imgproc_nrsort(unsigned long n, float arr[])
{
    long int i,j,k;
    long int ir = n -1;    /* ir =n */
    long int l =0;         /* l = 1*/
    long int jstack = 0, *istack;
    float a,temp;

#if defined( RTD_IMGPROC_DEBUG )        
     msg(DEBUG , " FUNC: imgproc_nrsort  \n");
#endif  


   istack = (long int *)malloc((size_t) ((NSTACK +1)*sizeof(long)));
   if (!istack)
   {
     msg (INFO," Couldn't allocate auxiliary sort memory for istack");     
     return (-1);
   }
     
   for (;;)
   { 
     if (ir-l < M)
     {        /* use insertion sort when subarray is small enough */
       for (j=l+1;j<=ir;j++)
       {
	  a = arr[j];
	  for (i=j-1; i>=0; i--)
	  {
	     if (arr[i] <= a)
	       break;
	     arr[i+1]=arr[i];
          }
	  arr[i+1]=a;
       } 
       if (jstack == 0)
          break;
       ir = istack[jstack--];
       l  = istack[jstack--];
     }
     else 
     {  /* choose median of left,center and right elements as partitioning */
        /* elemnt a */
	 k=(l+ir) >> 1;
	
	 
         SWAP(arr[k],arr[l+1])
         if (arr[l+1] > arr[ir]) {
   	      SWAP(arr[l+1],arr[ir])
         }
         if (arr[l] > arr[ir]) {
   	      SWAP(arr[l],arr[ir])
         }
         if (arr[l+1] > arr[l]) {
   	      SWAP(arr[l+1],arr[l])
         }
         i=l+1;
         j=ir;
         a=arr[l];
         for (;;) 
	 {
 
   	      do i++; while (arr[i] < a);
   	      do j--; while (arr[j] > a);
	      if (j < i) break;
             	      
	     SWAP(arr[i],arr[j]);
	 }
	 arr[l]=arr[j];
	 arr[j]=a; 
	 jstack += 2; 
	 if (jstack > NSTACK)
	 {
	     msg(INFO, "NSTACK too small in sort.");
	     return (-2);
	 }
	 if (ir-i+1 >= j-l)
	 {
	    istack[jstack]=ir;
	    istack[jstack-1]=i;
	    ir=j-1;
	 }
	 else
	 {
	     istack[jstack]=j-1;
	     istack[jstack-1]=l;
	     l=i;
	 }
     } /* end of else of if (ir < M) */
  }  /* end of  for (;;) */


   
   
  free(istack); 
  return 0; 
}
#undef M
#undef NSTACK
#undef SWAP
/* (C) Copr. 1986-92 Numerical Recipes Software );. */
