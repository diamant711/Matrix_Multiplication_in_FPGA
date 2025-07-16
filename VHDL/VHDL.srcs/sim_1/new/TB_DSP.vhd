library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Testbench senza porte
entity TB_DSP is
end TB_DSP;

architecture behavior of TB_DSP is

    -- Parametri del clock
    constant clk_period : time := 1 ns;

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
    signal DONE : STD_LOGIC;
    signal MPTY : STD_LOGIC;

begin

    clk_process : process
    begin
        while true loop
            CLOCK <= '0';
            wait for clk_period / 2;
            CLOCK <= '1';
            wait for clk_period / 2;
        end loop;
    end process clk_process;
    
    rst_process : process
    begin
        RESET <= '1';
        wait for 20 ns;
        RESET <= '0';
        wait;
    end process rst_process;
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
                DONE => DONE,
                MPTY => MPTY
            );

    stim_proc : process
    begin
        START <= '0';
        MPTY <= '0';
        DAREADY <= '0';
        DBREADY <= '0';
        DINA <= (others => '0');
        DINB <= (others => '0');
        
        -- Attendi il reset
        wait until RESET = '0';
        wait for 20 ns;
    
        -- Avvia la DSP
        START <= '1';
        wait until GETN = '1';
        START <= '0';
        DINA <= x"3FF0000000000000";
        DINB <= x"3FF0000000000000";
        DAREADY <= '1';
        DBREADY <= '1';
        -- Invio di 100 coppie di dati nulli
--        for i in 0 to 87 loop
--            wait until GETN = '1';
--        end loop;
--        wait until GETN = '1';
--        wait until GETN = '0';
        -- Disattiva i segnali dopo l'invio
        MPTY <= '1';
--        DAREADY <= '0';
--        DBREADY <= '0';
    
        -- Attendi completamento
        wait until DONE = '1';
        MPTY <= '0';
    
        -- Fine simulazione
        wait;
    end process stim_proc;

--    kill_switch : process
--    begin
--        wait for 1000 ns; -- Timeout di sicurezza (modifica secondo le tue esigenze)
--        assert false report "Simulazione terminata per timeout (kill switch attivato)." severity failure;
--    end process kill_switch;

end behavior;
