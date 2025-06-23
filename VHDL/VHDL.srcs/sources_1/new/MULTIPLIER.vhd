----------------------------------------------------------------------------------
-- Company: Riboldi's little engeneers
-- Engineer: Riccardo Osvaldo Nana e Stefano Pilosio
-- 
-- Create Date: 06/23/2025 02:58:45 PM
-- Design Name: 
-- Module Name: MULTIPLIER - v0
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

entity MULTIPLIER is
    Port (
        CLOCK        : in  std_logic;
        RESET        : in  std_logic;
        ROW_SELECT   : in  std_logic_vector(6 downto 0); -- 7 bit per 0..99
        COL_SELECT   : in  std_logic_vector(6 downto 0); -- 7 bit per 0..99
        ADATA        : in  std_logic_vector(63 downto 0);
        AADDR        : out std_logic_vector(13 downto 0); -- 14 bit per 100*100 = 10,000 celle
        GETA         : out std_logic;
        READYA       : in std_logic;
        BDATA        : in  std_logic_vector(63 downto 0);
        BADDR        : out std_logic_vector(13 downto 0);
        GETB         : out std_logic;
        READYB       : in std_logic;
        DOUT         : out STD_LOGIC_VECTOR (63 downto 0);
        DONE         : out std_logic;
        START        : in  std_logic
    );
end MULTIPLIER;

architecture v0 of MULTIPLIER is
    component CACHE
        Port (
            RESET   : in  STD_LOGIC;
            CLOCK   : in  STD_LOGIC;
            ADDR    : in  STD_LOGIC_VECTOR (6 downto 0);
            WE      : in  STD_LOGIC;
            WDONE   : out STD_LOGIC;
            DIN     : in  STD_LOGIC_VECTOR (63 downto 0);
            DOUT    : out STD_LOGIC_VECTOR (63 downto 0);
            MPTY    : out STD_LOGIC;
            FLL     : out STD_LOGIC;
            DREADY  : out STD_LOGIC;
            NE      : in  STD_LOGIC
        );
    end component;
    component CACHE_LOADER
        Port (
            clk          : in  std_logic;
            rst          : in  std_logic;
            start        : in  std_logic;
            row_select   : in  std_logic_vector(6 downto 0);
            col_select   : in  std_logic_vector(6 downto 0);
            ended        : out std_logic;
            A_data       : in  std_logic_vector(63 downto 0);
            A_addr       : out std_logic_vector(13 downto 0);
            GETA         : out std_logic;
            READYA       : in std_logic;
            B_data       : in  std_logic_vector(63 downto 0);
            B_addr       : out std_logic_vector(13 downto 0);
            GETB         : out std_logic;
            READYB       : in std_logic;
            ROW_we       : out std_logic;
            ROW_addr     : out std_logic_vector(6 downto 0);
            ROW_data     : out std_logic_vector(63 downto 0);
            ROW_full     : in std_logic;
            ROW_w_done   : in std_logic;
            COL_we       : out std_logic;
            COL_addr     : out std_logic_vector(6 downto 0);
            COL_data     : out std_logic_vector(63 downto 0);
            COL_full     : in std_logic;
            COL_w_done   : in std_logic
        );
    end component;
    component DSP
        Port ( 
           RESET : in STD_LOGIC;
           CLOCK : in STD_LOGIC;
           DINA : in STD_LOGIC_VECTOR (63 downto 0);
           DINB : in STD_LOGIC_VECTOR (63 downto 0);
           DOUT : out STD_LOGIC_VECTOR (63 downto 0);
           GETN : out STD_LOGIC;
           DAREADY : in STD_LOGIC;
           DBREADY : in STD_LOGIC;
           START : in STD_LOGIC;
           DONE : out STD_LOGIC;
           MPTY : in STD_LOGIC
        );
    end component;
    
    signal icl_ended : std_logic;
    
    signal irow_we : std_logic;
    signal irow_addr : std_logic_vector(6 downto 0);
    signal irow_din : std_logic_vector(63 downto 0);
    signal irow_full : std_logic;
    signal irow_w_done : std_logic;
    signal irow_dout : std_logic_vector(63 downto 0);
    signal irow_mpty : std_logic;
    signal irow_dready : std_logic;
    
    signal icol_we : std_logic;
    signal icol_addr : std_logic_vector(6 downto 0);
    signal icol_din : std_logic_vector(63 downto 0);
    signal icol_full : std_logic;
    signal icol_w_done : std_logic;
    signal icol_dout : std_logic_vector(63 downto 0);
    signal icol_mpty : std_logic;
    signal icol_dready : std_logic;
    
    signal idsp_ne : std_logic;
    signal idsp_start : std_logic;
    signal idsp_mpty : std_logic;
    
begin

    cl: CACHE_LOADER
        port map (
            clk => CLOCK,
            rst => RESET,
            start => START,
            row_select => ROW_SELECT,
            col_select => COL_SELECT,
            ended => icl_ended,
            A_data => ADATA,
            A_addr => AADDR,
            GETA => GETA,
            READYA => READYA,
            B_data => BDATA,
            B_addr => BADDR,
            GETB => GETB,
            READYB => READYB,
            ROW_we => irow_we,
            ROW_addr => irow_addr,
            ROW_data => irow_din,
            ROW_full => irow_full,
            ROW_w_done => irow_w_done,
            COL_we => icol_we,
            COL_addr => icol_addr,
            COL_data => icol_din,
            COL_full => icol_full,
            COL_w_done => icol_w_done
        );
    row: CACHE
        port map (
            RESET => RESET,
            CLOCK => CLOCK,
            ADDR => irow_addr,
            WE => irow_we,
            WDONE => irow_w_done,
            DIN => irow_din,
            DOUT => irow_dout,
            MPTY => irow_mpty,
            FLL => irow_full,
            DREADY => irow_dready,
            NE => idsp_ne
        );
    col: CACHE
        port map (
            RESET => RESET,
            CLOCK => CLOCK,
            ADDR => icol_addr,
            WE => icol_we,
            WDONE => icol_w_done,
            DIN => icol_din,
            DOUT => icol_dout,
            MPTY => icol_mpty,
            FLL => icol_full,
            DREADY => icol_dready,
            NE => idsp_ne
        );
    alu: DSP
        port map (
           RESET => RESET,
           CLOCK => CLOCK,
           DINA => irow_dout,
           DINB => icol_dout,
           DOUT => DOUT,
           GETN => idsp_ne,
           DAREADY => irow_dready,
           DBREADY => icol_dready,
           START => idsp_start,
           DONE => DONE,
           MPTY => idsp_mpty
        );

    idsp_start <= irow_full and icol_full and icl_ended;
    idsp_mpty <= irow_mpty or icol_mpty;

end v0;
