CXX=source /opt/Xilinx/petalinux/2018.2/settings.sh && arm-linux-gnueabihf-gcc
CXXFLAGS+=-c -O2 -Wall -Wextra -Werror -Wno-pointer-arith
LDFLAGS+=-L./ 


XVCSERVER=xvcServer

all:  $(XVCSERVER)

$(XVCSERVER):	$(XVCSERVER).o
	$(CXX) $(LDFLAGS) -o $@ $^

%.o:%.c
	$(CXX) -c $(CXXFLAGS) -o $@  $<

clean:
	@rm $(XVCSERVER) > /dev/null 2>&1
	@rm *.o > /dev/null 2>&1
	@rm *~ > /dev/null 2>&1

