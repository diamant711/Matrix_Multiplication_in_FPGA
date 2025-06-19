----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/09/2025 06:05:48 PM
-- Design Name: 
-- Module Name: TB_CACHE_LOADER - v0
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

entity TB_CACHE_LOADER is
end TB_CACHE_LOADER;

architecture sim of TB_CACHE_LOADER is

    -- Component declaration of the unit under test (UUT)
    component CACHE_LOADER
        port (
            clk         : in std_logic;
            rst         : in std_logic;
            start       : in std_logic;
            row_select  : in unsigned(6 downto 0);
            col_select  : in unsigned(6 downto 0);
            A_data      : in std_logic_vector(63 downto 0);
            A_addr      : out unsigned(13 downto 0);
            B_data      : in std_logic_vector(63 downto 0);
            B_addr      : out unsigned(13 downto 0);
            GETA        : out std_logic;
            GETB        : out std_logic;
            ROW_we      : out std_logic;
            ROW_addr    : out unsigned(6 downto 0);
            ROW_data    : out std_logic_vector(63 downto 0);
            COL_we      : out std_logic;
            COL_addr    : out unsigned(6 downto 0);
            COL_data    : out std_logic_vector(63 downto 0);
            ended        : out std_logic
        );
    end component;

    -- Signals
    signal clk         : std_logic := '0';
    signal rst         : std_logic := '0';
    signal start       : std_logic := '0';
    signal row_select  : unsigned(6 downto 0);
    signal col_select  : unsigned(6 downto 0);
    signal A_data      : std_logic_vector(63 downto 0);
    signal A_addr      : unsigned(13 downto 0);
    signal B_data      : std_logic_vector(63 downto 0);
    signal B_addr      : unsigned(13 downto 0);
    signal ROW_we      : std_logic;
    signal ROW_addr    : unsigned(6 downto 0);
    signal ROW_data    : std_logic_vector(63 downto 0);
    signal COL_we      : std_logic;
    signal COL_addr    : unsigned(6 downto 0);
    signal COL_data    : std_logic_vector(63 downto 0);
    signal ended        : std_logic;

    -- Fake memories for A and B
    type matrix_type is array(0 to 9999) of std_logic_vector(63 downto 0);
    signal A_mem : matrix_type;
    signal B_mem : matrix_type;

begin

    -- Clock process
    clk_process : process
    begin
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
    end process;

    -- UUT instantiation
    uut: CACHE_LOADER
        port map (
            clk => clk,
            rst => rst,
            start => start,
            row_select => row_select,
            col_select => col_select,
            A_data => A_data,
            A_addr => A_addr,
            B_data => B_data,
            B_addr => B_addr,
            ROW_we => ROW_we,
            ROW_addr => ROW_addr,
            ROW_data => ROW_data,
            COL_we => COL_we,
            COL_addr => COL_addr,
            COL_data => COL_data,
            ended => ended
        );

    -- Stimulus process
    stim_proc: process
    begin
        -- Init
        rst <= '1';
        wait for 20 ns;
        rst <= '0';

        -- Inizializza memorie A e B con valori noti
        for i in 0 to 9999 loop
            A_mem(i) <= std_logic_vector(to_unsigned(i, 64));
            B_mem(i) <= std_logic_vector(to_unsigned(10000 + i, 64));
        end loop;

        -- Imposta riga 2 e colonna 3 come selezione
        row_select <= to_unsigned(2, 7);  -- riga 2
        col_select <= to_unsigned(3, 7);  -- colonna 3

        wait for 20 ns;
        start <= '1';
        wait for 10 ns;
        start <= '0';

        wait until ended = '1';
        wait for 100 ns;

        -- Fine simulazione
        assert false report "Simulazione completata." severity failure;
    end process;

    -- Collegamento delle memorie a A_data e B_data (read-only)
    A_data <= A_mem(to_integer(A_addr));
    B_data <= B_mem(to_integer(B_addr));

end sim;
