----------------------------------------------------------------------------------
-- Company: 
-- Engineer:  
-- 
-- Create Date:    10:16:04 03/17/2010 
-- Design Name: 
-- Module Name:    AES_EBU_RX - Behavioral 
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

entity bdAES3rx is
	port (
		-- Clock sources
		MCLK:         			  in  std_logic;      -- 100 MHz XO   
		RST:     				  in  std_logic;
		-- AES Rx pins
		din:            		  in  std_logic;

		-- AES Rx1 Out internal
		ch0_out:				  out std_logic_vector (23 downto 0);              
        ch1_out:				  out std_logic_vector (23 downto 0);

        wclk_out:				  out std_logic;
        locked:                   out std_logic;
        audclk_out:               out std_logic
	);

end bdAES3rx;

architecture Behavioral of bdAES3rx is

subtype aes_audio_sample_type is std_logic_vector(23 downto 0);
subtype aes_frame_counter_type is std_logic_vector(7 downto 0);
subtype aes_rate_type is std_logic_vector(3 downto 0);


-------------------------------------------------------------------------------
-- Signal definitions
--
-- Clock signals
signal clk_100M :           std_logic;
signal gclk_audio_rx :      std_logic;                      -- global 100 MHz clock


-- Audio signals for all channels
signal audio_rst :          std_logic;                      -- reset for audio modules
signal clr_errs :           std_logic;

-- AES Rx #1 signals
signal aes1_rx :            std_logic;                      -- input bit stream
signal err_capture1 :       std_logic;                      -- parity err capture FF
signal err_cap_rst :        std_logic;                      -- error capture reset
signal cs1_crc_out :        std_logic;                      -- ch 1 C CRC bit
signal cs1_crc_out_en :     std_logic;                      -- ch 1 C CRC enable
signal cs1_crc_err :        std_logic;                      -- ch 1 C CRC err capture
signal cs1_crc_err_det :    std_logic;                      -- ch 1 C CRC err detect
signal cs0_crc_out :        std_logic;                      -- ch 2 C CRC bit
signal cs0_crc_out_en :     std_logic;                      -- ch 2 C CRC enable
signal cs0_crc_err :        std_logic;                      -- ch 2 C CRC err capture
signal cs0_crc_err_det :    std_logic;                      -- ch 2 C CRC err detect
signal rate_detect :        std_logic;                      -- 1 if valid AES rate
signal rate :               aes_rate_type;                  -- detected AES rate

-- Component declarations
component aes_rx
    port (
        clk:                    in  std_logic;     
        rst:                    in  std_logic;     
        din:                    in  std_logic;     
        mux_mode:               in  std_logic;     
        locked:                 out std_logic;     
        chan1_en:               out std_logic;     
        audio1:                 out std_logic_vector(23 downto 0);
        valid1:                 out std_logic; 
        user1:                  out std_logic; 
        cs1:                    out std_logic; 
        chan2_en:               out std_logic; 
        audio2:                 out std_logic_vector(23 downto 0);
        valid2:                 out std_logic;   
        user2:                  out std_logic;   
        cs2:                    out std_logic;   
        parity_err:             out std_logic;   
        frames:                 out std_logic_vector(7 downto 0);
        frame0:                 out std_logic;
		clk_6M:                 out std_logic);
end component;

component aes_crc
    port (
        clk:                    in  std_logic;
        ce:                     in  std_logic;
        frames:                 in  std_logic_vector(7 downto 0);           
        din:                    in  std_logic;  
        dout:                   out std_logic;  
        crc_out_en:             out std_logic;  
        frame191:               out std_logic;  
        crc_err:                out std_logic); 
end component;

    signal channel2_r: std_logic;
	
	signal cs0_out: std_logic;
	signal cs1_out: std_logic;
	signal parity_err1:	std_logic;
    signal aes_frame_count1: std_logic_vector (7 downto 0);
    
    
    signal ch0_cs_sr: std_logic_vector (31 downto 0);
    signal ch1_cs_sr: std_logic_vector (31 downto 0);
    signal cs_we_r:	std_logic;
    signal channel2_r_1:	std_logic;
    signal cs_addr_r : std_logic_vector(2 downto 0);
    
    signal counter_wclk : std_logic_vector(31 downto 0);
    signal counter_wclk_old : std_logic_vector(31 downto 0);
    signal locked_r : std_logic;
begin
	gclk_audio_rx <= MCLK;

    -- 
	--    BUFG100 : BUFG 
	--    port map (
	--        I               => MCLK, 
	--        O               => gclk_audio_rx);

	--buffer tasti
	audio_rst <= RST;
	clr_errs <= '0';

   
 
    --
    -- Input Buffers for AES Rx signals
    --
    -- To match the AES3id electrical interfaces on the demo board, the LVDS_25
    -- is used for the receive buffers and two LVCMOS25 buffers, used 
    -- differentially are use for each transmitter.
    --	 
	aes1_rx <=din;

    --TODO: wclk output
    wclk_out_process : process(gclk_audio_rx,audio_rst)
    begin
        if(audio_rst='1')then
            counter_wclk <= (others => '0');
            counter_wclk_old <= (others => '0'); 
            wclk_out <= '0';
            locked <= '0';        
        elsif rising_edge(gclk_audio_rx) then
            locked <= locked_r;
            if(locked_r = '1') then
                if(channel2_r = '1')then
                    counter_wclk <= (others => '0');
                    counter_wclk_old <= counter_wclk;
                else
                    counter_wclk <= counter_wclk+1;
                    if(counter_wclk(30 downto 0)>counter_wclk_old(31 downto 1))then
                        wclk_out <= '1';
                    else 
                        wclk_out <= '0';
                    end if;
                end if;
            else
                wclk_out <= '0';
                counter_wclk <= (others => '0');
            end if;        
        end if;
    end process;

    ----------------------------------------------------------------------------
    -- AES audio receivers
    --
    AESRX1 : aes_rx
    port map (
        clk                 => gclk_audio_rx,
        rst                 => audio_rst,
        din                 => aes1_rx,
        mux_mode            => '0',
        locked              => locked_r,
        chan1_en            => open,
        audio1              => ch0_out,
        valid1              => open,
        user1               => open,
        cs1                 => open,
        chan2_en            => channel2_r,
        audio2              => ch1_out,
        valid2              => open,
        user2               => open,
        cs2                 => open,
        parity_err          => parity_err1,
        frames              => aes_frame_count1,
        frame0              => open,
		clk_6M 			 	=> audclk_out);

    err_cap_rst <= clr_errs or audio_rst;

    process(gclk_audio_rx, err_cap_rst)
    begin
        if err_cap_rst = '1' then
            err_capture1 <= '0';
        elsif rising_edge(gclk_audio_rx) then
            if channel2_r = '1' and parity_err1 = '1' then
                err_capture1 <= '1';
            end if;
        end if;
    end process;
	
-- qua nel aes demo c'è il chipscope: i segnali vengono messi in una ram e letti dal chip scope

    --
    -- Channel status CRC checkers
    --
    -- The channel status CRC values are computed and checked for each of the
    -- four received audio channels. Each CRC checker drives a different LED on 
    -- the demo board.
    --
    AESCRCRX1: aes_crc 
    port map (
        clk         => gclk_audio_rx,
        ce          => channel2_r,
        frames      => aes_frame_count1,
        din         => cs0_out,
        dout        => cs0_crc_out,
        crc_out_en  => cs0_crc_out_en,
        frame191    => open,
        crc_err     => cs0_crc_err_det);

    process(gclk_audio_rx, err_cap_rst)
    begin
        if err_cap_rst = '1' then
            cs0_crc_err <= '0';
        elsif rising_edge(gclk_audio_rx) then
            if channel2_r = '1' and cs0_crc_out_en = '1' and cs0_crc_err_det = '1' then
                cs0_crc_err <= '1';
            end if;
        end if;
    end process;

    AESCRCRX2: aes_crc
    port map (
        clk         => gclk_audio_rx,
        ce          => channel2_r,
        frames      => aes_frame_count1,
        din         => cs1_out,
        dout        => cs1_crc_out,
        crc_out_en  => cs1_crc_out_en,
        frame191    => open,
        crc_err     => cs1_crc_err_det);

    process(gclk_audio_rx, err_cap_rst)
    begin
        if err_cap_rst = '1' then
            cs1_crc_err <= '0';
        elsif rising_edge(gclk_audio_rx) then
            if channel2_r = '1' and cs1_crc_out_en = '1' and cs1_crc_err_det = '1'then
                cs1_crc_err <= '1';
            end if;
        end if;
    end process;
end Behavioral;

