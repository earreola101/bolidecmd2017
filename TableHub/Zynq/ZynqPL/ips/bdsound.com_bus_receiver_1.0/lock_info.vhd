----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:58:51 04/05/2010 
-- Design Name: 
-- Module Name:    bdWclkAnalyzer - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity lock_info is
	generic(
		constant AUDIO_CHANNELS : integer := 15 
	);
    port (
		mclk:     		in  std_logic; --100M clk
		rst_n: 			in	std_logic;
		wclk_in: 	  		in 	std_logic; --low frequency clk		
		wclk_lock : 	out std_logic
		);
end lock_info;


architecture Behavioral of lock_info is
	constant MAX_15_COUNT    : std_logic_vector(11 downto 0) := x"28A";
	constant MIN_15_COUNT : std_logic_vector(11 downto 0) := x"276";

	constant MAX_11_COUNT    : std_logic_vector(11 downto 0) := x"1EA";
	constant MIN_11_COUNT : std_logic_vector(11 downto 0) := x"1D6";

	constant MAX_7_COUNT    : std_logic_vector(11 downto 0) := x"145";
	constant MIN_7_COUNT : std_logic_vector(11 downto 0) := x"13B";
	
	signal MAX_COUNT : std_logic_vector(11 downto 0);
	signal MIN_COUNT : std_logic_vector(11 downto 0);

	signal counter : std_logic_vector(11 downto 0);
	signal counter_overflow : std_logic;
	signal wclk_in_r : std_logic_vector(1 downto 0);

	signal counter_lock: std_logic_vector(3 downto 0);
	signal wclk_detected: std_logic;
	signal counter_ok : std_logic;
	signal wclk_up : std_logic;
    signal wclk_rst : std_logic;
begin
    wclk_lock <= wclk_detected AND counter_ok;

	
	GEN15 : if(AUDIO_CHANNELS=15)generate
		MAX_COUNT <= MAX_15_COUNT;
		MIN_COUNT <= MIN_15_COUNT;
	end generate GEN15;

	GEN11 : if(AUDIO_CHANNELS=11)generate
		MAX_COUNT <= MAX_11_COUNT;
		MIN_COUNT <= MIN_11_COUNT;
	end generate GEN11;

	GEN7 : if(AUDIO_CHANNELS=7)generate
		MAX_COUNT <= MAX_7_COUNT;
		MIN_COUNT <= MIN_7_COUNT;
	end generate GEN7;

	process(mclk, rst_n)
	begin
		if(rst_n='0') then
			counter <= (others => '0');
			counter_overflow <= '0';	
			wclk_in_r <= "00";

			wclk_detected <= '0';
			counter_lock <= "0000";
			counter_ok <= '0';
			wclk_up <= '0';
			wclk_rst <= '0';
		elsif rising_edge(mclk) then
			wclk_in_r <= wclk_in_r(0) & wclk_in;

			if(wclk_up='1')then
			     if(counter_lock="1111")then
			        counter_ok <= '1';
			     else
			        counter_lock <=  counter_lock +1;
			     end if;
			elsif(wclk_rst='1')then
			     counter_ok <= '0';
			     counter_lock <= "0000";
			end if;
			if(wclk_in_r = "01") then
				counter <= (others => '0');
				counter_overflow <= '0';
				if(counter_overflow='0') then
					if((counter>MIN_COUNT)AND(counter<MAX_COUNT)) then
						wclk_detected <= '1';
						wclk_up <= '1';
					else
						wclk_detected <= '0';
						wclk_rst <= '1';
					end if;
				else
					wclk_detected <= '0';
					wclk_rst <= '1';
				end if;
			else
			    wclk_up <= '0';
				if(counter < MAX_COUNT) then
					counter <= counter +1;
					wclk_rst <= '0';
				else
				    wclk_rst <= '1';
					wclk_detected <= '0';
					counter_overflow <= '1';
				end if;
			end if;
			
		end if;
	end process;

end Behavioral;
