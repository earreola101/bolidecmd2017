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



entity audio_ps is
Generic(
	WRITE_OFFSET : STD_LOGIC_VECTOR (31 downto 0) := x"00000000";
	-- 512 (10ms @48kHz) * 4 (byte * sample) *4 (ch) *2 (interleaved buffer) 
	-- READ_OFFSET : STD_LOGIC_VECTOR (31 downto 0)  := x"00004000"
	READ_OFFSET : STD_LOGIC_VECTOR (31 downto 0)  := x"00004000";
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
	in0  	 	: in  STD_LOGIC_VECTOR (23 downto 0);
	in1  	 	: in  STD_LOGIC_VECTOR (23 downto 0);
	in2  	 	: in  STD_LOGIC_VECTOR (23 downto 0);
	in3  	 	: in  STD_LOGIC_VECTOR (23 downto 0);
	out0  	 	: out STD_LOGIC_VECTOR (23 downto 0);
	out1  	 	: out STD_LOGIC_VECTOR (23 downto 0);
	out2  	 	: out STD_LOGIC_VECTOR (23 downto 0);
	out3  	 	: out STD_LOGIC_VECTOR (23 downto 0);
	
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
end audio_ps;

architecture Behavioral of audio_ps is    
	component intr_manager is
    generic (
        C_S_AXI_DATA_WIDTH    : integer    := 32;
        C_S_AXI_ADDR_WIDTH    : integer    := 3
    );
    port (
        INTR_STATUS: in std_logic;
        DATA_POS: in std_logic;
        CLEAR_INTR : out std_logic;
        ENABLE : out std_logic;
        SIZE : out std_logic_vector(15 downto 0);
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


	type audio_array_t is array(3 downto 0) of std_logic_vector(23 downto 0);
    signal lrclk_r : std_logic_vector(1 downto 0) := "00";
    signal in_r : audio_array_t;
	signal out_r : audio_array_t;
	signal start_cp : std_logic;
	
	type state_t is (idle, write_bram, change, read_bram); 
	signal state : state_t;
	signal counter : integer range 0 to 4;
	signal write_pointer : std_logic_vector(31 downto 0) := x"00000000";
	signal read_pointer : std_logic_vector(31 downto 0) := x"00000000";
	signal bram_addr_r : std_logic_vector(31 downto 0);
	signal sample_read : std_logic;
	signal size_r : std_logic_vector(15 downto 0);
	signal size : std_logic_vector(15 downto 0);
	signal intr_r : std_logic;
	signal clear_intr_r : std_logic;
	signal position_r : std_logic;
	signal enable_r : std_logic;
begin
    bram_rst <= not rst_n;
    bram_en <= '1';
    bram_clk <= clk;
    enable <= enable_r;
    sample_in : process(clk, rst_n)
    begin
        if(rst_n='0')then
            lrclk_r <= "00";
			start_cp <= '0';
			size_r <= (others => '0');
        elsif rising_edge(clk) then
            if(enable_r='0')then
                lrclk_r <= "00";
				start_cp <= '0';
				size_r <= size;
            else
                lrclk_r <= lrclk_r(0) & lrclk;
                if(lrclk_r="01")then

					out0 <= out_r(0);
					out1 <= out_r(1);
					out2 <= out_r(2);
					out3 <= out_r(3);
					start_cp <= '1';
				else
					start_cp <= '0';
				end if;
            end if;
        end if; 
    end process;

	bram_addr <= bram_addr_r;
	bram_dout(31 downto 24) <= x"00";
	state_machine : process(clk, rst_n)
	begin
		if(rst_n='0')then
			state <= idle;
			write_pointer 	<= WRITE_OFFSET;
			read_pointer 	<= READ_OFFSET;
			bram_we <= x"0";
			bram_addr_r <= (others => '0');
			sample_read <= '0';
		elsif rising_edge(clk)then
		    
			case (state) is
				when idle => 
				    sample_read <= '0';
					bram_we <= x"0";
					if(start_cp='1')then
						state <= write_bram;
						counter <= 3;
						bram_addr_r <= write_pointer;
						in_r(0) <= in0;
						in_r(1) <= in1;
						in_r(2) <= in2;
						in_r(3) <= in3;
					end if;
				when write_bram =>
					if(write_pointer=WRITE_OFFSET+size_r-4) then
					   write_pointer <=WRITE_OFFSET;
					else
					   write_pointer <= write_pointer + 4;
					end if;
					
					bram_dout(23 downto 0) <= in_r(0);
					bram_dout(31 downto 24) <= (31 downto 24 => in_r(0)(23));
					bram_we <= x"F";
					in_r(0) <= in_r(1);
					in_r(1) <= in_r(2);
					in_r(2) <= in_r(3);
					bram_addr_r <= write_pointer;
					if(counter=0)then
						-- bram_addr_r <= read_pointer;
						state <= change;
						
					else
						--bram_addr_r <= write_pointer + 4;
						counter <= counter -1;
					end if;
				when change => 
				    counter <= 3;
				    state <= read_bram;
				    bram_addr_r <= read_pointer;
				    bram_we <= x"0";
				when read_bram =>
				    if(read_pointer=READ_OFFSET+size_r-4) then
				        read_pointer <= READ_OFFSET;
                        bram_addr_r <= READ_OFFSET;
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
               out_r(0) <= out_r(1);
               out_r(1) <= out_r(2);
               out_r(2) <= out_r(3);
               out_r(3) <= bram_din(23 downto 0);
	       end if;
	       if(clear_intr_r='1')then
	           intr_r <= '0';
	       else
	           if sample_read='1' then
                   if(read_pointer=READ_OFFSET)then
                        intr_r <= '1';
                        position_r <= '0';
                   elsif(read_pointer=READ_OFFSET+size_r(15 downto 1))then
                        intr_r <= '1';
                        position_r <= '1';
                   end if;
               end if;
           end if;
	   end if;
	end process;
	
	
	

    intr_manager_0: intr_manager
    generic map (
        C_S_AXI_DATA_WIDTH    => S_AXI_DATA_WIDTH,
        C_S_AXI_ADDR_WIDTH    => S_AXI_ADDR_WIDTH
    )
    port map (
        INTR_STATUS => intr_r,
        DATA_POS => position_r,
        CLEAR_INTR  => clear_intr_r,
        SIZE        => size,
        ENABLE      => enable_r,
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
