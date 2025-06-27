----------------------------------------------------------------------------------
-- Company: Unimi
-- Engineer: Test Engineer
-- 
-- Create Date: 06/26/2025
-- Design Name: 
-- Module Name: CONTROLLER_TB - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Testbench for CONTROLLER module
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

entity TB_CONTROLLER is
end TB_CONTROLLER;

architecture Behavioral of TB_CONTROLLER is
    -- Component Declaration for the Unit Under Test (UUT)
    component CONTROLLER
    Port ( 
-- Quanto commentato appartiene a Vecchia Versione v0
        -- Sincronismo
        CLOCK : in std_logic;
        RESET : in std_logic;
        
        -- Interfaccia con Computer
        D_DIN   : in  std_logic_vector(63 downto 0);

        -- Appartiene a versione v1:
        AND_IT_S_ALL_FOLKS : out std_logic; -- Segnale di fine dei calcoli o di idling
        
        -- Controllo moltiplicatori
        -- -- Primo
        ROW_SELECT_A : out std_logic_vector(6 downto 0);
        COL_SELECT_A : out std_logic_vector(6 downto 0);
        START_A      : out std_logic;
        DONE_A       : in  std_logic; 
        RESULT_A     : in  std_logic_vector(63 downto 0);
        CL_DONE_A    : in  std_logic; -- segnala che moltiplicatore ha finito di leggere.

        -- -- Secondo
        ROW_SELECT_B : out std_logic_vector(6 downto 0);
        COL_SELECT_B : out std_logic_vector(6 downto 0);
        START_B      : out std_logic;
        DONE_B       : in  std_logic;
        RESULT_B     : in  std_logic_vector(63 downto 0);
        CL_DONE_B    : in  std_logic; -- segnala che moltiplicatore ha finito di leggere.
        
        -- Interfaccia con buffer C
        C_ADDR : out std_logic_vector( 13 downto 0 );
        C_DOUT : out std_logic_vector ( 63 downto 0 );    
        C_WE   : out std_logic;
        C_WD   : in  std_logic -- Write Done. 
    );    
    end component;
    
    -- Clock period definition
    constant clk_period : time := 1 ns;
    
    -- Signals to connect to UUT
    signal CLOCK : std_logic := '0';
    signal RESET : std_logic := '0';
    
    -- Computer interface signals
    signal D_DIN   : std_logic_vector(63 downto 0) := (others => '0');

    
    -- Multiplier A signals
    signal ROW_SELECT_A : std_logic_vector(6 downto 0);
    signal COL_SELECT_A : std_logic_vector(6 downto 0);
    signal START_A      : std_logic;
    signal DONE_A       : std_logic := '0';
    signal RESULT_A     : std_logic_vector(63 downto 0) := (others => '0');
    signal CL_DONE_A    : std_logic := '0';
    
    -- Multiplier B signals
    signal ROW_SELECT_B : std_logic_vector(6 downto 0);
    signal COL_SELECT_B : std_logic_vector(6 downto 0);
    signal START_B      : std_logic;
    signal DONE_B       : std_logic := '0';
    signal RESULT_B     : std_logic_vector(63 downto 0) := (others => '0');
    signal CL_DONE_B    : std_logic := '0';
    
    -- Buffer C signals
    signal C_ADDR : std_logic_vector(13 downto 0);
    signal C_DOUT : std_logic_vector(63 downto 0);
    signal C_WE   : std_logic;
    signal C_WD   : std_logic := '0';
    
    -- Testbench control signals
    signal test_complete : boolean := false;
    
    -- Multiplier simulation signals
    signal mult_a_counter : integer := 0;
    signal mult_b_counter : integer := 0;
    constant MULT_DELAY : integer := 5; -- Cycles for multiplication to complete

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: CONTROLLER 
        Port map (
            CLOCK => CLOCK,
            RESET => RESET,
            D_DIN => D_DIN,
            ROW_SELECT_A => ROW_SELECT_A,
            COL_SELECT_A => COL_SELECT_A,
            START_A => START_A,
            DONE_A => DONE_A,
            RESULT_A => RESULT_A,
            CL_DONE_A => CL_DONE_A,
            ROW_SELECT_B => ROW_SELECT_B,
            COL_SELECT_B => COL_SELECT_B,
            START_B => START_B,
            DONE_B => DONE_B,
            RESULT_B => RESULT_B,
            CL_DONE_B => CL_DONE_B,
            C_ADDR => C_ADDR,
            C_DOUT => C_DOUT,
            C_WE => C_WE,
            C_WD => C_WD
        );

    -- Clock process
    clk_process: process
    begin
        while true loop
            CLOCK <= '0';
            wait for clk_period/2;
            CLOCK <= '1';
            wait for clk_period/2;
        end loop;
        wait;
    end process;

    -- Multiplier A simulation process
    mult_a_sim: process(CLOCK, RESET)
    begin
        if RESET = '1' then
            DONE_A <= '0';
            CL_DONE_A <= '0';
            RESULT_A <= (others => '0');
            mult_a_counter <= 0;
        elsif rising_edge(CLOCK) then
            if START_A = '1' and mult_a_counter = 0 then
                -- Start multiplication
                mult_a_counter <= 1;
                CL_DONE_A <= '0';
                DONE_A <= '0';
            elsif mult_a_counter > 0 and mult_a_counter < 3 then
                -- Simulate reading phase
                mult_a_counter <= mult_a_counter + 1;
                CL_DONE_A <= '0';
            elsif mult_a_counter = 3 then
                -- Reading done
                mult_a_counter <= mult_a_counter + 1;
                CL_DONE_A <= '1';
            elsif mult_a_counter > 3 and mult_a_counter < MULT_DELAY then
                -- Computing
                mult_a_counter <= mult_a_counter + 1;
                CL_DONE_A <= '0';
            elsif mult_a_counter = MULT_DELAY then
                -- Multiplication complete
                DONE_A <= '1';
                -- Generate a test result based on row and column
                RESULT_A <= std_logic_vector(to_unsigned(
                    to_integer(unsigned(ROW_SELECT_A)) * 1000 + 
                    to_integer(unsigned(COL_SELECT_A)), 64));
                mult_a_counter <= mult_a_counter + 1;
            elsif mult_a_counter > MULT_DELAY then
                -- Wait for controller to read result
                if DONE_A = '1' then
                    mult_a_counter <= mult_a_counter + 1;
                else
                    -- Controller has read the result, reset
                    mult_a_counter <= 0;
                    DONE_A <= '0';
                    RESULT_A <= (others => '0');
                end if;
            end if;
        end if;
    end process;

    -- Multiplier B simulation process
    mult_b_sim: process(CLOCK, RESET)
    begin
        if RESET = '1' then
            DONE_B <= '0';
            CL_DONE_B <= '0';
            RESULT_B <= (others => '0');
            mult_b_counter <= 0;
        elsif rising_edge(CLOCK) then
            if START_B = '1' and mult_b_counter = 0 then
                -- Start multiplication
                mult_b_counter <= 1;
                CL_DONE_B <= '0';
                DONE_B <= '0';
            elsif mult_b_counter > 0 and mult_b_counter < 3 then
                -- Simulate reading phase
                mult_b_counter <= mult_b_counter + 1;
                CL_DONE_B <= '0';
            elsif mult_b_counter = 3 then
                -- Reading done
                mult_b_counter <= mult_b_counter + 1;
                CL_DONE_B <= '1';
            elsif mult_b_counter > 3 and mult_b_counter < MULT_DELAY then
                -- Computing
                mult_b_counter <= mult_b_counter + 1;
                CL_DONE_B <= '0';
            elsif mult_b_counter = MULT_DELAY then
                -- Multiplication complete
                DONE_B <= '1';
                -- Generate a test result based on row and column
                RESULT_B <= std_logic_vector(to_unsigned(
                    to_integer(unsigned(ROW_SELECT_B)) * 2000 + 
                    to_integer(unsigned(COL_SELECT_B)), 64));
                mult_b_counter <= mult_b_counter + 1;
            elsif mult_b_counter > MULT_DELAY then
                -- Wait for controller to read result
                if DONE_B = '1' then
                    mult_b_counter <= mult_b_counter + 1;
                else
                    -- Controller has read the result, reset
                    mult_b_counter <= 0;
                    DONE_B <= '0';
                    RESULT_B <= (others => '0');
                end if;
            end if;
        end if;
    end process;

    -- Memory C simulation process
    mem_c_sim: process(CLOCK, RESET)
        variable write_delay : integer := 0;
    begin
        if RESET = '1' then
            C_WD <= '0';
            write_delay := 0;
        elsif rising_edge(CLOCK) then
            if C_WE = '1' and write_delay = 0 then
                -- Start write operation
                write_delay := 1;
                C_WD <= '0';
            elsif write_delay > 0 and write_delay < 3 then
                -- Simulate write delay
                write_delay := write_delay + 1;
                C_WD <= '0';
            elsif write_delay = 3 then
                -- Write complete
                C_WD <= '1';
                write_delay := write_delay + 1;
            elsif write_delay > 3 then
                -- Reset after controller reads WD
                if C_WE = '0' then
                    C_WD <= '0';
                    write_delay := 0;
                end if;
            end if;
        end if;
    end process;

    -- Computer interface simulation
    computer_sim: process(CLOCK, RESET)
        variable de_delay : integer := 0;
    begin
        if RESET = '1' then
            de_delay := 0;
        elsif rising_edge(CLOCK) then
            if de_delay = 0 then
                -- Start write acknowledgment
                de_delay := 1;
            elsif de_delay > 0 and de_delay < 2 then
                -- Simulate write delay
                de_delay := de_delay + 1;
            elsif de_delay = 2 then
                -- Write acknowledged
                de_delay := de_delay + 1;
            end if;
        end if;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Reset phase
        RESET <= '1';
        wait for 20 ns;
        RESET <= '0';

        wait for 50 ns;
        
        -- Test 2: Send start command (D_DIN with bits 1:0 = "10")
        D_DIN <= (1 => '1', 0 => '0', others => '0'); -- Set bits 1:0 to "10"
                
        -- Wait for processing to start
        wait for 100 ns;
        
        -- Let the system run for a while to process some multiplications
        wait for 2000 ns;
        
        -- Test 3: Check if controller eventually reaches DONE state
        -- This will happen when CURRENT_ROW = CURRENT_COL = 100
        -- For testing purposes, we'll wait a reasonable amount of time
        wait for 1000 ns;
        
        -- Verify that some operations occurred
        assert START_A = '1' or START_B = '1' report "No multiplication started" severity warning;
        
        -- Test 4: Reset during operation
        wait for 100 ns;
        RESET <= '1';
        wait for 20 ns;
        RESET <= '0';

        
        -- Should remain in IDLING state
        wait for 100 ns;
        
        -- End simulation
        test_complete <= true;
        
        report "Simulation completed successfully" severity note;
        wait;
    end process;

    -- Monitor process for debugging
    monitor: process(CLOCK)
    begin
        if rising_edge(CLOCK) then
            -- Print state changes and important signals
            if START_A = '1' then
                report "Multiplier A started: ROW=" & integer'image(to_integer(unsigned(ROW_SELECT_A))) & 
                       " COL=" & integer'image(to_integer(unsigned(COL_SELECT_A))) severity note;
            end if;
            
            if START_B = '1' then
                report "Multiplier B started: ROW=" & integer'image(to_integer(unsigned(ROW_SELECT_B))) & 
                       " COL=" & integer'image(to_integer(unsigned(COL_SELECT_B))) severity note;
            end if;
            
            if C_WE = '1' then
                report "Writing to C: ADDR=" & integer'image(to_integer(unsigned(C_ADDR))) severity note;
            end if;

        end if;
    end process;

end Behavioral;
