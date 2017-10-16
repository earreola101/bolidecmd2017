----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.04.2017 10:42:46
-- Design Name: 
-- Module Name: tb - Behavioral
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
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb is
--  Port ( );
end tb;

architecture Behavioral of tb is

	component packet_sender is
	Generic(
		constant MAX_PACKET_SIZE 			: integer := 1024;
		constant PACKET_MEMORY_BIT_ADDR		: integer := 10;
		constant PORT_NUMBER                : integer := 1;
		constant PORT_1_TRUE_BRAM			: boolean := false;
		constant PORT_2_TRUE_BRAM			: boolean := false;
		constant PORT_3_TRUE_BRAM			: boolean := false;
		constant PORT_4_TRUE_BRAM			: boolean := false
		
	);
	Port ( 
		clk 			: in STD_LOGIC;
		rst_n 			: in STD_LOGIC;

		wclk			: in STD_LOGIC := '0';
		
		data_byte_0 	: out STD_LOGIC_VECTOR(7 downto 0) := x"00";
		data_valid_0 	: out STD_LOGIC := '0';
		data_byte_1 	: out STD_LOGIC_VECTOR(7 downto 0) := x"00";
		data_valid_1 	: out STD_LOGIC := '0';
		data_byte_2 	: out STD_LOGIC_VECTOR(7 downto 0) := x"00";
		data_valid_2 	: out STD_LOGIC := '0';

		
		packet1_bram_f_clk		: out STD_LOGIC;
		packet1_bram_f_rst		: out STD_LOGIC;
		packet1_bram_f_en		: out STD_LOGIC;	
		packet1_bram_f_wen		: out STD_LOGIC_VECTOR(3 downto 0);	
		packet1_bram_f_addr		: out STD_LOGIC_VECTOR(31 downto 0);	
		packet1_bram_f_dout		: in STD_LOGIC_VECTOR(31 downto 0) := x"00000000";	
		packet1_bram_f_din		: out STD_LOGIC_VECTOR(31 downto 0);	
		
		packet1_bram_s_clk 		: out STD_LOGIC;
		packet1_bram_s_rst		: out STD_LOGIC;
		packet1_bram_s_en 		: out STD_LOGIC;	
		packet1_bram_s_addr 	: out STD_LOGIC_VECTOR(PACKET_MEMORY_BIT_ADDR-1 downto 0);
		packet1_bram_s_dout 	: in STD_LOGIC_VECTOR(7 downto 0):= x"00";
		
		packet1_valid 			: in STD_LOGIC := '0';
		packet1_len 			: in STD_LOGIC_VECTOR(15 downto 0):= x"0000";
		packet1_got 			: out STD_LOGIC;
		
		packet2_bram_f_clk		: out STD_LOGIC;
		packet2_bram_f_rst		: out STD_LOGIC;
		packet2_bram_f_en		: out STD_LOGIC;	
		packet2_bram_f_wen		: out STD_LOGIC_VECTOR(3 downto 0);	
		packet2_bram_f_addr		: out STD_LOGIC_VECTOR(31 downto 0);	
		packet2_bram_f_dout		: in STD_LOGIC_VECTOR(31 downto 0):= x"00000000";
		packet2_bram_f_din		: out STD_LOGIC_VECTOR(31 downto 0);	

		packet2_bram_s_clk 		: out STD_LOGIC;
		packet2_bram_s_rst		: out STD_LOGIC;
		packet2_bram_s_en 		: out STD_LOGIC;
		packet2_bram_s_addr 	: out STD_LOGIC_VECTOR(PACKET_MEMORY_BIT_ADDR-1 downto 0);
		packet2_bram_s_dout 	: in STD_LOGIC_VECTOR(7 downto 0):= x"00";

		packet2_valid 			: in STD_LOGIC := '0';
		packet2_len 			: in STD_LOGIC_VECTOR(15 downto 0):= x"0000";
		packet2_got 			: out STD_LOGIC;
		
		packet3_bram_f_clk		: out STD_LOGIC;
		packet3_bram_f_rst		: out STD_LOGIC;
		packet3_bram_f_en		: out STD_LOGIC;	
		packet3_bram_f_wen		: out STD_LOGIC_VECTOR(3 downto 0);
		packet3_bram_f_addr		: out STD_LOGIC_VECTOR(31 downto 0);	
		packet3_bram_f_dout		: in STD_LOGIC_VECTOR(31 downto 0):= x"00000000";
		packet3_bram_f_din		: out STD_LOGIC_VECTOR(31 downto 0);	

		packet3_bram_s_clk 		: out STD_LOGIC;
		packet3_bram_s_rst		: out STD_LOGIC;
		packet3_bram_s_en 		: out STD_LOGIC;
		packet3_bram_s_addr 	: out STD_LOGIC_VECTOR(PACKET_MEMORY_BIT_ADDR-1 downto 0);
		packet3_bram_s_dout 	: in STD_LOGIC_VECTOR(7 downto 0):= x"00";

		packet3_valid 			: in STD_LOGIC := '0';
		packet3_len 			: in STD_LOGIC_VECTOR(15 downto 0):= x"0000";
		packet3_got 			: out STD_LOGIC;
		
		packet4_bram_f_clk		: out STD_LOGIC;
		packet4_bram_f_rst		: out STD_LOGIC;
		packet4_bram_f_en		: out STD_LOGIC;	
		packet4_bram_f_wen		: out STD_LOGIC_VECTOR(3 downto 0);
		packet4_bram_f_addr		: out STD_LOGIC_VECTOR(31 downto 0);	
		packet4_bram_f_dout		: in STD_LOGIC_VECTOR(31 downto 0):= x"00000000";	
		packet4_bram_f_din		: out STD_LOGIC_VECTOR(31 downto 0);	

		packet4_bram_s_clk 		: out STD_LOGIC;
		packet4_bram_s_rst		: out STD_LOGIC;
		packet4_bram_s_en 		: out STD_LOGIC;
		packet4_bram_s_addr 	: out STD_LOGIC_VECTOR(PACKET_MEMORY_BIT_ADDR-1 downto 0);
		packet4_bram_s_dout 	: in STD_LOGIC_VECTOR(7 downto 0):= x"00";

		packet4_valid 			: in STD_LOGIC := '0';
		packet4_len 			: in STD_LOGIC_VECTOR(15 downto 0):= x"0000";
		packet4_got 			: out STD_LOGIC
	);
	end component;
	
	COMPONENT blk_mem_gen_0
      PORT (
        clka : IN STD_LOGIC;
        ena : IN STD_LOGIC;
        wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        clkb : IN STD_LOGIC;
        enb : IN STD_LOGIC;
        addrb : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        doutb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
      );
    END COMPONENT;
    type data_vector_t is array(31 downto 0) of std_logic_vector(7 downto 0);
	
	signal clk 				: STD_LOGIC;

	signal rst_n			: STD_LOGIC;
	signal wclk				: STD_LOGIC;
	signal wclk_counter 	: integer := 0;
		
	constant AUDIO_CHANNELS : integer := 7;
	-- constant AUDIO_CHANNELS : integer := 11;
	-- constant AUDIO_CHANNELS : integer := 15;		
	constant CLK_FREQ : integer := 	(AUDIO_CHANNELS+1)*32000*40;

	constant clk_period : time := 1000 ms / real(CLK_FREQ);


	constant WCLK_RATIO : integer := (AUDIO_CHANNELS+1)*40;

	
	signal data_byte_0 				: STD_LOGIC_VECTOR(7 downto 0) := x"00";
	signal data_valid_0 			: STD_LOGIC := '0';
	signal data_byte_1 				: STD_LOGIC_VECTOR(7 downto 0) := x"00";
	signal data_valid_1 			: STD_LOGIC := '0';
	signal data_byte_2 				: STD_LOGIC_VECTOR(7 downto 0) := x"00";
	signal data_valid_2 			: STD_LOGIC := '0';

	signal packet1_bram_f_clk		: STD_LOGIC;
	signal packet1_bram_f_rst		: STD_LOGIC;
	signal packet1_bram_f_en		: STD_LOGIC;	
	signal packet1_bram_f_wen		: STD_LOGIC_VECTOR(3 downto 0);	
	signal packet1_bram_f_addr		: STD_LOGIC_VECTOR(31 downto 0);	
	signal packet1_bram_f_dout		: STD_LOGIC_VECTOR(31 downto 0);	
	signal packet1_bram_f_din		: STD_LOGIC_VECTOR(31 downto 0);	

	signal packet1_bram_s_clk 		: STD_LOGIC;
	signal packet1_bram_s_rst		: STD_LOGIC;
	signal packet1_bram_s_en 		: STD_LOGIC;	
	signal packet1_bram_s_addr 		: STD_LOGIC_VECTOR(9 downto 0);
	signal packet1_bram_s_dout 		: STD_LOGIC_VECTOR(7 downto 0);

	signal packet1_valid 			: STD_LOGIC := '0';
	signal packet1_len 				: STD_LOGIC_VECTOR(15 downto 0);
	signal packet1_got 				: STD_LOGIC;
	
	signal wea                      : STD_LOGIC_VECTOR(0 downto 0);
    signal addra                    : STD_LOGIC_VECTOR(9 DOWNTO 0);
    signal dina                     : STD_LOGIC_VECTOR(7 DOWNTO 0);	
	signal packet_to_send 			: data_vector_t;
	signal state					: STD_LOGIC_VECTOR(1 downto 0);
	
	signal counter_byte 			: integer := 0;
begin


	clk_process : process
	begin
		clk_loop : loop
			clk <= '0';
			wait for clk_period/2;
			clk <= '1';
			wait for clk_period/2;
		end loop clk_loop;
	end process;
	
	wclk_process : process(clk,rst_n)
	begin
		if(rst_n='0')then
			wclk <= '0';
		elsif rising_edge(clk) then
			
			if(wclk_counter=WCLK_RATIO-1)then
				wclk_counter <= 0;
			else
				wclk_counter <= wclk_counter+1;
			end if;
			
			if(wclk_counter<WCLK_RATIO/2) then
				wclk <= '0';
			else
				wclk <= '1';
			end if;
		end if;
	end process;
	
	tb : process
	begin
		rst_n <= '0';

		wait for 100 ns;
		rst_n <= '1';
		wait for 100 ns;
		
        wait for 1  ms;

		wait;
	end process;

	process_write_bram : process (clk, rst_n)
	begin
	   if (rst_n='0')then
	       wea <= "0";
	       addra <= (others => '0');
	       dina <= (others => '0');
	       counter_byte <= 0;
		   packet_to_send(0) <= x"55";
		   packet_to_send(1) <= x"AA";
		   packet_to_send(2) <= x"00";
		   packet_to_send(3) <= x"0A";
		   packet_to_send(4) <= x"00";
		   packet_to_send(5) <= x"00";
		   packet_to_send(6) <= x"00";
		   packet_to_send(7) <= x"00";
		   packet_to_send(8) <= x"00";
		   packet_to_send(9) <= x"F5";
		   state <= "00";
		   packet1_valid <= '0';
		   packet1_len <= x"0000";
	   elsif rising_edge(clk) then
	       if(state="00") then
				wea <= "1";
				addra <= std_logic_vector(to_unsigned(counter_byte, addra'length));
				dina <= packet_to_send(counter_byte);
				counter_byte <= counter_byte+1;
				if(counter_byte=9)then
					state <= "01";
				end if;
		   elsif(state="01")then
				wea <= "0";
				
				packet1_valid <= '1';
				packet1_len <= x"000A";
				if(packet1_got='1')then
					state <= "10";
				
				end if;
			else
				packet1_valid <= '0';
			end if;
	   end if;	
	end process;
	
	uut_send: packet_sender 
	generic map (
		PORT_NUMBER => 1
	)
	port map
	( 
		clk 					=> clk,       
		rst_n 					=> rst_n, 
		wclk					=> wclk,
		data_byte_0 			=> data_byte_0 ,
		data_valid_0 			=> data_valid_0,
		data_byte_1 			=> data_byte_1 ,
		data_valid_1 			=> data_valid_1,
		data_byte_2 			=> data_byte_2 ,
		data_valid_2 			=> data_valid_2,
				
		packet1_bram_s_clk 		=> packet1_bram_s_clk ,		
		packet1_bram_s_rst		=> packet1_bram_s_rst,		
		packet1_bram_s_en 		=> packet1_bram_s_en ,		
		packet1_bram_s_addr 	=> packet1_bram_s_addr, 	
		packet1_bram_s_dout 	=> packet1_bram_s_dout, 	
		
		packet1_valid 			=> packet1_valid,
		packet1_len 			=> packet1_len,
		packet1_got 			=> packet1_got 
	);
	
    block_ram : blk_mem_gen_0
      PORT MAP (
        clka => clk,
        ena => '1',
        wea => wea,
        addra => addra,
        dina => dina,
        clkb => packet1_bram_s_clk,
        enb => packet1_bram_s_en,
        addrb => packet1_bram_s_addr,
        doutb => packet1_bram_s_dout
      );
end Behavioral;
