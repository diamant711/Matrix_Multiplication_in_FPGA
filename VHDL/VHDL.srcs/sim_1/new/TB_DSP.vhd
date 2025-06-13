library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Testbench senza porte
entity TB_DSP is
end TB_DSP;

architecture behavior of TB_DSP is

    -- Parametri del clock
    constant clk_period : time := 10 ns;

    -- Segnali di test
    signal DINA : STD_LOGIC_VECTOR (63 downto 0);
    signal DINB : STD_LOGIC_VECTOR (63 downto 0);
    signal DOUT : STD_LOGIC_VECTOR (63 downto 0);
    signal RESET : STD_LOGIC;
    signal CLOCK : STD_LOGIC;
    signal GETN : STD_LOGIC;
    signal DAREADY : STD_LOGIC;
    signal DBREADY : STD_LOGIC;
    signal START : STD_LOGIC;
    signal RDY : STD_LOGIC;
    signal DONE : STD_LOGIC;
    signal MPTY : STD_LOGIC;

begin

    --------------------------------------------------------------------
    -- Clock process: genera un clock con periodo definito
    --------------------------------------------------------------------
    clk_process : process
    begin
        while true loop
            CLOCK <= '0';
            wait for clk_period / 2;
            CLOCK <= '1';
            wait for clk_period / 2;
        end loop;
    end process clk_process;

    --------------------------------------------------------------------
    -- Reset iniziale
    --------------------------------------------------------------------
    rst_process : process
    begin
        RESET <= '1';
        wait for 20 ns;
        RESET <= '0';
        wait;
    end process rst_process;

    --------------------------------------------------------------------
    -- Istanziamento del DUT (da modificare con il tuo modulo)
    --------------------------------------------------------------------
        uut : entity work.DSP
            port map ( 
                RESET => RESET,
                CLOCK => CLOCK,
                DINA => DINA,
                DINB => DINB,
                DOUT => DOUT,
                GETN => GETN,
                DAREADY => DAREADY,
                DBREADY => DBREADY,
                START => START,
                RDY => RDY,
                DONE => DONE,
                MPTY => MPTY
            );

    --------------------------------------------------------------------
    -- Stimoli di esempio (modifica o estendi)
    --------------------------------------------------------------------
    stim_proc : process
    begin
        -- Attendi il reset
        wait until RESET = '0';

        -- Simulazione
        DAREADY <= '1';
        DBREADY <= '1';
        DINA <= x"3FF0000000000000";
        DINB <= x"4000000000000000";
        MPTY <= '1';
        wait until DONE = '1';

        -- Fine simulazione
        wait;
    end process stim_proc;

end behavior;
