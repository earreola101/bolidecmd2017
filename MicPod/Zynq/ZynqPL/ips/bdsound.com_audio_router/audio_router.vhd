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
use IEEE.std_logic_arith.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity audio_router is
Generic(

	constant AUDIO_CHANNELS 	: integer := 15;
	constant INTERFACE_NUMBER	: integer := 3;
	-- Width of S_AXI data bus
    C_S_AXI_DATA_WIDTH    : integer    := 32;
    -- Width of S_AXI address bus
    C_S_AXI_ADDR_WIDTH    : integer    := 4
);
Port ( 
    clk 			: in STD_LOGIC;
    rst_n 			: in STD_LOGIC;
	
	wclk			: in STD_LOGIC := '0';

    int_bram_w_clk 		: out STD_LOGIC;
    int_bram_w_rst     	: out STD_LOGIC;
    int_bram_w_en       : out STD_LOGIC;
    int_bram_w_wen      : out STD_LOGIC_VECTOR(0 downto 0);    
    int_bram_w_addr     : out STD_LOGIC_VECTOR(5 downto 0);
    int_bram_w_din     	: out STD_LOGIC_VECTOR(25 downto 0);
    
    int_bram_r_clk      : out STD_LOGIC;
    int_bram_r_rst     	: out STD_LOGIC;
    int_bram_r_en       : out STD_LOGIC;
    int_bram_r_addr     : out STD_LOGIC_VECTOR(5 downto 0);
    int_bram_r_dout     : in STD_LOGIC_VECTOR(25 downto 0);
    
	audio_out_data_0 	: out STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_out_valid_0 	: out STD_LOGIC := '0';
	audio_out_mute_0 	: out STD_LOGIC := '0';
	audio_out_data_1 	: out STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_out_valid_1 	: out STD_LOGIC := '0';
	audio_out_mute_1 	: out STD_LOGIC := '0';
	audio_out_data_2 	: out STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_out_valid_2 	: out STD_LOGIC := '0';
	audio_out_mute_2 	: out STD_LOGIC := '0';
	audio_out_data_3 	: out STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_out_valid_3 	: out STD_LOGIC := '0';
	audio_out_mute_3 	: out STD_LOGIC := '0';
	audio_out_data_4 	: out STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_out_valid_4 	: out STD_LOGIC := '0';
	audio_out_mute_4 	: out STD_LOGIC := '0';
	audio_out_data_5 	: out STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_out_valid_5 	: out STD_LOGIC := '0';
	audio_out_mute_5 	: out STD_LOGIC := '0'; 
	audio_out_data_6 	: out STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_out_valid_6 	: out STD_LOGIC := '0';
	audio_out_mute_6 	: out STD_LOGIC := '0';
	audio_out_data_7 	: out STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_out_valid_7 	: out STD_LOGIC := '0';
	audio_out_mute_7 	: out STD_LOGIC := '0';
	audio_out_data_8 	: out STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_out_valid_8 	: out STD_LOGIC := '0';
	audio_out_mute_8 	: out STD_LOGIC := '0';
	audio_out_data_9 	: out STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_out_valid_9 	: out STD_LOGIC := '0';
	audio_out_mute_9 	: out STD_LOGIC := '0';
	audio_out_data_10 	: out STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_out_valid_10  : out STD_LOGIC := '0';
	audio_out_mute_10 	: out STD_LOGIC := '0';
	audio_out_data_11 	: out STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_out_valid_11  : out STD_LOGIC := '0';
	audio_out_mute_11 	: out STD_LOGIC := '0';
	audio_out_data_12 	: out STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_out_valid_12  : out STD_LOGIC := '0';
	audio_out_mute_12 	: out STD_LOGIC := '0';
	audio_out_data_13 	: out STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_out_valid_13  : out STD_LOGIC := '0';
	audio_out_mute_13 	: out STD_LOGIC := '0';
	audio_out_data_14 	: out STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_out_valid_14  : out STD_LOGIC := '0';
	audio_out_mute_14 	: out STD_LOGIC := '0';
	
	audio_0_in_data_0 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_0_in_valid_0 	: in STD_LOGIC := '0';
	audio_0_in_mute_0 	: in STD_LOGIC := '0';
	audio_0_in_data_1 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_0_in_valid_1 	: in STD_LOGIC := '0';
	audio_0_in_mute_1 	: in STD_LOGIC := '0';
	audio_0_in_data_2 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_0_in_valid_2 	: in STD_LOGIC := '0';
	audio_0_in_mute_2 	: in STD_LOGIC := '0';
	audio_0_in_data_3 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_0_in_valid_3 	: in STD_LOGIC := '0';
	audio_0_in_mute_3 	: in STD_LOGIC := '0';
	audio_0_in_data_4 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_0_in_valid_4 	: in STD_LOGIC := '0';
	audio_0_in_mute_4 	: in STD_LOGIC := '0';
	audio_0_in_data_5 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_0_in_valid_5 	: in STD_LOGIC := '0';
	audio_0_in_mute_5 	: in STD_LOGIC := '0'; 
	audio_0_in_data_6 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_0_in_valid_6 	: in STD_LOGIC := '0';
	audio_0_in_mute_6 	: in STD_LOGIC := '0';
	audio_0_in_data_7 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_0_in_valid_7 	: in STD_LOGIC := '0';
	audio_0_in_mute_7 	: in STD_LOGIC := '0';
	audio_0_in_data_8 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_0_in_valid_8 	: in STD_LOGIC := '0';
	audio_0_in_mute_8 	: in STD_LOGIC := '0';
	audio_0_in_data_9 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_0_in_valid_9 	: in STD_LOGIC := '0';
	audio_0_in_mute_9 	: in STD_LOGIC := '0';
	audio_0_in_data_10 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_0_in_valid_10 : in STD_LOGIC := '0';
	audio_0_in_mute_10 	: in STD_LOGIC := '0';
	audio_0_in_data_11 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_0_in_valid_11 : in STD_LOGIC := '0';
	audio_0_in_mute_11 	: in STD_LOGIC := '0';
	audio_0_in_data_12 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_0_in_valid_12 : in STD_LOGIC := '0';
	audio_0_in_mute_12 	: in STD_LOGIC := '0';
	audio_0_in_data_13 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_0_in_valid_13 : in STD_LOGIC := '0';
	audio_0_in_mute_13 	: in STD_LOGIC := '0';
	audio_0_in_data_14 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_0_in_valid_14 : in STD_LOGIC := '0';
	audio_0_in_mute_14 	: in STD_LOGIC := '0';
	
	
	audio_1_in_data_0 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_1_in_valid_0 	: in STD_LOGIC := '0';
	audio_1_in_mute_0 	: in STD_LOGIC := '0';
	audio_1_in_data_1 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_1_in_valid_1 	: in STD_LOGIC := '0';
	audio_1_in_mute_1 	: in STD_LOGIC := '0';
	audio_1_in_data_2 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_1_in_valid_2 	: in STD_LOGIC := '0';
	audio_1_in_mute_2 	: in STD_LOGIC := '0';
	audio_1_in_data_3 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_1_in_valid_3 	: in STD_LOGIC := '0';
	audio_1_in_mute_3 	: in STD_LOGIC := '0';
	audio_1_in_data_4 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_1_in_valid_4 	: in STD_LOGIC := '0';
	audio_1_in_mute_4 	: in STD_LOGIC := '0';
	audio_1_in_data_5 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_1_in_valid_5 	: in STD_LOGIC := '0';
	audio_1_in_mute_5 	: in STD_LOGIC := '0'; 
	audio_1_in_data_6 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_1_in_valid_6 	: in STD_LOGIC := '0';
	audio_1_in_mute_6 	: in STD_LOGIC := '0';
	audio_1_in_data_7 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_1_in_valid_7 	: in STD_LOGIC := '0';
	audio_1_in_mute_7 	: in STD_LOGIC := '0';
	audio_1_in_data_8 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_1_in_valid_8 	: in STD_LOGIC := '0';
	audio_1_in_mute_8 	: in STD_LOGIC := '0';
	audio_1_in_data_9 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_1_in_valid_9 	: in STD_LOGIC := '0';
	audio_1_in_mute_9 	: in STD_LOGIC := '0';
	audio_1_in_data_10 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_1_in_valid_10 : in STD_LOGIC := '0';
	audio_1_in_mute_10 	: in STD_LOGIC := '0';
	audio_1_in_data_11 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_1_in_valid_11 : in STD_LOGIC := '0';
	audio_1_in_mute_11 	: in STD_LOGIC := '0';
	audio_1_in_data_12 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_1_in_valid_12 : in STD_LOGIC := '0';
	audio_1_in_mute_12 	: in STD_LOGIC := '0';
	audio_1_in_data_13 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_1_in_valid_13 : in STD_LOGIC := '0';
	audio_1_in_mute_13 	: in STD_LOGIC := '0';
	audio_1_in_data_14 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_1_in_valid_14 : in STD_LOGIC := '0';
	audio_1_in_mute_14 	: in STD_LOGIC := '0';
	
	
	audio_2_in_data_0 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_2_in_valid_0 	: in STD_LOGIC := '0';
	audio_2_in_mute_0 	: in STD_LOGIC := '0';
	audio_2_in_data_1 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_2_in_valid_1 	: in STD_LOGIC := '0';
	audio_2_in_mute_1 	: in STD_LOGIC := '0';
	audio_2_in_data_2 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_2_in_valid_2 	: in STD_LOGIC := '0';
	audio_2_in_mute_2 	: in STD_LOGIC := '0';
	audio_2_in_data_3 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_2_in_valid_3 	: in STD_LOGIC := '0';
	audio_2_in_mute_3 	: in STD_LOGIC := '0';
	audio_2_in_data_4 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_2_in_valid_4 	: in STD_LOGIC := '0';
	audio_2_in_mute_4 	: in STD_LOGIC := '0';
	audio_2_in_data_5 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_2_in_valid_5 	: in STD_LOGIC := '0';
	audio_2_in_mute_5 	: in STD_LOGIC := '0'; 
	audio_2_in_data_6 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_2_in_valid_6 	: in STD_LOGIC := '0';
	audio_2_in_mute_6 	: in STD_LOGIC := '0';
	audio_2_in_data_7 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_2_in_valid_7 	: in STD_LOGIC := '0';
	audio_2_in_mute_7 	: in STD_LOGIC := '0';
	audio_2_in_data_8 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_2_in_valid_8 	: in STD_LOGIC := '0';
	audio_2_in_mute_8 	: in STD_LOGIC := '0';
	audio_2_in_data_9 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_2_in_valid_9 	: in STD_LOGIC := '0';
	audio_2_in_mute_9 	: in STD_LOGIC := '0';
	audio_2_in_data_10 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_2_in_valid_10 : in STD_LOGIC := '0';
	audio_2_in_mute_10 	: in STD_LOGIC := '0';
	audio_2_in_data_11 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_2_in_valid_11 : in STD_LOGIC := '0';
	audio_2_in_mute_11 	: in STD_LOGIC := '0';
	audio_2_in_data_12 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_2_in_valid_12 : in STD_LOGIC := '0';
	audio_2_in_mute_12 	: in STD_LOGIC := '0';
	audio_2_in_data_13 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_2_in_valid_13 : in STD_LOGIC := '0';
	audio_2_in_mute_13 	: in STD_LOGIC := '0';
	audio_2_in_data_14 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_2_in_valid_14 : in STD_LOGIC := '0';
	audio_2_in_mute_14 	: in STD_LOGIC := '0';
	
	            -- Global Clock Signal
            S_AXI_ACLK	: in std_logic;
            -- Global Reset Signal. This Signal is Active LOW
            S_AXI_ARESETN	: in std_logic;
            -- Write address (issued by master, acceped by Slave)
            S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
            -- Write channel Protection type. This signal indicates the
                -- privilege and security level of the transaction, and whether
                -- the transaction is a data access or an instruction access.
            S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
            -- Write address valid. This signal indicates that the master signaling
                -- valid write address and control information.
            S_AXI_AWVALID	: in std_logic;
            -- Write address ready. This signal indicates that the slave is ready
                -- to accept an address and associated control signals.
            S_AXI_AWREADY	: out std_logic;
            -- Write data (issued by master, acceped by Slave) 
            S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
            -- Write strobes. This signal indicates which byte lanes hold
                -- valid data. There is one write strobe bit for each eight
                -- bits of the write data bus.    
            S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
            -- Write valid. This signal indicates that valid write
                -- data and strobes are available.
            S_AXI_WVALID	: in std_logic;
            -- Write ready. This signal indicates that the slave
                -- can accept the write data.
            S_AXI_WREADY	: out std_logic;
            -- Write response. This signal indicates the status
                -- of the write transaction.
            S_AXI_BRESP	: out std_logic_vector(1 downto 0);
            -- Write response valid. This signal indicates that the channel
                -- is signaling a valid write response.
            S_AXI_BVALID	: out std_logic;
            -- Response ready. This signal indicates that the master
                -- can accept a write response.
            S_AXI_BREADY	: in std_logic;
            -- Read address (issued by master, acceped by Slave)
            S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
            -- Protection type. This signal indicates the privilege
                -- and security level of the transaction, and whether the
                -- transaction is a data access or an instruction access.
            S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
            -- Read address valid. This signal indicates that the channel
                -- is signaling valid read address and control information.
            S_AXI_ARVALID	: in std_logic;
            -- Read address ready. This signal indicates that the slave is
                -- ready to accept an address and associated control signals.
            S_AXI_ARREADY	: out std_logic;
            -- Read data (issued by slave)
            S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
            -- Read response. This signal indicates the status of the
                -- read transfer.
            S_AXI_RRESP	: out std_logic_vector(1 downto 0);
            -- Read valid. This signal indicates that the channel is
                -- signaling the required read data.
            S_AXI_RVALID	: out std_logic;
            -- Read ready. This signal indicates that the master can
                -- accept the read data and response information.
            S_AXI_RREADY	: in std_logic
);
end audio_router;
architecture Behavioral of audio_router is    

	type reg32_t is array (2**(C_S_AXI_ADDR_WIDTH-2)-1 downto 0) of std_logic_vector(31 downto 0);
    signal slv_regs : reg32_t;
    signal slv_regs_r : reg32_t;
    
	-- AXI4LITE signals
	signal axi_awaddr	: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	signal axi_awready	: std_logic;
	signal axi_wready	: std_logic;
	signal axi_bresp	: std_logic_vector(1 downto 0);
	signal axi_bvalid	: std_logic;
	signal axi_araddr	: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	signal axi_arready	: std_logic;
	signal axi_rdata	: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal axi_rresp	: std_logic_vector(1 downto 0);
	signal axi_rvalid	: std_logic;

	-- Example-specific design signals
	-- local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	-- ADDR_LSB is used for addressing 32/64 bit registers/memories
	-- ADDR_LSB = 2 for 32 bits (n downto 2)
	-- ADDR_LSB = 3 for 64 bits (n downto 3)
	constant ADDR_LSB  : integer := (C_S_AXI_DATA_WIDTH/32)+ 1;
	constant OPT_MEM_ADDR_BITS : integer := C_S_AXI_ADDR_WIDTH-3;
	-------------------------------------------------------------------------
	---- Signals for user logic register space example
	-------------------------------------------------------------------------
	---- Number of Slave Registers 4
	signal slv_reg_rden	: std_logic;
	signal slv_reg_wren	: std_logic;
	signal reg_data_out	: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal byte_index	: integer;
	

		
 	type in_vector_t is array(AUDIO_CHANNELS*INTERFACE_NUMBER-1 downto 0) of std_logic_vector(25 downto 0);
 	type out_vector_t is array(AUDIO_CHANNELS-1 downto 0) of std_logic_vector(25 downto 0);
	type routing_vector_t is array(AUDIO_CHANNELS-1 downto 0) of std_logic_vector(5 downto 0);
	
	type state_t is (idle, write_bram, read_routing); 
	
	signal state : state_t;
	
	signal in_vector: in_vector_t;
	signal in_vector_r: in_vector_t;
	signal out_vector: out_vector_t;
	signal out_vector_r: out_vector_t;
    signal routing_vector : routing_vector_t;
	signal routing_vector_r : routing_vector_t;
	
	signal wclk_r : std_logic_vector(1 downto 0);
	
	signal counter_write : std_logic_vector(5 downto 0);
	signal counter_read : integer range 0 to AUDIO_CHANNELS+1;
	
    signal int_bram_w_wen_r     : STD_LOGIC_VECTOR(0 downto 0);    
    signal int_bram_w_din_r     : STD_LOGIC_VECTOR(25 downto 0);
	signal int_bram_w_addr_r	: STD_LOGIC_VECTOR(5 downto 0);
begin

	wclk_process: process(clk,rst_n)
	begin
		if(rst_n='0')then
			wclk_r <= "00";
		elsif rising_edge(clk)then
			wclk_r <= wclk_r(0) & wclk;
		end if;
	end process;
                                               
						
	main_process: process(clk,rst_n)
	begin
		if(rst_n='0')then
			state <= idle;
			in_vector_r <= (others => (others => '0'));
			out_vector_r <= (others => (others => '0'));
			int_bram_w_wen <= "0";
			int_bram_w_wen_r <= "0";
			int_bram_w_addr <= (others => '0');
			int_bram_w_addr_r <= (others => '0');
			int_bram_w_din <= (others => '0');
			int_bram_w_din_r <= (others => '0');
			routing_vector_r <= (others => (others => '0'));
			int_bram_r_addr <= (others => '0');
			counter_read <= 0;
			--for testing purposes
			-- routing_vector(0) <= "000000"+4;
			-- routing_vector(1) <= "000000"+1;
			-- routing_vector(2) <= "000000"+0;
			-- routing_vector(3) <= "000000"+15;
			-- routing_vector(4) <= "000000"+18;
			-- routing_vector(5) <= "000000"+21;
			-- routing_vector(6) <= "000000"+30;
			-- routing_vector(7) <= "000000"+30;
			-- routing_vector(8) <= "000000"+30;
			-- routing_vector(9) <= "000000"+30;
			-- routing_vector(10) <= "000000"+30;
			-- routing_vector(11) <= "000000"+30;
			-- routing_vector(12) <= "000000"+30;
			-- routing_vector(13) <= "000000"+30;
			-- routing_vector(14) <= "000000"+20;
--			 routing_vector(0) <= "000000"+0;
--			 routing_vector(1) <= "000000"+1;
--			 routing_vector(2) <= "000000"+2;
--			 routing_vector(3) <= "000000"+3;
--			 routing_vector(4) <= "000000"+4;
--			 routing_vector(5) <= "000000"+5;
--			 routing_vector(6) <= "000000"+6;
--			 routing_vector(7) <= "000000"+7;
--			 routing_vector(8) <= "000000"+8;
--			 routing_vector(9) <= "000000"+9;
--			 routing_vector(10) <= "000000"+10;
--			 routing_vector(11) <= "000000"+11;
--			 routing_vector(12) <= "000000"+12;
--			 routing_vector(13) <= "000000"+13;
--			 routing_vector(14) <= "000000"+14;
			-- routing_vector(0) <=  "000000"+15+0;
			-- routing_vector(1) <=  "000000"+15+1;
			-- routing_vector(2) <=  "000000"+15+2;
			-- routing_vector(3) <=  "000000"+15+3;
			-- routing_vector(4) <=  "000000"+15+4;
			-- routing_vector(5) <=  "000000"+15+5;
			-- routing_vector(6) <=  "000000"+15+6;
			-- routing_vector(7) <=  "000000"+15+7;
			-- routing_vector(8) <=  "000000"+15+8;
			-- routing_vector(9) <=  "000000"+15+9;
			-- routing_vector(10) <= "000000"+15+10;
			-- routing_vector(11) <= "000000"+15+11;
			-- routing_vector(12) <= "000000"+15+12;
			-- routing_vector(13) <= "000000"+15+13;
			-- routing_vector(14) <= "000000"+15+14;  			
		elsif rising_edge(clk)then
			--int_bram_w_wen <= int_bram_w_wen_r;
			int_bram_w_din <= int_bram_w_din_r;
			int_bram_w_addr <= int_bram_w_addr_r;
			case (state) is
				when idle => 
					if(wclk_r="01")then
                        in_vector_r <= in_vector;
                        out_vector <= out_vector_r;
                        state <= write_bram;
						counter_write <= (others => '0');
						routing_vector_r <= routing_vector;
					end if;
					
				when write_bram =>
				    int_bram_w_din_r <= in_vector_r(0);
				    
					for I in 1 to AUDIO_CHANNELS*INTERFACE_NUMBER-1 loop
						in_vector_r(I-1) <= in_vector_r(I);
					end loop;
					
					int_bram_w_wen <= "1";
					int_bram_w_addr_r <= counter_write;
					counter_write <= counter_write +1;
					
					if(counter_write=AUDIO_CHANNELS*INTERFACE_NUMBER-1)then
						state <= read_routing;
						counter_read <= 0;
					end if;
				when read_routing => 
					int_bram_w_wen <= "0";
					
					int_bram_r_addr <= routing_vector_r(0);
					out_vector_r(AUDIO_CHANNELS-1) <= int_bram_r_dout;
					
					for I in 1 to AUDIO_CHANNELS-1 loop
						out_vector_r(I-1) <= out_vector_r(I);
						routing_vector_r(I-1) <= routing_vector_r(I);
					end loop;
					
					counter_read <= counter_read+1;
					
					if(counter_read=AUDIO_CHANNELS+1)then
						state <= idle;
					end if;
				
				when others => 
					state <= idle;
			end case;
			
		end if;	
	end process;
-- fase 1 me li copio tutti in un vettore
-- fase 2 li scrivo in una memoria
-- fase 3 1 alla volta leggo la memoria di routing e vado a scrivere il dato nel vettore di uscita
-- fase 4 = fase 1 metto il vettore in uscita in out vero e proprio


	int_bram_w_clk <= clk;
	int_bram_w_rst <= not rst_n;
	int_bram_w_en <= '1';
	
	int_bram_r_clk <= clk;
    int_bram_r_rst <= not rst_n;
    int_bram_r_en <= '1';
--	routing_vector(0) <= rout_ch0;
	
GEN_2: if(AUDIO_CHANNELS<=7)  generate	
	in_vector( 0) <= audio_0_in_mute_0 	& audio_0_in_valid_0  & audio_0_in_data_0 ;
	in_vector( 1) <= audio_0_in_mute_1 	& audio_0_in_valid_1  & audio_0_in_data_1 ;
	in_vector( 2) <= audio_0_in_mute_2 	& audio_0_in_valid_2  & audio_0_in_data_2 ;
	in_vector( 3) <= audio_0_in_mute_3 	& audio_0_in_valid_3  & audio_0_in_data_3 ;
	in_vector( 4) <= audio_0_in_mute_4 	& audio_0_in_valid_4  & audio_0_in_data_4 ;
	in_vector( 5) <= audio_0_in_mute_5 	& audio_0_in_valid_5  & audio_0_in_data_5 ;
	in_vector( 6) <= audio_0_in_mute_6 	& audio_0_in_valid_6  & audio_0_in_data_6 ;
GEN_22: if(INTERFACE_NUMBER>1) generate
	in_vector( 7) <= audio_1_in_mute_0  & audio_1_in_valid_0  & audio_1_in_data_0 ;
	in_vector( 8) <= audio_1_in_mute_1  & audio_1_in_valid_1  & audio_1_in_data_1 ;
	in_vector( 9) <= audio_1_in_mute_2  & audio_1_in_valid_2  & audio_1_in_data_2 ;
	in_vector(10) <= audio_1_in_mute_3  & audio_1_in_valid_3  & audio_1_in_data_3 ;
	in_vector(11) <= audio_1_in_mute_4  & audio_1_in_valid_4  & audio_1_in_data_4 ;
	in_vector(12) <= audio_1_in_mute_5  & audio_1_in_valid_5  & audio_1_in_data_5 ;
	in_vector(13) <= audio_1_in_mute_6  & audio_1_in_valid_6  & audio_1_in_data_6 ;
end generate GEN_22; 
GEN_23: if(INTERFACE_NUMBER>2) generate
	in_vector(14) <= audio_2_in_mute_0  & audio_2_in_valid_0  & audio_2_in_data_0 ;
	in_vector(15) <= audio_2_in_mute_1  & audio_2_in_valid_1  & audio_2_in_data_1 ;
	in_vector(16) <= audio_2_in_mute_2  & audio_2_in_valid_2  & audio_2_in_data_2 ;
	in_vector(17) <= audio_2_in_mute_3  & audio_2_in_valid_3  & audio_2_in_data_3 ;
	in_vector(18) <= audio_2_in_mute_4  & audio_2_in_valid_4  & audio_2_in_data_4 ;
	in_vector(19) <= audio_2_in_mute_5  & audio_2_in_valid_5  & audio_2_in_data_5 ;
	in_vector(20) <= audio_2_in_mute_6  & audio_2_in_valid_6  & audio_2_in_data_6 ;
end generate GEN_23;
end generate GEN_2;  

GEN_1: if((AUDIO_CHANNELS>7)AND(AUDIO_CHANNELS<=11))  generate	
	in_vector( 0) <= audio_0_in_mute_0 	& audio_0_in_valid_0  & audio_0_in_data_0 ;
	in_vector( 1) <= audio_0_in_mute_1 	& audio_0_in_valid_1  & audio_0_in_data_1 ;
	in_vector( 2) <= audio_0_in_mute_2 	& audio_0_in_valid_2  & audio_0_in_data_2 ;
	in_vector( 3) <= audio_0_in_mute_3 	& audio_0_in_valid_3  & audio_0_in_data_3 ;
	in_vector( 4) <= audio_0_in_mute_4 	& audio_0_in_valid_4  & audio_0_in_data_4 ;
	in_vector( 5) <= audio_0_in_mute_5 	& audio_0_in_valid_5  & audio_0_in_data_5 ;
	in_vector( 6) <= audio_0_in_mute_6 	& audio_0_in_valid_6  & audio_0_in_data_6 ;
	in_vector( 7) <= audio_0_in_mute_7 	& audio_0_in_valid_7  & audio_0_in_data_7 ;
	in_vector( 8) <= audio_0_in_mute_8 	& audio_0_in_valid_8  & audio_0_in_data_8 ;
	in_vector( 9) <= audio_0_in_mute_9 	& audio_0_in_valid_9  & audio_0_in_data_9 ;
	in_vector(10) <= audio_0_in_mute_10 & audio_0_in_valid_10 & audio_0_in_data_10;
GEN_12: if(INTERFACE_NUMBER>1) generate
	in_vector(11) <= audio_1_in_mute_0  & audio_1_in_valid_0  & audio_1_in_data_0 ;
	in_vector(12) <= audio_1_in_mute_1  & audio_1_in_valid_1  & audio_1_in_data_1 ;
	in_vector(13) <= audio_1_in_mute_2  & audio_1_in_valid_2  & audio_1_in_data_2 ;
	in_vector(14) <= audio_1_in_mute_3  & audio_1_in_valid_3  & audio_1_in_data_3 ;
	in_vector(15) <= audio_1_in_mute_4  & audio_1_in_valid_4  & audio_1_in_data_4 ;
	in_vector(16) <= audio_1_in_mute_5  & audio_1_in_valid_5  & audio_1_in_data_5 ;
	in_vector(17) <= audio_1_in_mute_6  & audio_1_in_valid_6  & audio_1_in_data_6 ;
	in_vector(18) <= audio_1_in_mute_7  & audio_1_in_valid_7  & audio_1_in_data_7 ;
	in_vector(19) <= audio_1_in_mute_8  & audio_1_in_valid_8  & audio_1_in_data_8 ;
	in_vector(20) <= audio_1_in_mute_9  & audio_1_in_valid_9  & audio_1_in_data_9 ;
	in_vector(21) <= audio_1_in_mute_10 & audio_1_in_valid_10 & audio_1_in_data_10;
end generate GEN_12; 
GEN_13: if(INTERFACE_NUMBER>2) generate
	in_vector(22) <= audio_2_in_mute_0  & audio_2_in_valid_0  & audio_2_in_data_0 ;
	in_vector(23) <= audio_2_in_mute_1  & audio_2_in_valid_1  & audio_2_in_data_1 ;
	in_vector(24) <= audio_2_in_mute_2  & audio_2_in_valid_2  & audio_2_in_data_2 ;
	in_vector(25) <= audio_2_in_mute_3  & audio_2_in_valid_3  & audio_2_in_data_3 ;
	in_vector(26) <= audio_2_in_mute_4  & audio_2_in_valid_4  & audio_2_in_data_4 ;
	in_vector(27) <= audio_2_in_mute_5  & audio_2_in_valid_5  & audio_2_in_data_5 ;
	in_vector(28) <= audio_2_in_mute_6  & audio_2_in_valid_6  & audio_2_in_data_6 ;
	in_vector(29) <= audio_2_in_mute_7  & audio_2_in_valid_7  & audio_2_in_data_7 ;
	in_vector(30) <= audio_2_in_mute_8  & audio_2_in_valid_8  & audio_2_in_data_8 ;
	in_vector(31) <= audio_2_in_mute_9  & audio_2_in_valid_9  & audio_2_in_data_9 ;
	in_vector(32) <= audio_2_in_mute_10 & audio_2_in_valid_10 & audio_2_in_data_10;
end generate GEN_13;
end generate GEN_1;  

GEN_0: if(AUDIO_CHANNELS>11) generate	
	in_vector( 0) <= audio_0_in_mute_0 	& audio_0_in_valid_0  & audio_0_in_data_0 ;
	in_vector( 1) <= audio_0_in_mute_1 	& audio_0_in_valid_1  & audio_0_in_data_1 ;
	in_vector( 2) <= audio_0_in_mute_2 	& audio_0_in_valid_2  & audio_0_in_data_2 ;
	in_vector( 3) <= audio_0_in_mute_3 	& audio_0_in_valid_3  & audio_0_in_data_3 ;
	in_vector( 4) <= audio_0_in_mute_4 	& audio_0_in_valid_4  & audio_0_in_data_4 ;
	in_vector( 5) <= audio_0_in_mute_5 	& audio_0_in_valid_5  & audio_0_in_data_5 ;
	in_vector( 6) <= audio_0_in_mute_6 	& audio_0_in_valid_6  & audio_0_in_data_6 ;
	in_vector( 7) <= audio_0_in_mute_7 	& audio_0_in_valid_7  & audio_0_in_data_7 ;
	in_vector( 8) <= audio_0_in_mute_8 	& audio_0_in_valid_8  & audio_0_in_data_8 ;
	in_vector( 9) <= audio_0_in_mute_9 	& audio_0_in_valid_9  & audio_0_in_data_9 ;
	in_vector(10) <= audio_0_in_mute_10 & audio_0_in_valid_10 & audio_0_in_data_10;
	in_vector(11) <= audio_0_in_mute_11 & audio_0_in_valid_11 & audio_0_in_data_11;
	in_vector(12) <= audio_0_in_mute_12 & audio_0_in_valid_12 & audio_0_in_data_12;
	in_vector(13) <= audio_0_in_mute_13 & audio_0_in_valid_13 & audio_0_in_data_13;
	in_vector(14) <= audio_0_in_mute_14 & audio_0_in_valid_14 & audio_0_in_data_14;
GEN_02: if(INTERFACE_NUMBER>1) generate
	in_vector(15) <= audio_1_in_mute_0  & audio_1_in_valid_0  & audio_1_in_data_0 ;
	in_vector(16) <= audio_1_in_mute_1  & audio_1_in_valid_1  & audio_1_in_data_1 ;
	in_vector(17) <= audio_1_in_mute_2  & audio_1_in_valid_2  & audio_1_in_data_2 ;
	in_vector(18) <= audio_1_in_mute_3  & audio_1_in_valid_3  & audio_1_in_data_3 ;
	in_vector(19) <= audio_1_in_mute_4  & audio_1_in_valid_4  & audio_1_in_data_4 ;
	in_vector(20) <= audio_1_in_mute_5  & audio_1_in_valid_5  & audio_1_in_data_5 ;
	in_vector(21) <= audio_1_in_mute_6  & audio_1_in_valid_6  & audio_1_in_data_6 ;
	in_vector(22) <= audio_1_in_mute_7  & audio_1_in_valid_7  & audio_1_in_data_7 ;
	in_vector(23) <= audio_1_in_mute_8  & audio_1_in_valid_8  & audio_1_in_data_8 ;
	in_vector(24) <= audio_1_in_mute_9  & audio_1_in_valid_9  & audio_1_in_data_9 ;
	in_vector(25) <= audio_1_in_mute_10 & audio_1_in_valid_10 & audio_1_in_data_10;
	in_vector(26) <= audio_1_in_mute_11 & audio_1_in_valid_11 & audio_1_in_data_11;
	in_vector(27) <= audio_1_in_mute_12 & audio_1_in_valid_12 & audio_1_in_data_12;
	in_vector(28) <= audio_1_in_mute_13 & audio_1_in_valid_13 & audio_1_in_data_13;
	in_vector(29) <= audio_1_in_mute_14 & audio_1_in_valid_14 & audio_1_in_data_14;
end generate GEN_02; 
GEN_03: if(INTERFACE_NUMBER>2) generate
	in_vector(30) <= audio_2_in_mute_0  & audio_2_in_valid_0  & audio_2_in_data_0 ;
	in_vector(31) <= audio_2_in_mute_1  & audio_2_in_valid_1  & audio_2_in_data_1 ;
	in_vector(32) <= audio_2_in_mute_2  & audio_2_in_valid_2  & audio_2_in_data_2 ;
	in_vector(33) <= audio_2_in_mute_3  & audio_2_in_valid_3  & audio_2_in_data_3 ;
	in_vector(34) <= audio_2_in_mute_4  & audio_2_in_valid_4  & audio_2_in_data_4 ;
	in_vector(35) <= audio_2_in_mute_5  & audio_2_in_valid_5  & audio_2_in_data_5 ;
	in_vector(36) <= audio_2_in_mute_6  & audio_2_in_valid_6  & audio_2_in_data_6 ;
	in_vector(37) <= audio_2_in_mute_7  & audio_2_in_valid_7  & audio_2_in_data_7 ;
	in_vector(38) <= audio_2_in_mute_8  & audio_2_in_valid_8  & audio_2_in_data_8 ;
	in_vector(39) <= audio_2_in_mute_9  & audio_2_in_valid_9  & audio_2_in_data_9 ;
	in_vector(40) <= audio_2_in_mute_10 & audio_2_in_valid_10 & audio_2_in_data_10;
	in_vector(41) <= audio_2_in_mute_11 & audio_2_in_valid_11 & audio_2_in_data_11;
	in_vector(42) <= audio_2_in_mute_12 & audio_2_in_valid_12 & audio_2_in_data_12;
	in_vector(43) <= audio_2_in_mute_13 & audio_2_in_valid_13 & audio_2_in_data_13;
	in_vector(44) <= audio_2_in_mute_14 & audio_2_in_valid_14 & audio_2_in_data_14;
end generate GEN_03;
end generate GEN_0; 


	
    audio_out_data_0  <= out_vector(0 )(23 downto 0);               
    audio_out_data_1  <= out_vector(1 )(23 downto 0);               
    audio_out_data_2  <= out_vector(2 )(23 downto 0);               
    audio_out_data_3  <= out_vector(3 )(23 downto 0);               
    audio_out_data_4  <= out_vector(4 )(23 downto 0);               
    audio_out_data_5  <= out_vector(5 )(23 downto 0);               
    audio_out_data_6  <= out_vector(6 )(23 downto 0);  
    
    audio_out_valid_0  <= out_vector(0 )(24);               
    audio_out_valid_1  <= out_vector(1 )(24);               
    audio_out_valid_2  <= out_vector(2 )(24);               
    audio_out_valid_3  <= out_vector(3 )(24);               
    audio_out_valid_4  <= out_vector(4 )(24);               
    audio_out_valid_5  <= out_vector(5 )(24);               
    audio_out_valid_6  <= out_vector(6 )(24);               
              


    audio_out_mute_0  <= out_vector(0 )(25);               
    audio_out_mute_1  <= out_vector(1 )(25);               
    audio_out_mute_2  <= out_vector(2 )(25);               
    audio_out_mute_3  <= out_vector(3 )(25);               
    audio_out_mute_4  <= out_vector(4 )(25);               
    audio_out_mute_5  <= out_vector(5 )(25);               
    audio_out_mute_6  <= out_vector(6 )(25);  
    
 GEN_4: if(AUDIO_CHANNELS>7) generate             
    audio_out_data_7  <= out_vector(7 )(23 downto 0);               
    audio_out_data_8  <= out_vector(8 )(23 downto 0);               
    audio_out_data_9  <= out_vector(9 )(23 downto 0);               
    audio_out_data_10 <= out_vector(10)(23 downto 0);
    
    audio_out_valid_7  <= out_vector(7 )(24);               
    audio_out_valid_8  <= out_vector(8 )(24);               
    audio_out_valid_9  <= out_vector(9 )(24);               
    audio_out_valid_10 <= out_vector(10)(24); 
    
    audio_out_mute_7  <= out_vector(7 )(25);               
    audio_out_mute_8  <= out_vector(8 )(25);               
    audio_out_mute_9  <= out_vector(9 )(25);               
    audio_out_mute_10 <= out_vector(10)(25);   
 end generate GEN_4;
     
 GEN_5: if(AUDIO_CHANNELS>11) generate                
    audio_out_data_11 <= out_vector(11)(23 downto 0);               
    audio_out_data_12 <= out_vector(12)(23 downto 0);               
    audio_out_data_13 <= out_vector(13)(23 downto 0);               
    audio_out_data_14 <= out_vector(14)(23 downto 0);
    
    audio_out_valid_11 <= out_vector(11)(24);               
    audio_out_valid_12 <= out_vector(12)(24);               
    audio_out_valid_13 <= out_vector(13)(24);               
    audio_out_valid_14 <= out_vector(14)(24);
    
    audio_out_mute_11 <= out_vector(11)(25);               
    audio_out_mute_12 <= out_vector(12)(25);               
    audio_out_mute_13 <= out_vector(13)(25);               
    audio_out_mute_14 <= out_vector(14)(25);
 end generate GEN_5;
 
 
 	
	-- I/O Connections assignments

	S_AXI_AWREADY	<= axi_awready;
	S_AXI_WREADY	<= axi_wready;
	S_AXI_BRESP	    <= axi_bresp;
	S_AXI_BVALID	<= axi_bvalid;
	S_AXI_ARREADY	<= axi_arready;
	S_AXI_RDATA	    <= axi_rdata;
	S_AXI_RRESP	    <= axi_rresp;
	S_AXI_RVALID	<= axi_rvalid;
	-- Implement axi_awready generation
	-- axi_awready is asserted for one S_AXI_ACLK clock cycle when both
	-- S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
	-- de-asserted when reset is low.

	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_awready <= '0';
	    else
	      if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1') then
	        -- slave is ready to accept write address when
	        -- there is a valid write address and write data
	        -- on the write address and data bus. This design 
	        -- expects no outstanding transactions. 
	        axi_awready <= '1';
	      else
	        axi_awready <= '0';
	      end if;
	    end if;
	  end if;
	end process;

	-- Implement axi_awaddr latching
	-- This process is used to latch the address when both 
	-- S_AXI_AWVALID and S_AXI_WVALID are valid. 

	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_awaddr <= (others => '0');
	    else
	      if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1') then
	        -- Write Address latching
	        axi_awaddr <= S_AXI_AWADDR;
	      end if;
	    end if;
	  end if;                   
	end process; 

	-- Implement axi_wready generation
	-- axi_wready is asserted for one S_AXI_ACLK clock cycle when both
	-- S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
	-- de-asserted when reset is low. 

	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_wready <= '0';
	    else
	      if (axi_wready = '0' and S_AXI_WVALID = '1' and S_AXI_AWVALID = '1') then
	          -- slave is ready to accept write data when 
	          -- there is a valid write address and write data
	          -- on the write address and data bus. This design 
	          -- expects no outstanding transactions.           
	          axi_wready <= '1';
	      else
	        axi_wready <= '0';
	      end if;
	    end if;
	  end if;
	end process; 

	-- Implement memory mapped register select and write logic generation
	-- The write data is accepted and written to memory mapped registers when
	-- axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
	-- select byte enables of slave registers while writing.
	-- These registers are cleared when reset (active low) is applied.
	-- Slave register write enable is asserted when valid address and data are available
	-- and the slave is ready to accept the write address and write data.
	slv_reg_wren <= axi_wready and S_AXI_WVALID and axi_awready and S_AXI_AWVALID ;


	process (S_AXI_ACLK)
	variable loc_addr :std_logic_vector(OPT_MEM_ADDR_BITS downto 0); 
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	        slv_regs <= (others => (others => '0'));
	        slv_regs_r <= (others => (others => '0'));
	        -- Users to add ports here
			routing_vector	<= (others => (others => '0'));

	    else
	
	        loc_addr := axi_awaddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
            if (slv_reg_wren = '1') then
              for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
                  if ( S_AXI_WSTRB(byte_index) = '1' ) then
                  -- Respective byte enables are asserted as per write strobes                   
                  -- slave registor 0
                      slv_regs(conv_integer(loc_addr))(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
                  end if;
              end loop; 
            else

                slv_regs_r(0) <= slv_regs(0);
                slv_regs_r(1) <= slv_regs(1);
                slv_regs_r(2) <= slv_regs(2);
				slv_regs_r(3) <= slv_regs(3);
		
            end if;

			routing_vector(0) <= slv_regs_r(0)(5 downto 0);
			routing_vector(1) <= slv_regs_r(0)(13 downto 8);
			routing_vector(2) <= slv_regs_r(0)(21 downto 16);
			routing_vector(3) <= slv_regs_r(0)(29 downto 24);
			routing_vector(4) <= slv_regs_r(1)(5 downto 0);
			routing_vector(5) <= slv_regs_r(1)(13 downto 8);
			routing_vector(6) <= slv_regs_r(1)(21 downto 16);
			routing_vector(7) <= slv_regs_r(1)(29 downto 24);
			routing_vector(8) <= slv_regs_r(2)(5 downto 0);
			routing_vector(9) <= slv_regs_r(2)(13 downto 8);
			routing_vector(10) <= slv_regs_r(2)(21 downto 16);
			routing_vector(11) <= slv_regs_r(2)(29 downto 24);
			routing_vector(12) <= slv_regs_r(3)(5 downto 0);
			routing_vector(13) <= slv_regs_r(3)(13 downto 8);
			routing_vector(14) <= slv_regs_r(3)(21 downto 16);

	    end if;
	  end if;                   
	end process; 

    
	-- Implement write response logic generation
	-- The write response and response valid signals are asserted by the slave 
	-- when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
	-- This marks the acceptance of address and indicates the status of 
	-- write transaction.

	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_bvalid  <= '0';
	      axi_bresp   <= "00"; --need to work more on the responses
	    else
	      if (axi_awready = '1' and S_AXI_AWVALID = '1' and axi_wready = '1' and S_AXI_WVALID = '1' and axi_bvalid = '0'  ) then
	        axi_bvalid <= '1';
	        axi_bresp  <= "00"; 
	      elsif (S_AXI_BREADY = '1' and axi_bvalid = '1') then   --check if bready is asserted while bvalid is high)
	        axi_bvalid <= '0';                                 -- (there is a possibility that bready is always asserted high)
	      end if;
	    end if;
	  end if;                   
	end process; 

	-- Implement axi_arready generation
	-- axi_arready is asserted for one S_AXI_ACLK clock cycle when
	-- S_AXI_ARVALID is asserted. axi_awready is 
	-- de-asserted when reset (active low) is asserted. 
	-- The read address is also latched when S_AXI_ARVALID is 
	-- asserted. axi_araddr is reset to zero on reset assertion.

	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_arready <= '0';
	      axi_araddr  <= (others => '1');
	    else
	      if (axi_arready = '0' and S_AXI_ARVALID = '1') then
	        -- indicates that the slave has acceped the valid read address
	        axi_arready <= '1';
	        -- Read Address latching 
	        axi_araddr  <= S_AXI_ARADDR;           
	      else
	        axi_arready <= '0';
	      end if;
	    end if;
	  end if;                   
	end process; 

	-- Implement axi_arvalid generation
	-- axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
	-- S_AXI_ARVALID and axi_arready are asserted. The slave registers 
	-- data are available on the axi_rdata bus at this instance. The 
	-- assertion of axi_rvalid marks the validity of read data on the 
	-- bus and axi_rresp indicates the status of read transaction.axi_rvalid 
	-- is deasserted on reset (active low). axi_rresp and axi_rdata are 
	-- cleared to zero on reset (active low).  
	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then
	    if S_AXI_ARESETN = '0' then
	      axi_rvalid <= '0';
	      axi_rresp  <= "00";
	    else
	      if (axi_arready = '1' and S_AXI_ARVALID = '1' and axi_rvalid = '0') then
	        -- Valid read data is available at the read data bus
	        axi_rvalid <= '1';
	        axi_rresp  <= "00"; -- 'OKAY' response
	      elsif (axi_rvalid = '1' and S_AXI_RREADY = '1') then
	        -- Read data is accepted by the master
	        axi_rvalid <= '0';
	      end if;            
	    end if;
	  end if;
	end process;

	-- Implement memory mapped register select and read logic generation
	-- Slave register read enable is asserted when valid address is available
	-- and the slave is ready to accept the read address.
	slv_reg_rden <= axi_arready and S_AXI_ARVALID and (not axi_rvalid) ;

	process (axi_araddr, S_AXI_ARESETN, slv_reg_rden)
	variable loc_addr :std_logic_vector(OPT_MEM_ADDR_BITS downto 0);
	begin
	  if S_AXI_ARESETN = '0' then
	    reg_data_out  <= (others => '1');
	  else
	    -- Address decoding for reading registers
	    loc_addr := axi_araddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
        reg_data_out <= slv_regs(conv_integer(loc_addr));
	  end if;
	end process; 

	-- Output register or memory read data
	process( S_AXI_ACLK ) is
	begin
	  if (rising_edge (S_AXI_ACLK)) then
	    if ( S_AXI_ARESETN = '0' ) then
	      axi_rdata  <= (others => '0');
	    else
	      if (slv_reg_rden = '1') then
	        -- When there is a valid read address (S_AXI_ARVALID) with 
	        -- acceptance of read address by the slave (axi_arready), 
	        -- output the read dada 
	        -- Read address mux
	          axi_rdata <= reg_data_out;     -- register read data
	      end if;   
	    end if;
	  end if;
	end process;
    
end Behavioral;
