----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/20/2023 07:46:08 PM
-- Design Name: 
-- Module Name: vga_sync - Behavioral
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

entity vga_sync is
    GENERIC(
        -- VGA 1280x1024@60Hz sync parameters
        FRAME_WIDTH : natural := 1280;
        FRAME_HEIGHT : natural := 1024;
        H_FP : natural := 48;
        H_PW : natural := 112;
        H_MAX : NATURAL := 1688;
        V_FP : natural := 1;
        V_PW : natural := 3;
        V_MAX : NATURAL := 1066;
        H_POL : std_logic := '1';
        V_POL : std_logic := '1'
    );
    PORT ( RST : in STD_LOGIC;
           CLK : in STD_LOGIC;
           H_SYNC : out STD_LOGIC;
           V_SYNC : out STD_LOGIC;
           PIXEL_X : out natural range 0 to FRAME_WIDTH;
           PIXEL_Y : out natural range 0 to FRAME_HEIGHT;
           VIDEO_EN : out STD_LOGIC;
           RENDER_OK: out STD_LOGIC
    );
end vga_sync;

architecture Behavioral of vga_sync is
        
    -- Horizontal and Vertical counters
    signal h_cntr_reg : natural range 0 to H_MAX := 0;
    signal v_cntr_reg : natural range 0 to V_MAX := 0;
    
    -- Horizontal and Vertical Sync
    signal h_sync_reg : std_logic := not(H_POL);
    signal v_sync_reg : std_logic := not(V_POL);
begin

    
    horizontal_counter: process(RST, CLK)
        begin
            if (RST = '0') then
                h_cntr_reg <= 0;
            elsif (rising_edge(CLK)) then
                if (h_cntr_reg = (H_MAX - 1)) then
                    h_cntr_reg <= 0;
                else
                    h_cntr_reg <= h_cntr_reg + 1;
                end if;
            end if;
        end process;
    
    horizontal_sync: process(RST, CLK)
        begin
            if (RST = '0') then
                h_sync_reg <= not(H_POL);
            elsif (rising_edge(CLK)) then
                if (h_cntr_reg >= (H_FP + FRAME_WIDTH - 1)) and (h_cntr_reg < (H_FP + FRAME_WIDTH + H_PW - 1)) then
                    h_sync_reg <= H_POL;
                else
                    h_sync_reg <= not(H_POL);
                end if;
            end if;
        end process;

    vertical_counter: process(RST, CLK)
        begin
            if (RST = '0') then
                v_cntr_reg <= 0;
            elsif (rising_edge(CLK)) then
                if (v_cntr_reg = (V_MAX - 1) and h_cntr_reg = (H_MAX - 1)) then
                    v_cntr_reg <= 0;
                elsif (h_cntr_reg = (H_MAX - 1)) then
                    v_cntr_reg <= v_cntr_reg + 1;
                end if;
            end if;
        end process;
    
    vertical_sync: process(RST, CLK)
        begin
            if (RST = '0') then
                v_sync_reg <= not(V_POL);
            elsif (rising_edge(CLK)) then
                if (v_cntr_reg >= (V_FP + FRAME_HEIGHT - 1)) and (v_cntr_reg < (V_FP + FRAME_HEIGHT + V_PW - 1)) then
                    v_sync_reg <= V_POL;
                else
                    v_sync_reg <= not(V_POL);
                end if;
            end if;
        end process;

    VIDEO_EN <= 
        '1' when (h_cntr_reg < FRAME_WIDTH and v_cntr_reg < FRAME_HEIGHT) else
        '0';
        
    H_SYNC <= h_sync_reg;
    V_SYNC <= v_sync_reg;
  
    PIXEL_X <= h_cntr_reg;
    PIXEL_Y <= v_cntr_reg;
    
    RENDER_OK <= '1' when v_cntr_reg = (V_MAX - 1) and h_cntr_reg = (H_MAX - 1) else '0';
end Behavioral;
