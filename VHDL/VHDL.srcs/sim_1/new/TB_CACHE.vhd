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
    signal TEST_ADDR : integer range 0 to 100 := 0;

    -- Clock period definition
    constant clk_period : time := 1 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: CACHE
        port map (
            RESET   => RESET,
            CLOCK   => CLOCK,
            ADDR    => ADDR,
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
    
        

        while FLL = '0' loop    
            -- Write to cache
            ADDR <= std_logic_vector(to_unsigned(TEST_ADDR, 7));
            DIN  <= std_logic_vector(to_unsigned(TEST_ADDR, 64));
            WE   <= '1';
            wait until WDONE = '1';
            WE   <= '0';
            wait for clk_period;
            TEST_ADDR <= TEST_ADDR + 1;
        end loop;

        -- Read from cache
        while MPTY = '0' loop
            NE   <= '1';
            wait for clk_period;
            NE   <= '0';
            wait for clk_period;
        end loop;

        wait for 10 ns;
    end process;

end behavior;