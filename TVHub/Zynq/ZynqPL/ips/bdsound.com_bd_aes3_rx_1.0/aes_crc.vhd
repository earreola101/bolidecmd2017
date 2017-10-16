----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:22:02 03/17/2010 
-- Design Name: 
-- Module Name:    aes_crc - Behavioral 
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

entity aes_crc is
    port (
        clk:            in  std_logic;                      -- input clock
        ce:             in  std_logic;                      -- must be asserted once per frame
        frames:         in  std_logic_vector(7 downto 0);   -- frame count input
        din:            in  std_logic;                      -- channel status serial input
        dout:           out std_logic;                      -- channel status bitstream with CRC
        crc_out_en:     out std_logic;                      -- 1 during last 8 frames of block
        frame191:       out std_logic;                      -- 1 during last frame of block
        crc_err:        out std_logic);                     -- 1 when din is not equal to crc(0)
																				-- ... when crc_out_en is asserted
end aes_crc;

architecture Behavioral of aes_crc is

--
-- Internal signal definitions
--
signal crc            : std_logic_vector(7 downto 0) := (others => '0');    -- CRC register
signal crc_fb         : std_logic;                                          -- feedback signal
signal crc_out_en_int : std_logic;                                          -- internal version of crc_out_en
signal frame191_int   : std_logic;                                          -- internal version of frame191


begin


    --
    -- Decode the frame input and generate the frame191 and crc_out_en signals. 
    -- The frame191 signal is asserted when frames equals 191. The other signal 
    -- is asserted starting at frame 184 through frame 191.
    --
    frame191_int <= '1' when frames = "10111111" else '0';      -- 191 decimal
    frame191 <= frame191_int;

    crc_out_en_int <= '1' when frames(7 downto 3) = "10111" else '0';
    crc_out_en <= crc_out_en_int;

    --
    -- The dout signal is equal to din except during frames 184 to 191 when the
    -- calculated CRC bits are inserted.
    --
    dout <= crc(0) when crc_out_en_int = '1' else din;

    --
    -- The crc_fb signal is the feedback signal of the CRC polynomial generator.
    -- During frames 184 to 191, it is forced to zero so that the 8 bits of the
    -- calculated CRC value can be shifted out of the shift register without 
    -- being modified by the feedback signal.
    --
    crc_fb <= '0' when crc_out_en_int = '1' else din xor crc(0);

    --
    -- The crc_err signal is asserted during frames 184 to 191 if the LSB of the
    -- CRC shift register and the din signal do not match.
    --
    crc_err <= crc_out_en_int and (din xor crc(0));

    --
    -- This is the CRC register. It shifts one bit the right every time ce is
    -- asserted, generating the CRC value in the process. It parallel loads with
    -- all ones when frame191 is asserted.
    --
    process(clk)
    begin
        if rising_edge(clk) then
            if ce = '1' then
                if frame191_int = '1' then
                    crc <= "11111111";
                else
                    crc <= crc_fb & crc(7) & (crc(6) xor crc_fb) & 
                           (crc(5) xor crc_fb) & (crc(4) xor crc_fb) & 
                           crc(3 downto 1);
                end if;
            end if;
        end if;
    end process;

end Behavioral;

