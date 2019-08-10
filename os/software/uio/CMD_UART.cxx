#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

#include <stdio.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>

#include <string>
#include <unistd.h> // usleep                                                                                   
#include <iostream> // cin                                                                                      
#include <string.h> // strlen                                                                                   
#include <ncurses.h>

#define RD_ADDR 0x11
#define RD_AVAILABLE 0x1000
#define RD_HALF_FULL 0x2000
#define RD_FULL 0x4000

#define WR_ADDR 0x10
#define WR_HALF_FULL 0x2000
#define WR_FULL 0x4000
#define WR_FULL_FULL (WR_FULL | WR_HALF_FULL)

#define MAXWRCOMMAND 100

#define ACK 0x100

char const * const usage = "uio r/w addr <data>";

bool SetNonBlocking(int &fd, bool value) {
  // Get the previou1s flags                                                                                     
  int currentFlags = fcntl(fd, F_GETFL, 0);
  if(currentFlags < 0) {return false;}

  // Make the socket non-blocking                                                                               
  if(value) {
    currentFlags |= O_NONBLOCK;
  } else {
    currentFlags &= ~O_NONBLOCK;
  }

  int currentFlags2 = fcntl(fd, F_SETFL, currentFlags);
  if(currentFlags2 < 0) {return false;}

  return(true);
}

int main(int argc, char ** argv){                                                                             
  //int main() {

  if(2 != argc) {
    printf("One argument only!\n");
    return 0;
  }

  uint32_t uioNumber = strtoul(argv[1],NULL,0);;

  //=============================================================================                               
  //UIO access                                                                                                  
  //=============================================================================                               

  //For now hard-code this to uio1, but in the future we should look in sys or some other API to find the corre\
ct devices.                                                                                                     
  //We do nothing about premissions and assume you are root or someone has changed the permissions to the UIO d\
evices already                                                                                                  
  const size_t dev_length = 30;
  char dev[dev_length+1];
  snprintf(dev,dev_length,"/dev/uio%u",uioNumber);
  int fdUIO = open(dev, O_RDWR|O_SYNC);
  if(-1 == fdUIO){
    fprintf(stderr,"Error!\nBad UIO %s\n",dev);
    return -1;
  }

  //setup memory mappings                                                                                       
  uint32_t volatile * hw = (uint32_t *) mmap(NULL,
                                             sizeof(uint32_t), //sizeof(TestHW),                                
                                             PROT_READ|PROT_WRITE,
                                             MAP_SHARED,
                                             fdUIO,
                                             0x0);  //This may need some page size rounding for safety, but for\
 now the AXI devices are easily on page boundaries.                                                             

  //=============================================================================                               
  //Reads and writes                                                                                            
  //=============================================================================                               

  int fd = 0; // stdin                                                                                          
  SetNonBlocking(fd, true);

  char writeByte;

  initscr();
  cbreak();
  noecho();

  while(true) {
    if(RD_FULL & hw[RD_ADDR]) {printf("Buffer full\n");}

    // read                                                                                                     
    if(RD_AVAILABLE & hw[RD_ADDR]) {
      //while(RD_AVAILABLE & hw[RD_ADDR]) {                                                                     
      printf("%c", 0xFF&hw[RD_ADDR]);
      fflush(stdout);
      hw[RD_ADDR] = ACK;
      //}                                                                                                       
    }

    //    if(!(WR_FULL_FULL & hw[WR_ADDR]) && (0 < read(fd, &writeByte, sizeof(writeByte)))) {                  
    if(0 < read(fd, &writeByte, sizeof(writeByte))) {
      // Group separator                                                                                        
      if(29 == writeByte) {break;}

      if('\n' == writeByte) {
        hw[WR_ADDR] = '\r';
      } else {
        hw[WR_ADDR] = writeByte;
      }
    }
  }

  endwin();
  printf("\n");
  fflush(stdout);

  return 0;
}
