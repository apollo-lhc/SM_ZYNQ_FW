#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

#include <stdio.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>


//===============================================================================
//Struct to use for mapping into the AXI slave
//===============================================================================
#define REG_COUNT 256
struct TestHW {
  uint32_t reg[REG_COUNT];
};


char const * const usage = "uio r/w addr <data>";



int main(int argc, char ** argv){

  uint32_t writeData = 0;
  uint32_t address;
  bool wr = false; //read = false

  uint32_t uioNumber = 0;
  //=============================================================================
  //Simple argument parsing
  //=============================================================================
  switch (argc){
  case 5:
    //write data
    writeData = strtoul(argv[4],NULL,0);
    __attribute__((fallthrough));
  case 4:
    address = strtoul(argv[3],NULL,0);
    if(address >= REG_COUNT){
      fprintf(stderr,"Bad address!\n");
      return -1;
    }
    
    uioNumber = strtoul(argv[1],NULL,0);

    if('r' == argv[2][0]  || 'R' == argv[2][0]){
      wr = false;
    }else if('w' == argv[2][0]  || 'W' == argv[2][0]){
      wr = true;
      if (argc < 5){
	fprintf(stderr,"Missing data for write!\n");
	return -1;
      }
    }else{
      fprintf(stderr,"Error\n Usage: %s %s\n",argv[0],usage);
      return -1;      
    }
    break;
  default:
    fprintf(stderr,"Error\n Usage: %s %s\n",argv[0],usage);
    return -1;      
  }

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
  TestHW volatile * hw = (TestHW *) mmap(NULL,
					 sizeof(TestHW),
					 PROT_READ|PROT_WRITE,
					 MAP_SHARED,
					 fdUIO,
					 0x0);  //This may need some page size rounding for safety, but for now the AXI devices are easily on page boundaries. 


  //=============================================================================
  //Reads and writes
  //=============================================================================
  if(wr){
    hw->reg[address] = writeData;
    printf("write 0x%02X: 0x%08X\n",address,writeData);
  }else{
    printf("read  0x%02X: 0x%08X\n",address,hw->reg[address]);
  }
  

  return 0;
}
