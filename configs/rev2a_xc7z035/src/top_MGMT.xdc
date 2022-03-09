# -------------------------------------------------------------------------------------------------
# MGBT (refclks)
# -------------------------------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN R6 }  [get_ports REFCLK_SSD_P];     #ConnB  4 (ZX1:  R6 , XU8:  M23)
set_property -dict {PACKAGE_PIN R5 }  [get_ports REFCLK_SSD_N];     #ConnB  6 (ZX1:  R5 , XU8:  M24)

set_property -dict {PACKAGE_PIN AA6 }  [get_ports REFCLK_C2C1_P[0]]; #ConnB  7 (ZX1: AA6 , XU8:  L25)
set_property -dict {PACKAGE_PIN AA5 }  [get_ports REFCLK_C2C1_N[0]]; #ConnB  9 (ZX1: AA5 , XU8:  L26)

set_property -dict {PACKAGE_PIN U6  }  [get_ports REFCLK_CMS_P[0]];  #ConnB 10 (ZX1:  U6 , XU8:  D10)
set_property -dict {PACKAGE_PIN U5  }  [get_ports REFCLK_CMS_N[0]];  #ConnB 12 (ZX1:  U5 , XU8:  D9 )

set_property -dict {PACKAGE_PIN W6  }  [get_ports REFCLK_REC_P];     #ConnB  3 (ZX1:  W6 , XU8:  B10)
set_property -dict {PACKAGE_PIN W5  }  [get_ports REFCLK_REC_N];     #ConnB  5 (ZX1:  W5 , XU8:  B9 )


#set_property -dict {PACKAGE_PIN F10 }  [get_ports REFCLK_C2C1_P[1]]; #ConnC 10 (ZX1:  -- , XU8:  F10)
#set_property -dict {PACKAGE_PIN F9  }  [get_ports REFCLK_C2C1_N[1]]; #ConnC 12 (ZX1:  -- , XU8:  F9)
#set_property -dict {PACKAGE_PIN J8  }  [get_ports REFCLK_C2C1_P[1]]; #ConnC 10 (ZX1:  -- , XU8:  F10)
#set_property -dict {PACKAGE_PIN J7  }  [get_ports REFCLK_C2C1_N[1]]; #ConnC 12 (ZX1:  -- , XU8:  F9)

#set_property -dict {PACKAGE_PIN H10 }  [get_ports REFCLK_C2C2_P];    #ConnC  4 (ZX1:  -- , XU8:  H10)
#set_property -dict {PACKAGE_PIN H9  }  [get_ports REFCLK_C2C2_N];    #ConnC  6 (ZX1:  -- , XU8:  H9)

#set_property -dict {PACKAGE_PIN J8  }  [get_ports REFCLK_CMS_P[1]];  #ConnC  7 (ZX1:  -- , XU8:  J8)
#set_property -dict {PACKAGE_PIN J7  }  [get_ports REFCLK_CMS_N[1]];  #ConnC  9 (ZX1:  -- , XU8:  J7 )
#set_property -dict {PACKAGE_PIN  F10 }  [get_ports REFCLK_CMS_P[1]];  #ConnC  7 (ZX1:  -- , XU8:  J8)
#set_property -dict {PACKAGE_PIN  F9  }  [get_ports REFCLK_CMS_N[1]];  #ConnC  9 (ZX1:  -- , XU8:  J7 )



# -------------------------------------------------------------------------------------------------
# MGBT 
# -------------------------------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN AB4 }  [get_ports AXI_C2C_CM1_RX_P[0]]; #ConnB 16 (ZX1: AB4 , XU8:  L29)
set_property -dict {PACKAGE_PIN AB3 }  [get_ports AXI_C2C_CM1_RX_N[0]]; #ConnB 20 (ZX1: AB3 , XU8:  L30)
set_property -dict {PACKAGE_PIN AA1 }  [get_ports AXI_C2C_CM1_TX_N[0]]; #ConnB 17 (ZX1: AA1 , XU8:  M28)
set_property -dict {PACKAGE_PIN AA2 }  [get_ports AXI_C2C_CM1_TX_P[0]]; #ConnB 13 (ZX1: AA2 , XU8:  M27)
				   
set_property -dict {PACKAGE_PIN  Y4 }  [get_ports AXI_C2C_CM1_RX_P[1]]; #ConnB 24 (ZX1:  Y4 , XU8:  J29)
set_property -dict {PACKAGE_PIN  Y3 }  [get_ports AXI_C2C_CM1_RX_N[1]]; #ConnB 28 (ZX1:  Y3 , XU8:  J30)
set_property -dict {PACKAGE_PIN  W2 }  [get_ports AXI_C2C_CM1_TX_P[1]]; #ConnB 21 (ZX1:  W2 , XU8:  K27)
set_property -dict {PACKAGE_PIN  W1 }  [get_ports AXI_C2C_CM1_TX_N[1]]; #ConnB 25 (ZX1:  W1 , XU8:  K28)

set_property -dict {PACKAGE_PIN  V4 }  [get_ports SSD_RX_P ];           #ConnB 32 (ZX1:  V4 , XU8:  H27) 
set_property -dict {PACKAGE_PIN  V4 }  [get_ports SSD_RX_N ];           #ConnB 36 (ZX1:  V4 , XU8:  H28)
set_property -dict {PACKAGE_PIN  U2 }  [get_ports SSD_TX_P ];           #ConnB 29 (ZX1:  U2 , XU8:  J25) 
set_property -dict {PACKAGE_PIN  U1 }  [get_ports SSD_TX_N ];           #ConnB 33 (ZX1:  U1 , XU8:  J26)

set_property -dict {PACKAGE_PIN  T4 }  [get_ports AXI_C2C_CM2_RX_P[0]]; #ConnB 40 (ZX1:  T4 , XU8:  G29)
set_property -dict {PACKAGE_PIN  T3 }  [get_ports AXI_C2C_CM2_RX_N[0]]; #ConnB 44 (ZX1:  T3 , XU8:  G30)
set_property -dict {PACKAGE_PIN  R2 }  [get_ports AXI_C2C_CM2_TX_P[0]]; #ConnB 37 (ZX1:  R2 , XU8:  G25)
set_property -dict {PACKAGE_PIN  R1 }  [get_ports AXI_C2C_CM2_TX_N[0]]; #ConnB 41 (ZX1:  R1 , XU8:  G36)



set_property -dict {PACKAGE_PIN  AD8 }  [get_ports CM1_TCDS_TTS_P];      #ConnB 48 (ZX1: AD8 , XU8:  D2 )
set_property -dict {PACKAGE_PIN  AD7 }  [get_ports CM1_TCDS_TTS_N];      #ConnB 50 (ZX1: AD7 , XU8:  D1 )
set_property -dict {PACKAGE_PIN   K8 }  [get_ports CM1_TCDS_TTC_P];      #ConnB 45 (ZX1:  K8 , XU8:  D6 )
set_property -dict {PACKAGE_PIN   K7 }  [get_ports CM1_TCDS_TTC_N];      #ConnB 47 (ZX1:  K7 , XU8:  D5 )

set_property -dict {PACKAGE_PIN AE5 }  [get_ports TCDS_TTC_P];          #ConnB 56 (ZX1: AE5 , XU8:  C3 )
set_property -dict {PACKAGE_PIN AE6 }  [get_ports TCDS_TTC_N];          #ConnB 54 (ZX1: AE6 , XU8:  C4 )
set_property -dict {PACKAGE_PIN  N7 }  [get_ports TCDS_TTS_P];          #ConnB 51 (ZX1:  N7 , XU8:  C8 )
set_property -dict {PACKAGE_PIN  N6 }  [get_ports TCDS_TTS_N];          #ConnB 53 (ZX1:  N6 , XU8:  C7 )

set_property -dict {PACKAGE_PIN AC6 }  [get_ports AXI_C2C_CM2_RX_P[1]]; #ConnB 60 (ZX1: AC6 , XU8:  B2 )
set_property -dict {PACKAGE_PIN AC5 }  [get_ports AXI_C2C_CM2_RX_N[1]]; #ConnB 62 (ZX1: AC5 , XU8:  B1 )
set_property -dict {PACKAGE_PIN AE2 }  [get_ports AXI_C2C_CM2_TX_P[1]]; #ConnB 63 (ZX1: AE2 , XU8:  B6 )
set_property -dict {PACKAGE_PIN AE1 }  [get_ports AXI_C2C_CM2_TX_N[1]]; #ConnB 65 (ZX1: AE1 , XU8:  B5 )

set_property -dict {PACKAGE_PIN AD4 }  [get_ports CM2_TCDS_TTS_P];      #ConnB 66 (ZX1: AD4 , XU8:  A4 )
set_property -dict {PACKAGE_PIN AD3 }  [get_ports CM2_TCDS_TTS_N];      #ConnB 68 (ZX1: AD3 , XU8:  A3 )
set_property -dict {PACKAGE_PIN  K6 }  [get_ports CM2_TCDS_TTC_P];      #ConnB 69 (ZX1:  K6 , XU8:  A8 )
set_property -dict {PACKAGE_PIN  J6 }  [get_ports CM2_TCDS_TTC_N];      #ConnB 71 (ZX1:  J6 , XU8:  A7 )





####set_property -dict {PACKAGE_PIN  H2 }  [get_ports LDAQ_RX_P];           #ConnC 16 (ZX1:  -- , XU8:  H2 )
####set_property -dict {PACKAGE_PIN  H1 }  [get_ports LDAQ_RX_N];           #ConnC 20 (ZX1:  -- , XU8:  H1 )
####set_property -dict {PACKAGE_PIN  H6 }  [get_ports LDAQ_TX_P];           #ConnC 13 (ZX1:  -- , XU8:  H6 )
####set_property -dict {PACKAGE_PIN  H5 }  [get_ports LDAQ_TX_N];           #ConnC 17 (ZX1:  -- , XU8:  H5 )
####
####
####set_property -dict {PACKAGE_PIN  J4 }  [get_ports AXI_C2C_CM1_RX_P[0]];    #ConnC 66 (ZX1:  -- , XU8:  J4 )
####set_property -dict {PACKAGE_PIN  J3 }  [get_ports AXI_C2C_CM1_RX_N[0]];    #ConnC 68 (ZX1:  -- , XU8:  J3 )
####set_property -dict {PACKAGE_PIN  K6 }  [get_ports AXI_C2C_CM1_TX_P[0]];    #ConnC 63 (ZX1:  -- , XU8:  K6 )
####set_property -dict {PACKAGE_PIN  K5 }  [get_ports AXI_C2C_CM1_TX_N[0]];    #ConnC 65 (ZX1:  -- , XU8:  K5 )
####								        
####set_property -dict {PACKAGE_PIN  K2 }  [get_ports AXI_C2C_CM1_RX_P[1]];    #ConnC 60 (ZX1:  -- , XU8:  K2 )
####set_property -dict {PACKAGE_PIN  K1 }  [get_ports AXI_C2C_CM1_RX_N[1]];    #ConnC 62 (ZX1:  -- , XU8:  K1 )
####set_property -dict {PACKAGE_PIN  L3 }  [get_ports AXI_C2C_CM1_TX_P[1]];    #ConnC 59 (ZX1:  -- , XU8:  L3 )
####set_property -dict {PACKAGE_PIN  L4 }  [get_ports AXI_C2C_CM1_TX_N[1]];    #ConnC 57 (ZX1:  -- , XU8:  L4 )
####								        
####set_property -dict {PACKAGE_PIN  N4 }  [get_ports AXI_C2C_CM2_RX_P[0]];    #ConnC 48 (ZX1:  -- , XU8:  N4 )
####set_property -dict {PACKAGE_PIN  N3 }  [get_ports AXI_C2C_CM2_RX_N[0]];    #ConnC 50 (ZX1:  -- , XU8:  N3 )
#####set_property -dict {PACKAGE_PIN  P5 }  [get_ports AXI_C2C_CM2_TX_P[0]];    #ConnC 47 (ZX1:  -- , XU8:  P5 )
#####set_property -dict {PACKAGE_PIN  P6 }  [get_ports AXI_C2C_CM2_TX_N[0]];    #ConnC 45 (ZX1:  -- , XU8:  P6 )
####set_property -dict {PACKAGE_PIN  P5 }  [get_ports AXI_C2C_CM2_TX_N[0]];    #ConnC 47 (ZX1:  -- , XU8:  P5 )
####set_property -dict {PACKAGE_PIN  P6 }  [get_ports AXI_C2C_CM2_TX_P[0]];    #ConnC 45 (ZX1:  -- , XU8:  P6 )

