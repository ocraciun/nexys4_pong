----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/22/2023 05:49:35 PM
-- Design Name: 
-- Module Name: ball - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ball is
    Generic (
        FRAME_WIDTH : natural := 1280;
        FRAME_HEIGHT : natural := 1024;
        BALL_SIZE : natural := 16
    );
    Port ( CLK: in STD_LOGIC;
           BALL_X : in natural range 0 to FRAME_WIDTH;
           BALL_Y : in natural range 0 to FRAME_HEIGHT;
           PIXEL_X : in natural range 0 to FRAME_WIDTH;
           PIXEL_Y : in natural range 0 to FRAME_HEIGHT;
           BALL_RGB_O : out STD_LOGIC_VECTOR (11 downto 0);
           BALL_EN : out STD_LOGIC);
end ball;

architecture Behavioral of ball is 
    signal ball_on_current, ball_on_next: std_logic := '0'; 
    constant BALL_SQ : natural := BALL_SIZE * BALL_SIZE / 4;
begin 
    process (PIXEL_X, BALL_X, PIXEL_Y, BALL_Y)
        variable dx, dy: integer  := 0;
    begin
        dx := PIXEL_X - BALL_X;
        dy := PIXEL_Y - BALL_Y;
       if (dx*dx + dy*dy < BALL_SQ) then
            ball_on_next <= '1';
       else
            ball_on_next <= '0';
       end if;
    end process;
    
    process (CLK)
    begin
        if rising_edge(CLK) then
            ball_on_current <= ball_on_next;
        end if;
    end process;
    
    BALL_EN <= ball_on_current;
    BALL_RGB_O <= x"0F0";
end Behavioral;
