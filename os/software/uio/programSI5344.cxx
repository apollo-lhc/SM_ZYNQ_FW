#include <fstream>
#include <unistd.h> //usleep

#include <stdint.h>
#include <stdio.h>
#include <i2c.hh>

#include <vector>
#include <string>

i2c SI("/dev/uio0");


void i2cWrite(uint16_t address,uint32_t value){
  uint8_t addr = address & 0xFF;
  uint8_t data = value & 0xFF;
  SI.write(0xd0,addr,data);
}
uint8_t i2cRead(uint8_t address){
  uint8_t addr = address & 0xFF;
  return SI.read(0xd0,addr);
}

void SetPage(uint8_t page){
  i2cWrite(0x1,page);
}

uint8_t GetPage(){
  return uint8_t(i2cRead(0x1)&0xFF);
}

uint8_t GetPageNumber(uint16_t address){
  return uint8_t((address >> 8)&0xFF); 
}

void LoadConfig(std::string const & fileName){
  std::ifstream confFile(fileName.c_str());

  if(confFile.fail()){
    throw "bad file";
  }

  std::vector<std::pair<uint16_t,uint8_t> > writes;
  while(!confFile.eof()){
    std::string line;
    std::getline(confFile,line);
    if(line.size() == 0){
      continue;
    }else if(line[0] == '#'){
      continue;
    }else if(line[0] == 'A'){
      continue;
    }else{
      if( line.find(',') == std::string::npos ){
	printf("Skipping bad line: \"%s\"\n",line.c_str());
	continue;
      }
      uint16_t address = strtoul(line.substr(0,line.find(',')).c_str(),NULL,16);
      uint8_t  data    = strtoul(line.substr(line.find(',')+1).c_str(),NULL,16);
      writes.push_back(std::pair<uint16_t,uint8_t>(address,data));
    }
  }


  uint8_t page = GetPage();
  unsigned int percentDone = 0;


  printf("\n[==================================================]\n");
  fprintf(stderr," ");
  for(size_t iWrite = 0; iWrite < writes.size();iWrite++){

    if(page != GetPageNumber(writes[iWrite].first)){
      page = GetPageNumber(writes[iWrite].first);
      SetPage(page);
      usleep(1000);
    }

    
    if(iWrite == 3){
      usleep(600000);
    }
    

    uint8_t  address = writes[iWrite].first & 0xFF;
    uint32_t data = (writes[iWrite].second) & 0xFF;
    i2cWrite(address ,data);    

    if((100*iWrite)/writes.size() > percentDone){
      fprintf(stderr,"#");
      percentDone+=2;
    }
  }
  printf("\n");

}



int main(){
  LoadConfig("config.txt");
}
