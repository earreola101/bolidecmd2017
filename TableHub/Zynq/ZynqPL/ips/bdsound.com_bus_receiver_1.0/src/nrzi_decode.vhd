----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:28:05 10/28/2014 
-- Design Name: 
-- Module Name:    nrzi_decode - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity nrzi_decode is
	Port(
		clk: in std_logic;
		rst_n: in std_logic;
		trig: in std_logic;
		word_5B_nrzi: in std_logic_vector (4 downto 0);
		word_5B_binary: out std_logic_vector (4 downto 0)
	);
end nrzi_decode;

architecture Behavioral of nrzi_decode is
	signal new_word_5B_nrzi: std_logic_vector(4 downto 0):="00000";
	signal old_bit: std_logic:='0';
	signal word_5B_binary_r: std_logic_vector (4 downto 0):="00000";
	signal trig_r : std_logic:='0';
	
begin
	
	p1: process(clk, rst_n)
	begin
		if rst_n='0' then
			new_word_5B_nrzi <= (others =>'0');
			word_5B_binary_r <= (others =>'0');
			trig_r <= '0';	 			
			old_bit <= '0'	;
		elsif rising_edge(clk) then
			trig_r <= trig; 
			if (trig_r ='0' and trig='1') then 
				word_5B_binary <= word_5B_binary_r; 
				new_word_5B_nrzi <= word_5B_nrzi; 
				old_bit <= new_word_5B_nrzi(0);
				
				if(new_word_5B_nrzi(4)/= old_bit) then
					word_5B_binary_r(4)<= '1';
				else 
					word_5B_binary_r(4) <= '0';
				end if;
				
				for I in 3 downto 0 loop
					if(new_word_5B_nrzi(I)/= new_word_5B_nrzi(I+1)) then
						word_5B_binary_r(I)<= '1';
					else 
						word_5B_binary_r(I) <= '0';
					end if;
				end loop;
				
			end if;
		end if;
	end process p1;
	
end Behavioral;