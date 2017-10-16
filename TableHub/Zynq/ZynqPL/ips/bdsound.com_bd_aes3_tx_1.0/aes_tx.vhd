-------------------------------------------------------------------------------- 
-- Copyright (c) 2006 Xilinx, Inc. 
-- All Rights Reserved 
-------------------------------------------------------------------------------- 
--   ____  ____ 
--  /   /\/   / 
-- /___/  \  /   Vendor: Xilinx 
-- \   \   \/    Author: John F. Snow, Advanced Product Division, Xilinx, Inc.
--  \   \        Filename: $RCSfile: aes_tx.vhd,rcs $
--  /   /        Date Last Modified:  $Date: 2006-01-26 10:17:37-07 $
-- /___/   /\    Date Created: Jan 16, 2006
-- \   \  /  \ 
--  \___\/\___\ 
-- 
--
-- Revision History: 
-- $Log: aes_tx.vhd,rcs $
-- Revision 1.1  2006-01-26 10:17:37-07  jsnow
-- Added initial values for signals for simulation.
--
-- Revision 1.0  2006-01-25 14:31:56-07  jsnow
-- Initial version.
--
-------------------------------------------------------------------------------- 
--   
--   XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS" 
--   AS A COURTESY TO YOU, SOLELY FOR USE IN DEVELOPING PROGRAMS AND 
--   SOLUTIONS FOR XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE, 
--   OR INFORMATION AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE, 
--   APPLICATION OR STANDARD, XILINX IS MAKING NO REPRESENTATION 
--   THAT THIS IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT, 
--   AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE 
--   FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY 
--   WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE 
--   IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR 
--   REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF 
--   INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
--   FOR A PARTICULAR PURPOSE. 
--
-------------------------------------------------------------------------------- 
--
-- This modules implements an AES3 compliant transmitter. It accepts 24-bit 
-- audio data, a channel status bit, a user data bit, and a valid bit for two 
-- channels whenever the ce_word clock enable signal is asserted. It interleaves
-- the two channels, serializes the data, and bi-phase mark encodes the 
-- bitstream. The encoded bitstream is output on the serout port.
-- 
-- The module requires a clock and three clock enables. The clock must be 
-- related to the sample rate of the audio data. It may be a multiple of the 
-- audio sample rate. The ce_word clock enable is used with the input clock to 
-- clock data into the transmitter at the audio sample rate. The transmitter 
-- will accept one audio word for each channel, along with the associated valid,
-- user data, and channel status bits for each channel, on the rising edge of 
-- clk whenever ce_word is asserted.
-- 
-- In addition, the module requires two additional clock enables called ce_bit 
-- and ce_bp. ce_bit is used with clk to clock the portion of the transmitter 
-- logic that runs at the bit rate. There are 64-bits in a frame. ce_word is 
-- asserted once per frame so ce_bit must be asserted 64 times per frame. ce_bp
-- is the bi-phase encoded bitstream clock enable. It must be asserted 128 times
-- per frame. 
-- 
-- Example: A 24.576 MHz reference clock is connected to the clk port of the 
-- aes_tx module. The audio sample rate is 48 kHz. ce_word must be asserted once
-- every 512 clock cycles (24.576 MHz / 48 kHz = 512). ce_bit must be asserted
-- once every eight clock cycles (48 kHz * 64 bits = 3.072 MHz so 24.576 MHz /
-- 3.072 MHz = 8). ce_bp is asserted once every four clock cycles because it 
-- must run twice as fast as the bit rate. (24.576 MHz / 4 = 6.144 MHz).
-- 
-- The minimum clock frequency required to support 48 kHz sampled audio is
-- 6.144 MHz. If a 6.144 MHz clock is provided to the aes_tx module, ce_bp would
-- always be asserted high. ce_bit would be asserted every other clock cycle.
-- And, ce_word would be asserted once every 128 clock cycles (6.144 MHz / 128 =
-- 48 kHz).
-- 
-- Each channel has a channel status input bit (cs1 and cs2). The AES3 channel
-- status information consists of 192 bits per channel. The cs1 and cs2 pins
-- must be given a serial stream of 192 channel status bits starting with bit 0
-- of byte 0 and ending with bit 7 of byte 23. The frame0 input port is used to
-- indicate to the transmitter when bit 0 of byte 0 is present on the cs1 and 
-- cs2 inputs. A high on this signal forces the transmitter to generate a Z 
-- preamble marking the start of a block of 192 frames. frame0 must be asserted 
-- high once every 192 frames (once every 192 times that ce_word is asserted).
-- 
-- Each channel has a user data input bit (user1 and user2). These work just 
-- like the channel status bits. A serial stream of 192 user data bits can be 
-- fed to each user data input port. One user data bit from each channel will be
-- sent each frame. User data bit 0 of byte 0 must be present on the user data 
-- input ports when frame0 is 1. User data is an optional part of the AES3 spec.
-- If user data is not required, tie the two user data input ports low.
-- 
-- Each channel has a valid bit input port (valid1 and valid2). These ports are
-- used to indicate whether the associated audio sample word is valid. The valid
-- bits are inserted into each frame. If an audio channel is valid, the 
-- associated valid bit must be low.
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity aes_tx is
    port (
        clk:            in  std_logic;                      -- input clock
        rst:            in  std_logic;                      -- async reset
        ce_word:        in  std_logic;                      -- word clk enable
        ce_bit:         in  std_logic;                      -- bit clk enable
        ce_bp:          in  std_logic;                      -- biphase clk enable
        audio1:         in  std_logic_vector(23 downto 0);  -- ch1 audio word
        cs1:            in  std_logic;                      -- ch1 channel status
        valid1:         in  std_logic;                      -- ch1 valid bit
        user1:          in  std_logic;                      -- ch1 user data
        audio2:         in  std_logic_vector(23 downto 0);  -- ch2 audio word
        cs2:            in  std_logic;                      -- ch2 channel status
        valid2:         in  std_logic;                      -- ch2 valid bit
        user2:          in  std_logic;                      -- ch2 user data
        frame0:         in  std_logic;                      -- 1 = frame 0
        serout:         out std_logic);                     -- AES3 serial out
end aes_tx;

architecture synth of aes_tx is

--
-- Internal signal definitions
--
signal frame0_reg :     std_logic := '0';                                   -- input reg for frame0
signal inreg1 :         std_logic_vector(26 downto 0) := (others => '0');   -- input reg for chan 1
signal inreg2 :         std_logic_vector(26 downto 0) := (others => '0');   -- input reg for chan 2
signal sr :             std_logic_vector(27 downto 0) := (others => '0');   -- output shift register
signal parity1 :        std_logic;                                          -- calculated parity bit
signal parity2 :        std_logic;                                          -- calculated parity bit
signal out_xz :         std_logic := '0';                                   -- 1 = X/Z preamble being sent
signal out_y :          std_logic := '0';                                   -- 1 = Y preamble being sent
signal out_ch1 :        std_logic := '0';                                   -- 1 = chan 1 data being sent
signal out_ch2 :        std_logic := '0';                                   -- 1 = chan 2 data being sent
signal set_out_xz :     std_logic := '0';                                   -- sets out_xz signal
signal set_out_y :      std_logic := '0';                                   -- sets out_y signal
signal set_out_ch1 :    std_logic := '0';                                   -- sets out_ch1 signal
signal set_out_ch2 :    std_logic := '0';                                   -- sets out ch2 signal
signal seq :            std_logic_vector(36 downto 0) := (others => '0');   -- master sequencer for Tx
signal pre_sr :         std_logic_vector( 7 downto 0) := (others => '0');   -- preamble shift reg
signal last_state :     std_logic := '0';                                   -- retains last state for
                                                                            --   bi-phase encoder
signal dout :           std_logic := '0';                                   -- shift reg output to encoder
signal b0 :             std_logic;                                          -- intermediate bi-phase bit
signal b1 :             std_logic;                                          -- intermediate bi-phase bit
signal txd :            std_logic;                                          -- bi-phase encoder output
signal state :          std_logic := '0';                                   -- indicates which bit of 

constant PRE_X :        std_logic_vector(7 downto 0) := "01000111";
constant PRE_X_INV :    std_logic_vector(7 downto 0) := "10111000";
constant PRE_Y :        std_logic_vector(7 downto 0) := "00100111";
constant PRE_Y_INV :    std_logic_vector(7 downto 0) := "11011000";
constant PRE_Z :        std_logic_vector(7 downto 0) := "00010111";
constant PRE_Z_INV :    std_logic_vector(7 downto 0) := "11101000";
signal audio1_r: std_logic_vector(23 downto 0) := x"000000";  -- ch1 audio word
signal audio2_r: std_logic_vector(23 downto 0) := x"000000";  -- ch1 audio word

begin

    --
    -- This flip-flop indicates whether the first or second bit of the bi-phase
    -- encoded data is being generated by the encoder. This flip-flop is set to
    -- 1 when ce_bit and ce_bp are both asserted, otherwise it clears to 0.
    --
    process(clk, rst)
    begin
        if rst = '1' then
            state <= '0';
        elsif rising_edge(clk) then
            if ce_bp = '1' then
                state <= ce_bit;
            end if;
        end if;
    end process;

    --
    -- Input registers
    --
    -- These registers hold the audio, channel status, user data, and valid bits
    -- for each channel. An input register is also provided for the frame0 input
    -- to keep it synchronized with the input data.
    --
    process(clk)
    begin
        if rising_edge(clk) then
            audio1_r <= audio1;
            audio2_r <= audio2;
            if ce_word = '1' then
                inreg1 <= cs1 & user1 & valid1 & audio1_r;
                inreg2 <= cs2 & user2 & valid2 & audio2_r;
                frame0_reg <= frame0;
            end if;
        end if;
    end process;

    --
    -- Audio shift register
    --
    -- This shift register is loaded with the audio data, channel status bit, 
    -- user data bit, valid bit, and parity bit for the channel to be sent next 
    -- when the preamble for the subframe is being generated. When the channel 
    -- data is being output, this register shifts one bit MSB to LSB every time 
    -- that ce_bit is asserted.
    -- 
    process(clk)
    begin
        if rising_edge(clk) then
            if ce_bit = '1' then
                if seq(1) = '1' then
                    sr <= parity1 & inreg1;
                elsif seq(33) = '1' then
                    sr <= parity2 & inreg2;
                elsif out_ch1 ='1' or out_ch2 = '1' then
                    sr <= '0' & sr(27 downto 1);
                end if;
            end if;
        end if;
    end process;

    parity1 <= inreg1( 0) xor inreg1( 1) xor inreg1( 2) xor inreg1( 3) xor 
               inreg1( 4) xor inreg1( 5) xor inreg1( 6) xor inreg1( 7) xor
               inreg1( 8) xor inreg1( 9) xor inreg1(10) xor inreg1(11) xor
               inreg1(12) xor inreg1(13) xor inreg1(14) xor inreg1(15) xor
               inreg1(16) xor inreg1(17) xor inreg1(18) xor inreg1(19) xor
               inreg1(20) xor inreg1(21) xor inreg1(22) xor inreg1(23) xor
               inreg1(24) xor inreg1(25) xor inreg1(26);
               
    parity2 <= inreg2( 0) xor inreg2( 1) xor inreg2( 2) xor inreg2( 3) xor 
               inreg2( 4) xor inreg2( 5) xor inreg2( 6) xor inreg2( 7) xor
               inreg2( 8) xor inreg2( 9) xor inreg2(10) xor inreg2(11) xor
               inreg2(12) xor inreg2(13) xor inreg2(14) xor inreg2(15) xor
               inreg2(16) xor inreg2(17) xor inreg2(18) xor inreg2(19) xor
               inreg2(20) xor inreg2(21) xor inreg2(22) xor inreg2(23) xor
               inreg2(24) xor inreg2(25) xor inreg2(26);

    --
    -- Sequencer
    --
    -- The sequencer controls the timing of the transmitter. It consists of a 
    -- 37-bit shift register -- essentially a one-hot encoded state machine. The
    -- sequencer shifts a 1 into its LSB when ce_word is asserted. This 1 is 
    -- shifted left in the shift register every time ce_bit is asserted, timing 
    -- the transmission of all bits of the frame. Several outputs are 
    -- generated from the sequencer. out_xz is asserted for four bit times while
    -- the X or Z preamble is being transmitted. Next, the out_ch1 signal is 
    -- asserted for 28 bit times while the audio and other channel 1 data are 
    -- being transmitted. Next, out_y is asserted for four bit times while the Y
    -- preamble is transmitted. Finally, the out_ch2 signal is asserted for 28 
    -- bit times while the channel 2 data is sent.
    --
    process(clk)
    begin
        if rising_edge(clk) then
            if ce_bit = '1' then
                seq <= seq(35 downto 0) & ce_word;
            end if;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if ce_bit = '1' then
                set_out_xz  <= '0';
                set_out_y   <= '0';
                set_out_ch1 <= '0';
                set_out_ch2 <= '0';

                if seq(0) = '1' then
                    set_out_xz <= '1';
                end if;
    
                if seq(4) = '1' then
                    set_out_ch1 <= '1';
                end if;
    
                if seq(32) = '1' then
                    set_out_y <= '1';
                end if;

                if seq(36) = '1' then
                    set_out_ch2 <= '1';
                end if;
            end if;
        end if;
    end process;            

    process(clk, rst)
    begin
        if rst = '1' then
            out_xz <= '0';
        elsif rising_edge(clk) then
            if ce_bit = '1' then
                if set_out_xz = '1' then
                    out_xz <= '1';
                elsif set_out_ch1 = '1' then
                    out_xz <= '0';
                end if;
            end if;
        end if;
    end process;    
        
    process(clk, rst)
    begin
        if rst = '1' then
            out_ch1 <= '0';
        elsif rising_edge(clk) then
            if ce_bit = '1' then
                if set_out_ch1 = '1' then
                    out_ch1 <= '1';
                elsif set_out_y = '1' then
                    out_ch1 <= '0';
                end if;
            end if;
        end if;
    end process;        

    process(clk, rst)
    begin
        if rst = '1' then
            out_y <= '0';
        elsif rising_edge(clk) then
            if ce_bit = '1' then
                if set_out_y = '1' then
                    out_y <= '1';
                elsif set_out_ch2 = '1' then
                    out_y <= '0';
                end if;
            end if;
        end if;
    end process;

    process(clk, rst)
    begin
        if rst = '1' then
            out_ch2 <= '0';
        elsif rising_edge(clk) then
            if ce_bit = '1' then
                if set_out_ch2 = '1' then
                    out_ch2 <= '1';
                elsif set_out_xz = '1' then
                    out_ch2 <= '0';
                end if;
            end if;
        end if;
    end process;
                                
    --
    -- Preamble logic
    --
    -- The preamble logic generates the correct preamble pattern based on which
    -- preamble (X, Y, or Z) is being generated and the value of the last state
    -- of the bi-phase of the encoder prior to the preamble.
    --
    process(clk)
    begin
        if rising_edge(clk) then
            if ce_bp = '1' then
                if seq(1) = '1' and ce_bit = '1' then
                    if frame0_reg = '1' then
                        if b1 = '1' then
                            pre_sr <= PRE_Z_INV;
                        else
                            pre_sr <= PRE_Z;
                        end if;
                    else
                        if b1 = '1' then
                            pre_sr <= PRE_X_INV;
                        else
                            pre_sr <= PRE_X;
                        end if;
                    end if;
                elsif seq(33) = '1' and ce_bit = '1' then
                    if b1 = '1' then
                        pre_sr <= PRE_Y_INV;
                    else
                        pre_sr <= PRE_Y;
                    end if;
                else
                    pre_sr <= '0' & pre_sr(7 downto 1);
                end if;
            end if;
        end if;
    end process;

    --
    -- Output mux
    --
    -- This mux produces the dout signal which goes into the bi-phase encoder. 
    -- The mux select either the preamble shift register's LSB output or the 
    -- regular data shift register's LSB output depending on whether a preamble
    -- is be sent or regular data.
    --
    dout <= pre_sr(0) when out_xz = '1' or out_y = '1' else sr(0);

    --
    -- Biphase encoding
    --
    -- The bi-phase encoder produces two bits for each input bit. The bits of 
    -- the preamble bypass the bi-phase encoder because the preambles are pre-
    -- encoded by the preamble generator and because the preambles actually 
    -- contain illegal bi-phase encoded data so that they can be uniquely 
    -- identified by the receiver. For non preamble data, the first bit produced
    -- by the encoder is the inverse of the second bit generated for the 
    -- previously encoded bit. The second bit will be the same as the first bit 
    -- if the bit being encoded is 0 or it will be the inverse of the first bit 
    -- if the bit being encoded is 1.
    --
    b0 <= dout when out_xz = '1' or out_y = '1' else not last_state;
    b1 <= dout when out_xz = '1' or out_y = '1' else b0 xor dout;
    txd <= b0 when state = '1' else b1;

    process(clk)
    begin
        if rising_edge(clk) then
            if ce_bit = '1' then
                last_state <= b1;
            end if;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if ce_bp = '1' then
                serout <= txd;
            end if;
        end if;
    end process;

end synth;
