

## Clock signal
set_property -dict { PACKAGE_PIN W5   IOSTANDARD LVCMOS33 } [get_ports clk_100MHz]

set_property -dict { PACKAGE_PIN R2    IOSTANDARD LVCMOS33 } [get_ports {i_rst_n}]


##USB-RS232 Interface
set_property -dict { PACKAGE_PIN B18   IOSTANDARD LVCMOS33 } [get_ports i_rx]
set_property -dict { PACKAGE_PIN A18   IOSTANDARD LVCMOS33 } [get_ports o_tx]



## Leds - Asignación de pines para los LEDs
 set_property -dict { PACKAGE_PIN U16 IOSTANDARD LVCMOS33 } [get_ports { o_PC_IF[0] }]
 set_property -dict { PACKAGE_PIN E19 IOSTANDARD LVCMOS33 } [get_ports { o_PC_IF[1] }]
 set_property -dict { PACKAGE_PIN U19 IOSTANDARD LVCMOS33 } [get_ports { o_PC_IF[2] }]
 set_property -dict { PACKAGE_PIN V19 IOSTANDARD LVCMOS33 } [get_ports { o_PC_IF[3] }]
 set_property -dict { PACKAGE_PIN W18 IOSTANDARD LVCMOS33 } [get_ports { o_PC_IF[4] }]
 set_property -dict { PACKAGE_PIN U15 IOSTANDARD LVCMOS33 } [get_ports { o_PC_IF[5] }]
 set_property -dict { PACKAGE_PIN U14 IOSTANDARD LVCMOS33 } [get_ports { o_PC_IF[6] }]
 set_property -dict { PACKAGE_PIN V14 IOSTANDARD LVCMOS33 } [get_ports { o_PC_IF[7] }]
 set_property -dict { PACKAGE_PIN V13 IOSTANDARD LVCMOS33 } [get_ports { o_PC_IF[8] }]
 set_property -dict { PACKAGE_PIN V3 IOSTANDARD LVCMOS33 } [get_ports { o_PC_IF[9] }]
 set_property -dict { PACKAGE_PIN W3 IOSTANDARD LVCMOS33 } [get_ports { o_PC_IF[10] }]
 set_property -dict { PACKAGE_PIN U3 IOSTANDARD LVCMOS33 } [get_ports { o_PC_IF[11] }]
 set_property -dict { PACKAGE_PIN P3 IOSTANDARD LVCMOS33 } [get_ports { o_PC_IF[12] }]
 set_property -dict { PACKAGE_PIN N3 IOSTANDARD LVCMOS33 } [get_ports { o_PC_IF[13] }]
 set_property -dict { PACKAGE_PIN P1 IOSTANDARD LVCMOS33 } [get_ports { o_PC_IF[14] }]
 set_property -dict { PACKAGE_PIN L1 IOSTANDARD LVCMOS33 } [get_ports { o_PC_IF[15] }]


## Configuration options, can be used for all designs
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

## SPI configuration mode options for QSPI boot, can be used for all designs
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]