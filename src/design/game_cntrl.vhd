----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/23/2023 02:47:06 PM
-- Design Name: 
-- Module Name: game_cntrl - Behavioral
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

entity game_cntrl is
    Generic (
        FRAME_WIDTH: natural;
        FRAME_HEIGHT: natural;
        PADDLE_WIDTH: natural := 10;
        PADDLE_HEIGHT: natural := 100;
        BALL_SIZE: natural := 16
    );
    Port ( CLK : in STD_LOGIC;
           RST : in STD_LOGIC;
           EN : in STD_LOGIC;
           BTN_START: in STD_LOGIC;
           
           PADDLE_1_UP: in STD_LOGIC;
           PADDLE_1_DOWN: in STD_LOGIC;
           PADDLE_1_POS_X : out natural range 0 to FRAME_WIDTH;
           PADDLE_1_POS_Y : out natural range 0 to FRAME_HEIGHT;
           
           PADDLE_2_UP: in STD_LOGIC;
           PADDLE_2_DOWN: in STD_LOGIC;
           PADDLE_2_POS_X : out natural range 0 to FRAME_WIDTH;
           PADDLE_2_POS_Y : out natural range 0 to FRAME_HEIGHT;
           
           BALL_POS_X: out natural range 0 to FRAME_WIDTH;
           BALL_POS_Y: out natural range 0 to FRAME_HEIGHT;
           SCORE_P1: out std_logic_vector(7 downto 0);
           SCORE_P2: out std_logic_vector(7 downto 0));
end game_cntrl;

architecture Behavioral of game_cntrl is
    -- GAME SETTINGS
    constant PADDLE_SPEED : natural := 10;
    
    -- GAME FSM
    type GAME_STATES is (INIT, START, RAND, PLAY, P1_SCORED, P2_SCORED, P_HIT);
    signal current_game_state, next_game_state : GAME_STATES := INIT;
    signal START_MOVING : std_logic := '0';

    -- PLAYER 1 
    constant P1_X_initial : natural range 0 to FRAME_WIDTH := 20;
    constant P1_Y_initial : natural range 0 to FRAME_WIDTH := FRAME_HEIGHT / 2;
    signal P1_X_current, P1_X_next : natural range 0 to FRAME_WIDTH;
    signal P1_Y_current, P1_Y_next : natural range 0 to FRAME_HEIGHT;
    signal P1_GOAL : std_logic;
    
    -- PLAYER 2
    constant P2_X_initial : natural range 0 to FRAME_WIDTH := FRAME_WIDTH - 20;
    constant P2_Y_initial : natural range 0 to FRAME_WIDTH := FRAME_HEIGHT / 2;
    signal P2_X_current, P2_X_next : natural range 0 to FRAME_WIDTH;
    signal P2_Y_current, P2_Y_next : natural range 0 to FRAME_HEIGHT;
    signal P2_GOAL : std_logic;
        
    -- BALL
    constant BALL_X_initial : natural range 0 to FRAME_WIDTH := 50;
    constant BALL_Y_initial : natural range 0 to FRAME_WIDTH := 50;
    signal BALL_SPEED_X : natural;
    signal BALL_SPEED_Y : natural;
    signal BALL_HIT: std_logic;
    signal BALL_X_current, BALL_X_next : natural range 0 to FRAME_WIDTH;
    signal BALL_Y_current, BALL_Y_next : natural range 0 to FRAME_HEIGHT;
    signal BALL_X_DIR_current, BALL_X_DIR_next, BALL_Y_DIR_current, BALL_Y_DIR_next : std_logic := '0'; -- 0 = up/left  1 = down/right
    
    signal RENDER : STD_LOGIC := '0';
begin
        
       
game_clc: process(current_game_state, BTN_START, P1_GOAL, P2_GOAL, BALL_HIT)
begin
    case current_game_state is
        when INIT => 
            next_game_state <= START;
        when START =>
            if BTN_START = '1' then
                next_game_state <= RAND;
            else
                next_game_state <= START;
            end if;
        when RAND =>
            next_game_state <= PLAY;
        when PLAY =>
            if P1_GOAL = '1' then
                next_game_state <= P1_SCORED;
            elsif P2_GOAL = '1' then
                next_game_state <= P2_SCORED;
            elsif BALL_HIT = '1' then
                next_game_state <= P_HIT;
            else
                next_game_state <= PLAY;
            end if;
        when P_HIT =>
            next_game_state <= PLAY;
        when P1_SCORED =>
            next_game_state <= START;
        when P2_SCORED =>
            next_game_state <= START;
        when others =>
            next_game_state <= INIT;
    end case;
end process;

ball_pos: process(RENDER, BALL_X_current, BALL_Y_current, BALL_X_DIR_current, BALL_Y_DIR_current, P1_X_current, P1_Y_current, P2_X_current, P2_Y_current, BALL_SPEED_X, BALL_SPEED_Y)
begin
    BALL_X_next <= BALL_X_current;
    BALL_Y_next <= BALL_Y_current;
    BALL_X_DIR_next <= BALL_X_DIR_current;
    BALL_Y_DIR_next <= BALL_Y_DIR_current;
    P1_GOAL <= '0';
    P2_GOAL <= '0';
    BALL_HIT <= '0';
    
    if RENDER = '1' then
        -- ball moving left
        if BALL_X_DIR_current = '0' then
            -- hit player 1
            if (BALL_X_current - (BALL_SIZE/2) - BALL_SPEED_X <= P1_X_current + (PADDLE_WIDTH / 2)) and 
                (P1_Y_current - (PADDLE_HEIGHT / 2) <= BALL_Y_current and BALL_Y_current <= P1_Y_current + (PADDLE_HEIGHT / 2)) then
                BALL_X_next <= P1_X_current + (PADDLE_WIDTH/2) + (BALL_SIZE/2);
                BALL_X_DIR_next <= '1'; -- bounce back
                BALL_HIT <= '1';
            -- hit left wall
            elsif BALL_X_current - BALL_SPEED_X < BALL_SIZE / 2 then
                BALL_X_next <= BALL_SIZE / 2;
                BALL_X_DIR_next <= '1'; -- bounce back
                P2_GOAL <= '1';
            else
                BALL_X_next <= BALL_X_current - BALL_SPEED_X;
            end if;
        -- ball moving right
        else
            -- hit player 2
            if (BALL_X_current + (BALL_SIZE/2) + BALL_SPEED_X >= P2_X_current - (PADDLE_WIDTH / 2)) and 
                (P2_Y_current - (PADDLE_HEIGHT / 2) <= BALL_Y_current and BALL_Y_current <= P2_Y_current + (PADDLE_HEIGHT / 2)) then
                BALL_X_next <= P2_X_current - (PADDLE_WIDTH / 2) - (BALL_SIZE / 2);
                BALL_X_DIR_next <= '0'; -- bounce back
                BALL_HIT <= '1';
            -- hit right wall
            elsif BALL_X_current + BALL_SPEED_X > FRAME_WIDTH - (BALL_SIZE / 2) then
                BALL_X_next <= FRAME_WIDTH - BALL_SIZE / 2;
                BALL_X_DIR_next <= '0'; -- bounce back
                P1_GOAL <= '1';
            else
                BALL_X_next <= BALL_X_current + BALL_SPEED_X;
            end if;
        end if;
        
        -- ball moving up
        if BALL_Y_DIR_current = '0' then
            -- hit top wall
            if BALL_Y_current - BALL_SPEED_Y < BALL_SIZE / 2 then
                BALL_Y_next <= BALL_SIZE / 2;
                BALL_Y_DIR_next <= '1'; -- bounce back
            else
                BALL_Y_next <= BALL_Y_current - BALL_SPEED_Y;
            end if;
        -- ball moving down
        else
            -- hit bottom wall
            if BALL_Y_current + BALL_SPEED_Y > FRAME_HEIGHT - (BALL_SIZE / 2) then
                BALL_Y_next <= FRAME_HEIGHT - (BALL_SIZE / 2);
                BALL_Y_DIR_next <= '0'; -- bounce back
            else
                BALL_Y_next <= BALL_Y_current + BALL_SPEED_Y;
            end if;
        end if;
    end if;
end process;

ball_speed: process(current_game_state)
    constant BALL_SPEED_X_initial : natural := 1;
    constant BALL_SPEED_Y_initial : natural := 1;
begin
    if RST = '0' then
        BALL_SPEED_X <= BALL_SPEED_X_initial;
        BALL_SPEED_Y <= BALL_SPEED_Y_initial;
    elsif rising_edge(CLK) then
        case current_game_state is
            when P_HIT =>
                BALL_SPEED_X <= BALL_SPEED_X + 1;
                BALL_SPEED_Y <= BALL_SPEED_Y + 1;
            when PLAY =>
                BALL_SPEED_X <= BALL_SPEED_X;
                BALL_SPEED_Y <= BALL_SPEED_Y;
            when others =>
                BALL_SPEED_X <= BALL_SPEED_X_initial;
                BALL_SPEED_Y <= BALL_SPEED_Y_initial;
        end case;
    end if;
end process;
 
player_1_pos: process (RENDER, P1_X_current, P1_Y_current, PADDLE_1_DOWN, PADDLE_1_UP)
begin
    P1_X_next <= P1_X_current;
    P1_Y_next <= P1_Y_current;
    -- render new player 1 position
    if RENDER = '1' then
        -- move up
        if PADDLE_1_UP = '1' and PADDLE_1_DOWN = '0' then
            if P1_Y_current - PADDLE_SPEED < PADDLE_HEIGHT/2 then
                P1_Y_next <= PADDLE_HEIGHT/2;
            else
                P1_Y_next <= P1_Y_current - PADDLE_SPEED;
            end if;
        -- move down
        elsif PADDLE_1_UP = '0' and PADDLE_1_DOWN = '1' then
            if P1_Y_current + PADDLE_SPEED > FRAME_HEIGHT - PADDLE_HEIGHT/2 then
                P1_Y_next <= FRAME_HEIGHT - PADDLE_HEIGHT/2;
            else
                P1_Y_next <= P1_Y_current + PADDLE_SPEED;
            end if;
        end if;
    end if;
end process;
    
player_2_pos: process (RENDER, P2_X_current, P2_Y_current, PADDLE_2_DOWN, PADDLE_2_UP)
begin
    P2_X_next <= P2_X_current;
    P2_Y_next <= P2_Y_current;
    -- render new player 2 position
    if RENDER = '1' then
        -- move up
        if PADDLE_2_UP = '1' and PADDLE_2_DOWN = '0' then
            if P2_Y_current - PADDLE_SPEED < PADDLE_HEIGHT/2 then
                P2_Y_next <= PADDLE_HEIGHT/2;
            else
                P2_Y_next <= P2_Y_current - PADDLE_SPEED;
            end if;
        -- move down
        elsif PADDLE_2_UP = '0' and PADDLE_2_DOWN = '1' then
            if P2_Y_current + PADDLE_SPEED > FRAME_HEIGHT - PADDLE_HEIGHT/2 then
                P2_Y_next <= FRAME_HEIGHT - PADDLE_HEIGHT/2;
            else
                P2_Y_next <= P2_Y_current + PADDLE_SPEED;
            end if;
        end if;
    end if;
end process;
    
flip_flop: process (RST, CLK)
begin
    if (RST = '0') then
        current_game_state <= INIT;
        
        P1_X_current <= P1_X_initial;
        P1_Y_current <= P1_Y_initial;
        P2_X_current <= P2_X_initial;
        P2_Y_current <= P2_Y_initial;
        BALL_X_current <= BALL_X_initial;
        BALL_Y_current <= BALL_Y_initial;
        BALL_X_DIR_current <= '0';
        BALL_Y_DIR_current <= '0';
    elsif rising_edge(CLK) then
        current_game_state <= next_game_state;
        P1_X_current <= P1_X_next;
        P1_Y_current <= P1_Y_next;
        P2_X_current <= P2_X_next;
        P2_Y_current <= P2_Y_next;
        BALL_X_current <= BALL_X_next;
        BALL_Y_current <= BALL_Y_next;
        BALL_X_DIR_current <= BALL_X_DIR_next;
        BALL_Y_DIR_current <= BALL_Y_DIR_next;
    end if;
end process;

score_count: process (RST, CLK, current_game_state)    
    variable p1_ten, p2_ten : integer range 0 to 9 := 0;
    variable p1_unit, p2_unit : integer range 0 to 9 := 0;
begin
    if RST = '0' then
        p1_ten := 0;
        p1_unit := 0;
        p2_ten := 0;
        p2_unit := 0;
    elsif rising_edge(CLK) then
        if current_game_state = P1_SCORED then
            if p1_unit = 9 then
                p1_unit := 0;
                if p1_ten = 9 then
                    p1_ten := 0;
                else
                    p1_ten := p1_ten + 1;
                end if;
            else
                p1_unit := p1_unit + 1;
            end if;
        end if;
        
        if current_game_state = P2_SCORED then
            if p2_unit = 9 then
                p2_unit := 0;
                if p2_ten = 9 then
                    p2_ten := 0;
                else
                    p2_ten := p2_ten + 1;
                end if;
            else
                p2_unit := p2_unit + 1;
            end if;
        end if;
    end if;
    
    SCORE_P1 <= std_logic_vector(to_unsigned(p1_ten,4)) & std_logic_vector(to_unsigned(p1_unit,4));
    SCORE_P2 <= std_logic_vector(to_unsigned(p2_ten,4)) & std_logic_vector(to_unsigned(p2_unit,4));
end process;
        
PADDLE_1_POS_X <= P1_X_current;
PADDLE_1_POS_Y <= P1_Y_current;

PADDLE_2_POS_X <= P2_X_current;
PADDLE_2_POS_Y <= P2_Y_current;

BALL_POS_X <= BALL_X_current;
BALL_POS_Y <= BALL_Y_current;

RENDER <= '1' when EN = '1' and current_game_state = PLAY else '0';

end Behavioral;
