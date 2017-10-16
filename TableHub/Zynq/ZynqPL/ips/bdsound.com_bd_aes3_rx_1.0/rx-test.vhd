
--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:17:15 10/10/2008
-- Design Name:   receiver
-- Module Name:   C:/Xilinx92i/projects/citac/tb_rx.vhd
-- Project Name:  citac
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: receiver
--
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends 
-- that these types always be used for the top-level I/O of a design in order 
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.std_logic_arith.all;
USE ieee.numeric_std.ALL;
use ieee.math_real.all; -- for UNIFORM, TRUNC

ENTITY tb_rx_vhd IS
END tb_rx_vhd;

ARCHITECTURE behavior OF tb_rx_vhd IS 

	-- Component Declaration for the Unit Under Test (UUT)
	COMPONENT aes3rx
	generic (
		reg_width : integer := 5
	);
   port (
      clk   : in  std_logic; -- master clock
      aes3  : in  std_logic; -- input 
      reset : in  std_logic; -- synchronous reset
      
      sdata : out std_logic; -- output serial data
      sclk  : out std_logic; -- output serial data clock
      bsync : out std_logic; -- block start (high when Z subframe is being transmitted)
      lrck  : out std_logic; -- frame sync (high for channel A, low for B)
      active: out std_logic;  -- receiver has valid data on its outputs
      dru_valid: out std_logic := '0';
      dru_out: out std_logic := '0'
   );
	end component;
	COMPONENT bdAES3rx
        port (
            -- Clock sources
            MCLK:                       in  std_logic;      -- 100 MHz XO   
            RST:                       in  std_logic;
            -- AES Rx pins
            din:                      in  std_logic;
    
            -- AES Rx1 Out internal
            ch0_out:                  out std_logic_vector (23 downto 0);              
            ch1_out:                  out std_logic_vector (23 downto 0);
    
            wclk_out:                  out std_logic;
            locked:                   out std_logic;
            audclk_out:               out std_logic
        );
    
    end component;
	--Inputs
	SIGNAL CLK_50MHZ :  std_logic := '0';
	SIGNAL RX :  std_logic := '0';
   signal TX : std_logic := '0';

	--Outputs
--	SIGNAL active : std_logic;
--	SIGNAL sdata :  std_logic;
--	SIGNAL sclk :  std_logic;
--	SIGNAL fsync :  std_logic;
--	signal bsync : std_logic;
	
   constant PERIOD : time := 10ns;
   constant DUTY_CYCLE : real := 0.5;
   constant OFFSET : time := 100 ns;
	type INT_ARRAY is array (integer range <>) of integer;
	shared variable vals : INT_ARRAY(0 to 191);
	
--	shared variable S : time :=155 ns;
--	shared variable M : time :=310 ns;
--	shared variable L : time :=485 ns;
	
	shared variable S : time :=38.75 ns;
    shared variable M : time :=77.5 ns;
    shared variable L : time :=116.25 ns;
	procedure vector2aes(vector : in std_logic_vector (23 downto 0); signal aes : inout  std_logic) is
	begin
		for i in 0 to 23 loop
			if vector(i) = '0' then
				aes <= not aes;
				wait for M;
			elsif vector(i) = '1' then
				aes <= not aes;
				wait for S;
				aes <= not aes;
				wait for S;
			end if;
		end loop;
	end procedure;
	
	procedure generate_block(pcm_data : in INT_ARRAY(0 to 191); signal aes : inout  std_logic; signal curr_val : out std_logic_vector(23 downto 0)) is
	begin
		-- Z preamble
		aes <= not aes;	
		wait for L;					
		aes <= not aes;	
		wait for S;
		aes <= not aes;	
		wait for S;
		aes <= not aes;	
		wait for L;

		vector2aes(conv_std_logic_vector(pcm_data(0), 24), aes);	
		curr_val <= conv_std_logic_vector(pcm_data(0), 24);

		aes <= not aes; -- 1.5
		wait for M;
		aes <= not aes; -- 1.5
		wait for M;
		aes <= not aes; -- 1.5
		wait for M;
		aes <= not aes; -- 1.5
		wait for M;				
				
		
		for i in 1 to 191 loop
			if i mod 2 /= 0 then --B subframe
				--Y preamble
				aes <= not aes; -- 1.5				
				wait for L;
				aes <= not aes; -- 1.5
				wait for M;
				aes <= not aes; -- 3
				wait for S;
				aes <= not aes; -- 3.5
				wait for M;		
				
			else --A subframe
				--X preamble
				aes <= not aes; -- 1.5				
				wait for L;
				aes <= not aes; 
				wait for L;
				aes <= not aes; 				
				wait for S;
				aes <= not aes; 
				wait for S;
				
			end if;
			curr_val <= conv_std_logic_vector(pcm_data(i), 24);

			vector2aes(conv_std_logic_vector(pcm_data(i), 24), aes);

			aes <= not aes; -- 1.5
			wait for M;
			aes <= not aes; -- 1.5
			wait for M;
			aes <= not aes; -- 1.5
			wait for M;
			aes <= not aes; -- 1.5
			wait for M;				
						
		end loop;
		
	end procedure;
	
	shared variable seed1 : positive;
	shared variable seed2 : positive;
	shared variable rand : real;
	signal curr_val : std_logic_vector(23 downto 0);
    signal RST : std_logic;

    signal new_data : std_logic;
    signal new_sclk : std_logic;
    signal new_bsync : std_logic;
    signal new_lrck : std_logic;
    signal new_active : std_logic;     
    signal new_dru_valid: std_logic;
    signal new_dru_out: std_logic;
    
    signal old_data0 : std_logic_vector (23 downto 0);     
    signal old_data1 : std_logic_vector (23 downto 0);  
    signal old_lrck : std_logic;
    signal old_locked : std_logic;
    signal old_sclk : std_logic;
             
BEGIN
	uut2: bdAES3rx
    port map(
        -- Clock sources
        MCLK => CLK_50MHZ,
        RST => RST,
        -- AES Rx pins
        din => RX,

        -- AES Rx1 Out internal
        ch0_out => old_data0,              
        ch1_out => old_data1,

        wclk_out => old_lrck,
        locked => old_locked,
        audclk_out => old_sclk
    );

	-- Instantiate the Unit Under Test (UUT)
	uut: aes3rx PORT MAP(
		clk  => CLK_50MHZ,
		aes3 => RX,
		reset => RST,
        sdata => new_data,
        sclk  => new_sclk,
        bsync => new_bsync,
        lrck => new_lrck,
        active => new_active,
        dru_valid => new_dru_valid,
        dru_out => new_dru_out
	);	
	
	PROCESS    -- clock process for CLK_50MHZ
	BEGIN
		WAIT for OFFSET;
		CLOCK_LOOP : LOOP
			 CLK_50MHZ <= '0';
			 WAIT FOR (PERIOD - (PERIOD * DUTY_CYCLE));
			 CLK_50MHZ <= '1';
			 WAIT FOR (PERIOD * DUTY_CYCLE);
		END LOOP CLOCK_LOOP;
	END PROCESS;

	tb : PROCESS
	BEGIN
		RST <= '1';
		wait for 1 ms;
		RST <= '0';
		wait for 100 ns;
	
		for i in 0 to 191 loop
			if i = 0 then
				vals(i) := 8388609;
			else 
				vals(i) := 8388609;
			end if;
		end loop;
		
		generate_block(vals, RX, curr_val);
		
		for i in 0 to 191 loop
			if i = 0 then
				vals(i) := 0;
			else 
				vals(i) := vals(i-1) + 10000;
			end if;
		end loop;
		
		generate_block(vals, RX, curr_val);
		
		
		-- Wait 100 ns for global reset to finish
		wait for 100 us;
      
      S := 81.2 ns;
      M := 162.6 ns;
      L := 244 ns;
      
      wait for 100 ns;
	
		for i in 0 to 191 loop
			if i = 0 then
				vals(i) := 0;
			else 
				vals(i) := 1;
			end if;
		end loop;
		
		generate_block(vals, RX, curr_val);
		
		for i in 0 to 191 loop
			if i = 0 then
				vals(i) := 0;
			else 
				vals(i) := vals(i-1) + 10000;
			end if;
		end loop;
		
		wait; -- will wait forever
	END PROCESS;

END;