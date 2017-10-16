----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 17.12.2013 14:02:04
-- Design Name: 
-- Module Name: bdI2sTransmitter - Behavioral
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

entity i2s_transmitter is
    Generic (
        NUM_I2S_STREAM  : integer := 1
    );
    Port ( 
        clk : in STD_LOGIC;
        rst_n : in STD_LOGIC;
		enable: in STD_LOGIC;
        
        i2s_bclk : in STD_LOGIC;
        i2s_lrclk : in STD_LOGIC;
		i2s_data_out : out STD_LOGIC_VECTOR(NUM_I2S_STREAM -1 downto 0);
		
		ch0  : in STD_LOGIC_VECTOR (23 downto 0) := x"000000";
		ch1  : in STD_LOGIC_VECTOR (23 downto 0) := x"000000";
		ch2  : in STD_LOGIC_VECTOR (23 downto 0) := x"000000";
		ch3  : in STD_LOGIC_VECTOR (23 downto 0) := x"000000";
		ch4  : in STD_LOGIC_VECTOR (23 downto 0) := x"000000";
		ch5  : in STD_LOGIC_VECTOR (23 downto 0) := x"000000";
		ch6  : in STD_LOGIC_VECTOR (23 downto 0) := x"000000";
		ch7  : in STD_LOGIC_VECTOR (23 downto 0) := x"000000";
		ch8  : in STD_LOGIC_VECTOR (23 downto 0) := x"000000";
		ch9  : in STD_LOGIC_VECTOR (23 downto 0) := x"000000";
		ch10  : in STD_LOGIC_VECTOR (23 downto 0) := x"000000";
		ch11  : in STD_LOGIC_VECTOR (23 downto 0) := x"000000";
		ch12  : in STD_LOGIC_VECTOR (23 downto 0) := x"000000";
		ch13  : in STD_LOGIC_VECTOR (23 downto 0) := x"000000";
		ch14  : in STD_LOGIC_VECTOR (23 downto 0) := x"000000";
		ch15  : in STD_LOGIC_VECTOR (23 downto 0) := x"000000";
		ch16  : in STD_LOGIC_VECTOR (23 downto 0) := x"000000";
		ch17  : in STD_LOGIC_VECTOR (23 downto 0) := x"000000";
		ch18  : in STD_LOGIC_VECTOR (23 downto 0) := x"000000";
		ch19  : in STD_LOGIC_VECTOR (23 downto 0) := x"000000";
		ch20  : in STD_LOGIC_VECTOR (23 downto 0) := x"000000";
		ch21  : in STD_LOGIC_VECTOR (23 downto 0) := x"000000";
		ch22  : in STD_LOGIC_VECTOR (23 downto 0) := x"000000";
		ch23  : in STD_LOGIC_VECTOR (23 downto 0) := x"000000";
		ch24  : in STD_LOGIC_VECTOR (23 downto 0) := x"000000";
		ch25  : in STD_LOGIC_VECTOR (23 downto 0) := x"000000";
		ch26  : in STD_LOGIC_VECTOR (23 downto 0) := x"000000";
		ch27  : in STD_LOGIC_VECTOR (23 downto 0) := x"000000";
		ch28  : in STD_LOGIC_VECTOR (23 downto 0) := x"000000";
		ch29  : in STD_LOGIC_VECTOR (23 downto 0) := x"000000";
		ch30  : in STD_LOGIC_VECTOR (23 downto 0) := x"000000";
		ch31  : in STD_LOGIC_VECTOR (23 downto 0) := x"000000"
    );
end i2s_transmitter;


architecture Behavioral of i2s_transmitter is
    signal bclk_r_0  : std_logic:='0';
    signal bclk_r_1  : std_logic:='0';
    signal lrclk_r_0: std_logic:='0';
    signal lrclk_r_1: std_logic:='0';
    signal bclk_pp  : std_logic:='0';
    signal lrclk_pp : std_logic:='0';
    signal bclk_np  : std_logic:='0';
    signal lrclk_np : std_logic:='0';

		
	signal data_out_00_r : std_logic_vector(23 downto 0):=(others => '0');
    signal data_out_01_r : std_logic_vector(23 downto 0):=(others => '0');
	signal data_out_02_r : std_logic_vector(23 downto 0):=(others => '0');
    signal data_out_03_r : std_logic_vector(23 downto 0):=(others => '0');
	signal data_out_04_r : std_logic_vector(23 downto 0):=(others => '0');
    signal data_out_05_r : std_logic_vector(23 downto 0):=(others => '0');
	signal data_out_06_r : std_logic_vector(23 downto 0):=(others => '0');
    signal data_out_07_r : std_logic_vector(23 downto 0):=(others => '0');
	signal data_out_08_r : std_logic_vector(23 downto 0):=(others => '0');
    signal data_out_09_r : std_logic_vector(23 downto 0):=(others => '0');
	signal data_out_10_r : std_logic_vector(23 downto 0):=(others => '0');
    signal data_out_11_r : std_logic_vector(23 downto 0):=(others => '0');
	signal data_out_12_r : std_logic_vector(23 downto 0):=(others => '0');
    signal data_out_13_r : std_logic_vector(23 downto 0):=(others => '0');
	signal data_out_14_r : std_logic_vector(23 downto 0):=(others => '0');
    signal data_out_15_r : std_logic_vector(23 downto 0):=(others => '0');	
	

begin
	
	i2s_data_out(0) <= data_out_00_r(23);
	
    INST_1 : if NUM_I2S_STREAM > 1 generate
    begin
        i2s_data_out(1) <= data_out_01_r(23);
    end generate INST_1; 
    
    INST_2 : if NUM_I2S_STREAM > 2 generate
    begin
        i2s_data_out(2) <= data_out_02_r(23);
    end generate INST_2; 
 	
    INST_3 : if NUM_I2S_STREAM > 3 generate
    begin
        i2s_data_out(3) <= data_out_03_r(23);
    end generate INST_3; 
    
    INST_4 : if NUM_I2S_STREAM > 4 generate
    begin
        i2s_data_out(4) <= data_out_04_r(23);
    end generate INST_4;    
 	
    INST_5 : if NUM_I2S_STREAM > 5 generate
    begin
        i2s_data_out(5) <= data_out_05_r(23);
    end generate INST_5; 
    
    INST_6 : if NUM_I2S_STREAM > 6 generate
    begin
        i2s_data_out(6) <= data_out_06_r(23);
    end generate INST_6; 
     
    INST_7 : if NUM_I2S_STREAM > 7 generate
    begin
        i2s_data_out(7) <= data_out_07_r(23);
    end generate INST_7; 
    
    INST_8 : if NUM_I2S_STREAM > 8 generate
    begin
        i2s_data_out(8) <= data_out_08_r(23);
    end generate INST_8;    
    	
    INST_9 : if NUM_I2S_STREAM > 9 generate
    begin
        i2s_data_out(9) <= data_out_09_r(23);
    end generate INST_9; 
    
    INST_10 : if NUM_I2S_STREAM > 10 generate
    begin
        i2s_data_out(10) <= data_out_10_r(23);
    end generate INST_10; 
     
    INST_11 : if NUM_I2S_STREAM > 11 generate
    begin
        i2s_data_out(11) <= data_out_11_r(23);
    end generate INST_11; 
    
    INST_12 : if NUM_I2S_STREAM > 12 generate
    begin
        i2s_data_out(12) <= data_out_12_r(23);
    end generate INST_12;    
    	
    INST_13 : if NUM_I2S_STREAM > 13 generate
    begin
        i2s_data_out(13) <= data_out_13_r(23);
    end generate INST_13; 
    
    INST_14 : if NUM_I2S_STREAM > 14 generate
    begin
        i2s_data_out(14) <= data_out_14_r(23);
    end generate INST_14; 
     
    INST_15 : if NUM_I2S_STREAM > 15 generate
    begin
        i2s_data_out(15) <= data_out_15_r(23);
    end generate INST_15; 
    
        
    sync_process: process(clk, rst_n)
    begin 
      if (rst_n = '0') then
            data_out_00_r   <= (others=>'0');
            data_out_01_r   <= (others=>'0');
            data_out_02_r   <= (others=>'0');
            data_out_03_r   <= (others=>'0');
            data_out_04_r   <= (others=>'0');
            data_out_05_r   <= (others=>'0');
            data_out_06_r   <= (others=>'0');
            data_out_07_r   <= (others=>'0');
            data_out_08_r   <= (others=>'0');
            data_out_09_r   <= (others=>'0');
            data_out_10_r   <= (others=>'0');
            data_out_11_r   <= (others=>'0');
            data_out_12_r   <= (others=>'0');
            data_out_13_r   <= (others=>'0');
            data_out_14_r   <= (others=>'0');
            data_out_15_r   <= (others=>'0');

            lrclk_r_0 <= '0';
            lrclk_r_1 <= '0';
            bclk_r_0 <= '0';
            bclk_r_1 <= '0';
      elsif rising_edge(clk) then
            if (enable='0') then
				data_out_00_r   <= (others=>'0');
				data_out_01_r   <= (others=>'0');
				data_out_02_r   <= (others=>'0');
				data_out_03_r   <= (others=>'0');
				data_out_04_r   <= (others=>'0');
				data_out_05_r   <= (others=>'0');
				data_out_06_r   <= (others=>'0');
				data_out_07_r   <= (others=>'0');
				data_out_08_r   <= (others=>'0');
				data_out_09_r   <= (others=>'0');
				data_out_10_r   <= (others=>'0');
				data_out_11_r   <= (others=>'0');
				data_out_12_r   <= (others=>'0');
				data_out_13_r   <= (others=>'0');
				data_out_14_r   <= (others=>'0');
				data_out_15_r   <= (others=>'0');

                lrclk_r_0 <= '0';
                lrclk_r_1 <= '0';
                bclk_r_0 <= '0';
                bclk_r_1 <= '0';
            else
                lrclk_r_0 <= i2s_lrclk;
                bclk_r_0 <= i2s_bclk;
                bclk_r_1 <= bclk_r_0;
                bclk_pp <= (NOT bclk_r_1) AND bclk_r_0;
                bclk_np <= (NOT bclk_r_0) AND bclk_r_1;
                if (bclk_np='1') then
                    lrclk_pp <= (NOT lrclk_r_1) AND lrclk_r_0;
                    lrclk_np <= (NOT lrclk_r_0) AND lrclk_r_1;
                    if (lrclk_pp='1') then
                        data_out_00_r <= ch1;
                        data_out_01_r <= ch3;
                        data_out_02_r <= ch5;
                        data_out_03_r <= ch7;
                        data_out_04_r <= ch9;
                        data_out_05_r <= ch11;
                        data_out_06_r <= ch13;
                        data_out_07_r <= ch15;
                        data_out_08_r <= ch17;
                        data_out_09_r <= ch19;
                        data_out_10_r <= ch21;
                        data_out_11_r <= ch23;
                        data_out_12_r <= ch25;
                        data_out_13_r <= ch27;
                        data_out_14_r <= ch29;
                        data_out_15_r <= ch31;
										
          
                    elsif (lrclk_np='1') then
                        data_out_00_r <= ch0;
                        data_out_01_r <= ch2;
                        data_out_02_r <= ch4;
                        data_out_03_r <= ch6;
                        data_out_04_r <= ch8;
                        data_out_05_r <= ch10;
                        data_out_06_r <= ch12;
                        data_out_07_r <= ch14;
                        data_out_08_r <= ch16;
                        data_out_09_r <= ch18;
                        data_out_10_r <= ch20;
                        data_out_11_r <= ch22;
                        data_out_12_r <= ch24;
                        data_out_13_r <= ch26;
                        data_out_14_r <= ch28;
                        data_out_15_r <= ch30;     
                    else
                        data_out_00_r <= data_out_00_r(22 downto 0) & '0';
                        data_out_01_r <= data_out_01_r(22 downto 0) & '0';
                        data_out_02_r <= data_out_02_r(22 downto 0) & '0';
                        data_out_03_r <= data_out_03_r(22 downto 0) & '0';
                        data_out_04_r <= data_out_04_r(22 downto 0) & '0';
                        data_out_05_r <= data_out_05_r(22 downto 0) & '0';
                        data_out_06_r <= data_out_06_r(22 downto 0) & '0';
                        data_out_07_r <= data_out_07_r(22 downto 0) & '0';
                        data_out_08_r <= data_out_08_r(22 downto 0) & '0';
                        data_out_09_r <= data_out_09_r(22 downto 0) & '0';
                        data_out_10_r <= data_out_10_r(22 downto 0) & '0';
                        data_out_11_r <= data_out_11_r(22 downto 0) & '0';
                        data_out_12_r <= data_out_12_r(22 downto 0) & '0';
                        data_out_13_r <= data_out_13_r(22 downto 0) & '0';
                        data_out_14_r <= data_out_14_r(22 downto 0) & '0';
                        data_out_15_r <= data_out_15_r(22 downto 0) & '0';
						
                    end if;
                elsif(bclk_pp='1') then
                    lrclk_r_1 <= lrclk_r_0;
                end if;
            end if;
        end if;
  end process;

end Behavioral;