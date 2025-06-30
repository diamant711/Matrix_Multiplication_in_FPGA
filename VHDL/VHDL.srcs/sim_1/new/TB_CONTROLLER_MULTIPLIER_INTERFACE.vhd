library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TB_CONTROLLER_MULTIPLIER_INTERFACE is
end TB_CONTROLLER_MULTIPLIER_INTERFACE;

architecture tb of TB_CONTROLLER_MULTIPLIER_INTERFACE is

    component CONTROLLER_MULTIPLIER_INTERFACE
        Port (
            CLOCK : in std_logic;
            RESET : in std_logic;

            ROW_SELECT      : out std_logic_vector(6 downto 0);
            COL_SELECT      : out std_logic_vector(6 downto 0);

            CNTRL_CUR_ROW   : in  unsigned(6 downto 0);
            CNTRL_CUR_COL   : in  unsigned(6 downto 0);
            CNTRL_ENABLE    : in  std_logic;
            CNTRL_WRT_DONE  : out std_logic;
            CNTRL_MULT_DONE : out std_logic;
            CNTRL_RES_SAVE  : in  std_logic;
            CNTRL_OCC       : out std_logic;
            TMP_RESULT      : out std_logic_vector(63 downto 0);

            MULT_START      : out std_logic;
            MULT_DONE       : in  std_logic;
            MULT_RESULT     : in  std_logic_vector(63 downto 0);
            MULT_CL_DONE    : in  std_logic
        );
    end component;

    -- Signals
    signal CLOCK           : std_logic := '0';
    signal RESET           : std_logic := '0';

    signal ROW_SELECT      : std_logic_vector(6 downto 0);
    signal COL_SELECT      : std_logic_vector(6 downto 0);

    signal CNTRL_CUR_ROW   : unsigned(6 downto 0) := (others => '0');
    signal CNTRL_CUR_COL   : unsigned(6 downto 0) := (others => '0');
    signal CNTRL_ENABLE    : std_logic := '0';
    signal CNTRL_WRT_DONE  : std_logic;
    signal CNTRL_MULT_DONE : std_logic;
    signal CNTRL_RES_SAVE  : std_logic := '0';
    signal CNTRL_OCC       : std_logic;
    signal TMP_RESULT      : std_logic_vector(63 downto 0);

    signal MULT_START      : std_logic;
    signal MULT_DONE       : std_logic := '0';
    signal MULT_RESULT     : std_logic_vector(63 downto 0) := (others => '0');
    signal MULT_CL_DONE    : std_logic := '0';

    constant clk_period : time := 10 ns;
begin
    -- Clock generation
    CLOCK <= not CLOCK after clk_period / 2;

    -- DUT instantiation
    DUT: CONTROLLER_MULTIPLIER_INTERFACE
        port map (
            CLOCK => CLOCK,
            RESET => RESET,

            ROW_SELECT      => ROW_SELECT,
            COL_SELECT      => COL_SELECT,

            CNTRL_CUR_ROW   => CNTRL_CUR_ROW,
            CNTRL_CUR_COL   => CNTRL_CUR_COL,
            CNTRL_ENABLE    => CNTRL_ENABLE,
            CNTRL_WRT_DONE  => CNTRL_WRT_DONE,
            CNTRL_MULT_DONE => CNTRL_MULT_DONE,
            CNTRL_RES_SAVE  => CNTRL_RES_SAVE,
            CNTRL_OCC       => CNTRL_OCC,
            TMP_RESULT      => TMP_RESULT,

            MULT_START      => MULT_START,
            MULT_DONE       => MULT_DONE,
            MULT_RESULT     => MULT_RESULT,
            MULT_CL_DONE    => MULT_CL_DONE
        );

    -- Stimuli process
    stim_proc: process
    begin
        -- Reset
        RESET <= '1';
        wait for 20 ns;
        RESET <= '0';

        -----------------------------------------------------------------------
        -- Calcolo 1
        -----------------------------------------------------------------------
        CNTRL_CUR_ROW <= to_unsigned(5, 7);
        CNTRL_CUR_COL <= to_unsigned(3, 7);
        CNTRL_ENABLE  <= '1';
        wait for clk_period;
        CNTRL_ENABLE  <= '0';

        wait for 20 ns;
        MULT_CL_DONE <= '1';  -- Fine lettura
        wait for clk_period;
        MULT_CL_DONE <= '0';

        wait for 20 ns;
        MULT_RESULT <= x"00000000000000AA";
        MULT_DONE   <= '1';   -- Fine calcolo
        wait for clk_period;
        MULT_DONE   <= '0';

        wait for 20 ns;
        CNTRL_RES_SAVE <= '1';
        wait for clk_period;
        CNTRL_RES_SAVE <= '0';

        wait for 30 ns;

        -----------------------------------------------------------------------
        -- Calcolo 2
        -----------------------------------------------------------------------
        CNTRL_CUR_ROW <= to_unsigned(8, 7);
        CNTRL_CUR_COL <= to_unsigned(2, 7);
        CNTRL_ENABLE  <= '1';
        wait for clk_period;
        CNTRL_ENABLE  <= '0';

        wait for 20 ns;
        MULT_CL_DONE <= '1';
        wait for clk_period;
        MULT_CL_DONE <= '0';

        wait for 20 ns;
        MULT_RESULT <= x"00000000000000BB";
        MULT_DONE   <= '1';
        wait for clk_period;
        MULT_DONE   <= '0';

        wait for 20 ns;
        CNTRL_RES_SAVE <= '1';
        wait for clk_period;
        CNTRL_RES_SAVE <= '0';

        wait for 50 ns;

        -- Stop simulation
        wait;
    end process;

end tb;
