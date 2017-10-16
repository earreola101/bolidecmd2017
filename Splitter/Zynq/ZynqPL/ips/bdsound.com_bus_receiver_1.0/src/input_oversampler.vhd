library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
Library UNISIM;
use UNISIM.vcomponents.all;

library UNISIM;
use UNISIM.VComponents.all;

entity input_oversampler is
    Port ( 
		clk_0       			: in  STD_LOGIC;
		clk_90       		: in  STD_LOGIC;
		clk_180      		: in  STD_LOGIC;
		clk_270      		: in  STD_LOGIC;
		data_in				: in  STD_LOGIC;
		data_in_oversampled  : out  STD_LOGIC_VECTOR (3 downto 0)
	);
end input_oversampler;

architecture Behavioral of input_oversampler is
	signal read_reg :  std_logic_vector (3 downto 0);
  
    signal a0 : std_logic;
    signal a1 : std_logic;
    signal a2 : std_logic;
    signal a3 : std_logic;
    signal b0 : std_logic;
    signal b1 : std_logic;
    signal b2 : std_logic;
    signal b3 : std_logic;
begin

    process(clk_0)
    begin
        if rising_edge(clk_0) then
            data_in_oversampled <= read_reg(3 downto 0);
        end if;
    end process;
            
    process(clk_0)
    begin
        if rising_edge(clk_0) then
            a0 <= data_in;
            b0 <= a0;
            b1 <= a1;
            read_reg(3) <= b0;
            read_reg(2) <= b1;
            read_reg(1) <= b2;
            read_reg(0) <= b3;
        end if;
    end process;
    
    process(clk_90)
    begin
        if rising_edge(clk_90) then
            a1 <= data_in;
            b2 <= a2;
            b3 <= a3;
        end if;   
    end process;

    process(clk_180)
    begin
        if rising_edge(clk_180) then
            a2 <= data_in;
        end if;     
    end process;
    
    process(clk_270)
    begin
        if rising_edge(clk_270) then
            a3 <= data_in;
        end if;     
    end process;

end Behavioral;

