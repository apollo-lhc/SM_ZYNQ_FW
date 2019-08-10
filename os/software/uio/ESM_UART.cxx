#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>

#include <unistd.h>
#include <string>
#include <ncurses.h>

#define RD_ADDR 0xB
#define RD_AVAILABLE 0x1000
#define RD_HALF_FULL 0x2000
#define RD_FULL 0x4000

#define WR_ADDR 0xA
#define WR_HALF_FULL 0x2000
#define WR_FULL 0x4000
#define WR_FULL_FULL (WR_FULL | WR_HALF_FULL)

#define MAXWRCOMMAND 100

#define ACK 0x100

char const * const usage = "uio r/w addr <data>";

int main() {
  uint32_t uioNumber = 8;
      
  //=============================================================================
  //UIO access
  //============================================================================= 
  
  //For now hard-code this to uio1, but in the future we should look in sys or some other API to find the correct devices.
  //We do nothing about premissions and assume you are root or someone has changed the permissions to the UIO devices already
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
					     0x0);  //This may need some page size rounding for safety, but for now the AXI devices are easily on page boundaries. 

  //=============================================================================
  //Reads and writes
  //=============================================================================

  int fd = 0; // stdin

  int n;
  
  char writeByte;

  initscr();
  cbreak();
  noecho();

  printf("going in\n");
  
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

    n = read(fd, &writeByte, sizeof(writeByte));
    
    // If writebuffer half full or full, the command is not sent. This would mean that any typed commands will not show up 
    //    if(!(WR_FULL_FULL & hw[WR_ADDR]) && (0 < read(fd, &writeByte, sizeof(writeByte)))) {
    //if(0 < read(fd, &writeByte, sizeof(writeByte))) {
    if(0 < n) {
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
 
