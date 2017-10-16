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

entity packet_sender is
Generic(
	constant MAX_PACKET_SIZE 			: integer := 1024;
	constant PACKET_MEMORY_BIT_ADDR		: integer := 10;
	constant PORT_NUMBER                : integer := 1;
	constant PORT_1_TRUE_BRAM			: boolean := false;
	constant PORT_2_TRUE_BRAM			: boolean := false;
	constant PORT_3_TRUE_BRAM			: boolean := false;
	constant PORT_4_TRUE_BRAM			: boolean := false
	
);
Port ( 
		clk 			: in STD_LOGIC;
		rst_n 			: in STD_LOGIC;
        enable          : in STD_LOGIC;
		wclk			: in STD_LOGIC := '0';
		
		dbg_busy_bram   : out STD_LOGIC_VECTOR(3 downto 0);
		dbg_busy        : out STD_LOGIC;
		
		data_byte_0 	: out STD_LOGIC_VECTOR(7 downto 0) := x"00";
		data_valid_0 	: out STD_LOGIC := '0';
		data_byte_1 	: out STD_LOGIC_VECTOR(7 downto 0) := x"00";
		data_valid_1 	: out STD_LOGIC := '0';
		data_byte_2 	: out STD_LOGIC_VECTOR(7 downto 0) := x"00";
		data_valid_2 	: out STD_LOGIC := '0';

		
		packet1_bram_f_clk		: out STD_LOGIC;
		packet1_bram_f_rst		: out STD_LOGIC;
		packet1_bram_f_en		: out STD_LOGIC;	
		packet1_bram_f_wen		: out STD_LOGIC_VECTOR(3 downto 0);	
		packet1_bram_f_addr		: out STD_LOGIC_VECTOR(31 downto 0);	
		packet1_bram_f_dout		: in STD_LOGIC_VECTOR(31 downto 0) := x"00000000";	
		packet1_bram_f_din		: out STD_LOGIC_VECTOR(31 downto 0);	
		
		packet1_bram_s_clk 		: out STD_LOGIC;
		packet1_bram_s_rst		: out STD_LOGIC;
		packet1_bram_s_en 		: out STD_LOGIC;	
		packet1_bram_s_addr 	: out STD_LOGIC_VECTOR(PACKET_MEMORY_BIT_ADDR-1 downto 0);
		packet1_bram_s_dout 	: in STD_LOGIC_VECTOR(7 downto 0):= x"00";
		
		packet1_valid 			: in STD_LOGIC := '0';
		packet1_len 			: in STD_LOGIC_VECTOR(15 downto 0):= x"0000";
		packet1_got 			: out STD_LOGIC;
		
		packet2_bram_f_clk		: out STD_LOGIC;
		packet2_bram_f_rst		: out STD_LOGIC;
		packet2_bram_f_en		: out STD_LOGIC;	
		packet2_bram_f_wen		: out STD_LOGIC_VECTOR(3 downto 0);	
		packet2_bram_f_addr		: out STD_LOGIC_VECTOR(31 downto 0);	
		packet2_bram_f_dout		: in STD_LOGIC_VECTOR(31 downto 0):= x"00000000";
		packet2_bram_f_din		: out STD_LOGIC_VECTOR(31 downto 0);	

		packet2_bram_s_clk 		: out STD_LOGIC;
		packet2_bram_s_rst		: out STD_LOGIC;
		packet2_bram_s_en 		: out STD_LOGIC;
		packet2_bram_s_addr 	: out STD_LOGIC_VECTOR(PACKET_MEMORY_BIT_ADDR-1 downto 0);
		packet2_bram_s_dout 	: in STD_LOGIC_VECTOR(7 downto 0):= x"00";

		packet2_valid 			: in STD_LOGIC := '0';
		packet2_len 			: in STD_LOGIC_VECTOR(15 downto 0):= x"0000";
		packet2_got 			: out STD_LOGIC;
		
		packet3_bram_f_clk		: out STD_LOGIC;
		packet3_bram_f_rst		: out STD_LOGIC;
		packet3_bram_f_en		: out STD_LOGIC;	
		packet3_bram_f_wen		: out STD_LOGIC_VECTOR(3 downto 0);
		packet3_bram_f_addr		: out STD_LOGIC_VECTOR(31 downto 0);	
		packet3_bram_f_dout		: in STD_LOGIC_VECTOR(31 downto 0):= x"00000000";
		packet3_bram_f_din		: out STD_LOGIC_VECTOR(31 downto 0);	

		packet3_bram_s_clk 		: out STD_LOGIC;
		packet3_bram_s_rst		: out STD_LOGIC;
		packet3_bram_s_en 		: out STD_LOGIC;
		packet3_bram_s_addr 	: out STD_LOGIC_VECTOR(PACKET_MEMORY_BIT_ADDR-1 downto 0);
		packet3_bram_s_dout 	: in STD_LOGIC_VECTOR(7 downto 0):= x"00";

		packet3_valid 			: in STD_LOGIC := '0';
		packet3_len 			: in STD_LOGIC_VECTOR(15 downto 0):= x"0000";
		packet3_got 			: out STD_LOGIC;
		
		packet4_bram_f_clk		: out STD_LOGIC;
		packet4_bram_f_rst		: out STD_LOGIC;
		packet4_bram_f_en		: out STD_LOGIC;	
		packet4_bram_f_wen		: out STD_LOGIC_VECTOR(3 downto 0);
		packet4_bram_f_addr		: out STD_LOGIC_VECTOR(31 downto 0);	
		packet4_bram_f_dout		: in STD_LOGIC_VECTOR(31 downto 0):= x"00000000";	
		packet4_bram_f_din		: out STD_LOGIC_VECTOR(31 downto 0);	

		packet4_bram_s_clk 		: out STD_LOGIC;
		packet4_bram_s_rst		: out STD_LOGIC;
		packet4_bram_s_en 		: out STD_LOGIC;
		packet4_bram_s_addr 	: out STD_LOGIC_VECTOR(PACKET_MEMORY_BIT_ADDR-1 downto 0);
		packet4_bram_s_dout 	: in STD_LOGIC_VECTOR(7 downto 0):= x"00";

		packet4_valid 			: in STD_LOGIC := '0';
		packet4_len 			: in STD_LOGIC_VECTOR(15 downto 0):= x"0000";
		packet4_got 			: out STD_LOGIC
);
end packet_sender;

architecture Behavioral of packet_sender is    
	constant MAX_LEN : integer := MAX_PACKET_SIZE-5;
	
	signal data_byte_0_r 	: STD_LOGIC_VECTOR(7 downto 0) := x"00";
	signal data_valid_0_r 	: STD_LOGIC := '0';
	signal data_byte_1_r 	: STD_LOGIC_VECTOR(7 downto 0) := x"00";
	signal data_valid_1_r 	: STD_LOGIC := '0';
	signal data_byte_2_r 	: STD_LOGIC_VECTOR(7 downto 0) := x"00";
	signal data_valid_2_r 	: STD_LOGIC := '0';
	
	signal busy : std_logic;
	signal busy_bram : std_logic_vector(3 downto 0);
	signal packet_len : std_logic_vector(15 downto 0);
	signal read_addr : std_logic_vector(15 downto 0);
	signal read_dout : std_logic_vector(7 downto 0);
	signal wclk_r : std_logic_vector(1 downto 0);
	signal valid : std_logic;
	
	signal state_machine : std_logic_vector(2 downto 0);
	signal wait_valid_down : std_logic;
	
	signal packet1_bram_dout 	: STD_LOGIC_VECTOR(7 downto 0):= x"00";
	signal packet2_bram_dout 	: STD_LOGIC_VECTOR(7 downto 0):= x"00";
	signal packet3_bram_dout 	: STD_LOGIC_VECTOR(7 downto 0):= x"00";
	signal packet4_bram_dout 	: STD_LOGIC_VECTOR(7 downto 0):= x"00";
	
	signal enable_r : STD_LOGIC;
	signal packet1_valid_r 		: STD_LOGIC := '0';
	signal packet1_len_r 		: STD_LOGIC_VECTOR(15 downto 0):= x"0000";


	signal packet2_valid_r 		: STD_LOGIC := '0';
	signal packet2_len_r 		: STD_LOGIC_VECTOR(15 downto 0):= x"0000";


	signal packet3_valid_r 		: STD_LOGIC := '0';
	signal packet3_len_r 		: STD_LOGIC_VECTOR(15 downto 0):= x"0000";


	signal packet4_valid_r 		: STD_LOGIC := '0';
	signal packet4_len_r 		: STD_LOGIC_VECTOR(15 downto 0):= x"0000";

begin

	packet1_bram_f_clk <= clk;
	packet1_bram_s_clk <= clk;
	packet2_bram_f_clk <= clk;
	packet2_bram_s_clk <= clk;
	packet3_bram_f_clk <= clk;
	packet3_bram_s_clk <= clk;
	packet4_bram_f_clk <= clk;
	packet4_bram_s_clk <= clk;

	packet1_bram_f_rst <= not rst_n;
	packet1_bram_s_rst <= not rst_n;
	packet2_bram_f_rst <= not rst_n;	
	packet2_bram_s_rst <= not rst_n;
	packet3_bram_f_rst <= not rst_n;
	packet3_bram_s_rst <= not rst_n;
	packet4_bram_f_rst <= not rst_n;	
	packet4_bram_s_rst <= not rst_n;
	
	packet1_bram_f_en <= enable_r;	
	packet1_bram_s_en <= enable_r;
	packet2_bram_f_en <= enable_r;	
	packet2_bram_s_en <= enable_r;
	packet3_bram_f_en <= enable_r;	
	packet3_bram_s_en <= enable_r;
	packet4_bram_f_en <= enable_r;	
	packet4_bram_s_en <= enable_r;
	
	packet1_bram_f_wen <= "0000";
	packet2_bram_f_wen <= "0000";
	packet3_bram_f_wen <= "0000";
	packet4_bram_f_wen <= "0000";	
		
	
	GEN_BRAM_1_S: if(PORT_1_TRUE_BRAM=false) generate
		packet1_bram_dout <= packet1_bram_s_dout;
	end generate GEN_BRAM_1_S;
	
	GEN_BRAM_1_F: if(PORT_1_TRUE_BRAM=true) generate
		packet1_bram_dout <= 	packet1_bram_f_dout(7 downto 0) when read_addr(1 downto 0)="00" else
								packet1_bram_f_dout(15 downto 8) when read_addr(1 downto 0)="01" else
								packet1_bram_f_dout(23 downto 16) when read_addr(1 downto 0)="10" else
								packet1_bram_f_dout(31 downto 24);
	end generate GEN_BRAM_1_F;
	
	GEN_BRAM_2_S: if(PORT_2_TRUE_BRAM=false) generate
		packet2_bram_dout <= packet2_bram_s_dout;
	end generate GEN_BRAM_2_S;
	
	GEN_BRAM_2_F: if(PORT_2_TRUE_BRAM=true) generate
		packet2_bram_dout <= 	packet2_bram_f_dout(7 downto 0) when read_addr(1 downto 0)="00" else
								packet2_bram_f_dout(15 downto 8) when read_addr(1 downto 0)="01" else
								packet2_bram_f_dout(23 downto 16) when read_addr(1 downto 0)="10" else
								packet2_bram_f_dout(31 downto 24);
	end generate GEN_BRAM_2_F;
	
	GEN_BRAM_3_S: if(PORT_3_TRUE_BRAM=false) generate
		packet3_bram_dout <= packet3_bram_s_dout;
	end generate GEN_BRAM_3_S;
	
	GEN_BRAM_3_F: if(PORT_3_TRUE_BRAM=true) generate
		packet3_bram_dout <= 	packet3_bram_f_dout(7 downto 0) when read_addr(1 downto 0)="00" else
								packet3_bram_f_dout(15 downto 8) when read_addr(1 downto 0)="01" else
								packet3_bram_f_dout(23 downto 16) when read_addr(1 downto 0)="10" else
								packet3_bram_f_dout(31 downto 24);
	end generate GEN_BRAM_3_F;
	
	GEN_BRAM_4_S: if(PORT_4_TRUE_BRAM=false) generate
		packet4_bram_dout <= packet4_bram_s_dout;
	end generate GEN_BRAM_4_S;
	
	GEN_BRAM_4_F: if(PORT_4_TRUE_BRAM=true) generate
		packet4_bram_dout <= 	packet4_bram_f_dout(7 downto 0) when read_addr(1 downto 0)="00" else
								packet4_bram_f_dout(15 downto 8) when read_addr(1 downto 0)="01" else
								packet4_bram_f_dout(23 downto 16) when read_addr(1 downto 0)="10" else
								packet4_bram_f_dout(31 downto 24);
	end generate GEN_BRAM_4_F;
	
	-- read_dout 	<= 	packet1_bram_s_dout when busy_bram="0001" AND PORT_1_TRUE_BRAM=false else
					-- packet1_bram_f_dout(7 downto 0) when busy_bram="0001" AND PORT_1_TRUE_BRAM=true AND read_addr(1 downto 0)="00" else
					-- packet1_bram_f_dout(15 downto 8) when busy_bram="0001" AND PORT_1_TRUE_BRAM=true AND read_addr(1 downto 0)="01" else
					-- packet1_bram_f_dout(23 downto 16) when busy_bram="0001" AND PORT_1_TRUE_BRAM=true AND read_addr(1 downto 0)="10" else
					-- packet1_bram_f_dout(31 downto 24) when busy_bram="0001" AND PORT_1_TRUE_BRAM=true AND read_addr(1 downto 0)="11" else
					-- packet2_bram_s_dout when busy_bram="0010" AND PORT_2_TRUE_BRAM=false else
					-- packet1_bram_f_dout(7 downto 0) when busy_bram="0001" AND PORT_1_TRUE_BRAM=true AND read_addr(1 downto 0)="00" else
					-- packet1_bram_f_dout(15 downto 8) when busy_bram="0001" AND PORT_1_TRUE_BRAM=true AND read_addr(1 downto 0)="01" else
					-- packet1_bram_f_dout(23 downto 16) when busy_bram="0001" AND PORT_1_TRUE_BRAM=true AND read_addr(1 downto 0)="10" else
					-- packet1_bram_f_dout(31 downto 24) when busy_bram="0001" AND PORT_1_TRUE_BRAM=true AND read_addr(1 downto 0)="11" else					
					-- packet3_bram_s_dout when busy_bram="0100" AND PORT_3_TRUE_BRAM=false else
					
					-- packet4_bram_s_dout when busy_bram="1000" AND PORT_4_TRUE_BRAM=false else
					
					-- x"00";
	read_dout 	<= 	packet1_bram_dout when busy_bram="0001" else
					packet2_bram_dout when busy_bram="0010" else
					packet3_bram_dout when busy_bram="0100" else
					packet4_bram_dout when busy_bram="1000" else
					x"00";
					

	packet1_bram_s_addr <= read_addr(PACKET_MEMORY_BIT_ADDR-1 downto 0);
	packet2_bram_s_addr <= read_addr(PACKET_MEMORY_BIT_ADDR-1 downto 0);
    packet3_bram_s_addr <= read_addr(PACKET_MEMORY_BIT_ADDR-1 downto 0);
    packet4_bram_s_addr <= read_addr(PACKET_MEMORY_BIT_ADDR-1 downto 0);

	packet1_bram_f_addr <= x"0000" & read_addr(15 downto 2) & "00";
	packet2_bram_f_addr <= x"0000" & read_addr(15 downto 2) & "00";
    packet3_bram_f_addr <= x"0000" & read_addr(15 downto 2) & "00";
    packet4_bram_f_addr <= x"0000" & read_addr(15 downto 2) & "00";
        
	dbg_busy_bram <= busy_bram;
	dbg_busy <= busy;
	process (rst_n,clk)
	begin
		if(rst_n='0')then
			wclk_r 				<= "00";
			busy 				<= '0';
			packet_len 			<= (others => '0');
			busy_bram 			<= (others => '0');
			data_byte_0_r  		<= (others => '0');	
			data_valid_0_r 		<= '0';	
			data_byte_1_r 	 	<= (others => '0');
			data_valid_1_r 		<= '0';
			data_byte_2_r  		<= (others => '0');	
			data_valid_2_r 		<= '0';
			state_machine 		<= (others => '0');
			valid <= '0';
			packet1_got <= '0';
			packet2_got <= '0';
			packet3_got <= '0';
			packet4_got <= '0';
			wait_valid_down <= '0';
			read_addr <= (others => '0');
			enable_r <= '0';
			packet1_valid_r 	<= '0';
			packet1_len_r 		<= (others => '0');
			packet2_valid_r 	<= '0';
			packet2_len_r 		<= (others => '0');
			packet3_valid_r 	<= '0';
			packet3_len_r 		<= (others => '0');
			packet4_valid_r 	<= '0';
			packet4_len_r 		<= (others => '0');
		elsif rising_edge(clk)then
		    enable_r <= enable;
		    if(enable_r='0')then
		      	wclk_r 				<= "00";
                busy                 <= '0';
                packet_len             <= (others => '0');
                busy_bram             <= (others => '0');
                data_byte_0_r          <= (others => '0');    
                data_valid_0_r         <= '0';    
                data_byte_1_r          <= (others => '0');
                data_valid_1_r         <= '0';
                data_byte_2_r          <= (others => '0');    
                data_valid_2_r         <= '0';
                state_machine         <= (others => '0');
                valid <= '0';
                packet1_got <= '0';
                packet2_got <= '0';
                packet3_got <= '0';
                packet4_got <= '0';
				packet1_valid_r 	<= '0';
				packet1_len_r 		<= (others => '0');
				packet2_valid_r 	<= '0';
				packet2_len_r 		<= (others => '0');
				packet3_valid_r 	<= '0';
				packet3_len_r 		<= (others => '0');
				packet4_valid_r 	<= '0';
				packet4_len_r 		<= (others => '0');
                wait_valid_down <= '0';
                read_addr <= (others => '0');
		    else
				packet1_valid_r 	<= packet1_valid; 	
				packet1_len_r 		<= packet1_len;
				packet2_valid_r 	<= packet2_valid;
				packet2_len_r 		<= packet2_len;	
				packet3_valid_r 	<= packet3_valid;
				packet3_len_r 		<= packet3_len;	
				packet4_valid_r 	<= packet4_valid;
				packet4_len_r 		<= packet4_len;	
				
                wclk_r <= wclk_r(0) & wclk;
                if(busy='0')then
                    if(wclk_r="01")then
                        data_byte_0  		<= (others => '0');	
                        data_valid_0 		<= '0';	
                        data_byte_1		 	<= (others => '0');
                        data_valid_1 		<= '0';
                        data_byte_2  		<= (others => '0');	
                        data_valid_2 		<= '0';
                    end if;
                    
                    if(packet1_valid_r='1')then 
                        busy <= '1';
                        busy_bram <= "0001";
                        packet_len(PACKET_MEMORY_BIT_ADDR-1 downto 0) <= packet1_len_r(PACKET_MEMORY_BIT_ADDR-1 downto 0);
                    elsif (packet2_valid_r='1')then 
                        busy <= '1';
                        busy_bram <= "0010";
                        packet_len(PACKET_MEMORY_BIT_ADDR-1 downto 0) <= packet2_len_r(PACKET_MEMORY_BIT_ADDR-1 downto 0);
                    elsif (packet3_valid_r='1')then 
                        busy <= '1';
                        busy_bram <= "0100";
                        packet_len(PACKET_MEMORY_BIT_ADDR-1 downto 0) <= packet3_len_r(PACKET_MEMORY_BIT_ADDR-1 downto 0);
                    elsif (packet4_valid_r='1')then 
                        busy <= '1';
                        busy_bram <= "1000";
                        packet_len(PACKET_MEMORY_BIT_ADDR-1 downto 0) <= packet4_len_r(PACKET_MEMORY_BIT_ADDR-1 downto 0);
					else
						busy <= '0';
						busy_bram <= "0000";
                    end if;
					state_machine <= "000";
					read_addr <= (others => '0');

                else
                    if(wait_valid_down='1')then
                        if(wclk_r="01")then
                            data_byte_0  		<= (others => '0');	
                            data_valid_0 		<= '0';	
                            data_byte_1 	 	<= (others => '0');
                            data_valid_1 		<= '0';
                            data_byte_2  		<= (others => '0');	
                            data_valid_2 		<= '0';
                        end if;
                        
                        if(((busy_bram(0)='1')AND(packet1_valid_r='0'))
                            OR	((busy_bram(1)='1')AND(packet2_valid_r='0'))
                            OR	((busy_bram(2)='1')AND(packet3_valid_r='0'))
                            OR	((busy_bram(3)='1')AND(packet4_valid_r='0'))) then
                            -- wait for valid flag to be cleared
                            busy <= '0';
                            wait_valid_down <= '0';
                            packet1_got <= '0';
                            packet2_got <= '0';
                            packet3_got <= '0';
                            packet4_got <= '0';
							busy_bram <= "0000";
                        end if;
                    else
    
                        if(state_machine < "110")then
                            if(wclk_r="01")then
                                data_byte_0  		<= (others => '0');	
                                data_valid_0 		<= '0';	
                                data_byte_1 	 	<= (others => '0');
                                data_valid_1 		<= '0';
                                data_byte_2  		<= (others => '0');	
                                data_valid_2 		<= '0';
                            end if;
                            
                            if(state_machine(0)='0')then
                                if(read_addr<packet_len) then
                                    valid <= '1';
                                else
                                    valid <= '0';
                                end if;
                            else
                                if(state_machine(2 downto 1)="00") then
                                    data_byte_0_r <= read_dout;
                                    data_valid_0_r <= valid;
                                elsif(state_machine(2 downto 1)="01") then
                                    data_byte_1_r <= read_dout;
                                    data_valid_1_r <= valid;	
                                else
                                    data_byte_2_r <= read_dout;
                                    data_valid_2_r <= valid;
                                end if;
                                read_addr <= read_addr +1;
                                
                            end if;
                            
                            state_machine <= state_machine+1;
                        else 
                            if(wclk_r="01")then
                                data_byte_0		<= data_byte_0_r;
                                data_valid_0	<= data_valid_0_r;
                                data_byte_1		<= data_byte_1_r;
                                data_valid_1	<= data_valid_1_r;
                                data_byte_2		<= data_byte_2_r;
                                data_valid_2	<= data_valid_2_r;
                                state_machine	<= "000";
                                
                                if(read_addr>=packet_len)then
                                    wait_valid_down <= '1';
                                    -- clear valid flag on the current bram
                                    packet1_got <= busy_bram(0);
                                    packet2_got <= busy_bram(1);
                                    packet3_got <= busy_bram(2);
                                    packet4_got <= busy_bram(3);
                                end if;
                            end if;
                        end if;
                    end if;
                end if;
			end if;
		end if;	
	end process;

end Behavioral;
