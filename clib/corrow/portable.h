/*----------------------------------------------------------------------------*/
/*                                                                            */
/*                     Instituto de Astrofisica de Canarias                   */
/*                             Software Department                            */
/*                                                                            */
/*                               Proyecto LIRIS                               */
/*----------------------------------------------------------------------------*/

/*- start of module header information -----------------------------------------

COMPONENT:

   portable.h


HISTORY:

   Version  Date     Author      Description

   1.1               S Rees      Original code.
   1.2      991200   H Moreno    Addapted for LIRIS based on INGRID's code


TYPE:

   C include file


PURPOSE:

   RTD portability file


PORTABILITY:

   ANSI-C


DESCRIPTION:

   This file contains definitions designed to aid in the portability
   of software across platforms.


--- End of module header information -----------------------------------------*/

#if !defined( PORTABLE_H )
#define PORTABLE_H


/*- Feature test switches ----------------------------------------------------*/
/*- Headers required by this header ------------------------------------------*/



/*- Exported Macros ----------------------------------------------------------*/

/*---------------------------------------------------------------------------*/
/* Throughout the RTD messages are output to the user by calls to a general  */
/* purpose msg() function with a parameter - INFO, WARN, ERROR or DEBUG -    */
/* which indicates the class of the message.                                 */
/*                                                                           */
/* Message generation itself is handled in a consistent way by calls to the  */
/* RTD MSG module.  This portability file handles the translation of these   */
/* calls via the following definitions.                                      */
/*---------------------------------------------------------------------------*/

/* Translate every instance of msg( XX, ... ) to a call to msg_print( XX, ... ) */

#define msg msg_print   


/* Map the supplied message class - INFO, WARN, ERROR or DEBUG -  onto   */
/* parameters supplied to genmsg(). The inclusion of the ANSI __FILE__   */
/* and __LINE__ macros provide additional information which may be used  */
/* to indicate where a particular message was generated.                 */

#define INFO  MSG_TYPE_INFO,  __FILE__, __LINE__
#define WARN  MSG_TYPE_WARN,  __FILE__, __LINE__
#define ERROR MSG_TYPE_ERROR, __FILE__, __LINE__
#define DEBUG MSG_TYPE_DEBUG, __FILE__, __LINE__ 

/*---------------------------------------------------------------------------*/
/*                                                                           */
/* The upshot of all the above is that a call like this:                     */
/*                                                                           */
/*     msg( INFO, "This is a message" );                                     */
/*                                                                           */
/* gets translated to a call to rtdmsg thus:                                 */
/*                                                                           */
/*     msg_print( MSG_TYPE_INFO, "fred.c",  "27", "This is a message" );     */
/*                                                                           */
/*---------------------------------------------------------------------------*/


/* This constant defines the storage allocation for all arrays associated */
/* with the Unix file system. This includes allocations for filenames,    */
/* pathnames, directory names etc. The value specified here should be     */
/* sufficient to allow concatanation of at least three names without risk */
/* of exceeding array bounds.                                             */

#define FILESYS_NAME_ALLOC_SIZE     1024


/*- Exported typedefs, structures and unions ---------------------------------*/

/* Define basic data types according to machine-specific implementation */

typedef unsigned char  Byte;       /* must map onto an 8-bit quantity   */
typedef unsigned short Word16;     /* must map onto a 16-bit quantity   */
typedef unsigned int   Word32;     /* must map onto a 32-bit quantity   */
typedef float          Float32;    /* must map onto a 32-bit float      */


/*- Exported data ------------------------------------------------------------*/
/*- Exported functions  ------------------------------------------------------*/

#endif

