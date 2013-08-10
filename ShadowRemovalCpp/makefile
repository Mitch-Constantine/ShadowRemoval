OPENCV=../OpenCV

CC=g++ 
CPFLAGS=-I $(OPENCV)/include/opencv -o $@
LINKFLAGS=-L $(OPENCV)/release/lib
LIBFLAGS=-L $(OPENCV)/release/lib -shared

SRCS = $(wildcard src/*.cpp) $(wildcard src/utils/*.cpp)
SRCS_LIB = $subst($(SRCS), src/main.cpp, )
OPENCVLIBS = $(wildcard $(OPENCV)/release/lib/*2.4.6.dylib)
OBJS = $(patsubst src/%.cpp,obj/%.o,$(SRCS))
OBJS_LIB = $(patsubst src/%.cpp,obj/%.o,$(SRCS_LIB))

removeShadows.dylib: $(OBJS)
	$(CC) $(LIBFLAGS) -o $@ $(OPENCVLIBS) $^ 

runsample: $(OBJS)
	$(CC) $(LINKFLAGS) -o $@ $(OPENCVLIBS) $^ 

clean: 
	-rm runsample removeShadows.dylib $(OBJS)

obj/%.o: src/%.cpp
	$(CC) $(CPFLAGS)  -c  $<