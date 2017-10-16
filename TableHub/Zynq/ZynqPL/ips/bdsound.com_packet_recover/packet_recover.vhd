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

entity packet_recover is
Generic(
	constant MAX_PACKET_SIZE 			: integer := 1024;
	constant CIRCULAR_MEMORY_SIZE 		: integer := 4096;
	constant CIRCULAR_MEMORY_BIT_ADDR	: integer := 12;
	constant PACKET_MEMORY_BIT_ADDR		: integer := 10;
	constant TRUE_BRAM					: boolean := false
);
Port ( 
    clk 			: in STD_LOGIC;
    rst_n 			: in STD_LOGIC;
    enable          : in STD_LOGIC;
	wclk			: in STD_LOGIC := '0';
	
	data_byte_0 	: in STD_LOGIC_VECTOR(7 downto 0) := x"00";
	data_valid_0 	: in STD_LOGIC := '0';

	data_byte_1 	: in STD_LOGIC_VECTOR(7 downto 0) := x"00";
	data_valid_1 	: in STD_LOGIC := '0';

	data_byte_2 	: in STD_LOGIC_VECTOR(7 downto 0) := x"00";
	data_valid_2 	: in STD_LOGIC := '0';

	circular_bram_w_clk 	: out STD_LOGIC;
	circular_bram_w_rst 	: out STD_LOGIC;
	circular_bram_w_en 		: out STD_LOGIC;
	circular_bram_w_wen		: out STD_LOGIC;	
	circular_bram_w_addr 	: out STD_LOGIC_VECTOR(CIRCULAR_MEMORY_BIT_ADDR-1 downto 0);
	circular_bram_w_data 	: out STD_LOGIC_VECTOR(7 downto 0);
	
	circular_bram_r_clk		: out STD_LOGIC;
	circular_bram_r_rst 	: out STD_LOGIC;
	circular_bram_r_en		: out STD_LOGIC;
	circular_bram_r_addr 	: out STD_LOGIC_VECTOR(CIRCULAR_MEMORY_BIT_ADDR-1 downto 0);
	circular_bram_r_data 	: in STD_LOGIC_VECTOR(7 downto 0);
	
	packet_bram_f_clk		: out STD_LOGIC;
	packet_bram_f_rst		: out STD_LOGIC;
	packet_bram_f_en		: out STD_LOGIC;	
	packet_bram_f_wen		: out STD_LOGIC_VECTOR(3 downto 0);
	packet_bram_f_addr		: out STD_LOGIC_VECTOR(31 downto 0);	
	packet_bram_f_dout		: in STD_LOGIC_VECTOR(31 downto 0):= x"00000000";
	packet_bram_f_din		: out STD_LOGIC_VECTOR(31 downto 0):= x"00000000";
	
	packet_bram_s_clk 		: out STD_LOGIC;
	packet_bram_s_rst 		: out STD_LOGIC;
	packet_bram_s_en 		: out STD_LOGIC;
	packet_bram_s_wen		: out STD_LOGIC;	
	packet_bram_s_addr 		: out STD_LOGIC_VECTOR(PACKET_MEMORY_BIT_ADDR-1 downto 0);
	packet_bram_s_data 		: out STD_LOGIC_VECTOR(7 downto 0);
	
	
	packet_valid 			: out STD_LOGIC;
	packet_len 				: out STD_LOGIC_VECTOR(15 downto 0);
	packet_got 				: in STD_LOGIC
);
end packet_recover;

architecture Behavioral of packet_recover is    
	constant MAX_LEN : integer := MAX_PACKET_SIZE-5;
	type read_circular_state_t is (waiting_header, finding_header, waiting_len, finding_len, waiting_crc, check_crc, waiting_copy, copy_out, wait_ack);
	signal read_circular_state : read_circular_state_t;
	signal wclk_r : std_logic_vector(1 downto 0);
	
	signal data_byte_0_r 	: STD_LOGIC_VECTOR(7 downto 0) := x"00";
	signal data_valid_0_r 	: STD_LOGIC := '0';
	signal data_byte_1_r 	: STD_LOGIC_VECTOR(7 downto 0) := x"00";
	signal data_valid_1_r 	: STD_LOGIC := '0';
	signal data_byte_2_r 	: STD_LOGIC_VECTOR(7 downto 0) := x"00";
	signal data_valid_2_r 	: STD_LOGIC := '0';
	
	
	signal write_on_circular : std_logic;
	signal index_w : std_logic_vector(CIRCULAR_MEMORY_BIT_ADDR-1 downto 0);
	signal counter_w : integer range 0 to 3;
	
	signal index_r : std_logic_vector(CIRCULAR_MEMORY_BIT_ADDR-1 downto 0);
	signal read_addr_aux : std_logic_vector(CIRCULAR_MEMORY_BIT_ADDR-1 downto 0);
	signal circular_present : std_logic_vector(CIRCULAR_MEMORY_BIT_ADDR-1  downto 0);
	
	signal counter_read_aux : std_logic_vector(CIRCULAR_MEMORY_BIT_ADDR-1 downto 0);
	signal read_data_aux : std_logic_vector(7 downto 0);
	signal packet_len_aux : std_logic_vector(15 downto 0);
	
	signal crc_number_byte : std_logic_vector(15 downto 0);
	signal crc_val_aux : std_logic_vector(7 downto 0);
	
	signal write_addr_s_aux : STD_LOGIC_VECTOR(PACKET_MEMORY_BIT_ADDR-1 downto 0);
	
	signal enable_r : STD_LOGIC;
	signal packet_got_r : STD_LOGIC;
begin
	circular_bram_w_addr <= index_w;
	
	circular_bram_w_clk <= clk;
	circular_bram_w_en <= enable_r;
	
	circular_bram_r_clk	 <= clk;
    circular_bram_r_en   <= enable_r;

    packet_bram_s_clk	<= clk;
	packet_bram_s_en    <= enable_r;
	packet_bram_f_clk	<= clk;
	packet_bram_f_rst	<= not rst_n;
	packet_bram_s_rst   <= not rst_n;
	circular_bram_w_rst <= not rst_n;
	circular_bram_r_rst <= not rst_n;
	packet_bram_f_en	<= enable_r;	

	write_on_circular_process: process(clk,rst_n)
	begin
		if(rst_n='0')then
			wclk_r <= "00";
			write_on_circular <= '0';
			data_byte_0_r <= (others => '0');
			data_byte_1_r <= (others => '0');
			data_byte_2_r <= (others => '0');
			data_valid_0_r <= '0';
			data_valid_1_r <= '0';
			data_valid_2_r <= '0';
			counter_w <= 0;
			index_w <= (others => '0');
			circular_bram_w_wen <= '0';
			circular_bram_w_data <= (others => '0');
		    enable_r <= '0';	
		elsif rising_edge(clk) then
		    enable_r <= enable;
		    if(enable_r='0')then
		    	wclk_r <= "00";
                write_on_circular <= '0';
                data_byte_0_r <= (others => '0');
                data_byte_1_r <= (others => '0');
                data_byte_2_r <= (others => '0');
                data_valid_0_r <= '0';
                data_valid_1_r <= '0';
                data_valid_2_r <= '0';
                counter_w <= 0;
                index_w <= (others => '0');
                circular_bram_w_wen <= '0';
                circular_bram_w_data <= (others => '0');
		    else
                wclk_r <= wclk_r(0) & wclk;
                if(wclk_r="01")then
                    data_byte_0_r <= data_byte_0;
                    data_byte_1_r <= data_byte_1;
                    data_byte_2_r <= data_byte_2;
                    data_valid_0_r <= data_valid_0;
                    data_valid_1_r <= data_valid_1;
                    data_valid_2_r <= data_valid_2;
                    
                    if((data_valid_0='1')OR(data_valid_1='1')OR(data_valid_2='1'))then
                        write_on_circular <= '1';
                        counter_w <= 0;
                    end if;
                else
                    if(write_on_circular='1')then
                        counter_w <= counter_w+1;
                        if((counter_w=0)AND(data_valid_0='1'))then
                            circular_bram_w_data <= data_byte_0_r;
                            circular_bram_w_wen <= '1';
                            
                        elsif((counter_w=1)AND(data_valid_1='1'))then
                            circular_bram_w_data <= data_byte_1_r;
                            circular_bram_w_wen <= '1';
                            index_w <= index_w +1;
                        elsif((counter_w=2)AND(data_valid_2='1'))then
                            circular_bram_w_data <= data_byte_2_r;
                            circular_bram_w_wen <= '1';
                            index_w <= index_w +1;
                        else
                            
                            circular_bram_w_wen <= '0';
                        end if;
                        
                        if(counter_w=3)then
                            index_w <= index_w +1;
                            write_on_circular <= '0';
                        end if;
                    end if;
                end if;
             end if;
		end if;
	end process;
	
	circular_bram_r_addr <= read_addr_aux;



		
	read_from_circular_process : process(clk,rst_n)
	begin
		if(rst_n='0')then
		
            packet_got_r <= '0';
			index_r <= (others => '0');
			circular_present <= (others => '0');
			read_addr_aux <= (others => '0');
			read_circular_state <= waiting_header;
			packet_len_aux <= (others => '0');
			read_data_aux <= (others => '0');
			crc_number_byte <= (others => '0');
			crc_val_aux <= (others => '0');
			packet_valid <= '0';
			packet_len <= (others => '0');
			packet_bram_s_wen <= '0';
			write_addr_s_aux <= (others => '0');
			packet_bram_s_data <= (others => '0');
			packet_bram_f_wen <= "0000";
			packet_bram_f_addr	<= (others => '0');	
			packet_bram_f_din	<= (others => '0');
			
		elsif rising_edge(clk) then
            if(enable_r='0')then
            	packet_got_r <= '0';
				index_r <= (others => '0');
                circular_present <= (others => '0');
                read_addr_aux <= (others => '0');
                read_circular_state <= waiting_header;
                packet_len_aux <= (others => '0');
                read_data_aux <= (others => '0');
                crc_number_byte <= (others => '0');
                crc_val_aux <= (others => '0');
                packet_valid <= '0';
                packet_len <= (others => '0');
                packet_bram_s_wen <= '0';
                write_addr_s_aux <= (others => '0');
                packet_bram_s_data <= (others => '0');
                packet_bram_f_wen <= "0000";
                packet_bram_f_addr    <= (others => '0');    
                packet_bram_f_din    <= (others => '0');
            else
				packet_got_r <= packet_got;
				circular_present <= index_w - index_r;
                packet_bram_s_addr <= write_addr_s_aux;
                packet_bram_f_addr <= (31 downto PACKET_MEMORY_BIT_ADDR => '0') & write_addr_s_aux(PACKET_MEMORY_BIT_ADDR-1 downto 2) & "00";
                -- type read_circular_state_t is (waiting_header,finding_header, waiting_len, finding_len, waiting_crc, check_crc, copy_out);
                
                case read_circular_state is
                    when waiting_header =>
                        crc_number_byte <= (others => '0');
                        crc_val_aux <= (others => '0');
                        counter_read_aux <= (others => '0');
                        read_addr_aux <= index_r;
                        if(circular_present>1)then
                            read_circular_state <= finding_header;
                        end if;
                    when finding_header => 
                        if(counter_read_aux < 2)then
                            
                            read_addr_aux <= read_addr_aux +1;
                        end if;
                        counter_read_aux <= counter_read_aux +1;
                        if(counter_read_aux=x"0001")then
                            crc_number_byte <= crc_number_byte +1;
                            crc_val_aux <= crc_val_aux XOR circular_bram_r_data;
                            read_data_aux <= circular_bram_r_data;					
                        elsif(counter_read_aux=x"0002")then
                            crc_number_byte <= crc_number_byte +1;
                            crc_val_aux <= crc_val_aux XOR circular_bram_r_data;
                            if((read_data_aux=x"55")AND(circular_bram_r_data=x"AA"))then
                                read_circular_state <= waiting_len;
                            else
                                index_r <= index_r+1;
                                read_circular_state <= waiting_header;
                            end if;
                        end if;
                    when waiting_len => 
                        counter_read_aux <= (others => '0');
                        if(circular_present>3)then
                            read_circular_state <= finding_len;
                        end if;
                    when finding_len => 
                        counter_read_aux <= counter_read_aux +1;
                        if(counter_read_aux < 2)then
                            read_addr_aux <= read_addr_aux +1;
                        end if;
                        if(counter_read_aux=x"0001")then
                            crc_number_byte <= crc_number_byte +1;
                            crc_val_aux <= crc_val_aux XOR circular_bram_r_data;
                            read_data_aux <= circular_bram_r_data;					
                        elsif(counter_read_aux=x"0002")then
                            crc_number_byte <= crc_number_byte +1;
                            crc_val_aux <= crc_val_aux XOR circular_bram_r_data;
                            if((read_data_aux & circular_bram_r_data) < MAX_PACKET_SIZE)then
                                read_circular_state <= waiting_crc;
                                packet_len_aux <= read_data_aux & circular_bram_r_data;
                            else
                                index_r <= index_r+1;
                                read_circular_state <= waiting_header;
                            end if;
                        end if;
                    when waiting_crc => 
                        counter_read_aux <= (others => '0');
                        if(circular_present>packet_len_aux-1)then
                            read_circular_state <= check_crc;
                        end if;
                    when check_crc => 
                        counter_read_aux <= counter_read_aux +1;
                        -- -1 for crc, -4 for header and length already used
                        if(counter_read_aux < packet_len_aux-5)then
                            read_addr_aux <= read_addr_aux +1;
                        end if;
                        if(counter_read_aux /=0) then
                            if(counter_read_aux<packet_len_aux-4) then
                                crc_number_byte <= crc_number_byte +1;
                                crc_val_aux <= crc_val_aux XOR circular_bram_r_data;
                            else
                                if(crc_val_aux=circular_bram_r_data)then
                                    read_circular_state <= waiting_copy;
                                    read_addr_aux <= index_r;
                                else
                                    index_r <= index_r+1;
                                    read_circular_state <= waiting_header;
                                end if;
                            end if;
                        end if;
                    when waiting_copy => 
                        counter_read_aux <= (others => '0');
                        read_circular_state <= copy_out;
                        read_addr_aux <= read_addr_aux+1;
                        write_addr_s_aux <= (others => '0');
                    when copy_out => 
                        counter_read_aux <= counter_read_aux +1;
                        index_r <= index_r+1;
                        read_addr_aux <= read_addr_aux+1;
                        write_addr_s_aux <= write_addr_s_aux +1;
                        packet_bram_s_data <= circular_bram_r_data;
                        case write_addr_s_aux(1 downto 0) is
                            when "00" =>
                                packet_bram_f_din(7 downto 0) <= circular_bram_r_data;
                            when "01" => 
                                packet_bram_f_din(15 downto 8) <= circular_bram_r_data;
                            when "10" => 
                                packet_bram_f_din(23 downto 16) <= circular_bram_r_data;
                            when "11" => 
                                packet_bram_f_din(31 downto 24) <= circular_bram_r_data;
                            when others => 
                        end case;
                        packet_bram_s_wen <= '1';
                        packet_bram_f_wen <= "1111";
                        if(counter_read_aux=packet_len_aux-1)then
                            read_circular_state <= wait_ack;
                            packet_valid <= '1';
                            packet_len <= packet_len_aux;
                        end if;
                    when wait_ack => 
                        packet_bram_f_wen <= "0000";
                        packet_bram_s_wen <= '0';
                        if(packet_got_r='1')then
                            packet_valid <= '0';
                            read_circular_state <= waiting_header;
                        end if;
                    when others => 
                        read_circular_state <= waiting_header;
                end case;
           end if;
		end if;	
	end process;
	
end Behavioral;
