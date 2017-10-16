----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 18.12.2013 14:59:19
-- Design Name: 
-- Module Name: i2s_slave_receiver - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--use IEEE.std_logic_arith.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;



entity gain_block is
Generic(
    S_AXI_DATA_WIDTH    : integer    := 32;
    S_AXI_ADDR_WIDTH    : integer    := 3
	);
Port ( 
    clk 	 	: in  STD_LOGIC;
    rst_n 	 	: in  STD_LOGIC;
    lrclk 	 	: in  STD_LOGIC;
	in0  	 	: in  STD_LOGIC_VECTOR (23 downto 0);
	in1  	 	: in  STD_LOGIC_VECTOR (23 downto 0);

	out0  	 	: out STD_LOGIC_VECTOR (23 downto 0);
	out1  	 	: out STD_LOGIC_VECTOR (23 downto 0);
	
    S_AXI_AWADDR    : in std_logic_vector(S_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_AWPROT    : in std_logic_vector(2 downto 0);
    S_AXI_AWVALID    : in std_logic;
    S_AXI_AWREADY    : out std_logic;
    S_AXI_WDATA    : in std_logic_vector(S_AXI_DATA_WIDTH-1 downto 0);
    S_AXI_WSTRB    : in std_logic_vector((S_AXI_DATA_WIDTH/8)-1 downto 0);
    S_AXI_WVALID    : in std_logic;
    S_AXI_WREADY    : out std_logic;
    S_AXI_BRESP    : out std_logic_vector(1 downto 0);
    S_AXI_BVALID    : out std_logic;
    S_AXI_BREADY    : in std_logic;
    S_AXI_ARADDR    : in std_logic_vector(S_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_ARPROT    : in std_logic_vector(2 downto 0);
    S_AXI_ARVALID    : in std_logic;
    S_AXI_ARREADY    : out std_logic;
    S_AXI_RDATA    : out std_logic_vector(S_AXI_DATA_WIDTH-1 downto 0);
    S_AXI_RRESP    : out std_logic_vector(1 downto 0);
    S_AXI_RVALID    : out std_logic;
    S_AXI_RREADY    : in std_logic
    );
end gain_block;

architecture Behavioral of gain_block is    
	component gain_reg is
    generic (
        C_S_AXI_DATA_WIDTH    : integer    := 32;
        C_S_AXI_ADDR_WIDTH    : integer    := 3
    );
    port (
        VOLUME : out std_logic_vector(11 downto 0);
        S_AXI_ACLK    : in std_logic;
        S_AXI_ARESETN    : in std_logic;
        S_AXI_AWADDR    : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
        S_AXI_AWPROT    : in std_logic_vector(2 downto 0);
        S_AXI_AWVALID    : in std_logic;
        S_AXI_AWREADY    : out std_logic;
        S_AXI_WDATA    : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        S_AXI_WSTRB    : in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
        S_AXI_WVALID    : in std_logic;
        S_AXI_WREADY    : out std_logic;
        S_AXI_BRESP    : out std_logic_vector(1 downto 0);
        S_AXI_BVALID    : out std_logic;
        S_AXI_BREADY    : in std_logic;
        S_AXI_ARADDR    : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
        S_AXI_ARPROT    : in std_logic_vector(2 downto 0);
        S_AXI_ARVALID    : in std_logic;
        S_AXI_ARREADY    : out std_logic;
        S_AXI_RDATA    : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        S_AXI_RRESP    : out std_logic_vector(1 downto 0);
        S_AXI_RVALID    : out std_logic;
        S_AXI_RREADY    : in std_logic
    );
    end component;
	
	signal volume_r : std_logic_vector(11 downto 0);
	signal lrclk_r : std_logic_vector(1 downto 0);
	signal in0_r : std_logic_vector(23 downto 0);
	signal in1_r : std_logic_vector(23 downto 0);
    signal in0_rm : std_logic_vector(36 downto 0);
    signal in1_rm : std_logic_vector(36 downto 0);
begin

    sample_in : process(clk, rst_n)
    begin
        if(rst_n='0')then
            lrclk_r <= "00";
        elsif rising_edge(clk) then
			lrclk_r <= lrclk_r(0) & lrclk;
			if(lrclk_r="10")then
                in0_r <= in0;
                in1_r <= in1;
				in0_rm <= std_logic_vector(signed(in0_r ) * signed('0'& volume_r));
				in1_rm <= std_logic_vector(signed(in1_r ) * signed('0'& volume_r));
				out0 <= in0_rm(35 downto 12);
				out1 <= in1_rm(35 downto 12);
			end if;
        end if; 
    end process;
	
	
	

    gain_reg_0: gain_reg
    generic map (
        C_S_AXI_DATA_WIDTH    => S_AXI_DATA_WIDTH,
        C_S_AXI_ADDR_WIDTH    => S_AXI_ADDR_WIDTH
    )
    port map (
        VOLUME      => volume_r,
        S_AXI_ACLK        => clk,
        S_AXI_ARESETN    => rst_n,
        S_AXI_AWADDR    => s_axi_awaddr,
        S_AXI_AWPROT    => s_axi_awprot,
        S_AXI_AWVALID    => s_axi_awvalid,
        S_AXI_AWREADY    => s_axi_awready,
        S_AXI_WDATA        => s_axi_wdata,
        S_AXI_WSTRB        => s_axi_wstrb,
        S_AXI_WVALID    => s_axi_wvalid,
        S_AXI_WREADY    => s_axi_wready,
        S_AXI_BRESP        => s_axi_bresp,
        S_AXI_BVALID    => s_axi_bvalid,
        S_AXI_BREADY    => s_axi_bready,
        S_AXI_ARADDR    => s_axi_araddr,
        S_AXI_ARPROT    => s_axi_arprot,
        S_AXI_ARVALID    => s_axi_arvalid,
        S_AXI_ARREADY    => s_axi_arready,
        S_AXI_RDATA        => s_axi_rdata,
        S_AXI_RRESP        => s_axi_rresp,
        S_AXI_RVALID    => s_axi_rvalid,
        S_AXI_RREADY    => s_axi_rready
    );
    
	
	
	
end Behavioral;
