	library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;
	use ieee.numeric_std.all;

	entity input_decoder is
	 port(
		 clk 			: in std_logic;
		 rst_n			: in std_logic;
		 valid_in 	: in std_logic;                           -- @25MHz
		 word_in : in std_logic_vector(4 downto 0);
		 
		 wclk_out : out std_logic;
		 valid_out : out std_logic;
		 write_out : out std_logic;
		
		 channel : out std_logic_vector(3 downto 0) := (others => '0');
		 data : out std_logic_vector(31 downto 0) := (others => '0')


		 );
	end input_decoder;

	architecture behavioral of input_decoder is

		type nibble_buffer_t is array(6 downto 0) of std_logic_vector(3 downto 0);

		signal valid_in_r : std_logic_vector(1 downto 0) := (others => '0');
		signal word_in_r : std_logic_vector(14 downto 0) := (others => '0');
		
		constant JK: std_logic_vector(9 downto 0):="1100010001";
		signal sync_detect : std_logic := '0';
		signal aligned : std_logic := '0';
		signal symbol : std_logic_vector(4 downto 0) := (others => '0');
		

		signal index_sequence: integer:=0;
		signal index_sequence_r: integer:=0;

		signal nibble : std_logic_vector(3 downto 0) := (others => '0');
		signal nibble_rst : std_logic := '0';
		signal nibble_clk : std_logic := '0';
		signal nibble_cnt : std_logic_vector(2 downto 0) := (others => '0');
		signal nibble_buffer : nibble_buffer_t;
		
		signal channel_cnt : std_logic_vector(3 downto 0) := (others => '0');
		signal channel_rst : std_logic := '0';
		
		signal write_buffer : std_logic := '0';
		
		signal wordclk_shift : std_logic_vector(1 downto 0);
		signal wordclk_count : std_logic_vector(12 downto 0) := (others => '0');
		signal wordclk_current : std_logic_vector(11 downto 0) := (others => '0');
		signal wordclk_reference : std_logic_vector(24 downto 0) := (others => '0'); --24
		
		signal write_buffer_r : std_logic := '0';
		signal chA: std_logic_vector(23 downto 0) := (others => '0');
		signal chB: std_logic_vector(23 downto 0) := (others => '0');



	 begin

	  shift_clk : process (clk)
		begin
		  if clk'event and clk = '1' then
				valid_in_r <= valid_in_r(0) & valid_in;
		  end if;
		end process shift_clk;
	 
 	  shift_input : process (clk, rst_n)
		begin
			 if (rst_n='0') then 
				word_in_r <= (others =>'0');
				sync_detect <= '0';
				aligned <= '0';
				valid_out <= '0';
			 elsif clk'event and clk = '1' then
					if valid_in_r = "01" then
						word_in_r <= word_in_r(9 downto 0) & word_in;
						if (index_sequence /=5) then 
							sync_detect <= '1';
							aligned <= '1';
							index_sequence_r <= index_sequence;
							valid_out <= '1';
						else 
						    sync_detect <= '0';
						end if;
					
						if aligned = '1' then
							symbol <= word_in_r(index_sequence_r+4 downto index_sequence_r);
						end if;
				
					end if;		
			end if;
	   end process  shift_input;
		
		
		process(word_in_r)
			variable k: integer:=0;
		begin
		    loopA: for i in 0 to 5 loop
					k:=i;
					exit loopA when k=5;
					exit loopA 
				        when    word_in_r(i+9 downto i)=JK;
			 end loop loopA;
			 index_sequence <= k; 
		end process;
	
		 decode : process (clk, rst_n)
		 begin
		 if (rst_n='0') then
			 nibble <= (others => '0');
			 nibble_clk <= '0';
			 nibble_rst <= '0';
		 elsif clk'event and clk = '1' then
		   if (valid_in_r="01") then
		          if(aligned='1') then
                      
                    case symbol is
                         when "11110" =>
                              nibble <= "0000";
                              nibble_clk <= '1';
                              nibble_rst <= '0';
                         when "01001" =>
                              nibble <= "0001";
                              nibble_clk <= '1';
                              nibble_rst <= '0';
                         when "10100" =>
                              nibble <= "0010";
                              nibble_clk <= '1';
                              nibble_rst <= '0';
                         when "10101" =>
                              nibble <= "0011";
                              nibble_clk <= '1';
                              nibble_rst <= '0';
                         when "01010" =>
                              nibble <= "0100";
                              nibble_clk <= '1';
                              nibble_rst <= '0';
                         when "01011" =>
                              nibble <= "0101";
                              nibble_clk <= '1';
                              nibble_rst <= '0';
                         when "01110" =>
                              nibble <= "0110";
                              nibble_clk <= '1';
                              nibble_rst <= '0';
                         when "01111" =>
                              nibble <= "0111";
                              nibble_clk <= '1';
                              nibble_rst <= '0';
                         when "10010" =>
                              nibble <= "1000";
                              nibble_clk <= '1';
                              nibble_rst <= '0';
                         when "10011" =>
                              nibble <= "1001";
                              nibble_clk <= '1';
                              nibble_rst <= '0';
                         when "10110" =>
                              nibble <= "1010";
                              nibble_clk <= '1';
                              nibble_rst <= '0';
                         when "10111" =>
                              nibble <= "1011";
                              nibble_clk <= '1';
                              nibble_rst <= '0';
                         when "11010" =>
                              nibble <= "1100";
                              nibble_clk <= '1';
                              nibble_rst <= '0';
                         when "11011" =>
                              nibble <= "1101";
                              nibble_clk <= '1';
                              nibble_rst <= '0';
                         when "11100" =>
                              nibble <= "1110";
                              nibble_clk <= '1';
                              nibble_rst <= '0';
                         when "11101" =>
                              nibble <= "1111";
                              nibble_clk <= '1';
                              nibble_rst <= '0';
                         when others  =>
                              nibble <= "0000";
                              nibble_clk <= '0';
                              nibble_rst <= '1';
                    end case;
                end if;
		  end if;
		end if; 
	 end process decode;
		 
		 
		 place_nibble : process (clk, rst_n)
		 begin
		   if(rst_n ='0') then
				  channel_cnt <= (others => '0');
				  write_buffer <= '0';
				  nibble_buffer <= (others => (others=> '0'));


--				  channel_cnt_del <= (others => '0');
			elsif clk'event and clk = '1' then

--				  channel_cnt_del <= channel_cnt;	

				  if (valid_in_r="01") then
						
						if nibble_rst = '1' then
							nibble_cnt <= (others => '0');
						end if;
						if channel_rst = '1' then
							channel_rst <= '0';
						end if;
						if nibble_clk = '1' then
								 nibble_cnt <= nibble_cnt + 1;
								 case nibble_cnt is
									  when "000" =>
											nibble_buffer(0) <= nibble;
									  when "001" =>
											nibble_buffer(1) <= nibble;
									  when "010" =>
											nibble_buffer(2) <= nibble;
									  when "011" =>
											nibble_buffer(3) <= nibble;
									  when "100" =>
											nibble_buffer(4) <= nibble;
									  when "101" =>
											nibble_buffer(5) <= nibble;
									  when "110" =>
											nibble_buffer(6) <= nibble;
									  when others =>
								 end case;

								 
								 if nibble_cnt = 7 then
										data <= nibble_buffer(0) & nibble_buffer(1) & nibble_buffer(2) & nibble_buffer(3) & nibble_buffer(4) & nibble_buffer(5) & nibble_buffer(6) & nibble;
										write_buffer <= '1';
								 else
										write_buffer <= '0';
								 end if;
								 
								 if ((nibble(3) = '1') and (nibble_cnt = 0)) then    -- Canale 0
										channel_rst <= '1';
										channel_cnt <= (others => '0');
								 elsif nibble_cnt = 7 then
										channel_cnt <= channel_cnt + 1;
										channel <= channel_cnt; 
								end if;
						end if;
						write_out <= write_buffer;    --Segnala il dato relativo ad ogni canale

				  end if;
		    end if;
		 end process place_nibble;
		
	end behavioral;