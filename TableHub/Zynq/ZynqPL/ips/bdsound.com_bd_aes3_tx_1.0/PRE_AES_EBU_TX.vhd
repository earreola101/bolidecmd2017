----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:52:47 03/18/2010 
-- Design Name: 
-- Module Name:    PRE_AES_EBU_TX - Behavioral 
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
--library UNISIM;
--use UNISIM.VComponents.all;

entity PRE_AES_EBU_TX is

    port (
        clk:            in  std_logic;  -- 24.576 MHz clock
        ce_word:        in  std_logic;  -- sample rate clock enable
        force_crc_err:  in  std_logic;  -- forces a channel status CRC err when 1
        use_cs_fixed:   in std_logic;
        cs0:            in std_logic_vector(31 downto 0);
        cs1:            in std_logic_vector(31 downto 0);
        cs2:            in std_logic_vector(31 downto 0);
        cs3:            in std_logic_vector(31 downto 0);
        cs4:            in std_logic_vector(31 downto 0);
        cs5:            in std_logic_vector(31 downto 0);
        cs:             out std_logic;  -- channel status
        frame0:         out std_logic); -- frame0 indicator


end PRE_AES_EBU_TX;

architecture Behavioral of PRE_AES_EBU_TX is






-------------------------------------------------------------------------------
-- Local signal definitions
--



signal frames :                         -- frame counter for CRC generation
                        std_logic_vector(7 downto 0) := (others => '0');
signal frames_tc :      std_logic;      -- frame counter terminal count indicator
signal cs_rom :                         -- channel status ROM
                        std_logic_vector(7 downto 0);
signal crc_out_en :     std_logic;      -- channel status CRC output enable
signal cs_mux :         std_logic;      -- channel status bit mux
signal cs_crc_out :     std_logic;      -- channel status CRC output



component aes_crc
    port (
        clk:            in  std_logic; 
        ce:             in  std_logic; 
        frames:         in  std_logic_vector(7 downto 0);           
        din:            in  std_logic;
        dout:           out std_logic;
        crc_out_en:     out std_logic;
        frame191:       out std_logic;
        crc_err:        out std_logic);
end component;   


signal cs_rom_fixed: std_logic_vector(7 downto 0);
signal cs_rom_bram : std_logic_vector(7 downto 0);
  


begin





    

    --
    -- Channel status data ROM
    -- 
    --
    --   
    cs_rom_fixed <= X"A1" when frames(7 downto 3) = "00000" else  -- professional, 48 khz
                  X"00" when frames(7 downto 3) = "00001" else  -- stereo mode
                  "00101100" when frames(7 downto 3) = "00010" else  -- 20-bit audio 
                  X"00" when frames(7 downto 3) = "00110" else  -- channel origin 
                  X"00" when frames(7 downto 3) = "00111" else  --  is set to "FPGA"
                  X"00" when frames(7 downto 3) = "01000" else
                  X"00" when frames(7 downto 3) = "01001" else
                  X"00";
    cs_rom <= cs_rom_fixed when use_cs_fixed = '1' else cs_rom_bram;
    cs_rom_bram <=   cs0(7 downto 0) when frames(7 downto 3)   = "00000" else  
                cs0(15 downto 8) when frames(7 downto 3)  = "00001" else  
                cs0(23 downto 16) when frames(7 downto 3) = "00010" else 
                cs0(31 downto 24) when frames(7 downto 3) = "00011" else 
                cs1(7 downto 0) when frames(7 downto 3)   = "00100" else  
                cs1(15 downto 8) when frames(7 downto 3)  = "00101" else  
                cs1(23 downto 16) when frames(7 downto 3) = "00110" else 
                cs1(31 downto 24) when frames(7 downto 3) = "00111" else 
                cs2(7 downto 0) when frames(7 downto 3)   = "01000" else  
                cs2(15 downto 8) when frames(7 downto 3)  = "01001" else  
                cs2(23 downto 16) when frames(7 downto 3) = "01010" else 
                cs2(31 downto 24) when frames(7 downto 3) = "01011" else 
                cs3(7 downto 0) when frames(7 downto 3)   = "01100" else  
                cs3(15 downto 8) when frames(7 downto 3)  = "01101" else  
                cs3(23 downto 16) when frames(7 downto 3) = "01110" else 
                cs3(31 downto 24) when frames(7 downto 3) = "01111" else 
                cs4(7 downto 0) when frames(7 downto 3)   = "10000" else  
                cs4(15 downto 8) when frames(7 downto 3)  = "10001" else  
                cs4(23 downto 16) when frames(7 downto 3) = "10010" else 
                cs4(31 downto 24) when frames(7 downto 3) = "10011" else 
                cs5(7 downto 0) when frames(7 downto 3)   = "10100" else  
                cs5(15 downto 8) when frames(7 downto 3)  = "10101" else  
                cs5(23 downto 16) when frames(7 downto 3) = "10110" else 
                cs5(31 downto 24);     --
    -- The channel status mux takes the 8-bit values from the channel status ROM
    -- and outputs one bit at a time, based on the LS 3 bits of the frame count.
    --
    cs_mux <= cs_rom(CONV_INTEGER(frames(2 downto 0)));

    --
    -- When the force_crc_err signal is asserted, this logic inverts the CRC 
    -- value.
    --
    cs <= cs_crc_out xor (crc_out_en and force_crc_err);

    --
    -- Channel status CRC generator
    --
    AESCRC: aes_crc
    port map (
        clk             => clk,
        ce              => ce_word,
        frames          => frames,
        din             => cs_mux,
        dout            => cs_crc_out,
        crc_out_en      => crc_out_en,
        frame191        => frames_tc,
        crc_err         => open);

    --
    -- Frame counter
    --
    -- The frame counter feeds into the CRC module and uses the decoded frame191
    -- signal from the CRC generator to indicate when to roll over to zero.
    --      
    process(clk)
    begin
        if rising_edge(clk) then
            if ce_word = '1' then
                if frames_tc = '1' then
                    frames <= (others => '0');
                else
                    frames <= frames + 1;
                end if;
            end if;
        end if;
    end process;

    --
    -- By delaying the frame191 signal from the CRC module by one frame, a
    -- frame0 signal is generated.
    --
    process(clk)
    begin
        if rising_edge(clk) then
            if ce_word = '1' then
                frame0 <= frames_tc;
            end if;
        end if;
    end process;
	 
	 
	 
	 

end Behavioral;




