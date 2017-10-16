----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:31:01 03/17/2010 
-- Design Name: 
-- Module Name:    aes_rx_formatter - Behavioral 
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

entity aes_rx_formatter is

   port (
        clk:            in  std_logic;                      -- input clock
        din_valid:      in  std_logic;                      -- input clock enable
        din:            in  std_logic_vector(7 downto 0);   -- 16-bit input data
        x_preamble:     in  std_logic;                      -- X preamble detect
        y_preamble:     in  std_logic;                      -- Y preamble detect
        z_preamble:     in  std_logic;                      -- Z preamble detect
        channel1:       out std_logic;                      -- chan1 out data valid
        channel2:       out std_logic;                      -- chan2 out data valid
        audio:          out std_logic_vector(23 downto 0);  -- audio data
        valid:          out std_logic;                      -- valid bit for each word
        parity_err:     out std_logic;                      -- 1 = parity error
        user:           out std_logic;                      -- user data bit
        cs:             out std_logic;                      -- channel status bit
        frames:         out std_logic_vector(7 downto 0));  -- frame counter


end aes_rx_formatter;

architecture Behavioral of aes_rx_formatter is


--
-- Internal signal definitions
--
signal in_reg :     std_logic_vector(31 downto 4) := (others => '0');   -- input register
signal sub :        std_logic := '0';                                   -- 1=subframe 2, 0=subframe 1 
signal bytes :      std_logic_vector(3 downto 0) := (others => '0');    -- byte counter
signal preamble_in: std_logic;                                          -- OR of 3 preamble signals
signal ce :         std_logic := '0';                                   -- din valid delayed by 1 clk
signal ld_out :     std_logic;                                          -- loads the output reg
signal frames_int : std_logic_vector(7 downto 0) := (others => '0');    -- frame counter



begin


   preamble_in <= x_preamble or y_preamble or z_preamble;

    --
    -- Byte counter
    --
    -- This is a 4-bit one-hot encoded counter. It is set to 0001 when a 
    -- preamble preamble_in is asserted. It then sequences through its four 
    -- possible states on each clock cycle when din_valid is asserted. The 
    -- counter will terminate in a count of all zeros if a preamble does not 
    -- occur every four bytes.
    -- 
    process(clk)
    begin
        if rising_edge(clk) then
            if din_valid = '1' then
                if preamble_in = '1' then
                    bytes <= "0001";
                else
                    bytes <= bytes(2 downto 0) & '0';
                end if;
            end if;
        end if;
    end process;

    --
    -- Input register
    --
    -- The 32-bit input register is loaded with four consecutive input bytes using
    -- the bytes counter to determine which byte is to be loaded.
    --
    process(clk)
    begin
        if rising_edge(clk) then
            if din_valid = '1' then
                if preamble_in = '1' then
                    in_reg(7 downto 4) <= din(7 downto 4);
                elsif bytes(0) = '1' then
                    in_reg(15 downto 8) <= din;
                elsif bytes(1) = '1' then
                    in_reg(23 downto 16) <= din;
                elsif bytes(2) = '1' then
                    in_reg(31 downto 24) <= din;
                end if;
            end if;
        end if;
    end process;

    --
    -- Subframe tracker
    --
    -- The subframe tracker keeps track of whether the current subframe is for
    -- channel 0 or channel 1.
    process(clk)
    begin
        if rising_edge(clk) then
            if din_valid = '1' then
                if y_preamble = '1' then
                    sub <= '1';
                elsif z_preamble = '1' or x_preamble = '1' then
                    sub <= '0';
                end if;
            end if;
        end if;
    end process;


    --
    -- Frame counter
    --
    -- The 8-bit frame counter is reset to zero on a Z preamble and increments 
    -- on X preambles.
    --
    process(clk)
    begin
        if rising_edge(clk) then
            if din_valid = '1' then
                if z_preamble = '1' then
                    frames_int <= (others => '0');
                elsif x_preamble = '1' then
                    frames_int <= frames_int + 1;
                end if;
            end if;
        end if;
    end process;

    frames <= frames_int;

    --
    -- Output clock enable 
    --
    -- The output register clock enable is simply din_valid delayed by one clock
    -- cycle. The output register loads when ce is asserted and the bytes 
    -- counter reaches terminal count indicating that all four input bytes have 
    -- been loaded into the input register.
    --
    process(clk)
    begin
        if rising_edge(clk) then
            ce <= din_valid;
        end if;
    end process;

    ld_out <= ce and bytes(3);

    --
    -- Audio output register
    --
    process(clk)
    begin
        if rising_edge(clk) then
            if ld_out = '1' then
                audio <= in_reg(27 downto 4);
            end if;
        end if;
    end process;

    --
    -- Channel indicator
    --
    process(clk)
    begin
        if rising_edge(clk) then
            channel1 <= ld_out and not sub;
            channel2 <= ld_out and sub;
        end if;
    end process;

    --
    -- Valid bit output register
    --
    process(clk)
    begin
        if rising_edge(clk) then
            if ld_out = '1' then
                valid <= in_reg(28);
            end if;
        end if;
    end process;

    --
    -- User data bit output register
    --
    process(clk)
    begin
        if rising_edge(clk) then
            if ld_out = '1' then
                user <= in_reg(29);
            end if;
        end if;
    end process;

    --
    -- Channel status output register
    --
    process(clk)
    begin
        if rising_edge(clk) then
            if ld_out = '1' then
                cs <= in_reg(30);
            end if;
        end if;
    end process;

    --
    -- Parity error detection
    --
    process(clk)
    begin
        if rising_edge(clk) then
            if ld_out = '1' then
                parity_err <= in_reg(31) xor in_reg(30) xor in_reg(29) xor
                              in_reg(28) xor in_reg(27) xor in_reg(26) xor
                              in_reg(25) xor in_reg(24) xor in_reg(23) xor
                              in_reg(22) xor in_reg(21) xor in_reg(20) xor
                              in_reg(19) xor in_reg(18) xor in_reg(17) xor
                              in_reg(16) xor in_reg(15) xor in_reg(14) xor
                              in_reg(13) xor in_reg(12) xor in_reg(11) xor
                              in_reg(10) xor in_reg( 9) xor in_reg( 8) xor
                              in_reg( 7) xor in_reg( 6) xor in_reg( 5) xor
                              in_reg( 4);
            end if;
        end if;
    end process;



end Behavioral;

