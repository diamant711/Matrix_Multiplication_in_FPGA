----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/23/2025 04:11:48 PM
-- Design Name: 
-- Module Name: TB_MULTIPLIER - Behavioral
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

entity TB_MULTIPLIER is
end TB_MULTIPLIER;

architecture Behavioral of TB_MULTIPLIER is
    -- Component declaration
    component MULTIPLIER
        Port (
            CLOCK        : in  std_logic;
            RESET        : in  std_logic;
            ROW_SELECT   : in  std_logic_vector(6 downto 0);
            COL_SELECT   : in  std_logic_vector(6 downto 0);
            ADATA        : in  std_logic_vector(63 downto 0);
            AADDR        : out std_logic_vector(13 downto 0);
            GETA         : out std_logic;
            READYA       : in  std_logic;
            BDATA        : in  std_logic_vector(63 downto 0);
            BADDR        : out std_logic_vector(13 downto 0);
            GETB         : out std_logic;
            READYB       : in  std_logic;
            DOUT         : out std_logic_vector(63 downto 0);
            DONE         : out std_logic;
            START        : in  std_logic
        );
    end component;

    -- Signals
    signal CLOCK      : std_logic := '0';
    signal RESET      : std_logic := '0';
    signal ROW_SELECT : std_logic_vector(6 downto 0) := (others => '0');
    signal COL_SELECT : std_logic_vector(6 downto 0) := (others => '0');
    signal ADATA      : std_logic_vector(63 downto 0) := (others => '0');
    signal AADDR      : std_logic_vector(13 downto 0);
    signal GETA       : std_logic;
    signal READYA     : std_logic := '0';
    signal BDATA      : std_logic_vector(63 downto 0) := (others => '0');
    signal BADDR      : std_logic_vector(13 downto 0);
    signal GETB       : std_logic;
    signal READYB     : std_logic := '0';
    signal DOUT       : std_logic_vector(63 downto 0);
    signal DONE       : std_logic;
    signal START      : std_logic := '0';

    constant clk_period : time := 1 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: MULTIPLIER
        port map (
            CLOCK      => CLOCK,
            RESET      => RESET,
            ROW_SELECT => ROW_SELECT,
            COL_SELECT => COL_SELECT,
            ADATA      => ADATA,
            AADDR      => AADDR,
            GETA       => GETA,
            READYA     => READYA,
            BDATA      => BDATA,
            BADDR      => BADDR,
            GETB       => GETB,
            READYB     => READYB,
            DOUT       => DOUT,
            DONE       => DONE,
            START      => START
        );

    -- Clock generation
    clk_process : process
    begin
        while true loop
            CLOCK <= '0';
            wait for clk_period/2;
            CLOCK <= '1';
            wait for clk_period/2;
        end loop;
        wait;
    end process;

    -- Stimulus
    stim_proc : process
        variable i : integer;
        variable cycle_count : integer := 0;
    begin
        -- Reset
        RESET <= '1';
        wait for 20 ns;
        RESET <= '0';
        wait for 20 ns;

        -- Loop su righe e colonne
        --for r in 0 to 2 loop
            --for c in 0 to 2 loop
                report "Starting row=" & integer'image(0) & " col=" & integer'image(0);
                ROW_SELECT <= std_logic_vector(to_unsigned(0, 7));
                COL_SELECT <= std_logic_vector(to_unsigned(0, 7));
                START <= '1';
                
                -- Simulazione del comportamento della memoria
                for i in 0 to 99 loop
                    wait until GETA = '1' and GETB = '1';
                    START <= '0';
                    
                    -- Aspetta 1 ciclo, poi fornisce i dati
                    --wait for CLK_PERIOD;
                    
                    ADATA  <= x"3FF0000000000000"; -- 1.0
                    BDATA  <= x"3FF0000000000000"; -- 1.0
                    READYA <= '1';
                    READYB <= '1';

                    -- Aspetta che scriva
                    wait until GETA = '0' and GETB = '0';

                    -- Simula fine scrittura
                    ADATA <= (others => '0');
                    BDATA <= (others => '0');
                    READYA <= '0';
                    READYB <= '0';

                end loop;
                -- Attesa fine
                wait until DONE = '1';
                START <= '0';
                wait for 2 * CLK_PERIOD;
            --end loop;
        --end loop;

        report "SIMULAZIONE COMPLETATA CON SUCCESSO";
        wait;
    end process;
end Behavioral;
