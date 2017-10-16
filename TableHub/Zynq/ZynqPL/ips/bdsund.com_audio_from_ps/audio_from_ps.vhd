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



entity audio_from_ps is
Generic(
    CH_NUM           : integer    := 8;
    S_AXI_DATA_WIDTH    : integer    := 32;
    S_AXI_ADDR_WIDTH    : integer    := 3
	);
Port ( 
    clk 	 	: in  STD_LOGIC;
    rst_n 	 	: in  STD_LOGIC;
    lrclk 	 	: in  STD_LOGIC;
	intr	 	: out STD_LOGIC;
	clear_intr  : out STD_LOGIC;
	position 	: out STD_LOGIC;
	enable      : out STD_LOGIC;
	out0  	 	: out STD_LOGIC_VECTOR (23 downto 0) := x"000000";
	valid0      : out STD_LOGIC := '0';
	mute0       : out STD_LOGIC := '1';
	out1  	 	: out STD_LOGIC_VECTOR (23 downto 0) := x"000000";
	valid1      : out STD_LOGIC := '0';
    mute1       : out STD_LOGIC := '1';
	out2  	 	: out STD_LOGIC_VECTOR (23 downto 0) := x"000000";
	valid2      : out STD_LOGIC := '0';
    mute2       : out STD_LOGIC := '1';
	out3  	 	: out STD_LOGIC_VECTOR (23 downto 0) := x"000000";
	valid3      : out STD_LOGIC := '0';
    mute3       : out STD_LOGIC := '1';
	out4  	 	: out STD_LOGIC_VECTOR (23 downto 0) := x"000000";
	valid4      : out STD_LOGIC := '0';
    mute4       : out STD_LOGIC := '1';
    out5        : out STD_LOGIC_VECTOR (23 downto 0) := x"000000";
    valid5      : out STD_LOGIC := '0';
    mute5       : out STD_LOGIC := '1';
    out6        : out STD_LOGIC_VECTOR (23 downto 0) := x"000000";
    valid6      : out STD_LOGIC := '0';
    mute6       : out STD_LOGIC := '1';
    out7        : out STD_LOGIC_VECTOR (23 downto 0) := x"000000";
    valid7      : out STD_LOGIC := '0';
    mute7       : out STD_LOGIC := '1';
    	
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
    S_AXI_RREADY    : in std_logic;	
	-- bram
	bram_addr 	: out STD_LOGIC_VECTOR (31 downto 0);
	bram_clk	: out STD_LOGIC;
	bram_dout	: out STD_LOGIC_VECTOR (31 downto 0);
	bram_din	: in  STD_LOGIC_VECTOR (31 downto 0);
	bram_en		: out STD_LOGIC;
	bram_rst	: out STD_LOGIC;
	bram_we		: out STD_LOGIC_VECTOR (3 downto 0)
    );
end audio_from_ps;

architecture Behavioral of audio_from_ps is    
	component intr_manager is
    generic (
        CH_NUM : integer := 8;
        C_S_AXI_DATA_WIDTH    : integer    := 32;
        C_S_AXI_ADDR_WIDTH    : integer    := 3
    );
    port (
        INTR_STATUS: in std_logic;
        DATA_POS: in std_logic;
        CLEAR_INTR : out std_logic;
        ENABLE : out std_logic;
        SIZE : out std_logic_vector(15 downto 0);
        VALID : out std_logic_vector(CH_NUM-1 downto 0);
        MUTE : out std_logic;

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


	type audio_array_t is array(CH_NUM-1 downto 0) of std_logic_vector(23 downto 0);
    signal lrclk_r : std_logic_vector(1 downto 0) := "00";

	signal out_r : audio_array_t;
	signal out_array : audio_array_t;
	signal start_cp : std_logic;
	
	type state_t is (idle, read_bram); 
	signal state : state_t;
	signal counter : integer range 0 to CH_NUM;

	signal read_pointer : std_logic_vector(31 downto 0) := x"00000000";
	signal bram_addr_r : std_logic_vector(31 downto 0);
	signal sample_read : std_logic;
	signal size_r : std_logic_vector(15 downto 0);
	signal size : std_logic_vector(15 downto 0);
	signal intr_r : std_logic;
	signal clear_intr_r : std_logic;
	signal position_r : std_logic;
	signal enable_r : std_logic;
	signal mute_r : std_logic;
	signal valid_r : std_logic_vector(CH_NUM-1 downto 0);
	signal valid_array : std_logic_vector(CH_NUM-1 downto 0);
	signal mute_array : std_logic_vector(CH_NUM-1 downto 0);
begin
    bram_rst <= not rst_n;
    bram_en <= '1';
    bram_clk <= clk;
    enable <= enable_r;
    
    out0 <= out_array(0);
    out1 <= out_array(1);
    out2 <= out_array(2);
    out3 <= out_array(3);
    
    valid0 <= valid_array(0);
    valid1 <= valid_array(1);
    valid2 <= valid_array(2);
    valid3 <= valid_array(3);
    
    mute0 <= mute_array(0);
    mute1 <= mute_array(1);
    mute2 <= mute_array(2);
    mute3 <= mute_array(3);


    OUT_8_GEN :  if CH_NUM>4 generate
        out4 <= out_array(4);
        out5 <= out_array(5);
        out6 <= out_array(6);
        out7 <= out_array(7);
        
        valid4 <= valid_array(4);
        valid5 <= valid_array(5);
        valid6 <= valid_array(6);
        valid7 <= valid_array(7);
        
        mute4 <= mute_array(4);
        mute5 <= mute_array(5);
        mute6 <= mute_array(6);
        mute7 <= mute_array(7);
    end generate OUT_8_GEN;
    
    sample_in : process(clk, rst_n)
    begin
        if(rst_n='0')then
            lrclk_r <= "00";
			start_cp <= '0';
			size_r <= (others => '0');
			
            mute_array <= (others => '1');
            valid_array <= (others => '0');
            out_array <= (others => (others => '0'));
        elsif rising_edge(clk) then
            if(enable_r='0')then
                lrclk_r <= "00";
				start_cp <= '0';
				size_r <= size;
				mute_array <= (others => '1');
		        valid_array <= (others => '0');
            else
                lrclk_r <= lrclk_r(0) & lrclk;
                if(lrclk_r="01")then
                    for I in 0 to CH_NUM-1 loop
                        valid_array(I) <= valid_r(I);
                        mute_array(I) <= mute_r;
                        out_array(I) <= out_r(I);
                    end loop;
					start_cp <= '1';
				else
					start_cp <= '0';
				end if;
            end if;
        end if; 
    end process;

	bram_addr <= bram_addr_r;
	bram_dout <= x"00000000";
	state_machine : process(clk, rst_n)
	begin
		if(rst_n='0')then
			state <= idle;

			read_pointer 	<= (others => '0');
			bram_we <= x"0";
			bram_addr_r <= (others => '0');
			sample_read <= '0';
			counter <= CH_NUM-1;
		elsif rising_edge(clk)then
		    
			case (state) is
				when idle => 
				    sample_read <= '0';
					bram_we <= x"0";
					if(start_cp='1')then
                        counter <= CH_NUM-1;
                        state <= read_bram;
                        bram_addr_r <= read_pointer;
                        bram_we <= x"0";
					end if;

				when read_bram =>
				    if(read_pointer=size_r-4) then
				        read_pointer <= (others => '0');
                        bram_addr_r <= (others => '0');
				    else
                        read_pointer <= read_pointer + 4;
                        bram_addr_r <= read_pointer + 4;
                    end if;
                    sample_read <= '1';
					if(counter=0)then
						state <= idle;
					else
						
						counter <= counter -1;
					end if;
					bram_we <= x"0";
					
				when others => 
					state <= idle;
			end case;
		end if;
	end process;
	intr <= intr_r;
	clear_intr <= clear_intr_r;
	position <= position_r;
	read_process : process(clk,rst_n)
	begin
	   if rst_n='0'then
	       intr_r <= '0';
	       out_r <= (others => (others => '0'));
	   elsif rising_edge(clk) then
	       if sample_read='1' then
	           for I in 0 to CH_NUM-2 loop
                   out_r(I) <= out_r(I+1);
               end loop;
               out_r(CH_NUM-1) <= bram_din(23 downto 0);
	       end if;
	       if(clear_intr_r='1')then
	           intr_r <= '0';
	       else
	           if sample_read='1' then
                   if(read_pointer=0)then
                        intr_r <= '1';
                        position_r <= '0';
                   elsif(read_pointer=size_r(15 downto 1))then
                        intr_r <= '1';
                        position_r <= '1';
                   end if;
               end if;
           end if;
	   end if;
	end process;
	
	
	

    intr_manager_0: intr_manager
    generic map (
        CH_NUM                => CH_NUM,
        C_S_AXI_DATA_WIDTH    => S_AXI_DATA_WIDTH,
        C_S_AXI_ADDR_WIDTH    => S_AXI_ADDR_WIDTH
    )
    port map (
        INTR_STATUS => intr_r,
        DATA_POS => position_r,
        CLEAR_INTR  => clear_intr_r,
        SIZE        => size,
        ENABLE      => enable_r,
        MUTE        => mute_r,
        VALID       => valid_r,
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
