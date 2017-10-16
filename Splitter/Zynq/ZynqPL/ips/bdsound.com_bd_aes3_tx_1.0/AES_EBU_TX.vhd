----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:58:51 04/05/2010 
-- Design Name: 
-- Module Name:    AES_EBU_TX - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity bdAES3tx is
    port (
    -- Clock sources        
		audio_clk:        in std_logic;      -- 24.576 MHz audio VCXO
		rst:		      in std_logic;
		out_freq: 	      in std_logic_vector(1 downto 0); --00 192kHz 01 96kHz 10 48kHz 11 ??
	-- internal inputs
	--tx1                    
		ch0_in :          in std_logic_vector(23 downto 0);         
		ch1_in :          in std_logic_vector(23 downto 0);     
           
    -- AES Tx pins		  
        dout:             out std_logic
	   );
end bdAES3tx;

architecture Behavioral of bdAES3tx is

subtype aes_audio_sample_type is std_logic_vector(23 downto 0);
subtype aes_frame_counter_type is std_logic_vector(7 downto 0);
subtype aes_rate_type is std_logic_vector(3 downto 0);

--signal declaration
--clock signal

signal gclk_audio_vcxo:     std_logic;                      -- global audio vcxo clock

signal aes_tx_clk_divisor : std_logic_vector(3 downto 0);   -- Tx clock enable divisor


-- Audio signals for all channels

signal ce_audio_tx_bp :     std_logic;                      -- bi-phase clock enable
signal ce_audio_tx_bit :    std_logic;                      -- bit rate clock enable
signal ce_audio_tx_word :   std_logic;                      -- sample rate clock enable


signal tx1_cs1 : 				 std_logic;                      
signal tx1_cs2 :	 			 std_logic; 
 		
 

signal tx1_frame0 :         std_logic;

 

signal cs0_aux :             std_logic;
signal cs1_aux :             std_logic;
signal frame0_aux :			 std_logic;

--dichiarazione dei component



component aes_tx
    port (
        clk:                    in  std_logic; 
        rst:                    in  std_logic; 
        ce_word:                in  std_logic; 
        ce_bit:                 in  std_logic; 
        ce_bp:                  in  std_logic; 
        audio1:                 in  std_logic_vector(23 downto 0);
        cs1:                    in  std_logic;
        valid1:                 in  std_logic;
        user1:                  in  std_logic;
        audio2:                 in  std_logic_vector(23 downto 0);
        cs2:                    in  std_logic; 
        valid2:                 in  std_logic; 
        user2:                  in  std_logic; 
        frame0:                 in  std_logic; 
        serout:                 out std_logic);
end component;



component aes_tx_clkdiv
    port (
        clk:                    in    std_logic;                   
        divisor:                in    std_logic_vector(3 downto 0);
        ce_bp:                  inout std_logic;   
        ce_bit:                 inout std_logic;   
        ce_word:                inout std_logic);  
end component;


	COMPONENT PRE_AES_EBU_TX
	PORT(
		clk : IN std_logic;
		ce_word : IN std_logic;
		force_crc_err : IN std_logic;
	    use_cs_fixed:   in std_logic;
		cs0:            in std_logic_vector(31 downto 0);
        cs1:            in std_logic_vector(31 downto 0);
        cs2:            in std_logic_vector(31 downto 0);
        cs3:            in std_logic_vector(31 downto 0);
        cs4:            in std_logic_vector(31 downto 0);
        cs5:            in std_logic_vector(31 downto 0);
		cs : OUT std_logic;
		frame0 : OUT std_logic
		);
	END COMPONENT;
	signal ch0_cs0 : std_logic_vector(31 downto 0);
	signal ch0_cs1 : std_logic_vector(31 downto 0);
	signal ch0_cs2 : std_logic_vector(31 downto 0);
	signal ch0_cs3 : std_logic_vector(31 downto 0);
	signal ch0_cs4 : std_logic_vector(31 downto 0);
	signal ch0_cs5 : std_logic_vector(31 downto 0);
	signal ch1_cs0 : std_logic_vector(31 downto 0);
	signal ch1_cs1 : std_logic_vector(31 downto 0);
	signal ch1_cs2 : std_logic_vector(31 downto 0);
	signal ch1_cs3 : std_logic_vector(31 downto 0);
	signal ch1_cs4 : std_logic_vector(31 downto 0);
	signal ch1_cs5 : std_logic_vector(31 downto 0);
    signal address : std_logic_vector(31 downto 0);
    signal ce_audio_tx_word_r : std_logic;
begin


gclk_audio_vcxo <=  audio_clk;


-- il clock d'ingresso viene diviso per aes_tx_clk_divisor + 1:
-- se voglio andare a 48KHz il clock aes ebu dev'essere di 6.144 MHz quindi se entro con 
-- un 12.288 MHz, devo dividere per due, metto quindi 1
freq_out_process : process(gclk_audio_vcxo)
begin
	if rising_edge(gclk_audio_vcxo) then
		if (out_freq="00") then
			aes_tx_clk_divisor <= X"0";
		elsif (out_freq="01") then 
			aes_tx_clk_divisor <= X"1";
		elsif (out_freq="10") then
			aes_tx_clk_divisor <= X"3";
		else
			aes_tx_clk_divisor <= X"5";
		end if;
	end if;
end process;

tx1_cs1 <= cs0_aux;
tx1_cs2 <= cs1_aux;
tx1_frame0 <= frame0_aux;    


	Inst_PRE_AES_EBU_TX0: PRE_AES_EBU_TX PORT MAP(
		clk => gclk_audio_vcxo,
		ce_word => ce_audio_tx_word,
		force_crc_err => '0',
		use_cs_fixed => '1',
		cs0 => ch0_cs0,
        cs1 => ch0_cs1,
        cs2 => ch0_cs2,
        cs3 => ch0_cs3,
        cs4 => ch0_cs4,
        cs5 => ch0_cs5,
		cs => cs0_aux,
		frame0 => frame0_aux 
	);
 	Inst_PRE_AES_EBU_TX1: PRE_AES_EBU_TX PORT MAP(
		clk => gclk_audio_vcxo,
		ce_word => ce_audio_tx_word,
		force_crc_err => '0',
		use_cs_fixed => '1',
		cs0 => ch1_cs0,
        cs1 => ch1_cs1,
        cs2 => ch1_cs2,
        cs3 => ch1_cs3,
        cs4 => ch1_cs4,
        cs5 => ch1_cs5,
		cs => cs1_aux,
		frame0 => open 
	);   
	
    --
    -- AES audio transmitter #1
    --
    -- 
    --
    AESTX1: aes_tx
    port map (
        clk             => gclk_audio_vcxo,
        rst             => rst,
        ce_word         => ce_audio_tx_word,
        ce_bit          => ce_audio_tx_bit,
        ce_bp           => ce_audio_tx_bp,
        audio1          => ch0_in,
        audio2          => ch1_in,
        cs1             => tx1_cs1,
        cs2             => tx1_cs2,
        valid1          => '1',
        valid2          => '1',
        user1           => '0',
        user2           => '0',
        frame0          => tx1_frame0,
        serout          => dout);


  


    CLKDIV : aes_tx_clkdiv
    port map (
        clk                 => gclk_audio_vcxo,
        divisor             => aes_tx_clk_divisor,
        ce_bp               => ce_audio_tx_bp,
        ce_bit              => ce_audio_tx_bit,
        ce_word             => ce_audio_tx_word);



end Behavioral;

