--This file was auto-generated.
--Modifications might be lost.
library IEEE;
use IEEE.std_logic_1164.all;


package plXVC_CTRL is
  type plXVC_XVC_REMOTE_CTRL_t is record
    IP                         :std_logic_vector(31 downto 0);  -- IP of remote connection
    PORT_NUMBER                :std_logic_vector(15 downto 0);  -- port of remote connection
  end record plXVC_XVC_REMOTE_CTRL_t;


  constant DEFAULT_plXVC_XVC_REMOTE_CTRL_t : plXVC_XVC_REMOTE_CTRL_t := (
                                                                         IP => (others => '0'),
                                                                         PORT_NUMBER => (others => '0')
                                                                        );
  type plXVC_XVC_FIFO_MODE_LENGTH_MOSI_t is record
    clk       : std_logic;
    reset     : std_logic;
    rd_enable : std_logic;
    wr_enable : std_logic;
    wr_data   : std_logic_vector(32-1 downto 0);
  end record plXVC_XVC_FIFO_MODE_LENGTH_MOSI_t;
  type plXVC_XVC_FIFO_MODE_LENGTH_MISO_t is record
    rd_data         : std_logic_vector(32-1 downto 0);
    rd_data_valid   : std_logic;
    rd_error        : std_logic;
    wr_error        : std_logic;
    wr_response     : std_logic;
  end record plXVC_XVC_FIFO_MODE_LENGTH_MISO_t;
  constant Default_plXVC_XVC_FIFO_MODE_LENGTH_MOSI_t : plXVC_XVC_FIFO_MODE_LENGTH_MOSI_t := (
                                                     clk       => '0',
                                                     reset     => '0',
                                                     rd_enable => '0',
                                                     wr_enable => '0',
                                                     wr_data   => (others => '0')
  );
  type plXVC_XVC_FIFO_MODE_TMS_VECTOR_MOSI_t is record
    clk       : std_logic;
    reset     : std_logic;
    rd_enable : std_logic;
    wr_enable : std_logic;
    wr_data   : std_logic_vector(32-1 downto 0);
  end record plXVC_XVC_FIFO_MODE_TMS_VECTOR_MOSI_t;
  type plXVC_XVC_FIFO_MODE_TMS_VECTOR_MISO_t is record
    rd_data         : std_logic_vector(32-1 downto 0);
    rd_data_valid   : std_logic;
    rd_error        : std_logic;
    wr_error        : std_logic;
    wr_response     : std_logic;
  end record plXVC_XVC_FIFO_MODE_TMS_VECTOR_MISO_t;
  constant Default_plXVC_XVC_FIFO_MODE_TMS_VECTOR_MOSI_t : plXVC_XVC_FIFO_MODE_TMS_VECTOR_MOSI_t := (
                                                     clk       => '0',
                                                     reset     => '0',
                                                     rd_enable => '0',
                                                     wr_enable => '0',
                                                     wr_data   => (others => '0')
  );
  type plXVC_XVC_FIFO_MODE_TDI_VECTOR_MOSI_t is record
    clk       : std_logic;
    reset     : std_logic;
    rd_enable : std_logic;
    wr_enable : std_logic;
    wr_data   : std_logic_vector(32-1 downto 0);
  end record plXVC_XVC_FIFO_MODE_TDI_VECTOR_MOSI_t;
  type plXVC_XVC_FIFO_MODE_TDI_VECTOR_MISO_t is record
    rd_data         : std_logic_vector(32-1 downto 0);
    rd_data_valid   : std_logic;
    rd_error        : std_logic;
    wr_error        : std_logic;
    wr_response     : std_logic;
  end record plXVC_XVC_FIFO_MODE_TDI_VECTOR_MISO_t;
  constant Default_plXVC_XVC_FIFO_MODE_TDI_VECTOR_MOSI_t : plXVC_XVC_FIFO_MODE_TDI_VECTOR_MOSI_t := (
                                                     clk       => '0',
                                                     reset     => '0',
                                                     rd_enable => '0',
                                                     wr_enable => '0',
                                                     wr_data   => (others => '0')
  );
  type plXVC_XVC_FIFO_MODE_MON_t is record
    LENGTH                     :plXVC_XVC_FIFO_MODE_LENGTH_MISO_t;
    TMS_VECTOR                 :plXVC_XVC_FIFO_MODE_TMS_VECTOR_MISO_t;
    TDI_VECTOR                 :plXVC_XVC_FIFO_MODE_TDI_VECTOR_MISO_t;
  end record plXVC_XVC_FIFO_MODE_MON_t;


  type plXVC_XVC_FIFO_MODE_CTRL_t is record
    ENABLE                     :std_logic;     -- Enable FIFO mode
    LENGTH                     :plXVC_XVC_FIFO_MODE_LENGTH_MOSI_t;
    TMS_VECTOR                 :plXVC_XVC_FIFO_MODE_TMS_VECTOR_MOSI_t;
    TDI_VECTOR                 :plXVC_XVC_FIFO_MODE_TDI_VECTOR_MOSI_t;
  end record plXVC_XVC_FIFO_MODE_CTRL_t;


  constant DEFAULT_plXVC_XVC_FIFO_MODE_CTRL_t : plXVC_XVC_FIFO_MODE_CTRL_t := (
                                                                               ENABLE => '0',
                                                                               LENGTH => Default_plXVC_XVC_FIFO_MODE_LENGTH_MOSI_t,
                                                                               TMS_VECTOR => Default_plXVC_XVC_FIFO_MODE_TMS_VECTOR_MOSI_t,
                                                                               TDI_VECTOR => Default_plXVC_XVC_FIFO_MODE_TDI_VECTOR_MOSI_t
                                                                              );
  type plXVC_XVC_MON_t is record
    TDO_VECTOR                 :std_logic_vector(31 downto 0);  -- Test Data Out (TDO) Capture Vector
    BUSY                       :std_logic;                      -- Cable is operating
    FIFO_MODE                  :plXVC_XVC_FIFO_MODE_MON_t;
  end record plXVC_XVC_MON_t;
  type plXVC_XVC_MON_t_ARRAY is array(1 to 3) of plXVC_XVC_MON_t;

  type plXVC_XVC_CTRL_t is record
    LENGTH                     :std_logic_vector(31 downto 0);  -- Length of shift operation in bits
    TMS_VECTOR                 :std_logic_vector(31 downto 0);  -- Test Mode Select (TMS) Bit Vector
    TDI_VECTOR                 :std_logic_vector(31 downto 0);  -- Test Data In (TDI) Bit Vector
    GO                         :std_logic;                      -- Enable shift operation
    LOCK                       :std_logic_vector(31 downto 0);  -- Lock cable from access
    REMOTE                     :plXVC_XVC_REMOTE_CTRL_t;
    PS_RST                     :std_logic;                      -- PS reset
    FIFO_MODE                  :plXVC_XVC_FIFO_MODE_CTRL_t;
  end record plXVC_XVC_CTRL_t;
  type plXVC_XVC_CTRL_t_ARRAY is array(1 to 3) of plXVC_XVC_CTRL_t;

  constant DEFAULT_plXVC_XVC_CTRL_t : plXVC_XVC_CTRL_t := (
                                                           LENGTH => (others => '0'),
                                                           TMS_VECTOR => (others => '0'),
                                                           TDI_VECTOR => (others => '0'),
                                                           GO => '0',
                                                           LOCK => (others => '0'),
                                                           REMOTE => DEFAULT_plXVC_XVC_REMOTE_CTRL_t,
                                                           PS_RST => '1',
                                                           FIFO_MODE => DEFAULT_plXVC_XVC_FIFO_MODE_CTRL_t
                                                          );
  type plXVC_MON_t is record
    XVC                        :plXVC_XVC_MON_t_ARRAY;
  end record plXVC_MON_t;


  type plXVC_CTRL_t is record
    XVC                        :plXVC_XVC_CTRL_t_ARRAY;
  end record plXVC_CTRL_t;


  constant DEFAULT_plXVC_CTRL_t : plXVC_CTRL_t := (
                                                   XVC => (others => DEFAULT_plXVC_XVC_CTRL_t )
                                                  );


end package plXVC_CTRL;