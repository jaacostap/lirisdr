/*----------------------------------------------------------------------------*/
/*                                                                            */
/*                     Instituto de Astrofisica de Canarias                   */
/*                             Software Department                            */
/*                                                                            */
/*                               Proyecto LIRIS                               */
/*----------------------------------------------------------------------------*/

/*- start of module header information -----------------------------------------

COMPONENT:

   rtdmsg.c


HISTORY:

   Version  Date     Author      Description

   1.1              S Rees      Original code.
   1.2              H Moreno    Adapted for LIRIS

TYPE:

   C source file


PURPOSE:

   Provides RTD-wide messaging facility.
   


PORTABILITY:

   ANSI-C 'style' coding  but uses syslog facility which
   is non-portable.



DESCRIPTION:


          |
          | msg_print()
          |
       ______________________
      |                      |
      |   MSG                |
      |   interface module   |
      |______________________|

 
This module provides a messaging facility for the RTD.

Four message types are defined:

  MSG_TYPE_DEBUG  -  Debugging messages useful during initial software 
                     development and future software maintenance.

  MSG_TYPE_INFO   -  General information messages always to be displayed
                     to the user.

  MSG_TYPE_WARN   -  Messages to warn the user of some non-fatal condition
                     which has affected the normal operation of the software.

  MSG_TYPE_ERROR  -  Messages which indicate some illegal condition which
                     prevents a program from continuing.


This module provides a consistent way of handling these messages.


The current (29/6/99) message handling is as follows:


             Output Stream Formatting      Syslog formatting 

   DEBUG     n/a                           Yes - DEBUG level

   INFO      to stdout exactly as          Yes - INFO level
             formatted.

   WARN      starts on newline,            Yes - NOTICE level
             blank line afterwards

   ERROR     starts on newline,            Yes - ALARM level
             blank line afterwards



--- End of module header information -----------------------------------------*/


/*- Feature test switches ----------------------------------------------------*/

#define _POSIX_SOURCE 1

 
/*- System headers -----------------------------------------------------------*/

#include <stdio.h>         /* for vsprintf and fprintf funcs        */
#include <stdarg.h>        /* for variable argument list handling   */
#include <syslog.h>        /* system message logging interface      */


/*- Local headers ------------------------------------------------------------*/

#include "rtdmsg.h"


/*- Local Macros -------------------------------------------------------------*/

#define MSG_SIZE_MAX 16384

#define SYSLOG_PRIO_MSG_ERROR  ( LOG_USER | LOG_CRIT   )
#define SYSLOG_PRIO_MSG_WARN   ( LOG_USER | LOG_NOTICE )
#define SYSLOG_PRIO_MSG_INFO   ( LOG_USER | LOG_INFO   )
#define SYSLOG_PRIO_MSG_DEBUG  ( LOG_USER | LOG_DEBUG  )

#define ANSI_STREAM_MSG_ERROR  stdout
#define ANSI_STREAM_MSG_WARN   stdout
#define ANSI_STREAM_MSG_INFO   stdout
#define ANSI_STREAM_MSG_DEBUG  stdout 
/*#undef ANSI_STREAM_MSG_DEBUG   */


/*- Local typedefs, structures and unions ------------------------------------*/
/*- External data ------------------------------------------------------------*/
/*- Local data ---------------------------------------------------------------*/
/*- Local function prototypes ------------------------------------------------*/
/*- Signal catching functions ------------------------------------------------*/
/*- Main ---------------------------------------------------------------------*/
/*- Externally visible functions ---------------------------------------------*/

/*--------------------------------------------------------------------*/
/* Function name : msg_print                                          */
/*                                                                    */
/* Passed        : msg_type - classification of message.              */
/*                                                                    */
/*                 p_file   - pointer to string containing filename   */
/*                            in which message was generated.         */
/*                                                                    */
/*                 line     - line number on which message was        */
/*                            generated.                              */
/*                                                                    */
/*                 format   - message format specifier                */
/*                                                                    */
/*                 ...      - variable argument list                  */
/*                                                                    */
/* Returned      : None                                               */
/*                                                                    */
/* Description   : Handle output of messages from the RTD.            */
/*                                                                    */
/* NOTE: This function should be used exactly like printf, but with   */
/*       an initial token defining the class of the message to be     */
/*       promoted.                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/

void msg_print( Msg_types msg_type, char *p_file, int line, 
                const char *format,  ... )
{
   va_list ap;
   char    buf[ MSG_SIZE_MAX + 1 ];

   /* Format supplied arguments according to format specification */
   /* placing output into text buffer.                            */ 

   va_start( ap, format );
   (void) vsprintf( buf, format, ap );
   va_end( ap );

   switch ( msg_type )
   {
       case MSG_TYPE_DEBUG:

#if defined( ANSI_STREAM_MSG_DEBUG )
          /* Send message to appropriate ANSI stream */
          (void) fprintf( ANSI_STREAM_MSG_DEBUG, "%s", buf );
          (void) fflush( ANSI_STREAM_MSG_DEBUG );
#endif

          /* Send message to syslog prepending category string */
          syslog( SYSLOG_PRIO_MSG_DEBUG, "DEBUG (%s, line %d) %s", p_file, line, buf );
          break;


       case MSG_TYPE_INFO:
       
#if defined( ANSI_STREAM_MSG_ERROR )

          /* Send message to appropriate ANSI stream */
          (void) fprintf( ANSI_STREAM_MSG_INFO, "%s", buf );
          (void) fflush( ANSI_STREAM_MSG_INFO );
#endif


          /* Send message to syslog prepending category string */
          syslog( SYSLOG_PRIO_MSG_INFO, "INFO  %s", buf );

          break;


       case MSG_TYPE_WARN:

          /* Send message to appropriate ANSI stream */
          (void) fprintf( ANSI_STREAM_MSG_WARN, "\nWARNING: %s\n\n", buf );
          (void) fflush( ANSI_STREAM_MSG_WARN );

          /* Send message to syslog prepending category string */
          syslog( SYSLOG_PRIO_MSG_WARN,  
                  "NOTICE (%s, line %d) %s", p_file, line, buf );

          break;


       case MSG_TYPE_ERROR:

          /* Send message to appropriate ANSI stream */
          (void) fprintf( ANSI_STREAM_MSG_ERROR, "\nERROR: %s\n\n", buf );
          (void) fflush( ANSI_STREAM_MSG_ERROR );

          /* Send message to syslog prepending category string */
          syslog( SYSLOG_PRIO_MSG_ERROR, 
                  "ALARM  (%s, line %d) %s", p_file, line, buf );

          break;

   } /* switch */

} /* msg_print */


/*- Local functions -------------------- -------------------------------------*/

