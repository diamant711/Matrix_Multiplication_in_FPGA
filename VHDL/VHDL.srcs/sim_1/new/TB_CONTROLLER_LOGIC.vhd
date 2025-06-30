library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TB_CONTROLLER_LOGIC is
end TB_CONTROLLER_LOGIC;

architecture tb of TB_CONTROLLER_LOGIC is

    component CONTROLLER_LOGIC
        Port (
            CLOCK : in std_logic;
            RESET : in std_logic;
            D_DIN : in std_logic_vector(63 downto 0);
            AND_IT_S_ALL_FOLKS : out std_logic;
            C_ADDR : out std_logic_vector(13 downto 0);
            C_DOUT : out std_logic_vector(63 downto 0);
            C_WE : out std_logic;
            C_WD : in std_logic;
            CNTRL_CUR_ROW : out unsigned(6 downto 0);
            CNTRL_CUR_COL : out unsigned(6 downto 0);
            CNTRL_ENABLE_A : out std_logic;
            CNTRL_ENABLE_B : out std_logic;
            CNTRL_RES_SAVE_A : out std_logic;
            CNTRL_RES_SAVE_B : out std_logic;
            CNTRL_OCC_A : in std_logic;
            CNTRL_OCC_B : in std_logic;
            CNTRL_WRT_DONE_A : in std_logic;
            CNTRL_WRT_DONE_B : in std_logic;
            CNTRL_MULT_DONE_A : in std_logic;
            CNTRL_MULT_DONE_B : in std_logic;
            TMP_RESULT_A : in std_logic_vector(63 downto 0);
            TMP_RESULT_B : in std_logic_vector(63 downto 0)
        );
    end component;

    -- Signals
    signal CLOCK : std_logic := '0';
    signal RESET : std_logic := '0';
    signal D_DIN : std_logic_vector(63 downto 0) := (others => '0');
    signal AND_IT_S_ALL_FOLKS : std_logic;
    signal C_ADDR : std_logic_vector(13 downto 0);
    signal C_DOUT : std_logic_vector(63 downto 0);
    signal C_WE : std_logic;
    signal C_WD : std_logic := '0';
    signal CNTRL_CUR_ROW : unsigned(6 downto 0);
    signal CNTRL_CUR_COL : unsigned(6 downto 0);
    signal CNTRL_ENABLE_A : std_logic;
    signal CNTRL_ENABLE_B : std_logic;
    signal CNTRL_RES_SAVE_A : std_logic;
    signal CNTRL_RES_SAVE_B : std_logic;
    signal CNTRL_OCC_A : std_logic := '0';
    signal CNTRL_OCC_B : std_logic := '0';
    signal CNTRL_WRT_DONE_A : std_logic := '0';
    signal CNTRL_WRT_DONE_B : std_logic := '0';
    signal CNTRL_MULT_DONE_A : std_logic := '0';
    signal CNTRL_MULT_DONE_B : std_logic := '0';
    signal TMP_RESULT_A : std_logic_vector(63 downto 0) := (others => '0');
    signal TMP_RESULT_B : std_logic_vector(63 downto 0) := std_logic_vector(to_unsigned(10000, 64));

    constant clk_period : time := 1 ns;

begin

    -- Clock generation
    CLOCK <= not CLOCK after clk_period / 2;

    -- Device under test
    DUT: CONTROLLER_LOGIC
        port map (
            CLOCK => CLOCK,
            RESET => RESET,
            D_DIN => D_DIN,
            AND_IT_S_ALL_FOLKS => AND_IT_S_ALL_FOLKS,
            C_ADDR => C_ADDR,
            C_DOUT => C_DOUT,
            C_WE => C_WE,
            C_WD => C_WD,
            CNTRL_CUR_ROW => CNTRL_CUR_ROW,
            CNTRL_CUR_COL => CNTRL_CUR_COL,
            CNTRL_ENABLE_A => CNTRL_ENABLE_A,
            CNTRL_ENABLE_B => CNTRL_ENABLE_B,
            CNTRL_RES_SAVE_A => CNTRL_RES_SAVE_A,
            CNTRL_RES_SAVE_B => CNTRL_RES_SAVE_B,
            CNTRL_OCC_A => CNTRL_OCC_A,
            CNTRL_OCC_B => CNTRL_OCC_B,
            CNTRL_WRT_DONE_A => CNTRL_WRT_DONE_A,
            CNTRL_WRT_DONE_B => CNTRL_WRT_DONE_B,
            CNTRL_MULT_DONE_A => CNTRL_MULT_DONE_A,
            CNTRL_MULT_DONE_B => CNTRL_MULT_DONE_B,
            TMP_RESULT_A => TMP_RESULT_A,
            TMP_RESULT_B => TMP_RESULT_B
        );

    response_a : process
    begin
        wait until CNTRL_ENABLE_A = '1';
        CNTRL_OCC_A <= '1';
        wait for 10 ns;
        CNTRL_WRT_DONE_A <= '1';
        wait until CNTRL_ENABLE_A = '0';
        CNTRL_WRT_DONE_A <= '0';
        wait for 10 ns;
        CNTRL_MULT_DONE_A <= '1';
        TMP_RESULT_A <= std_logic_vector(unsigned(TMP_RESULT_A) + 1);
        wait until CNTRL_RES_SAVE_A = '1';
        CNTRL_MULT_DONE_A <= '0';
        CNTRL_OCC_A <= '0';
        wait for 10 ns;
    end process;


    
    response_b : process
    begin
        wait until CNTRL_ENABLE_B = '1';
        CNTRL_OCC_B <= '1';
        wait for 10 ns;
        CNTRL_WRT_DONE_B <= '1';
        wait until CNTRL_ENABLE_B = '0';
        CNTRL_WRT_DONE_B <= '0';
        wait for 10 ns;
        CNTRL_MULT_DONE_B <= '1';
        TMP_RESULT_B <= std_logic_vector(unsigned(TMP_RESULT_B) + 1);
        wait until CNTRL_RES_SAVE_B = '1';
        CNTRL_MULT_DONE_B <= '0';
        CNTRL_OCC_B <= '0';
        wait for 10 ns;
    end process;
    
    memory_response : process
    begin
        wait until C_WE = '1';
        C_WD <= '1';
        wait for 10 ns;
        assert C_WE = '0' report "Sistema smette di scrivere" severity note;
        C_WD <= '0';
    end process;
    
    -- Stimuli
    stim_proc: process
    begin
        -- Reset
        RESET <= '1';
        wait for 20 ns;
        RESET <= '0';

        -- Start elaboration
        wait for 20 ns;
        D_DIN(1 downto 0) <= "10";  -- Avvia il calcolo
        wait for clk_period;
        D_DIN(1 downto 0) <= "00";  -- Torna a idle dopo trigger



        -- Fine simulazione
        wait until AND_IT_S_ALL_FOLKS = '1';
        assert false report "Fine simulazione." severity note;
        wait;
    end process;

end tb;
