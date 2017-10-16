----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:26:05 03/17/2010 
-- Design Name: 
-- Module Name:    aes_framer - Behavioral 
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

entity aes_framer is

    port (
        clk:            in  std_logic;                      -- input clock
        rst:            in  std_logic;                      -- async reset
        din_valid:      in  std_logic;                      -- input clock enable
        din:            in  std_logic;                      -- serial input data
        dout_valid:     out std_logic;                      -- output data valid
        dout:           out std_logic_vector(7 downto 0);   -- output decoded & framed data
        x_preamble:     out std_logic;                      -- x preamble
        y_preamble:     out std_logic;                      -- y preamble
        z_preamble:     out std_logic);                     -- z preamble


end aes_framer;

architecture Behavioral of aes_framer is


--
-- Internal signal definitions
--
signal in_sr :      std_logic_vector(8 downto 0) := (others => '0');    -- 9-bit input shift reg
signal deser :      std_logic_vector(7 downto 0) := (others => '0');    -- 8-bit deserialization reg
signal deser_ce :   std_logic;                                          -- clock enable for deser reg
signal predet_in :  std_logic_vector(7 downto 0);                       -- 8-bit input to preamble detect
signal x_detect :   std_logic;                                          -- X preamble detect
signal y_detect :   std_logic;                                          -- Y preamble detect
signal z_detect :   std_logic;                                          -- Z preamble detect
signal pre_detect : std_logic;                                          -- any preamble detect
signal fixed_match: std_logic;                                          -- partial result used in preamble detect
signal dout_ld :    std_logic;                                          -- load enable for dout reg
signal state :      std_logic := '0';                                   -- control state bit
signal bitcntr :    std_logic_vector(2 downto 0) := (others => '0');    -- deserial bit counter
signal int_xyz :    std_logic_vector(2 downto 0) := (others => '0');    -- internal XYZ preamble indicator bits


begin


   --
    -- Input shift register
    --
    -- This register holds nine bits received serially from the data recovery 
    -- unit. The nine bits are prior to bi-phase decoding so they are really 
    -- half bits, not full bits. These nine bits are fed to the preamble 
    -- detection logic.
    --
    process(clk)
    begin
        if rising_edge(clk) then
            if din_valid = '1' then
                in_sr <= din & in_sr(8 downto 1);
            end if;
        end if;
    end process;
    
    --
    -- Preamble detect logic
    --
    -- This logic examines the 9 bits in the input shift register to see if they
    -- match the known patterns for the preamble sequences. The LSB is actually
    -- from the previous word, not part of the preamble, but it dictates the
    -- polarity of the preamble.
    --

    -- Invert the 8-bits of the potential preamble if the bit received just 
    -- prior was 1. This allows the preamble detection logic to only detect one 
    -- polarity of the preamble.
    predet_in <= not in_sr(8 downto 1) when in_sr(0) = '1' else in_sr(8 downto 1);

    -- See if the five fixed value bits of the preamble match.
    fixed_match <= predet_in(0) and predet_in(1) and predet_in(2) and 
                   not predet_in(3) and not predet_in(7);

    -- If one, and only one, of the X, Y, or Z bits is asserted, then assert the
    -- corresponding preamble detect signal and the pre_detect signal.
    x_detect <= '1' when fixed_match = '1' and predet_in(6 downto 4) = "100" else '0';
    y_detect <= '1' when fixed_match = '1' and predet_in(6 downto 4) = "010" else '0';
    z_detect <= '1' when fixed_match = '1' and predet_in(6 downto 4) = "001" else '0';

    pre_detect <= '1' when fixed_match = '1' and 
                      ((predet_in(6 downto 4) = "001") or
                       (predet_in(6 downto 4) = "010") or
                       (predet_in(6 downto 4) = "100"))
                  else '0';

    --
    -- Deserialization register
    --
    -- This eight bit shift register shifts in one decoded bit whenever the 
    -- control logic asserts the deser_ce signal. Once eight bits have been 
    -- shifted into this register, the output register loads them to generate 
    -- the eight-bit parallel output word. Proper framing of the bytes is 
    -- accomplished by resetting a bit counter when the preamble is detected.
    --
    -- Note that in_sr shifts with every input bit, but deser shifts every other
    -- input bits because it takes two input bits from the AES bitstream to
    -- produce one decoded bit in the deser register.
    --
    process(clk)
    begin
        if rising_edge(clk) then
            if deser_ce = '1' then
                deser <= (in_sr(1) xor in_sr(2)) & deser(7 downto 1);
            end if;
        end if;
    end process;
    
    --
    -- Output register
    --
    -- This 8-bit output data register loads from the deserialization register
    -- whenever the dout_ld signal is asserted by the control logic.
    --
    process(clk)
    begin
        if rising_edge(clk) then
            if dout_ld = '1' then
                dout <= deser;
            end if;
        end if;
    end process;

    --
    -- Framer control logic
    --
    -- The framer control logic consists of a two-state state machine. The state
    -- is forced to 0 when pre_detect is asserted. Otherwise, it toggles states 
    -- every time din_valid is asserted. The state bit tracks the status of the 
    -- two input bits required to decode a bi-phase encoded bit. When the state 
    -- bit is 1, the in_sr(2:1) bits contain the two values needed to decode a 
    -- bi-phase encoded bit.  
    --
    -- A 3-bit bit counter is cleared to 0 when pre_detect is asserted. 
    -- Otherwise, it increments by one every time a bit is shifted into the 
    -- deserialization register. The counter is to generate the dout_ld signal 
    -- when the deserialization register is full.
    -- 
    process(clk, rst)
    begin
        if rst = '1' then
            state <= '0';
        elsif rising_edge(clk) then
            if din_valid = '1' then
                if pre_detect = '1' then
                    state <= '0';
                else
                    state <= not state;
                end if;
            end if;
        end if;
    end process;

    process(clk, rst)
    begin
        if rst = '1' then
            bitcntr <= (others => '0');
        elsif rising_edge(clk) then
            if din_valid = '1' then
                if pre_detect = '1' then
                    bitcntr <= (others => '0');
                elsif deser_ce = '1' then
                    bitcntr <= bitcntr + 1;
                end if;
            end if;
        end if;
    end process;

    deser_ce <= state and din_valid;
    dout_ld <= '1' when state = '0' and din_valid = '1' and (bitcntr = "111") 
               else '0';

    --
    -- Delay register for preamble detect bits
    --
    -- This register implements an internal pipeline delay so that the 
    -- x_preamble, y_preamble, and z_preamble outputs can be asserted 
    -- synchronously with the out going word containing the preamble.
    process(clk, rst)
    begin
        if rst = '1' then
            int_xyz <= (others => '0');
        elsif rising_edge(clk) then
            if din_valid = '1' then
                if pre_detect = '1' then
                    int_xyz <= x_detect & y_detect & z_detect;
                elsif bitcntr = "111" then
                    int_xyz <= (others => '0');
                end if;
            end if;
        end if;
    end process;

    process(clk, rst)
    begin
        if rst = '1' then
            x_preamble <= '0';
            y_preamble <= '0';
            z_preamble <= '0';
        elsif rising_edge(clk) then
            if dout_ld = '1' then
                x_preamble <= int_xyz(2);
                y_preamble <= int_xyz(1);
                z_preamble <= int_xyz(0);
            end if;
        end if;
    end process;
    
    -- 
    -- dout_valid generator
    --
    -- This implements a pipeline delay so that dout_valid is asserted when the
    -- data word in the dout register has been updated.
    -- 
    process(clk, rst)
    begin
        if rst = '1' then
            dout_valid <= '0';
        elsif rising_edge(clk) then
            dout_valid <= dout_ld;
        end if;
    end process;





end Behavioral;

