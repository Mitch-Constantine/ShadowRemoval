OPENCV=$(realpath ../OpenCV)
CC=g++-4.2
MEX=/Applications/MATLAB_R2012a.app/bin/mex 

MEXFLAGS=-I$(OPENCV)/include/opencv -L$(OPENCV)/release/lib $(OPENCVLIBS) -output $@ 
CPFLAGS=-I$(OPENCV)/include/opencv -o $@
LINKFLAGS=-L $(OPENCV)/release/lib
LIBFLAGS=-L $(OPENCV)/release/lib -shared

SRCS = $(wildcard src/*.cpp) $(wildcard src/utils/*.cpp)
SRCS_LIB = $subst( $subst($(SRCS), src/main.cpp, ), src/MatlabInterface/matlabRemoveShadows.cpp, )
OPENCVLIBS = $(wildcard $(OPENCV)/release/lib/*2.4.6.dylib)
OBJS = $(patsubst src/%.cpp,obj/%.o,$(SRCS))
OBJS_LIB = $(patsubst src/%.cpp,obj/%.o,$(SRCS_LIB))

bin/matlabRemoveShadows.mexmaci64: src/MatlabInterface/matlabRemoveShadows.cpp bin/removeShadows.dylib
	$(MEX) $(MEXFLAGS) src/MatlabInterface/matlabRemoveShadows.cpp bin/removeShadows.dylib

bin/removeShadows.dylib: $(OBJS)
	$(CC) $(LIBFLAGS) -o $@ $(OPENCVLIBS) $^ 

bin/runsample: $(OBJS)
	$(CC) $(LINKFLAGS) -o $@ $(OPENCVLIBS) $^ 

clean: 
	-rm bin/* obj/utils/* obj/*

obj/%.o: src/%.cpp
	$(CC) $(CPFLAGS)  -c  $<