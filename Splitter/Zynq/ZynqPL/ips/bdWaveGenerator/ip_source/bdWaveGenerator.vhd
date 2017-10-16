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



entity bdWaveGenerator is
Generic(
    SHIFT_DIVISOR : integer := 0;
	CHOOSE_SINE : integer range 0 to 1 := 0
    );
Port ( 
    clk : in STD_LOGIC;
    rst_n : in STD_LOGIC;
	enable : in STD_LOGIC;
    lrclk : in STD_LOGIC;
	sineOut  : out STD_LOGIC_VECTOR (23 downto 0)
    );
end bdWaveGenerator;

architecture Behavioral of bdWaveGenerator is    
    signal lrclk_r_1 : std_logic;
    signal lrclk_r_0 : std_logic;
	signal counter : integer;
	signal sineOut_r : std_logic_vector(23 downto 0);
	type   testSineType is array(31 downto 0) of integer;
	constant testSineWave : testSineType := (
        0,
        1309229  ,
        2568145  ,
        3728369   ,
        4745313  ,
        5579898  ,
        6200051  ,
        6581939   ,
        6710886  ,
        6581939  ,
        6200051  ,
        5579898 ,
        4745313  ,
        3728369  ,
        2568145  ,
        1309229  ,
        0        ,
        -1309229 ,
        -2568145 ,
        -3728369 ,
        -4745313 ,
        -5579898 ,
        -6200051 ,
        -6581939 ,
        -6710886 ,
        -6581939 ,
        -6200051 ,
        -5579898 ,
        -4745313 ,
        -3728369 ,
        -2568145 ,
        -1309229

      );
	constant testSineWave2 : testSineType := (	  
           0,
       16365,
       32102,
       46605,
       59316,
       69749,
       77501,
       82274,
       83886,
       82274,
       77501,
       69749,
       59316,
       46605,
       32102,
       16365,
           0,
      -16365,
      -32102,
      -46605,
      -59316,
      -69749,
      -77501,
      -82274,
      -83886,
      -82274,
      -77501,
      -69749,
      -59316,
      -46605,
      -32102,
      -16365 
);
begin
    
    sineOut <= (23 downto 23 - SHIFT_DIVISOR => sineOut_r(23)) & sineOut_r(23-1 downto SHIFT_DIVISOR);
	generate_process : process(clk,rst_n)
	begin
        if(rst_n='0') then
			lrclk_r_0 <= '0';
            lrclk_r_1 <= '0';
            counter <= 0;
            sineOut_r <= (others => '0');
        elsif rising_edge(clk) then
            if(enable='0') then
				lrclk_r_0 <= '0';
				lrclk_r_1 <= '0';
				counter <= 0;
				sineOut_r <= (others => '0');
			else
				lrclk_r_0 <= lrclk;
				lrclk_r_1 <= lrclk_r_0;
				if((lrclk_r_1 = '1') AND (lrclk_r_0 = '0')) then
					if(CHOOSE_SINE = 0) then
						sineOut_r <= std_logic_vector(conv_signed(testSineWave(counter),24));
					else
						sineOut_r <= std_logic_vector(conv_signed(testSineWave2(counter),24));
					end if;
					if(counter >=31) then 
						counter <=0; 
					else 
						counter <= counter +1;     
					end if;
				end if;
	
			end if;
        end if;
	end process;

end Behavioral;
