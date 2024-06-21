----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/20/2023 07:39:31 PM
-- Design Name: 
-- Module Name: pong_game - Behavioral
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

entity pong_game is
    Port ( RST : in STD_LOGIC;
           CLK : in STD_LOGIC;
           BTN_U : in STD_LOGIC;
           BTN_D: in STD_LOGIC;
           BTN_L : in STD_LOGIC;
           BTN_R: in STD_LOGIC;
           BTN_C: in STD_LOGIC;
           VGA_H_SYNC_O : out STD_LOGIC;
           VGA_V_SYNC_O : out STD_LOGIC;
           VGA_RED_O : out STD_LOGIC_VECTOR (3 downto 0);
           VGA_GREEN_O : out STD_LOGIC_VECTOR (3 downto 0);
           VGA_BLUE_O : out STD_LOGIC_VECTOR (3 downto 0);
           seg: out STD_LOGIC_VECTOR(0 to 6);
           an: out std_logic_vector(7 downto 0);
           dp: out STD_LOGIC);
end pong_game;

architecture Behavioral of pong_game is
    -- VGA 1280x1024@60Hz sync parameters
    constant FRAME_WIDTH : natural := 1280;
    constant FRAME_HEIGHT : natural := 1024;
    constant H_FP : natural := 48; --H front porch width (pixels)
    constant H_PW : natural := 112; --H sync pulse width (pixels)
    constant H_MAX : natural := 1688; --H total period (pixels)
    constant V_FP : natural := 1; --V front porch width (lines)
    constant V_PW : natural := 3; --V sync pulse width (lines)
    constant V_MAX : natural := 1066; --V total period (lines)
    constant H_POL : std_logic := '1';
    constant V_POL : std_logic := '1';
    
    signal rgb : std_logic_vector(11 downto 0);
    signal video_on : std_logic;
    signal pixel_x, pos_x_paddle_1, pos_x_paddle_2, pos_x_ball  : natural range 0 to FRAME_WIDTH;
    signal pixel_y, pos_y_paddle_1, pos_y_paddle_2, pos_y_ball : natural range 0 to FRAME_HEIGHT;
    
    constant BALL_SIZE : natural := 16;
    constant PADDLE_WIDTH : natural := 10;
    constant PADDLE_HEIGHT : natural := 100;
    
    signal ball_delta_x, ball_delta_y: integer range -32 to 32 := 0;
    
    signal START_GAME, P1_UP, P1_DOWN, P2_UP, P2_DOWN : std_logic;
    signal enable_render: std_logic;
    
    signal pxl_clk : STD_LOGIC;
    
    signal SCORE_P1, SCORE_P2 : std_logic_vector(7 downto 0);
    
    component clk_wiz_0 is
      PORT ( 
        CLK_IN1 : in STD_LOGIC;
        resetn : in STD_LOGIC;
        CLK_OUT1 : out STD_LOGIC
      );
    end component clk_wiz_0;
begin
    Inst_PixelClockGen: clk_wiz_0
       port map
        (CLK_IN1    => CLK,
         CLK_OUT1   => pxl_clk,
         resetn     => RST
        );

    debouncer_start : entity work.debouncer
        generic map (
            CLK_FREQUENCY => 108_000_000,
            BTN_STABLE_TIME => 10
        )
        port map (
            CLK=>pxl_clk,
            RST=>RST,
            BTN_IN=>BTN_C,
            BTN_OUT=>START_GAME
        );
        
    debouncer_p1_up : entity work.debouncer
        generic map (
            CLK_FREQUENCY => 108_000_000,
            BTN_STABLE_TIME => 10
        )
        port map (
            CLK=>pxl_clk,
            RST=>RST,
            BTN_IN=>BTN_L,
            BTN_OUT=>P1_UP
        );
    
    debouncer_p1_down : entity work.debouncer
        generic map (
            CLK_FREQUENCY => 108_000_000,
            BTN_STABLE_TIME => 10
        )
        port map (
            CLK=>pxl_clk,
            RST=>RST,
            BTN_IN=>BTN_D,
            BTN_OUT=>P1_DOWN
        );
        
    debouncer_p2_up : entity work.debouncer
        generic map (
            CLK_FREQUENCY => 108_000_000,
            BTN_STABLE_TIME => 10
        )
        port map (
            CLK=>pxl_clk,
            RST=>RST,
            BTN_IN=>BTN_U,
            BTN_OUT=>P2_UP
        );
    
    debouncer_p2_down : entity work.debouncer
        generic map (
            CLK_FREQUENCY => 108_000_000,
            BTN_STABLE_TIME => 10
        )
        port map (
            CLK=>pxl_clk,
            RST=>RST,
            BTN_IN=>BTN_R,
            BTN_OUT=>P2_DOWN
        );
        
    game_controller: entity work.game_cntrl
        generic map (
            FRAME_WIDTH=> FRAME_WIDTH,
            FRAME_HEIGHT=>FRAME_HEIGHT,
            PADDLE_WIDTH=>PADDLE_WIDTH,
            PADDLE_HEIGHT=>PADDLE_HEIGHT,
            BALL_SIZE=>BALL_SIZE
        )
        port map (
            CLK => pxl_clk,
            RST => RST,
            EN=>enable_render,
            BTN_START=>START_GAME,
            PADDLE_1_UP=>P1_UP,
            PADDLE_1_DOWN=>P1_DOWN,
            PADDLE_2_UP=>P2_UP,
            PADDLE_2_DOWN=>P2_DOWN,
            PADDLE_1_POS_X=>pos_x_paddle_1,
            PADDLE_1_POS_Y=>pos_y_paddle_1,
            PADDLE_2_POS_X=>pos_x_paddle_2,
            PADDLE_2_POS_Y=>pos_y_paddle_2,
            BALL_POS_X=>pos_x_ball,
            BALL_POS_Y=>pos_y_ball,
            SCORE_P1=>SCORE_P1,
            SCORE_P2=>SCORE_P2
        );
    
    vga_sync_unit: entity work.vga_sync
        generic map(
            FRAME_WIDTH=> FRAME_WIDTH,
            FRAME_HEIGHT=>FRAME_HEIGHT,
            H_FP=>H_FP,
            H_PW=>H_PW,
            H_MAX=>H_MAX,
            V_FP=>V_FP,
            V_PW=>V_PW,
            V_MAX=>V_MAX,
            H_POL=>H_POL,
            V_POL=>V_POL
        )
        port map(
            RST=>RST,
            CLK=>pxl_clk,
            H_SYNC=>VGA_H_SYNC_O,
            V_SYNC=>VGA_V_SYNC_O,
            PIXEL_X=>pixel_x,
            PIXEL_Y=>pixel_y,
            VIDEO_EN=>video_on,
            RENDER_OK=>enable_render
       );  
              
    vga_color_gen: entity work.vga_color
        generic map(
            FRAME_WIDTH=>FRAME_WIDTH,
            FRAME_HEIGHT=>FRAME_HEIGHT
        )
        port map(
            CLK=>pxl_clk,
            RST=>RST,
            PADDLE_1_X => pos_x_paddle_1,
            PADDLE_1_Y => pos_y_paddle_1,
            PADDLE_2_X => pos_x_paddle_2,
            PADDLE_2_Y => pos_y_paddle_2,
            BALL_X => pos_x_ball,
            BALL_Y => pos_y_ball,
            VIDEO_ON=>video_on,
            PIXEL_X=>pixel_x,
            PIXEL_Y=>pixel_y,
            RGB_O=>rgb
        );
        
     seg_disp: entity work.driver7seg
        port map (
            CLK=>CLK,
            RST=>RST,
            din(31 downto 24)=> "11110001", -- P1
            din(23 downto 16)=> SCORE_P1,
            din(15 downto 8) => "11110010", -- P2
            din(7 downto 0) => SCORE_P2,
            dp_in=>(others=>'X'),
            an=>an,
            seg=>seg,
            dp_out=>dp
        );
        
    VGA_RED_O <=
        rgb(11 downto 8) when video_on = '1' else
        "0000";
        
    VGA_GREEN_O <=
        rgb(7 downto 4) when video_on = '1' else
        "0000";
        
    VGA_BLUE_O <=
        rgb(3 downto 0) when video_on = '1' else
        "0000";
        
end Behavioral;
