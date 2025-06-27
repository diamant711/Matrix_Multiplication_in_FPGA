----------------------------------------------------------------------------------
-- Company: Unimi
-- Engineer: Stefano Pilosio
-- 
-- Create Date: 06/25/2025 03:15:18 PM
-- Design Name: 
-- Module Name: CONTROLLER - v0
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
-- Quanto commentato appartiene a Vecchia Versione v0
        -- Sincronismo
        CLOCK : in std_logic;
        RESET : in std_logic;
        
        -- Interfaccia con Computer
--        D_ADDR  : out std_logic_vector( 13 downto 0);
        D_DIN   : in  std_logic_vector(63 downto 0);
--        D_DOUT  : out std_logic_vector(63 downto 0);
--        D_WE    : out std_logic;
--        D_DE    : in std_logic; -- Writing Done
--        D_READY : in  std_logic; -- Reading Ready
        
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
end CONTROLLER;

architecture v1 of CONTROLLER is
    component CONTROLLER_LOGIC
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
    end component;
    
    component CONTROLLER_MULTIPLIER_INTERFACE
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
    end component;

    -- Intermediate signals between entities
    signal global_cur_col : unsigned(6 downto 0);
    signal global_cur_row : unsigned(6 downto 0);

    signal ctrl_mult_enable_a  : std_logic;
    signal ctrl_mult_save_a    : std_logic;
    signal mult_ctrl_done_a    : std_logic;
    signal mult_ctrl_wrote_a   : std_logic;
    signal mult_ctrl_tmp_res_a : std_logic_vector(63 downto 0);
    signal mult_ctrol_occ_a    : std_logic;

    signal ctrl_mult_enable_b  : std_logic;
    signal ctrl_mult_save_b    : std_logic;
    signal mult_ctrl_done_b    : std_logic;
    signal mult_ctrl_wrote_b   : std_logic;
    signal mult_ctrl_tmp_res_b : std_logic_vector(63 downto 0);
    signal mult_ctrol_occ_b    : std_logic;

begin
    cl: CONTROLLER_LOGIC
    port map(
        CLOCK => CLOCK,
        RESET => RESET,
        D_DIN => D_DIN,
        AND_IT_S_ALL_FOLKS => AND_IT_S_ALL_FOLKS,
        C_ADDR => C_ADDR,
        C_DOUT => C_DOUT,
        C_WE   => C_WE,
        C_WD   => C_WD,
        CNTRL_CUR_ROW     => global_cur_row,
        CNTRL_CUR_COL     => global_cur_col,
        CNTRL_ENABLE_A    => ctrl_mult_enable_a,
        CNTRL_ENABLE_B    => ctrl_mult_enable_b,
        CNTRL_RES_SAVE_A  => ctrl_mult_save_a,
        CNTRL_RES_SAVE_B  => ctrl_mult_save_b,
        CNTRL_OCC_A       => mult_ctrol_occ_a,
        CNTRL_OCC_B       => mult_ctrol_occ_b,
        CNTRL_WRT_DONE_A  => mult_ctrl_wrote_a, 
        CNTRL_WRT_DONE_B  => mult_ctrl_wrote_b,
        CNTRL_MULT_DONE_A => mult_ctrl_done_a,
        CNTRL_MULT_DONE_B => mult_ctrl_done_b,
        TMP_RESULT_A      => mult_ctrl_tmp_res_a,
        TMP_RESULT_B      => mult_ctrl_tmp_res_b
    );

    multiplier_a: CONTROLLER_MULTIPLIER_INTERFACE
    port map(
        CLOCK => CLOCK,
        RESET => RESET,
        -- Controllo moltiplicatori
        ROW_SELECT => ROW_SELECT_A,
        COL_SELECT => COL_SELECT_A,
    
        -- Comunicazione con controller        
        CNTRL_CUR_ROW   => global_cur_row,
        CNTRL_CUR_COL   => global_cur_col,
        CNTRL_ENABLE    => ctrl_mult_enable_a,
        CNTRL_WRT_DONE  => mult_ctrl_wrote_a,
        CNTRL_MULT_DONE => mult_ctrl_done_a,
        CNTRL_RES_SAVE  => ctrl_mult_save_a,
        CNTRL_OCC       => mult_ctrol_occ_a,
        TMP_RESULT      => mult_ctrl_tmp_res_a, -- risultato comunicato al controller
    
        -- Comunicazione con multiplier
        MULT_START   => START_A,
        MULT_DONE    => DONE_A, 
        MULT_RESULT  => RESULT_A, -- risultato del moltiplicatore
        MULT_CL_DONE => CL_DONE_A
    );
    
    multiplier_b: CONTROLLER_MULTIPLIER_INTERFACE
    port map(
        CLOCK => CLOCK,
        RESET => RESET,
        -- Controllo moltiplicatori
        ROW_SELECT => ROW_SELECT_B,
        COL_SELECT => COL_SELECT_B,
    
        -- Comunicazione con controller
        CNTRL_CUR_ROW   => global_cur_row,
        CNTRL_CUR_COL   => global_cur_col,
        CNTRL_ENABLE    => ctrl_mult_enable_b,
        CNTRL_WRT_DONE  => mult_ctrl_wrote_b,
        CNTRL_MULT_DONE => mult_ctrl_done_b,
        CNTRL_RES_SAVE  => ctrl_mult_save_b,
        CNTRL_OCC       => mult_ctrol_occ_b,
        TMP_RESULT      => mult_ctrl_tmp_res_b,
    
        -- Comunicazione con multiplier
        MULT_START   => START_B,
        MULT_DONE    => DONE_B,
        MULT_RESULT  => RESULT_B,
        MULT_CL_DONE => CL_DONE_B
    );

end v1;


-- Me la tengo che voglio poi chiedere perch`e non funzioni al professore.
--architecture v0 of CONTROLLER is
--    constant size : unsigned := to_unsigned( 100, 7 );
    
--    type MULTIPLIER_STATE is (COMPUTING, ACCEPTING, DONE);
--    type PROCESS_CONTROL_STATE is (IDLING, PROCESSING, LOAD, DONE);
    
--    signal PC_STATE : PROCESS_CONTROL_STATE := IDLING;
    
--    signal CURRENT_ROW : unsigned(6 downto 0) := to_unsigned(0, 7);
--    signal CURRENT_COL : unsigned(6 downto 0) := to_unsigned(0, 7);
    
--    signal ENABLE_A      : std_logic := '0'; -- Variabile per abilitare all'accesso
--    signal ENABLE_B      : std_logic := '0'; -- alla memoria il moltiplicatore

    
--    signal READING_DONE_A : std_logic := '0'; -- Variabile per dichiare al processo di
--    signal READING_DONE_B : std_logic := '0'; -- gestione del moltiplicatore che si e' letto
--                                              -- il dato in TMP_RESULT
                           
--    signal M_STATE_A : MULTIPLIER_STATE := ACCEPTING;
--    signal M_STATE_B : MULTIPLIER_STATE := ACCEPTING;

--    signal TMP_RESULT_A : std_logic_vector(63 downto 0) := std_logic_vector(to_unsigned(0,64));
--    signal TMP_RESULT_B : std_logic_vector(63 downto 0) := std_logic_vector(to_unsigned(0,64));
--    signal ROW_IDX_A : unsigned(6 downto 0) := to_unsigned(0, 7); -- servono come variabili temporanee...
--    signal ROW_IDX_B : unsigned(6 downto 0) := to_unsigned(0, 7);
--    signal COL_IDX_A : unsigned(6 downto 0) := to_unsigned(0, 7); -- servono come variabili temporanee...
--    signal COL_IDX_B : unsigned(6 downto 0) := to_unsigned(0, 7);

--begin
    
--    PROCESS_CONTROL:  process(CLOCK, RESET)
--        variable GLOBAL_ENABLE : std_logic := '0'; -- Qualcuno sta accendo alla memoria?
--    begin
--        if RESET = '1' then
--            CURRENT_ROW <= to_unsigned(0,7);
--            CURRENT_COL <= to_unsigned(0,7);
--            PC_STATE <= IDLING;
--            D_ADDR <= std_logic_vector(to_unsigned( 0, 14));
--            C_ADDR <= std_logic_vector(to_unsigned( 0, 14));
--            C_DOUT <= std_logic_vector(to_unsigned( 0, 64));
--            D_DOUT <= std_logic_vector(to_unsigned( 0, 64));
--            C_WE <= '0';
--            ENABLE_A <= '0';
--            ENABLE_B <= '0';
--        elsif rising_edge(CLOCK) then
--             case PC_STATE is
--                when IDLING =>
--                    D_ADDR <= std_logic_vector(to_unsigned( 0, 14));
--                    D_WE <= '0';
--                    if D_READY = '1' then
--                        if D_DIN(1 downto 0) = "10" then
--                            -- Assumo che A e B siano state riempite correttamente.
--                            CURRENT_ROW <= to_unsigned(0,7);
--                            CURRENT_COL <= to_unsigned(0,7);
--                            PC_STATE <= PROCESSING;
--                        else
--                            D_ADDR <= std_logic_vector(to_unsigned( 0, 14));
--                            D_WE <= '0';
--                            PC_STATE <= IDLING; 
--                        end if;
--                    else
--                        D_ADDR <= std_logic_vector(to_unsigned( 0, 14));
--                        D_WE <= '0';
--                        PC_STATE <= IDLING;
--                    end if;
                    
--                when PROCESSING =>
--                    GLOBAL_ENABLE := ENABLE_A or ENABLE_B;
--                    if CURRENT_COL = size and CURRENT_ROW = size then
--                        PC_STATE <= DONE;
--                    elsif M_STATE_A = ACCEPTING and GLOBAL_ENABLE = '0' then
--                        ENABLE_A <= '1'; 
--                    elsif M_STATE_B = ACCEPTING and GLOBAL_ENABLE = '0' then
--                        ENABLE_B <= '1';
--                    elsif M_STATE_A = DONE then
--                        -- Trasferisco il risultato in C
--                        -- Comunico ad A che ho finito e puo' tornare in IDLE
                        
--                        C_WE <= '1'; -- Comunico a C di voler scrivere
--                        C_ADDR <= std_logic_vector(ROW_IDX_A + COL_IDX_A * size);
--                        C_DOUT <= TMP_RESULT_A;
--                        READING_DONE_A <= '0';
--                        PC_STATE <= LOAD;                 
--                    elsif M_STATE_B = DONE then
--                        -- Trasferisco il risultato in C
--                        -- Comunico a B che ho finito e puo' tornare in IDLE
                                                
--                        C_WE <= '1'; -- Comunico a C di voler scrivere
--                        C_ADDR <= std_logic_vector(ROW_IDX_B + COL_IDX_B * size);
--                        C_DOUT <= TMP_RESULT_B;
--                        READING_DONE_A <= '0';
--                        PC_STATE <= LOAD;
--                    else
--                        PC_STATE <= PROCESSING;
--                    end if;
                
--                WHEN LOAD =>
--                    if C_WD = '1' then 
--                        PC_STATE <= PROCESSING;
--                    else
--                        PC_STATE <= LOAD;
--                    end if;
                       
--                when DONE =>
--                    D_WE <= '1';
--                    D_DOUT <= (62 downto 0 => '0') & '1';
--                    if D_DE = '0' then
--                        PC_STATE <= DONE;
--                    else
--                        PC_STATE <= IDLING;
--                    end if;
--                when others =>
--                    CURRENT_ROW <= to_unsigned(0,7);
--                    CURRENT_COL <= to_unsigned(0,7);
--                    PC_STATE <= IDLING;
--                    D_ADDR <= std_logic_vector(to_unsigned( 0, 14));
--                    C_ADDR <= std_logic_vector(to_unsigned( 0, 14));
--                    C_DOUT <= std_logic_vector(to_unsigned( 0, 64));
--                    D_DOUT <= std_logic_vector(to_unsigned( 0, 64));
--                    C_WE <= '0';      
--             end case;
--        end if;
--    end process;
    
--    MULTIPLIER_A : process(CLOCK, RESET)
--    begin
--        if RESET = '1' then
--            ROW_SELECT_A <= std_logic_vector(TO_UNSIGNED( 0, 7));
--            COL_SELECT_A <= std_logic_vector(TO_UNSIGNED( 0, 7));
--            TMP_RESULT_A <= std_logic_vector(TO_UNSIGNED( 0, 64));
--            START_A <= '0';
--            M_STATE_A <= ACCEPTING;
--        elsif rising_edge(CLOCK) then
--            case M_STATE_A is
--                when ACCEPTING =>
--                    if ENABLE_A = '1' then
--                        ROW_SELECT_A <= std_logic_vector(CURRENT_ROW);
--                        COL_SELECT_A <= std_logic_vector(CURRENT_COL);
--                        ROW_IDX_A <= CURRENT_ROW;
--                        COL_IDX_A <= CURRENT_COL;
                        
--                        if CURRENT_COL < size then
--                            CURRENT_COL <= CURRENT_COL + 1;
--                        else
--                            CURRENT_COL <= TO_UNSIGNED (0, 7);
--                            CURRENT_ROW <= CURRENT_ROW + 1;
--                        end if;
                        
--                        START_A <= '1';
--                        M_STATE_A <= COMPUTING;
--                    else 
--                        M_STATE_A <= ACCEPTING;
--                    end if;
--                when COMPUTING =>
--                    START_A <= '0';
--                    if ENABLE_A = '1' and CL_DONE_A = '1' then
--                         -- Aspetto che il moltiplicatore finisca di leggere prima di restituire il controllo del BUS
--                         ENABLE_A <= '0';
--                         M_STATE_A <= COMPUTING;
--                    elsif ENABLE_A = '1' and CL_DONE_A = '0' then
--                        M_STATE_A <= COMPUTING;
--                    elsif DONE_A = '1' then
--                        TMP_RESULT_A <= RESULT_A;
--                        M_STATE_A <= DONE;
--                    else
--                        M_STATE_A <= COMPUTING;
--                    end if;       
--                when DONE =>
--                    if READING_DONE_A = '1' then
--                        READING_DONE_A <= '0';
--                        M_STATE_A <= ACCEPTING;
--                    else
--                        M_STATE_A <= DONE;
--                    end if;    
--                when others =>
--                    ROW_SELECT_A <= std_logic_vector(TO_UNSIGNED (0, 7));
--                    COL_SELECT_A <= std_logic_vector(TO_UNSIGNED (0, 7));
--                    START_A <= '0';
--                    M_STATE_A <= ACCEPTING;
--            end case;         
--        end if;
--    end process;
    
--    MULTIPLIER_B : process(CLOCK, RESET)
--    begin
--        if RESET = '1' then
--            ROW_SELECT_B <= std_logic_vector(TO_UNSIGNED( 0, 7));
--            COL_SELECT_B <= std_logic_vector(TO_UNSIGNED( 0, 7));
--            TMP_RESULT_B <= std_logic_vector(TO_UNSIGNED( 0, 64));
--            START_B <= '0';
--            M_STATE_B <= ACCEPTING;
--        elsif rising_edge(CLOCK) then
--            case M_STATE_B is
--                when ACCEPTING =>
--                    if ENABLE_B = '1' then
--                        ROW_SELECT_B <= std_logic_vector(CURRENT_ROW);
--                        COL_SELECT_B <= std_logic_vector(CURRENT_COL);
--                        ROW_IDX_B <= CURRENT_ROW;
--                        COL_IDX_B <= CURRENT_COL;
--                        if CURRENT_COL < size then
--                            CURRENT_COL <= CURRENT_COL + 1;
--                        else
--                            CURRENT_COL <= TO_UNSIGNED (0, 7);
--                            CURRENT_ROW <= CURRENT_ROW + 1;
--                        end if;
--                        START_B <= '1';
--                        M_STATE_B <= COMPUTING;
--                    else 
--                        M_STATE_B <= ACCEPTING;
--                    end if;
--                when COMPUTING =>
--                    START_B <= '0';
--                    if ENABLE_B = '1' and CL_DONE_B= '1' then
--                         -- Aspetto che il moltiplicatore finisca di leggere prima di restituire il controllo del BUS
--                         ENABLE_B <= '0';
--                         M_STATE_B <= COMPUTING;
--                    elsif ENABLE_B = '1' and CL_DONE_B = '0' then
--                        M_STATE_B <= COMPUTING;               
--                    elsif DONE_B = '1' then
--                        TMP_RESULT_B <= RESULT_B;
--                        M_STATE_B <= DONE;
--                    else
--                        M_STATE_B <= COMPUTING;
--                    end if;       
--                when DONE =>
--                    if READING_DONE_B = '1' then
--                        READING_DONE_B <= '0';
--                        M_STATE_B <= ACCEPTING;
--                    else
--                        M_STATE_B <= DONE;
--                    end if;    
--                when others =>
--                    ROW_SELECT_B <= std_logic_vector(TO_UNSIGNED (0, 7));
--                    COL_SELECT_B <= std_logic_vector(TO_UNSIGNED (0, 7));
--                    START_B <= '0';
--                    M_STATE_B <= ACCEPTING;
--            end case;         
--        end if;
--    end process;
--end v0;
