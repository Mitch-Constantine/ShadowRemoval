OPENCV=../OpenCV

CC=g++ 
CPFLAGS=-I $(OPENCV)/include/opencv -o $@
LIBFLAGS=-L $(OPENCV)/release/lib

SRCS = $(wildcard src/*.cpp) $(wildcard src/utils/*.cpp)
OPENCVLIBS = $(wildcard $(OPENCV)/release/lib/*2.4.6.dylib)
OBJS = $(patsubst src/%.cpp,obj/%.o,$(SRCS))

runsample: $(OBJS)
	$(CC) $(LIBFLAGS) -o $@ $(OPENCVLIBS) $^ 

clean: 
	-rm runsample $(OBJS)

obj/%.o: src/%.cpp
	$(CC) $(CPFLAGS)  -c  $<