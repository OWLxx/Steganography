#--------------------------------------------------------------------
COMPILEFLAGS=-c -fPIC -fno-omit-frame-pointer -ansi -D_GNU_SOURCE -pthread -DMX_COMPAT_32
OPTIMFLAGS=-O3 -ipo -DNDEBUG
DEBUGFLAGS=-DDEBUG -g -DSAVE_RESULTS
#-------------------------------------------------------------------- 
LINKFLAGS=-pthread -shared -Wl,--version-script,/matlab/r2006a/extern/lib/glnxa64/mexFunction.map -Wl,-rpath-link,/matlab/r2006a/bin/glnxa64
LIBDIRS=-L/matlab/r2006a/bin/glnxa64
LIBS=-lmx -lmex -lmat -lm -lm -ljpeg
INCLUDE=-I/matlab/r2006a/extern/include -I./jpeg-6b
#mexa64 mexglx
MATLEXT=mexa64
#--------------------------------------------------------------------
all:
	clear
	icc $(COMPILEFLAGS) $(OPTIMFLAGS) $(INCLUDE) -o jpeg_read.o jpeg_read.c
	icc $(COMPILEFLAGS) $(OPTIMFLAGS) $(INCLUDE) -o jpeg_write.o jpeg_write.c
	icc $(LINKFLAGS) $(OPTIMFLAGS) $(LIBDIRS) $(LIBS) -o jpeg_read.$(MATLEXT) jpeg_read.o
	icc $(LINKFLAGS) $(OPTIMFLAGS) $(LIBDIRS) $(LIBS) -o jpeg_write.$(MATLEXT) jpeg_write.o