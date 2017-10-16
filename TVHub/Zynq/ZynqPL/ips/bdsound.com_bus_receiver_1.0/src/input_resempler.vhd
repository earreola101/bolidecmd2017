----------------------------------------------------------------------------------
-- Engineer: Mike Field <hamster@snap.net.nz>
-- 
-- Description: This is the input sampling stage for the high speed serial link
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_arith.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
Library UNISIM;
use UNISIM.vcomponents.all;


entity input_resempler is
    Port ( 
		clk       			: in  STD_LOGIC;
        rst_n 				: in STD_LOGIC;
        data_in_resampled 	: out STD_LOGIC_VECTOR(4 downto 0);
        data_in_valid 		: out STD_LOGIC;
        data_in_oversampled : in  STD_LOGIC_VECTOR (3 downto 0)
    );
end input_resempler;

architecture Behavioral of input_resempler is
    type edges_count_t is array (3 downto 0) of std_logic_vector(7 downto 0);
    
    
    -- time 0
    signal data_in_oversampled_buffer_0 : std_logic_vector(27 downto 0);
    signal data_in_oversampled_0_n : std_logic_vector(3 downto 0);
    
    -- time 1
    signal data_in_oversampled_buffer_1 : std_logic_vector(27 downto 0);
    signal edges_1 : std_logic_vector(3 downto 0);
    
    -- time 2
    signal data_in_oversampled_buffer_2 : std_logic_vector(27 downto 0);
    signal edges_count_2 : edges_count_t;
    
    -- time 3
    signal data_in_oversampled_buffer_3 : std_logic_vector(27 downto 0);
    signal index_max_3 : integer range 0 to 3;
    
    -- time 4
    signal count_bit_4 : std_logic_vector (2 downto 0);
    signal index_max_4_old : integer range 0 to 3;
    
begin
    -- time 0
    buffer_oversamples : process(clk, rst_n)
    begin
        if(rst_n='0') then
            data_in_oversampled_buffer_0 <= (others => '0');
        elsif rising_edge(clk) then
            data_in_oversampled_buffer_0 <= data_in_oversampled_buffer_0(23 downto 0) & data_in_oversampled;
        end if;
    end process;
    data_in_oversampled_0_n <= not data_in_oversampled_buffer_0(4 downto 1);

    --time 1
    edges_process : process(clk,rst_n)
    begin
        if (rst_n = '0') then
            data_in_oversampled_buffer_1 <= (others => '0');
            edges_1 <= (others => '0');
        elsif rising_edge(clk) then
            data_in_oversampled_buffer_1 <= data_in_oversampled_buffer_0; 
            edges_1 <= (data_in_oversampled_buffer_0(3 downto 0) AND data_in_oversampled_0_n) OR ((NOT data_in_oversampled_buffer_0(3 downto 0))AND(NOT data_in_oversampled_0_n));
        end if;
    end process;
    
    --time 2
    counter_process : process(clk,rst_n)
    begin
        if(rst_n='0') then
            edges_count_2 <= (others => (others => '0'));
            data_in_oversampled_buffer_2 <= (others => '0');
        elsif rising_edge(clk) then
            data_in_oversampled_buffer_2 <= data_in_oversampled_buffer_1;
            for I in 3 downto 0 loop
                if(edges_1(I)='1') then
                    if(edges_count_2(I)< x"7C")then
                        edges_count_2(I) <= edges_count_2(I)+4;
                    end if;
                else
                    if(edges_count_2(I)/= x"0")then
                        edges_count_2(I) <= edges_count_2(I)-1;
                    end if;     
                end if;
            end loop;
        end if;
    end process;
    
    --time 3
    index_max_process : process(clk,rst_n)
    begin
        if(rst_n='0') then
            index_max_3 <= 0;
            data_in_oversampled_buffer_3 <= (others => '0');
        elsif rising_edge(clk) then
            data_in_oversampled_buffer_3 <= data_in_oversampled_buffer_2;
            if(edges_count_2(0)>edges_count_2(1)) then
                if(edges_count_2(0)>edges_count_2(2)) then
                    if(edges_count_2(0)>edges_count_2(3)) then
                        index_max_3 <= 0;
                    else
                        index_max_3 <= 3;
                    end if;
                else
                    if(edges_count_2(2)>edges_count_2(3)) then
                        index_max_3 <= 2;
                    else
                        index_max_3 <= 3;
                    end if;
                end if;
             else
                 if(edges_count_2(1)>edges_count_2(2)) then
                     if(edges_count_2(1)>edges_count_2(3)) then
                         index_max_3 <= 1;
                     else
                         index_max_3 <= 3;
                     end if;
                 else
                     if(edges_count_2(2)>edges_count_2(3)) then
                         index_max_3 <= 2;
                     else
                         index_max_3 <= 3;
                     end if;
                 end if;            
             end if;
        end if;    
    end process;
    
    -- time 4
    resampler_process : process(clk,rst_n)
    begin
        if(rst_n='0')then
            count_bit_4 <= (others => '0');
            data_in_resampled <= (others => '0');
            data_in_valid <= '0';
            index_max_4_old <= 0;
        elsif rising_edge(clk) then
            if(count_bit_4="000") then
                
                data_in_valid <= '1';
                index_max_4_old <= index_max_3;
                if((index_max_4_old=0)AND(index_max_3=3))then
                    count_bit_4 <= "101";
                elsif((index_max_4_old=3)AND(index_max_3=0))then
                    count_bit_4 <= "011";
                else
                    count_bit_4 <= "100";
                end if;
                data_in_resampled(0) <= data_in_oversampled_buffer_3(index_max_4_old+3);
                data_in_resampled(1) <= data_in_oversampled_buffer_3(index_max_4_old+7);
                data_in_resampled(2) <= data_in_oversampled_buffer_3(index_max_4_old+11);
                data_in_resampled(3) <= data_in_oversampled_buffer_3(index_max_4_old+15);
                data_in_resampled(4) <= data_in_oversampled_buffer_3(index_max_4_old+19);
            else
                data_in_valid <= '0'; 
                count_bit_4 <= count_bit_4 - 1;
            end if;          
        end if;
    end process;
end Behavioral;
