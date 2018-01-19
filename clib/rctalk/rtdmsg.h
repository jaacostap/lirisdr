/*----------------------------------------------------------------------------*/
/*                                                                            */
/*                     Instituto de Astrofisica de Canarias                   */
/*                             Software Department                            */
/*                                                                            */
/*                               Proyecto LIRIS                               */
/*----------------------------------------------------------------------------*/

/*- start of module header information -----------------------------------------

COMPONENT:

   rtdmsg.h


HISTORY:

   Version  Date     Author      Description

   1.1      990629   S Rees      INGRID's Original code.
   1.2      991212   H Moreno    Adapted for LIRIS

TYPE:

   C include file


PURPOSE:

   RTD-wide messaging facility


PORTABILITY:

   ANSI-C


DESCRIPTION:

   C include file for RTD MSG module.


--- End of module header information -----------------------------------------*/

#if !defined( RTDMSG_H )
#define RTDMSG_H


/*- Feature test switches ----------------------------------------------------*/
/*- Headers required by this header ------------------------------------------*/
/*- Exported Macros ----------------------------------------------------------*/

typedef enum { MSG_TYPE_INFO, MSG_TYPE_WARN, 
               MSG_TYPE_ERROR, MSG_TYPE_DEBUG } Msg_types;


/*- Exported typedefs, structures and unions ---------------------------------*/
/*- Exported data ------------------------------------------------------------*/
/*- Exported functions  ------------------------------------------------------*/

/*--------------------------------------------------------------------*/
/* Function name : msg_print                                          */
/*                                                                    */
/* Passed        : msg_type - classification of message.              */
/*                                                                    */
/*                 p_file   - pointer to string containing filename   */
/*                            in which message was generated.         */
/*                                                                    */
/*                 p_line   - pointer to string containing line       */
/*                            number on which message was generated.  */
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
/*--------------------------------------------------------------------*/

void msg_print( Msg_types msg_type, char *file, int line, 
                const char *format,  ... );

#endif

