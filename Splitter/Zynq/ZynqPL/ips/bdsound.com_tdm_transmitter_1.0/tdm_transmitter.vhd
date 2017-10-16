----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.11.2014 14:02:04
-- Design Name: 
-- Module Name: bdi2sTdmTrasmitter - Behavioral
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

entity tdm_transmitter is
    Port( 
			clk : in STD_LOGIC;
			rst_n : in STD_LOGIC;
			enable: in STD_LOGIC;

			bclk2x : in STD_LOGIC;
			lrclk : in STD_LOGIC;
			dout : out STD_LOGIC_VECTOR(3 downto 0);


			ch_tx_0  : in STD_LOGIC_VECTOR (23 downto 0);
			ch_tx_1  : in STD_LOGIC_VECTOR (23 downto 0);
			ch_tx_2  : in STD_LOGIC_VECTOR (23 downto 0);
			ch_tx_3  : in STD_LOGIC_VECTOR (23 downto 0);
			ch_tx_4  : in STD_LOGIC_VECTOR (23 downto 0);
			ch_tx_5  : in STD_LOGIC_VECTOR (23 downto 0);
			ch_tx_6  : in STD_LOGIC_VECTOR (23 downto 0);
			ch_tx_7  : in STD_LOGIC_VECTOR (23 downto 0);
			ch_tx_8  : in STD_LOGIC_VECTOR (23 downto 0);
			ch_tx_9  : in STD_LOGIC_VECTOR (23 downto 0);
			ch_tx_10  : in STD_LOGIC_VECTOR (23 downto 0);
			ch_tx_11  : in STD_LOGIC_VECTOR (23 downto 0);
			ch_tx_12  : in STD_LOGIC_VECTOR (23 downto 0);
			ch_tx_13  : in STD_LOGIC_VECTOR (23 downto 0);
			ch_tx_14  : in STD_LOGIC_VECTOR (23 downto 0);
			ch_tx_15  : in STD_LOGIC_VECTOR (23 downto 0)
			);
end tdm_transmitter;


architecture Behavioral of tdm_transmitter is
    signal bclk_r_0  : std_logic:='0';
    signal bclk_r_1  : std_logic:='0';
    signal lrclk_r_0: std_logic:='0';
    signal lrclk_r_1: std_logic:='0';
    signal bclk_pp  : std_logic:='0';
    signal lrclk_pp : std_logic:='0';
    signal bclk_np  : std_logic:='0';
    signal lrclk_np : std_logic:='0';

    signal data0 : std_logic_vector (119 downto 0):=(others => '0'); 
    signal data1 : std_logic_vector (119 downto 0):=(others => '0'); 
    signal data2 : std_logic_vector (119 downto 0):=(others => '0'); 
    signal data3 : std_logic_vector (119 downto 0):=(others => '0'); 
	
	begin
	



    dout(0) <= data0(119);
    dout(1) <= data1(119);
    dout(2) <= data2(119);
    dout(3) <= data3(119);
    sync_process: process(clk, rst_n)
    begin 
      if (rst_n = '0') then
            data0   <= (others=>'0');
            data1   <= (others=>'0');
            data2   <= (others=>'0');
            data3   <= (others=>'0');

            lrclk_r_0 <= '0';
            lrclk_r_1 <= '0';
            bclk_r_0 <= '0';
            bclk_r_1 <= '0';
      elsif rising_edge(clk) then
            if (enable='0') then
				data0   <= (others=>'0');
				data1   <= (others=>'0');
				data2   <= (others=>'0');
				data3   <= (others=>'0');
                lrclk_r_0 <= '0';
                lrclk_r_1 <= '0';
                bclk_r_0 <= '0';
                bclk_r_1 <= '0';
            else

				
                lrclk_r_0 <= lrclk;
                bclk_r_0 <= bclk2x;
                bclk_r_1 <= bclk_r_0;
                bclk_pp <= (NOT bclk_r_1) AND bclk_r_0;
                bclk_np <= (NOT bclk_r_0) AND bclk_r_1;
                if (bclk_np='1') then
                    lrclk_pp <= (NOT lrclk_r_1) AND lrclk_r_0;
                    lrclk_np <= (NOT lrclk_r_0) AND lrclk_r_1;


                   -- if (lrclk_pp='1') then
                    if (((NOT lrclk_r_1) AND lrclk_r_0)='1') then
                        data0 <= ch_tx_0 & x"00" & ch_tx_1 & x"00" & ch_tx_2 & x"00" & ch_tx_3;
                        data1 <= ch_tx_4 & x"00" & ch_tx_5 & x"00" & ch_tx_6 & x"00" & ch_tx_7;
                        data2 <= ch_tx_8 & x"00" & ch_tx_9 & x"00" & ch_tx_10 & x"00" & ch_tx_11;
                        data3 <= ch_tx_12 & x"00" & ch_tx_13 & x"00" & ch_tx_14 & x"00" & ch_tx_15;
                    else
                        data0 <= data0(118 downto 0) & '0';
                        data1 <= data1(118 downto 0) & '0';
                        data2 <= data2(118 downto 0) & '0';
                        data3 <= data3(118 downto 0) & '0';
                    end if;
                elsif(bclk_pp='1') then
                    lrclk_r_1 <= lrclk_r_0;
                end if;
            end if;
        end if;
  end process;

end Behavioral;