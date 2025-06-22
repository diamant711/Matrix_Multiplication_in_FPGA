library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TB_CACHE_LOADER is
end TB_CACHE_LOADER;

architecture behavior of TB_CACHE_LOADER is

    -- Component under test
    component CACHE_LOADER
        Port (
            clk          : in  std_logic;
            rst          : in  std_logic;
            start        : in  std_logic;
            row_select   : in  unsigned(6 downto 0);
            col_select   : in  unsigned(6 downto 0);
            ended        : out std_logic;
            A_data       : in  std_logic_vector(63 downto 0);
            A_addr       : out unsigned(13 downto 0);
            GETA         : out std_logic;
            READYA       : in std_logic;
            B_data       : in  std_logic_vector(63 downto 0);
            B_addr       : out unsigned(13 downto 0);
            GETB         : out std_logic;
            READYB       : in std_logic;
            ROW_we       : out std_logic;
            ROW_addr     : out unsigned(6 downto 0);
            ROW_data     : out std_logic_vector(63 downto 0);
            ROW_full     : in std_logic;
            ROW_w_done   : in std_logic;
            COL_we       : out std_logic;
            COL_addr     : out unsigned(6 downto 0);
            COL_data     : out std_logic_vector(63 downto 0);
            COL_full     : in std_logic;
            COL_w_done   : in std_logic
        );
    end component;

    -- Clock period
    constant CLK_PERIOD : time := 1 ns;

    -- Signals
    signal clk         : std_logic := '0';
    signal rst         : std_logic := '0';
    signal start       : std_logic := '0';
    signal row_select  : unsigned(6 downto 0) := (others => '0');
    signal col_select  : unsigned(6 downto 0) := (others => '0');
    signal ended       : std_logic;
    signal A_data      : std_logic_vector(63 downto 0) := (others => '0');
    signal A_addr      : unsigned(13 downto 0);
    signal GETA        : std_logic;
    signal READYA      : std_logic := '0';
    signal B_data      : std_logic_vector(63 downto 0) := (others => '0');
    signal B_addr      : unsigned(13 downto 0);
    signal GETB        : std_logic;
    signal READYB      : std_logic := '0';
    signal ROW_we      : std_logic;
    signal ROW_addr    : unsigned(6 downto 0);
    signal ROW_data    : std_logic_vector(63 downto 0);
    signal ROW_full    : std_logic := '0';
    signal ROW_w_done  : std_logic := '0';
    signal COL_we      : std_logic;
    signal COL_addr    : unsigned(6 downto 0);
    signal COL_data    : std_logic_vector(63 downto 0);
    signal COL_full    : std_logic := '0';
    signal COL_w_done  : std_logic := '0';

begin

    -- Clock generation
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- Instantiate the Unit Under Test
    uut: CACHE_LOADER
        port map (
            clk => clk,
            rst => rst,
            start => start,
            row_select => row_select,
            col_select => col_select,
            ended => ended,
            A_data => A_data,
            A_addr => A_addr,
            GETA => GETA,
            READYA => READYA,
            B_data => B_data,
            B_addr => B_addr,
            GETB => GETB,
            READYB => READYB,
            ROW_we => ROW_we,
            ROW_addr => ROW_addr,
            ROW_data => ROW_data,
            ROW_full => ROW_full,
            ROW_w_done => ROW_w_done,
            COL_we => COL_we,
            COL_addr => COL_addr,
            COL_data => COL_data,
            COL_full => COL_full,
            COL_w_done => COL_w_done
        );

    -- Stimulus
    stim_proc : process
        variable i : integer;
        variable cycle_count : integer := 0;
    begin
        -- Reset
        rst <= '1';
        wait for 20 ns;
        rst <= '0';
        wait for 20 ns;

        -- Loop su righe e colonne
        --for r in 0 to 2 loop
            --for c in 0 to 2 loop
                report "Starting row=" & integer'image(0) & " col=" & integer'image(0);
                row_select <= to_unsigned(0, 7);
                col_select <= to_unsigned(0, 7);
                start <= '1';

                -- Simulazione del comportamento della memoria
                for i in 0 to 99 loop
                    wait until GETA = '1' and GETB = '1';
                    ROW_w_done <= '0';
                    COL_w_done <= '0';
                    
                    -- Aspetta 1 ciclo, poi fornisce i dati
                    --wait for CLK_PERIOD;
                    
                    A_data <= std_logic_vector(to_unsigned(1000 + i, 64));  -- dummy data
                    B_data <= std_logic_vector(to_unsigned(2000 + i, 64));
                    READYA <= '1';
                    READYB <= '1';

                    -- Aspetta che scriva
                    wait until GETA = '0' and GETB = '0';


                    -- Verifica indirizzi A e B
                    assert A_addr = to_unsigned(0 * 100 + i, 14)
                        report "Errore A_addr: atteso " & integer'image(0 * 100 + i) &
                               " ma ricevuto " & integer'image(to_integer(A_addr))
                        severity error;

                    assert B_addr = to_unsigned(i * 100 + 0, 14)
                        report "Errore B_addr: atteso " & integer'image(i * 100 + 0) &
                               " ma ricevuto " & integer'image(to_integer(B_addr))
                        severity error;

                    -- Simula fine scrittura
                    A_data <= (others => '0');
                    B_data <= (others => '0');
                    READYA <= '0';
                    READYB <= '0';
                    ROW_w_done <= '1';
                    COL_w_done <= '1';
                end loop;
                COL_full <= '1';
                ROW_full <= '1';
                -- Attesa fine
                wait until ended = '1';
                start <= '0';
                wait for 2 * CLK_PERIOD;
            --end loop;
        --end loop;

        report "SIMULAZIONE COMPLETATA CON SUCCESSO";
        wait;
    end process;

end behavior;
