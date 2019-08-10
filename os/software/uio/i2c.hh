#ifndef __I2C_HH__
#define __I2C_HH__

#include <string>
#include <stdint.h>

class i2c {
public:
  i2c(std::string const & UIO_DEV);
  uint8_t read(uint8_t i2c_addr, uint8_t reg_addr);
  void write(uint8_t i2c_addr,uint8_t reg_addr,uint8_t data);
private:
  i2c();
  void init(std::string const & UIO_DEV,size_t _size = 256);  
  void clear();
  uint32_t volatile * reg;
  int fdUIO;
  size_t size;
};
#endif
