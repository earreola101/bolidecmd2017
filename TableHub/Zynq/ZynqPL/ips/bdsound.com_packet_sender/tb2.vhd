----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.04.2017 10:42:46
-- Design Name: 
-- Module Name: tb - Behavioral
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
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb2 is
--  Port ( );
end tb2;


architecture Behavioral of tb2 is
	constant MAX_PACKET_SIZE 			: integer := 1024;
	constant CIRCULAR_MEMORY_SIZE 		: integer := 4096;
	constant CIRCULAR_MEMORY_BIT_ADDR	: integer := 12;
	constant PACKET_MEMORY_BIT_ADDR		: integer := 10;
	constant TRUE_BRAM					: boolean := false;
	
	component packet_recover is
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

		wclk			: in STD_LOGIC := '0';
		
		data_byte_0 	: in STD_LOGIC_VECTOR(7 downto 0) := x"00";
		data_valid_0 	: in STD_LOGIC := '0';

		data_byte_1 	: in STD_LOGIC_VECTOR(7 downto 0) := x"00";
		data_valid_1 	: in STD_LOGIC := '0';

		data_byte_2 	: in STD_LOGIC_VECTOR(7 downto 0) := x"00";
		data_valid_2 	: in STD_LOGIC := '0';

		circular_bram_w_clk 	: out STD_LOGIC;
		circular_bram_w_en 		: out STD_LOGIC;
		circular_bram_w_wen		: out STD_LOGIC;	
		circular_bram_w_addr 	: out STD_LOGIC_VECTOR(CIRCULAR_MEMORY_BIT_ADDR-1 downto 0);
		circular_bram_w_data 	: out STD_LOGIC_VECTOR(7 downto 0);
		
		circular_bram_r_clk		: out STD_LOGIC;
		circular_bram_r_en		: out STD_LOGIC;
		circular_bram_r_addr 	: out STD_LOGIC_VECTOR(CIRCULAR_MEMORY_BIT_ADDR-1 downto 0);
		circular_bram_r_data 	: in STD_LOGIC_VECTOR(7 downto 0);
		
		packet_bram_f_clk		: out STD_LOGIC;
		packet_bram_f_rst		: out STD_LOGIC;
		packet_bram_f_en		: out STD_LOGIC;	
		packet_bram_f_wen		: out STD_LOGIC_VECTOR(3 downto 0);
		packet_bram_f_addr		: out STD_LOGIC_VECTOR(31 downto 0);	
		packet_bram_f_dout		: in STD_LOGIC_VECTOR(31 downto 0);	
		packet_bram_f_din		: out STD_LOGIC_VECTOR(31 downto 0):= x"00000000";
		
		packet_bram_s_clk 		: out STD_LOGIC;
		packet_bram_s_en 		: out STD_LOGIC;
		packet_bram_s_wen		: out STD_LOGIC;	
		packet_bram_s_addr 		: out STD_LOGIC_VECTOR(PACKET_MEMORY_BIT_ADDR-1 downto 0);
		packet_bram_s_data 		: out STD_LOGIC_VECTOR(7 downto 0);
		
		
		packet_valid 			: out STD_LOGIC;
		packet_len 				: out STD_LOGIC_VECTOR(15 downto 0);
		packet_got 				: in STD_LOGIC
	);
	end component;

	component packet_sender is
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

		wclk			: in STD_LOGIC := '0';
		
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
	end component;
	
	component bus_transmitter is
    Generic(
        constant AUDIO_CHANNELS : integer := 15
    );
    Port ( 
        clk             : in STD_LOGIC;
        rst_n             : in STD_LOGIC;
        enable            : in STD_LOGIC;
		
        dout             : out STD_LOGIC;
        wclk            : in STD_LOGIC;
        
        data_byte_0     : in STD_LOGIC_VECTOR(7 downto 0);
        data_valid_0     : in STD_LOGIC;
        
        data_byte_1     : in STD_LOGIC_VECTOR(7 downto 0);
        data_valid_1     : in STD_LOGIC;
        
        data_byte_2     : in STD_LOGIC_VECTOR(7 downto 0);
        data_valid_2     : in STD_LOGIC;
        
        audio_data_0     : in STD_LOGIC_VECTOR(23 downto 0);
        audio_valid_0     : in STD_LOGIC;
        audio_mute_0     : in STD_LOGIC;
            
        audio_data_1     : in STD_LOGIC_VECTOR(23 downto 0);
        audio_valid_1     : in STD_LOGIC;
        audio_mute_1     : in STD_LOGIC;
            
        audio_data_2     : in STD_LOGIC_VECTOR(23 downto 0);
        audio_valid_2     : in STD_LOGIC;
        audio_mute_2     : in STD_LOGIC;
            
        audio_data_3     : in STD_LOGIC_VECTOR(23 downto 0);
        audio_valid_3     : in STD_LOGIC;
        audio_mute_3     : in STD_LOGIC;
            
        audio_data_4     : in STD_LOGIC_VECTOR(23 downto 0);
        audio_valid_4     : in STD_LOGIC;
        audio_mute_4     : in STD_LOGIC;
            
        audio_data_5     : in STD_LOGIC_VECTOR(23 downto 0);
        audio_valid_5     : in STD_LOGIC;
        audio_mute_5     : in STD_LOGIC;
            
        audio_data_6     : in STD_LOGIC_VECTOR(23 downto 0);
        audio_valid_6     : in STD_LOGIC;
        audio_mute_6     : in STD_LOGIC;
            
        audio_data_7     : in STD_LOGIC_VECTOR(23 downto 0);
        audio_valid_7     : in STD_LOGIC;
        audio_mute_7     : in STD_LOGIC;
        
        audio_data_8     : in STD_LOGIC_VECTOR(23 downto 0);
        audio_valid_8     : in STD_LOGIC;
        audio_mute_8     : in STD_LOGIC;
            
        audio_data_9     : in STD_LOGIC_VECTOR(23 downto 0);
        audio_valid_9     : in STD_LOGIC;
        audio_mute_9     : in STD_LOGIC;
            
        audio_data_10     : in STD_LOGIC_VECTOR(23 downto 0);
        audio_valid_10     : in STD_LOGIC;
        audio_mute_10     : in STD_LOGIC;
            
        audio_data_11     : in STD_LOGIC_VECTOR(23 downto 0);
        audio_valid_11     : in STD_LOGIC;
        audio_mute_11     : in STD_LOGIC;
            
        audio_data_12     : in STD_LOGIC_VECTOR(23 downto 0);
        audio_valid_12     : in STD_LOGIC;
        audio_mute_12     : in STD_LOGIC;
            
        audio_data_13     : in STD_LOGIC_VECTOR(23 downto 0);
        audio_valid_13     : in STD_LOGIC;
        audio_mute_13     : in STD_LOGIC;
            
        audio_data_14     : in STD_LOGIC_VECTOR(23 downto 0);
        audio_valid_14     : in STD_LOGIC;
        audio_mute_14     : in STD_LOGIC
        
    );
    end component;
	COMPONENT blk_mem_gen_0
      PORT (
        clka : IN STD_LOGIC;
        ena : IN STD_LOGIC;
        wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        clkb : IN STD_LOGIC;
        enb : IN STD_LOGIC;
        addrb : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        doutb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
      );
    END COMPONENT;
    
	COMPONENT blk_mem_gen_1
      PORT (
        clka : IN STD_LOGIC;
        ena : IN STD_LOGIC;
        wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addra : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
        dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        clkb : IN STD_LOGIC;
        enb : IN STD_LOGIC;
        addrb : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
        doutb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
      );
    END COMPONENT;
	
    COMPONENT MarsZX3_blk_mem_gen_2_0
      PORT (
        clka : IN STD_LOGIC;
        rsta : IN STD_LOGIC;
        ena : IN STD_LOGIC;
        wea : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        addra : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        clkb : IN STD_LOGIC;
        rstb : IN STD_LOGIC;
        enb : IN STD_LOGIC;
        web : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        addrb : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        dinb : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        doutb : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
      );
    END COMPONENT;
    
    
    type data_vector_t is array(31 downto 0) of std_logic_vector(7 downto 0);
	
	
		component bus_receiver is
    Generic(
        constant AUDIO_CHANNELS : integer := 15
    );
    Port ( 
        clk_0             : in STD_LOGIC;
        clk_90             : in STD_LOGIC;
        clk_180            : in STD_LOGIC;
        clk_270            : in STD_LOGIC;
        rst_n             : in STD_LOGIC;
        enable            : in STD_LOGIC;
        
        din             : in STD_LOGIC;
        
        wclk            : out STD_LOGIC;
        
        data_byte_0     : out STD_LOGIC_VECTOR(7 downto 0);
        data_valid_0     : out STD_LOGIC;

        data_byte_1     : out STD_LOGIC_VECTOR(7 downto 0);
        data_valid_1     : out STD_LOGIC;

        data_byte_2     : out STD_LOGIC_VECTOR(7 downto 0);
        data_valid_2     : out STD_LOGIC;

        audio_data_0     : out STD_LOGIC_VECTOR(23 downto 0);
        audio_valid_0     : out STD_LOGIC;
        audio_mute_0     : out STD_LOGIC;

        audio_data_1     : out STD_LOGIC_VECTOR(23 downto 0);
        audio_valid_1     : out STD_LOGIC;
        audio_mute_1     : out STD_LOGIC;

        audio_data_2     : out STD_LOGIC_VECTOR(23 downto 0);
        audio_valid_2     : out STD_LOGIC;
        audio_mute_2     : out STD_LOGIC;

        audio_data_3     : out STD_LOGIC_VECTOR(23 downto 0);
        audio_valid_3     : out STD_LOGIC;
        audio_mute_3     : out STD_LOGIC;

        audio_data_4     : out STD_LOGIC_VECTOR(23 downto 0);
        audio_valid_4     : out STD_LOGIC;
        audio_mute_4     : out STD_LOGIC;

        audio_data_5     : out STD_LOGIC_VECTOR(23 downto 0);
        audio_valid_5     : out STD_LOGIC;
        audio_mute_5     : out STD_LOGIC;
             
        audio_data_6     : out STD_LOGIC_VECTOR(23 downto 0);
        audio_valid_6     : out STD_LOGIC;
        audio_mute_6     : out STD_LOGIC;
            
        audio_data_7     : out STD_LOGIC_VECTOR(23 downto 0);
        audio_valid_7     : out STD_LOGIC;
        audio_mute_7     : out STD_LOGIC;
           
        audio_data_8     : out STD_LOGIC_VECTOR(23 downto 0);
        audio_valid_8     : out STD_LOGIC;
        audio_mute_8     : out STD_LOGIC;
        
        audio_data_9     : out STD_LOGIC_VECTOR(23 downto 0);
        audio_valid_9     : out STD_LOGIC;
        audio_mute_9     : out STD_LOGIC;
             
        audio_data_10     : out STD_LOGIC_VECTOR(23 downto 0);
        audio_valid_10     : out STD_LOGIC;
        audio_mute_10     : out STD_LOGIC;
        
        audio_data_11     : out STD_LOGIC_VECTOR(23 downto 0);
        audio_valid_11     : out STD_LOGIC;
        audio_mute_11     : out STD_LOGIC;
        
        audio_data_12     : out STD_LOGIC_VECTOR(23 downto 0);
        audio_valid_12     : out STD_LOGIC;
        audio_mute_12     : out STD_LOGIC;
            
        audio_data_13     : out STD_LOGIC_VECTOR(23 downto 0);
        audio_valid_13     : out STD_LOGIC;
        audio_mute_13     : out STD_LOGIC;
              
        audio_data_14     : out STD_LOGIC_VECTOR(23 downto 0);
        audio_valid_14     : out STD_LOGIC;
        audio_mute_14     : out STD_LOGIC
        
    );
    end component;
    
    signal rx_data_byte_0         : STD_LOGIC_VECTOR(7 downto 0);
    signal rx_data_valid_0     : STD_LOGIC;
    signal rx_data_byte_1         : STD_LOGIC_VECTOR(7 downto 0);
    signal rx_data_valid_1     : STD_LOGIC;
    signal rx_data_byte_2         : STD_LOGIC_VECTOR(7 downto 0);
    signal rx_data_valid_2     : STD_LOGIC;
    signal rx_audio_data_0     : STD_LOGIC_VECTOR(23 downto 0);
    signal rx_audio_valid_0     : STD_LOGIC;
    signal rx_audio_mute_0     : STD_LOGIC;
    signal rx_audio_data_1     : STD_LOGIC_VECTOR(23 downto 0);
    signal rx_audio_valid_1     : STD_LOGIC;
    signal rx_audio_mute_1     : STD_LOGIC;
    signal rx_audio_data_2     : STD_LOGIC_VECTOR(23 downto 0);
    signal rx_audio_valid_2     : STD_LOGIC;
    signal rx_audio_mute_2     : STD_LOGIC;
    signal rx_audio_data_3     : STD_LOGIC_VECTOR(23 downto 0);
    signal rx_audio_valid_3     : STD_LOGIC;
    signal rx_audio_mute_3     : STD_LOGIC;
    signal rx_audio_data_4     : STD_LOGIC_VECTOR(23 downto 0);
    signal rx_audio_valid_4     : STD_LOGIC;
    signal rx_audio_mute_4     : STD_LOGIC;
    signal rx_audio_data_5     : STD_LOGIC_VECTOR(23 downto 0);
    signal rx_audio_valid_5     : STD_LOGIC;
    signal rx_audio_mute_5     : STD_LOGIC;
    signal rx_audio_data_6     : STD_LOGIC_VECTOR(23 downto 0);
    signal rx_audio_valid_6     : STD_LOGIC;
    signal rx_audio_mute_6     : STD_LOGIC;
    signal rx_audio_data_7     : STD_LOGIC_VECTOR(23 downto 0);
    signal rx_audio_valid_7     : STD_LOGIC;
    signal rx_audio_mute_7     : STD_LOGIC;
    signal rx_audio_data_8     : STD_LOGIC_VECTOR(23 downto 0);
    signal rx_audio_valid_8     : STD_LOGIC;
    signal rx_audio_mute_8     : STD_LOGIC;
    signal rx_audio_data_9     : STD_LOGIC_VECTOR(23 downto 0);
    signal rx_audio_valid_9     : STD_LOGIC;
    signal rx_audio_mute_9     : STD_LOGIC;
    signal rx_audio_data_10     : STD_LOGIC_VECTOR(23 downto 0);
    signal rx_audio_valid_10     : STD_LOGIC;
    signal rx_audio_mute_10     : STD_LOGIC;
    signal rx_audio_data_11     : STD_LOGIC_VECTOR(23 downto 0);
    signal rx_audio_valid_11     : STD_LOGIC;
    signal rx_audio_mute_11     : STD_LOGIC;
    signal rx_audio_data_12     : STD_LOGIC_VECTOR(23 downto 0);
    signal rx_audio_valid_12     : STD_LOGIC;
    signal rx_audio_mute_12     : STD_LOGIC;
    signal rx_audio_data_13     : STD_LOGIC_VECTOR(23 downto 0);
    signal rx_audio_valid_13     : STD_LOGIC;
    signal rx_audio_mute_13     : STD_LOGIC;
    signal rx_audio_data_14     : STD_LOGIC_VECTOR(23 downto 0);
    signal rx_audio_valid_14     : STD_LOGIC;
    signal rx_audio_mute_14     : STD_LOGIC;
             

    signal tx_data_byte_0         : STD_LOGIC_VECTOR(7 downto 0) := x"00";
    signal tx_data_valid_0     : STD_LOGIC := '0';
    signal tx_data_byte_1         : STD_LOGIC_VECTOR(7 downto 0) := x"00";
    signal tx_data_valid_1     : STD_LOGIC := '0';
    signal tx_data_byte_2         : STD_LOGIC_VECTOR(7 downto 0) := x"00";
    signal tx_data_valid_2     : STD_LOGIC := '0';
    signal tx_audio_data_0     : STD_LOGIC_VECTOR(23 downto 0) := x"000000";
    signal tx_audio_valid_0     : STD_LOGIC := '0';
    signal tx_audio_mute_0     : STD_LOGIC := '0';
    signal tx_audio_data_1     : STD_LOGIC_VECTOR(23 downto 0) := x"000000";
    signal tx_audio_valid_1     : STD_LOGIC := '0';
    signal tx_audio_mute_1     : STD_LOGIC := '0';
    signal tx_audio_data_2     : STD_LOGIC_VECTOR(23 downto 0) := x"000000";
    signal tx_audio_valid_2     : STD_LOGIC := '0';
    signal tx_audio_mute_2     : STD_LOGIC := '0';
    signal tx_audio_data_3     : STD_LOGIC_VECTOR(23 downto 0) := x"000000";
    signal tx_audio_valid_3     : STD_LOGIC := '0';
    signal tx_audio_mute_3     : STD_LOGIC := '0';
    signal tx_audio_data_4     : STD_LOGIC_VECTOR(23 downto 0) := x"000000";
    signal tx_audio_valid_4     : STD_LOGIC := '0';
    signal tx_audio_mute_4     : STD_LOGIC := '0';
    signal tx_audio_data_5     : STD_LOGIC_VECTOR(23 downto 0) := x"000000";
    signal tx_audio_valid_5     : STD_LOGIC := '0';
    signal tx_audio_mute_5     : STD_LOGIC := '0';
    signal tx_audio_data_6     : STD_LOGIC_VECTOR(23 downto 0) := x"000000";
    signal tx_audio_valid_6     : STD_LOGIC := '0';
    signal tx_audio_mute_6     : STD_LOGIC := '0';
    signal tx_audio_data_7     : STD_LOGIC_VECTOR(23 downto 0) := x"000000";
    signal tx_audio_valid_7     : STD_LOGIC := '0';
    signal tx_audio_mute_7     : STD_LOGIC := '0';
    signal tx_audio_data_8     : STD_LOGIC_VECTOR(23 downto 0) := x"000000";
    signal tx_audio_valid_8     : STD_LOGIC := '0';
    signal tx_audio_mute_8     : STD_LOGIC := '0';
    signal tx_audio_data_9     : STD_LOGIC_VECTOR(23 downto 0) := x"000000";
    signal tx_audio_valid_9     : STD_LOGIC := '0';
    signal tx_audio_mute_9     : STD_LOGIC := '0';
    signal tx_audio_data_10     : STD_LOGIC_VECTOR(23 downto 0) := x"000000";
    signal tx_audio_valid_10     : STD_LOGIC := '0';
    signal tx_audio_mute_10     : STD_LOGIC := '0';
    signal tx_audio_data_11     : STD_LOGIC_VECTOR(23 downto 0) := x"000000";
    signal tx_audio_valid_11     : STD_LOGIC := '0';
    signal tx_audio_mute_11     : STD_LOGIC := '0';
    signal tx_audio_data_12     : STD_LOGIC_VECTOR(23 downto 0) := x"000000";
    signal tx_audio_valid_12     : STD_LOGIC := '0';
    signal tx_audio_mute_12     : STD_LOGIC := '0';
    signal tx_audio_data_13     : STD_LOGIC_VECTOR(23 downto 0) := x"000000";
    signal tx_audio_valid_13     : STD_LOGIC := '0';
    signal tx_audio_mute_13     : STD_LOGIC := '0';
    signal tx_audio_data_14     : STD_LOGIC_VECTOR(23 downto 0) := x"000000";
    signal tx_audio_valid_14     : STD_LOGIC := '0';
    signal tx_audio_mute_14     : STD_LOGIC := '0';
    
	
	signal clk 				: STD_LOGIC;
	signal clk_0 		    : STD_LOGIC;
	signal clk_90 	    	: STD_LOGIC;
	signal clk_180			: STD_LOGIC;
	signal clk_270			: STD_LOGIC;
	signal rst_n			: STD_LOGIC;
	signal rst			: STD_LOGIC;
        
	signal wclk_in				: STD_LOGIC;
	signal wclk_out				: STD_LOGIC;
	signal wclk_counter 	: integer := 0;
		
	
    constant AUDIO_CHANNELS : integer := 7;
    -- constant AUDIO_CHANNELS : integer := 11;
    -- constant AUDIO_CHANNELS : integer := 15;        
    constant CLK_FREQ : integer :=     (AUDIO_CHANNELS+1)*32000*40;
    constant CLK_FREQ_1 : integer := (AUDIO_CHANNELS+1)*32032*40;
    constant CLK_FREQ_2 : integer := (AUDIO_CHANNELS+1)*31968*40;
    constant clk_period_tx : time := 1000 ms / real(CLK_FREQ);
    constant clk_period_rx : time := 1000 ms / real(CLK_FREQ);
    -- constant clk_period_rx : time := 1000 ms / real(CLK_FREQ_1); -- +0.1%
    --constant clk_period_rx : time := 1000 ms / real(CLK_FREQ_2); -- -0.1%

    constant WCLK_RATIO : integer := (AUDIO_CHANNELS+1)*40;

	
	signal data_byte_0 				: STD_LOGIC_VECTOR(7 downto 0) := x"00";
	signal data_valid_0 			: STD_LOGIC := '0';
	signal data_byte_1 				: STD_LOGIC_VECTOR(7 downto 0) := x"00";
	signal data_valid_1 			: STD_LOGIC := '0';
	signal data_byte_2 				: STD_LOGIC_VECTOR(7 downto 0) := x"00";
	signal data_valid_2 			: STD_LOGIC := '0';

	signal packet1_bram_f_clk		: STD_LOGIC;
	signal packet1_bram_f_rst		: STD_LOGIC;
	signal packet1_bram_f_en		: STD_LOGIC;	
	signal packet1_bram_f_wen		: STD_LOGIC_VECTOR(3 downto 0);	
	signal packet1_bram_f_addr		: STD_LOGIC_VECTOR(31 downto 0);	
	signal packet1_bram_f_dout		: STD_LOGIC_VECTOR(31 downto 0);	
	signal packet1_bram_f_din		: STD_LOGIC_VECTOR(31 downto 0);	

	signal packet1_bram_s_clk 		: STD_LOGIC;
	signal packet1_bram_s_rst		: STD_LOGIC;
	signal packet1_bram_s_en 		: STD_LOGIC;	
	signal packet1_bram_s_addr 		: STD_LOGIC_VECTOR(9 downto 0);
	signal packet1_bram_s_dout 		: STD_LOGIC_VECTOR(7 downto 0);

	signal packet1_valid 			: STD_LOGIC := '0';
	signal packet1_len 				: STD_LOGIC_VECTOR(15 downto 0);
	signal packet1_got 				: STD_LOGIC;
	signal state_1					: STD_LOGIC_VECTOR(2 downto 0);
	signal counter_byte_1 			: integer := 0;
	
	signal we_1_s                  : STD_LOGIC_VECTOR(0 downto 0);
    signal addr_1_s                : STD_LOGIC_VECTOR(9 DOWNTO 0);
    signal din_1_s                 : STD_LOGIC_VECTOR(7 DOWNTO 0);	
	signal en_1_f 					: STD_LOGIC;
    signal we_1_f 					: STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal addr_1_f 				: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal din_1_f 					: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal dout_1_f 				: STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal packet_to_send_1_s 		: data_vector_t := (others => (others => '0'));
	signal packet_to_send_1_f 		: data_vector_t := (others => (others => '0'));

	signal packet2_bram_f_clk		: STD_LOGIC;
	signal packet2_bram_f_rst		: STD_LOGIC;
	signal packet2_bram_f_en		: STD_LOGIC;	
	signal packet2_bram_f_wen		: STD_LOGIC_VECTOR(3 downto 0);	
	signal packet2_bram_f_addr		: STD_LOGIC_VECTOR(31 downto 0);	
	signal packet2_bram_f_dout		: STD_LOGIC_VECTOR(31 downto 0);	
	signal packet2_bram_f_din		: STD_LOGIC_VECTOR(31 downto 0);	

	signal packet2_bram_s_clk 		: STD_LOGIC;
	signal packet2_bram_s_rst		: STD_LOGIC;
	signal packet2_bram_s_en 		: STD_LOGIC;	
	signal packet2_bram_s_addr 		: STD_LOGIC_VECTOR(9 downto 0);
	signal packet2_bram_s_dout 		: STD_LOGIC_VECTOR(7 downto 0);

	signal packet2_valid 			: STD_LOGIC := '0';
	signal packet2_len 				: STD_LOGIC_VECTOR(15 downto 0);
	signal packet2_got 				: STD_LOGIC;
	signal state_2					: STD_LOGIC_VECTOR(2 downto 0);
	signal counter_byte_2 			: integer := 0;
	
	signal we_2_s                  : STD_LOGIC_VECTOR(0 downto 0);
    signal addr_2_s                : STD_LOGIC_VECTOR(9 DOWNTO 0);
    signal din_2_s                 : STD_LOGIC_VECTOR(7 DOWNTO 0);	
	signal en_2_f 					: STD_LOGIC;
    signal we_2_f 					: STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal addr_2_f 				: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal din_2_f 					: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal dout_2_f 				: STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal packet_to_send_2_s 		: data_vector_t := (others => (others => '0'));
	signal packet_to_send_2_f 		: data_vector_t := (others => (others => '0'));

	signal packet3_bram_f_clk		: STD_LOGIC;
	signal packet3_bram_f_rst		: STD_LOGIC;
	signal packet3_bram_f_en		: STD_LOGIC;	
	signal packet3_bram_f_wen		: STD_LOGIC_VECTOR(3 downto 0);	
	signal packet3_bram_f_addr		: STD_LOGIC_VECTOR(31 downto 0);	
	signal packet3_bram_f_dout		: STD_LOGIC_VECTOR(31 downto 0);	
	signal packet3_bram_f_din		: STD_LOGIC_VECTOR(31 downto 0);	

	signal packet3_bram_s_clk 		: STD_LOGIC;
	signal packet3_bram_s_rst		: STD_LOGIC;
	signal packet3_bram_s_en 		: STD_LOGIC;	
	signal packet3_bram_s_addr 		: STD_LOGIC_VECTOR(9 downto 0);
	signal packet3_bram_s_dout 		: STD_LOGIC_VECTOR(7 downto 0);

	signal packet3_valid 			: STD_LOGIC := '0';
	signal packet3_len 				: STD_LOGIC_VECTOR(15 downto 0);
	signal packet3_got 				: STD_LOGIC;
	signal state_3					: STD_LOGIC_VECTOR(2 downto 0);
	signal counter_byte_3 			: integer := 0;
	
	signal we_3_s                  : STD_LOGIC_VECTOR(0 downto 0);
    signal addr_3_s                : STD_LOGIC_VECTOR(9 DOWNTO 0);
    signal din_3_s                 : STD_LOGIC_VECTOR(7 DOWNTO 0);	
	signal en_3_f 					: STD_LOGIC;
    signal we_3_f 					: STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal addr_3_f 				: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal din_3_f 					: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal dout_3_f 				: STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal packet_to_send_3_s 		: data_vector_t := (others => (others => '0'));
	signal packet_to_send_3_f 		: data_vector_t := (others => (others => '0'));


	signal packet4_bram_f_clk		: STD_LOGIC;
	signal packet4_bram_f_rst		: STD_LOGIC;
	signal packet4_bram_f_en		: STD_LOGIC;	
	signal packet4_bram_f_wen		: STD_LOGIC_VECTOR(3 downto 0);	
	signal packet4_bram_f_addr		: STD_LOGIC_VECTOR(31 downto 0);	
	signal packet4_bram_f_dout		: STD_LOGIC_VECTOR(31 downto 0);	
	signal packet4_bram_f_din		: STD_LOGIC_VECTOR(31 downto 0);	

	signal packet4_bram_s_clk 		: STD_LOGIC;
	signal packet4_bram_s_rst		: STD_LOGIC;
	signal packet4_bram_s_en 		: STD_LOGIC;	
	signal packet4_bram_s_addr 		: STD_LOGIC_VECTOR(9 downto 0);
	signal packet4_bram_s_dout 		: STD_LOGIC_VECTOR(7 downto 0);

	signal packet4_valid 			: STD_LOGIC := '0';
	signal packet4_len 				: STD_LOGIC_VECTOR(15 downto 0);
	signal packet4_got 				: STD_LOGIC;
	signal state_4					: STD_LOGIC_VECTOR(2 downto 0);
	signal counter_byte_4 			: integer := 0;
	
	signal we_4_s                  : STD_LOGIC_VECTOR(0 downto 0);
    signal addr_4_s                : STD_LOGIC_VECTOR(9 DOWNTO 0);
    signal din_4_s                 : STD_LOGIC_VECTOR(7 DOWNTO 0);	
	signal en_4_f 					: STD_LOGIC;
    signal we_4_f 					: STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal addr_4_f 				: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal din_4_f 					: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal dout_4_f 				: STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal packet_to_send_4_s 		: data_vector_t := (others => (others => '0'));
	signal packet_to_send_4_f 		: data_vector_t := (others => (others => '0'));

	
	

	signal circular_bram_w_clk 		:  STD_LOGIC;
	signal circular_bram_w_en 		:  STD_LOGIC;
	signal circular_bram_w_wen		:  STD_LOGIC_VECTOR(0 downto 0);	
	signal circular_bram_w_addr 	:  STD_LOGIC_VECTOR(CIRCULAR_MEMORY_BIT_ADDR-1 downto 0);
	signal circular_bram_w_data 	:  STD_LOGIC_VECTOR(7 downto 0);

	signal circular_bram_r_clk		:  STD_LOGIC;
	signal circular_bram_r_en		:  STD_LOGIC;
	signal circular_bram_r_addr 	:  STD_LOGIC_VECTOR(CIRCULAR_MEMORY_BIT_ADDR-1 downto 0);
	signal circular_bram_r_data 	:  STD_LOGIC_VECTOR(7 downto 0);

	signal packet_bram_s_clk 		:  STD_LOGIC;
	signal packet_bram_s_en 		:  STD_LOGIC;
	signal packet_bram_s_wen		:  STD_LOGIC_VECTOR(0 downto 0);	
	signal packet_bram_s_addr 		:  STD_LOGIC_VECTOR(PACKET_MEMORY_BIT_ADDR-1 downto 0);
	signal packet_bram_s_data 		:  STD_LOGIC_VECTOR(7 downto 0);

	
	signal packet_bram_f_clk		: STD_LOGIC;
	signal packet_bram_f_rst		: STD_LOGIC;
	signal packet_bram_f_en		: STD_LOGIC;	
	signal packet_bram_f_wen		: STD_LOGIC_VECTOR(3 downto 0);	
	signal packet_bram_f_addr		: STD_LOGIC_VECTOR(31 downto 0);	
	signal packet_bram_f_dout		: STD_LOGIC_VECTOR(31 downto 0);	
	signal packet_bram_f_din		: STD_LOGIC_VECTOR(31 downto 0);	

	
	signal packet_valid 			:  STD_LOGIC;
	signal packet_len 				:  STD_LOGIC_VECTOR(15 downto 0);
	signal packet_got 				:  STD_LOGIC;	
		
	
	signal enable                   : std_logic;
	signal dout                     : std_logic;
begin


	clk_process : process
	begin
		clk_loop : loop
			clk <= '0';
			wait for clk_period_tx/2;
			clk <= '1';
			wait for clk_period_tx/2;
		end loop clk_loop;
	end process;
	
	clk0_process : process
	begin
		clk0_loop : loop
			clk_0 <= '0';
			wait for clk_period_rx/2;
			clk_0 <= '1';
			wait for clk_period_rx/2;
		end loop clk0_loop;
	end process;
	
	clk90_process : process
	begin
	    clk_90 <= '0';
		wait for clk_period_rx/4;
		clk90_loop : loop
			clk_90 <= '0';
			wait for clk_period_rx/2;
			clk_90 <= '1';
			wait for clk_period_rx/2;
		end loop clk90_loop;
	end process;
	
	clk180_process : process
	begin
	    clk_180 <= '0';
		wait for clk_period_rx/2;
		clk180_loop : loop
			clk_180 <= '0';
			wait for clk_period_rx/2;
			clk_180 <= '1';
			wait for clk_period_rx/2;
		end loop clk180_loop;
	end process;
	
	clk270_process : process
	begin
	    clk_270 <= '0';
		wait for 3*clk_period_rx/4;
		clk270_loop : loop
			clk_270 <= '0';
			wait for clk_period_rx/2;
			clk_270 <= '1';
			wait for clk_period_rx/2;
		end loop clk270_loop;
	end process;
	
	wclk_process : process(clk,rst_n)
	begin
		if(rst_n='0')then
			wclk_in <= '0';
		elsif rising_edge(clk) then
			
			if(wclk_counter=WCLK_RATIO-1)then
				wclk_counter <= 0;
			else
				wclk_counter <= wclk_counter+1;
			end if;
			
			if(wclk_counter<WCLK_RATIO/2) then
				wclk_in <= '0';
			else
				wclk_in <= '1';
			end if;
		end if;
	end process;
	
	tb : process
    begin
        rst_n <= '0';
		rst <= '1';
        enable <= '0';
		en_1_f <= '1';
		en_2_f <= '1';
		en_3_f <= '1';
		en_4_f <= '1';
        wait for 100 ns;
        rst_n <= '1';
        rst <= '0';
		wait for 100 ns;
        enable <= '1';

        wait;
    end process;

	process_write_bram_1 : process (clk, rst_n)
	begin
	   if (rst_n='0')then
	       we_1_s <= "0";
	       we_1_f <= "0000";
	       addr_1_s <= (others => '0');
	       din_1_s <= (others => '0');
	       addr_1_f <= (others => '0');
           din_1_f <= (others => '0');
	       counter_byte_1 <= 0;
		   packet_to_send_1_s(0) <= x"55";
		   packet_to_send_1_s(1) <= x"AA";
		   packet_to_send_1_s(2) <= x"00";
		   packet_to_send_1_s(3) <= x"0A";
		   packet_to_send_1_s(4) <= x"10";
		   packet_to_send_1_s(5) <= x"01";
		   packet_to_send_1_s(6) <= x"10";
		   packet_to_send_1_s(7) <= x"01";
		   packet_to_send_1_s(8) <= x"10";
		   packet_to_send_1_s(9) <= x"E5";
		   
		   packet_to_send_1_f(0) <= x"55";
		   packet_to_send_1_f(1) <= x"AA";
		   packet_to_send_1_f(2) <= x"00";
		   packet_to_send_1_f(3) <= x"0A";
		   packet_to_send_1_f(4) <= x"20";
		   packet_to_send_1_f(5) <= x"02";
		   packet_to_send_1_f(6) <= x"20";
		   packet_to_send_1_f(7) <= x"02";
		   packet_to_send_1_f(8) <= x"20";
		   packet_to_send_1_f(9) <= x"D5";
		   
		   state_1 <= "000";
		   packet1_valid <= '0';
		   packet1_len <= x"0000";
		   
		  
	   elsif rising_edge(clk) then
		
	   
	       if(state_1="000") then
				we_1_s <= "1";
				addr_1_s <= std_logic_vector(to_unsigned(counter_byte_1, addr_1_s'length));
				din_1_s <= packet_to_send_1_s(counter_byte_1);
				counter_byte_1 <= counter_byte_1+1;
				if(counter_byte_1>=9)then
					state_1 <= "001";
				end if;
		   elsif(state_1="001")then
				counter_byte_1 <= 0;
				we_1_s <= "0";
				state_1 <= "010";
			elsif(state_1="010")then
				we_1_f <= "1111";
				addr_1_f <= std_logic_vector(to_unsigned(counter_byte_1, addr_1_f'length));
				din_1_f <= packet_to_send_1_f(counter_byte_1+3) & packet_to_send_1_f(counter_byte_1+2) & packet_to_send_1_f(counter_byte_1+1) & packet_to_send_1_f(counter_byte_1);
				counter_byte_1 <= counter_byte_1+4;
				if(counter_byte_1>=9)then
					state_1 <= "011";
				end if;
			elsif(state_1="011")then
				counter_byte_1 <= 0;
				we_1_f <= "0000";
				state_1 <= "110";
			elsif(state_1="110")then
				packet1_valid <= '1';
				packet1_len <= x"000A";
				if(packet1_got='1')then
					state_1 <= "111";
				end if;
			else
				packet1_valid <= '0';
			end if;
	   end if;	
	end process;
	
	process_write_bram_2 : process (clk, rst_n)
	begin
	   if (rst_n='0')then
	       we_2_s <= "0";
	       we_2_f <= "0000";
	       addr_2_s <= (others => '0');
	       din_2_s <= (others => '0');
	       addr_2_f <= (others => '0');
           din_2_f <= (others => '0');
	       counter_byte_2 <= 0;
		   packet_to_send_2_s(0) <= x"55";
		   packet_to_send_2_s(1) <= x"AA";
		   packet_to_send_2_s(2) <= x"00";
		   packet_to_send_2_s(3) <= x"0A";
		   packet_to_send_2_s(4) <= x"30";
		   packet_to_send_2_s(5) <= x"03";
		   packet_to_send_2_s(6) <= x"30";
		   packet_to_send_2_s(7) <= x"03";
		   packet_to_send_2_s(8) <= x"30";
		   packet_to_send_2_s(9) <= x"C5";
		   
		   packet_to_send_2_f(0) <= x"55";
		   packet_to_send_2_f(1) <= x"AA";
		   packet_to_send_2_f(2) <= x"00";
		   packet_to_send_2_f(3) <= x"0A";
		   packet_to_send_2_f(4) <= x"40";
		   packet_to_send_2_f(5) <= x"04";
		   packet_to_send_2_f(6) <= x"40";
		   packet_to_send_2_f(7) <= x"04";
		   packet_to_send_2_f(8) <= x"40";
		   packet_to_send_2_f(9) <= x"B5";
		   
		   state_2 <= "000";
		   packet2_valid <= '0';
		   packet2_len <= x"0000";
		   
		  
	   elsif rising_edge(clk) then
		
	   
	       if(state_2="000") then
				we_2_s <= "1";
				addr_2_s <= std_logic_vector(to_unsigned(counter_byte_2, addr_2_s'length));
				din_2_s <= packet_to_send_2_s(counter_byte_2);
				counter_byte_2 <= counter_byte_2+1;
				if(counter_byte_2>=9)then
					state_2 <= "001";
				end if;
		   elsif(state_2="001")then
				counter_byte_2 <= 0;
				we_2_s <= "0";
				state_2 <= "010";
			elsif(state_2="010")then
				we_2_f <= "1111";
				addr_2_f <= std_logic_vector(to_unsigned(counter_byte_2, addr_2_f'length));
				din_2_f <= packet_to_send_2_f(counter_byte_2+3) & packet_to_send_2_f(counter_byte_2+2) & packet_to_send_2_f(counter_byte_2+1) & packet_to_send_2_f(counter_byte_2);
				counter_byte_2 <= counter_byte_2+4;
				if(counter_byte_2>=9)then
					state_2 <= "011";
				end if;
			elsif(state_2="011")then
				counter_byte_2 <= 0;
				we_2_f <= "0000";
				state_2 <= "110";
			elsif(state_2="110")then
				packet2_valid <= '1';
				packet2_len <= x"000A";
				if(packet2_got='1')then
					state_2 <= "111";
				end if;
			else
				packet2_valid <= '0';
			end if;
	   end if;	
	end process;
		
	
	process_write_bram_3 : process (clk, rst_n)
	begin
	   if (rst_n='0')then
	       we_3_s <= "0";
	       we_3_f <= "0000";
	       addr_3_s <= (others => '0');
	       din_3_s <= (others => '0');
	       addr_3_f <= (others => '0');
           din_3_f <= (others => '0');
	       counter_byte_3 <= 0;
		   packet_to_send_3_s(0) <= x"55";
		   packet_to_send_3_s(1) <= x"AA";
		   packet_to_send_3_s(2) <= x"00";
		   packet_to_send_3_s(3) <= x"0A";
		   packet_to_send_3_s(4) <= x"50";
		   packet_to_send_3_s(5) <= x"05";
		   packet_to_send_3_s(6) <= x"50";
		   packet_to_send_3_s(7) <= x"05";
		   packet_to_send_3_s(8) <= x"50";
		   packet_to_send_3_s(9) <= x"A5";
		   
		   packet_to_send_3_f(0) <= x"55";
		   packet_to_send_3_f(1) <= x"AA";
		   packet_to_send_3_f(2) <= x"00";
		   packet_to_send_3_f(3) <= x"0A";
		   packet_to_send_3_f(4) <= x"60";
		   packet_to_send_3_f(5) <= x"06";
		   packet_to_send_3_f(6) <= x"60";
		   packet_to_send_3_f(7) <= x"06";
		   packet_to_send_3_f(8) <= x"60";
		   packet_to_send_3_f(9) <= x"95";
		   
		   state_3 <= "000";
		   packet3_valid <= '0';
		   packet3_len <= x"0000";
		   
		  
	   elsif rising_edge(clk) then
		
	   
	       if(state_3="000") then
				we_3_s <= "1";
				addr_3_s <= std_logic_vector(to_unsigned(counter_byte_3, addr_3_s'length));
				din_3_s <= packet_to_send_3_s(counter_byte_3);
				counter_byte_3 <= counter_byte_3+1;
				if(counter_byte_3>=9)then
					state_3 <= "001";
				end if;
		   elsif(state_3="001")then
				counter_byte_3 <= 0;
				we_3_s <= "0";
				state_3 <= "010";
			elsif(state_3="010")then
				we_3_f <= "1111";
				addr_3_f <= std_logic_vector(to_unsigned(counter_byte_3, addr_3_f'length));
				din_3_f <= packet_to_send_3_f(counter_byte_3+3) & packet_to_send_3_f(counter_byte_3+2) & packet_to_send_3_f(counter_byte_3+1) & packet_to_send_3_f(counter_byte_3);
				counter_byte_3 <= counter_byte_3+4;
				if(counter_byte_3>=9)then
					state_3 <= "011";
				end if;
			elsif(state_3="011")then
				counter_byte_3 <= 0;
				we_3_f <= "0000";
				state_3 <= "110";
			elsif(state_3="110")then
				packet3_valid <= '1';
				packet3_len <= x"000A";
				if(packet3_got='1')then
					state_3 <= "111";
				end if;
			else
				packet3_valid <= '0';
			end if;
	   end if;	
	end process;
	
	-- process_write_bram_4 : process (clk, rst_n)
	-- begin
	   -- if (rst_n='0')then
	       -- we_4_s <= "0";
	       -- we_4_f <= "0000";
	       -- addr_4_s <= (others => '0');
	       -- din_4_s <= (others => '0');
	       -- addr_4_f <= (others => '0');
           -- din_4_f <= (others => '0');
	       -- counter_byte_4 <= 0;
		   -- packet_to_send_4_s(0) <= x"55";
		   -- packet_to_send_4_s(1) <= x"AA";
		   -- packet_to_send_4_s(2) <= x"00";
		   -- packet_to_send_4_s(3) <= x"0A";
		   -- packet_to_send_4_s(4) <= x"70";
		   -- packet_to_send_4_s(5) <= x"07";
		   -- packet_to_send_4_s(6) <= x"70";
		   -- packet_to_send_4_s(7) <= x"07";
		   -- packet_to_send_4_s(8) <= x"70";
		   -- packet_to_send_4_s(9) <= x"85";
		   
		   -- packet_to_send_4_f(0) <= x"55";
		   -- packet_to_send_4_f(1) <= x"AA";
		   -- packet_to_send_4_f(2) <= x"00";
		   -- packet_to_send_4_f(3) <= x"0A";
		   -- packet_to_send_4_f(4) <= x"80";
		   -- packet_to_send_4_f(5) <= x"08";
		   -- packet_to_send_4_f(6) <= x"80";
		   -- packet_to_send_4_f(7) <= x"08";
		   -- packet_to_send_4_f(8) <= x"80";
		   -- packet_to_send_4_f(9) <= x"75";
		   
		   -- state_4 <= "000";
		   -- packet4_valid <= '0';
		   -- packet4_len <= x"0000";
		   
		  
	   -- elsif rising_edge(clk) then
		
	   
	       -- if(state_4="000") then
				-- we_4_s <= "1";
				-- addr_4_s <= std_logic_vector(to_unsigned(counter_byte_4, addr_4_s'length));
				-- din_4_s <= packet_to_send_4_s(counter_byte_4);
				-- counter_byte_4 <= counter_byte_4+1;
				-- if(counter_byte_4>=9)then
					-- state_4 <= "001";
				-- end if;
		   -- elsif(state_4="001")then
				-- counter_byte_4 <= 0;
				-- we_4_s <= "0";
				-- state_4 <= "010";
			-- elsif(state_4="010")then
				-- we_4_f <= "1111";
				-- addr_4_f <= std_logic_vector(to_unsigned(counter_byte_4, addr_4_f'length));
				-- din_4_f <= packet_to_send_4_f(counter_byte_4+3) & packet_to_send_4_f(counter_byte_4+2) & packet_to_send_4_f(counter_byte_4+1) & packet_to_send_4_f(counter_byte_4);
				-- counter_byte_4 <= counter_byte_4+4;
				-- if(counter_byte_4>=9)then
					-- state_4 <= "011";
				-- end if;
			-- elsif(state_4="011")then
				-- counter_byte_4 <= 0;
				-- we_4_f <= "0000";
				-- state_4 <= "110";
			-- elsif(state_4="110")then
				-- packet4_valid <= '1';
				-- packet4_len <= x"000A";
				-- if(packet4_got='1')then
					-- state_4 <= "111";
				-- end if;
			-- else
				-- packet4_valid <= '0';
			-- end if;
	   -- end if;	
	-- end process;
	
	
	uut_send: packet_sender 
	generic map (
		PORT_NUMBER => 4,
		PORT_1_TRUE_BRAM => false,
		PORT_2_TRUE_BRAM => false,
		PORT_3_TRUE_BRAM => false,
		PORT_4_TRUE_BRAM => true
	)
	port map
	( 
		clk 					=> clk,       
		rst_n 					=> rst_n, 
		wclk					=> wclk_in,
		data_byte_0 			=> tx_data_byte_0 ,
		data_valid_0 			=> tx_data_valid_0,
		data_byte_1 			=> tx_data_byte_1 ,
		data_valid_1 			=> tx_data_valid_1,
		data_byte_2 			=> tx_data_byte_2 ,
		data_valid_2 			=> tx_data_valid_2,
		
        packet1_bram_f_clk     => packet1_bram_f_clk  ,
        packet1_bram_f_rst     => packet1_bram_f_rst  ,
        packet1_bram_f_en      => packet1_bram_f_en   ,
        packet1_bram_f_wen     => packet1_bram_f_wen  ,
        packet1_bram_f_addr    => packet1_bram_f_addr ,
        packet1_bram_f_dout    => packet1_bram_f_dout ,
        packet1_bram_f_din     => packet1_bram_f_din  ,
        				
		packet1_bram_s_clk 		=> packet1_bram_s_clk ,		
		packet1_bram_s_rst		=> packet1_bram_s_rst,		
		packet1_bram_s_en 		=> packet1_bram_s_en ,		
		packet1_bram_s_addr 	=> packet1_bram_s_addr, 	
		packet1_bram_s_dout 	=> packet1_bram_s_dout, 	
		
		packet1_valid 			=> packet1_valid,
		packet1_len 			=> packet1_len,
		packet1_got 			=> packet1_got,

        packet2_bram_f_clk     => packet2_bram_f_clk  ,
        packet2_bram_f_rst     => packet2_bram_f_rst  ,
        packet2_bram_f_en      => packet2_bram_f_en   ,
        packet2_bram_f_wen     => packet2_bram_f_wen  ,
        packet2_bram_f_addr    => packet2_bram_f_addr ,
        packet2_bram_f_dout    => packet2_bram_f_dout ,
        packet2_bram_f_din     => packet2_bram_f_din  ,
        				
		packet2_bram_s_clk 		=> packet2_bram_s_clk ,		
		packet2_bram_s_rst		=> packet2_bram_s_rst,		
		packet2_bram_s_en 		=> packet2_bram_s_en ,		
		packet2_bram_s_addr 	=> packet2_bram_s_addr, 	
		packet2_bram_s_dout 	=> packet2_bram_s_dout, 	
		
		packet2_valid 			=> packet2_valid,
		packet2_len 			=> packet2_len,
		packet2_got 			=> packet2_got,

        packet3_bram_f_clk     => packet3_bram_f_clk  ,
        packet3_bram_f_rst     => packet3_bram_f_rst  ,
        packet3_bram_f_en      => packet3_bram_f_en   ,
        packet3_bram_f_wen     => packet3_bram_f_wen  ,
        packet3_bram_f_addr    => packet3_bram_f_addr ,
        packet3_bram_f_dout    => packet3_bram_f_dout ,
        packet3_bram_f_din     => packet3_bram_f_din  ,
        
		packet3_bram_s_clk 		=> packet3_bram_s_clk ,		
		packet3_bram_s_rst		=> packet3_bram_s_rst,		
		packet3_bram_s_en 		=> packet3_bram_s_en ,		
		packet3_bram_s_addr 	=> packet3_bram_s_addr, 	
		packet3_bram_s_dout 	=> packet3_bram_s_dout, 	
	            
		packet3_valid 			=> packet3_valid,
		packet3_len 			=> packet3_len,
		packet3_got 			=> packet3_got,


        packet4_bram_f_clk     => packet4_bram_f_clk  ,
        packet4_bram_f_rst     => packet4_bram_f_rst  ,
        packet4_bram_f_en      => packet4_bram_f_en   ,
        packet4_bram_f_wen     => packet4_bram_f_wen  ,
        packet4_bram_f_addr    => packet4_bram_f_addr ,
        packet4_bram_f_dout    => packet4_bram_f_dout ,
        packet4_bram_f_din     => packet4_bram_f_din  ,

		packet4_bram_s_clk 		=> packet4_bram_s_clk ,		
		packet4_bram_s_rst		=> packet4_bram_s_rst,		
		packet4_bram_s_en 		=> packet4_bram_s_en ,		
		packet4_bram_s_addr 	=> packet4_bram_s_addr, 	
		packet4_bram_s_dout 	=> packet4_bram_s_dout, 	
  
		packet4_valid 			=> packet4_valid,
		packet4_len 			=> packet4_len,
		packet4_got 			=> packet4_got 	 		
	);
	
		uut_tx: bus_transmitter 
    generic map (
        AUDIO_CHANNELS => AUDIO_CHANNELS
    )
    port map
    ( 
        clk             => clk,       
        rst_n             => rst_n,       
        enable            => enable,       
                                      
        dout             => dout,      
                                      
        wclk            => wclk_in,      
        
        data_byte_0     => tx_data_byte_0      ,
        data_valid_0     => tx_data_valid_0 ,
        data_byte_1     => tx_data_byte_1      ,
        data_valid_1     => tx_data_valid_1 ,
        data_byte_2     => tx_data_byte_2      ,
        data_valid_2     => tx_data_valid_2 ,
        audio_data_0     => tx_audio_data_0 ,
        audio_valid_0     => tx_audio_valid_0 ,    
        audio_mute_0     => tx_audio_mute_0 ,
        audio_data_1     => tx_audio_data_1 ,
        audio_valid_1     => tx_audio_valid_1 ,    
        audio_mute_1     => tx_audio_mute_1 ,
        audio_data_2     => tx_audio_data_2 ,
        audio_valid_2     => tx_audio_valid_2 ,    
        audio_mute_2     => tx_audio_mute_2 ,
        audio_data_3     => tx_audio_data_3 ,
        audio_valid_3     => tx_audio_valid_3 ,    
        audio_mute_3     => tx_audio_mute_3 ,
        audio_data_4     => tx_audio_data_4 ,
        audio_valid_4     => tx_audio_valid_4 ,    
        audio_mute_4     => tx_audio_mute_4 ,
        audio_data_5     => tx_audio_data_5 ,
        audio_valid_5     => tx_audio_valid_5 ,    
        audio_mute_5     => tx_audio_mute_5 ,
        audio_data_6     => tx_audio_data_6 ,
        audio_valid_6     => tx_audio_valid_6 ,    
        audio_mute_6     => tx_audio_mute_6 ,
        audio_data_7     => tx_audio_data_7 ,
        audio_valid_7     => tx_audio_valid_7 ,    
        audio_mute_7     => tx_audio_mute_7 ,
        audio_data_8     => tx_audio_data_8 ,
        audio_valid_8     => tx_audio_valid_8 ,    
        audio_mute_8     => tx_audio_mute_8 ,
        audio_data_9     => tx_audio_data_9 ,
        audio_valid_9     => tx_audio_valid_9 ,    
        audio_mute_9     => tx_audio_mute_9 ,
        audio_data_10     => tx_audio_data_10 ,    
        audio_valid_10     => tx_audio_valid_10,    
        audio_mute_10     => tx_audio_mute_10 ,    
        audio_data_11     => tx_audio_data_11 ,    
        audio_valid_11     => tx_audio_valid_11,    
        audio_mute_11     => tx_audio_mute_11 ,     
        audio_data_12     => tx_audio_data_12 ,    
        audio_valid_12     => tx_audio_valid_12,    
        audio_mute_12     => tx_audio_mute_12 ,    
        audio_data_13     => tx_audio_data_13 ,    
        audio_valid_13     => tx_audio_valid_13,    
        audio_mute_13     => tx_audio_mute_13 ,         
        audio_data_14     => tx_audio_data_14 ,    
        audio_valid_14     => tx_audio_valid_14,    
        audio_mute_14     => tx_audio_mute_14 
    );                                
	
	uut_rx: bus_receiver    
    generic map (
        AUDIO_CHANNELS => AUDIO_CHANNELS
    )
    port map                          
    (                                 
        clk_0             => clk_0,
        clk_90             => clk_90,
        clk_180            => clk_180,
        clk_270            => clk_270,
        rst_n             => rst_n,
        enable            => enable,
             
        din             => dout,
               
        wclk            => wclk_out,
               
        data_byte_0     => rx_data_byte_0      ,
        data_valid_0     => rx_data_valid_0 ,
        data_byte_1     => rx_data_byte_1      ,
        data_valid_1     => rx_data_valid_1 ,
        data_byte_2     => rx_data_byte_2      ,
        data_valid_2     => rx_data_valid_2 ,
        audio_data_0     => rx_audio_data_0 ,
        audio_valid_0     => rx_audio_valid_0 ,    
        audio_mute_0     => rx_audio_mute_0 ,
        audio_data_1     => rx_audio_data_1 ,
        audio_valid_1     => rx_audio_valid_1 ,    
        audio_mute_1     => rx_audio_mute_1 ,
        audio_data_2     => rx_audio_data_2 ,
        audio_valid_2     => rx_audio_valid_2 ,    
        audio_mute_2     => rx_audio_mute_2 ,
        audio_data_3     => rx_audio_data_3 ,
        audio_valid_3     => rx_audio_valid_3 ,    
        audio_mute_3     => rx_audio_mute_3 ,
        audio_data_4     => rx_audio_data_4 ,
        audio_valid_4     => rx_audio_valid_4 ,    
        audio_mute_4     => rx_audio_mute_4 ,
        audio_data_5     => rx_audio_data_5 ,
        audio_valid_5     => rx_audio_valid_5 ,    
        audio_mute_5     => rx_audio_mute_5 ,
        audio_data_6     => rx_audio_data_6 ,
        audio_valid_6     => rx_audio_valid_6 ,    
        audio_mute_6     => rx_audio_mute_6 ,
        audio_data_7     => rx_audio_data_7 ,
        audio_valid_7     => rx_audio_valid_7 ,    
        audio_mute_7     => rx_audio_mute_7 ,
        audio_data_8     => rx_audio_data_8 ,
        audio_valid_8     => rx_audio_valid_8 ,    
        audio_mute_8     => rx_audio_mute_8 ,
        audio_data_9     => rx_audio_data_9 ,
        audio_valid_9     => rx_audio_valid_9 ,    
        audio_mute_9     => rx_audio_mute_9 ,
        audio_data_10     => rx_audio_data_10 ,    
        audio_valid_10     => rx_audio_valid_10,    
        audio_mute_10     => rx_audio_mute_10 ,    
        audio_data_11     => rx_audio_data_11 ,    
        audio_valid_11     => rx_audio_valid_11,    
        audio_mute_11     => rx_audio_mute_11 ,      
        audio_data_12     => rx_audio_data_12 ,    
        audio_valid_12     => rx_audio_valid_12,    
        audio_mute_12     => rx_audio_mute_12 ,    
        audio_data_13     => rx_audio_data_13 ,    
        audio_valid_13     => rx_audio_valid_13,    
        audio_mute_13     => rx_audio_mute_13 ,    
        audio_data_14     => rx_audio_data_14 ,    
        audio_valid_14     => rx_audio_valid_14,    
        audio_mute_14     => rx_audio_mute_14 
    );
    	
	uut_recover: packet_recover    	
	Generic map(
		MAX_PACKET_SIZE 			=> 1024,
		CIRCULAR_MEMORY_SIZE 		=> 4096,
		CIRCULAR_MEMORY_BIT_ADDR	=> 12,
		PACKET_MEMORY_BIT_ADDR		=> 10,
		TRUE_BRAM					=> false
	)
	Port map ( 
		clk 			=> clk_0,
		rst_n 			=> rst_n,

		wclk			=> wclk_out,
				
		data_byte_0 	=> rx_data_byte_0,
		data_valid_0 	=> rx_data_valid_0,

		data_byte_1 	=> rx_data_byte_1,
		data_valid_1 	=> rx_data_valid_1,

		data_byte_2 	=> rx_data_byte_2,
		data_valid_2 	=> rx_data_valid_2,

		circular_bram_w_clk 	=> circular_bram_w_clk 	,
		circular_bram_w_en 		=> circular_bram_w_en 	,	
		circular_bram_w_wen		=> circular_bram_w_wen(0)	,	
		circular_bram_w_addr 	=> circular_bram_w_addr ,	
		circular_bram_w_data 	=> circular_bram_w_data ,	

		circular_bram_r_clk		=> circular_bram_r_clk	,	
		circular_bram_r_en		=> circular_bram_r_en	,	
		circular_bram_r_addr 	=> circular_bram_r_addr ,	
		circular_bram_r_data 	=> circular_bram_r_data ,	
		
		packet_bram_f_clk		=> packet_bram_f_clk	,	
		packet_bram_f_rst		=> packet_bram_f_rst	,	
		packet_bram_f_en		=> packet_bram_f_en		,
		packet_bram_f_wen		=> packet_bram_f_wen	,	
		packet_bram_f_addr		=> packet_bram_f_addr	,	
		packet_bram_f_dout		=> packet_bram_f_dout	,	
		packet_bram_f_din		=> packet_bram_f_din	,	
		
		packet_bram_s_clk 	=> packet_bram_s_clk 	,
		packet_bram_s_en 	=> packet_bram_s_en 	,
		packet_bram_s_wen	=> packet_bram_s_wen(0)	,
		packet_bram_s_addr 	=> packet_bram_s_addr 	,
		packet_bram_s_data 	=> packet_bram_s_data 	,
		
		
		packet_valid 		=> packet4_valid,
		packet_len 			=> packet4_len,
		packet_got 			=> packet4_got
	);

	-- process_read_recover : process (clk_0, rst_n)
	-- begin
		-- if(rst_n='0')then
			-- packet_got <= '0';
			-- reading_recover <= '0';
			-- packet_bram_s_r_addr <= (others => '0');
		-- elsif rising_edge(clk_0)then
			-- if(reading_recover= '0')then
				-- if(packet_valid='1')then
					-- reading_recover <= '1';
				-- end if;
			-- else
				-- packet_bram_s_r_addr <= packet_bram_s_r_addr +1;
				-- if(packet_bram_s_r_addr=packet_len)then
					
				-- end if;
			-- end if;
		-- end if;
	-- end process;
	
	block_ram_recover_f : MarsZX3_blk_mem_gen_2_0
     PORT MAP (
       clka => packet_bram_f_clk,
       rsta => packet_bram_f_rst,
       ena => packet_bram_f_en,
       wea => packet_bram_f_wen,
       addra => packet_bram_f_addr,
       dina => packet_bram_f_din,
       douta => packet_bram_f_dout,
       clkb => packet4_bram_f_clk,
       rstb => packet4_bram_f_rst,
       enb => packet4_bram_f_en,
       web => packet4_bram_f_wen,
       addrb => packet4_bram_f_addr,
       dinb => packet4_bram_f_din,
       doutb => packet4_bram_f_dout
     );


	block_ram_recover : blk_mem_gen_0
      PORT MAP (
        clka => packet_bram_s_clk,
        ena => packet_bram_s_en,
        wea => packet_bram_s_wen,
        addra => packet_bram_s_addr,
        dina => packet_bram_s_data,
        clkb => packet4_bram_s_clk,
        enb => packet4_bram_s_en,
        addrb => packet4_bram_s_addr,
        doutb => packet4_bram_s_dout
      );

	block_ram_circular : blk_mem_gen_1
      PORT MAP (
        clka => circular_bram_w_clk,
        ena => circular_bram_w_en,
        wea => circular_bram_w_wen,
        addra => circular_bram_w_addr,
        dina => circular_bram_w_data,
        clkb => circular_bram_r_clk,
        enb => circular_bram_r_en,
        addrb => circular_bram_r_addr,
        doutb => circular_bram_r_data
      );
	  
    block_ram_1_s : blk_mem_gen_0
      PORT MAP (
        clka => clk,
        ena => '1',
        wea => we_1_s,
        addra => addr_1_s,
        dina => din_1_s,
        clkb => packet1_bram_s_clk,
        enb => packet1_bram_s_en,
        addrb => packet1_bram_s_addr,
        doutb => packet1_bram_s_dout
      );

		
		
	block_ram_2_s : blk_mem_gen_0
      PORT MAP (
        clka => clk,
        ena => '1',
        wea => we_2_s,
        addra => addr_2_s,
        dina => din_2_s,
        clkb => packet2_bram_s_clk,
        enb => packet2_bram_s_en,
        addrb => packet2_bram_s_addr,
        doutb => packet2_bram_s_dout
      );


		
	block_ram_3_s : blk_mem_gen_0
      PORT MAP (
        clka => clk,
        ena => '1',
        wea => we_3_s,
        addra => addr_3_s,
        dina => din_3_s,
        clkb => packet3_bram_s_clk,
        enb => packet3_bram_s_en,
        addrb => packet3_bram_s_addr,
        doutb => packet3_bram_s_dout
      );


	
	    -- block_ram_4_s : blk_mem_gen_0
      -- PORT MAP (
        -- clka => clk,
        -- ena => '1',
        -- wea => we_4_s,
        -- addra => addr_4_s,
        -- dina => din_4_s,
        -- clkb => packet4_bram_s_clk,
        -- enb => packet4_bram_s_en,
        -- addrb => packet4_bram_s_addr,
        -- doutb => packet4_bram_s_dout
      -- );
      
      
--    block_ram_1_f : MarsZX3_blk_mem_gen_2_0
--      PORT MAP (
--        clka => packet1_bram_f_clk,
--        rsta => packet1_bram_f_rst,
--        ena => packet1_bram_f_en,
--        wea => packet1_bram_f_wen,
--        addra => packet1_bram_f_addr,
--        dina => packet1_bram_f_din,
--        douta => packet1_bram_f_dout,
--        clkb => clk,
--        rstb => rst,
--        enb => en_1_f,
--        web => we_1_f,
--        addrb => addr_1_f,
--        dinb => din_1_f,
--        doutb => dout_1_f
--      );
      
--      block_ram_2_f : MarsZX3_blk_mem_gen_2_0
--        PORT MAP (
--          clka => packet2_bram_f_clk,
--          rsta => packet2_bram_f_rst,
--          ena => packet2_bram_f_en,
--          wea => packet2_bram_f_wen,
--          addra => packet2_bram_f_addr,
--          dina => packet2_bram_f_din,
--          douta => packet2_bram_f_dout,
--          clkb => clk,
--          rstb => rst,
--          enb => en_2_f,
--          web => we_2_f,
--          addrb => addr_2_f,
--          dinb => din_2_f,
--          doutb => dout_2_f
--        );    
        
--    block_ram_3_f : MarsZX3_blk_mem_gen_2_0
--      PORT MAP (
--        clka => packet3_bram_f_clk,
--        rsta => packet3_bram_f_rst,
--        ena => packet3_bram_f_en,
--        wea => packet3_bram_f_wen,
--        addra => packet3_bram_f_addr,
--        dina => packet3_bram_f_din,
--        douta => packet3_bram_f_dout,
--        clkb => clk,
--        rstb => rst,
--        enb => en_3_f,
--        web => we_3_f,
--        addrb => addr_3_f,
--        dinb => din_3_f,
--        doutb => dout_3_f
--      );    

--      block_ram_4_f : MarsZX3_blk_mem_gen_2_0
--        PORT MAP (
--          clka => packet4_bram_f_clk,
--          rsta => packet4_bram_f_rst,
--          ena => packet4_bram_f_en,
--          wea => packet4_bram_f_wen,
--          addra => packet4_bram_f_addr,
--          dina => packet4_bram_f_din,
--          douta => packet4_bram_f_dout,
--          clkb => clk,
--          rstb => rst,
--          enb => en_4_f,
--          web => we_4_f,
--          addrb => addr_4_f,
--          dinb => din_4_f,
--          doutb => dout_4_f
--        );
			
end Behavioral;
