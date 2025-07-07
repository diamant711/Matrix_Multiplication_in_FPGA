----------------------------------------------------------------------------------
-- Company: Unimi
-- Engineer: Riccardo Osvaldo Nana, Stefano Pilosio
--
-- Create Date: 06/09/2025 05:06:57 PM
-- Design Name:
-- Module Name: TB_CACHE - v0
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
use IEEE.NUMERIC_STD.ALL;

entity TB_CACHE is
end TB_CACHE;

architecture behavior of TB_CACHE is

    -- Component Declaration for the Unit Under Test (UUT)
    component CACHE
        Port (
            RESET   : in  STD_LOGIC;
            CLOCK   : in  STD_LOGIC;
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

    -- Signals to connect to UUT
    signal RESET     : STD_LOGIC := '0';
    signal CLOCK     : STD_LOGIC := '0';
    signal ADDR      : STD_LOGIC_VECTOR (6 downto 0) := (others => '0');
    signal WE        : STD_LOGIC := '0';
    signal WDONE     : STD_LOGIC;
    signal DIN       : STD_LOGIC_VECTOR (63 downto 0) := (others => '0');
    signal DOUT      : STD_LOGIC_VECTOR (63 downto 0);
    signal MPTY      : STD_LOGIC;
    signal FLL       : STD_LOGIC;
    signal DREADY    : STD_LOGIC;
    signal NE        : STD_LOGIC := '0';
    signal TEST_DATA : integer range 0 to 100 := 0;

    -- Clock period definition
    constant clk_period : time := 1 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: CACHE
        port map (
            RESET   => RESET,
            CLOCK   => CLOCK,
            WE      => WE,
            WDONE   => WDONE,
            DIN     => DIN,
            DOUT    => DOUT,
            MPTY    => MPTY,
            FLL     => FLL,
            DREADY  => DREADY,
            NE      => NE
        );

    -- Clock process definitions
    clk_process :process
    begin
        while true loop
            CLOCK <= '0';
            wait for clk_period/2;
            CLOCK <= '1';
            wait for clk_period/2;
        end loop;
        wait;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Reset
        RESET <= '1';
        wait for 20 ns;
        RESET <= '0';
        wait for clk_period;
    
        

        while TEST_DATA < 99 loop    
            -- Write to cache
            DIN  <= std_logic_vector(to_unsigned(TEST_DATA, 64));
            WE   <= '1';
            wait until WDONE = '1';
            WE   <= '0';
            wait for clk_period;
            TEST_DATA <= TEST_DATA + 1;
        end loop;
        DIN  <= std_logic_vector(to_unsigned(0, 64));
        WE   <= '1';
        wait for clk_period;
        WE   <= '0';
        wait for clk_period;
        DIN <= (others => '0');
        -- Read from cache
        while TEST_DATA >= 0 loop
            NE   <= '1';
            wait for clk_period;
            NE   <= '0';
            wait for clk_period;
            TEST_DATA <= TEST_DATA - 1;
        end loop;

        wait for 10 ns;
    end process;

end behavior;