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

entity bus_receiver is
Generic(
	--constant AUDIO_CHANNELS : integer := 7
	--constant AUDIO_CHANNELS : integer := 11
	constant AUDIO_CHANNELS : integer := 15
);
Port ( 
    clk_0 			: in STD_LOGIC;
    clk_90 			: in STD_LOGIC;
    clk_180			: in STD_LOGIC;
    clk_270			: in STD_LOGIC;
    rst_n 			: in STD_LOGIC;
    enable			: in STD_LOGIC;
    
	din 			: in STD_LOGIC;
	
	wclk			: out STD_LOGIC := '0';
	locked          : out STD_LOGIC := '0';
	data_byte_0 	: out STD_LOGIC_VECTOR(7 downto 0) := x"00";
	data_valid_0 	: out STD_LOGIC := '0';

	data_byte_1 	: out STD_LOGIC_VECTOR(7 downto 0) := x"00";
	data_valid_1 	: out STD_LOGIC := '0';

	data_byte_2 	: out STD_LOGIC_VECTOR(7 downto 0) := x"00";
	data_valid_2 	: out STD_LOGIC := '0';

	audio_data_0 	: out STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_valid_0 	: out STD_LOGIC := '0';
	audio_mute_0 	: out STD_LOGIC := '0';

	audio_data_1 	: out STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_valid_1 	: out STD_LOGIC := '0';
	audio_mute_1 	: out STD_LOGIC := '0';

	audio_data_2 	: out STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_valid_2 	: out STD_LOGIC := '0';
	audio_mute_2 	: out STD_LOGIC := '0';

	audio_data_3 	: out STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_valid_3 	: out STD_LOGIC := '0';
	audio_mute_3 	: out STD_LOGIC := '0';

	audio_data_4 	: out STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_valid_4 	: out STD_LOGIC := '0';
	audio_mute_4 	: out STD_LOGIC := '0';

	audio_data_5 	: out STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_valid_5 	: out STD_LOGIC := '0';
	audio_mute_5 	: out STD_LOGIC := '0';
		 
	audio_data_6 	: out STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_valid_6 	: out STD_LOGIC := '0';
	audio_mute_6 	: out STD_LOGIC := '0';
		
	audio_data_7 	: out STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_valid_7 	: out STD_LOGIC := '0';
	audio_mute_7 	: out STD_LOGIC := '0';
	   
	audio_data_8 	: out STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_valid_8 	: out STD_LOGIC := '0';
	audio_mute_8 	: out STD_LOGIC := '0';
	
	audio_data_9 	: out STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_valid_9 	: out STD_LOGIC := '0';
	audio_mute_9 	: out STD_LOGIC := '0';
		 
	audio_data_10 	: out STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_valid_10 	: out STD_LOGIC := '0';
	audio_mute_10 	: out STD_LOGIC := '0';
	
	audio_data_11 	: out STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_valid_11 	: out STD_LOGIC := '0';
	audio_mute_11 	: out STD_LOGIC := '0';
	
	audio_data_12 	: out STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_valid_12 	: out STD_LOGIC := '0';
	audio_mute_12 	: out STD_LOGIC := '0';
		
	audio_data_13 	: out STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_valid_13 	: out STD_LOGIC := '0';
	audio_mute_13 	: out STD_LOGIC := '0';
		  
	audio_data_14 	: out STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	audio_valid_14 	: out STD_LOGIC := '0';
	audio_mute_14 	: out STD_LOGIC := '0'
	
);
end bus_receiver;

architecture Behavioral of bus_receiver is    
    component lock_info is
	generic(
		constant AUDIO_CHANNELS : integer := 15 
	);
    port (
		mclk:     		in  std_logic; --100M clk
		rst_n: 			in	std_logic;
		wclk_in: 	  		in 	std_logic; --low frequency clk		
		wclk_lock : 	out std_logic
	);
    end component;

	component input_oversampler is
		Port ( 
			clk_0       		: in  STD_LOGIC;
			clk_90       		: in  STD_LOGIC;
			clk_180      		: in  STD_LOGIC;
			clk_270      		: in  STD_LOGIC;
			data_in				: in  STD_LOGIC;
			data_in_oversampled : out  STD_LOGIC_VECTOR (3 downto 0)
		);
	end component;
	
	component input_resempler is
    Port ( 
		clk       			: in  STD_LOGIC;
        rst_n 				: in STD_LOGIC;
        data_in_resampled 	: out STD_LOGIC_VECTOR(4 downto 0);
        data_in_valid 		: out STD_LOGIC;
        data_in_oversampled : in  STD_LOGIC_VECTOR (3 downto 0)
    );
	end component;
	
	component nrzi_decode is
	Port(
		clk				: in std_logic;
		rst_n			: in std_logic;
		trig			: in std_logic;
		word_5B_nrzi	: in std_logic_vector (4 downto 0);
		word_5B_binary	: out std_logic_vector (4 downto 0)
	);
	end component;
	
	component input_decoder is
	port(
		clk 			: in std_logic;
		rst_n			: in std_logic;
		valid_in 	: in std_logic;
		word_in : in std_logic_vector(4 downto 0);

		wclk_out : out std_logic;
		valid_out : out std_logic;
		write_out : out std_logic;
		channel : out std_logic_vector(3 downto 0) := (others => '0');
		data : out std_logic_vector(31 downto 0) := (others => '0')
	);
	end component;
	
	--input_oversampler
	signal data_in_oversampled   : std_logic_vector (3 downto 0);
	
	--input_oversampler
	signal data_in_resampled_valid : std_logic;
    signal data_in_resampled : std_logic_vector(4 downto 0);
	
	--input_oversampler
	signal data_in_binary : std_logic_vector(4 downto 0);
	--input_decoder
	signal valid_in 	: std_logic;
    signal word_in 		: std_logic_vector(4 downto 0);

    signal wclk_out 	: std_logic;
    signal valid_out 	: std_logic;
    signal write_out 	: std_logic;
    signal channel 		: std_logic_vector(3 downto 0) := (others => '0');
    signal data 		: std_logic_vector(31 downto 0) := (others => '0');
	signal enable_r		: std_logic;
	
	
	signal r_data_byte_0 	: STD_LOGIC_VECTOR(7 downto 0) := x"00";
	signal r_data_valid_0 	: STD_LOGIC := '0';
	signal r_data_byte_1 	: STD_LOGIC_VECTOR(7 downto 0) := x"00";
	signal r_data_valid_1 	: STD_LOGIC := '0';
	signal r_data_byte_2 	: STD_LOGIC_VECTOR(7 downto 0) := x"00";
	signal r_data_valid_2 	: STD_LOGIC := '0';
	signal r_audio_data_0 	: STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	signal r_audio_valid_0 	: STD_LOGIC := '0';
	signal r_audio_mute_0 	: STD_LOGIC := '0';
	signal r_audio_data_1 	: STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	signal r_audio_valid_1 	: STD_LOGIC := '0';
	signal r_audio_mute_1 	: STD_LOGIC := '0';
	signal r_audio_data_2 	: STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	signal r_audio_valid_2 	: STD_LOGIC := '0';
	signal r_audio_mute_2 	: STD_LOGIC := '0';
	signal r_audio_data_3 	: STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	signal r_audio_valid_3 	: STD_LOGIC := '0';
	signal r_audio_mute_3 	: STD_LOGIC := '0';
	signal r_audio_data_4 	: STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	signal r_audio_valid_4 	: STD_LOGIC := '0';
	signal r_audio_mute_4 	: STD_LOGIC := '0';
	signal r_audio_data_5 	: STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	signal r_audio_valid_5 	: STD_LOGIC := '0';
	signal r_audio_mute_5 	: STD_LOGIC := '0';
	signal r_audio_data_6 	: STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	signal r_audio_valid_6 	: STD_LOGIC := '0';
	signal r_audio_mute_6 	: STD_LOGIC := '0';
	signal r_audio_data_7 	: STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	signal r_audio_valid_7 	: STD_LOGIC := '0';
	signal r_audio_mute_7 	: STD_LOGIC := '0';
	signal r_audio_data_8 	: STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	signal r_audio_valid_8 	: STD_LOGIC := '0';
	signal r_audio_mute_8 	: STD_LOGIC := '0';
	signal r_audio_data_9 	: STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	signal r_audio_valid_9 	: STD_LOGIC := '0';
	signal r_audio_mute_9 	: STD_LOGIC := '0';
	signal r_audio_data_10 	: STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	signal r_audio_valid_10 : STD_LOGIC := '0';
	signal r_audio_mute_10 	: STD_LOGIC := '0';
	signal r_audio_data_11 	: STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	signal r_audio_valid_11 : STD_LOGIC := '0';
	signal r_audio_mute_11 	: STD_LOGIC := '0';
	signal r_audio_data_12 	: STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	signal r_audio_valid_12 : STD_LOGIC := '0';
	signal r_audio_mute_12 	: STD_LOGIC := '0';
	signal r_audio_data_13 	: STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	signal r_audio_valid_13 : STD_LOGIC := '0';
	signal r_audio_mute_13 	: STD_LOGIC := '0';
	signal r_audio_data_14 	: STD_LOGIC_VECTOR(23 downto 0) := x"000000";
	signal r_audio_valid_14 : STD_LOGIC := '0';
	signal r_audio_mute_14 	: STD_LOGIC := '0';
	
	
	signal write_out_r : STD_LOGIC := '0';
	signal wclk_r : STD_LOGIC;
begin

    wclk <= wclk_r;
    lock_info_inst: lock_info
    generic map (
        AUDIO_CHANNELS => AUDIO_CHANNELS 
    )
    port map (
        mclk=>clk_0,
        rst_n => rst_n,
        wclk_in=>wclk_r, 
        wclk_lock  => locked
    );
    input_oversampler_inst: input_oversampler 
	PORT MAP (
        clk_0    => clk_0,
        clk_90   => clk_90,
        clk_180  => clk_180,
        clk_270  => clk_270,
        data_in => din,
        data_in_oversampled => data_in_oversampled
    );  
	
    input_resempler_inst : input_resempler
    Port MAP( 
         clk => clk_0,
         rst_n => rst_n,
         data_in_resampled => data_in_resampled,
         data_in_valid => data_in_resampled_valid,
         data_in_oversampled => data_in_oversampled
     );
	 
	 
	nrzi_decode_inst : nrzi_decode
	Port MAP(
		clk => clk_0,
		rst_n => rst_n,
		trig => data_in_resampled_valid,
		word_5B_nrzi => data_in_resampled,
		word_5B_binary => data_in_binary
	);
	

	input_decoder_inst : input_decoder 
	port map(
		clk => clk_0,
		rst_n => rst_n,
		valid_in => data_in_resampled_valid,
		word_in => data_in_binary,
		valid_out => valid_out,
		wclk_out => wclk_out,
		
		write_out => write_out,
		channel => channel,
		data => data
	);
	
	demux_data_process: process(rst_n, clk_0)
	begin
		if(rst_n='0')then
			enable_r <= '0';
		elsif rising_edge(clk_0)then
			enable_r <= enable;
			if(enable_r='0')then
				wclk_r <= '0';
				write_out_r <= '0';
				r_data_byte_0 		<= x"00";
				r_data_valid_0 		<= '0';
				r_data_byte_1 		<= x"00";
				r_data_valid_1 		<= '0';
				r_data_byte_2 		<= x"00";
				r_data_valid_2 		<= '0';
				r_audio_data_0 		<= x"000000";
				r_audio_valid_0 	<= '0';
				r_audio_mute_0 		<= '0';
				r_audio_data_1 		<= x"000000";
				r_audio_valid_1 	<= '0';
				r_audio_mute_1 		<= '0';
				r_audio_data_2 		<= x"000000";
				r_audio_valid_2 	<= '0';
				r_audio_mute_2 		<= '0';
				r_audio_data_3 		<= x"000000";
				r_audio_valid_3 	<= '0';
				r_audio_mute_3 		<= '0';
				r_audio_data_4 		<= x"000000";
				r_audio_valid_4 	<= '0';
				r_audio_mute_4 		<= '0';
				r_audio_data_5 		<= x"000000";
				r_audio_valid_5 	<= '0';
				r_audio_mute_5 		<= '0'; 
				r_audio_data_6 		<= x"000000";
				r_audio_valid_6 	<= '0';
				r_audio_mute_6 		<= '0';
				r_audio_data_7 		<= x"000000";
				r_audio_valid_7 	<= '0';
				r_audio_mute_7 		<= '0';
				r_audio_data_8 		<= x"000000";
				r_audio_valid_8 	<= '0';
				r_audio_mute_8 		<= '0';
				r_audio_data_9 		<= x"000000";
				r_audio_valid_9 	<= '0';
				r_audio_mute_9 		<= '0';
				r_audio_data_10 	<= x"000000";
				r_audio_valid_10 	<= '0';
				r_audio_mute_10 	<= '0';
				r_audio_data_11 	<= x"000000";
				r_audio_valid_11 	<= '0';
				r_audio_mute_11 	<= '0';
				r_audio_data_12 	<= x"000000";
				r_audio_valid_12 	<= '0';
				r_audio_mute_12 	<= '0';	
				r_audio_data_13 	<= x"000000";
				r_audio_valid_13 	<= '0';
				r_audio_mute_13 	<= '0';  
				r_audio_data_14 	<= x"000000";
				r_audio_valid_14 	<= '0';
				r_audio_mute_14 	<= '0';
			else
				write_out_r <= write_out;
				if((write_out_r='1')AND(write_out='0')) then 
					if(channel=AUDIO_CHANNELS-1)then
						data_byte_0 	<= r_data_byte_0 	;
						data_valid_0 	<= r_data_valid_0 	;
						data_byte_1 	<= r_data_byte_1 	;
						data_valid_1 	<= r_data_valid_1 	;
						data_byte_2 	<= r_data_byte_2 	;
						data_valid_2 	<= r_data_valid_2 	;
						audio_data_0 	<= r_audio_data_0 	;
						audio_valid_0 	<= r_audio_valid_0 	;
						audio_mute_0 	<= r_audio_mute_0 	;
						audio_data_1 	<= r_audio_data_1 	;
						audio_valid_1 	<= r_audio_valid_1 	;
						audio_mute_1 	<= r_audio_mute_1 	;
						audio_data_2 	<= r_audio_data_2 	;
						audio_valid_2 	<= r_audio_valid_2 	;
						audio_mute_2 	<= r_audio_mute_2 	;
						audio_data_3 	<= r_audio_data_3 	;
						audio_valid_3 	<= r_audio_valid_3 	;
						audio_mute_3 	<= r_audio_mute_3 	;
						audio_data_4 	<= r_audio_data_4 	;
						audio_valid_4 	<= r_audio_valid_4 	;
						audio_mute_4 	<= r_audio_mute_4 	;
						audio_data_5 	<= r_audio_data_5 	;
						audio_valid_5 	<= r_audio_valid_5 	;
						audio_mute_5 	<= r_audio_mute_5 	;
						audio_data_6 	<= r_audio_data_6 	;
						audio_valid_6 	<= r_audio_valid_6 	;
						audio_mute_6 	<= r_audio_mute_6 	;
						audio_data_7 	<= r_audio_data_7 	;
						audio_valid_7 	<= r_audio_valid_7 	;
						audio_mute_7 	<= r_audio_mute_7 	;
						audio_data_8 	<= r_audio_data_8 	;
						audio_valid_8 	<= r_audio_valid_8 	;
						audio_mute_8 	<= r_audio_mute_8 	;
						audio_data_9 	<= r_audio_data_9 	;
						audio_valid_9 	<= r_audio_valid_9 	;
						audio_mute_9 	<= r_audio_mute_9 	;
						audio_data_10 	<= r_audio_data_10 	;
						audio_valid_10 	<= r_audio_valid_10 ;
						audio_mute_10 	<= r_audio_mute_10 	;
						audio_data_11 	<= r_audio_data_11 	;
						audio_valid_11 	<= r_audio_valid_11 ;
						audio_mute_11 	<= r_audio_mute_11 	;
						audio_data_12 	<= r_audio_data_12 	;
						audio_valid_12 	<= r_audio_valid_12 ;
						audio_mute_12 	<= r_audio_mute_12 	;
						audio_data_13 	<= r_audio_data_13 	;
						audio_valid_13 	<= r_audio_valid_13 ;
						audio_mute_13 	<= r_audio_mute_13 	;
						audio_data_14 	<= r_audio_data_14 	;
						audio_valid_14 	<= r_audio_valid_14 ;
						audio_mute_14 	<= r_audio_mute_14 	;
					end if;
				end if;
				
				if(write_out='1')then
					case channel is
						when "0000" =>
							r_audio_data_0 	 <= data(27 downto 4);
							r_audio_valid_0  <= data(30);
							r_audio_mute_0 	 <= data(29);
							r_data_byte_0(3 downto 0)	 <= data(3 downto 0);
							wclk_r <= '1';     
						when "0001" =>       
							r_audio_data_1 	 <= data(27 downto 4);
							r_audio_valid_1  <= data(30);
							r_audio_mute_1 	 <= data(29);
							r_data_byte_0(7 downto 4)	 <= data(3 downto 0);
						when "0010" =>       
							r_audio_data_2 	 <= data(27 downto 4);
							r_audio_valid_2  <= data(30);
							r_audio_mute_2 	 <= data(29);
							r_data_byte_1(3 downto 0)	 <= data(3 downto 0);
						when "0011" =>       
							r_audio_data_3 	 <= data(27 downto 4);
							r_audio_valid_3  <= data(30);
							r_audio_mute_3 	 <= data(29);
							r_data_byte_1(7 downto 4)	 <= data(3 downto 0);
						when "0100" =>       
							r_audio_data_4 	 <= data(27 downto 4);
							r_audio_valid_4  <= data(30);
							r_audio_mute_4 	 <= data(29);
							r_data_byte_2(3 downto 0)	 <= data(3 downto 0);
							if(AUDIO_CHANNELS=7)then
								wclk_r <= '0';     
							end if;
						when "0101" =>       
							r_audio_data_5 	 <= data(27 downto 4);
							r_audio_valid_5  <= data(30);
							r_audio_mute_5 	 <= data(29);
							r_data_byte_2(7 downto 4)	 <= data(3 downto 0);
						when "0110" =>       
							r_audio_data_6 	 <= data(27 downto 4);
							r_audio_valid_6  <= data(30);
							r_audio_mute_6 	 <= data(29);
							r_data_valid_0   <= data(2);
							r_data_valid_1	 <= data(1);
							r_data_valid_2   <= data(0);
							if(AUDIO_CHANNELS=11)then
								wclk_r <= '0';     
							end if;
						when "0111" =>       
							r_audio_data_7 	 <= data(27 downto 4);
							r_audio_valid_7  <= data(30);
							r_audio_mute_7 	 <= data(29);
						when "1000" =>       
							r_audio_data_8 	 <= data(27 downto 4);
							r_audio_valid_8  <= data(30);
							r_audio_mute_8 	 <= data(29);
							if(AUDIO_CHANNELS=15)then
								wclk_r <= '0';     
							end if;
						when "1001" =>       
							r_audio_data_9 	 <= data(27 downto 4);
							r_audio_valid_9  <= data(30);
							r_audio_mute_9 	 <= data(29);
						when "1010" =>       
							r_audio_data_10	 <= data(27 downto 4);
							r_audio_valid_10 <= data(30);
							r_audio_mute_10	 <= data(29);
						when "1011" =>       
							r_audio_data_11  <= data(27 downto 4);
							r_audio_valid_11 <= data(30);
							r_audio_mute_11  <= data(29);
						when "1100" =>       
							r_audio_data_12	 <= data(27 downto 4);
							r_audio_valid_12 <= data(30);
							r_audio_mute_12	 <= data(29);
						when "1101" =>       
							r_audio_data_13  <= data(27 downto 4);
							r_audio_valid_13 <= data(30);
							r_audio_mute_13	 <= data(29);
						when "1110" =>       
							r_audio_data_14  <= data(27 downto 4);
							r_audio_valid_14 <= data(30);
							r_audio_mute_14	 <= data(29);

						when others => 
							wclk_r <= '0';     
					end case;
				end if;
			end if;
		end if;
	end process;
end Behavioral;
