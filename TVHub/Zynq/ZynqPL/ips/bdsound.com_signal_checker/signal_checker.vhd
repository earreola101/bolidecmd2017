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

entity signal_checker is
Generic(
	--constant AUDIO_CHANNELS : integer := 7
	--constant AUDIO_CHANNELS : integer := 11
	constant AUDIO_CHANNELS : integer := 15
);
Port ( 
    clk 			: in STD_LOGIC;
    rst_n 			: in STD_LOGIC;

	error_data		: out STD_LOGIC;
	error_audio		: out STD_LOGIC;
	
	wclk			: in STD_LOGIC := '0';
	
	data_byte_0 	: in STD_LOGIC_VECTOR(7 downto 0) := x"00";
	data_valid_0 	: in STD_LOGIC := '0';
                 
	data_byte_1 	: in STD_LOGIC_VECTOR(7 downto 0) := x"00";
	data_valid_1 	: in STD_LOGIC := '0';
               
	data_byte_2 	: in STD_LOGIC_VECTOR(7 downto 0) := x"00";
	data_valid_2 	: in STD_LOGIC := '0';
          
	audio_data_0 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_valid_0 	: in STD_LOGIC := '0';
	audio_mute_0 	: in STD_LOGIC := '0';
            
	audio_data_1 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_valid_1 	: in STD_LOGIC := '0';
	audio_mute_1 	: in STD_LOGIC := '0';
      
	audio_data_2 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_valid_2 	: in STD_LOGIC := '0';
	audio_mute_2 	: in STD_LOGIC := '0';
    
	audio_data_3 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_valid_3 	: in STD_LOGIC := '0';
	audio_mute_3 	: in STD_LOGIC := '0';
  
	audio_data_4 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_valid_4 	: in STD_LOGIC := '0';
	audio_mute_4 	: in STD_LOGIC := '0';
       
	audio_data_5 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_valid_5 	: in STD_LOGIC := '0';
	audio_mute_5 	: in STD_LOGIC := '0';

	audio_data_6 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_valid_6 	: in STD_LOGIC := '0';
	audio_mute_6 	: in STD_LOGIC := '0';
	
	audio_data_7 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_valid_7 	: in STD_LOGIC := '0';
	audio_mute_7 	: in STD_LOGIC := '0';

	audio_data_8 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_valid_8 	: in STD_LOGIC := '0';
	audio_mute_8 	: in STD_LOGIC := '0';

	audio_data_9 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_valid_9 	: in STD_LOGIC := '0';
	audio_mute_9 	: in STD_LOGIC := '0';

	audio_data_10 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_valid_10 	: in STD_LOGIC := '0';
	audio_mute_10 	: in STD_LOGIC := '0';
	              
	audio_data_11 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_valid_11 	: in STD_LOGIC := '0';
	audio_mute_11 	: in STD_LOGIC := '0';

	audio_data_12 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_valid_12 	: in STD_LOGIC := '0';
	audio_mute_12 	: in STD_LOGIC := '0';

	audio_data_13 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_valid_13 	: in STD_LOGIC := '0';
	audio_mute_13 	: in STD_LOGIC := '0';

	audio_data_14 	: in STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_valid_14 	: in STD_LOGIC := '0';
	audio_mute_14 	: in STD_LOGIC := '0'
	
);
end signal_checker;

architecture Behavioral of signal_checker is    
	type data_array_t is array(2 downto 0) of std_logic_vector(7 downto 0);
	type audio_array_t is array(AUDIO_CHANNELS-1 downto 0) of std_logic_vector(23 downto 0);

	signal wclk_in_r : std_logic_vector(1 downto 0);
	
	
	signal audio_old : audio_array_t;
	signal audio_new : audio_array_t;
	signal data_old : data_array_t;
	signal data_new : data_array_t;
    signal error_data_r: std_logic;
    signal error_audio_r: std_logic;
begin
    error_data <= error_data_r;
    error_audio <= error_audio_r;
	data_process : process(rst_n, clk)
	begin
		if(rst_n='0')then
            wclk_in_r <= "00";
            error_data_r <= '0';
		elsif rising_edge(clk)then
			wclk_in_r <= wclk_in_r(0) & wclk;
			if(wclk_in_r="01")then
			    if(error_data_r='1')then
			        error_data_r <= '0'; 
			    else
                    for I in 0 to 2 loop
                      if(data_new(i)/=data_old(i)+1)then
                        error_data_r <= '1';
                      end if;
                    end loop;
                end if;
                if(error_audio_r='1')then
                    error_audio_r <= '0'; 
                else
                    for I in 0 to AUDIO_CHANNELS-1 loop
                      if(audio_new(i)/=audio_old(i)+1)then
                        error_audio_r <= '1';
                      end if;
                    end loop;
                end if;
                
                for I in 0 to 2 loop
                      data_old(i)<=data_new(i);
                end loop;           
                
                for I in 0 to AUDIO_CHANNELS-1 loop
                      audio_old(i)<=audio_new(i);
                end loop;     
                
			end if;
		end if;
	end process;
    
    data_new(0) <= data_byte_0;
    data_new(1) <= data_byte_1;
    data_new(2) <= data_byte_2;

    audio_new(0) <= audio_data_0;
    audio_new(1) <= audio_data_1;
    audio_new(2) <= audio_data_2;
    audio_new(3) <= audio_data_3;
    audio_new(4) <= audio_data_4;
    audio_new(5) <= audio_data_5;
    audio_new(6) <= audio_data_6;



    GEN_0: if(AUDIO_CHANNELS>7) generate


        audio_new(7) <= audio_data_7;
        audio_new(8) <= audio_data_8;
        audio_new(9) <= audio_data_9;
        audio_new(10) <= audio_data_10;

    end generate GEN_0;

    GEN_1: if(AUDIO_CHANNELS>11) generate
        audio_new(11) <= audio_data_11;
        audio_new(12) <= audio_data_12;
        audio_new(13) <= audio_data_13;
        audio_new(14) <= audio_data_14;
    end generate GEN_1;    
    
end Behavioral;
