#include <i2c.hh>

#include <stdint.h>
#include <stdlib.h>

#include <stdio.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>


#define I2C_RX_FIFO_PIRQ 0x46
#define I2C_CONTROL      0x40
#define I2C_STATUS       0x41
#define I2C_TX_FIFO      0x42
#define I2C_RX_FIFO      0x43
#define I2C_RESET        0x10

i2c::i2c(std::string const & UIO_DEV):
  reg(NULL),
  fdUIO(-1),
  size(0){
  clear();
  init(UIO_DEV);
}

void i2c::clear(){
  if(reg && size){
    munmap((void *)reg,size);
  }
  if(fdUIO>=0){
    close(fdUIO);
  }
}
void i2c::init(std::string const & UIO_DEV,size_t _size){
  size = _size;
  int fdUIO = open(UIO_DEV.c_str(), O_RDWR|O_SYNC);  
  if(-1 == fdUIO){
    fprintf(stderr,"Error!\nBad UIO %s\n",UIO_DEV.c_str());
    throw -1;
  }

  //setup memory mappings
  reg = (uint32_t volatile *) mmap(NULL,
				   size,
				   PROT_READ|PROT_WRITE,
				   MAP_SHARED,
				   fdUIO,
				   0x0);  //This may need some page size rounding for safety, but for now the AXI devices are easily on page boundaries. 
  
}

uint8_t i2c::read(uint8_t i2c_addr, uint8_t reg_addr){

  //Clear the read/write bit
  i2c_addr &= 0xFE;
  //=====================================
  //Set the reg address

  //reset the IP
  reg[I2C_RESET] = 0xA;
  //reset the TX fifo
  reg[I2C_CONTROL] = 0x2;
  //remove TX_FIFO reset, set as iic master, and set TX
  reg[I2C_CONTROL] = 0xC;
  //Queue up the i2c address with start bit set
  reg[I2C_TX_FIFO] = uint32_t(i2c_addr) | 0x100;
  //write reg address with stop bit
  reg[I2C_TX_FIFO] = uint32_t(reg_addr) | 0x200;
  //start transaction by setting en bit
  reg[I2C_CONTROL] = 0xD;
  uint16_t tries = 1000;
  while(!(reg[I2C_STATUS] & 0x80)){
    tries--;
    if(!tries){
      fprintf(stderr,"Failed to send data");
      throw -2;
      //should throw
    }
  }
  usleep(50);
  //disable
  reg[I2C_CONTROL] = 0x0;

  //=====================================
  //Read the reg

  //reset the IP
  reg[I2C_RESET] = 0xA;
  //reset the TX fifo
  reg[I2C_CONTROL] = 0x2;
  //remove TX_FIFO reset, set as iic master
  reg[I2C_CONTROL] = 0x4;
  //Queue up the i2c address with start bit set (and the read direction bit)
  reg[I2C_TX_FIFO] = uint32_t(i2c_addr | 0x1) | 0x100;
  //write the number of reads to do
  reg[I2C_TX_FIFO] = uint32_t(1);
  //start transaction by setting en bit
  reg[I2C_CONTROL] = 0x15;
  tries = 1000;
  while(!(reg[I2C_STATUS] & 0x80)){
    tries--;
    if(!tries){
      fprintf(stderr,"Failed to send data");
      throw -3;
      //should throw
    }
  }
  //Wait for RX data
  tries = 1000;
  while((reg[I2C_STATUS] & 0x40)){
    tries--;
    if(!tries){
      fprintf(stderr,"Failed to get data");
      throw -4;
      //should throw
    }
  }
  //disable
  reg[I2C_CONTROL] = 0x0;
  
  return reg[I2C_RX_FIFO];

}
void i2c::write(uint8_t i2c_addr,uint8_t reg_addr,uint8_t data){
  //Clear the read/write bit
  i2c_addr &= 0xFE;
  //=====================================
  //Set the reg address

  //reset the IP
  reg[I2C_RESET] = 0xA;
  //reset the TX fifo
  reg[I2C_CONTROL] = 0x2;
  //remove TX_FIFO reset, set as iic master, and set TX
  reg[I2C_CONTROL] = 0xC;
  //Queue up the i2c address with start bit set
  reg[I2C_TX_FIFO] = uint32_t(i2c_addr) | 0x100;
  //write reg address
  reg[I2C_TX_FIFO] = uint32_t(reg_addr);
  //write reg address with stop bit
  reg[I2C_TX_FIFO] = uint32_t(data) | 0x200;
  //start transaction by setting en bit
  reg[I2C_CONTROL] = 0xD;
  uint16_t tries = 1000;
  while(!(reg[I2C_STATUS] & 0x80)){
    tries--;
    if(!tries){
      fprintf(stderr,"Failed to send data");
      throw -2;
      //should throw
    }
  }
  usleep(50);
  //disable
  reg[I2C_CONTROL] = 0x0;

}
