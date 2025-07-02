----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/27/2025 10:27:36 AM
-- Design Name: 
-- Module Name: CONTROLLER_LOGIC - v0
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

entity CONTROLLER_LOGIC is
    Port (
        -- Sincronismo
        CLOCK : in std_logic;
        RESET : in std_logic;
        
        -- Interfaccia con Computer
        D_DIN   : in  std_logic_vector(63 downto 0);
  
        AND_IT_S_ALL_FOLKS : out std_logic;
        
        -- Interfaccia con buffer C
        C_ADDR : out std_logic_vector( 13 downto 0 );
        C_DOUT : out std_logic_vector ( 63 downto 0 );    
        C_WE   : out std_logic;
        C_WD   : in  std_logic; -- Write Done.
        
        -- Interfacce comuni tra i moltiplicatori
        CNTRL_CUR_ROW : out unsigned(6 downto 0);
        CNTRL_CUR_COL : out unsigned(6 downto 0);
        
        -- Interfacce specifiche con moltiplicatori
        
        CNTRL_ENABLE_A    : out std_logic; -- Variabile per abilitare all'accesso
        CNTRL_ENABLE_B    : out std_logic; -- alla memoria il moltiplicatore
        CNTRL_RES_SAVE_A  : out std_logic;
        CNTRL_RES_SAVE_B  : out std_logic;
        CNTRL_OCC_A       : in  std_logic;
        CNTRL_OCC_B       : in  std_logic;
        CNTRL_WRT_DONE_A  : in  std_logic; -- Segnalo al controller che il moltiplicatore ha smesso di leggere
        CNTRL_WRT_DONE_B  : in  std_logic; -- Segnalo al controller che il moltiplicatore ha smesso di leggere
        CNTRL_MULT_DONE_A : in  std_logic;
        CNTRL_MULT_DONE_B : in  std_logic;
        TMP_RESULT_A      : in  std_logic_vector(63 downto 0);
        TMP_RESULT_B      : in  std_logic_vector(63 downto 0)        
    );
end CONTROLLER_LOGIC;

architecture v0 of CONTROLLER_LOGIC is
        constant SIZE : unsigned := to_unsigned( 100, 7 );
        type PROCESS_CONTROL_STATE is (IDLING, PROCESSING, LOAD, DONE);
        signal PC_STATE : PROCESS_CONTROL_STATE := IDLING;
        
        signal CURRENT_ROW_A : unsigned(6 downto 0) := to_unsigned(0, 7);
        signal CURRENT_COL_A : unsigned(6 downto 0) := to_unsigned(0, 7);
        signal CURRENT_ROW_B : unsigned(6 downto 0) := to_unsigned(0, 7);
        signal CURRENT_COL_B : unsigned(6 downto 0) := to_unsigned(0, 7);
        signal DUMMY_CUR_ROW : unsigned(6 downto 0) := to_unsigned(0, 7);
        signal DUMMY_CUR_COL : unsigned(6 downto 0) := to_unsigned(0, 7);        
        signal DUMMY_ENABLE_A : std_logic := '0';
        signal DUMMY_ENABLE_B : std_logic := '0';
        signal D_DIN_reg : std_logic_vector(63 downto 0);

begin

    PROCESS_CONTROL : process(CLOCK, RESET)
        variable GLOBAL_ENABLE : std_logic := '0';

    begin
        if RESET = '1' then
            CURRENT_ROW_A <= (others => '0');
            CURRENT_COL_A <= (others => '0');
            --CURRENT_ROW_B <= (others => '0');
            --CURRENT_COL_B <= (others => '0');
            AND_IT_S_ALL_FOLKS <= '1';
            C_ADDR <= (others => '0');
            C_DOUT <= (others => '0');    
            C_WE   <= '0';
            DUMMY_CUR_ROW    <= (others => '0');
            DUMMY_CUR_COL    <= (others => '0');
            CNTRL_CUR_ROW    <= (others => '0');
            CNTRL_CUR_COL    <= (others => '0');
            DUMMY_ENABLE_A <= '0'; -- Segnale per avere accesso al valore di CNTRL_ENABLE_A
            DUMMY_ENABLE_B <= '0'; -- Segnale per avere accesso al valore di CNTRL_ENABLE_B
            CNTRL_ENABLE_A   <= '0'; -- Variabile per abilitare all'accesso
            CNTRL_ENABLE_B   <= '0'; -- alla memoria il moltiplicatore
            CNTRL_RES_SAVE_A <= '0';
            CNTRL_RES_SAVE_B <= '0';
            PC_STATE <= IDLING;
            D_DIN_reg <= D_DIN;
        elsif rising_edge(CLOCK) then
            case PC_STATE is
                when IDLING =>
                    if D_DIN(1 downto 0) = "01" then
                        -- Assumo che A e B siano state riempite correttamente.
                        CNTRL_CUR_ROW <= to_unsigned(0,7);
                        CNTRL_CUR_COL <= to_unsigned(0,7);
                        AND_IT_S_ALL_FOLKS <= '0';
                        PC_STATE <= PROCESSING;
                    else
                        PC_STATE <= IDLING;
                    end if;
                when PROCESSING =>
                    GLOBAL_ENABLE := DUMMY_ENABLE_A or DUMMY_ENABLE_B;
                    CNTRL_ENABLE_A <= DUMMY_ENABLE_A;
                    CNTRL_ENABLE_B <= DUMMY_ENABLE_B;
                    CNTRL_CUR_ROW <= DUMMY_CUR_ROW;
                    CNTRL_CUR_COL <= DUMMY_CUR_COL;
                    
                    if CNTRL_OCC_A = '0' and GLOBAL_ENABLE = '0' then
                        DUMMY_ENABLE_A <= '1';
                        CURRENT_ROW_A <= DUMMY_CUR_ROW;
                        CURRENT_COL_A <= DUMMY_CUR_COL; 
                        PC_STATE <= PROCESSING;
                    elsif CNTRL_OCC_B = '0' and GLOBAL_ENABLE = '0' then
                        DUMMY_ENABLE_B <= '1';
                        CURRENT_ROW_A <= DUMMY_CUR_ROW;
                        CURRENT_COL_A <= DUMMY_CUR_COL;
                        PC_STATE <= PROCESSING;
                    elsif GLOBAL_ENABLE = '1' and CNTRL_WRT_DONE_A = '1' then
                        DUMMY_ENABLE_A <= '0';
                        if DUMMY_CUR_COL < SIZE - 1 then
                            DUMMY_CUR_COL <= DUMMY_CUR_COL + 1;
                        else -- DUMMY_CUR_COL = SIZE - 1 then
                            DUMMY_CUR_COL <= to_unsigned(0,7);
                            DUMMY_CUR_ROW <= DUMMY_CUR_ROW + 1;
                        end if;
                        PC_STATE <= PROCESSING;

                    elsif GLOBAL_ENABLE = '1' and CNTRL_WRT_DONE_B = '1' then
                        DUMMY_ENABLE_B <= '0';
                        if DUMMY_CUR_COL < SIZE - 1 then
                            DUMMY_CUR_COL <= DUMMY_CUR_COL + 1;
                        else -- DUMMY_CUR_COL = SIZE - 1 then
                            DUMMY_CUR_COL <= to_unsigned(0,7);
                            DUMMY_CUR_ROW <= DUMMY_CUR_ROW + 1;
                        end if;
                        PC_STATE <= PROCESSING;
                    elsif CNTRL_MULT_DONE_A = '1' then
                        C_ADDR <= std_logic_vector(CURRENT_ROW_A + CURRENT_COL_A * size);
                        C_DOUT <= TMP_RESULT_A;
                        C_WE <= '1';
                        CNTRL_RES_SAVE_A <= '1';
                        PC_STATE <= LOAD;
                    elsif CNTRL_MULT_DONE_B = '1' then
                        C_ADDR <= std_logic_vector(CURRENT_ROW_B + CURRENT_COL_B * size);
                        C_DOUT <= TMP_RESULT_B;
                        C_WE <= '1';
                        CNTRL_RES_SAVE_B <= '1';
                        PC_STATE <= LOAD;      
                    else
                        PC_STATE <= PROCESSING;
                    end if;
                when LOAD =>
                    if C_WD = '1' then
                        CNTRL_RES_SAVE_A <= '0';
                        CNTRL_RES_SAVE_B <= '0';
                        C_WE <= '0';
                        if DUMMY_CUR_ROW = size then
                            PC_STATE <= DONE;
                        else 
                            PC_STATE <= PROCESSING;
                        end if;
                    else 
                        PC_STATE <= LOAD;
                    end if;             
                when DONE =>
                    AND_IT_S_ALL_FOLKS <= '1';
                    PC_STATE <= IDLING;
                when others =>
                    AND_IT_S_ALL_FOLKS <= '1';
                    C_ADDR <= (others => '0');
                    C_DOUT <= (others => '0');    
                    C_WE   <= '0';
                    CNTRL_CUR_ROW    <= (others => '0');
                    CNTRL_CUR_COL    <= (others => '0');
                    CNTRL_ENABLE_A   <= '0'; -- Variabile per abilitare all'accesso
                    CNTRL_ENABLE_B   <= '0'; -- alla memoria il moltiplicatore
                    CNTRL_RES_SAVE_A <= '0';
                    CNTRL_RES_SAVE_B <= '0';
                    PC_STATE <= IDLING;
            end case;         
        end if;
    end process;

end v0;
