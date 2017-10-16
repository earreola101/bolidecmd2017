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

entity delay is
Generic (
    DELAY_COUNTER : integer range 0 to 1000000000 := 1024;
	RST_VAL : std_logic := '0'
);
Port ( 
    mclk : in STD_LOGIC;
    rst_n : in STD_LOGIC;
	signal_in : in STD_LOGIC;
	signal_out : out STD_LOGIC
);
end delay;

architecture Behavioral of delay is    
	signal counter : integer;

begin

    main_process : process(mclk,rst_n)
    begin
        if(rst_n='0') then
			counter <= 0;
			signal_out <= RST_VAL;
        elsif rising_edge(mclk) then
			if(signal_in=RST_VAL)then
				signal_out <= RST_VAL;
				counter <= 0;
			else
				if(counter<DELAY_COUNTER)then
					counter <= counter +1;
				else
					signal_out <= signal_in;
				end if;
			end if;
		end if;
    end process;

end Behavioral;
