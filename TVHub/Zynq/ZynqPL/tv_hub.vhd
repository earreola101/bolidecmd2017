--Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2017.1 (win64) Build 1846317 Fri Apr 14 18:55:03 MDT 2017
--Date        : Thu Apr 27 11:21:40 2017
--Host        : Andrea-bdPC running 64-bit major release  (build 9200)
--Command     : generate_target table_hub_design_wrapper.bd
--Design      : table_hub_design_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity tv_hub_design_wrapper is
  port (
    DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
    DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR_cas_n : inout STD_LOGIC;
    DDR_ck_n : inout STD_LOGIC;
    DDR_ck_p : inout STD_LOGIC;
    DDR_cke : inout STD_LOGIC;
    DDR_cs_n : inout STD_LOGIC;
    DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_odt : inout STD_LOGIC;
    DDR_ras_n : inout STD_LOGIC;
    DDR_reset_n : inout STD_LOGIC;
    DDR_we_n : inout STD_LOGIC;
    FIXED_IO_ddr_vrn : inout STD_LOGIC;
    FIXED_IO_ddr_vrp : inout STD_LOGIC;
    FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_ps_clk : inout STD_LOGIC;
    FIXED_IO_ps_porb : inout STD_LOGIC;
    FIXED_IO_ps_srstb : inout STD_LOGIC;
    STM32_BOOT0 : out STD_LOGIC;
    STM32_NRST_M : out STD_LOGIC;
    UART_0_RX : in STD_LOGIC;
    UART_1_RX : in STD_LOGIC;
    UART_2_RX : in STD_LOGIC;
    UART_0_TX : out STD_LOGIC;
    UART_1_TX : out STD_LOGIC;
    UART_2_TX : out STD_LOGIC;
    BUFFER_3_DIR : out STD_LOGIC;
    BUFFER_3_RX : in STD_LOGIC;
    BUFFER_3_TX : out STD_LOGIC;
    BUFFER_4_DIR : out STD_LOGIC;
    BUFFER_4_RX : in STD_LOGIC;
    BUFFER_4_TX : out STD_LOGIC;
	PLL_SPI_CS : out STD_LOGIC;
    PLL_SPI_MOSI : out STD_LOGIC;
    PLL_SPI_SCLK : out STD_LOGIC;
    I2S_0_SCK : out STD_LOGIC;
    I2S_0_SDI : in STD_LOGIC;
    I2S_0_SDO : out STD_LOGIC_VECTOR ( 0 to 0 );
    I2S_0_WS : out STD_LOGIC;
    I2S_USB_SCK : in STD_LOGIC;
    I2S_USB_SD_IN : in STD_LOGIC;
    I2S_USB_SD_OUT : out STD_LOGIC_VECTOR ( 0 to 0 );
    I2S_USB_WS : in STD_LOGIC;
    AES3_1_TX : out STD_LOGIC;
    AES3_2_TX : out STD_LOGIC;
    PLL_MCLK : in STD_LOGIC;
    PLL_WCLK : out STD_LOGIC
  );
end tv_hub_design_wrapper;

architecture STRUCTURE of tv_hub_design_wrapper is
  component tv_hub_design is
  port (
    DDR_cas_n : inout STD_LOGIC;
    DDR_cke : inout STD_LOGIC;
    DDR_ck_n : inout STD_LOGIC;
    DDR_ck_p : inout STD_LOGIC;
    DDR_cs_n : inout STD_LOGIC;
    DDR_reset_n : inout STD_LOGIC;
    DDR_odt : inout STD_LOGIC;
    DDR_ras_n : inout STD_LOGIC;
    DDR_we_n : inout STD_LOGIC;
    DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
    DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_ddr_vrn : inout STD_LOGIC;
    FIXED_IO_ddr_vrp : inout STD_LOGIC;
    FIXED_IO_ps_srstb : inout STD_LOGIC;
    FIXED_IO_ps_clk : inout STD_LOGIC;
    FIXED_IO_ps_porb : inout STD_LOGIC;
    GPO : out STD_LOGIC_VECTOR ( 1 downto 0 );
    UART_CMD_rxd : in STD_LOGIC;
    UART_CMD_txd : out STD_LOGIC;
    UART_DBG_rxd : in STD_LOGIC;
    UART_DBG_txd : out STD_LOGIC;
    UART_STM_rxd : in STD_LOGIC;
    UART_STM_txd : out STD_LOGIC;
    BUS_HUB_0_DIR : out STD_LOGIC;
    BUS_HUB_0_RX : in STD_LOGIC;
    BUS_HUB_0_TX : out STD_LOGIC;
	PLL_SPI_CS : out STD_LOGIC;
    PLL_SPI_MOSI : out STD_LOGIC;
    PLL_SPI_SCLK : out STD_LOGIC;
    I2S_0_SCK : out STD_LOGIC;
    I2S_0_SDI : in STD_LOGIC;
    I2S_0_SDO : out STD_LOGIC_VECTOR ( 0 to 0 );
    I2S_0_WS : out STD_LOGIC;
    I2S_USB_SCK : in STD_LOGIC;
    I2S_USB_SD_IN : in STD_LOGIC;
    I2S_USB_SD_OUT : out STD_LOGIC_VECTOR ( 0 to 0 );
    I2S_USB_WS : in STD_LOGIC;
    AES3_1_TX : out STD_LOGIC;
    AES3_2_TX : out STD_LOGIC;
    PLL_MCLK : in STD_LOGIC;
    PLL_WCLK : out STD_LOGIC
  );
  end component tv_hub_design;
  
  signal GPO : std_logic_vector(1 downto 0);
  
  signal BUS_HUB_0_DIR : STD_LOGIC;
  signal BUS_HUB_0_RX : STD_LOGIC;
  signal BUS_HUB_0_TX : STD_LOGIC;
  
begin
tv_hub_design_i: component tv_hub_design
     port map (
      DDR_addr(14 downto 0) => DDR_addr(14 downto 0),
      DDR_ba(2 downto 0) => DDR_ba(2 downto 0),
      DDR_cas_n => DDR_cas_n,
      DDR_ck_n => DDR_ck_n,
      DDR_ck_p => DDR_ck_p,
      DDR_cke => DDR_cke,
      DDR_cs_n => DDR_cs_n,
      DDR_dm(3 downto 0) => DDR_dm(3 downto 0),
      DDR_dq(31 downto 0) => DDR_dq(31 downto 0),
      DDR_dqs_n(3 downto 0) => DDR_dqs_n(3 downto 0),
      DDR_dqs_p(3 downto 0) => DDR_dqs_p(3 downto 0),
      DDR_odt => DDR_odt,
      DDR_ras_n => DDR_ras_n,
      DDR_reset_n => DDR_reset_n,
      DDR_we_n => DDR_we_n,
      FIXED_IO_ddr_vrn => FIXED_IO_ddr_vrn,
      FIXED_IO_ddr_vrp => FIXED_IO_ddr_vrp,
      FIXED_IO_mio(53 downto 0) => FIXED_IO_mio(53 downto 0),
      FIXED_IO_ps_clk => FIXED_IO_ps_clk,
      FIXED_IO_ps_porb => FIXED_IO_ps_porb,
      FIXED_IO_ps_srstb => FIXED_IO_ps_srstb,
      GPO => GPO,
	  UART_CMD_rxd => UART_1_RX,
      UART_CMD_txd => UART_1_TX,
      UART_DBG_rxd => UART_2_RX,
      UART_DBG_txd => UART_2_TX,
      UART_STM_rxd => UART_0_RX,
      UART_STM_txd => UART_0_TX,
      BUS_HUB_0_DIR => BUS_HUB_0_DIR,
      BUS_HUB_0_RX => BUS_HUB_0_RX,
      BUS_HUB_0_TX => BUS_HUB_0_TX,
	  PLL_SPI_CS => PLL_SPI_CS,
	  PLL_SPI_MOSI => PLL_SPI_MOSI,
	  PLL_SPI_SCLK => PLL_SPI_SCLK,
      I2S_0_SCK => I2S_0_SCK,
      I2S_0_SDI => I2S_0_SDI,
      I2S_0_SDO => I2S_0_SDO,
      I2S_0_WS => I2S_0_WS,
      I2S_USB_SCK => I2S_USB_SCK,
      I2S_USB_SD_IN =>I2S_USB_SD_IN,
      I2S_USB_SD_OUT =>I2S_USB_SD_OUT,
      I2S_USB_WS =>I2S_USB_WS,
      AES3_1_TX => AES3_1_TX,
      AES3_2_TX => AES3_2_TX,
      PLL_MCLK => PLL_MCLK,
      PLL_WCLK => PLL_WCLK
    );
    
    STM32_BOOT0 <= GPO(0);
    STM32_NRST_M <= GPO(1);
    
   
    BUFFER_3_DIR <= BUS_HUB_0_DIR;
    BUFFER_4_DIR <= not BUS_HUB_0_DIR;
    BUFFER_3_TX <= BUS_HUB_0_TX;
    BUFFER_4_TX <= BUS_HUB_0_TX;
    BUS_HUB_0_RX <= BUFFER_3_RX when BUS_HUB_0_DIR = '0' else BUFFER_4_RX;

end STRUCTURE;
