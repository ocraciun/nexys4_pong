----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/22/2023 11:28:07 PM
-- Design Name: 
-- Module Name: debouncer - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity debouncer is
    Generic (
        CLK_FREQUENCY: natural := 100_000_000;
        BTN_STABLE_TIME: natural := 3 -- BTN_IN pressed time in ms
    );
    Port ( CLK : in STD_LOGIC;
           RST : in STD_LOGIC;
           BTN_IN : in STD_LOGIC;
           BTN_OUT : out STD_LOGIC);
end debouncer;

architecture Behavioral of debouncer is
    signal FLIP_FLOPS : std_logic_vector(1 downto 0);
    signal CLR : std_logic;
    
    constant MAX_COUNT : natural := CLK_FREQUENCY * BTN_STABLE_TIME / 1000;
begin
    CLR <= FLIP_FLOPS(0) xor FLIP_FLOPS(1);
    
counter: process (CLK, RST)
    variable count : natural range 0 to MAX_COUNT;
    begin
        if (RST = '0') then
            FLIP_FLOPS <= "00";
            BTN_OUT <= '0';
        elsif (rising_edge(CLK)) then
            FLIP_FLOPS(1) <= FLIP_FLOPS(0);
            FLIP_FLOPS(0) <= BTN_IN;
            if (CLR = '1') then
                count := 0;
            elsif(count < MAX_COUNT) then
                count := count + 1;
            else
                BTN_OUT <= FLIP_FLOPS(1);
            end if;
        end if;
    end process;
end Behavioral;
