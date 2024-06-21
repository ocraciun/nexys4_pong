----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/21/2023 06:11:57 PM
-- Design Name: 
-- Module Name: paddle_1 - Behavioral
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

entity paddle is
    Generic (
        -- VGA 1280x1024@60Hz
        FRAME_WIDTH : natural := 1280;
        FRAME_HEIGHT : natural := 1024;
        PADDLE_WIDTH : natural := 10;
        PADDLE_HEIGHT : natural := 100
    );
    Port ( 
           PADDLE_X : in natural range 0 to FRAME_WIDTH;
           PADDLE_Y : in natural range 0 to FRAME_HEIGHT;
           PIXEL_X : in natural range 0 to FRAME_WIDTH;
           PIXEL_Y : in natural range 0 to FRAME_HEIGHT;
           PADDLE_RGB_O : out STD_LOGIC_VECTOR (11 downto 0);
           PADDLE_EN : out STD_LOGIC);
end paddle;

architecture Behavioral of paddle is    
    constant HALF_PADDLE_WIDTH : natural := PADDLE_WIDTH / 2;
    constant HALF_PADDLE_HEIGHT : natural := PADDLE_HEIGHT / 2;
    
    signal PADDLE_X_LEFT : natural := PADDLE_X - HALF_PADDLE_WIDTH;
    signal PADDLE_X_RIGHT : natural := PADDLE_X + HALF_PADDLE_WIDTH;

    signal PADDLE_Y_TOP  : natural := PADDLE_Y - HALF_PADDLE_HEIGHT;
    signal PADDLE_Y_BOTTOM : natural := PADDLE_Y + HALF_PADDLE_HEIGHT;
begin
    PADDLE_X_LEFT <= PADDLE_X - HALF_PADDLE_WIDTH;
    PADDLE_X_RIGHT <= PADDLE_X + HALF_PADDLE_WIDTH;
    
    PADDLE_Y_TOP <= PADDLE_Y - HALF_PADDLE_HEIGHT;
    PADDLE_Y_BOTTOM <= PADDLE_Y + HALF_PADDLE_HEIGHT;
 
    PADDLE_EN <=
        '1' when (PADDLE_X_LEFT <= PIXEL_X) and (PIXEL_X <= PADDLE_X_RIGHT) and
            (PADDLE_Y_TOP <= PIXEL_Y) and (PIXEL_Y <= PADDLE_Y_BOTTOM) else
        '0';
    PADDLE_RGB_O <= x"F00"; -- red
end Behavioral;
