----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.01.2017 17:15:40
-- Design Name: 
-- Module Name: tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_arith.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb is
--  Port ( );
end tb;

architecture Behavioral of tb is
	component audio_ps is
	Port ( 
		clk 	 	: in  STD_LOGIC;
		rst_n 	 	: in  STD_LOGIC;
		enable 	 	: in  STD_LOGIC;
		lrclk 	 	: in  STD_LOGIC;
		intr	 	: out STD_LOGIC;
		clear_intr  : in STD_LOGIC;
		position 	: out STD_LOGIC;
		size        : in STD_LOGIC_VECTOR(15 downto 0);
		in0  	 	: in  STD_LOGIC_VECTOR (23 downto 0);
		in1  	 	: in  STD_LOGIC_VECTOR (23 downto 0);
		in2  	 	: in  STD_LOGIC_VECTOR (23 downto 0);
		in3  	 	: in  STD_LOGIC_VECTOR (23 downto 0);
		out0  	 	: out STD_LOGIC_VECTOR (23 downto 0);
		out1  	 	: out STD_LOGIC_VECTOR (23 downto 0);
		out2  	 	: out STD_LOGIC_VECTOR (23 downto 0);
		out3  	 	: out STD_LOGIC_VECTOR (23 downto 0);
		-- bram
		bram_addr 	: out STD_LOGIC_VECTOR (31 downto 0);
		bram_clk	: out STD_LOGIC;
		bram_dout	: out STD_LOGIC_VECTOR (31 downto 0);
		bram_din	: in  STD_LOGIC_VECTOR (31 downto 0);
		bram_en		: out STD_LOGIC;
		bram_rst	: out STD_LOGIC;
		bram_we		: out STD_LOGIC_VECTOR (3 downto 0)
		);
	end component;
    component blk_mem_gen_0 IS
          PORT (
            clka : IN STD_LOGIC;
            rsta : IN STD_LOGIC;
            ena : IN STD_LOGIC;
            wea : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            addra : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
          );
        END component;


    signal clk 	 		: STD_LOGIC;
    signal rst_n 		: STD_LOGIC;
	signal enable 		: STD_LOGIC;
    signal lrclk 		: STD_LOGIC;
	signal intr	 		: STD_LOGIC;
	signal position 	: STD_LOGIC;
	signal in0  		: STD_LOGIC_VECTOR (23 downto 0);
	signal in1  		: STD_LOGIC_VECTOR (23 downto 0);
	signal in2  		: STD_LOGIC_VECTOR (23 downto 0);
	signal in3  		: STD_LOGIC_VECTOR (23 downto 0);
	signal out0  		: STD_LOGIC_VECTOR (23 downto 0);
	signal out1  		: STD_LOGIC_VECTOR (23 downto 0);
	signal out2  		: STD_LOGIC_VECTOR (23 downto 0);
	signal out3  		: STD_LOGIC_VECTOR (23 downto 0);

	signal bram_addr 	: STD_LOGIC_VECTOR (31 downto 0);
	signal bram_clk		: STD_LOGIC;
	signal bram_dout	: STD_LOGIC_VECTOR (31 downto 0);
	signal bram_din		: STD_LOGIC_VECTOR (31 downto 0);
	signal bram_en		: STD_LOGIC;
	signal bram_rst		: STD_LOGIC;
	signal bram_we		: STD_LOGIC_VECTOR (3 downto 0);
	
	constant clk_period : time := 10 ns;
	constant lrclk_period : time := 20833 ns;
begin

	uut: audio_ps 
	port map
	( 
		clk 	 	=> clk,
		rst_n 	 	=> rst_n,
		enable 	 	=> enable,
		lrclk 	 	=> lrclk,
		intr	 	=> intr,
		clear_intr  => intr,
		position 	=> position,
		size        => x"1000",
		in0  	 	=> in0,
		in1  	 	=> in1,
		in2  	 	=> in2,
		in3  	 	=> in3,
		out0  	 	=> out0,
		out1  	 	=> out1,
		out2  	 	=> out2,
		out3  	 	=> out3,

		bram_addr 	=> bram_addr,
		bram_clk	=> bram_clk,
		bram_dout	=> bram_dout,
		bram_din	=> bram_din,
		bram_en		=> bram_en,
		bram_rst	=> bram_rst,
		bram_we		=> bram_we
	);
	
    bram: blk_mem_gen_0
    PORT MAP(
        clka  => bram_clk,
        rsta  => bram_rst,
        ena   => bram_en,
        wea   => bram_we,
        addra => bram_addr,
        dina  => bram_dout,
        douta => bram_din
    );

        
	process
	begin
		clk_loop : loop
			clk <= '0';
			wait for clk_period/2;
			clk <= '1';
			wait for clk_period/2;
		end loop clk_loop;
	end process;

	process
	begin
		lrclk_loop : loop
			lrclk <= '0';
			wait for lrclk_period/2;
			lrclk <= '1';
			wait for lrclk_period/2;
		end loop lrclk_loop;
	end process;
	
	tb : process
	begin
		rst_n <= '0';
		in0 <= x"000011";
		in1 <= x"000022";
		in2 <= x"000033";
		in3 <= x"000044";
		enable <= '0';
		wait for 100 ns;
		
		rst_n <= '1';
		wait for 100 ns;
		enable <= '1';
		data_loop : loop
		wait for lrclk_period;
		in0 <= in0+x"000100";
		in1 <= in1+x"000100";
		in2 <= in2+x"000100";
		in3 <= in3+x"000100";
		end loop data_loop;
		wait;
	end process;
end Behavioral;
