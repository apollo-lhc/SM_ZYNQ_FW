----------------------------------------------------------------------------------
--
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.types.all;

package AXIRegPkg is

  type AXIReadMOSI is record
    --read address
    address : slv_32_t;                 -- ARADDR
    protection_type : slv_3_t;          -- ARPROT
    address_valid : std_logic;          -- ARVALID
                                        
    --read data                         
    ready_for_data : std_logic;         -- RREADY
  end record AXIReadMOSI;
  type AXIReadMOSI_array_t is array (integer range <>) of AXIReadMOSI;
  constant DefaultAXIReadMOSI : AXIReadMOSI := (address => x"00000000",
                                                protection_type => "000",
                                                address_valid => '0',
                                                ready_for_Data => '0');
  
  
  type AXIReadMISO is record
    --read address
    ready_for_address : std_logic;      -- ARREADY

    --read data
    data          : slv_32_t;           -- RDATA
    data_valid    : std_logic;          -- RVALID
    response      : slv_2_t;            -- RRESP
  end record AXIReadMISO;
  type AXIReadMISO_array_t is array (integer range <>) of AXIReadMISO;
  constant DefaultAXIReadMISO : AXIReadMISO := (ready_for_address => '0',
                                                data => x"00000000",
                                                data_valid => '0',
                                                response => "00");

  
  type AXIWriteMOSI is record
    --write address
    address : slv_32_t;                 -- AWADDR
    protection_type : slv_3_t;          -- AWPROT
    address_valid : std_logic;          -- AWVALID

    --write data
    data : slv_32_t;                    -- WDATA
    data_valid : std_logic;             -- WVALID
    data_write_strobe : slv_4_t;        -- WSTRB

    --write response
    ready_for_response : std_logic;         -- BREADY
  end record AXIWriteMOSI;
  type AXIWriteMOSI_array_t is array (integer range <>) of AXIWriteMOSI;
  constant DefaultAXIWriteMOSI : AXIWriteMOSI := (address => x"00000000",
                                                  protection_type => "000",
                                                  address_valid => '0',
                                                  data => x"00000000",
                                                  data_valid => '0',
                                                  data_write_strobe => x"0",
                                                  ready_for_response => '0');    

  
  type AXIWriteMISO is record
    --write address
    ready_for_address : std_logic;      -- AWREADY

    --write data
    ready_for_data    : std_logic;      -- WREADY

    --write response
    response_valid    : std_logic;      -- BVALID
    response          : slv_2_t;        -- BRESP    
  end record AXIWriteMISO;
  type AXIWriteMISO_array_t is array (integer range <>) of AXIWriteMISO;
  constant DefaultAXIWriteMISO : AXIWriteMISO := (ready_for_address => '0',
                                                  ready_for_data => '0',
                                                  response_valid => '0',
                                                  response => "00");
  
  
end package AXIRegPkg;
