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

entity bus_transmitter is
Generic(
	--constant AUDIO_CHANNELS : integer := 7
	--constant AUDIO_CHANNELS : integer := 11
	constant AUDIO_CHANNELS : integer := 15
);
Port ( 
    clk 			: in STD_LOGIC;
    rst_n 			: in STD_LOGIC;
    enable			: in STD_LOGIC;
    
	dout 			: out STD_LOGIC;
	
	wclk			: in STD_LOGIC;
	
	data_byte_0 	: in STD_LOGIC_VECTOR(7 downto 0);
	data_valid_0 	: in STD_LOGIC;
	
	data_byte_1 	: in STD_LOGIC_VECTOR(7 downto 0);
	data_valid_1 	: in STD_LOGIC;
	
	data_byte_2 	: in STD_LOGIC_VECTOR(7 downto 0);
	data_valid_2 	: in STD_LOGIC;
	
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
end bus_transmitter;

architecture Behavioral of bus_transmitter is    
	type audio_vector_t is array(AUDIO_CHANNELS-1 downto 0) of std_logic_vector(23 downto 0);
	type data_vector_t is array(AUDIO_CHANNELS-1 downto 0) of std_logic_vector(3 downto 0);
    constant jk : std_logic_vector(39 downto 0)          := "1100010001110001000111000100011100010001";
	
	
	-- process_send
    signal send_bit 			: std_logic;
    signal send_bit_nzri 		: std_logic;
    signal counter_bit 			: integer range 0 to 9;
    signal send_word_5b 		: std_logic_vector(9 downto 0);
	
	-- process_data
	signal counter_sub_word : integer range 0 to 3;
	signal counter_channel : integer range 0 to 15;
    signal next_word_5b : std_logic_vector(9 downto 0);
	signal current_word_5b : std_logic_vector(39 downto 0);
	signal get_new_data : std_logic;

	
	-- process_4b5b
	signal next_word_4b5b : std_logic_vector(39 downto 0);
	
	-- process_feed4b
	signal next_word_4b 		: std_logic_vector(31 downto 0);
	
	
	-- Signal generator
	signal creator_audio 		: std_logic_vector(23 downto 0);
	signal creator_header_audio : std_logic_vector(2 downto 0);
	signal creator_parity_audio : std_logic;
	signal creator_data 	: std_logic_vector(3 downto 0);


	-- process_buffer
	signal audio_r : audio_vector_t;
	signal data_r : data_vector_t;
	signal valid_r : std_logic_vector(AUDIO_CHANNELS-1 downto 0);
	signal mute_r : std_logic_vector(AUDIO_CHANNELS-1 downto 0);

	signal audio_r1 : audio_vector_t;
	signal data_r1 : data_vector_t;
	signal valid_r1 : std_logic_vector(AUDIO_CHANNELS-1 downto 0);
	signal mute_r1 : std_logic_vector(AUDIO_CHANNELS-1 downto 0);

	signal wclk_r : std_logic_vector(1 downto 0);
	signal wclk1_r : std_logic;
	signal enable_r : std_logic;
	
begin
    dout <= send_bit_nzri;
    process_send : process(rst_n, clk)
    begin
        if rst_n = '0' then       
            counter_bit <= 0;
            send_bit_nzri <= '0';
            send_word_5b <= (others => '0');
        elsif rising_edge(clk) then

            if(counter_bit/=9) then
                counter_bit <= counter_bit +1;
            else
                counter_bit <= 0;
            end if;

            
            if(send_bit='1') then
                send_bit_nzri <= NOT send_bit_nzri;
            end if;
            
            send_bit <= send_word_5b(9);
            
            if(counter_bit=9) then
                send_word_5b <= next_word_5b;
            else
                send_word_5b <= send_word_5b(8 downto 0) & '0';
            end if;
        end if;        
    end process;
	
	process_data : process(rst_n, clk)
	begin
	    if rst_n = '0' then
            wclk1_r <= '0';
            counter_sub_word <= 0;
			counter_channel <= 0;
		    next_word_5b <= (others => '0');
		    current_word_5b <= (others => '0');
			get_new_data <= '0';
        elsif rising_edge(clk) then

            if(counter_bit=9) then
                wclk1_r <= wclk_r(0);		  
                if((wclk1_r='0')AND(wclk_r(0)='1')) then
                    counter_channel <= 0;
					counter_sub_word <= 3;
					get_new_data <= '1';

                else
					if(get_new_data='1') then 
						counter_channel <= counter_channel +1;						
					end if;
					
					if(counter_sub_word=3)then
						counter_sub_word <= 0;
						get_new_data <= '0';
					else
						if(counter_sub_word=2)then
							get_new_data <= '1';
						end if;
						counter_sub_word <= counter_sub_word +1;
					end if;
                end if;               
				
				
                case(counter_sub_word)is
                    when 0 => 
                        next_word_5b <= current_word_5b(39 downto 30);
                    when 1 =>
                        next_word_5b <= current_word_5b(29 downto 20);
                    when 2 =>
                        next_word_5b <= current_word_5b(19 downto 10);
                    when 3 =>
                        next_word_5b <= current_word_5b(9 downto 0);
                    when others => 
                        next_word_5b <= (others => '0');                 
                end case;
				

                if(get_new_data='1') then  
					if(counter_channel>=AUDIO_CHANNELS)then
						current_word_5b <= jk;
					else
						current_word_5b <= next_word_4b5b;   
					end if;
                end if;
            end if;
            	
		end if; 
	end process;
	
    process_4b5b : process(rst_n, clk)
    begin
        if(rst_n='0') then
            next_word_4b5b <= (others => '0');
        elsif rising_edge(clk)then
			--next_word_4b5b(4 downto 0) <= "11000";
            for I in 0 to 7 loop                           
                case ( next_word_4b(((I*4)+3) downto ((I*4))) ) is
                    when "0000" =>
                        ( next_word_4b5b((I*5)+4 downto (I*5)) ) <= "11110";
                    when "0001" =>
                        ( next_word_4b5b((I*5)+4 downto (I*5)) ) <= "01001";
                    when "0010" =>
                        ( next_word_4b5b((I*5)+4 downto (I*5)) ) <= "10100";
                    when "0011" =>
                        ( next_word_4b5b((I*5)+4 downto (I*5)) ) <= "10101";
                    when "0100" =>
                        ( next_word_4b5b((I*5)+4 downto (I*5)) ) <= "01010";
                    when "0101" =>
                        ( next_word_4b5b((I*5)+4 downto (I*5)) ) <= "01011";
                    when "0110" =>
                        ( next_word_4b5b((I*5)+4 downto (I*5)) ) <= "01110";
                    when "0111" =>
                        ( next_word_4b5b((I*5)+4 downto (I*5)) ) <= "01111";
                    when "1000" =>
                        ( next_word_4b5b((I*5)+4 downto (I*5)) ) <= "10010";
                    when "1001" =>
                        ( next_word_4b5b((I*5)+4 downto (I*5)) ) <= "10011";
                    when "1010" =>
                        ( next_word_4b5b((I*5)+4 downto (I*5)) ) <= "10110";
                    when "1011" =>
                        ( next_word_4b5b((I*5)+4 downto (I*5)) ) <= "10111";
                    when "1100" =>
                        ( next_word_4b5b((I*5)+4 downto (I*5)) ) <= "11010";
                    when "1101" =>
                        ( next_word_4b5b((I*5)+4 downto (I*5)) ) <= "11011";
                    when "1110" =>
                        ( next_word_4b5b((I*5)+4 downto (I*5)) ) <= "11100";
                    when "1111" =>
                        ( next_word_4b5b((I*5)+4 downto (I*5)) ) <= "11101";
                    when others  =>
                        ( next_word_4b5b((I*5)+4 downto (I*5)) ) <= "00000";
                end case;
            end loop;   
        end if;
    end process;
	
	next_word_4b <= creator_header_audio & creator_parity_audio & creator_audio & creator_data;
	
	process_feed4b : process(rst_n, clk)
    begin
        if(rst_n='0') then
			creator_audio <= (others => '0');
			creator_header_audio <= (others => '0');
	
			creator_data <= (others => '0');
        elsif rising_edge(clk)then
			if(enable_r='0')then
				creator_audio <= (others => '0');
				creator_header_audio <= (others => '0');
				creator_data <= (others => '0');
			else			
				if(get_new_data='1') then
					if(counter_bit=7) then
						if(counter_channel<AUDIO_CHANNELS) then
							creator_audio <= audio_r(counter_channel);
							creator_data <= data_r(counter_channel);
						end if;
						if(counter_channel=0) then
							creator_header_audio <= '1' & valid_r(counter_channel) & mute_r(counter_channel);
						elsif(counter_channel<AUDIO_CHANNELS) then
							creator_header_audio <= '0' & valid_r(counter_channel) & mute_r(counter_channel);
						end if;
					
					end if;
				end if;
			end if;
        end if; 
    end process;

	
	creator_parity_audio <= creator_audio(23) 	XOR creator_audio(22) 	XOR creator_audio(21) 	XOR creator_audio(20) XOR
							creator_audio(19) 	XOR creator_audio(18) 	XOR creator_audio(17) 	XOR creator_audio(16) XOR
							creator_audio(15) 	XOR creator_audio(14) 	XOR creator_audio(13) 	XOR creator_audio(12) XOR
							creator_audio(11) 	XOR creator_audio(10) 	XOR creator_audio(9) 	XOR creator_audio(8) XOR
							creator_audio(7) 	XOR creator_audio(6) 	XOR creator_audio(5) 	XOR creator_audio(4) XOR
							creator_audio(3) 	XOR creator_audio(2) 	XOR creator_audio(1) 	XOR creator_audio(0) XOR
							creator_data(3) 	XOR creator_data(2) 	XOR creator_data(1) 	XOR creator_data(0) XOR
							creator_header_audio(2) XOR creator_header_audio(1) XOR creator_header_audio(0);
							
	process_buffer : process (rst_n, clk)
	begin
		if(rst_n='0')then
			audio_r <= (others => (others =>'0'));
			wclk_r <= (others => '0');
			enable_r <= '0';
		elsif rising_edge(clk) then	
			enable_r <= enable;
			wclk_r <= wclk_r(0) & wclk;
			if(wclk_r="01") then
				for I in 0 to AUDIO_CHANNELS-1 loop
					data_r(I)	<= data_r1(I);
					audio_r(I) 	<= audio_r1(I);
					valid_r(I)	<= valid_r1(I);
					mute_r(I)	<= mute_r1(I);
				end loop;
			end if;
		end if;
	end process;

	data_r1(0) <= data_byte_0(3 downto 0);
	data_r1(1) <= data_byte_0(7 downto 4);
	data_r1(2) <= data_byte_1(3 downto 0);
	data_r1(3) <= data_byte_1(7 downto 4);
	data_r1(4) <= data_byte_2(3 downto 0);
	data_r1(5) <= data_byte_2(7 downto 4);
	data_r1(6) <= '0' & data_valid_0 & data_valid_1 & data_valid_2;

	audio_r1(0) <= audio_data_0;
	audio_r1(1) <= audio_data_1;
	audio_r1(2) <= audio_data_2;
	audio_r1(3) <= audio_data_3;
	audio_r1(4) <= audio_data_4;
	audio_r1(5) <= audio_data_5;
	audio_r1(6) <= audio_data_6;

	valid_r1(0) <= audio_valid_0;
	valid_r1(1) <= audio_valid_1;		
	valid_r1(2) <= audio_valid_2;
	valid_r1(3) <= audio_valid_3;
	valid_r1(4) <= audio_valid_4;
	valid_r1(5) <= audio_valid_5;
	valid_r1(6) <= audio_valid_6;


	mute_r1(0) <= audio_mute_0;
	mute_r1(1) <= audio_mute_1;
	mute_r1(2) <= audio_mute_2;
	mute_r1(3) <= audio_mute_3;
	mute_r1(4) <= audio_mute_4;
	mute_r1(5) <= audio_mute_5;
	mute_r1(6) <= audio_mute_6;

	GEN_0: if(AUDIO_CHANNELS>7) generate
		data_r1(7) <= (others => '0');
		data_r1(8) <= (others => '0');
		data_r1(9) <= (others => '0');
		data_r1(10) <= (others => '0');

		audio_r1(7) <= audio_data_7;
		audio_r1(8) <= audio_data_8;
		audio_r1(9) <= audio_data_9;
		audio_r1(10) <= audio_data_10;

		valid_r1(7) <= audio_valid_7;
		valid_r1(8) <= audio_valid_8;
		valid_r1(9) <= audio_valid_9;
		valid_r1(10) <= audio_valid_10;

		mute_r1(7) <= audio_mute_7;
		mute_r1(8) <= audio_mute_8;
		mute_r1(9) <= audio_mute_9;
		mute_r1(10) <= audio_mute_10;
	end generate GEN_0;

	GEN_1: if(AUDIO_CHANNELS>11) generate
		data_r1(11) <= (others => '0');
		data_r1(12) <= (others => '0');
		data_r1(13) <= (others => '0');
		data_r1(14) <= (others => '0');

		audio_r1(11) <= audio_data_11;
		audio_r1(12) <= audio_data_12;
		audio_r1(13) <= audio_data_13;
		audio_r1(14) <= audio_data_14;

		valid_r1(11) <= audio_valid_11;
		valid_r1(12) <= audio_valid_12;
		valid_r1(13) <= audio_valid_13;
		valid_r1(14) <= audio_valid_14;

		mute_r1(11) <= audio_mute_11;
		mute_r1(12) <= audio_mute_12;
		mute_r1(13) <= audio_mute_13;
		mute_r1(14) <= audio_mute_14;
	end generate GEN_1;	

end Behavioral;
