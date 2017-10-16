--Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2016.4 (win64) Build 1756540 Mon Jan 23 19:11:23 MST 2017
--Date        : Fri May 05 18:13:51 2017
--Host        : Andrea-bdPC running 64-bit major release  (build 9200)
--Command     : generate_target table_hub_design_wrapper.bd
--Design      : table_hub_design_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity mic_pod_design_wrapper is
  port (
    BUS0_RX : in STD_LOGIC;
    BUS0_TX : out STD_LOGIC;
    BUS1_RX : in STD_LOGIC;
    BUS1_TX : out STD_LOGIC;
    DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
    DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR_cas_n : inout STD_LOGIC;
    DDR_ck_n : inout STD_LOGIC;
    DDR_ck_p : inout STD_LOGIC;
    DDR_cke : inout STD_LOGIC;
    DDR_cs_n : inout STD_LOGIC;
    DDR_dm : inout STD_LOGIC_VECTOR ( 1 downto 0 );
    DDR_dq : inout STD_LOGIC_VECTOR ( 15 downto 0 );
    DDR_dqs_n : inout STD_LOGIC_VECTOR ( 1 downto 0 );
    DDR_dqs_p : inout STD_LOGIC_VECTOR ( 1 downto 0 );
    DDR_odt : inout STD_LOGIC;
    DDR_ras_n : inout STD_LOGIC;
    DDR_reset_n : inout STD_LOGIC;
    DDR_we_n : inout STD_LOGIC;
    FIXED_IO_ddr_vrn : inout STD_LOGIC;
    FIXED_IO_ddr_vrp : inout STD_LOGIC;
    FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    FIXED_IO_ps_clk : inout STD_LOGIC;
    FIXED_IO_ps_porb : inout STD_LOGIC;
    FIXED_IO_ps_srstb : inout STD_LOGIC;
    MCLK : in STD_LOGIC;
    PLL_SPI_CS : out STD_LOGIC;
    PLL_SPI_MOSI : out STD_LOGIC;
    PLL_SPI_SCLK : out STD_LOGIC;
    PLL_WCLK : out STD_LOGIC;
    PLL_AUX : in STD_LOGIC;
    LEDS: out STD_LOGIC_VECTOR(7 downto 0);
    ADC_RSTN_01 : out STD_LOGIC;
    ADC_RSTN_23 : out STD_LOGIC;
    MUTE_BUTTON : in STD_LOGIC;
    WS_01 : out STD_LOGIC;
    SCK_01 : out STD_LOGIC;
    ADC_SD_01 : in STD_LOGIC;   
    MEMS01_D : in STD_LOGIC;
    
    WS_23 : out STD_LOGIC;
    SCK_23 : out STD_LOGIC;
    ADC_SD_23 : in STD_LOGIC;
    MEMS23_D : in STD_LOGIC  
        
  );
end mic_pod_design_wrapper;

architecture STRUCTURE of mic_pod_design_wrapper is
  component mic_pod_design is
  port (
    BUS0_TX : out STD_LOGIC;
    BUS0_RX : in STD_LOGIC;
    BUS1_TX : out STD_LOGIC;
    BUS1_RX : in STD_LOGIC;
    PLL_SPI_SCLK : out STD_LOGIC;
    PLL_SPI_MOSI : out STD_LOGIC;
    PLL_SPI_CS : out STD_LOGIC;
    MCLK : in STD_LOGIC;
    PLL_WCLK : out STD_LOGIC;
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
    DDR_dm : inout STD_LOGIC_VECTOR ( 1 downto 0 );
    DDR_dq : inout STD_LOGIC_VECTOR ( 15 downto 0 );
    DDR_dqs_n : inout STD_LOGIC_VECTOR ( 1 downto 0 );
    DDR_dqs_p : inout STD_LOGIC_VECTOR ( 1 downto 0 );
    FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    FIXED_IO_ddr_vrn : inout STD_LOGIC;
    FIXED_IO_ddr_vrp : inout STD_LOGIC;
    FIXED_IO_ps_srstb : inout STD_LOGIC;
    FIXED_IO_ps_clk : inout STD_LOGIC;
    FIXED_IO_ps_porb : inout STD_LOGIC;
    GPIOS_OUT: out STD_LOGIC_VECTOR(10 downto 0);
    GPIOS_IN: in STD_LOGIC_VECTOR(10 downto 0);
    WS_01 : out STD_LOGIC;
    SCK_01 : out STD_LOGIC;
    ADC_SD_01 : in STD_LOGIC;   
    MEMS01_D : in STD_LOGIC;
    
    WS_23 : out STD_LOGIC;
    SCK_23 : out STD_LOGIC;
    ADC_SD_23 : in STD_LOGIC;
    MEMS23_D : in STD_LOGIC  
  );
  end component mic_pod_design;
  signal GPIOS_IN: std_logic_vector(10 downto 0);
  signal GPIOS_OUT: std_logic_vector(10 downto 0);
    
begin
mic_pod_design_i: component mic_pod_design
     port map (
      BUS0_RX => BUS0_RX,
      BUS0_TX => BUS0_TX,
      BUS1_RX => BUS1_RX,
      BUS1_TX => BUS1_TX,
      DDR_addr(14 downto 0) => DDR_addr(14 downto 0),
      DDR_ba(2 downto 0) => DDR_ba(2 downto 0),
      DDR_cas_n => DDR_cas_n,
      DDR_ck_n => DDR_ck_n,
      DDR_ck_p => DDR_ck_p,
      DDR_cke => DDR_cke,
      DDR_cs_n => DDR_cs_n,
      DDR_dm(1 downto 0) => DDR_dm(1 downto 0),
      DDR_dq(15 downto 0) => DDR_dq(15 downto 0),
      DDR_dqs_n(1 downto 0) => DDR_dqs_n(1 downto 0),
      DDR_dqs_p(1 downto 0) => DDR_dqs_p(1 downto 0),
      DDR_odt => DDR_odt,
      DDR_ras_n => DDR_ras_n,
      DDR_reset_n => DDR_reset_n,
      DDR_we_n => DDR_we_n,
      FIXED_IO_ddr_vrn => FIXED_IO_ddr_vrn,
      FIXED_IO_ddr_vrp => FIXED_IO_ddr_vrp,
      FIXED_IO_mio(31 downto 0) => FIXED_IO_mio(31 downto 0),
      FIXED_IO_ps_clk => FIXED_IO_ps_clk,
      FIXED_IO_ps_porb => FIXED_IO_ps_porb,
      FIXED_IO_ps_srstb => FIXED_IO_ps_srstb,
      MCLK => MCLK,
      PLL_SPI_CS => PLL_SPI_CS,
      PLL_SPI_MOSI => PLL_SPI_MOSI,
      PLL_SPI_SCLK => PLL_SPI_SCLK,
      PLL_WCLK => PLL_WCLK,
      GPIOS_OUT => GPIOS_OUT,
      GPIOS_IN => GPIOS_IN,
      WS_01 => WS_01,
      SCK_01 => SCK_01,
      ADC_SD_01 => ADC_SD_01,
      MEMS01_D => MEMS01_D,
      
      WS_23 => WS_23,
      SCK_23 => SCK_23,
      ADC_SD_23 => ADC_SD_23,
      MEMS23_D => MEMS23_D
    );
    LEDS <= GPIOS_OUT(7 downto 0);
    
     ADC_RSTN_01 <= GPIOS_OUT(8);
     ADC_RSTN_23 <= GPIOS_OUT(9);
     GPIOS_IN(9 downto 0) <= GPIOS_OUT(9 downto 0);
     GPIOS_IN(10) <= MUTE_BUTTON;
    
end STRUCTURE;
