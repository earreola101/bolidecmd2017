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



entity audio_to_ps is
Generic(
    CH_NUM               : integer      := 6;
    S_AXI_DATA_WIDTH     : integer      := 32;
    S_AXI_ADDR_WIDTH     : integer      := 3
	);
Port ( 
    clk 	 	: in  STD_LOGIC;
    rst_n 	 	: in  STD_LOGIC;
    lrclk 	 	: in  STD_LOGIC;
	intr	 	: out STD_LOGIC;
	clear_intr  : out STD_LOGIC;
	position 	: out STD_LOGIC;
	enable      : out STD_LOGIC;
	
	in0  	 	: in  STD_LOGIC_VECTOR (23 downto 0) := x"000000";
	in1  	 	: in  STD_LOGIC_VECTOR (23 downto 0) := x"000000";
	in2  	 	: in  STD_LOGIC_VECTOR (23 downto 0) := x"000000";
	in3  	 	: in  STD_LOGIC_VECTOR (23 downto 0) := x"000000";
	in4  	 	: in  STD_LOGIC_VECTOR (23 downto 0) := x"000000";
	in5  	 	: in  STD_LOGIC_VECTOR (23 downto 0) := x"000000";
    in6         : in  STD_LOGIC_VECTOR (23 downto 0) := x"000000";
    in7         : in  STD_LOGIC_VECTOR (23 downto 0) := x"000000";
	in8  	 	: in  STD_LOGIC_VECTOR (23 downto 0) := x"000000";
    in9           : in  STD_LOGIC_VECTOR (23 downto 0) := x"000000";
    in10           : in  STD_LOGIC_VECTOR (23 downto 0) := x"000000";
    in11           : in  STD_LOGIC_VECTOR (23 downto 0) := x"000000";
    in12           : in  STD_LOGIC_VECTOR (23 downto 0) := x"000000";
    in13           : in  STD_LOGIC_VECTOR (23 downto 0) := x"000000";
    in14         : in  STD_LOGIC_VECTOR (23 downto 0) := x"000000";
    in15         : in  STD_LOGIC_VECTOR (23 downto 0) := x"000000";
    
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
end audio_to_ps;

architecture Behavioral of audio_to_ps is    
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


	type audio_array_t is array(CH_NUM-1 downto 0) of std_logic_vector(23 downto 0);
    signal lrclk_r : std_logic_vector(1 downto 0) := "00";
    signal in_r : audio_array_t;
    signal in_array : audio_array_t;
	signal start_cp : std_logic;
	
	type state_t is (idle, write_bram, change); 
	signal state : state_t;
	signal counter : integer range 0 to CH_NUM;
	signal write_pointer : std_logic_vector(31 downto 0) := x"00000000";

	signal bram_addr_r : std_logic_vector(31 downto 0);

	signal size_r : std_logic_vector(15 downto 0);
	signal size : std_logic_vector(15 downto 0);
	signal intr_r : std_logic;
	signal clear_intr_r : std_logic;
	signal position_r : std_logic;
	signal enable_r : std_logic;
	signal bram_we_r : std_logic_vector(3 downto 0);
begin
    bram_rst <= not rst_n;
    bram_en <= '1';
    bram_clk <= clk;
    enable <= enable_r;
    
    in_array(0) <= in0;
    
    CP_IN_1: if CH_NUM>1 generate
        in_array(1) <= in1; 
    end generate CP_IN_1;
    
    CP_IN_2: if CH_NUM>2 generate
        in_array(2) <= in2; 
    end generate CP_IN_2;
    
    CP_IN_3: if CH_NUM>3 generate
        in_array(3) <= in3; 
    end generate CP_IN_3;
    
    CP_IN_4: if CH_NUM>4 generate
        in_array(4) <= in4; 
    end generate CP_IN_4;
    
    CP_IN_5: if CH_NUM>5 generate
        in_array(5) <= in5; 
    end generate CP_IN_5;
    
    CP_IN_6: if CH_NUM>6 generate
        in_array(6) <= in6; 
    end generate CP_IN_6;

    CP_IN_7: if CH_NUM>7 generate
        in_array(7) <= in7; 
    end generate CP_IN_7;
    
     CP_IN_8: if CH_NUM>8 generate
        in_array(8) <= in8; 
        in_array(9) <= in9; 
        in_array(10) <= in10; 
        in_array(11) <= in11; 
        in_array(12) <= in12; 
        in_array(13) <= in13; 
        in_array(14) <= in14; 
        in_array(15) <= in15;                               
    end generate CP_IN_8;
                   
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
					start_cp <= '1';
				else
					start_cp <= '0';
				end if;
            end if;
        end if; 
    end process;

	bram_addr <= bram_addr_r;

	state_machine : process(clk, rst_n)
	begin
		if(rst_n='0')then
			state <= idle;
			write_pointer 	<= (others =>'0');
			bram_we_r <= x"0";
			bram_addr_r <= (others => '0');
		elsif rising_edge(clk)then
		    
			case (state) is
				when idle => 
					bram_we_r <= x"0";
					if(start_cp='1')then
						state <= write_bram;
						counter <= CH_NUM-1;
						bram_addr_r <= write_pointer;
						
						for I in 0 to CH_NUM-1 loop
						      in_r(I) <= in_array(I);
						end loop;
						
					end if;
				when write_bram =>
					if(write_pointer=size_r-4) then
					   write_pointer <=(others =>'0');
					else
					   write_pointer <= write_pointer + 4;
					end if;
					
					bram_dout(23 downto 0) <= in_r(0);
					bram_dout(31 downto 24) <= (31 downto 24 => in_r(0)(23));
					bram_we_r <= x"F";
					
					for I in 0 to CH_NUM-2 loop
                          in_r(I) <= in_r(I+1);
                    end loop;

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
				    state <= idle;
				    bram_we_r <= x"0";
				when others => 
					state <= idle;
			end case;
		end if;
	end process;
	bram_we <= bram_we_r;
	intr <= intr_r;
	clear_intr <= clear_intr_r;
	position <= position_r;

	
	read_process : process(clk,rst_n)
    begin
       if rst_n='0'then
           intr_r <= '0';

       elsif rising_edge(clk) then

           if(clear_intr_r='1')then
               intr_r <= '0';
           else
               if (bram_we_r="1111") then
                   if(write_pointer=0)then
                        intr_r <= '1';
                        position_r <= '0';
                   elsif(write_pointer=size_r(15 downto 1))then
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
