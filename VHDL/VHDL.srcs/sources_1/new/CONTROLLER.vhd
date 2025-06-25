----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/25/2025 03:15:18 PM
-- Design Name: 
-- Module Name: CONTROLLER - Behavioral
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

entity CONTROLLER is
    Port ( 
        -- Sincronismo
        CLOCK : in std_logic;
        RESET : in std_logic;
        
        -- Interfaccia con Computer
        D_ADDR  : out std_logic_vector( 13 downto 0);
        D_DIN   : in  std_logic_vector(63 downto 0);
        D_DOUT  : out std_logic_vector(63 downto 0);
        D_WE    : out std_logic;
        D_READY : in  std_logic;
        
        -- Controllo moltiplicatori
        -- -- Primo
        ROW_SELECT_A : out std_logic_vector(6 downto 0);
        COL_SELECT_A : out std_logic_vector(6 downto 0);
        START_A      : out std_logic;
        DONE_A       : in  std_logic; 
        RESULT_A     : in  std_logic_vector(64 downto 0);
        
        -- -- Secondo
        ROW_SELECT_B : out std_logic_vector(6 downto 0);
        COL_SELECT_B : out std_logic_vector(6 downto 0);
        START_B      : out std_logic;
        DONE_B       : in  std_logic;
        RESULT_B     : in  std_logic_vector(64 downto 0);
        
        -- Interfaccia con buffer C
        C_ADDR : out std_logic_vector( 13 downto 0 );
        C_DOUT : out std_logic_vector ( 63 downto 0 );    
        C_WE   : out std_logic;
        C_WD   : in  std_logic -- Write Done. 
);
end CONTROLLER;

architecture v0 of CONTROLLER is
    constant size : unsigned := to_unsigned( 100, 7 );
    
    type MULTIPLIER_STATE is (COMPUTING, ACCEPTING, DONE);
    type PROCESS_CONTROL_STATE is (IDLING, PROCESSING, LOAD, DONE);
    
    signal PC_STATE : PROCESS_CONTROL_STATE := IDLING;
    
    signal CURRENT_ROW : unsigned := to_unsigned( 0, 7);
    signal CURRENT_COL : unsigned := TO_UNSIGNED( 0, 7);
    
    signal ENABLE_A      : std_logic := '0'; -- Variabile per abilitare all'accesso
    signal ENABLE_B      : std_logic := '0'; -- alla memoria il moltiplicatore

    
    signal READING_DONE_A : std_logic := '0'; -- Variabile per dichiare al processo di
    signal READING_DONE_B : std_logic := '0'; -- gestione del moltiplicatore che si e' letto
                                              -- il dato in TMP_RESULT
                           
    signal M_STATE_A : MULTIPLIER_STATE := ACCEPTING;
    signal M_STATE_B : MULTIPLIER_STATE := ACCEPTING;

    signal TMP_RESULT_A : std_logic_vector(63 downto 0) := std_logic_vector(to_unsigned(0,64));
    signal TMP_RESULT_B : std_logic_vector(63 downto 0) := std_logic_vector(to_unsigned(0,64));
    signal ROW_IDX_A : unsigned := to_unsigned(0, 7); -- servono come variabili temporanee...
    signal ROW_IDX_B : unsigned := to_unsigned(0, 7);
    signal COL_IDX_A : unsigned := to_unsigned(0, 7); -- servono come variabili temporanee...
    signal COL_IDX_B : unsigned := to_unsigned(0, 7);

begin
    
    PROCESS_CONTROL:  process(CLOCK, RESET)
        variable GLOBAL_ENABLE : std_logic := '0'; -- Qualcuno sta accendo alla memoria?
    begin
        if RESET = '1' then
            CURRENT_ROW <= to_unsigned(0,7);
            CURRENT_COL <= to_unsigned(0,7);
            PC_STATE <= IDLING;
            D_ADDR <= std_logic_vector(to_unsigned( 0, 14));
        elsif rising_edge(CLOCK) then
             case PC_STATE is
                when IDLING =>
                    D_ADDR <= std_logic_vector(to_unsigned( 0, 14));
                    D_WE <= '0';
                    if D_READY = '1' then
                        if D_DIN(1 downto 0) = "10" then
                            -- Assumo che A e B siano state riempite correttamente.
                            CURRENT_ROW <= to_unsigned(0,7);
                            CURRENT_COL <= to_unsigned(0,7);
                            PC_STATE <= PROCESSING;
                        else
                            D_ADDR <= std_logic_vector(to_unsigned( 0, 14));
                            D_WE <= '0';
                            PC_STATE <= IDLING; 
                        end if;
                    else
                        D_ADDR <= std_logic_vector(to_unsigned( 0, 14));
                        D_WE <= '0';
                        PC_STATE <= IDLING;
                    end if;
                    
                when PROCESSING =>
                    GLOBAL_ENABLE := ENABLE_A or ENABLE_B;
                    if CURRENT_COL = size and CURRENT_ROW = size then
                        PC_STATE <= DONE;
                    elsif M_STATE_A = ACCEPTING and GLOBAL_ENABLE = '0' then
                        ENABLE_A <= '1'; 
                    elsif M_STATE_B = ACCEPTING and GLOBAL_ENABLE = '0' then
                        ENABLE_B <= '1';
                    elsif M_STATE_A = DONE then
                        -- Trasferisco il risultato in C
                        -- Comunico ad A che ho finito e puo' tornare in IDLE
                        
                        C_WE <= '1'; -- Comunico a C di voler scrivere
                        C_ADDR <= std_logic_vector(ROW_IDX_A + COL_IDX_A * size);
                        C_DOUT <= TMP_RESULT_A;
                        READING_DONE_A <= '0';
                        PC_STATE <= LOAD;                 
                    elsif M_STATE_B = DONE then
                        -- Trasferisco il risultato in C
                        -- Comunico a B che ho finito e puo' tornare in IDLE
                                                
                        C_WE <= '1'; -- Comunico a C di voler scrivere
                        C_ADDR <= std_logic_vector(ROW_IDX_B + COL_IDX_B * size);
                        C_DOUT <= TMP_RESULT_B;
                        READING_DONE_A <= '0';
                        PC_STATE <= LOAD;
                    else
                    end if;
                
                WHEN LOAD =>
                    if C_WD = '1' then 
                        PC_STATE <= PROCESSING;
                    else
                        PC_STATE <= LOAD;
                    end if;
                       
                when DONE =>
                when others =>        
             end case;
        end if;
    end process;
    
    MULTIPLIER_A : process(CLOCK, RESET)
    begin
        if RESET = '1' then
            ROW_SELECT_A <= std_logic_vector(TO_UNSIGNED( 0, 7));
            COL_SELECT_A <= std_logic_vector(TO_UNSIGNED( 0, 7));
            TMP_RESULT_A <= std_logic_vector(TO_UNSIGNED( 0, 64));
            START_A <= '0';
            M_STATE_A <= ACCEPTING;
        elsif rising_edge(CLOCK) then
            case M_STATE_A is
                when ACCEPTING =>
                    if ENABLE_A = '1' then
                        ROW_SELECT_A <= std_logic_vector(CURRENT_ROW);
                        COL_SELECT_A <= std_logic_vector(CURRENT_COL);
                        ROW_IDX_A <= CURRENT_ROW;
                        COL_IDX_A <= CURRENT_COL;
                        if CURRENT_COL < size then
                            CURRENT_COL <= CURRENT_COL + 1;
                        else
                            CURRENT_COL <= TO_UNSIGNED (0, 7);
                            CURRENT_ROW <= CURRENT_ROW + 1;
                        end if;

                        
                        START_A <= '1';
                        M_STATE_A <= COMPUTING;
                    else 
                        M_STATE_A <= ACCEPTING;
                    end if;
                when COMPUTING =>
                    START_A <= '0';                    
                    if DONE_A = '1' then
                        TMP_RESULT_A <= RESULT_A;
                        M_STATE_A <= DONE;
                    else
                        M_STATE_A <= COMPUTING;
                    end if;       
                when DONE =>
                    if READING_DONE_A = '1' then
                        READING_DONE_A <= '0';
                        M_STATE_A <= ACCEPTING;
                    else
                        M_STATE_A <= DONE;
                    end if;    
                when others =>
                    ROW_SELECT_A <= std_logic_vector(TO_UNSIGNED (0, 7));
                    COL_SELECT_A <= std_logic_vector(TO_UNSIGNED (0, 7));
                    START_A <= '0';
                    M_STATE_A <= ACCEPTING;
            end case;         
        end if;
    end process;
    
    MULTIPLIER_B : process(CLOCK, RESET)
    begin
        if RESET = '1' then
            ROW_SELECT_B <= std_logic_vector(TO_UNSIGNED( 0, 7));
            COL_SELECT_B <= std_logic_vector(TO_UNSIGNED( 0, 7));
            TMP_RESULT_B <= std_logic_vector(TO_UNSIGNED( 0, 64));
            START_B <= '0';
            M_STATE_B <= ACCEPTING;
        elsif rising_edge(CLOCK) then
            case M_STATE_B is
                when ACCEPTING =>
                    if ENABLE_B = '1' then
                        ROW_SELECT_B <= std_logic_vector(CURRENT_ROW);
                        COL_SELECT_B <= std_logic_vector(CURRENT_COL);
                        ROW_IDX_B <= CURRENT_ROW;
                        COL_IDX_B <= CURRENT_COL;
                        if CURRENT_COL < size then
                            CURRENT_COL <= CURRENT_COL + 1;
                        else
                            CURRENT_COL <= TO_UNSIGNED (0, 7);
                            CURRENT_ROW <= CURRENT_ROW + 1;
                        end if;
                        START_B <= '1';
                        M_STATE_B <= COMPUTING;
                    else 
                        M_STATE_B <= ACCEPTING;
                    end if;
                when COMPUTING =>
                    START_B <= '0';                    
                    if DONE_B = '1' then
                        TMP_RESULT_B <= RESULT_A;
                        M_STATE_B <= DONE;
                    else
                        M_STATE_B <= COMPUTING;
                    end if;       
                when DONE =>
                    if READING_DONE_B = '1' then
                        READING_DONE_B <= '0';
                        M_STATE_B <= ACCEPTING;
                    else
                        M_STATE_B <= DONE;
                    end if;    
                when others =>
                    ROW_SELECT_B <= std_logic_vector(TO_UNSIGNED (0, 7));
                    COL_SELECT_B <= std_logic_vector(TO_UNSIGNED (0, 7));
                    START_B <= '0';
                    M_STATE_B <= ACCEPTING;
            end case;         
        end if;
    end process;
end v0;
