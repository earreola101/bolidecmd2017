----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:24:39 03/17/2010 
-- Design Name: 
-- Module Name:    aes_dru - Behavioral 
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

entity aes_dru is


    generic (
        UPDATE_CNTR_WIDTH:  integer := 10;
        MIN_VAL_WIDTH:      integer := 10);
    port (
        clk:            in  std_logic;      -- 4X oversampling clock
        rst:            in  std_logic;      -- async reset
        serin:          in  std_logic;      -- serial bitstream input
        data_out:       out std_logic;      -- recovered data serial out
        data_valid:     out std_logic);     -- asserted when data_out is valid


end aes_dru;

architecture Behavioral of aes_dru is

subtype min_type is std_logic_vector(MIN_VAL_WIDTH-1 downto 0);
subtype upd_type is std_logic_vector(UPDATE_CNTR_WIDTH-1 downto 0);

--
-- Internal signal definitions
--
signal inffs :          std_logic_vector(2 downto 0);   -- edge detection FFs
signal edge_detect :    std_logic;                      -- edge detection signal
signal min_cntr :       min_type;                       -- counts clocks between edges
signal min_capture :    min_type;                       -- minimum capture reg
signal min_hold :       min_type;                       -- minimum value hold reg
signal update_min :     std_logic;                      -- update the min cap & hold regs
signal new_min :        std_logic;                      -- symlen_cntr < min_capture
signal update_cntr :    upd_type;                       -- update period counter
signal update_tc :      upd_type := (others => '1');    -- terminal count for update_cntr
signal sample_cntr :    min_type;                       -- finds sample points
signal sample_now :     std_logic;                      -- sample when asserted




begin

    --
    -- Input FFs
    --
    -- A shift register of three FFs is used to sample the incoming bitstream.
    -- The first and second FF remove metastability from the signal. The outputs
    -- of the second FF and the third FF are compared to determine when an edge
    -- occurs.
    --

    process(clk)
    begin
        if rising_edge(clk) then
            inffs <= inffs(1 downto 0) & serin;
        end if;
    end process;

    edge_detect <= inffs(2) xor inffs(1);

    --
    -- Min counter
    --
    -- The min counter is reset when an edge is detected and increments by 1
    -- the rest of the time, counting the number of clock cycles between edges.
    --
    process(clk)
    begin
        if rising_edge(clk) then
            if edge_detect = '1' then
                min_cntr <= (others => '0');
            else
                min_cntr <= min_cntr + 1;
            end if;
        end if;
    end process;

    --
    -- Minimum capture register
    --
    -- This register loads with a value of all ones when update_min is asserted.
    -- Otherwise, when edge is asserted, it loads with the value of the min
    -- counter if the min count is less than the current value in the register.
    --
    process(clk)
    begin
        if rising_edge(clk) then
            if edge_detect = '1' then
                if update_min = '1' then
                    min_capture <= (others => '1');
                elsif new_min = '1' then
                    min_capture <= min_cntr;
                end if;
            end if;
        end if;
    end process;

    new_min <= '1' when min_cntr < min_capture else '0';

    --
    -- Minimum hold register
    --
    -- When ever edge_detect and update_min are both asserted, this register 
    -- loads with the current contents of the min_capture register, holding the 
    -- minimum value found while min_capture begins searching for a new minimum 
    -- value.
    --
    process(clk)
    begin
        if rising_edge(clk) then
            if edge_detect = '1' and update_min = '1' then
                min_hold <= min_capture;
            end if;
        end if;
    end process;

    --
    -- Update period counter
    --
    -- The update period counter increments by one on every detected edge. When
    -- this counter reaches its maximum count, update_min is asserted and the
    -- counter rolls over to zero.
    --
   process(clk)
    begin
		if rising_edge(clk) then
			if rst = '1' then
				update_cntr <= "0000000000";
			else 
				if edge_detect = '1' then
               update_cntr <= update_cntr + 1;
            end if;
         end if;
		end if;
	end process;

    update_min <= '1' when update_cntr = update_tc else '0';

    --
    -- Sample counter
    --
    -- The sample counter determines when it is time to sample the bitstream 
    -- output of inffs[2]. This counter resets to zero when edge_detect is 
    -- asserted or when the sample count is equal to or greater than the 
    -- min_hold value. Thus, this counter counts from 0 to the min_hold value 
    -- which is then length of time of one symbol (half an encoded bit), then it
    -- resets and starts over. The bitstream is sampled each time the sample 
    -- counter reaches one half the min_hold value which is approximately the 
    -- middle of the symbol.
    --
    process(clk)
    begin
        if rising_edge(clk) then
            if edge_detect = '1' or (sample_cntr >= min_hold) then
                sample_cntr <= (others => '0');
            else
                sample_cntr <= sample_cntr + 1;
            end if;
        end if;
    end process;

    sample_now <= '1' when sample_cntr = ('0' & min_hold(MIN_VAL_WIDTH-1 downto 1))
                  else '0';

    --
    -- Output data
    --
    process(clk)
    begin
        if rising_edge(clk) then
            if sample_now = '1' then
                data_out <= inffs(2);
            end if;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            data_valid <= sample_now;
        end if;
    end process;

end Behavioral;

