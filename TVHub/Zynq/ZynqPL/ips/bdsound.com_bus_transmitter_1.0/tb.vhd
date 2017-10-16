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
	component bus_transmitter is
	Generic(
		constant AUDIO_CHANNELS : integer := 15
	);
	Port ( 
		clk 			: in STD_LOGIC;
		rst_n 			: in STD_LOGIC;
		enable			: in STD_LOGIC;
		
		dout 			: out STD_LOGIC;
		
		wclk			: in STD_LOGIC;
		
		data_byte_0 	: in STD_LOGIC_VECTOR(7 downto 0);
		data_valid_0 	: in STD_LOGIC;
		
		data_byte_1 	: in STD_LOGIC_VECTOR(7 downto 0);
		data_valid_1 	: in STD_LOGIC;
		
		data_byte_2 	: in STD_LOGIC_VECTOR(7 downto 0);
		data_valid_2 	: in STD_LOGIC;
		
		audio_data_0 	: in STD_LOGIC_VECTOR(23 downto 0);
		audio_valid_0 	: in STD_LOGIC;
		audio_mute_0 	: in STD_LOGIC;
			
		audio_data_1 	: in STD_LOGIC_VECTOR(23 downto 0);
		audio_valid_1 	: in STD_LOGIC;
		audio_mute_1 	: in STD_LOGIC;
			
		audio_data_2 	: in STD_LOGIC_VECTOR(23 downto 0);
		audio_valid_2 	: in STD_LOGIC;
		audio_mute_2 	: in STD_LOGIC;
			
		audio_data_3 	: in STD_LOGIC_VECTOR(23 downto 0);
		audio_valid_3 	: in STD_LOGIC;
		audio_mute_3 	: in STD_LOGIC;
			
		audio_data_4 	: in STD_LOGIC_VECTOR(23 downto 0);
		audio_valid_4 	: in STD_LOGIC;
		audio_mute_4 	: in STD_LOGIC;
			
		audio_data_5 	: in STD_LOGIC_VECTOR(23 downto 0);
		audio_valid_5 	: in STD_LOGIC;
		audio_mute_5 	: in STD_LOGIC;
			
		audio_data_6 	: in STD_LOGIC_VECTOR(23 downto 0);
		audio_valid_6 	: in STD_LOGIC;
		audio_mute_6 	: in STD_LOGIC;
			
		audio_data_7 	: in STD_LOGIC_VECTOR(23 downto 0);
		audio_valid_7 	: in STD_LOGIC;
		audio_mute_7 	: in STD_LOGIC;
		
		audio_data_8 	: in STD_LOGIC_VECTOR(23 downto 0);
		audio_valid_8 	: in STD_LOGIC;
		audio_mute_8 	: in STD_LOGIC;
			
		audio_data_9 	: in STD_LOGIC_VECTOR(23 downto 0);
		audio_valid_9 	: in STD_LOGIC;
		audio_mute_9 	: in STD_LOGIC;
			
		audio_data_10 	: in STD_LOGIC_VECTOR(23 downto 0);
		audio_valid_10 	: in STD_LOGIC;
		audio_mute_10 	: in STD_LOGIC;
			
		audio_data_11 	: in STD_LOGIC_VECTOR(23 downto 0);
		audio_valid_11 	: in STD_LOGIC;
		audio_mute_11 	: in STD_LOGIC;
			
		audio_data_12 	: in STD_LOGIC_VECTOR(23 downto 0);
		audio_valid_12 	: in STD_LOGIC;
		audio_mute_12 	: in STD_LOGIC;
			
		audio_data_13 	: in STD_LOGIC_VECTOR(23 downto 0);
		audio_valid_13 	: in STD_LOGIC;
		audio_mute_13 	: in STD_LOGIC;
			
		audio_data_14 	: in STD_LOGIC_VECTOR(23 downto 0);
		audio_valid_14 	: in STD_LOGIC;
		audio_mute_14 	: in STD_LOGIC
		
	);
	end component;
	component bus_receiver is
	Generic(
		constant AUDIO_CHANNELS : integer := 15
	);
	Port ( 
		clk_0 			: in STD_LOGIC;
		clk_90 			: in STD_LOGIC;
		clk_180			: in STD_LOGIC;
		clk_270			: in STD_LOGIC;
		rst_n 			: in STD_LOGIC;
		enable			: in STD_LOGIC;
		
		din 			: in STD_LOGIC;
		
		wclk			: out STD_LOGIC;
		
		data_byte_0 	: out STD_LOGIC_VECTOR(7 downto 0);
		data_valid_0 	: out STD_LOGIC;

		data_byte_1 	: out STD_LOGIC_VECTOR(7 downto 0);
		data_valid_1 	: out STD_LOGIC;

		data_byte_2 	: out STD_LOGIC_VECTOR(7 downto 0);
		data_valid_2 	: out STD_LOGIC;

		audio_data_0 	: out STD_LOGIC_VECTOR(23 downto 0);
		audio_valid_0 	: out STD_LOGIC;
		audio_mute_0 	: out STD_LOGIC;

		audio_data_1 	: out STD_LOGIC_VECTOR(23 downto 0);
		audio_valid_1 	: out STD_LOGIC;
		audio_mute_1 	: out STD_LOGIC;

		audio_data_2 	: out STD_LOGIC_VECTOR(23 downto 0);
		audio_valid_2 	: out STD_LOGIC;
		audio_mute_2 	: out STD_LOGIC;

		audio_data_3 	: out STD_LOGIC_VECTOR(23 downto 0);
		audio_valid_3 	: out STD_LOGIC;
		audio_mute_3 	: out STD_LOGIC;

		audio_data_4 	: out STD_LOGIC_VECTOR(23 downto 0);
		audio_valid_4 	: out STD_LOGIC;
		audio_mute_4 	: out STD_LOGIC;

		audio_data_5 	: out STD_LOGIC_VECTOR(23 downto 0);
		audio_valid_5 	: out STD_LOGIC;
		audio_mute_5 	: out STD_LOGIC;
			 
		audio_data_6 	: out STD_LOGIC_VECTOR(23 downto 0);
		audio_valid_6 	: out STD_LOGIC;
		audio_mute_6 	: out STD_LOGIC;
			
		audio_data_7 	: out STD_LOGIC_VECTOR(23 downto 0);
		audio_valid_7 	: out STD_LOGIC;
		audio_mute_7 	: out STD_LOGIC;
		   
		audio_data_8 	: out STD_LOGIC_VECTOR(23 downto 0);
		audio_valid_8 	: out STD_LOGIC;
		audio_mute_8 	: out STD_LOGIC;
		
		audio_data_9 	: out STD_LOGIC_VECTOR(23 downto 0);
		audio_valid_9 	: out STD_LOGIC;
		audio_mute_9 	: out STD_LOGIC;
			 
		audio_data_10 	: out STD_LOGIC_VECTOR(23 downto 0);
		audio_valid_10 	: out STD_LOGIC;
		audio_mute_10 	: out STD_LOGIC;
		
		audio_data_11 	: out STD_LOGIC_VECTOR(23 downto 0);
		audio_valid_11 	: out STD_LOGIC;
		audio_mute_11 	: out STD_LOGIC;
		
		audio_data_12 	: out STD_LOGIC_VECTOR(23 downto 0);
		audio_valid_12 	: out STD_LOGIC;
		audio_mute_12 	: out STD_LOGIC;
			
		audio_data_13 	: out STD_LOGIC_VECTOR(23 downto 0);
		audio_valid_13 	: out STD_LOGIC;
		audio_mute_13 	: out STD_LOGIC;
			  
		audio_data_14 	: out STD_LOGIC_VECTOR(23 downto 0);
		audio_valid_14 	: out STD_LOGIC;
		audio_mute_14 	: out STD_LOGIC
		
	);
	end component;
	
	signal rx_data_byte_0 		: STD_LOGIC_VECTOR(7 downto 0);
	signal rx_data_valid_0 	: STD_LOGIC;
	signal rx_data_byte_1 		: STD_LOGIC_VECTOR(7 downto 0);
	signal rx_data_valid_1 	: STD_LOGIC;
	signal rx_data_byte_2 		: STD_LOGIC_VECTOR(7 downto 0);
	signal rx_data_valid_2 	: STD_LOGIC;
	signal rx_audio_data_0 	: STD_LOGIC_VECTOR(23 downto 0);
	signal rx_audio_valid_0 	: STD_LOGIC;
	signal rx_audio_mute_0 	: STD_LOGIC;
	signal rx_audio_data_1 	: STD_LOGIC_VECTOR(23 downto 0);
	signal rx_audio_valid_1 	: STD_LOGIC;
	signal rx_audio_mute_1 	: STD_LOGIC;
	signal rx_audio_data_2 	: STD_LOGIC_VECTOR(23 downto 0);
	signal rx_audio_valid_2 	: STD_LOGIC;
	signal rx_audio_mute_2 	: STD_LOGIC;
	signal rx_audio_data_3 	: STD_LOGIC_VECTOR(23 downto 0);
	signal rx_audio_valid_3 	: STD_LOGIC;
	signal rx_audio_mute_3 	: STD_LOGIC;
	signal rx_audio_data_4 	: STD_LOGIC_VECTOR(23 downto 0);
	signal rx_audio_valid_4 	: STD_LOGIC;
	signal rx_audio_mute_4 	: STD_LOGIC;
	signal rx_audio_data_5 	: STD_LOGIC_VECTOR(23 downto 0);
	signal rx_audio_valid_5 	: STD_LOGIC;
	signal rx_audio_mute_5 	: STD_LOGIC;
	signal rx_audio_data_6 	: STD_LOGIC_VECTOR(23 downto 0);
	signal rx_audio_valid_6 	: STD_LOGIC;
	signal rx_audio_mute_6 	: STD_LOGIC;
	signal rx_audio_data_7 	: STD_LOGIC_VECTOR(23 downto 0);
	signal rx_audio_valid_7 	: STD_LOGIC;
	signal rx_audio_mute_7 	: STD_LOGIC;
	signal rx_audio_data_8 	: STD_LOGIC_VECTOR(23 downto 0);
	signal rx_audio_valid_8 	: STD_LOGIC;
	signal rx_audio_mute_8 	: STD_LOGIC;
	signal rx_audio_data_9 	: STD_LOGIC_VECTOR(23 downto 0);
	signal rx_audio_valid_9 	: STD_LOGIC;
	signal rx_audio_mute_9 	: STD_LOGIC;
	signal rx_audio_data_10 	: STD_LOGIC_VECTOR(23 downto 0);
	signal rx_audio_valid_10 	: STD_LOGIC;
	signal rx_audio_mute_10 	: STD_LOGIC;
	signal rx_audio_data_11 	: STD_LOGIC_VECTOR(23 downto 0);
	signal rx_audio_valid_11 	: STD_LOGIC;
	signal rx_audio_mute_11 	: STD_LOGIC;
	signal rx_audio_data_12 	: STD_LOGIC_VECTOR(23 downto 0);
	signal rx_audio_valid_12 	: STD_LOGIC;
	signal rx_audio_mute_12 	: STD_LOGIC;
	signal rx_audio_data_13 	: STD_LOGIC_VECTOR(23 downto 0);
	signal rx_audio_valid_13 	: STD_LOGIC;
	signal rx_audio_mute_13 	: STD_LOGIC;
	signal rx_audio_data_14 	: STD_LOGIC_VECTOR(23 downto 0);
	signal rx_audio_valid_14 	: STD_LOGIC;
	signal rx_audio_mute_14 	: STD_LOGIC;
			 

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
	
	signal clk 				: STD_LOGIC;
	signal clk_0 			: STD_LOGIC;
	signal clk_90 			: STD_LOGIC;
	signal clk_180			: STD_LOGIC;
	signal clk_270			: STD_LOGIC;
	
	signal rst_n			: STD_LOGIC;
	signal enable			: STD_LOGIC;
	
	signal wclk_in			: STD_LOGIC;
	signal wclk_out			: STD_LOGIC;
	signal din				: STD_LOGIC;
	signal dout				: STD_LOGIC;
	
	signal wclk_counter : integer := 0;
	signal wclk_in_r : STD_LOGIC;
	signal counter_trans: integer :=0;
	
	constant AUDIO_CHANNELS : integer := 7;
	-- constant AUDIO_CHANNELS : integer := 11;
	-- constant AUDIO_CHANNELS : integer := 15;		
	constant CLK_FREQ : integer := 	(AUDIO_CHANNELS+1)*32000*40;
	constant CLK_FREQ_1 : integer := (AUDIO_CHANNELS+1)*32032*40;
    constant CLK_FREQ_2 : integer := (AUDIO_CHANNELS+1)*31968*40;
	constant clk_period_tx : time := 1000 ms / real(CLK_FREQ);
	-- constant clk_period_rx : time := 1000 ms / real(CLK_FREQ);
	-- constant clk_period_rx : time := 1000 ms / real(CLK_FREQ_1); -- +0.1%
	constant clk_period_rx : time := 1000 ms / real(CLK_FREQ_2); -- -0.1%

	constant WCLK_RATIO : integer := (AUDIO_CHANNELS+1)*40;

	signal error_check : STD_LOGIC := '0';
	

begin


	clk_process : process
	begin
		clk_loop : loop
			clk <= '0';
			wait for clk_period_tx/2;
			clk <= '1';
			wait for clk_period_tx/2;
		end loop clk_loop;
	end process;
	
	clk0_process : process
	begin
		clk0_loop : loop
			clk_0 <= '0';
			wait for clk_period_rx/2;
			clk_0 <= '1';
			wait for clk_period_rx/2;
		end loop clk0_loop;
	end process;
	
	clk90_process : process
	begin
		wait for clk_period_rx/4;
		clk90_loop : loop
			clk_90 <= '0';
			wait for clk_period_rx/2;
			clk_90 <= '1';
			wait for clk_period_rx/2;
		end loop clk90_loop;
	end process;
	
	clk180_process : process
	begin
		wait for clk_period_rx/2;
		clk180_loop : loop
			clk_180 <= '0';
			wait for clk_period_rx/2;
			clk_180 <= '1';
			wait for clk_period_rx/2;
		end loop clk180_loop;
	end process;
	
	clk270_process : process
	begin
		wait for 3*clk_period_rx/4;
		clk270_loop : loop
			clk_270 <= '0';
			wait for clk_period_rx/2;
			clk_270 <= '1';
			wait for clk_period_rx/2;
		end loop clk270_loop;
	end process;
	
	wclk_process : process(clk)
	begin
		if rising_edge(clk) then
			
			if(wclk_counter=WCLK_RATIO-1)then
				wclk_counter <= 0;
			else
				wclk_counter <= wclk_counter+1;
			end if;
			
			if(wclk_counter<WCLK_RATIO/2) then
				wclk_in <= '0';
			else
				wclk_in <= '1';
			end if;
		end if;
	end process;
	
	
	tb : process
	begin
		rst_n <= '0';
		enable <= '0';
		wait for 100 ns;
		rst_n <= '1';
		wait for 100 ns;
		enable <= '1';

		wait;
	end process;
	
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
			error_check <= '0';
		elsif rising_edge(clk)then
			wclk_in_r <= wclk_in;
			if((wclk_in_r='0')AND(wclk_in='1'))then
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
				--error check
				if(error_check = '1')then
					error_check <= '0';
				else
					if(
						(rx_data_byte_0/=tx_data_byte_0-1) OR
						(rx_data_byte_1/=tx_data_byte_1-1) OR
						(rx_data_byte_2/=tx_data_byte_2-1) OR
						(rx_audio_data_0/=tx_audio_data_0-1) OR
						(rx_audio_data_1/=tx_audio_data_1-1) OR
						(rx_audio_data_2/=tx_audio_data_2-1) OR
						(rx_audio_data_3/=tx_audio_data_3-1) OR
						(rx_audio_data_4/=tx_audio_data_4-1) OR
						(rx_audio_data_5/=tx_audio_data_5-1) OR
						(rx_audio_data_6/=tx_audio_data_6-1)
						) then
					
						error_check <= '1';
					elsif (AUDIO_CHANNELS>7) then
						if(
							(rx_audio_data_7/=tx_audio_data_7-1) OR
							(rx_audio_data_8/=tx_audio_data_8-1) OR
							(rx_audio_data_9/=tx_audio_data_9-1) OR
							(rx_audio_data_10/=tx_audio_data_10-1) 
							) then
							error_check <= '1';
						elsif(AUDIO_CHANNELS>11) then
							if((rx_audio_data_11/=tx_audio_data_11-1) OR
								(rx_audio_data_12/=tx_audio_data_12-1) OR
								(rx_audio_data_13/=tx_audio_data_13-1) OR
								(rx_audio_data_14/=tx_audio_data_14-1)) then
								error_check <= '1';
							end if;
						end if;
					end if;
				end if;
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
	uut_tx: bus_transmitter 
	generic map (
		AUDIO_CHANNELS => AUDIO_CHANNELS
	)
	port map
	( 
		clk 			=> clk,       
		rst_n 			=> rst_n,       
		enable			=> enable,       
                                      
		dout 			=> dout,      
                                      
		wclk			=> wclk_in,      
		
		data_byte_0 	=> tx_data_byte_0 	 ,
		data_valid_0 	=> tx_data_valid_0 ,
		data_byte_1 	=> tx_data_byte_1 	 ,
		data_valid_1 	=> tx_data_valid_1 ,
		data_byte_2 	=> tx_data_byte_2 	 ,
		data_valid_2 	=> tx_data_valid_2 ,
		audio_data_0 	=> tx_audio_data_0 ,
		audio_valid_0 	=> tx_audio_valid_0 ,	
		audio_mute_0 	=> tx_audio_mute_0 ,
		audio_data_1 	=> tx_audio_data_1 ,
		audio_valid_1 	=> tx_audio_valid_1 ,	
		audio_mute_1 	=> tx_audio_mute_1 ,
		audio_data_2 	=> tx_audio_data_2 ,
		audio_valid_2 	=> tx_audio_valid_2 ,	
		audio_mute_2 	=> tx_audio_mute_2 ,
		audio_data_3 	=> tx_audio_data_3 ,
		audio_valid_3 	=> tx_audio_valid_3 ,	
		audio_mute_3 	=> tx_audio_mute_3 ,
		audio_data_4 	=> tx_audio_data_4 ,
		audio_valid_4 	=> tx_audio_valid_4 ,	
		audio_mute_4 	=> tx_audio_mute_4 ,
		audio_data_5 	=> tx_audio_data_5 ,
		audio_valid_5 	=> tx_audio_valid_5 ,	
		audio_mute_5 	=> tx_audio_mute_5 ,
		audio_data_6 	=> tx_audio_data_6 ,
		audio_valid_6 	=> tx_audio_valid_6 ,	
		audio_mute_6 	=> tx_audio_mute_6 ,
		audio_data_7 	=> tx_audio_data_7 ,
		audio_valid_7 	=> tx_audio_valid_7 ,	
		audio_mute_7 	=> tx_audio_mute_7 ,
		audio_data_8 	=> tx_audio_data_8 ,
		audio_valid_8 	=> tx_audio_valid_8 ,	
		audio_mute_8 	=> tx_audio_mute_8 ,
		audio_data_9 	=> tx_audio_data_9 ,
		audio_valid_9 	=> tx_audio_valid_9 ,	
		audio_mute_9 	=> tx_audio_mute_9 ,
		audio_data_10 	=> tx_audio_data_10 ,	
		audio_valid_10 	=> tx_audio_valid_10,	
		audio_mute_10 	=> tx_audio_mute_10 ,	
		audio_data_11 	=> tx_audio_data_11 ,	
		audio_valid_11 	=> tx_audio_valid_11,	
		audio_mute_11 	=> tx_audio_mute_11 ,	 
		audio_data_12 	=> tx_audio_data_12 ,	
		audio_valid_12 	=> tx_audio_valid_12,	
		audio_mute_12 	=> tx_audio_mute_12 ,	
		audio_data_13 	=> tx_audio_data_13 ,	
		audio_valid_13 	=> tx_audio_valid_13,	
		audio_mute_13 	=> tx_audio_mute_13 ,	     
		audio_data_14 	=> tx_audio_data_14 ,	
		audio_valid_14 	=> tx_audio_valid_14,	
		audio_mute_14 	=> tx_audio_mute_14 
	);                                
	                                  
                                      
	uut_rx: bus_receiver    
	generic map (
		AUDIO_CHANNELS => AUDIO_CHANNELS
	)
	port map                          
	(                                 
		clk_0 			=> clk_0,
		clk_90 			=> clk_90,
		clk_180			=> clk_180,
		clk_270			=> clk_270,
		rst_n 			=> rst_n,
		enable			=> enable,
		     
		din 			=> dout,
		       
		wclk			=> wclk_out,
		       
		data_byte_0 	=> rx_data_byte_0 	 ,
		data_valid_0 	=> rx_data_valid_0 ,
		data_byte_1 	=> rx_data_byte_1 	 ,
		data_valid_1 	=> rx_data_valid_1 ,
		data_byte_2 	=> rx_data_byte_2 	 ,
		data_valid_2 	=> rx_data_valid_2 ,
		audio_data_0 	=> rx_audio_data_0 ,
		audio_valid_0 	=> rx_audio_valid_0 ,	
		audio_mute_0 	=> rx_audio_mute_0 ,
		audio_data_1 	=> rx_audio_data_1 ,
		audio_valid_1 	=> rx_audio_valid_1 ,	
		audio_mute_1 	=> rx_audio_mute_1 ,
		audio_data_2 	=> rx_audio_data_2 ,
		audio_valid_2 	=> rx_audio_valid_2 ,	
		audio_mute_2 	=> rx_audio_mute_2 ,
		audio_data_3 	=> rx_audio_data_3 ,
		audio_valid_3 	=> rx_audio_valid_3 ,	
		audio_mute_3 	=> rx_audio_mute_3 ,
		audio_data_4 	=> rx_audio_data_4 ,
		audio_valid_4 	=> rx_audio_valid_4 ,	
		audio_mute_4 	=> rx_audio_mute_4 ,
		audio_data_5 	=> rx_audio_data_5 ,
		audio_valid_5 	=> rx_audio_valid_5 ,	
		audio_mute_5 	=> rx_audio_mute_5 ,
		audio_data_6 	=> rx_audio_data_6 ,
		audio_valid_6 	=> rx_audio_valid_6 ,	
		audio_mute_6 	=> rx_audio_mute_6 ,
		audio_data_7 	=> rx_audio_data_7 ,
		audio_valid_7 	=> rx_audio_valid_7 ,	
		audio_mute_7 	=> rx_audio_mute_7 ,
		audio_data_8 	=> rx_audio_data_8 ,
		audio_valid_8 	=> rx_audio_valid_8 ,	
		audio_mute_8 	=> rx_audio_mute_8 ,
		audio_data_9 	=> rx_audio_data_9 ,
		audio_valid_9 	=> rx_audio_valid_9 ,	
		audio_mute_9 	=> rx_audio_mute_9 ,
		audio_data_10 	=> rx_audio_data_10 ,	
		audio_valid_10 	=> rx_audio_valid_10,	
		audio_mute_10 	=> rx_audio_mute_10 ,	
		audio_data_11 	=> rx_audio_data_11 ,	
		audio_valid_11 	=> rx_audio_valid_11,	
		audio_mute_11 	=> rx_audio_mute_11 ,	  
		audio_data_12 	=> rx_audio_data_12 ,	
		audio_valid_12 	=> rx_audio_valid_12,	
		audio_mute_12 	=> rx_audio_mute_12 ,	
		audio_data_13 	=> rx_audio_data_13 ,	
		audio_valid_13 	=> rx_audio_valid_13,	
		audio_mute_13 	=> rx_audio_mute_13 ,	
		audio_data_14 	=> rx_audio_data_14 ,	
		audio_valid_14 	=> rx_audio_valid_14,	
		audio_mute_14 	=> rx_audio_mute_14 
	);
end Behavioral;
