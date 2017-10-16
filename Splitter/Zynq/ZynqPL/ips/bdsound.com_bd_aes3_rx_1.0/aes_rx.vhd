----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:20:30 03/17/2010 
-- Design Name: 
-- Module Name:    aes_rx - Behavioral 
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

entity aes_rx is

   generic (
        LCK_BITS :      integer := 15);                     -- # of bits in lock timeout counter
    port (
        clk:            in  std_logic;                      -- input clock
        rst:            in  std_logic;                      -- async reset input
        din:            in  std_logic;                      -- serial AES data input
        mux_mode:       in  std_logic;                      -- 1 = channel mux, 0 = channel de-mux
        locked:         out std_logic;                      -- interface locked indicator

-- The channel 1 outputs are only active in de-mux mode (mux_mode = 0)
        chan1_en:       out std_logic;                      -- output enable for chan 1 (mux mode only)
        audio1:         out std_logic_vector(23 downto 0);  -- chan 1 audio
        valid1:         out std_logic;                      -- chan 1 valid bit
        user1:          out std_logic;                      -- chan 1 user data bit
        cs1:            out std_logic;                      -- chan 1 status

-- The channel 2 outputs carry the information for audio channel 2 in de-mux 
-- mode or both channel in mux mode.
        chan2_en:       out std_logic;                      -- chan 2 output enable
        audio2:         out std_logic_vector(23 downto 0);  -- chan 2 audio
        valid2:         out std_logic;                      -- chan 2 valid bit
        user2:          out std_logic;                      -- chan 2 user data
        cs2:            out std_logic;                      -- chan 2 status

        parity_err:     out std_logic;                      -- 1 = parity error
        frames:         out std_logic_vector(7 downto 0);   -- audio frame counter
        frame0:         out std_logic;
		  clk_6M : out std_logic);                     -- 1 during frame 0



end aes_rx;

architecture Behavioral of aes_rx is

subtype lockcntr_type is std_logic_vector(LCK_BITS-1 downto 0);
--
-- Internal signal definitions
--
signal recdata :            std_logic;                                          -- data from data recovery unit
signal recdata_valid :      std_logic;                                          -- data enable from data recovery unit
signal framer_out :         std_logic_vector(7 downto 0);                       -- framed and decoded data bytes
signal framer_valid :       std_logic;                                          -- framer data enable output
signal x_preamble :         std_logic;                                          -- X preamble detect
signal y_preamble :         std_logic;                                          -- Y preamble detect
signal z_preamble :         std_logic;                                          -- Z preamble detect
signal channel1 :           std_logic;                                          -- chan 1 enable from formatter
signal channel2 :           std_logic;                                          -- chan 2 enable from formatter
signal audio :              std_logic_vector(23 downto 0);                      -- multiplexed audio from formatter
signal valid :              std_logic;                                          -- multiplexed valid signal from formatter
signal user_data :          std_logic;                                          -- multiplexed user data from formatter
signal cs :                 std_logic;                                          -- multiplexed cs bit from formatter
signal locked_timeout :     lockcntr_type := (others => '0');                   -- used to generate locked output
signal locked_timeout_tc :  lockcntr_type := (others => '1');                   -- terminal count for locked_timeout
signal audio1_hold :        std_logic_vector(23 downto 0) := (others => '0');   -- demux register
signal valid1_hold :        std_logic := '0';                                   -- demux register
signal user1_hold :         std_logic := '0';                                   -- demux register
signal cs1_hold :           std_logic := '0';                                   -- demux register
signal parity_err_int :     std_logic;                                          -- parity error detect
signal frames_int :         std_logic_vector(7 downto 0) := (others => '0');    -- formatter frame counter output   
signal frames_int_zero :    std_logic_vector(7 downto 0);                       -- compared to frames_int to detect all zeros
signal dru_lock     : std_logic;
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
	
component aes_dru
    port (
        clk:            in  std_logic;     
        rst:            in  std_logic;     
        serin:          in  std_logic;     
        data_out:       out std_logic;     
        data_valid:     out std_logic); 
end component;
component aes_dru_2
    port (
        clk:            in  std_logic;     
        rst:            in  std_logic;     
        serin:          in  std_logic;     
        data_out:       out std_logic;     
        data_valid:     out std_logic;
        lock:              out std_logic); 
end component;
component aes_framer
    port (
        clk:            in  std_logic;  
        rst:            in  std_logic;  
        din_valid:      in  std_logic;  
        din:            in  std_logic;  
        dout_valid:     out std_logic;  
        dout:           out std_logic_vector(7 downto 0);
        x_preamble:     out std_logic;  
        y_preamble:     out std_logic;  
        z_preamble:     out std_logic); 
end component;

component aes_rx_formatter
    port (
        clk:            in  std_logic;
        din_valid:      in  std_logic;
        din:            in  std_logic_vector(7 downto 0);
        x_preamble:     in  std_logic; 
        y_preamble:     in  std_logic;
        z_preamble:     in  std_logic;
        channel1:       out std_logic; 
        channel2:       out std_logic; 
        audio:          out std_logic_vector(23 downto 0);
        valid:          out std_logic; 
        parity_err:     out std_logic; 
        user:           out std_logic; 
        cs:             out std_logic; 
        frames:         out std_logic_vector(7 downto 0));
end component;

begin


    --
    -- AES data recovery unit
    --
    -- The DRU will produce one recovered bit whenever the recdata_valid signal
    -- is asserted. Use recdata_valid as the clock enable to the framer module.
    --
--    AESDRU: aes_dru
--        port map (
--            clk         => clk,
--            rst         => rst,
--            serin       => din,
--            data_out    => recdata,
--            data_valid  => recdata_valid);
        AESDRU: aes_dru_2
        port map (
            clk         => clk,
            rst         => rst,
            serin       => din,
            data_out    => recdata,
            data_valid  => recdata_valid,
            lock        => dru_lock);       
   	-- Instantiate the Unit Under Test (UUT)
--        AESDRU: aes3rx PORT MAP(
--            clk  => clk,
--            aes3 => din,
--            reset => rst,
--            sdata => open,
--            sclk  => open,
--            bsync => open,
--            lrck => open,
--            active => open,
--            dru_valid => recdata_valid,
--            dru_out => recdata
--        );             
            
            
clk_6M <= recdata_valid;
    --
    -- AES framer
    --
    -- The framer looks for preamble sequences. When one is detected, it then 
    -- aligns all subsequent data to the same word alignment as the preamble 
    -- until a preamble at a different alignment is found. The input to the 
    -- framer is serial data from the data recovery unit with a valid signal 
    -- indicating when the data bit is valid. The output from the framer is 
    -- 8-bit data words with a valid bit indicating when the output word of the 
    -- framer is valid.
    --
    -- The framer also generates x, y, and z preamble indicator signals.
    --
    AESFRM: aes_framer
    port map (
        clk         => clk,
        rst         => rst,
        din_valid   => recdata_valid,
        din         => recdata,
        dout_valid  => framer_valid,
        dout        => framer_out,
        x_preamble  => x_preamble,
        y_preamble  => y_preamble,
        z_preamble  => z_preamble);
            
    --
    -- AES data formatter
    --
    -- The formatter modules takes the framed data words and preamble indicators 
    -- from the framer module and separates the data into audio words, user data
    -- bits, channel status bits, and valid bits.
    --
    AESFMT: aes_rx_formatter
    port map (
        clk         => clk,
        din_valid   => framer_valid,
        din         => framer_out,
        x_preamble  => x_preamble,
        y_preamble  => y_preamble,
        z_preamble  => z_preamble,
        channel1    => channel1,
        channel2    => channel2,
        audio       => audio,
        valid       => valid,
        parity_err  => parity_err_int,
        user        => user_data,
        cs          => cs,
        frames      => frames_int);

    --
    -- Rx locked signal generator
    --
    -- The locked detector will assert the locked signal as long as a Y preamble
    -- is detected at least every 1024 clock cycles. A Y preamble occurs every
    -- frame and a frame will last about 256 clock cycles, so a 1024 clock cycle
    -- timeout is more than ample.
    --
    process(clk)
    begin
        if rising_edge(clk) then
            if y_preamble = '1' and framer_valid = '1' then
                locked_timeout <= (others => '0');
            else
                locked_timeout <= locked_timeout + 1;
            end if;
        end if;
    end process;

    process(clk, rst)
    begin
        if rst = '1' then
            locked <= '0';
        elsif rising_edge(clk) then
            if(dru_lock='1')then
                if y_preamble = '1' and framer_valid = '1' then
                    locked <= '1';
                elsif locked_timeout = locked_timeout_tc then
                    locked <= '0';
                end if;
            else
                locked <= '0';
            end if;
        end if;
    end process;

    --
    -- Demux registers
    --
    -- These registers hold the channel one data from the formatter so that it
    -- can be output with the channel 2 data in demultiplexed mode.
    --
    process(clk)
    begin
        if rising_edge(clk) then
            if channel1 = '1' then
                audio1_hold <= audio;
                valid1_hold <= valid;
                user1_hold  <= user_data;
                cs1_hold    <= cs;
            end if;
        end if;
    end process;

    --
    -- Output registers
    --
    -- The channel 1 output registers and the frame0 and frames output registers
    -- load when the channel2 signal from the formatter is asserted. The channel
    -- one registers load from the channel 1 demux registers.
    --
    -- The channel 2 output registers load only when the channel2 signal is
    -- asserted in demultiplexed mode. However, in multiplexed mode, the channel
    -- 2 output registers load on both the channel1 and channel2 signals so as 
    -- to load the multiplexed data for both channels.
    --
    -- Output registers are provided for the channel enables and the parity 
    -- error to keep them synchronized with the data.
    --
    frames_int_zero <= (others => '0');

    process(clk)
    begin
        if rising_edge(clk) then
			if mux_mode = '0'   then
            if channel2 = '1' then
                audio1 <= audio1_hold;
                valid1 <= valid1_hold;
                user1  <= user1_hold;
                cs1    <= cs1_hold;
                frames <= frames_int;
                
                if frames_int = frames_int_zero then
                    frame0 <= '1';
                else
                    frame0 <= '0';
                end if;
            end if;
			 else 
					 audio1 <= x"000000";
                valid1 <= '0';
                user1  <= '0';
                cs1    <= '0';
                frames <= x"00";
					 if frames_int = frames_int_zero then
                    frame0 <= '1';
                else
                    frame0 <= '0';
                end if;
			 end if;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if channel2 = '1' or (channel1 = '1' and mux_mode = '1') then
                audio2 <= audio;
                valid2 <= valid;
                user2  <= user_data;
                cs2    <= cs;
            end if;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            chan1_en <= mux_mode and channel1;
            chan2_en <= channel2;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if channel1 = '1' or channel2 = '1' then
                parity_err <= parity_err_int;
            end if;
        end if;
    end process;





end Behavioral;

