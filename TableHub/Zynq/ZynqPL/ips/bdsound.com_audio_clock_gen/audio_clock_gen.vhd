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



entity audio_clock_gen is
Generic (
    SHIFT_DIV : integer range 0 to 4 := 0
);
Port ( 
    clk : in STD_LOGIC;
	lock : in STD_LOGIC;
    wclk : out STD_LOGIC;
	bclk  : out STD_LOGIC;
	bclk2x : out STD_LOGIC;
	wclk32 : out STD_LOGIC
    );
end audio_clock_gen;

architecture Behavioral of audio_clock_gen is    
	signal counter: STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
	signal counter_32 : integer := 0;
begin
	process(clk)
	begin
		if rising_edge(clk) then
			counter <= counter + 1;
			
			if(lock='1')then
				bclk2x <= counter(0+SHIFT_DIV);
				bclk <= counter(1+SHIFT_DIV);
				wclk <= counter(7+SHIFT_DIV);
			else
				wclk <= '1';
				bclk <= '1';
				bclk2x <= '1';
			end if;
			if(counter_32 < 639) then
			     counter_32 <= counter_32+1;
			else
			     counter_32 <= 0;
			end if;
			if(counter_32=0)then
			 wclk32 <= '1';
			elsif(counter_32=320)then
			 wclk32 <= '0';
			end if;
		end if;
	end process;
end Behavioral;
