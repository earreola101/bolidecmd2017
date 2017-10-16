-------------------------------------------------------------------------------- 
-- Copyright (c) 2006 Xilinx, Inc. 
-- All Rights Reserved 
-------------------------------------------------------------------------------- 
--	 ____  ____	
--	/	/\/	  /	
-- /___/  \	 /	 Vendor: Xilinx	
-- \   \   \/	 Author: John F. Snow, Advanced	Product	Division, Xilinx, Inc.
--	\	\		 Filename: $RCSfile: aes_tx_clkdiv.vhd,rcs $
--	/	/		 Date Last Modified:  $Date: 2006-05-22 15:44:40-06 $
-- /___/   /\	 Date Created: May 5, 2006
-- \   \  /	 \ 
--	\___\/\___\	
-- 
--
-- Revision	History: 
-- $Log: aes_tx_clkdiv.vhd,rcs $
-- Revision 1.0  2006-05-22 15:44:40-06  jsnow
-- Initial version.
--
-------------------------------------------------------------------------------- 
--	 
--	 XILINX	IS PROVIDING THIS DESIGN, CODE,	OR INFORMATION "AS IS" 
--	 AS	A COURTESY TO YOU, SOLELY FOR USE IN DEVELOPING	PROGRAMS AND 
--	 SOLUTIONS FOR XILINX DEVICES.	BY PROVIDING THIS DESIGN, CODE,	
--	 OR	INFORMATION	AS ONE POSSIBLE	IMPLEMENTATION OF THIS FEATURE,	
--	 APPLICATION OR	STANDARD, XILINX IS	MAKING NO REPRESENTATION 
--	 THAT THIS IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT, 
--	 AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE 
--	 FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY	DISCLAIMS ANY 
--	 WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE 
--	 IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR	
--	 REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF 
--	 INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
--	 FOR A PARTICULAR PURPOSE. 
--
-------------------------------------------------------------------------------- 
--This module is an	example	of a clock divider to generate the three clock
--enables required by the AES3 Tx module. When provided	with a 24.576 MHz clock
--input, this module can produce clock enables for sample rates	based around
--48 kHz, up to	192	kHz. When provided with	a 22.5792 MHz	clock, this	module 
--can produce clock	enables	for	sample rates based around the 44.1 kHz,	up to
-- 176.4 kHz.
--
--The divisor input	sets the audio sample rate.	The	input clock	is divided by
--the divisor+1	to produce the bi-phase	symbol rate	clock enable. The bit rate 
--clock	enable is	half the frequency of the bi-phase symbol clock	enable.	The
--sample rate (word) clock enable is equal to the bit rate clock enable	divided
--by 64.
--
--With a 24.576	MHz	clock input, the following audio sample	rates are generated
--by the divisor values	shown below:
--
--divisor		Sample Rate
--	 0		  192 kHz
--	 1			 96	kHz
--	 3		   48 kHz
--	 5		   32 kHz
--	11		   16 kHz
--	
--With a 22.5792 MHz clock input, the following	audio sample rates are generated
--by the divisor values	shown below:
--
--divisor		Sample Rate
--	 0		 176.4 kHz
--	 1			88.2 kHz
--	 3		  44.1 kHz
--	 7		  22.05kHz
--
--The divisor inputs should	only be	changed	synchronously with clk.	To prevent 
--runt intervals, the divisor inputs should	only change	when ce_word is	asserted.
--------------------------------------------------------------------------------

library	ieee;
use	ieee.std_logic_1164.all;
use	ieee.std_logic_unsigned.all;
use	ieee.std_logic_arith.all;
use	ieee.numeric_std.all;
	
library	unisim;	
use	unisim.vcomponents.all;	

entity aes_tx_clkdiv is
	port (
		clk:			in	  std_logic;					-- input clock
		divisor:		in	  std_logic_vector(3 downto	0);	-- first state divisor
		ce_bp:			inout std_logic;					-- bi-phase	symbol rate	ce
		ce_bit:			inout std_logic;					-- bit rate	ce
		ce_word:		inout std_logic					-- sample rate ce
);
end	aes_tx_clkdiv;

architecture synth of aes_tx_clkdiv	is

--
-- Internal	signal definitions
--
signal vardiv :		std_logic_vector(3 downto 0) :=	"0000";	-- variable	divider
signal div2	:		   std_logic := '0';						-- divide by 2 for bit rate	ce
signal div64a :		std_logic;								-- first stage of /64
--signal div64b :		std_logic;								-- second stage	of /64
signal div64b_ce :	std_logic;								-- ce for div64b SRL16E
signal div64b:       std_logic;

begin

	--
	-- First stage divider
	--
	-- This	stage divides by 1 through 16 depending	on the divisor input. The
	-- output of this stage	is the bi-phase	symbol rate	clock enable.
	--
	process(clk)
	begin
		if rising_edge(clk)	then
			if ce_bp = '1' then
				vardiv <= (others => '0');
			else
				vardiv <= vardiv + "0001";
			end	if;
		end	if;
	end	process;

	ce_bp <= '1' when vardiv = divisor else	'0';

	--
	-- Second stage	divider
	--
	-- This	stage always divides by	2 to generate the bit rate clock enable.
	--
	process(clk)
	begin
		if rising_edge(clk)	then
			if ce_bp = '1' then
				div2 <=	not	div2;
			end	if;
		end	if;
	end	process;

	ce_bit <= div2 and ce_bp;

	--
	-- Third stage divider
	--
	-- This	stage always divides by	64 to get the sample (word)	rate clock enable.
	-- This	stage consists of two SRL16E primitives. The first divides by 16 and
	-- the second divides by 4 to get a	total division of 64.
	--
	DIV64_A: SRL16E
		generic	map	(
			INIT	=> X"0001")
		port map (
			CLK		=> clk,
			CE		=> ce_bit,
			D		=> div64a,
			A0		=> '1',
			A1		=> '1',
			A2		=> '1',
			A3		=> '1',
			Q		=> div64a);

	div64b_ce <= ce_bit	and	div64a;

	DIV64_B: SRL16E
		generic	map	(
			INIT	=> X"0001")
		port map (
			CLK		=> clk,
			CE		=> div64b_ce,
			D		=> div64b,
			A0		=> '1',
			A1		=> '1',
			A2		=> '0',
			A3		=> '0',
			Q		=> div64b);

	ce_word	<= div64b and div64a and ce_bp and div2;

end	synth;
