----------------------------------------------------------------------------------
-- Company:  Unimi
-- Engineer: Stefano Pilosio
-- 
-- Create Date: 06/27/2025 10:26:50 AM
-- Design Name: 
-- Module Name: CONTROLLER_MULTIPLIER_INTERFACE - v0
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

entity CONTROLLER_MULTIPLIER_INTERFACE is
    Port (
        -- Sincronia
        CLOCK : in std_logic;
        RESET : in std_logic;
    
        -- Controllo moltiplicatori
        ROW_SELECT      : out std_logic_vector(6 downto 0);
        COL_SELECT      : out std_logic_vector(6 downto 0);

        -- Comunicazione con controller        
        CNTRL_CUR_ROW   : in  unsigned(6 downto 0);
        CNTRL_CUR_COL   : in  unsigned(6 downto 0);
        CNTRL_ENABLE    : in  std_logic; -- L'interfaccia `e abilitata all'accesso di memoria
        CNTRL_WRT_DONE  : out std_logic; -- Segnalo al controller che il moltiplicatore ha smesso di leggere
        CNTRL_MULT_DONE : out std_logic;
        CNTRL_RES_SAVE  : in  std_logic;
        CNTRL_OCC       : out std_logic; -- Segnala al controller che il moltiplicatore sta calcolando
        TMP_RESULT      : out std_logic_vector(63 downto 0);
   
        -- Comunicazione con multiplier
        MULT_START      : out std_logic;
        MULT_DONE       : in  std_logic; 
        MULT_RESULT     : in  std_logic_vector(63 downto 0);
        MULT_CL_DONE    : in  std_logic -- segnala che moltiplicatore ha finito di leggere.
        
    );
end CONTROLLER_MULTIPLIER_INTERFACE;

architecture v0 of CONTROLLER_MULTIPLIER_INTERFACE is
    constant SIZE : unsigned := to_unsigned(100, 7);
    type MULTIPLIER_STATE is (COMPUTING, ACCEPTING, DONE);
    
    signal MULT_STATE : MULTIPLIER_STATE := ACCEPTING;
begin
    INTERFACE_STATE : process(CLOCK, RESET)
    begin
        if RESET = '1' then
            ROW_SELECT <= std_logic_vector(TO_UNSIGNED( 0, 7));
            COL_SELECT <= std_logic_vector(TO_UNSIGNED( 0, 7));
            TMP_RESULT <= std_logic_vector(TO_UNSIGNED( 0, 64));
            
            CNTRL_WRT_DONE  <= '0';
            CNTRL_MULT_DONE <= '0';
            CNTRL_OCC       <= '0';
            MULT_START      <= '0';
            
            MULT_STATE <= ACCEPTING;
        elsif rising_edge(CLOCK) then
            case MULT_STATE is
                when ACCEPTING =>
                    if CNTRL_ENABLE = '1' then
                        ROW_SELECT <= std_logic_vector(CNTRL_CUR_ROW);
                        COL_SELECT <= std_logic_vector(CNTRL_CUR_COL);
                        MULT_START <= '1';
                        CNTRL_OCC <= '1';
                        MULT_STATE <= COMPUTING;
                    else
                        MULT_STATE <= ACCEPTING;
                    end if;
                when COMPUTING =>
                    MULT_START <= '0';
                    if MULT_CL_DONE = '1' then
                        CNTRL_WRT_DONE <= '1';
                        MULT_STATE <= COMPUTING;
                    elsif MULT_DONE = '1' then
                        TMP_RESULT <= MULT_RESULT;
                        CNTRL_MULT_DONE <= '1';
                        MULT_STATE <= DONE;
                    else
                        CNTRL_WRT_DONE <= '0';
                        MULT_STATE <= COMPUTING;
                    end if;                 
                when DONE =>
                    if CNTRL_RES_SAVE = '1' then
                        CNTRL_MULT_DONE <= '0';
                        CNTRL_OCC       <= '0';
                        MULT_STATE <= ACCEPTING;
                    else
                        MULT_STATE <= DONE;
                    end if; 
                when others =>
                    ROW_SELECT <= std_logic_vector(TO_UNSIGNED( 0, 7));
                    COL_SELECT <= std_logic_vector(TO_UNSIGNED( 0, 7));
                    TMP_RESULT <= std_logic_vector(TO_UNSIGNED( 0, 64));
                    
                    CNTRL_WRT_DONE  <= '0';
                    CNTRL_MULT_DONE <= '0';
                    MULT_START      <= '0';
                    
                    MULT_STATE <= ACCEPTING;
            end case;         
        end if;
    end process;
end v0;
