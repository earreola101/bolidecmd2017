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

entity i2s_receiver is
Generic (
    NUM_BIT : integer := 32
);
Port ( 
    mclk : in STD_LOGIC;
    rst_n : in STD_LOGIC;
    enable: in STD_LOGIC;
    
    i2s_bclk : in STD_LOGIC;
    i2s_lrclk : in STD_LOGIC;
    i2s_data_in : in STD_LOGIC;
	
    ch0  : out STD_LOGIC_VECTOR (23 downto 0);
    ch1  : out STD_LOGIC_VECTOR (23 downto 0)
);
end i2s_receiver;

architecture Behavioral of i2s_receiver is    
	signal bclk_r : std_logic_vector(1 downto 0);    
	signal lrclk_r : std_logic_vector(1 downto 0);
	
	
    signal data00 : std_logic_vector(2*NUM_BIT-1 downto 0):=(others => '0');

	signal din_r : std_logic;

    signal ch00_r  : STD_LOGIC_VECTOR (23 downto 0);
    signal ch01_r  : STD_LOGIC_VECTOR (23 downto 0);
	
	signal cnt     : integer range 0 to 2*NUM_BIT-1;
	signal store     : std_logic;

begin



 
    receive_process : process(mclk,rst_n)
    begin
        if(rst_n='0') then
            ch1  <= (others => '0');
            ch0  <= (others => '0');
            data00 <= (others => '0');
            din_r <= '0';
            lrclk_r <= "00";
            bclk_r <= "00";
			cnt  <= 0;
			store <= '0';
        elsif rising_edge(mclk) then
            if(enable='0') then
                ch1  <= (others => '0');
                ch0  <= (others => '0');
                din_r <= '0';
                lrclk_r <= "00";
                bclk_r <= "00";
                cnt  <= 0;
                store <= '0';
            else
                din_r <= i2s_data_in;

				bclk_r <= bclk_r(0) & i2s_bclk;
				lrclk_r <= lrclk_r(0) & i2s_lrclk;
				
				if(lrclk_r = "10") then 
					store <= '1';
				elsif(bclk_r="01") then
					if(store ='1') then
					   if(NUM_BIT>24) then
                            ch0 <= data00(2*NUM_BIT-1 downto 2*NUM_BIT-24);
                            ch1 <= data00(NUM_BIT-1 downto NUM_BIT-24);
				        else
                            ch0(23 downto 24-NUM_BIT) <= data00(2*NUM_BIT-1 downto NUM_BIT);
                            ch1(23 downto 24-NUM_BIT) <= data00(NUM_BIT-1 downto 0);			        
				        end if;
						store <= '0';	
						cnt <= 2*NUM_BIT-1; 				
					
					else
						data00(cnt)  <= din_r;
						cnt <= cnt-1;
                    end if; -- store

                end if; --bclk_pp
            end if; --enable
        end if; --rst
    end process;

end Behavioral;
