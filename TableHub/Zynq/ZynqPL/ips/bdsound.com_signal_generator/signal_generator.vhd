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

entity signal_generator is
Generic(
	--constant AUDIO_CHANNELS : integer := 7
	--constant AUDIO_CHANNELS : integer := 11
	constant AUDIO_CHANNELS : integer := 15
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

	audio_data_0 	: out STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_valid_0 	: out STD_LOGIC := '0';
	audio_mute_0 	: out STD_LOGIC := '0';

	audio_data_1 	: out STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_valid_1 	: out STD_LOGIC := '0';
	audio_mute_1 	: out STD_LOGIC := '0';

	audio_data_2 	: out STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_valid_2 	: out STD_LOGIC := '0';
	audio_mute_2 	: out STD_LOGIC := '0';

	audio_data_3 	: out STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_valid_3 	: out STD_LOGIC := '0';
	audio_mute_3 	: out STD_LOGIC := '0';

	audio_data_4 	: out STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_valid_4 	: out STD_LOGIC := '0';
	audio_mute_4 	: out STD_LOGIC := '0';

	audio_data_5 	: out STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_valid_5 	: out STD_LOGIC := '0';
	audio_mute_5 	: out STD_LOGIC := '0';
		 
	audio_data_6 	: out STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_valid_6 	: out STD_LOGIC := '0';
	audio_mute_6 	: out STD_LOGIC := '0';
		
	audio_data_7 	: out STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_valid_7 	: out STD_LOGIC := '0';
	audio_mute_7 	: out STD_LOGIC := '0';
	   
	audio_data_8 	: out STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_valid_8 	: out STD_LOGIC := '0';
	audio_mute_8 	: out STD_LOGIC := '0';
	
	audio_data_9 	: out STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_valid_9 	: out STD_LOGIC := '0';
	audio_mute_9 	: out STD_LOGIC := '0';
		 
	audio_data_10 	: out STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_valid_10 	: out STD_LOGIC := '0';
	audio_mute_10 	: out STD_LOGIC := '0';
	
	audio_data_11 	: out STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_valid_11 	: out STD_LOGIC := '0';
	audio_mute_11 	: out STD_LOGIC := '0';
	
	audio_data_12 	: out STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_valid_12 	: out STD_LOGIC := '0';
	audio_mute_12 	: out STD_LOGIC := '0';
		
	audio_data_13 	: out STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_valid_13 	: out STD_LOGIC := '0';
	audio_mute_13 	: out STD_LOGIC := '0';
		  
	audio_data_14 	: out STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_valid_14 	: out STD_LOGIC := '0';
	audio_mute_14 	: out STD_LOGIC := '0'
	
);
end signal_generator;

architecture Behavioral of signal_generator is    
	signal counter_trans : integer := 0;
	signal wclk_in_r : std_logic_vector(1 downto 0);
	signal tx_data_byte_0 		: STD_LOGIC_VECTOR(7 downto 0);
	signal tx_data_valid_0 	: STD_LOGIC;
	signal tx_data_byte_1 		: STD_LOGIC_VECTOR(7 downto 0);
	signal tx_data_valid_1 	: STD_LOGIC;
	signal tx_data_byte_2 		: STD_LOGIC_VECTOR(7 downto 0);
	signal tx_data_valid_2 	: STD_LOGIC;
	signal tx_audio_data_0 	: STD_LOGIC_VECTOR(23 downto 0);
	signal tx_audio_valid_0 	: STD_LOGIC;
	signal tx_audio_mute_0 	: STD_LOGIC;
	signal tx_audio_data_1 	: STD_LOGIC_VECTOR(23 downto 0);
	signal tx_audio_valid_1 	: STD_LOGIC;
	signal tx_audio_mute_1 	: STD_LOGIC;
	signal tx_audio_data_2 	: STD_LOGIC_VECTOR(23 downto 0);
	signal tx_audio_valid_2 	: STD_LOGIC;
	signal tx_audio_mute_2 	: STD_LOGIC;
	signal tx_audio_data_3 	: STD_LOGIC_VECTOR(23 downto 0);
	signal tx_audio_valid_3 	: STD_LOGIC;
	signal tx_audio_mute_3 	: STD_LOGIC;
	signal tx_audio_data_4 	: STD_LOGIC_VECTOR(23 downto 0);
	signal tx_audio_valid_4 	: STD_LOGIC;
	signal tx_audio_mute_4 	: STD_LOGIC;
	signal tx_audio_data_5 	: STD_LOGIC_VECTOR(23 downto 0);
	signal tx_audio_valid_5 	: STD_LOGIC;
	signal tx_audio_mute_5 	: STD_LOGIC;
	signal tx_audio_data_6 	: STD_LOGIC_VECTOR(23 downto 0);
	signal tx_audio_valid_6 	: STD_LOGIC;
	signal tx_audio_mute_6 	: STD_LOGIC;
	signal tx_audio_data_7 	: STD_LOGIC_VECTOR(23 downto 0);
	signal tx_audio_valid_7 	: STD_LOGIC;
	signal tx_audio_mute_7 	: STD_LOGIC;
	signal tx_audio_data_8 	: STD_LOGIC_VECTOR(23 downto 0);
	signal tx_audio_valid_8 	: STD_LOGIC;
	signal tx_audio_mute_8 	: STD_LOGIC;
	signal tx_audio_data_9 	: STD_LOGIC_VECTOR(23 downto 0);
	signal tx_audio_valid_9 	: STD_LOGIC;
	signal tx_audio_mute_9 	: STD_LOGIC;
	signal tx_audio_data_10 	: STD_LOGIC_VECTOR(23 downto 0);
	signal tx_audio_valid_10 	: STD_LOGIC;
	signal tx_audio_mute_10 	: STD_LOGIC;
	signal tx_audio_data_11 	: STD_LOGIC_VECTOR(23 downto 0);
	signal tx_audio_valid_11 	: STD_LOGIC;
	signal tx_audio_mute_11 	: STD_LOGIC;
	signal tx_audio_data_12 	: STD_LOGIC_VECTOR(23 downto 0);
	signal tx_audio_valid_12 	: STD_LOGIC;
	signal tx_audio_mute_12 	: STD_LOGIC;
	signal tx_audio_data_13 	: STD_LOGIC_VECTOR(23 downto 0);
	signal tx_audio_valid_13 	: STD_LOGIC;
	signal tx_audio_mute_13 	: STD_LOGIC;
	signal tx_audio_data_14 	: STD_LOGIC_VECTOR(23 downto 0);
	signal tx_audio_valid_14 	: STD_LOGIC;
	signal tx_audio_mute_14 	: STD_LOGIC;
	
begin

	data_process : process(rst_n, clk)
	begin
		if(rst_n='0')then
			tx_data_byte_0    <= x"10";
			tx_data_valid_0   <= '0';
			tx_data_byte_1    <= x"20";
			tx_data_valid_1   <= '1';
			tx_data_byte_2    <= x"30";
			tx_data_valid_2   <= '1';
			tx_audio_data_0   <= x"800000";
			tx_audio_valid_0  <= '1';
			tx_audio_mute_0   <= '0';
			tx_audio_data_1   <= x"800100";
			tx_audio_valid_1  <= '1';
			tx_audio_mute_1   <= '0';
			tx_audio_data_2   <= x"800200";
			tx_audio_valid_2  <= '1';
			tx_audio_mute_2   <= '0';
			tx_audio_data_3   <= x"800300";
			tx_audio_valid_3  <= '0';
			tx_audio_mute_3   <= '0';
			tx_audio_data_4   <= x"800400";
			tx_audio_valid_4  <= '1';
			tx_audio_mute_4   <= '0';
			tx_audio_data_5   <= x"800500";
			tx_audio_valid_5  <= '0';
			tx_audio_mute_5   <= '0';
			tx_audio_data_6   <= x"800600";
			tx_audio_valid_6  <= '1';
			tx_audio_mute_6   <= '0';
			tx_audio_data_7   <= x"800700";
			tx_audio_valid_7  <= '0';
			tx_audio_mute_7   <= '0';
			tx_audio_data_8   <= x"800800";
			tx_audio_valid_8  <= '1';
			tx_audio_mute_8   <= '0';
			tx_audio_data_9   <= x"800900";
			tx_audio_valid_9  <= '0';
			tx_audio_mute_9   <= '0';
			tx_audio_data_10  <= x"800A00";
			tx_audio_valid_10 <= '1';
			tx_audio_mute_10  <= '0';
			tx_audio_data_11  <= x"800B00";
			tx_audio_valid_11 <= '0';
			tx_audio_mute_11  <= '0';
			tx_audio_data_12  <= x"800C00";
			tx_audio_valid_12 <= '1';
			tx_audio_mute_12  <= '0';
			tx_audio_data_13  <= x"800D00";
			tx_audio_valid_13 <= '0';
			tx_audio_mute_13  <= '0';
			tx_audio_data_14  <= x"800E00";
			tx_audio_valid_14 <= '1';
			tx_audio_mute_14  <= '1';
            wclk_in_r <= "00";
		elsif rising_edge(clk)then
			wclk_in_r <= wclk_in_r(0) & wclk;
			if(wclk_in_r="01")then
				counter_trans <= counter_trans +1;
				tx_data_byte_0    <= tx_data_byte_0   + 1;
				tx_data_byte_1    <= tx_data_byte_1   + 1;
				tx_data_byte_2    <= tx_data_byte_2   + 1;
				tx_audio_data_0   <= tx_audio_data_0  + 1;
				tx_audio_data_1   <= tx_audio_data_1  + 1;
				tx_audio_data_2   <= tx_audio_data_2  + 1;
				tx_audio_data_3   <= tx_audio_data_3  + 1;
				tx_audio_data_4   <= tx_audio_data_4  + 1;
				tx_audio_data_5   <= tx_audio_data_5  + 1;
				tx_audio_data_6   <= tx_audio_data_6  + 1;
				tx_audio_data_7   <= tx_audio_data_7  + 1;
				tx_audio_data_8   <= tx_audio_data_8  + 1;
				tx_audio_data_9   <= tx_audio_data_9  + 1;
				tx_audio_data_10  <= tx_audio_data_10 + 1;
				tx_audio_data_11  <= tx_audio_data_11 + 1;
				tx_audio_data_12  <= tx_audio_data_12 + 1;
				tx_audio_data_13  <= tx_audio_data_13 + 1;
				tx_audio_data_14  <= tx_audio_data_14 + 1;

				
				if(counter_trans=100)then
					tx_data_valid_0   <= '1';
					tx_data_valid_1   <= '0';
					tx_data_valid_2   <= '0';
					tx_audio_valid_0  <= '0';
					tx_audio_mute_0   <= '1';
					tx_audio_valid_1  <= '1';
					tx_audio_mute_1   <= '1';
					tx_audio_valid_2  <= '0';
					tx_audio_mute_2   <= '0';
					tx_audio_valid_3  <= '0';
					tx_audio_mute_3   <= '1';
					tx_audio_valid_4  <= '0';
					tx_audio_mute_4   <= '0';
					tx_audio_valid_5  <= '1';
					tx_audio_mute_5   <= '1';
					tx_audio_valid_6  <= '0';
					tx_audio_mute_6   <= '1';
					tx_audio_valid_7  <= '1';
					tx_audio_mute_7   <= '0';
					tx_audio_valid_8  <= '1';
					tx_audio_mute_8   <= '0';
					tx_audio_valid_9  <= '0';
					tx_audio_mute_9   <= '0';
					tx_audio_valid_10 <= '1';
					tx_audio_mute_10  <= '0';
					tx_audio_valid_11 <= '0';
					tx_audio_mute_11  <= '0';
					tx_audio_valid_12 <= '1';
					tx_audio_mute_12  <= '0';
					tx_audio_valid_13 <= '1';
					tx_audio_mute_13  <= '1';
					tx_audio_valid_14 <= '0';
					tx_audio_mute_14  <= '0';
				end if;
			end if;
		end if;
	end process;

	data_byte_0 	    <= tx_data_byte_0 	  ;
	data_valid_0 	<= tx_data_valid_0 	  ;
	data_byte_1 	    <= tx_data_byte_1 	  ;
	data_valid_1 	<= tx_data_valid_1 	  ;
	data_byte_2 	    <= tx_data_byte_2 	  ;
	data_valid_2 	<= tx_data_valid_2 	  ;
	audio_data_0 	<= tx_audio_data_0 	  ;
	audio_valid_0    <= tx_audio_valid_0   ;
	audio_mute_0 	<= tx_audio_mute_0 	  ;
	audio_data_1 	<= tx_audio_data_1 	  ;
	audio_valid_1    <= tx_audio_valid_1   ;
	audio_mute_1 	<= tx_audio_mute_1 	  ;
	audio_data_2 	<= tx_audio_data_2 	  ;
	audio_valid_2    <= tx_audio_valid_2   ;
	audio_mute_2 	<= tx_audio_mute_2 	  ;
	audio_data_3 	<= tx_audio_data_3 	  ;
	audio_valid_3    <= tx_audio_valid_3   ;
	audio_mute_3 	<= tx_audio_mute_3 	  ;
	audio_data_4 	<= tx_audio_data_4 	  ;
	audio_valid_4    <= tx_audio_valid_4   ;
	audio_mute_4 	<= tx_audio_mute_4 	  ;
	audio_data_5 	<= tx_audio_data_5 	  ;
	audio_valid_5    <= tx_audio_valid_5   ;
	audio_mute_5 	<= tx_audio_mute_5 	  ;
	audio_data_6 	<= tx_audio_data_6 	  ;
	audio_valid_6    <= tx_audio_valid_6   ;
	audio_mute_6 	<= tx_audio_mute_6 	  ;
	audio_data_7 	<= tx_audio_data_7 	  ;
	audio_valid_7    <= tx_audio_valid_7   ;
	audio_mute_7 	<= tx_audio_mute_7 	  ;
	audio_data_8 	<= tx_audio_data_8 	  ;
	audio_valid_8    <= tx_audio_valid_8   ;
	audio_mute_8 	<= tx_audio_mute_8 	  ;
	audio_data_9 	<= tx_audio_data_9 	  ;
	audio_valid_9    <= tx_audio_valid_9   ;
	audio_mute_9 	<= tx_audio_mute_9 	  ;
	audio_data_10    <= tx_audio_data_10   ;
	audio_valid_10   <= tx_audio_valid_10  ;
	audio_mute_10    <= tx_audio_mute_10   ;
	audio_data_11    <= tx_audio_data_11   ;
	audio_valid_11   <= tx_audio_valid_11  ;
	audio_mute_11    <= tx_audio_mute_11   ;
	audio_data_12    <= tx_audio_data_12   ;
	audio_valid_12   <= tx_audio_valid_12  ;
	audio_mute_12    <= tx_audio_mute_12   ;
	audio_data_13    <= tx_audio_data_13   ;
	audio_valid_13   <= tx_audio_valid_13  ;
	audio_mute_13    <= tx_audio_mute_13   ;
	audio_data_14    <= tx_audio_data_14   ;
	audio_valid_14   <= tx_audio_valid_14  ;
	audio_mute_14    <= tx_audio_mute_14   ;
	
	
	
	
	
	
	
	
	
	
end Behavioral;
