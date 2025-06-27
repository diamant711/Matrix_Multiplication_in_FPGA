----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/27/2025 11:45:31 AM
-- Design Name: 
-- Module Name: TOP - v0
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

entity TOP is
    Port ( UART_D_IN : in STD_LOGIC;
           UART_D_OUT : out STD_LOGIC;
           Reset : in STD_LOGIC;
           Clock_100MHz : in STD_LOGIC;
           INNER_PROD_DONE : out STD_LOGIC
    );
end TOP;

architecture v0 of TOP is
    component PC_INTERFACE is
        Port (
            Clock : in std_logic;
            Reset : in std_logic;
            
            DATA_OUT_A : out std_logic_vector(63 downto 0);
            DATA_ADDR_A : in std_logic_vector(13 downto 0);
            DATA_VALID_A : out std_logic;
            DATA_ADDR_VALID_A : in std_logic;
            
            DATA_OUT_B : out std_logic_vector(63 downto 0);
            DATA_ADDR_B : in std_logic_vector(13 downto 0);
            DATA_VALID_B : out std_logic;
            DATA_ADDR_VALID_B : in std_logic;
            
            DATA_IN_C : in std_logic_vector(63 downto 0);
            DATA_ADDR_C : in std_logic_vector(13 downto 0);
            DATA_VALID_C : out std_logic;
            DATA_ADDR_VALID_C : in std_logic;
            
            DATA_OUT_D : out std_logic_vector(63 downto 0);
            
            D_IN : in STD_LOGIC; 
            D_OUT : out std_logic
            );
    end component;
    component CONTROLLER is
        Port ( 
            CLOCK : in std_logic;
            RESET : in std_logic;
            AND_IT_S_ALL_FOLKS  : out std_logic;
            D_DIN   : in  std_logic_vector(63 downto 0);
            ROW_SELECT_A : out std_logic_vector(6 downto 0);
            COL_SELECT_A : out std_logic_vector(6 downto 0);
            START_A      : out std_logic;
            DONE_A       : in  std_logic; 
            RESULT_A     : in  std_logic_vector(63 downto 0);
            CL_DONE_A    : in  std_logic;
            ROW_SELECT_B : out std_logic_vector(6 downto 0);
            COL_SELECT_B : out std_logic_vector(6 downto 0);
            START_B      : out std_logic;
            DONE_B       : in  std_logic;
            RESULT_B     : in  std_logic_vector(63 downto 0);
            CL_DONE_B    : in  std_logic;
            C_ADDR : out std_logic_vector( 13 downto 0 );
            C_DOUT : out std_logic_vector ( 63 downto 0 );    
            C_WE   : out std_logic;
            C_WD   : in  std_logic
        );
    end component;
    component MULTIPLIER is
        Port (
            CLOCK        : in  std_logic;
            RESET        : in  std_logic;
            ROW_SELECT   : in  std_logic_vector(6 downto 0);
            COL_SELECT   : in  std_logic_vector(6 downto 0);
            ADATA        : in  std_logic_vector(63 downto 0);
            AADDR        : out std_logic_vector(13 downto 0);
            GETA         : out std_logic;
            READYA       : in std_logic;
            BDATA        : in  std_logic_vector(63 downto 0);
            BADDR        : out std_logic_vector(13 downto 0);
            GETB         : out std_logic;
            READYB       : in std_logic;
            DOUT         : out STD_LOGIC_VECTOR (63 downto 0);
            DONE         : out std_logic;
            CL_DONE      : out std_logic;
            START        : in  std_logic
        );
    end component;
    signal DATA_OUT_A : std_logic_vector(63 downto 0);
    signal DATA_ADDR_A_PC : std_logic_vector(13 downto 0);
    signal DATA_VALID_A : std_logic;
    signal DATA_ADDR_VALID_A_PC : std_logic;
    signal DATA_OUT_B : std_logic_vector(63 downto 0);
    signal DATA_ADDR_B_PC : std_logic_vector(13 downto 0);
    signal DATA_VALID_B : std_logic;
    signal DATA_ADDR_VALID_B_PC : std_logic;     
    signal DATA_IN_C : std_logic_vector(63 downto 0);
    signal DATA_ADDR_C : std_logic_vector(13 downto 0);
    signal DATA_VALID_C : std_logic;
    signal DATA_ADDR_VALID_C : std_logic;       
    signal DATA_OUT_D : std_logic_vector(63 downto 0);
    
    signal ROW_SELECT_A : std_logic_vector(6 downto 0);
    signal COL_SELECT_A : std_logic_vector(6 downto 0);
    signal START_A : std_logic;
    signal DONE_A : std_logic; 
    signal RESULT_A : std_logic_vector(63 downto 0);
    signal CL_DONE_A : std_logic;
    signal ROW_SELECT_B : std_logic_vector(6 downto 0);
    signal COL_SELECT_B : std_logic_vector(6 downto 0);
    signal START_B : std_logic;
    signal DONE_B : std_logic;
    signal RESULT_B : std_logic_vector(63 downto 0);
    signal CL_DONE_B : std_logic;

    signal DATA_ADDR_B_MA : std_logic_vector(13 downto 0);
    signal DATA_ADDR_A_MA : std_logic_vector(13 downto 0);
    signal DATA_ADDR_VALID_B_MA : std_logic;
    signal DATA_ADDR_VALID_A_MA : std_logic;
    signal DATA_ADDR_B_MB : std_logic_vector(13 downto 0);
    signal DATA_ADDR_A_MB : std_logic_vector(13 downto 0);
    signal DATA_ADDR_VALID_B_MB : std_logic;
    signal DATA_ADDR_VALID_A_MB : std_logic;

begin    
    PC: PC_INTERFACE
        port map (
            Clock => Clock_100MHz,
            Reset => Reset,
            DATA_OUT_A => DATA_OUT_A,
            DATA_ADDR_A => DATA_ADDR_A_PC,
            DATA_VALID_A => DATA_VALID_A,
            DATA_ADDR_VALID_A => DATA_ADDR_VALID_A_PC,
            DATA_OUT_B => DATA_OUT_B,
            DATA_ADDR_B => DATA_ADDR_B_PC,
            DATA_VALID_B => DATA_VALID_B,
            DATA_ADDR_VALID_B => DATA_ADDR_VALID_B_PC,
            DATA_IN_C => DATA_IN_C,
            DATA_ADDR_C => DATA_ADDR_C,
            DATA_VALID_C => DATA_VALID_C,
            DATA_ADDR_VALID_C => DATA_ADDR_VALID_C,
            DATA_OUT_D => DATA_OUT_D,
            D_IN => UART_D_IN,
            D_OUT => UART_D_OUT
        );
    CNT: CONTROLLER
        port map (
            CLOCK => Clock_100MHz,
            RESET => Reset,
            AND_IT_S_ALL_FOLKS => INNER_PROD_DONE,
            D_DIN => DATA_OUT_D,
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
            C_ADDR => DATA_ADDR_C,
            C_DOUT => DATA_IN_C, 
            C_WE => DATA_ADDR_VALID_C, --Compatibile?
            C_WD => DATA_VALID_C --Compatibile?
        );
    A: MULTIPLIER
        port map (
            CLOCK => Clock_100MHz,
            RESET => Reset,
            ROW_SELECT => ROW_SELECT_A,
            COL_SELECT => COL_SELECT_A,
            ADATA => DATA_OUT_A,
            AADDR => DATA_ADDR_A_MA,
            GETA => DATA_ADDR_VALID_A_MA, --Compatibile?
            READYA => DATA_VALID_A, --Compatibile?
            BDATA => DATA_OUT_B,
            BADDR => DATA_ADDR_B_MA,
            GETB => DATA_ADDR_VALID_B_MA, --Compatibile?
            READYB => DATA_VALID_B, --Compatibile?
            DOUT => RESULT_A,
            DONE => DONE_A,
            CL_DONE => CL_DONE_A,
            START => START_A
        );
    B: MULTIPLIER
        port map (
            CLOCK => Clock_100MHz,
            RESET => Reset,
            ROW_SELECT => ROW_SELECT_B,
            COL_SELECT => COL_SELECT_B,
            ADATA => DATA_OUT_A,
            AADDR => DATA_ADDR_A_MB,
            GETA => DATA_ADDR_VALID_A_MB, --Compatibile?
            READYA => DATA_VALID_A, --Compatibile?
            BDATA => DATA_OUT_B,
            BADDR => DATA_ADDR_B_MB,
            GETB => DATA_ADDR_VALID_B_MB, --Compatibile?
            READYB => DATA_VALID_B, --Compatibile?
            DOUT => RESULT_B,
            DONE => DONE_B,
            CL_DONE => CL_DONE_B,
            START => START_B
        );
    DATA_ADDR_B_PC <= DATA_ADDR_B_MA or DATA_ADDR_B_MB;
    DATA_ADDR_A_PC <= DATA_ADDR_A_MA or DATA_ADDR_A_MB;
    DATA_ADDR_VALID_B_PC <= DATA_ADDR_VALID_B_MA or DATA_ADDR_VALID_B_MB;
    DATA_ADDR_VALID_A_PC <= DATA_ADDR_VALID_A_MA or DATA_ADDR_VALID_A_MB;
end v0;
