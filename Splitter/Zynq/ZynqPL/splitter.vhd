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
entity splitter_design_wrapper is
  port (
    BUFFER_0_DIR : out STD_LOGIC;
    BUFFER_0_RX : in STD_LOGIC;
    BUFFER_0_TX : out STD_LOGIC;
    BUFFER_1_DIR : out STD_LOGIC;
    BUFFER_1_RX : in STD_LOGIC;
    BUFFER_1_TX : out STD_LOGIC;
    BUFFER_2_DIR : out STD_LOGIC;
    BUFFER_2_RX : in STD_LOGIC;
    BUFFER_2_TX : out STD_LOGIC;
    BUFFER_3_DIR : out STD_LOGIC;
    BUFFER_3_RX : in STD_LOGIC;
    BUFFER_3_TX : out STD_LOGIC;
    BUFFER_4_RX : in STD_LOGIC;
    BUFFER_4_TX : out STD_LOGIC;
    BUFFER_5_RX : in STD_LOGIC;
    BUFFER_5_TX : out STD_LOGIC;
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
    LEDS_OUT : out STD_LOGIC_VECTOR ( 3 downto 0 );
    MCLK : in STD_LOGIC;
    PLL_LOCK : in STD_LOGIC;
    PLL_SPI_CS : out STD_LOGIC;
    PLL_SPI_MOSI : out STD_LOGIC;
    PLL_SPI_SCLK : out STD_LOGIC;
    PLL_WCLK : out STD_LOGIC
  );
end splitter_design_wrapper;
architecture STRUCTURE of splitter_design_wrapper is
component splitter_design is
port (
  BUFFER_0_TX : out STD_LOGIC;
  BUFFER_1_TX : out STD_LOGIC;
  BUFFER_2_TX : out STD_LOGIC;
  BUFFER_3_TX : out STD_LOGIC;
  BUFFER_4_TX : out STD_LOGIC;
  BUFFER_5_TX : out STD_LOGIC;
  BUFFER_0_RX : in STD_LOGIC;
  BUFFER_1_RX : in STD_LOGIC;
  BUFFER_2_RX : in STD_LOGIC;
  BUFFER_3_RX : in STD_LOGIC;
  BUFFER_4_RX : in STD_LOGIC;
  BUFFER_5_RX : in STD_LOGIC;
  PLL_SPI_SCLK : out STD_LOGIC;
  PLL_SPI_MOSI : out STD_LOGIC;
  PLL_SPI_CS : out STD_LOGIC;
  MCLK : in STD_LOGIC;
  PLL_WCLK : out STD_LOGIC;
  PLL_LOCK : in STD_LOGIC;
  BUFFER_0_DIR : out STD_LOGIC;
  BUFFER_1_DIR : out STD_LOGIC;
  BUFFER_2_DIR : out STD_LOGIC;
  BUFFER_3_DIR : out STD_LOGIC;
  LEDS_OUT : out STD_LOGIC_VECTOR ( 3 downto 0 );
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
  FIXED_IO_ps_porb : inout STD_LOGIC
);
end component splitter_design;
  signal GPIOS_IN: std_logic_vector(10 downto 0);
  signal GPIOS_OUT: std_logic_vector(10 downto 0);
    
begin
splitter_design_i: component splitter_design
     port map (
      BUFFER_0_DIR => BUFFER_0_DIR,
      BUFFER_0_RX => BUFFER_0_RX,
      BUFFER_0_TX => BUFFER_0_TX,
      BUFFER_1_DIR => BUFFER_1_DIR,
      BUFFER_1_RX => BUFFER_1_RX,
      BUFFER_1_TX => BUFFER_1_TX,
      BUFFER_2_DIR => BUFFER_2_DIR,
      BUFFER_2_RX => BUFFER_2_RX,
      BUFFER_2_TX => BUFFER_2_TX,
      BUFFER_3_DIR => BUFFER_3_DIR,
      BUFFER_3_RX => BUFFER_3_RX,
      BUFFER_3_TX => BUFFER_3_TX,
      BUFFER_4_RX => BUFFER_4_RX,
      BUFFER_4_TX => BUFFER_4_TX,
      BUFFER_5_RX => BUFFER_5_RX,
      BUFFER_5_TX => BUFFER_5_TX,
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
      LEDS_OUT(3 downto 0) => LEDS_OUT(3 downto 0),
      MCLK => MCLK,
      PLL_LOCK => PLL_LOCK,
      PLL_SPI_CS => PLL_SPI_CS,
      PLL_SPI_MOSI => PLL_SPI_MOSI,
      PLL_SPI_SCLK => PLL_SPI_SCLK,
      PLL_WCLK => PLL_WCLK
    );
end STRUCTURE;
