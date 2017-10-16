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

entity wclk_generator is
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
end wclk_generator;

architecture Behavioral of wclk_generator is    
    signal reference_count : std_logic_vector(31 downto 0);
    signal reference_count_r : std_logic_vector(31 downto 0);
    constant COUNT_MAX : integer := (MCLK_FREQUENCY/WCLK_FREQUENCY)+(MCLK_FREQUENCY/(100*WCLK_FREQUENCY));
    constant COUNT_MIN : integer := (MCLK_FREQUENCY/WCLK_FREQUENCY)-(MCLK_FREQUENCY/(100*WCLK_FREQUENCY));
        
    signal wclk_out_r : std_logic := '0';
    signal out_counter : integer := 0;
    
    signal ref_counter : integer := 0;
    signal ref_counted : integer := 0;
    signal ref_counter_eval : std_logic := '0';
    signal wclk_ref_r : std_logic_vector(1 downto 0);
begin
    sample_process : process(mclk, rst_n)
    begin
        if(rst_n= '0')then
            ref_counter <= 0;
            wclk_ref_r <= "00";
            ref_counter_eval <= '0';
            ref_counted <= 0;
        elsif rising_edge(mclk) then
            wclk_ref_r <= wclk_ref_r(0) & wclk_ref;
            if(wclk_ref_r="01")then
                ref_counted <= ref_counter;
                ref_counter <= 0;
                ref_counter_eval <= '1';
            else
                if(ref_counter>COUNT_MAX)then
                    ref_counted <= ref_counter;
                    ref_counter <= 0;
                    ref_counter_eval <= '1';
                else
                    ref_counter <= ref_counter +1;
                    ref_counter_eval <= '0';
                end if;
            end if;
        end if;
    end process;
    
    eval_process : process(mclk, rst_n)
    begin
        if(rst_n= '0')then    
            wclk_ref_locked <= '0';
            reference_count <= std_logic_vector(to_unsigned(MCLK_FREQUENCY/WCLK_FREQUENCY, reference_count'length));
        elsif rising_edge(mclk) then  
            if(ref_counter_eval='1') then
                if((ref_counted<COUNT_MAX)AND(ref_counted>COUNT_MIN))then
                    reference_count <= std_logic_vector(to_unsigned(ref_counted, reference_count'length));
                    wclk_ref_locked <= '1';
                else
                    wclk_ref_locked <= '0';
                end if;
            end if;
        end if;
    end process;
    
    out_process : process(mclk, rst_n)
    begin
        if(rst_n= '0')then
            reference_count_r <= std_logic_vector(to_unsigned(MCLK_FREQUENCY/WCLK_FREQUENCY, reference_count_r'length));--reference_count;
            out_counter <= 0;
            wclk_out_r <= '0';
        elsif rising_edge(mclk) then
            if(out_counter < reference_count_r) then  
                out_counter <= out_counter +1;
            else
                out_counter <= 0;
                reference_count_r <= reference_count;                
            end if;
            
            if(out_counter = 0) then               
                wclk_out_r <= '0';
            elsif(out_counter = reference_count_r(31 downto 1))then
                wclk_out_r <= '1';
            end if;
        end if;    
    end process;
    wclk_out <= wclk_out_r;

end Behavioral;
