-------------------------------------------------------------------------------
-- AES3 / SPDIF Minimalistic Receiver
-- Version 0.9
-- Petr Nohavica (c) 2009
-- Released under GNU Lesser General Public License
-- Original target device: Xilinx Spartan-3AN family
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity aes_dru_2 is
    port (
       clk:            in  std_logic;     
       rst:            in  std_logic;     
       serin:          in  std_logic;     
       data_out:       out std_logic;     
       data_valid:     out std_logic;
	   lock: 	  	   out std_logic
	   ); 
end aes_dru_2;

architecture Behavioral of aes_dru_2 is

	constant X_PREAMBLE     : std_logic_vector(7 downto 0) := "01000111"; 
	constant Y_PREAMBLE     : std_logic_vector(7 downto 0) := "00100111"; 
	constant Z_PREAMBLE     : std_logic_vector(7 downto 0) := "00010111";
   
	type lock_state_t is (not_locked, locking, locked);
	signal lock_state       : lock_state_t := not_locked;
	signal lock_state_next  : lock_state_t;
 

	signal serin_r1          : std_logic_vector(3 downto 0) := (others => '0');
	signal serin_r2    : std_logic_vector(7 downto 0) := (others => '0');
	
	signal edge_det         : std_logic := '0'; 
	signal est_clk          : std_logic := '0';
	signal est_clk_alive : std_logic := '0';
	signal clk_counter      : std_logic_vector(4 downto 0) := (others => '0');
	signal clk_est_period   : std_logic_vector(4 downto 0) := (others => '1'); 

	signal sync_cnt         : std_logic_vector(5 downto 0) := (others => '0'); 
	signal sync_lost        : std_logic := '1';
	

	
   -- Asserted when locking state machine is not in locked state
   
   -- Asserted when preamble has been detected
   signal preamble_detected: std_logic := '0';



   -- Signal indicating some error in received AES3, used primarily by locking state machine
   signal lock_error       : std_logic;
   -- Asserted when sync_cnt is full (i.e. it has value of 63)
   signal sync_cnt_full    : std_logic;
   -- Asserted when there was at least one aes3_clk pulse since last input transition
  
   -- Signals indicating detection of X, Y and Z preambles
   signal x_detected       : std_logic := '0';
   signal y_detected       : std_logic := '0';
   signal z_detected       : std_logic := '0';
begin


	edge_detect_process: process (clk,rst)
	begin
		if rst = '1' then
			serin_r1 <= (others => '0');
			edge_det <= '0';
		elsif rising_edge(clk) then
			serin_r1 <= serin & serin_r1(3 downto 1);
			edge_det <= serin_r1(2) xor serin_r1(1);
		end if;
	end process;	



	

	-- lock_state_process: process (lock_state, preamble_detected, sync_cnt_full, lock_error)
	-- begin
		-- case lock_state is 
			-- when not_locked =>
				-- if preamble_detected = '1' then
					-- lock_state_next <= locking;
				-- else
					-- lock_state_next <= not_locked;
				-- end if;
			-- when locking =>
				-- if lock_error = '1' then
					-- lock_state_next <= not_locked;
				-- elsif sync_cnt_full = '1' and preamble_detected = '1' then
					-- lock_state_next <= locked;
				-- else
					-- lock_state_next <= locking;
				-- end if;
			-- when locked =>
				-- if lock_error = '1' then
					-- lock_state_next <= not_locked;
				-- else
					-- lock_state_next <= locked;
				-- end if;
		-- end case;
	-- end process;
	
	lock_state_next <= 	not_locked when ((lock_state=not_locked)AND (preamble_detected = '0')) OR ((lock_state/=not_locked)AND(lock_error = '1')) else
						locked when ((lock_state=locking)AND ( sync_cnt_full = '1') AND (preamble_detected = '1')) OR ((lock_state=locked)AND(lock_error = '0')) else
						locking;
    

	sync_lost <= '0' when (lock_state=locked) else '1';

	sync_process: process (clk,rst)
	begin
		if rst = '1' then
			lock_state <= not_locked;
		elsif rising_edge(clk) then
			if est_clk = '1' or (edge_det = '1' and est_clk_alive = '0') then
				lock_state <= lock_state_next;
			end if;
		end if;
	end process;
	
	sync_cnt_full <= '1' when sync_cnt = 63 else '0';
	x_detected <= '1' when (serin_r2 = X_PREAMBLE or serin_r2 = not X_PREAMBLE) else '0';
	y_detected <= '1' when (serin_r2 = Y_PREAMBLE or serin_r2 = not Y_PREAMBLE) else '0';
	z_detected <= '1' when (serin_r2 = Z_PREAMBLE or serin_r2 = not Z_PREAMBLE) else '0'; 
	preamble_detected <= x_detected or y_detected or z_detected;
	lock_error 	<= 	(sync_cnt_full and not preamble_detected) or
					(not sync_cnt_full and preamble_detected) or
					(edge_det and not est_clk_alive);
	
	clk_process: process (clk,rst)
	begin
		if rst = '1' then
			est_clk_alive <= '0';
			est_clk <= '0';
			clk_counter <= (others => '0');
			serin_r2 <= (others => '0');
			clk_est_period <= (others => '1');
			sync_cnt <= (others => '0');
		elsif rising_edge(clk) then
			if edge_det = '1' then
				est_clk_alive <= '0';
			elsif clk_counter = 0 then
				est_clk_alive <= '1';
			end if;
			
			if clk_counter = 0 then
				est_clk <= '1';
			else
				est_clk <= '0';
			end if;
			
			if edge_det = '1' or clk_counter = 0 then
				if edge_det = '1' then
					clk_counter <= '0' & clk_est_period(4 downto 1);
				else
					clk_counter <= clk_est_period;
				end if;
			else
				clk_counter <= clk_counter - 1;
			end if;
			
			if est_clk = '1' then
				serin_r2 <= serin_r1(0) & serin_r2(7  downto 1);
			end if;
			
			if (lock_state = locked and lock_state_next = not_locked) then
				clk_est_period <= (others => '1');
			elsif (est_clk = '1' and sync_cnt_full = '1' and lock_state_next = not_locked) or (edge_det = '1' and est_clk_alive = '0') then
				clk_est_period <= clk_est_period - 1;
			end if;
			
			if est_clk = '1' then 
				if preamble_detected = '1' then
				   sync_cnt <= (others => '0');
				else 
				   sync_cnt <= sync_cnt + 1;
				end if;
			end if;
		end if;
	end process;  

	data_out_process: process (clk,rst)
	begin
		if(rst='1')then
		   data_valid <= '0';
		   data_out <= '0';
		elsif rising_edge(clk) then
			lock <= not sync_lost;
			data_valid <= est_clk;

			if est_clk = '1' then
				data_out <= serin_r1(0);
			end if;
		end if;
	end process; 

    
end Behavioral;

