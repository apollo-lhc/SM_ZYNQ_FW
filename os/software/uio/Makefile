CXX=source /opt/Xilinx/petalinux/2018.2/settings.sh && arm-linux-gnueabihf-g++
CXXFLAGS+=-c -O2 -Wall -Wextra -Werror -Wno-pointer-arith -I./
LDFLAGS+=-L./ 


UIO_REG=uioReg
SI_REG=siIO
PROG_SI=programSI5344
ESM_UART=ESM_UART

all:  $(UIO_REG) $(SI_REG) $(PROG_SI) $(ESM_UART)

$(UIO_REG):	$(UIO_REG).o
	$(CXX) $(LDFLAGS) -o $@ $^

$(SI_REG):	$(SI_REG).o i2c.o
	$(CXX) $(LDFLAGS) -o $@ $^

$(PROG_SI):	$(PROG_SI).o i2c.o
	$(CXX) $(LDFLAGS) -o $@ $^

$(ESM_UART):	$(ESM_UART).o
	$(CXX) $(LDFLAGS) -o $@ $^ -lncurses

%.o:%.cxx
	$(CXX) -c $(CXXFLAGS) -o $@  $<

clean:
	@rm $(UIO_REG) > /dev/null 2>&1
	@rm $(ESM_UART) > /dev/null 2>&1
	@rm *.o > /dev/null 2>&1
	@rm *~ > /dev/null 2>&1

