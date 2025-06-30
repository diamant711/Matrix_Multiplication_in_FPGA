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
    
    -- End Signal
    signal AND_IT_S_ALL_FOLKS : std_logic; -- Segnale di fine dei calcoli o di idling

    
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
    signal RESULT_B     : std_logic_vector(63 downto 0) := std_logic_vector(to_unsigned(10000, 64));
    signal CL_DONE_B    : std_logic := '0';
    
    -- Buffer C signals
    signal C_ADDR : std_logic_vector(13 downto 0);
    signal C_DOUT : std_logic_vector(63 downto 0);
    signal C_WE   : std_logic;
    signal C_WD   : std_logic := '0';
    
begin
    -- Instantiate the Unit Under Test (UUT)
    uut: CONTROLLER 
        Port map (
        -- Sincronismo
        CLOCK => CLOCK,
        RESET => RESET,
        
        -- Interfaccia con Computer
        D_DIN => D_DIN,
        AND_IT_S_ALL_FOLKS => AND_IT_S_ALL_FOLKS, -- Segnale di fine dei calcoli o di idling
        
        -- Controllo moltiplicatori
        -- -- Primo
        ROW_SELECT_A => ROW_SELECT_A,
        COL_SELECT_A => COL_SELECT_A,
        START_A => START_A,
        DONE_A => DONE_A,
        RESULT_A => RESULT_A,
        CL_DONE_A => CL_DONE_A, -- segnala che moltiplicatore ha finito di leggere.

        -- -- Secondo
        ROW_SELECT_B => ROW_SELECT_B,
        COL_SELECT_B => COL_SELECT_B,
        START_B => START_B,
        DONE_B => DONE_B,
        RESULT_B => RESULT_B,
        CL_DONE_B => CL_DONE_B, -- segnala che moltiplicatore ha finito di leggere.
        
        -- Interfaccia con buffer C
        C_ADDR => C_ADDR,
        C_DOUT => C_DOUT,
        C_WE => C_WE,
        C_WD => C_WD -- Write Done.
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
    mult_a_sim: process
    begin    
        -- Simulo il reset
        DONE_A <= '0';
        CL_DONE_A <= '0';
        RESULT_A <= (others => '0');
        -- Adesso aspetto che arrivi dall'interfaccia al moltiplicatore la partenza
        wait until START_A = '1';
        ASSERT unsigned(ROW_SELECT_A) < 100 report "Superato limite su righe" severity note;
        ASSERT unsigned(COL_SELECT_A) < 100 report "Superato limite su colonne" severity note;
        wait for 10 ns;
        CL_DONE_A <= '1';
        wait for 10 ns;
        DONE_A <= '1';
        RESULT_A <= std_logic_vector(unsigned(RESULT_A) + 1); 
        wait until C_WD = '1'; -- presumibilmente verr`a salvato subito.
    end process;

    -- Multiplier B simulation process
    mult_b_sim: process
    begin    
        -- Simulo il reset
        DONE_B <= '0';
        CL_DONE_B <= '0';
        RESULT_B <= (others => '0');
        -- Adesso aspetto che arrivi dall'interfaccia al moltiplicatore la partenza
        wait until START_B = '1';
        ASSERT unsigned(ROW_SELECT_B) < 100 report "Superato limite su righe" severity note;
        ASSERT unsigned(COL_SELECT_B) < 100 report "Superato limite su colonne" severity note;
        wait for 10 ns;
        CL_DONE_B <= '1';
        wait for 10 ns;
        DONE_B <= '1';
        RESULT_B <= std_logic_vector(unsigned(RESULT_B) + 1); 
        wait until C_WD = '1'; -- presumibilmente verr`a salvato subito.
    end process;

    -- Memory C simulation process
    memory_response : process
    begin
        wait until C_WE = '1';
        C_WD <= '1';
        assert C_DOUT = RESULT_A or C_DOUT = RESULT_B report "Si `e inventato il risultato" severity note;
        wait for 10 ns;
        assert C_WE = '0' report "Sistema smette di scrivere" severity note;
        C_WD <= '0';
    end process;

    -- Stimulus process
    stim_proc: process
    begin
         -- Reset
        RESET <= '1';
        wait for 20 ns;
        RESET <= '0';

        -- Start elaboration
        wait for 20 ns;
        D_DIN(1 downto 0) <= "10";  -- Avvia il calcolo
        wait for clk_period;
        D_DIN(1 downto 0) <= "00";  -- Torna a idle dopo trigger



        -- Fine simulazione
        wait until AND_IT_S_ALL_FOLKS = '1';
        assert false report "Fine simulazione." severity note;
        wait;
    end process;


end Behavioral;
