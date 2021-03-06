#
# Generic Makefile for CDL Example tasks.
#
     CFITSIODIR = /usr/pkg/cfitsio/src/cfitsio/
    CURRENT_DIR = .
    
    CDEBUGFLAGS = -g
        FCFLAGS = -g -i $(INCLUDES)
             RM = rm
         
       INCLUDES = -I$(CURRENT_DIR) -I$(RTDDIR) -I$(CDLDIR) -I$(CFITSIODIR)
        LDFLAGS = -L$(RTDDIR) -L$(CDLDIR) -L$(CFITSIODIR)


	    
 

# SunOS definitions
	CC1     = cc 
        SRCS1   = rctalk.c lirisfits.c 
	LOCAL_LIBS1 =  $(CFITSIODIR)/libcfitsio_unix.a   
        OBJS1   = ./rctalk.o  ./lirisfits.o 
        LDLIBS1 = -lnsl  -lm -lcfitsio_unix

# Linux definitions
	CC2     = gcc 
        SRCS2   = rctalk.c lirisfits.c 
	LOCAL_LIBS2 =  $(CFITSIODIR)/libcfitsio.a 
        OBJS2   = ./rctalk.o  ./lirisfits.o  
	LDLIBS2 = -lm -lcfitsio
	
# Sun4 definitions
	CC3     = cc 
        SRCS3   = rctalk.c lirisfits.c 
	LOCAL_LIBS3 =  $(CFITSIODIR)/libcfitsio_sun4.a   
        OBJS3   = ./rctalk.o  ./lirisfits.o 
        LDLIBS3 = -lnsl -lsocket -lm -lcfitsio_sun4


#SYSTEM = `uname -s`
COMP_TYPE = -@system = "`uname -s`"; \
            echo "for $$system"; \
            if [$$system = "Linux"]; then \
	      echo "Linux system recognised"; \
	      rctalk_linux; \
	    elif [$$system = "SunOS"]; then \
	      echo "UNIX system recognised"; \
	      rctalk_unix ; \
	    else \
	      echo "Don't know what to do with $$system"; \
	      exit 1; \
	    fi;


all:: rctalk_linux

.c.o:
	$(RM) -f $@
	$(CC) -c $(INCLUDES) $(CFLAGS) $*.c

.f.o:
	$(RM) -f $@
	$(FC) -c $(FCFLAGS) $*.f

# -------------------------------------------------------------------------
# Correct row cross-talk

rctalk_linux: $(OBJS2)
	echo "linux system";
	$(RM) -f $@
	$(CC2) -o $@ $(OBJS2) -L$(CFITSIODIR)  -I$(CFITSIODIR) $(LDLIBS2)

clean::
	$(RM) rctalk_linux

rctalk_unix: $(OBJS1)
	echo "SunOS system";
	$(RM) -f $@
	$(CC1) -o $@ $(OBJS1)  -L$(CFITSIODIR) $(LDLIBS1)

clean::
	$(RM) rctalk_unix
	
rctalk_sun4: $(OBJS3)
	echo "Sun4 system";
	$(RM) -f $@
	$(CC3) -o $@ $(OBJS3)  -L$(CFITSIODIR) $(LDLIBS3)

clean::
	$(RM) rctalk_sun4
	

depend::

lint1:
	$(LINT) $(LINTFLAGS) $(SRCS1) $(LINTLIBS)
lint2:
	$(LINT) $(LINTFLAGS) $(SRCS2) $(LINTLIBS)
lint3:
	$(LINT) $(LINTFLAGS) $(SRCS3) $(LINTLIBS)

clean::
	$(RM) -f *.o





# -------------------------------------------------------------------------
# common rules for all Makefiles - do not edit

emptyrule::

Makefile::
	-@if [ -f Makefile ]; then set -x; \
	$(RM) -f Makefile.bak; $(MV) Makefile Makefile.bak; \
	else exit 0; fi
	$(IMAKE_CMD) -DTOPDIR=$(TOP) -DCURDIR=$(CURRENT_DIR)

tags::
	$(TAGS) -w *.[ch]
	$(TAGS) -xw *.[ch] > TAGS

saber:
	# load $(ALLDEFINES) $(SRCS)

osaber:
	# load $(ALLDEFINES) $(OBJS)

# -------------------------------------------------------------------------
# empty rules for directories that do not have SUBDIRS - do not edit

install::
	@echo "install in $(CURRENT_DIR) done"

install.man::
	@echo "install.man in $(CURRENT_DIR) done"

Makefiles::

includes::

# -------------------------------------------------------------------------
# dependencies generated by makedepend

# DO NOT DELETE
