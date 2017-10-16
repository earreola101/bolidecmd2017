----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.11.2014 14:59:19
-- Design Name: 
-- Module Name: tdm_receiver - Behavioral
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

entity tdm_receiver is
Port ( 
    clk : in STD_LOGIC;
    rst_n : in STD_LOGIC;
    enable: in STD_LOGIC;
    
    bclk2x : in STD_LOGIC;
    lrclk : in STD_LOGIC;
    din : in STD_LOGIC_VECTOR(3 downto 0);
    
    ch_rx_0  : out STD_LOGIC_VECTOR (23 downto 0);
    ch_rx_1  : out STD_LOGIC_VECTOR (23 downto 0);
    ch_rx_2  : out STD_LOGIC_VECTOR (23 downto 0);
    ch_rx_3  : out STD_LOGIC_VECTOR (23 downto 0)
);
end tdm_receiver;

architecture Behavioral of tdm_receiver is    
    signal bclk_r_0  : std_logic:='0';
    signal bclk_r_1  : std_logic:='0';
    signal lrclk_r_0: std_logic:='0';
    signal lrclk_r_1: std_logic:='0';
    signal bclk_pp  : std_logic:='0';
    signal lrclk_pp : std_logic:='0';
    signal bclk_np  : std_logic:='0';

    
    
    signal data0 : std_logic_vector(127 downto 0):=(others => '0');
    signal din0_r : std_logic;
    
    
    signal ch_rx_0_r   : STD_LOGIC_VECTOR (23 downto 0);
    signal ch_rx_1_r   : STD_LOGIC_VECTOR (23 downto 0);
    signal ch_rx_2_r   : STD_LOGIC_VECTOR (23 downto 0);
    signal ch_rx_3_r   : STD_LOGIC_VECTOR (23 downto 0);
    
begin

    receive_process : process(clk,rst_n)
    begin
        if(rst_n='0') then
            din0_r <= '0';
            lrclk_r_0 <= '0';
            lrclk_r_1 <= '0';
            bclk_r_0 <= '0';
            bclk_r_1 <= '0';
        elsif rising_edge(clk) then
            if(enable='0') then
                din0_r <= '0';
                lrclk_r_0 <= '0';
                lrclk_r_1 <= '0';
                bclk_r_0 <= '0';
                bclk_r_1 <= '0';
            else
                din0_r <= din(0);
                lrclk_r_0 <= lrclk;
                bclk_r_0 <= bclk2x;
                bclk_r_1 <= bclk_r_0;
                bclk_pp <= (NOT bclk_r_1) AND bclk_r_0;
                bclk_np <= (NOT bclk_r_0) AND bclk_r_1;
                ch_rx_0   <=  ch_rx_0_r; 
                ch_rx_1   <=  ch_rx_1_r; 
                ch_rx_2   <=  ch_rx_2_r; 
                ch_rx_3   <=  ch_rx_3_r; 

               if (bclk_np='1') then
                   lrclk_pp <= (NOT lrclk_r_1) AND lrclk_r_0;
  
--                    if (lrclk_pp='1') then
                    if(((NOT lrclk_r_1) AND lrclk_r_0)='1') then
                        ch_rx_0_r <= data0(126 downto 103); 
                        ch_rx_1_r <= data0(94 downto 71);
						ch_rx_2_r <= data0(62 downto 39);
						ch_rx_3_r <= data0(30 downto 7);					
                    end if;
                elsif(bclk_pp='1') then
                    lrclk_r_1 <= lrclk_r_0;
					data0 <= data0(126 downto 0) & din0_r;
                end if;
            end if;
        end if;
    end process;

end Behavioral;
