----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.08.2017
-- Design Name: 
-- Module Name: wclk_generator - Behavioral
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

entity wclk_generator_tb is

end wclk_generator_tb;

architecture Behavioral of wclk_generator_tb is    
	component wclk_generator is
	Generic(

		constant MCLK_FREQUENCY : integer := 100000000;
		constant WCLK_FREQUENCY	: integer := 32000
	);
	Port ( 
		mclk 			: in STD_LOGIC;
		rst_n			: in STD_LOGIC;
		wclk_ref		: in STD_LOGIC;
		wclk_out		: out STD_LOGIC;
        wclk_ref_locked : out STD_LOGIC
	);
	end component;
	constant MCLK_FREQUENCY : integer := 100000000;
	constant WCLK_FREQUENCY_GEN : integer := 32100;
	constant WCLK_FREQUENCY_WANT : integer := 32000;
        
    signal mclk : std_logic;
    signal rst_n : std_logic;
    signal wclk_ref : std_logic;
    signal wclk_ref_in : std_logic;
	
    signal wclk_out : std_logic;
    signal wclk_ref_locked : std_logic;        
    
    constant mclk_period : time := 1000 ms / real(MCLK_FREQUENCY);
    constant wclk_period : time := 1000 ms / real(WCLK_FREQUENCY_GEN);
	
	signal switch_ref : std_logic;
begin
    mclk_process : process
    begin
        mclk_loop : loop
            mclk <= '0';
            wait for mclk_period/2;
            mclk <= '1';
            wait for mclk_period/2;
        end loop mclk_loop;
    end process;
    
    wclk_process : process
    begin
        wclk_loop : loop
            wclk_ref <= '0';
            wait for wclk_period/2;
            wclk_ref <= '1';
            wait for wclk_period/2;
        end loop wclk_loop;
    end process;
    
	uut: wclk_generator 
	generic map (
		MCLK_FREQUENCY => MCLK_FREQUENCY,
		WCLK_FREQUENCY => WCLK_FREQUENCY_WANT
	)
	port map
	( 
		mclk 					=> mclk,       
		rst_n 					=> rst_n, 
		wclk_ref				=> wclk_ref_in,
		wclk_out 			    => wclk_out,
		wclk_ref_locked         => wclk_ref_locked
	);
	wclk_ref_in <= wclk_ref when switch_ref ='1' else '0';
	tb : process
    begin
        rst_n <= '0';
		switch_ref <= '0';
        wait for 100 ns;
        rst_n <= '1';
        wait for 100 ns;
        
        wait for 100  ms;
			switch_ref <= '1';

        wait;
    end process;	
end Behavioral;
